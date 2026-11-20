<?php

namespace App\Services\Payment;

use App\Models\ActivityLog;
use App\Models\CommissionRecord;
use App\Models\Order;
use App\Models\Payment;
use App\Models\PlatformSetting;
use App\Models\Promo;
use App\Models\User;
use App\Models\WebhookEvent;
use Exception;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class PaymentService
{
    public function __construct(
        protected MidtransService $midtransService,
        protected PromoService $promoService,
        protected CommissionService $commissionService,
        protected WalletService $walletService
    ) {}

    /**
     * Checkout Pembayaran (QRIS, Transfer Manual, atau Cash).
     * Mencegah multiple attempt aktif per order menggunakan lockForUpdate & idempotency key.
     */
    public function checkout(
        Order $order,
        string $paymentMethod,
        ?string $promoCode = null,
        ?string $idempotencyKey = null,
        ?string $senderBankName = null,
        ?string $senderAccountName = null
    ): Payment {
        if (! in_array($paymentMethod, ['qris', 'cash'], true)) {
            throw new Exception('Metode pembayaran transfer bank tidak tersedia. Gunakan QRIS atau tunai.');
        }

        return DB::transaction(function () use (
            $order,
            $paymentMethod,
            $promoCode,
            $idempotencyKey,
            $senderBankName,
            $senderAccountName
        ) {
            // Cek idempotency key jika dikirimkan
            if (! empty($idempotencyKey)) {
                $existingByIdempotency = Payment::where('idempotency_key', $idempotencyKey)->first();
                if ($existingByIdempotency) {
                    return $existingByIdempotency;
                }
            }

            // Lock order
            $order = Order::where('id', $order->id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($order->status === Order::STATUS_COMPLETED || $order->status === Order::STATUS_CANCELLED) {
                throw new Exception('Pesanan sudah selesai atau dibatalkan, tidak dapat dibayar.');
            }

            if ($order->payment_status === 'paid' || Payment::where('order_id', $order->id)
                ->where('payment_status', Payment::STATUS_PAID)
                ->exists()) {
                throw new Exception('Pesanan ini sudah memiliki pembayaran yang berhasil.');
            }

            // Batalkan attempt aktif sebelumnya jika ada (misal retry pembayaran baru)
            $activePayment = Payment::where('order_id', $order->id)
                ->whereIn('payment_status', [
                    Payment::STATUS_PENDING,
                    Payment::STATUS_AWAITING_VERIFICATION,
                ])
                ->lockForUpdate()
                ->first();

            if ($activePayment) {
                if ($activePayment->gateway_provider === 'midtrans' && $activePayment->gateway_order_id) {
                    try {
                        $this->midtransService->cancelTransaction($activePayment->gateway_order_id);
                    } catch (Exception $e) {
                        Log::warning("Gagal membatalkan attempt QRIS lama: {$e->getMessage()}");
                    }
                }

                $activePayment->update([
                    'payment_status' => Payment::STATUS_CANCELLED,
                ]);
            }

            // Reservasi Promo jika ada kode promo
            $discountAmount = 0;
            if (! empty($promoCode)) {
                $promoUsage = $this->promoService->reservePromo($order, $promoCode, $paymentMethod);
                $discountAmount = $promoUsage->discount_applied;
            } else {
                // Jika tidak kirim promo, lepas reservasi promo lama jika ada
                $this->promoService->releasePromo($order);
            }

            // Hitung struktur finansial
            $commissionPercent = PlatformSetting::get('platform_commission_percent', '5.00');
            $roundingMode = PlatformSetting::get('rounding_mode', 'round');
            $roundingUnit = (int) PlatformSetting::get('rounding_unit', 1);

            $calc = FinancialCalculator::calculate(
                serviceSubtotal: (int) $order->subtotal,
                transportFee: (int) $order->transport_fee,
                discountAmount: $discountAmount,
                commissionPercent: $commissionPercent,
                roundingMode: $roundingMode,
                roundingUnit: $roundingUnit
            );

            // Update nilai diskon & total_amount di order
            $order->update([
                'discount' => $calc->discountAmount,
                'total_amount' => $calc->paymentAmount,
                'payment_method' => $paymentMethod,
            ]);

            $paymentNumber = 'PAY-'.date('Ymd').'-'.strtoupper(bin2hex(random_bytes(4)));
            $gatewayOrderId = 'KP-'.$order->id.'-'.date('YmdHis').'-'.strtoupper(Str::random(4));

            $payment = new Payment([
                'order_id' => $order->id,
                'customer_id' => $order->customer_id,
                'payment_number' => $paymentNumber,
                'idempotency_key' => $idempotencyKey,
                'payment_method' => $paymentMethod,
                'amount' => $calc->paymentAmount,
                'payment_status' => Payment::STATUS_PENDING,
            ]);

            if ($paymentMethod === 'qris') {
                $expiryMinutes = (int) PlatformSetting::get('qris_expiry_minutes', 15);
                $payment->gateway_provider = 'midtrans';
                $payment->gateway_order_id = $gatewayOrderId;
                $payment->expires_at = now()->addMinutes($expiryMinutes);

                // Charge Midtrans Core API
                $chargeResult = $this->midtransService->chargeQris(
                    gatewayOrderId: $gatewayOrderId,
                    grossAmount: $calc->paymentAmount,
                    expiryMinutes: $expiryMinutes
                );

                $payment->gateway_transaction_id = $chargeResult['transaction_id'] ?? null;
                $payment->qris_qr_string = $chargeResult['extracted_qr_string'] ?? ($chargeResult['qr_string'] ?? null);
                $payment->qris_qr_url = $chargeResult['extracted_qr_url'] ?? null;
                $payment->payload = $chargeResult;
            } elseif ($paymentMethod === 'transfer') {
                $expiryHours = (int) PlatformSetting::get('manual_transfer_expiry_hours', 24);
                $payment->gateway_provider = 'midtrans';
                $payment->gateway_order_id = $gatewayOrderId;
                $payment->bank_name = strtolower($senderBankName ?? 'bca');
                $payment->sender_bank_name = $senderBankName ?? 'BCA';
                $payment->sender_account_name = $senderAccountName;
                $payment->expires_at = now()->addHours($expiryHours);

                // Charge Midtrans Bank Transfer (Virtual Account)
                $chargeResult = $this->midtransService->chargeBankTransfer(
                    bank: $senderBankName ?? 'bca',
                    gatewayOrderId: $gatewayOrderId,
                    grossAmount: $calc->paymentAmount,
                    expiryHours: $expiryHours
                );

                $payment->gateway_transaction_id = $chargeResult['transaction_id'] ?? null;
                $payment->va_number = $chargeResult['extracted_va_number'] ?? null;
                $payment->biller_code = $chargeResult['biller_code'] ?? null;
                $payment->bill_key = $chargeResult['bill_key'] ?? null;
                $payment->payload = $chargeResult;
            } elseif ($paymentMethod === 'cash') {
                $payment->gateway_provider = 'cash';
                $payment->expires_at = now()->addDays(7); // Toleransi waktu penyelesaian servis tunai
            }

            $payment->save();

            // Buat snapshot catatan komisi
            $this->commissionService->createCommissionRecord(
                order: $order,
                paymentMethod: $paymentMethod,
                payment: $payment,
                discountAmount: $calc->discountAmount
            );

            ActivityLog::logEvent(
                eventName: 'payment.created',
                description: "Pembayaran #{$payment->payment_number} dibuat untuk pesanan #{$order->order_number} ({$paymentMethod})",
                entity: $payment
            );

            return $payment;
        });
    }

    /**
     * Upload Bukti Transfer Manual oleh Pelanggan.
     */
    public function uploadTransferProof(
        Payment $payment,
        UploadedFile $file,
        ?string $senderBankName = null,
        ?string $senderAccountName = null
    ): Payment {
        return DB::transaction(function () use ($payment, $file, $senderBankName, $senderAccountName) {
            $payment = Payment::where('id', $payment->id)->lockForUpdate()->firstOrFail();

            if ($payment->payment_method !== 'transfer') {
                throw new Exception('Hanya pembayaran metode transfer yang membutuhkan bukti transfer.');
            }

            if ($payment->payment_status === Payment::STATUS_PAID) {
                throw new Exception('Pembayaran ini sudah diverifikasi lunas.');
            }

            if ($payment->expires_at && now()->gt($payment->expires_at)) {
                $payment->update(['payment_status' => Payment::STATUS_EXPIRED]);
                throw new Exception('Batas waktu unggah bukti transfer telah kedaluwarsa.');
            }

            // Simpan file ke disk private lokal
            $filename = Str::uuid().'.'.$file->getClientOriginalExtension();
            $path = $file->storeAs('payment_proofs', $filename, 'local');

            $payment->update([
                'proof_url' => $path,
                'proof_uploaded_at' => now(),
                'sender_bank_name' => $senderBankName ?? $payment->sender_bank_name,
                'sender_account_name' => $senderAccountName ?? $payment->sender_account_name,
                'payment_status' => Payment::STATUS_AWAITING_VERIFICATION,
                'rejection_reason' => null,
            ]);

            ActivityLog::logEvent(
                eventName: 'payment.proof_uploaded',
                description: "Bukti transfer diunggah untuk pembayaran #{$payment->payment_number}",
                entity: $payment
            );

            return $payment;
        });
    }

    /**
     * Verifikasi Transfer Manual oleh Admin.
     */
    public function verifyManualTransfer(
        Payment $payment,
        User $admin,
        bool $isApproved,
        ?string $rejectionReason = null
    ): Payment {
        return DB::transaction(function () use ($payment, $admin, $isApproved, $rejectionReason) {
            $payment = Payment::where('id', $payment->id)->lockForUpdate()->firstOrFail();

            if ($payment->payment_method !== 'transfer') {
                throw new Exception('Pembayaran bukan metode transfer manual.');
            }

            if ($payment->payment_status === Payment::STATUS_PAID) {
                return $payment; // Idempotent
            }

            if (! $isApproved && empty(trim((string) $rejectionReason))) {
                throw ValidationException::withMessages([
                    'rejection_reason' => ['Alasan penolakan wajib diisi saat menolak bukti pembayaran.'],
                ]);
            }

            $order = Order::where('id', $payment->order_id)->lockForUpdate()->firstOrFail();

            if ($isApproved) {
                $payment->update([
                    'payment_status' => Payment::STATUS_PAID,
                    'paid_at' => now(),
                    'verified_by' => $admin->id,
                    'verified_at' => now(),
                    'rejection_reason' => null,
                ]);

                $order->update(['payment_status' => 'paid']);

                // Tandai promo used
                $this->promoService->markUsed($order);

                // Masukkan escrow ke dompet teknisi jika teknisi sudah ditugaskan
                if ($order->technician_id) {
                    $technician = User::find($order->technician_id);
                    if ($technician) {
                        $this->walletService->holdEscrow($technician, (int) $payment->amount, $order);
                    }
                }

                ActivityLog::logEvent(
                    eventName: 'payment.manual_approved',
                    description: "Admin menyetujui transfer manual #{$payment->payment_number}",
                    entity: $payment,
                    actor: $admin
                );
            } else {
                $payment->update([
                    'payment_status' => Payment::STATUS_FAILED,
                    'verified_by' => $admin->id,
                    'verified_at' => now(),
                    'rejection_reason' => $rejectionReason,
                ]);

                // Lepas kuota promo
                $this->promoService->releasePromo($order);

                ActivityLog::logEvent(
                    eventName: 'payment.manual_rejected',
                    description: "Admin menolak transfer manual #{$payment->payment_number}: {$rejectionReason}",
                    entity: $payment,
                    actor: $admin
                );
            }

            return $payment;
        });
    }

    /**
     * Konfirmasi Pembayaran Cash oleh Teknisi.
     */
    public function confirmCashPayment(
        Payment $payment,
        User $technician,
        int $amountReceived
    ): Payment {
        return DB::transaction(function () use ($payment, $technician, $amountReceived) {
            $payment = Payment::where('id', $payment->id)->lockForUpdate()->firstOrFail();

            if ($payment->payment_method !== 'cash') {
                throw new Exception('Bukan pembayaran cash.');
            }

            if ($payment->payment_status === Payment::STATUS_PAID) {
                return $payment; // Idempotent
            }

            if ($amountReceived !== (int) $payment->amount) {
                throw ValidationException::withMessages([
                    'amount_received' => [
                        'Nominal tunai yang diterima (Rp '.number_format($amountReceived, 0, ',', '.').
                        ') harus sama persis dengan total tagihan (Rp '.number_format($payment->amount, 0, ',', '.').').',
                    ],
                ]);
            }

            $order = Order::where('id', $payment->order_id)->lockForUpdate()->firstOrFail();

            if ($order->technician_id !== $technician->id) {
                throw new Exception('Hanya teknisi yang bertugas pada pesanan ini yang dapat mengonfirmasi uang tunai.');
            }

            $payment->update([
                'payment_status' => Payment::STATUS_PAID,
                'paid_at' => now(),
                'verified_by' => $technician->id,
                'verified_at' => now(),
            ]);

            $order->update(['payment_status' => 'paid']);

            // Tandai promo used
            $this->promoService->markUsed($order);

            // Jalankan settlement komisi tunai dua arah di dompet teknisi
            $commissionRecord = CommissionRecord::where('order_id', $order->id)->first();
            if ($commissionRecord) {
                $this->walletService->settleCashPayment($technician, $order, $commissionRecord);
            }

            ActivityLog::logEvent(
                eventName: 'payment.cash_confirmed',
                description: "Teknisi mengonfirmasi pembayaran cash #{$payment->payment_number} sebesar Rp ".number_format($amountReceived, 0, ',', '.'),
                entity: $payment,
                actor: $technician
            );

            return $payment;
        });
    }

    /**
     * Verifikasi Pembayaran Cash oleh Admin.
     */
    public function verifyCashPaymentByAdmin(
        Payment $payment,
        User $admin,
        bool $isApproved,
        ?string $notes = null
    ): Payment {
        return DB::transaction(function () use ($payment, $admin, $isApproved, $notes) {
            $payment = Payment::where('id', $payment->id)->lockForUpdate()->firstOrFail();

            if ($payment->payment_method !== 'cash') {
                throw new Exception('Bukan transaksi tunai (cash).');
            }

            if ($payment->payment_status === Payment::STATUS_PAID) {
                return $payment; // Idempotent
            }

            $order = Order::where('id', $payment->order_id)->lockForUpdate()->firstOrFail();

            if ($isApproved) {
                $payment->update([
                    'payment_status' => Payment::STATUS_PAID,
                    'paid_at' => now(),
                    'verified_by' => $admin->id,
                    'verified_at' => now(),
                    'rejection_reason' => $notes ? "Admin Note: {$notes}" : null,
                ]);

                $order->update(['payment_status' => 'paid']);

                // Tandai promo used
                $this->promoService->markUsed($order);

                // Settlement komisi tunai di dompet teknisi jika teknisi sudah ditugaskan
                if ($order->technician_id) {
                    $technician = User::find($order->technician_id);
                    $commissionRecord = CommissionRecord::where('order_id', $order->id)->first();
                    if ($technician && $commissionRecord) {
                        $this->walletService->settleCashPayment($technician, $order, $commissionRecord);
                    }
                }

                ActivityLog::logEvent(
                    eventName: 'payment.cash_admin_verified',
                    description: "Admin memverifikasi pembayaran tunai #{$payment->payment_number} untuk pesanan #{$order->order_number}",
                    entity: $payment,
                    actor: $admin
                );
            } else {
                $payment->update([
                    'payment_status' => Payment::STATUS_FAILED,
                    'verified_by' => $admin->id,
                    'verified_at' => now(),
                    'rejection_reason' => $notes ?? 'Ditolak oleh admin',
                ]);

                $this->promoService->releasePromo($order);

                ActivityLog::logEvent(
                    eventName: 'payment.cash_admin_rejected',
                    description: "Admin menolak konfirmasi pembayaran tunai #{$payment->payment_number}",
                    entity: $payment,
                    actor: $admin
                );
            }

            return $payment;
        });
    }

    /**
     * Handle Webhook Midtrans.
     * Idempoten: pengiriman webhook berulang kali menghasilkan respon aman tanpa kredit ganda.
     */
    public function handleWebhook(array $payload): array
    {
        $orderId = $payload['order_id'] ?? '';
        $statusCode = $payload['status_code'] ?? '';
        $grossAmount = $payload['gross_amount'] ?? '';
        $signatureKey = $payload['signature_key'] ?? '';
        $transactionStatus = $payload['transaction_status'] ?? '';
        $fraudStatus = $payload['fraud_status'] ?? '';
        $transactionId = $payload['transaction_id'] ?? '';

        // Cek apakah webhook event identik sudah pernah diterima sebelumnya (Idempotensi Webhook Gateway)
        if (! empty($transactionId) && ! empty($transactionStatus)) {
            $existingDuplicate = WebhookEvent::where('gateway_transaction_id', $transactionId)
                ->where('transaction_status', $transactionStatus)
                ->first();

            if ($existingDuplicate) {
                return [
                    'success' => true,
                    'message' => 'Duplicate webhook event ignored idempotently.',
                ];
            }

        }

        // Catat raw webhook event
        $isValidSignature = $this->midtransService->verifyWebhookSignature(
            $orderId,
            $statusCode,
            $grossAmount,
            $signatureKey
        );

        $webhookEvent = WebhookEvent::create([
            'order_id' => null,
            'payment_id' => null,
            'gateway_provider' => 'midtrans',
            'gateway_order_id' => $orderId,
            'gateway_transaction_id' => $transactionId ?: ('TX-'.Str::uuid()),
            'transaction_status' => $transactionStatus ?: 'unknown',
            'signature_valid' => $isValidSignature,
            'is_processed' => false,
            'flagged_for_manual_refund' => false,
            'payload' => $payload,
            'created_at' => now(),
        ]);

        if (! $isValidSignature) {
            Log::warning("Midtrans Webhook: Invalid Signature for order {$orderId}");

            return ['success' => false, 'message' => 'Invalid signature', 'code' => 403];
        }

        // Cari pembayaran berdasarkan gateway_order_id
        $payment = Payment::where('gateway_order_id', $orderId)->first();

        if (! $payment) {
            Log::warning("Midtrans Webhook: Payment not found for {$orderId}");

            return ['success' => false, 'message' => 'Payment not found', 'code' => 404];
        }

        $webhookEvent->update([
            'order_id' => $payment->order_id,
            'payment_id' => $payment->id,
        ]);

        // Verifikasi kesesuaian gross_amount dengan nilai di database
        // Format Midtrans gross_amount bisa berupa '120000.00' atau '120000'
        $payloadAmount = (int) explode('.', $grossAmount)[0];
        if ($payloadAmount !== (int) $payment->amount) {
            Log::error("Midtrans Webhook: Amount mismatch for {$orderId}. Expected {$payment->amount}, got {$payloadAmount}");

            return ['success' => false, 'message' => 'Amount mismatch', 'code' => 400];
        }

        return DB::transaction(function () use ($payment, $transactionStatus, $fraudStatus, $payload, $webhookEvent) {
            $payment = Payment::where('id', $payment->id)->lockForUpdate()->first();
            $order = Order::where('id', $payment->order_id)->lockForUpdate()->first();

            // Cek jika payment sudah pernah paid sebelumnya (Idempotensi webhook)
            if ($payment->payment_status === Payment::STATUS_PAID) {
                $webhookEvent->update(['is_processed' => true, 'processed_at' => now()]);

                return ['success' => true, 'message' => 'Payment already settled previously.'];
            }

            // Jika order sudah memiliki pembayaran aktif lain yang sudah lunas (late webhook from old attempt)
            $otherPaid = Payment::where('order_id', $payment->order_id)
                ->where('id', '!=', $payment->id)
                ->where('payment_status', Payment::STATUS_PAID)
                ->exists();

            if ($otherPaid) {
                // Tandai flagged_for_manual_refund
                $webhookEvent->update([
                    'is_processed' => true,
                    'flagged_for_manual_refund' => true,
                    'processed_at' => now(),
                ]);
                $payment->update([
                    'payment_status' => Payment::STATUS_CANCELLED,
                    'payload' => $payload,
                ]);
                Log::warning("Midtrans Webhook: Flagged for manual refund because order #{$order->id} already paid via another attempt.");

                return ['success' => true, 'message' => 'Flagged for manual refund.'];
            }

            if ($transactionStatus === 'settlement' || ($transactionStatus === 'capture' && $fraudStatus === 'accept')) {
                $payment->update([
                    'payment_status' => Payment::STATUS_PAID,
                    'paid_at' => now(),
                    'payload' => $payload,
                ]);

                $order->update(['payment_status' => 'paid']);

                // Tandai promo used
                $this->promoService->markUsed($order);

                // Masukkan dana escrow ke pending_balance teknisi jika teknisi sudah diassign
                if ($order->technician_id) {
                    $technician = User::find($order->technician_id);
                    if ($technician) {
                        $this->walletService->holdEscrow($technician, (int) $payment->amount, $order);
                    }
                }

                $webhookEvent->update(['is_processed' => true, 'processed_at' => now()]);

                ActivityLog::logEvent(
                    eventName: 'payment.webhook_settled',
                    description: "Midtrans webhook settlement untuk pembayaran #{$payment->payment_number}",
                    entity: $payment
                );
            } elseif (in_array($transactionStatus, ['expire', 'cancel', 'deny'], true)) {
                $newStatus = ($transactionStatus === 'expire') ? Payment::STATUS_EXPIRED : Payment::STATUS_FAILED;
                $payment->update([
                    'payment_status' => $newStatus,
                    'payload' => $payload,
                ]);

                // Lepaskan reservasi promo
                $this->promoService->releasePromo($order);

                $webhookEvent->update(['is_processed' => true, 'processed_at' => now()]);
            }

            return ['success' => true, 'message' => 'Webhook processed successfully.'];
        });
    }

    /**
     * Apply a terminal gateway status while releasing any reserved promo.
     */
    public function markGatewayStatus(Payment $payment, string $transactionStatus): void
    {
        DB::transaction(function () use ($payment, $transactionStatus): void {
            $lockedPayment = Payment::whereKey($payment->id)->lockForUpdate()->firstOrFail();
            if ($lockedPayment->payment_status !== Payment::STATUS_PENDING) {
                return;
            }

            $status = $transactionStatus === 'expire'
                ? Payment::STATUS_EXPIRED
                : Payment::STATUS_FAILED;
            $lockedPayment->update(['payment_status' => $status]);

            $order = Order::find($lockedPayment->order_id);
            if ($order) {
                $this->promoService->releasePromo($order);
            }
        });
    }

    /**
     * Refund Pembayaran (Hanya Admin).
     */
    public function refund(Payment $payment, User $admin, string $reason): Payment
    {
        return DB::transaction(function () use ($payment, $admin, $reason) {
            $payment = Payment::where('id', $payment->id)->lockForUpdate()->firstOrFail();

            if ($payment->payment_status !== Payment::STATUS_PAID) {
                throw new Exception('Hanya pembayaran yang berstatus lunas (paid) yang dapat di-refund.');
            }

            $order = Order::where('id', $payment->order_id)->lockForUpdate()->firstOrFail();

            if ($payment->gateway_provider === 'midtrans' && $payment->gateway_order_id) {
                $this->midtransService->refundTransaction(
                    gatewayOrderId: $payment->gateway_order_id,
                    amount: (int) $payment->amount,
                    reason: $reason
                );
            }

            $payment->update([
                'payment_status' => Payment::STATUS_REFUNDED,
                'rejection_reason' => "Refund: {$reason}",
            ]);

            $order->update(['payment_status' => 'refunded']);

            // Jika order belum selesai (belum completed), tarik kembali escrow dari pending_balance
            // Jika order sudah selesai (completed), tarik kembali hak teknisi dari saldo aktif (saldo minus jadi utang)
            if ($order->technician_id) {
                $technician = User::find($order->technician_id);
                if ($technician) {
                    if ($order->status !== Order::STATUS_COMPLETED) {
                        $this->walletService->reverseEscrow($technician, (int) $payment->amount);
                    } else {
                        $commissionRecord = CommissionRecord::where('order_id', $order->id)->first();
                        $techNet = $commissionRecord ? (int) $commissionRecord->technician_net_income : (int) $payment->amount;
                        $this->walletService->reverseCompletedSettlement($technician, $order, $techNet, $reason);
                    }
                }
            }

            // Lepas reservasi/pemakaian promo
            $this->promoService->releasePromo($order);

            ActivityLog::logEvent(
                eventName: 'payment.refunded',
                description: "Admin merefund pembayaran #{$payment->payment_number} sebesar Rp ".number_format($payment->amount, 0, ',', '.').": {$reason}",
                entity: $payment,
                actor: $admin
            );

            return $payment;
        });
    }

    /**
     * Scheduled Job: Otomatis kedaluwarsa-kan pembayaran pending yang melewati expires_at.
     */
    public function expirePendingPayments(): int
    {
        $expiredPayments = Payment::where('payment_status', Payment::STATUS_PENDING)
            ->whereNotNull('expires_at')
            ->where('expires_at', '<', now())
            ->get();

        $count = 0;
        foreach ($expiredPayments as $p) {
            DB::transaction(function () use ($p) {
                $payment = Payment::where('id', $p->id)->lockForUpdate()->first();
                if ($payment && $payment->payment_status === Payment::STATUS_PENDING) {
                    $payment->update(['payment_status' => Payment::STATUS_EXPIRED]);
                    $order = Order::find($payment->order_id);
                    if ($order) {
                        $this->promoService->releasePromo($order);
                    }
                }
            });
            $count++;
        }

        return $count;
    }
}
