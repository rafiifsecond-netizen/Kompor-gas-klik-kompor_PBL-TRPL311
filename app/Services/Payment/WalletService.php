<?php

namespace App\Services\Payment;

use App\Models\ActivityLog;
use App\Models\CommissionRecord;
use App\Models\Order;
use App\Models\PayoutRequest;
use App\Models\PlatformSetting;
use App\Models\TechnicianWallet;
use App\Models\User;
use App\Models\WalletTransaction;
use Exception;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class WalletService
{
    /**
     * Dapatkan atau inisialisasi dompet teknisi.
     */
    public function getOrCreateWallet(User $technician): TechnicianWallet
    {
        return TechnicianWallet::firstOrCreate(
            ['technician_id' => $technician->id],
            [
                'balance' => 0,
                'pending_balance' => 0,
            ]
        );
    }

    /**
     * Generate transaction number unik: WTX-YYYYMMDD-XXXXXXXX
     */
    protected function generateTransactionNumber(): string
    {
        do {
            $number = 'WTX-'.date('Ymd').'-'.strtoupper(bin2hex(random_bytes(4)));
        } while (WalletTransaction::where('transaction_number', $number)->exists());

        return $number;
    }

    /**
     * 1. Escrow masuk saat pembayaran non-cash lunas (status paid).
     * Dana ditahan di pending_balance sampai pekerjaan selesai.
     */
    public function holdEscrow(User $technician, int $amount, Order $order): void
    {
        DB::transaction(function () use ($technician, $amount) {
            $wallet = TechnicianWallet::where('technician_id', $technician->id)
                ->lockForUpdate()
                ->firstOrCreate(
                    ['technician_id' => $technician->id],
                    ['balance' => 0, 'pending_balance' => 0]
                );

            $wallet->increment('pending_balance', $amount);
        });
    }

    /**
     * 2. Escrow reversal sebelum completed (misal order dicancel/refund).
     */
    public function reverseEscrow(User $technician, int $amount): void
    {
        DB::transaction(function () use ($technician, $amount) {
            $wallet = TechnicianWallet::where('technician_id', $technician->id)
                ->lockForUpdate()
                ->first();

            if ($wallet && $wallet->pending_balance >= $amount) {
                $wallet->decrement('pending_balance', $amount);
            } elseif ($wallet) {
                $wallet->update(['pending_balance' => 0]);
            }
        });
    }

    /**
     * 3. Rilis escrow ke saldo aktif (completed).
     * - Lepas pending_balance
     * - Kreditkan hak teknisi (N) ke balance
     * - Catat mutasi wallet_transactions
     * - Jalankan auto-netoff jika ada utang cash sebelumnya
     */
    public function releaseEscrowToBalance(
        User $technician,
        Order $order,
        int $technicianNetIncome,
        int $escrowAmountToRelease
    ): void {
        DB::transaction(function () use ($technician, $order, $technicianNetIncome, $escrowAmountToRelease) {
            $wallet = TechnicianWallet::where('technician_id', $technician->id)
                ->lockForUpdate()
                ->firstOrCreate(
                    ['technician_id' => $technician->id],
                    ['balance' => 0, 'pending_balance' => 0]
                );

            // Lepas pending_balance
            $currentPending = (int) $wallet->pending_balance;
            $newPending = max(0, $currentPending - $escrowAmountToRelease);
            $wallet->pending_balance = $newPending;

            // Kreditkan net income ke balance aktif
            $balanceBefore = (int) $wallet->balance;
            $balanceAfter = $balanceBefore + $technicianNetIncome;
            $wallet->balance = $balanceAfter;
            $wallet->save();

            // Catat mutasi kredit
            WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'transaction_number' => $this->generateTransactionNumber(),
                'type' => WalletTransaction::TYPE_CREDIT,
                'amount' => $technicianNetIncome,
                'balance_before' => $balanceBefore,
                'balance_after' => $balanceAfter,
                'reference_type' => 'order_settlement',
                'reference_id' => $order->id,
                'description' => "Pendapatan jasa pesanan #{$order->order_number}",
                'created_at' => now(),
            ]);

            // Evaluasi status suspensi teknisi jika saldo sebelumnya minus
            $this->evaluateTechnicianSuspension($technician, $balanceAfter);
        });
    }

    /**
     * 4. Settlement Pesanan Tunai (Cash):
     * - Teknisi menerima uang tunai langsung dari customer (P).
     * - Hak teknisi N TIDAK dikreditkan ke dompet (karena uang cash fisik sudah dipegang teknisi).
     * - Jika delta > 0 (teknisi berutang komisi delta = C - D):
     *   Debet dompet teknisi sebesar delta. Jika saldo positif ada, terpotong otomatis (net-off FIFO).
     *   Jika saldo kurang, saldo dompet menjadi negatif (utang komisi cash).
     * - Jika delta < 0 (platform berutang subsidi promo ke teknisi |C - D|):
     *   Kredit dompet teknisi sebesar subsidi.
     */
    public function settleCashPayment(
        User $technician,
        Order $order,
        CommissionRecord $commissionRecord
    ): void {
        DB::transaction(function () use ($technician, $order, $commissionRecord) {
            $wallet = TechnicianWallet::where('technician_id', $technician->id)
                ->lockForUpdate()
                ->firstOrCreate(
                    ['technician_id' => $technician->id],
                    ['balance' => 0, 'pending_balance' => 0]
                );

            $direction = $commissionRecord->settlement_direction;
            $amount = (int) $commissionRecord->settlement_amount;

            if ($direction === CommissionRecord::DIRECTION_TECH_PAYS_PLATFORM && $amount > 0) {
                // Teknisi bayar komisi ke platform (debet saldo dompet)
                $balanceBefore = (int) $wallet->balance;
                $balanceAfter = $balanceBefore - $amount;
                $wallet->balance = $balanceAfter;
                $wallet->save();

                WalletTransaction::create([
                    'wallet_id' => $wallet->id,
                    'transaction_number' => $this->generateTransactionNumber(),
                    'type' => WalletTransaction::TYPE_DEBIT,
                    'amount' => $amount,
                    'balance_before' => $balanceBefore,
                    'balance_after' => $balanceAfter,
                    'reference_type' => 'cash_commission_deduction',
                    'reference_id' => $order->id,
                    'description' => "Potongan komisi platform pesanan cash #{$order->order_number}",
                    'created_at' => now(),
                ]);

                $commissionRecord->update([
                    'settlement_status' => CommissionRecord::STATUS_SETTLED,
                    'settled_at' => now(),
                ]);

                $this->evaluateTechnicianSuspension($technician, $balanceAfter);
            } elseif ($direction === CommissionRecord::DIRECTION_PLATFORM_PAYS_TECH && $amount > 0) {
                // Platform bayar subsidi diskon ke teknisi (kredit saldo dompet)
                $balanceBefore = (int) $wallet->balance;
                $balanceAfter = $balanceBefore + $amount;
                $wallet->balance = $balanceAfter;
                $wallet->save();

                WalletTransaction::create([
                    'wallet_id' => $wallet->id,
                    'transaction_number' => $this->generateTransactionNumber(),
                    'type' => WalletTransaction::TYPE_CREDIT,
                    'amount' => $amount,
                    'balance_before' => $balanceBefore,
                    'balance_after' => $balanceAfter,
                    'reference_type' => 'cash_promo_subsidy',
                    'reference_id' => $order->id,
                    'description' => "Subsidi promo pesanan cash #{$order->order_number}",
                    'created_at' => now(),
                ]);

                $commissionRecord->update([
                    'settlement_status' => CommissionRecord::STATUS_SETTLED,
                    'settled_at' => now(),
                ]);

                $this->evaluateTechnicianSuspension($technician, $balanceAfter);
            } else {
                $commissionRecord->update([
                    'settlement_status' => CommissionRecord::STATUS_SETTLED,
                    'settled_at' => now(),
                ]);
            }
        });
    }

    /**
     * 5. Hook Evaluasi Suspensi Teknisi berdasarkan Batas Toleransi Utang Cash.
     * Jika balance < -max_cash_debt_limit => suspend teknisi dari order baru.
     * Jika balance >= -max_cash_debt_limit => un-suspend.
     */
    public function evaluateTechnicianSuspension(User $technician, int $currentBalance): void
    {
        $maxDebtLimit = (int) PlatformSetting::get('max_cash_debt_limit', 200000);

        // Saldo negatif melebihi limit (misal balance = -250.000 vs limit 200.000)
        if ($currentBalance < -$maxDebtLimit) {
            if (! $technician->is_suspended_from_orders) {
                $technician->update(['is_suspended_from_orders' => true]);
                ActivityLog::logEvent(
                    eventName: 'technician.suspended_for_debt',
                    description: "Teknisi #{$technician->id} {$technician->name} disuspend karena utang cash mencapai Rp ".number_format(abs($currentBalance), 0, ',', '.'),
                    entity: $technician
                );
            }
        } else {
            if ($technician->is_suspended_from_orders) {
                $technician->update(['is_suspended_from_orders' => false]);
                ActivityLog::logEvent(
                    eventName: 'technician.unsuspended_from_debt',
                    description: "Teknisi #{$technician->id} {$technician->name} di-unsuspend karena utang cash telah diselesaikan",
                    entity: $technician
                );
            }
        }
    }

    /**
     * Scheduled Job: Evaluasi suspensi seluruh teknisi yang memiliki saldo negatif.
     */
    public function evaluateAllTechniciansSuspension(): int
    {
        $wallets = TechnicianWallet::where('balance', '<', 0)->with('technician')->get();
        $count = 0;
        foreach ($wallets as $wallet) {
            if ($wallet->technician) {
                $this->evaluateTechnicianSuspension($wallet->technician, (int) $wallet->balance);
                $count++;
            }
        }

        return $count;
    }

    /**
     * 6. Payout Request:
     * - Mengunci dan memotong saldo saat request dibuat.
     */
    public function requestPayout(User $technician, int $amount, array $bankDetails): PayoutRequest
    {
        return DB::transaction(function () use ($technician, $amount, $bankDetails) {
            $minPayout = (int) PlatformSetting::get('min_payout_amount', 50000);

            if ($amount < $minPayout) {
                throw ValidationException::withMessages([
                    'amount' => ['Minimum penarikan saldo adalah Rp '.number_format($minPayout, 0, ',', '.').'.'],
                ]);
            }

            $wallet = TechnicianWallet::where('technician_id', $technician->id)
                ->lockForUpdate()
                ->first();

            if (! $wallet || $wallet->balance < $amount) {
                throw ValidationException::withMessages([
                    'amount' => ['Saldo dompet aktif Anda tidak mencukupi untuk melakukan penarikan ini.'],
                ]);
            }

            // Potong saldo aktif dan tahan untuk payout
            $balanceBefore = (int) $wallet->balance;
            $balanceAfter = $balanceBefore - $amount;
            $wallet->balance = $balanceAfter;

            // Simpan detail bank terakhir teknisi
            $wallet->bank_name = $bankDetails['bank_name'];
            $wallet->bank_account_number = $bankDetails['bank_account_number'];
            $wallet->bank_account_holder = $bankDetails['bank_account_holder'];
            $wallet->save();

            $payoutNumber = 'PO-'.date('Ymd').'-'.strtoupper(bin2hex(random_bytes(3)));

            // Catat mutasi debet penahanan saldo
            WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'transaction_number' => $this->generateTransactionNumber(),
                'type' => WalletTransaction::TYPE_DEBIT,
                'amount' => $amount,
                'balance_before' => $balanceBefore,
                'balance_after' => $balanceAfter,
                'reference_type' => 'payout_request',
                'description' => "Pengajuan penarikan dana #{$payoutNumber}",
                'created_at' => now(),
            ]);

            return PayoutRequest::create([
                'payout_number' => $payoutNumber,
                'technician_id' => $technician->id,
                'amount' => $amount,
                'bank_name' => $bankDetails['bank_name'],
                'account_number' => $bankDetails['bank_account_number'] ?? $bankDetails['account_number'],
                'account_holder' => $bankDetails['bank_account_holder'] ?? $bankDetails['account_holder'],
                'status' => PayoutRequest::STATUS_PENDING,
            ]);
        });
    }

    /**
     * 7. Payout Approval (Admin):
     * Wajib melampirkan transfer_proof_url.
     */
    public function approvePayout(PayoutRequest $payout, User $admin, string $transferProofUrl, ?string $adminNotes = null): PayoutRequest
    {
        return DB::transaction(function () use ($payout, $admin, $transferProofUrl, $adminNotes) {
            $lockedPayout = PayoutRequest::where('id', $payout->id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($lockedPayout->status !== PayoutRequest::STATUS_PENDING) {
                throw new Exception('Pengajuan penarikan sudah diproses sebelumnya.');
            }

            $lockedPayout->update([
                'status' => PayoutRequest::STATUS_APPROVED,
                'transfer_proof_url' => $transferProofUrl,
                'admin_notes' => $adminNotes,
                'processed_by' => $admin->id,
                'processed_at' => now(),
            ]);

            ActivityLog::logEvent(
                eventName: 'payout.approved',
                description: "Admin menyetujui penarikan dana #{$lockedPayout->payout_number} sebesar Rp ".number_format($lockedPayout->amount, 0, ',', '.'),
                entity: $lockedPayout,
                actor: $admin
            );

            return $lockedPayout;
        });
    }

    /**
     * 8. Payout Rejection (Admin):
     * Mengembalikan saldo yang sebelumnya ditahan ke dompet teknisi.
     */
    public function rejectPayout(PayoutRequest $payout, User $admin, string $reason): PayoutRequest
    {
        return DB::transaction(function () use ($payout, $admin, $reason) {
            $lockedPayout = PayoutRequest::where('id', $payout->id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($lockedPayout->status !== PayoutRequest::STATUS_PENDING) {
                throw new Exception('Pengajuan penarikan sudah diproses sebelumnya.');
            }

            $wallet = TechnicianWallet::where('technician_id', $lockedPayout->technician_id)
                ->lockForUpdate()
                ->firstOrFail();

            $balanceBefore = (int) $wallet->balance;
            $balanceAfter = $balanceBefore + (int) $lockedPayout->amount;
            $wallet->balance = $balanceAfter;
            $wallet->save();

            // Mutasi kredit pengembalian dana
            WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'transaction_number' => $this->generateTransactionNumber(),
                'type' => WalletTransaction::TYPE_CREDIT,
                'amount' => (int) $lockedPayout->amount,
                'balance_before' => $balanceBefore,
                'balance_after' => $balanceAfter,
                'reference_type' => 'payout_rejection_refund',
                'reference_id' => $lockedPayout->id,
                'description' => "Pengembalian dana penolakan penarikan #{$lockedPayout->payout_number}",
                'created_at' => now(),
            ]);

            $lockedPayout->update([
                'status' => PayoutRequest::STATUS_REJECTED,
                'admin_notes' => $reason,
                'processed_by' => $admin->id,
                'processed_at' => now(),
            ]);

            ActivityLog::logEvent(
                eventName: 'payout.rejected',
                description: "Admin menolak penarikan dana #{$lockedPayout->payout_number}: {$reason}",
                entity: $lockedPayout,
                actor: $admin
            );

            return $lockedPayout;
        });
    }
}
