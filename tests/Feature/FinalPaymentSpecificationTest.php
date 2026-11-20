<?php

namespace Tests\Feature;

use App\Models\CommissionRecord;
use App\Models\Order;
use App\Models\Payment;
use App\Models\PayoutRequest;
use App\Models\PlatformSetting;
use App\Models\Promo;
use App\Models\PromoUsage;
use App\Models\ServiceItem;
use App\Models\TechnicianWallet;
use App\Models\User;
use App\Models\WalletTransaction;
use App\Models\WebhookEvent;
use App\Services\Payment\FinancialCalculator;
use App\Services\Payment\MidtransService;
use App\Services\Payment\PaymentService;
use App\Services\Payment\WalletService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class FinalPaymentSpecificationTest extends TestCase
{
    use RefreshDatabase;

    protected User $customer;
    protected User $technician;
    protected User $admin;
    protected Order $order;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed();

        $this->customer = User::where('email', 'budi@example.com')->first()
            ?? User::factory()->create(['role' => 'customer', 'email' => 'budi@example.com']);
        $this->technician = User::where('email', 'agus@example.com')->first()
            ?? User::factory()->create(['role' => 'technician', 'email' => 'agus@example.com']);
        $this->admin = User::where('email', 'admin@klikkompor.com')->first()
            ?? User::factory()->create(['role' => 'admin', 'email' => 'admin@klikkompor.com']);

        // Pastikan teknisi punya profil
        if (! $this->technician->technicianProfile) {
            $this->technician->technicianProfile()->create([
                'bio' => 'Teknisi Berpengalaman',
                'years_of_experience' => 5,
                'is_verified' => true,
                'is_available' => true,
            ]);
        }

        // Buat pesanan standar untuk pengujian: Subtotal jasa = 100.000, Transport = 20.000
        $this->order = Order::create([
            'order_number' => 'KP-TEST-' . bin2hex(random_bytes(3)),
            'customer_id' => $this->customer->id,
            'technician_id' => $this->technician->id,
            'status' => Order::STATUS_ACCEPTED,
            'scheduled_at' => now()->addDay(),
            'customer_name' => $this->customer->name,
            'customer_phone' => $this->customer->phone ?? '08123456789',
            'address' => 'Jl. Pengujian No. 123',
            'problem_description' => 'Kompor mati total',
            'subtotal' => 100000,
            'transport_fee' => 20000,
            'discount' => 0,
            'total_amount' => 120000,
            'payment_method' => 'qris',
            'payment_status' => 'unpaid',
        ]);

        Http::fake([
            'https://api.sandbox.midtrans.com/v2/charge' => Http::response([
                'status_code' => '201',
                'status_message' => 'Success, QRIS transaction is created',
                'transaction_id' => 'mid-tx-mock-12345',
                'order_id' => 'KP-TEST-ORDER',
                'gross_amount' => '120000.00',
                'payment_type' => 'qris',
                'transaction_status' => 'pending',
                'actions' => [
                    [
                        'name' => 'generate-qr-code',
                        'method' => 'GET',
                        'url' => 'https://api.sandbox.midtrans.com/v2/qris/123/qr-code',
                    ],
                ],
                'qr_string' => '00020101021226670016ID.CO.MIDTRANS.WWW01189360091800000000005204581253033605802ID5909KLIKKOMPOR6007JAKARTA61051234062070703A016304MOCK',
            ], 201),
            'https://api.sandbox.midtrans.com/v2/*/cancel' => Http::response([
                'status_code' => '200',
                'status_message' => 'Success, transaction is canceled',
            ], 200),
            'https://api.sandbox.midtrans.com/v2/*/status' => Http::response([
                'status_code' => '200',
                'transaction_status' => 'pending',
            ], 200),
        ]);
    }

    /*
    |--------------------------------------------------------------------------
    | BAGIAN B: PEMBAYARAN - QRIS, Midtrans Webhook, Transfer, Cash
    |--------------------------------------------------------------------------
    */

    /**
     * Test QRIS Checkout: Charge Core API, custom_expiry, dan polling status.
     */
    public function test_qris_checkout_and_status_polling(): void
    {
        $response = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.payment.payment_method', 'qris')
            ->assertJsonPath('data.payment.payment_status', 'pending');

        $paymentId = $response->json('data.payment.id');
        $this->assertNotNull($response->json('data.qris.qr_string'));

        // Polling status
        $statusResp = $this->actingAs($this->customer)
            ->getJson("/api/v1/payments/{$paymentId}/status");

        $statusResp->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.payment_status', 'pending')
            ->assertJsonPath('data.is_expired', false);
    }

    /**
     * Test Idempotency Key pada Checkout.
     */
    public function test_checkout_idempotency_key_returns_same_payment(): void
    {
        $idempotencyKey = 'IDEMP-TEST-' . bin2hex(random_bytes(6));

        $res1 = $this->actingAs($this->customer)
            ->withHeader('Idempotency-Key', $idempotencyKey)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'transfer',
            ]);

        $res1->assertStatus(201);
        $payId1 = $res1->json('data.payment.id');

        // Panggil kedua kalinya dengan idempotency key yang sama
        $res2 = $this->actingAs($this->customer)
            ->withHeader('Idempotency-Key', $idempotencyKey)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'transfer',
            ]);

        $payId2 = $res2->json('data.payment.id') ?? $res2->json('data.id');
        $this->assertSame($payId1, $payId2);
        $this->assertSame(1, Payment::where('idempotency_key', $idempotencyKey)->count());
    }

    /**
     * Test Hanya Satu Attempt Aktif per Order (Retry membatalkan attempt lama).
     */
    public function test_only_one_active_attempt_per_order_and_retry_cancels_old(): void
    {
        $res1 = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);

        $res1->assertStatus(201);
        $oldPaymentId = $res1->json('data.payment.id');

        // Buat checkout baru (retry)
        $res2 = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'transfer',
            ]);

        $res2->assertStatus(201);
        $newPaymentId = $res2->json('data.payment.id');

        $this->assertNotSame($oldPaymentId, $newPaymentId);

        // Payment lama harus berstatus cancelled
        $oldPayment = Payment::find($oldPaymentId);
        $this->assertSame(Payment::STATUS_CANCELLED, $oldPayment->payment_status);

        // Payment baru berstatus pending
        $newPayment = Payment::find($newPaymentId);
        $this->assertSame(Payment::STATUS_PENDING, $newPayment->payment_status);
    }

    /**
     * Test Webhook Midtrans: Signature SHA-512, Idempotensi (3x webhook hasil sama), Escrow hold.
     */
    public function test_midtrans_webhook_signature_and_idempotency(): void
    {
        config(['services.midtrans.server_key' => 'SB-Mid-server-TESTKEY123']);

        $res = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);

        $payment = Payment::find($res->json('data.payment.id'));
        $orderId = $payment->gateway_order_id;
        $statusCode = '200';
        $grossAmount = (string) $payment->amount . '.00';
        $serverKey = 'SB-Mid-server-TESTKEY123';

        // Hitung signature valid: sha512(order_id + status_code + gross_amount + ServerKey)
        $validSignature = hash('sha512', $orderId . $statusCode . $grossAmount . $serverKey);

        $webhookPayload = [
            'order_id' => $orderId,
            'status_code' => $statusCode,
            'gross_amount' => $grossAmount,
            'signature_key' => $validSignature,
            'transaction_status' => 'settlement',
            'transaction_id' => 'mid-tx-' . bin2hex(random_bytes(6)),
        ];

        // 1. Webhook Pertama
        $wh1 = $this->postJson('/api/v1/payments/webhook', $webhookPayload);
        $wh1->assertStatus(200)
            ->assertJsonPath('success', true);

        $payment->refresh();
        $this->assertSame(Payment::STATUS_PAID, $payment->payment_status);
        $this->assertSame('paid', $this->order->fresh()->payment_status);

        // Cek escrow hold di dompet teknisi
        $wallet = TechnicianWallet::where('technician_id', $this->technician->id)->first();
        $this->assertNotNull($wallet);
        $this->assertSame($payment->amount, $wallet->pending_balance);
        $this->assertSame(0, $wallet->balance); // Belum rilis ke balance aktif

        // 2. Webhook Kedua (Idempotensi: replay)
        $wh2 = $this->postJson('/api/v1/payments/webhook', $webhookPayload);
        $wh2->assertStatus(200);

        // 3. Webhook Ketiga (Idempotensi: replay)
        $wh3 = $this->postJson('/api/v1/payments/webhook', $webhookPayload);
        $wh3->assertStatus(200);

        // Pending balance tidak berlipat ganda
        $wallet->refresh();
        $this->assertSame($payment->amount, $wallet->pending_balance);

        // Cek tabel webhook_events (tercatat 1 kali karena unik dan idempoten)
        $this->assertSame(1, WebhookEvent::where('payment_id', $payment->id)->count());
    }

    /**
     * Test Webhook Signature Palsu Ditolak (403).
     */
    public function test_midtrans_webhook_fake_signature_rejected(): void
    {
        config(['services.midtrans.server_key' => 'SB-Mid-server-TESTKEY123']);

        $res = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);

        $payment = Payment::find($res->json('data.payment.id'));

        $webhookPayload = [
            'order_id' => $payment->gateway_order_id,
            'status_code' => '200',
            'gross_amount' => (string) $payment->amount . '.00',
            'signature_key' => 'INVALID_SIGNATURE_HASH',
            'transaction_status' => 'settlement',
            'transaction_id' => 'mid-tx-fake',
        ];

        $response = $this->postJson('/api/v1/payments/webhook', $webhookPayload);
        $response->assertStatus(403)
            ->assertJsonPath('success', false);

        $payment->refresh();
        $this->assertSame(Payment::STATUS_PENDING, $payment->payment_status);
    }

    /**
     * Test Webhook Terlambat dari Attempt Lama Ditandai flagged_for_manual_refund.
     */
    public function test_late_webhook_from_old_attempt_flagged_for_manual_refund(): void
    {
        config(['services.midtrans.server_key' => 'SB-Mid-server-TESTKEY123']);

        // Attempt 1: QRIS
        $res1 = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);
        $oldPayment = Payment::find($res1->json('data.payment.id'));

        // Attempt 2: Transfer yang kemudian dilunasi oleh pelanggan
        $res2 = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'transfer',
            ]);
        $newPayment = Payment::find($res2->json('data.payment.id'));
        $newPayment->update(['payment_status' => Payment::STATUS_PAID, 'paid_at' => now()]);

        // Tiba-tiba webhook settlement datang untuk attempt 1 lama yang sudah tercancel
        $orderId = $oldPayment->gateway_order_id;
        $statusCode = '200';
        $grossAmount = (string) $oldPayment->amount . '.00';
        $serverKey = 'SB-Mid-server-TESTKEY123';
        $validSignature = hash('sha512', $orderId . $statusCode . $grossAmount . $serverKey);

        $webhookPayload = [
            'order_id' => $orderId,
            'status_code' => $statusCode,
            'gross_amount' => $grossAmount,
            'signature_key' => $validSignature,
            'transaction_status' => 'settlement',
            'transaction_id' => 'mid-tx-late-' . bin2hex(random_bytes(4)),
        ];

        $response = $this->postJson('/api/v1/payments/webhook', $webhookPayload);
        $response->assertStatus(200);

        // Harus ditandai flagged_for_manual_refund = true di tabel webhook_events
        $event = WebhookEvent::where('payment_id', $oldPayment->id)->latest('id')->first();
        $this->assertNotNull($event);
        $this->assertTrue((bool) $event->flagged_for_manual_refund);
    }

    /**
     * Test Transfer Manual: Upload Bukti, Verifikasi Admin, Signed URL 30 Menit.
     */
    public function test_manual_transfer_workflow_upload_and_admin_approval(): void
    {
        Storage::fake('local');

        // 1. Checkout Transfer
        $res = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'transfer',
            ]);
        $res->assertStatus(201);
        $paymentId = $res->json('data.payment.id');

        // 2. Upload Bukti Transfer (MIME jpg, size valid)
        $file = UploadedFile::fake()->image('bukti_transfer.jpg', 600, 800)->size(500);

        $uploadRes = $this->actingAs($this->customer)
            ->postJson("/api/v1/payments/{$paymentId}/upload-proof", [
                'proof' => $file,
                'sender_bank_name' => 'BCA',
                'sender_account_name' => 'Budi Santoso',
            ]);

        $uploadRes->assertStatus(200)
            ->assertJsonPath('success', true);

        $payment = Payment::find($paymentId);
        $this->assertSame(Payment::STATUS_AWAITING_VERIFICATION, $payment->payment_status);
        $this->assertNotNull($payment->proof_url);
        Storage::disk('local')->assertExists($payment->proof_url);

        // 3. Admin dapatkan Signed URL 30 menit
        $signedResp = $this->actingAs($this->admin)
            ->getJson("/api/v1/admin/payments/{$paymentId}/proof-url");

        $signedResp->assertStatus(200)
            ->assertJsonPath('success', true);
        $signedUrl = $signedResp->json('data.signed_url');
        $this->assertNotNull($signedUrl);

        // 4. Admin Verifikasi Menyetujui Transfer
        $approveResp = $this->actingAs($this->admin)
            ->postJson("/api/v1/admin/payments/{$paymentId}/verify-transfer", [
                'approved' => true,
            ]);

        $approveResp->assertStatus(200);
        $payment->refresh();
        $this->assertSame(Payment::STATUS_PAID, $payment->payment_status);
        $this->assertSame($this->admin->id, $payment->verified_by);
    }

    /**
     * Test Transfer Manual Ditolak Admin: Alasan wajib diisi.
     */
    public function test_manual_transfer_rejection_requires_reason(): void
    {
        Storage::fake('local');

        $res = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'transfer',
            ]);
        $paymentId = $res->json('data.payment.id');

        // Tolak tanpa alasan -> validation error
        $rejectNoReason = $this->actingAs($this->admin)
            ->postJson("/api/v1/admin/payments/{$paymentId}/verify-transfer", [
                'approved' => false,
            ]);
        $rejectNoReason->assertStatus(422)
            ->assertJsonValidationErrors(['rejection_reason']);

        // Tolak dengan alasan valid
        $rejectValid = $this->actingAs($this->admin)
            ->postJson("/api/v1/admin/payments/{$paymentId}/verify-transfer", [
                'approved' => false,
                'rejection_reason' => 'Bukti mutasi tidak terbaca dan nominal tidak sesuai.',
            ]);
        $rejectValid->assertStatus(200);

        $payment = Payment::find($paymentId);
        $this->assertSame(Payment::STATUS_FAILED, $payment->payment_status);
        $this->assertSame('Bukti mutasi tidak terbaca dan nominal tidak sesuai.', $payment->rejection_reason);
    }

    /**
     * Test Pembayaran Cash: Konfirmasi teknisi, nominal harus sama persis, dan settlement 2 arah.
     */
    public function test_cash_payment_confirmation_and_settlement(): void
    {
        // Checkout Cash: S = 100.000, T = 20.000, D = 0 -> Total = 120.000. Komisi C = 5.000.
        $res = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'cash',
            ]);
        $paymentId = $res->json('data.payment.id');

        // 1. Teknisi mengonfirmasi dengan nominal salah -> 422
        $failConfirm = $this->actingAs($this->technician)
            ->postJson("/api/v1/payments/{$paymentId}/confirm-cash", [
                'amount_received' => 100000, // Kurang dari 120.000
            ]);
        $failConfirm->assertStatus(422);

        // 2. Teknisi mengonfirmasi dengan nominal pas 120.000
        $successConfirm = $this->actingAs($this->technician)
            ->postJson("/api/v1/payments/{$paymentId}/confirm-cash", [
                'amount_received' => 120000,
            ]);
        $successConfirm->assertStatus(200);

        $payment = Payment::find($paymentId);
        $this->assertSame(Payment::STATUS_PAID, $payment->payment_status);

        // Cek dompet teknisi:
        // Cash tanpa promo: teknisi terima uang tunai fisik 120.000 di tangan.
        // Komisi platform C = 5.000 dipotong dari balance dompet teknisi.
        // Karena saldo awal 0, saldo menjadi -5.000 (utang komisi tunai).
        $wallet = TechnicianWallet::where('technician_id', $this->technician->id)->first();
        $this->assertSame(-5000, $wallet->balance);
        $this->assertSame(0, $wallet->pending_balance);

        // Mutasi tercatat konsisten
        $tx = WalletTransaction::where('wallet_id', $wallet->id)->latest('id')->first();
        $this->assertSame(WalletTransaction::TYPE_DEBIT, $tx->type);
        $this->assertSame(5000, $tx->amount);
        $this->assertSame(0, $tx->balance_before);
        $this->assertSame(-5000, $tx->balance_after);
    }

    /*
    |--------------------------------------------------------------------------
    | BAGIAN C: PROMO - Kuota Dinamis, Reservasi, Rilis, Validasi
    |--------------------------------------------------------------------------
    */

    /**
     * Test Kuota Promo Dinamis & Reservasi: Diskon persen dan batas kuota.
     */
    public function test_promo_dynamic_quota_and_reservation(): void
    {
        $promo = Promo::create([
            'code' => 'HEMAT20',
            'name' => 'Diskon 20 Persen',
            'type' => 'percentage',
            'discount_amount' => 20, // 20%
            'max_discount' => 30000,
            'min_order_amount' => 50000,
            'start_date' => now()->subDay(),
            'end_date' => now()->addDays(5),
            'total_quota' => 2,
            'quota_per_user' => 1,
            'is_active' => true,
        ]);

        // Validasi promo endpoint
        $valRes = $this->actingAs($this->customer)
            ->postJson('/api/v1/promos/validate', [
                'order_id' => $this->order->id,
                'promo_code' => 'HEMAT20',
                'payment_method' => 'qris',
            ]);

        // 20% dari 100.000 = 20.000
        $valRes->assertStatus(200)
            ->assertJsonPath('data.discount_amount', 20000);

        // Checkout dengan promo HEMAT20
        $chkRes = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
                'promo_code' => 'HEMAT20',
            ]);

        $chkRes->assertStatus(201);
        $this->assertSame(20000, $this->order->fresh()->discount);
        // Total = (100.000 - 20.000) + 20.000 = 100.000
        $this->assertSame(100000, $this->order->fresh()->total_amount);

        // PromoUsage tercatat status reserved
        $usage = PromoUsage::where('order_id', $this->order->id)->first();
        $this->assertNotNull($usage);
        $this->assertSame(PromoUsage::STATUS_RESERVED, $usage->status);
        $this->assertSame(20000, $usage->discount_applied);

        // Sisa kuota berkurang menjadi 1
        $this->assertSame(1, $promo->remainingQuota());
    }

    /**
     * Test Rilis Kuota Promo Saat Pesanan Dibatalkan.
     */
    public function test_promo_released_when_order_is_cancelled(): void
    {
        $promo = Promo::create([
            'code' => 'DISKON10K',
            'name' => 'Diskon 10 Ribu',
            'type' => 'fixed',
            'discount_amount' => 10000,
            'min_order_amount' => 50000,
            'start_date' => now()->subDay(),
            'end_date' => now()->addDays(5),
            'total_quota' => 1,
            'quota_per_user' => 1,
            'is_active' => true,
        ]);

        $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'transfer',
                'promo_code' => 'DISKON10K',
            ]);

        $this->assertSame(0, $promo->remainingQuota());

        // Batalkan pesanan
        $this->actingAs($this->customer)
            ->patchJson("/api/v1/orders/{$this->order->id}/cancel", [
                'reason' => 'Ingin ganti jadwal',
            ])
            ->assertStatus(200);

        // Kuota promo harus terilis kembali
        $this->assertSame(1, $promo->remainingQuota());
        $usage = PromoUsage::where('order_id', $this->order->id)->first();
        $this->assertSame(PromoUsage::STATUS_RELEASED, $usage->status);
    }

    /*
    |--------------------------------------------------------------------------
    | BAGIAN D: DOMPET, KOMISI, PAYOUT, NET-OFF, SUSPENSI
    |--------------------------------------------------------------------------
    */

    /**
     * Test Escrow Lifecycle: Paid (hold pending) -> Completed (release to balance).
     */
    public function test_escrow_lifecycle_paid_to_completed(): void
    {
        // 1. Bayar via QRIS (Subtotal 100k, Transport 20k -> Total 120k)
        $res = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);
        $payment = Payment::find($res->json('data.payment.id'));
        $payment->update(['payment_status' => Payment::STATUS_PAID, 'paid_at' => now()]);
        $this->order->update(['payment_status' => 'paid']);

        // Hold escrow
        app(WalletService::class)->holdEscrow($this->technician, 120000, $this->order);

        $wallet = TechnicianWallet::where('technician_id', $this->technician->id)->first();
        $this->assertSame(120000, $wallet->pending_balance);
        $this->assertSame(0, $wallet->balance);

        // 2. Teknisi menyelesaikan servis (STATUS_COMPLETED)
        $this->actingAs($this->technician)
            ->patchJson("/api/v1/orders/{$this->order->id}/status", [
                'status' => 'completed',
                'note' => 'Pekerjaan servis telah selesai dengan baik.',
            ])
            ->assertStatus(200);

        // Escrow harus lepas dari pending_balance dan masuk ke balance sebagai net income
        // Komisi 5% dari 100k = 5k -> Net income teknisi N = 100k + 20k - 5k = 115.000
        $wallet->refresh();
        $this->assertSame(0, $wallet->pending_balance);
        $this->assertSame(115000, $wallet->balance);

        // Invarian: Mutasi sama dengan saldo wallet
        $sumCredit = WalletTransaction::where('wallet_id', $wallet->id)->where('type', 'credit')->sum('amount');
        $sumDebit = WalletTransaction::where('wallet_id', $wallet->id)->where('type', 'debit')->sum('amount');
        $this->assertSame($wallet->balance, (int) ($sumCredit - $sumDebit));
    }

    /**
     * Test Hook Suspensi Teknisi Saat Utang Cash Melebihi Batas Toleransi.
     */
    public function test_technician_suspension_when_cash_debt_exceeds_limit(): void
    {
        // Limit utang cash diatur 200.000
        PlatformSetting::set('max_cash_debt_limit', '200000');

        $wallet = app(WalletService::class)->getOrCreateWallet($this->technician);
        $wallet->update(['balance' => 0]);

        $this->assertFalse((bool) $this->technician->is_suspended_from_orders);

        // Simulasikan akumulasi utang komisi hingga -250.000 (melebihi limit 200.000)
        app(WalletService::class)->evaluateTechnicianSuspension($this->technician, -250000);

        $this->technician->refresh();
        $this->assertTrue((bool) $this->technician->is_suspended_from_orders);

        // Teknisi melunasi atau menerima pendapatan sehingga saldo kembali di atas -200.000 (misal -50.000)
        app(WalletService::class)->evaluateTechnicianSuspension($this->technician, -50000);

        $this->technician->refresh();
        $this->assertFalse((bool) $this->technician->is_suspended_from_orders);
    }

    /**
     * Test Payout Request, Approval, Rejection, dan Lock Saldo.
     */
    public function test_technician_payout_lifecycle(): void
    {
        Storage::fake('local');

        // Isi saldo teknisi 200.000
        $wallet = app(WalletService::class)->getOrCreateWallet($this->technician);
        $wallet->update(['balance' => 200000]);

        // 1. Pengajuan payout 100.000
        $payoutRes = $this->actingAs($this->technician)
            ->postJson('/api/v1/wallet/payout', [
                'amount' => 100000,
                'bank_name' => 'BCA',
                'bank_account_number' => '1234567890',
                'bank_account_holder' => 'Agus Kompor',
            ]);

        $payoutRes->assertStatus(201)
            ->assertJsonPath('success', true);

        $payoutId = $payoutRes->json('data.id');

        // Saldo langsung ter-lock / terpotong menjadi 100.000
        $wallet->refresh();
        $this->assertSame(100000, $wallet->balance);

        // 2. Admin menolak payout -> saldo 100.000 kembali ke dompet
        $rejectResp = $this->actingAs($this->admin)
            ->postJson("/api/v1/admin/payouts/{$payoutId}/reject", [
                'reason' => 'Nomor rekening dan nama pemilik tidak cocok.',
            ]);

        $rejectResp->assertStatus(200);
        $wallet->refresh();
        $this->assertSame(200000, $wallet->balance);

        // 3. Ajukan lagi dan Admin Approve dengan bukti transfer
        $payoutRes2 = $this->actingAs($this->technician)
            ->postJson('/api/v1/wallet/payout', [
                'amount' => 150000,
                'bank_name' => 'Mandiri',
                'bank_account_number' => '9876543210',
                'bank_account_holder' => 'Agus Kompor',
            ]);
        $payoutId2 = $payoutRes2->json('data.id');

        $proofFile = UploadedFile::fake()->image('bukti_transfer_payout.jpg', 500, 500);
        $approveResp = $this->actingAs($this->admin)
            ->postJson("/api/v1/admin/payouts/{$payoutId2}/approve", [
                'proof' => $proofFile,
                'admin_notes' => 'Transfer berhasil via BI-Fast',
            ]);

        $approveResp->assertStatus(200);
        $payout2 = PayoutRequest::find($payoutId2);
        $this->assertSame(PayoutRequest::STATUS_APPROVED, $payout2->status);
        $this->assertNotNull($payout2->transfer_proof_url);
    }

    /*
    |--------------------------------------------------------------------------
    | BAGIAN E & F: ADMIN & KEAMANAN (RBAC, IDOR, FormRequest, Audit Log)
    |--------------------------------------------------------------------------
    */

    /**
     * Test Keamanan: RBAC - Akses ditolak (403) jika role tidak berwenang.
     */
    public function test_security_rbac_forbidden_roles(): void
    {
        // Customer tidak boleh akses endpoint admin
        $this->actingAs($this->customer)
            ->getJson('/api/v1/admin/payments')
            ->assertStatus(403);

        // Teknisi tidak boleh akses checkout customer
        $this->actingAs($this->technician)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ])
            ->assertStatus(403);

        // Customer tidak boleh konfirmasi uang tunai teknisi
        $res = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'cash',
            ]);
        $paymentId = $res->json('data.payment.id');

        $this->actingAs($this->customer)
            ->postJson("/api/v1/payments/{$paymentId}/confirm-cash", [
                'amount_received' => 120000,
            ])
            ->assertStatus(403);
    }

    /**
     * Test Keamanan: IDOR - Customer lain tidak boleh melihat status / upload bukti milik customer lain.
     */
    public function test_security_idor_protection(): void
    {
        $otherCustomer = User::factory()->create(['role' => 'customer']);

        $res = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'transfer',
            ]);
        $paymentId = $res->json('data.payment.id');

        // Customer lain mencoba melihat status
        $this->actingAs($otherCustomer)
            ->getJson("/api/v1/payments/{$paymentId}/status")
            ->assertStatus(403);

        // Customer lain mencoba upload bukti
        $file = UploadedFile::fake()->image('bukti.jpg');
        $this->actingAs($otherCustomer)
            ->postJson("/api/v1/payments/{$paymentId}/upload-proof", [
                'proof' => $file,
            ])
            ->assertStatus(403);
    }

    /**
     * Test Admin: Ekspor Data Pembayaran ke CSV.
     */
    public function test_admin_export_payments_csv(): void
    {
        Payment::create([
            'order_id' => $this->order->id,
            'customer_id' => $this->customer->id,
            'payment_number' => 'PAY-EXP-001',
            'payment_method' => 'qris',
            'amount' => 120000,
            'payment_status' => Payment::STATUS_PAID,
            'paid_at' => now(),
            'expires_at' => now()->addMinutes(15),
        ]);

        $response = $this->actingAs($this->admin)
            ->get('/api/v1/admin/payments/export');

        $response->assertStatus(200)
            ->assertHeader('Content-Type', 'text/csv; charset=UTF-8');
    }
}
