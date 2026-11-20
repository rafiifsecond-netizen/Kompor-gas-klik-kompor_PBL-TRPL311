<?php

namespace Database\Seeders;

use App\Models\CommissionRecord;
use App\Models\Order;
use App\Models\Payment;
use App\Models\Promo;
use App\Models\TechnicianWallet;
use App\Models\User;
use App\Models\WalletTransaction;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class PaymentSpecificationSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Seed Promos
        $promo1 = Promo::firstOrCreate(
            ['code' => 'HEMAT20'],
            [
                'name' => 'Diskon 20% Servis Kompor',
                'description' => 'Potongan 20% maksimal Rp 30.000 untuk semua layanan servis kompor.',
                'type' => 'percentage',
                'discount_amount' => 20,
                'max_discount' => 30000,
                'min_order_amount' => 50000,
                'start_date' => now()->subDays(2),
                'end_date' => now()->addDays(30),
                'total_quota' => 100,
                'quota_per_user' => 2,
                'is_active' => true,
            ]
        );

        $promo2 = Promo::firstOrCreate(
            ['code' => 'BERSIH30'],
            [
                'name' => 'Voucher Kompor Bersih 30K',
                'description' => 'Potongan langsung Rp 30.000 minimal order Rp 75.000.',
                'type' => 'fixed',
                'discount_amount' => 30000,
                'max_discount' => null,
                'min_order_amount' => 75000,
                'start_date' => now()->subDays(5),
                'end_date' => now()->addDays(60),
                'total_quota' => 50,
                'quota_per_user' => 1,
                'is_active' => true,
            ]
        );

        // 2. Buat Dummy Bukti Transfer Gambar
        $proofDir = 'payment_proofs';
        if (! Storage::disk('local')->exists($proofDir)) {
            Storage::disk('local')->makeDirectory($proofDir);
        }
        $sampleProofPath = "{$proofDir}/sample_transfer_proof.png";
        if (! Storage::disk('local')->exists($sampleProofPath)) {
            // Buat gambar PNG 1x1 transparan sebagai file bukti transfer fisik
            $pngHeader = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
            Storage::disk('local')->put($sampleProofPath, $pngHeader);
        }

        // 3. Seed Dompet Teknisi
        $technicians = User::where('role', 'technician')->get();
        foreach ($technicians as $tech) {
            $wallet = TechnicianWallet::firstOrCreate(
                ['technician_id' => $tech->id],
                [
                    'balance' => 250000,
                    'pending_balance' => 85000,
                    'bank_name' => 'BCA',
                    'bank_account_number' => '8040' . rand(10000000, 99999999),
                    'bank_account_holder' => $tech->name,
                ]
            );

            // Mutasi awal
            if (WalletTransaction::where('wallet_id', $wallet->id)->count() === 0) {
                WalletTransaction::create([
                    'wallet_id' => $wallet->id,
                    'transaction_number' => 'WTX-' . date('Ymd') . '-' . strtoupper(bin2hex(random_bytes(4))),
                    'type' => WalletTransaction::TYPE_CREDIT,
                    'amount' => 250000,
                    'balance_before' => 0,
                    'balance_after' => 250000,
                    'reference_type' => 'order_settlement',
                    'reference_id' => 1,
                    'description' => 'Pendapatan jasa servis kompor sebelumnya',
                    'created_at' => now()->subDays(2),
                ]);
            }
        }

        // 4. Seed Pembayaran Demo untuk Pesanan yang Ada
        $orders = Order::orderBy('id')->get();
        $admin = User::where('role', 'admin')->first();

        foreach ($orders as $idx => $order) {
            if (Payment::where('order_id', $order->id)->exists()) {
                continue;
            }

            $amount = (int) ($order->total_amount ?: ($order->subtotal + $order->transport_fee));
            $paymentNumber = 'PAY-' . date('Ymd') . '-' . str_pad((string) ($idx + 10), 4, '0', STR_PAD_LEFT);

            // Variasi status pembayaran untuk demonstrasi
            if ($idx === 1) {
                // Awaiting Verification (Transfer Manual siap diverifikasi Admin)
                Payment::create([
                    'order_id' => $order->id,
                    'customer_id' => $order->customer_id,
                    'payment_number' => $paymentNumber,
                    'payment_method' => 'transfer',
                    'amount' => $amount,
                    'payment_status' => Payment::STATUS_AWAITING_VERIFICATION,
                    'sender_bank_name' => 'BCA',
                    'sender_account_name' => $order->customer_name ?: 'Pelanggan BCA',
                    'proof_url' => $sampleProofPath,
                    'proof_uploaded_at' => now()->subMinutes(30),
                    'expires_at' => now()->addHours(23),
                    'created_at' => now()->subMinutes(45),
                ]);
            } elseif ($idx === 2) {
                // QRIS Pending dengan QR String Midtrans
                Payment::create([
                    'order_id' => $order->id,
                    'customer_id' => $order->customer_id,
                    'payment_number' => $paymentNumber,
                    'payment_method' => 'qris',
                    'amount' => $amount,
                    'payment_status' => Payment::STATUS_PENDING,
                    'gateway_provider' => 'midtrans',
                    'gateway_order_id' => 'KP-' . $order->id . '-' . date('YmdHis'),
                    'gateway_transaction_id' => 'mid-demo-' . Str::random(8),
                    'qris_qr_string' => '00020101021226670016ID.CO.MIDTRANS.WWW01189360091800000000005204581253033605802ID5909KLIKKOMPOR6007JAKARTA61051234062070703A016304DEMO',
                    'expires_at' => now()->addMinutes(12),
                    'created_at' => now()->subMinutes(3),
                ]);
            } elseif ($idx === 3) {
                // Cash Paid
                $payment = Payment::create([
                    'order_id' => $order->id,
                    'customer_id' => $order->customer_id,
                    'payment_number' => $paymentNumber,
                    'payment_method' => 'cash',
                    'amount' => $amount,
                    'payment_status' => Payment::STATUS_PAID,
                    'paid_at' => now()->subHours(4),
                    'created_at' => now()->subHours(5),
                ]);

                $rec = app(\App\Services\Payment\CommissionService::class)->createCommissionRecord(
                    order: $order,
                    paymentMethod: 'cash',
                    payment: $payment,
                    discountAmount: (int) ($order->discount ?? 0)
                );
                $rec->update([
                    'settlement_status' => CommissionRecord::STATUS_SETTLED,
                    'settled_at' => now()->subHours(4),
                ]);
            } elseif ($idx >= 4) {
                // Lunas Transfer
                Payment::create([
                    'order_id' => $order->id,
                    'customer_id' => $order->customer_id,
                    'payment_number' => $paymentNumber,
                    'payment_method' => 'transfer',
                    'amount' => $amount,
                    'payment_status' => Payment::STATUS_PAID,
                    'sender_bank_name' => 'Mandiri',
                    'sender_account_name' => $order->customer_name ?: 'Pelanggan Mandiri',
                    'proof_url' => $sampleProofPath,
                    'proof_uploaded_at' => now()->subDays(1),
                    'verified_by' => $admin?->id,
                    'verified_at' => now()->subDays(1)->addMinutes(15),
                    'paid_at' => now()->subDays(1)->addMinutes(15),
                    'created_at' => now()->subDays(1)->addMinutes(10),
                ]);
            }
        }
    }
}
