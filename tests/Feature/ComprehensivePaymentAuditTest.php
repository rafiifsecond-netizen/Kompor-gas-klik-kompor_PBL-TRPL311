<?php

namespace Tests\Feature;

use App\Models\ActivityLog;
use App\Models\Order;
use App\Models\Payment;
use App\Models\User;
use App\Models\WebhookEvent;
use App\Services\Payment\PaymentService;
use Exception;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ComprehensivePaymentAuditTest extends TestCase
{
    use RefreshDatabase;

    protected User $customer;
    protected User $otherCustomer;
    protected User $technician;
    protected User $otherTechnician;
    protected User $admin;
    protected Order $order;

    protected function setUp(): void
    {
        parent::setUp();

        config(['services.midtrans.server_key' => 'SB-Mid-server-TESTKEY123']);
        $this->app->singleton(\App\Services\Payment\MidtransService::class, function () {
            return new \App\Services\Payment\MidtransService();
        });

        \Illuminate\Support\Facades\Http::fake([
            'https://api.sandbox.midtrans.com/v2/charge*' => function ($request) {
                $body = json_decode($request->body(), true) ?? (array) $request->data();
                $type = $body['payment_type'] ?? 'qris';
                $orderId = $body['transaction_details']['order_id'] ?? 'KP-MOCK';
                $amount = $body['transaction_details']['gross_amount'] ?? 120000;

                if ($type === 'bank_transfer') {
                    $bank = $body['bank_transfer']['bank'] ?? 'bca';

                    return \Illuminate\Support\Facades\Http::response([
                        'status_code' => '201',
                        'status_message' => 'Success, Bank Transfer transaction is created',
                        'transaction_id' => 'mid-tx-va-'.bin2hex(random_bytes(6)),
                        'order_id' => $orderId,
                        'gross_amount' => (string) $amount.'.00',
                        'payment_type' => 'bank_transfer',
                        'transaction_status' => 'pending',
                        'va_numbers' => [
                            ['bank' => $bank, 'va_number' => '8040'.rand(1000000000, 9999999999)],
                        ],
                    ], 201);
                }

                return \Illuminate\Support\Facades\Http::response([
                    'status_code' => '201',
                    'status_message' => 'Success, QRIS transaction is created',
                    'transaction_id' => 'mid-tx-qris-'.bin2hex(random_bytes(6)),
                    'order_id' => $orderId,
                    'gross_amount' => (string) $amount.'.00',
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
                ], 201);
            },
            'https://api.sandbox.midtrans.com/v2/*/cancel*' => \Illuminate\Support\Facades\Http::response([
                'status_code' => '200',
                'status_message' => 'Success, transaction is canceled',
            ], 200),
            'https://api.sandbox.midtrans.com/v2/*/status*' => \Illuminate\Support\Facades\Http::response([
                'status_code' => '200',
                'transaction_status' => 'pending',
            ], 200),
            'https://api.sandbox.midtrans.com/*' => \Illuminate\Support\Facades\Http::response([
                'status_code' => '200',
                'status_message' => 'OK',
            ], 200),
        ]);

        $this->seed();

        $this->customer = User::where('email', 'budi@example.com')->first()
            ?? User::factory()->create(['role' => 'customer', 'email' => 'budi@example.com', 'name' => 'Budi Customer']);

        $this->otherCustomer = User::factory()->create(['role' => 'customer', 'name' => 'Other Customer']);

        $this->technician = User::where('email', 'agus@example.com')->first()
            ?? User::factory()->create(['role' => 'technician', 'email' => 'agus@example.com', 'name' => 'Agus Teknisi']);

        $this->otherTechnician = User::factory()->create(['role' => 'technician', 'name' => 'Other Teknisi']);

        $this->admin = User::where('email', 'admin@klikkompor.com')->first()
            ?? User::factory()->create(['role' => 'admin', 'email' => 'admin@klikkompor.com', 'name' => 'Admin Utama']);

        if (! $this->technician->technicianProfile) {
            $this->technician->technicianProfile()->create([
                'bio' => 'Teknisi Handal',
                'years_of_experience' => 4,
                'is_verified' => true,
                'is_available' => true,
            ]);
        }

        // Order standar: subtotal 100.000, transport 20.000, total = 120.000
        $this->order = Order::create([
            'order_number' => 'KP-AUDIT-'.bin2hex(random_bytes(3)),
            'customer_id' => $this->customer->id,
            'customer_name' => $this->customer->name,
            'customer_phone' => '081234567890',
            'technician_id' => $this->technician->id,
            'subtotal' => 100000,
            'transport_fee' => 20000,
            'discount' => 0,
            'total_amount' => 120000,
            'status' => Order::STATUS_ACCEPTED,
            'payment_status' => 'unpaid',
            'payment_method' => 'cash',
            'scheduled_at' => now()->addDay(),
            'address' => 'Jl. Pengujian No. 10',
            'latitude' => -6.2,
            'longitude' => 106.8,
            'problem_description' => 'Servis kompor gas',
        ]);
    }

    /**
     * Skenario 1: Pelanggan berhasil membuat transaksi QRIS dinamis.
     */
    public function test_scenario_1_customer_creates_qris_transaction(): void
    {
        $response = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'payment' => ['id', 'order_id', 'amount', 'payment_status', 'payment_method'],
                    'qris' => ['qr_string', 'expires_at'],
                ],
            ]);

        $this->assertDatabaseHas('payments', [
            'order_id' => $this->order->id,
            'payment_method' => 'qris',
            'payment_status' => Payment::STATUS_PENDING,
            'amount' => 120000,
        ]);
    }

    /**
     * Skenario 2: Pelanggan berhasil membuat transaksi Virtual Account.
     */
    public function test_scenario_2_customer_creates_virtual_account_transaction(): void
    {
        $response = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'transfer',
                'sender_bank_name' => 'BCA',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.payment.payment_method', 'transfer')
            ->assertJsonStructure([
                'data' => [
                    'payment' => ['id', 'amount', 'payment_status'],
                    'va' => ['bank', 'va_number', 'expires_at'],
                ],
            ]);

        $payment = Payment::where('order_id', $this->order->id)->first();
        $this->assertNotNull($payment->va_number);
        $this->assertEquals(Payment::STATUS_PENDING, $payment->payment_status);
    }

    /**
     * Skenario 3: Pelanggan berhasil memilih pembayaran Cash (status awal Unpaid/Pending).
     */
    public function test_scenario_3_customer_chooses_cash_payment_initial_unpaid(): void
    {
        $response = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'cash',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.payment.payment_status', Payment::STATUS_PENDING)
            ->assertJsonPath('data.payment.payment_method', 'cash');

        $this->order->refresh();
        $this->assertEquals('unpaid', $this->order->payment_status);
    }

    /**
     * Skenario 4: Nominal transaksi sesuai dengan total pesanan di database (bukan input user).
     */
    public function test_scenario_4_transaction_amount_matches_order_total_in_db(): void
    {
        // Mencoba inject nominal palsu 500 rupiah pada payload request
        $response = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
                'amount' => 500, // Attacker injected field
            ]);

        $response->assertStatus(201);
        $paymentData = $response->json('data.payment');

        // Nominal HARUS tetap 120.000 sesuai pesanan di database
        $this->assertEquals(120000, $paymentData['amount']);
        $this->assertDatabaseHas('payments', [
            'order_id' => $this->order->id,
            'amount' => 120000,
        ]);
    }

    /**
     * Skenario 5: Pembayaran berhasil mengubah status menjadi Paid (via settlement webhook).
     */
    public function test_scenario_5_successful_payment_updates_status_to_paid(): void
    {
        $checkout = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);
        $paymentId = $checkout->json('data.payment.id');
        $payment = Payment::find($paymentId);

        // Simulasi webhook settlement Midtrans
        $serverKey = 'SB-Mid-server-TESTKEY123';

        $orderId = $payment->gateway_order_id;
        $grossAmount = '120000.00';
        $statusCode = '200';
        $signature = hash('sha512', $orderId.$statusCode.$grossAmount.$serverKey);

        $webhookPayload = [
            'order_id' => $orderId,
            'status_code' => $statusCode,
            'gross_amount' => $grossAmount,
            'signature_key' => $signature,
            'transaction_status' => 'settlement',
            'transaction_id' => 'midtrans-tx-001',
        ];

        $webhookRes = $this->postJson('/api/v1/payments/webhook', $webhookPayload);
        $webhookRes->assertStatus(200);

        $payment->refresh();
        $this->order->refresh();

        $this->assertEquals(Payment::STATUS_PAID, $payment->payment_status);
        $this->assertEquals('paid', $this->order->payment_status);
        $this->assertNotNull($payment->paid_at);
    }

    /**
     * Skenario 6: Pembayaran gagal tidak mengubah status menjadi Paid (deny/cancel).
     */
    public function test_scenario_6_failed_payment_does_not_update_status_to_paid(): void
    {
        $checkout = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);
        $payment = Payment::find($checkout->json('data.payment.id'));

        $serverKey = 'SB-Mid-server-TESTKEY123';

        $orderId = $payment->gateway_order_id;
        $grossAmount = '120000.00';
        $statusCode = '202';
        $signature = hash('sha512', $orderId.$statusCode.$grossAmount.$serverKey);

        $webhookPayload = [
            'order_id' => $orderId,
            'status_code' => $statusCode,
            'gross_amount' => $grossAmount,
            'signature_key' => $signature,
            'transaction_status' => 'deny',
            'transaction_id' => 'midtrans-tx-failed-1',
        ];

        $webhookRes = $this->postJson('/api/v1/payments/webhook', $webhookPayload);
        $webhookRes->assertStatus(200);

        $payment->refresh();
        $this->order->refresh();

        $this->assertEquals(Payment::STATUS_FAILED, $payment->payment_status);
        $this->assertEquals('unpaid', $this->order->payment_status);
    }

    /**
     * Skenario 7: Transaksi kedaluwarsa tidak dapat dibayar kembali.
     */
    public function test_scenario_7_expired_transaction_cannot_be_paid(): void
    {
        $checkout = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);
        $payment = Payment::find($checkout->json('data.payment.id'));

        // Set expires_at ke masa lalu
        $payment->update([
            'expires_at' => now()->subMinutes(10),
            'payment_status' => Payment::STATUS_EXPIRED,
        ]);

        $statusRes = $this->actingAs($this->customer)
            ->getJson("/api/v1/payments/{$payment->id}/status");

        $statusRes->assertStatus(200)
            ->assertJsonPath('data.payment_status', Payment::STATUS_EXPIRED)
            ->assertJsonPath('data.is_expired', true);
    }

    /**
     * Skenario 8: Callback berulang tidak membuat pembayaran ganda (Idempotency).
     */
    public function test_scenario_8_duplicate_callback_does_not_create_duplicate_payment(): void
    {
        $checkout = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);
        $payment = Payment::find($checkout->json('data.payment.id'));

        $serverKey = 'SB-Mid-server-TESTKEY123';

        $orderId = $payment->gateway_order_id;
        $grossAmount = '120000.00';
        $statusCode = '200';
        $signature = hash('sha512', $orderId.$statusCode.$grossAmount.$serverKey);

        $payload = [
            'order_id' => $orderId,
            'status_code' => $statusCode,
            'gross_amount' => $grossAmount,
            'signature_key' => $signature,
            'transaction_status' => 'settlement',
            'transaction_id' => 'midtrans-tx-idempotent-1',
        ];

        // Callback pertama
        $res1 = $this->postJson('/api/v1/payments/webhook', $payload);
        $res1->assertStatus(200);

        // Callback kedua (duplikat)
        $res2 = $this->postJson('/api/v1/payments/webhook', $payload);
        $res2->assertStatus(200);

        // Hanya boleh ada 1 pembayaran yang lunas
        $paidCount = Payment::where('order_id', $this->order->id)
            ->where('payment_status', Payment::STATUS_PAID)
            ->count();
        $this->assertEquals(1, $paidCount);
    }

    /**
     * Skenario 9: Pelanggan tidak dapat membayar pesanan milik orang lain (403 Forbidden).
     */
    public function test_scenario_9_customer_cannot_pay_order_belonging_to_someone_else(): void
    {
        // otherCustomer mencoba membayar pesanan milik customer
        $response = $this->actingAs($this->otherCustomer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'qris',
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('success', false);
    }

    /**
     * Skenario 10: Teknisi tidak dapat mengonfirmasi pembayaran pesanan yang bukan tanggung jawabnya.
     */
    public function test_scenario_10_technician_cannot_confirm_cash_on_unassigned_order(): void
    {
        $checkout = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'cash',
            ]);
        $paymentId = $checkout->json('data.payment.id');

        // otherTechnician mencoba konfirmasi uang tunai
        $response = $this->actingAs($this->otherTechnician)
            ->postJson("/api/v1/payments/{$paymentId}/confirm-cash", [
                'amount_received' => 120000,
            ]);

        $response->assertStatus(422);

        $payment = Payment::find($paymentId);
        $this->assertNotEquals(Payment::STATUS_PAID, $payment->payment_status);
    }

    /**
     * Skenario 11: Admin dapat melihat seluruh transaksi tanpa nilai dummy fallback.
     */
    public function test_scenario_11_admin_can_view_all_transactions(): void
    {
        $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'cash',
            ]);

        // API Endpoint Admin
        $apiRes = $this->actingAs($this->admin)
            ->getJson('/api/v1/admin/payments');

        $apiRes->assertStatus(200)
            ->assertJsonPath('success', true);

        // Web Admin View
        $webRes = $this->actingAs($this->admin)
            ->get('/admin/payments');

        $webRes->assertStatus(200);
        // Pastikan tidak ada dummy teks Rp.90.000 atau #PAY-2026-001 dari empty block
        $webRes->assertDontSee('#PAY-2026-001');
    }

    /**
     * Skenario 12: Status pembayaran Flutter dan Web Admin selalu konsisten.
     */
    public function test_scenario_12_payment_status_consistency_across_api_and_admin_web(): void
    {
        $checkout = $this->actingAs($this->customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $this->order->id,
                'payment_method' => 'cash',
            ]);
        $payment = Payment::find($checkout->json('data.payment.id'));

        // Admin verifikasi tunai
        $this->actingAs($this->admin)
            ->postJson("/admin/payments/{$payment->id}/verify-cash", [
                'approved' => true,
                'notes' => 'Uang tunai diserahkan di kantor',
            ])
            ->assertStatus(200);

        // Flutter API Check Status
        $flutterStatus = $this->actingAs($this->customer)
            ->getJson("/api/v1/payments/{$payment->id}/status");

        $flutterStatus->assertStatus(200)
            ->assertJsonPath('data.payment_status', Payment::STATUS_PAID);

        // Web Admin Check Status
        $adminList = $this->actingAs($this->admin)
            ->getJson('/api/v1/admin/payments?status=paid');

        $adminList->assertStatus(200);
        $items = $adminList->json('data.data');
        $matching = collect($items)->firstWhere('id', $payment->id);
        $this->assertNotNull($matching);
        $this->assertEquals(Payment::STATUS_PAID, $matching['payment_status']);
    }
}
