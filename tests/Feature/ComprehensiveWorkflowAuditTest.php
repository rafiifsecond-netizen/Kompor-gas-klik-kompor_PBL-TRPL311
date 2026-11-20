<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use App\Models\ServiceCategory;
use App\Models\ServiceItem;
use App\Models\TechnicianProfile;
use App\Models\User;
use App\Models\Notification;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ComprehensiveWorkflowAuditTest extends TestCase
{
    use RefreshDatabase;

    protected User $customer;
    protected User $technician;
    protected User $otherTechnician;
    protected User $admin;
    protected TechnicianProfile $technicianProfile;
    protected ServiceCategory $category;
    protected ServiceItem $service;

    protected function setUp(): void
    {
        parent::setUp();

        $this->customer = User::factory()->create([
            'role' => 'customer',
            'name' => 'Budi Customer',
            'email' => 'customer@test.com',
            'phone' => '081234567890',
        ]);

        $this->technician = User::factory()->create([
            'role' => 'technician',
            'name' => 'Agus Teknisi',
            'email' => 'tech@test.com',
            'is_active' => true,
        ]);

        $this->technicianProfile = TechnicianProfile::create([
            'user_id' => $this->technician->id,
            'is_available' => true,
            'rating' => 5.0,
            'skills' => json_encode(['Service Kompor Gas']),
        ]);

        $this->otherTechnician = User::factory()->create([
            'role' => 'technician',
            'name' => 'Bambang Teknisi',
            'email' => 'tech2@test.com',
            'is_active' => true,
        ]);

        TechnicianProfile::create([
            'user_id' => $this->otherTechnician->id,
            'is_available' => true,
            'rating' => 4.5,
        ]);

        $this->admin = User::factory()->create([
            'role' => 'admin',
            'name' => 'Admin KlikKompor',
            'email' => 'admin@test.com',
        ]);

        $this->category = ServiceCategory::create([
            'name' => 'Kompor Gas',
            'slug' => 'kompor-gas',
            'description' => 'Kategori service kompor gas',
            'is_active' => true,
        ]);

        $this->service = ServiceItem::create([
            'service_category_id' => $this->category->id,
            'name' => 'Service Kompor 2 Tungku',
            'slug' => 'service-kompor-2-tungku',
            'description' => 'Pembersihan dan kalibrasi burner',
            'base_price' => 75000,
            'is_active' => true,
        ]);
    }

    /*
    |--------------------------------------------------------------------------
    | F014: Pengerjaan Teknisi, Validasi Transisi, & Isolasi Pembayaran
    |--------------------------------------------------------------------------
    */

    public function test_assigned_technician_can_update_status_sequentially_with_timestamps()
    {
        $order = Order::create([
            'customer_id' => $this->customer->id,
            'technician_id' => $this->technician->id,
            'order_number' => 'ORD-F014-001',
            'status' => Order::STATUS_PENDING,
            'payment_status' => 'unpaid',
            'total_amount' => 75000,
            'address' => 'Jl. Pengujian No. 10',
            'customer_name' => $this->customer->name,
            'customer_phone' => '081234567890',
            'problem_description' => 'Api kompor merah',
            'payment_method' => 'cash',
            'scheduled_at' => now()->addDay(),
        ]);

        // 1. Pending -> Accepted
        $res = $this->actingAs($this->technician, 'sanctum')
            ->patchJson("/api/v1/orders/{$order->id}/status", ['status' => Order::STATUS_ACCEPTED]);
        $res->assertOk();
        $this->assertDatabaseHas('orders', ['id' => $order->id, 'status' => Order::STATUS_ACCEPTED]);

        // 2. Accepted -> On The Way
        $res = $this->actingAs($this->technician, 'sanctum')
            ->patchJson("/api/v1/orders/{$order->id}/status", ['status' => Order::STATUS_ON_THE_WAY]);
        $res->assertOk();
        $this->assertDatabaseHas('orders', ['id' => $order->id, 'status' => Order::STATUS_ON_THE_WAY]);

        // 3. On The Way -> Arrived (checks arrived_at timestamp)
        $res = $this->actingAs($this->technician, 'sanctum')
            ->patchJson("/api/v1/orders/{$order->id}/status", ['status' => Order::STATUS_ARRIVED]);
        $res->assertOk();
        $order->refresh();
        $this->assertEquals(Order::STATUS_ARRIVED, $order->status);
        $this->assertNotNull($order->arrived_at);

        // 4. Arrived -> In Progress (checks started_at timestamp)
        $res = $this->actingAs($this->technician, 'sanctum')
            ->patchJson("/api/v1/orders/{$order->id}/status", ['status' => Order::STATUS_IN_PROGRESS]);
        $res->assertOk();
        $order->refresh();
        $this->assertEquals(Order::STATUS_IN_PROGRESS, $order->status);
        $this->assertNotNull($order->started_at);

        // 5. In Progress -> Completed (checks completed_at timestamp)
        $res = $this->actingAs($this->technician, 'sanctum')
            ->patchJson("/api/v1/orders/{$order->id}/status", ['status' => Order::STATUS_COMPLETED]);
        $res->assertOk();
        $order->refresh();
        $this->assertEquals(Order::STATUS_COMPLETED, $order->status);
        $this->assertNotNull($order->completed_at);

        // 6. ISOLATION: Order completed status does NOT automatically mark payment as paid
        $this->assertEquals('unpaid', $order->payment_status);

        // 7. Verify customer received notifications
        $notifications = Notification::where('user_id', $this->customer->id)->get();
        $this->assertTrue($notifications->count() >= 3);
    }

    public function test_unassigned_technician_is_forbidden_from_updating_order_status()
    {
        $order = Order::create([
            'customer_id' => $this->customer->id,
            'technician_id' => $this->technician->id,
            'order_number' => 'ORD-F014-002',
            'status' => Order::STATUS_ACCEPTED,
            'payment_status' => 'unpaid',
            'total_amount' => 75000,
            'address' => 'Jl. Pengujian No. 10',
            'customer_name' => $this->customer->name,
            'customer_phone' => '081234567890',
            'problem_description' => 'Api mati',
            'payment_method' => 'cash',
            'scheduled_at' => now()->addDay(),
        ]);

        $res = $this->actingAs($this->otherTechnician, 'sanctum')
            ->patchJson("/api/v1/orders/{$order->id}/status", ['status' => Order::STATUS_ON_THE_WAY]);

        $res->assertStatus(403);
    }

    public function test_invalid_status_jumping_is_rejected()
    {
        $order = Order::create([
            'customer_id' => $this->customer->id,
            'technician_id' => $this->technician->id,
            'order_number' => 'ORD-F014-003',
            'status' => Order::STATUS_PENDING,
            'payment_status' => 'unpaid',
            'total_amount' => 75000,
            'address' => 'Jl. Pengujian No. 10',
            'customer_name' => $this->customer->name,
            'customer_phone' => '081234567890',
            'problem_description' => 'Api mati',
            'payment_method' => 'cash',
            'scheduled_at' => now()->addDay(),
        ]);

        // Attempt jump: pending directly to completed without accepted/arrived/in_progress
        $res = $this->actingAs($this->technician, 'sanctum')
            ->patchJson("/api/v1/orders/{$order->id}/status", ['status' => Order::STATUS_COMPLETED]);

        $res->assertStatus(422);
    }

    /*
    |--------------------------------------------------------------------------
    | F017: Manajemen Layanan Katalog & Perlindungan Harga Transaksi
    |--------------------------------------------------------------------------
    */

    public function test_admin_can_perform_full_crud_on_service_catalog()
    {
        // 1. Create service
        $createRes = $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/v1/admin/services', [
                'service_category_id' => $this->category->id,
                'name' => 'Service Kompor Tanam 3 Tungku',
                'description' => 'Pembersihan pipa dan valve',
                'base_price' => 150000,
                'is_active' => true,
            ]);
        $createRes->assertStatus(201);
        $serviceId = $createRes->json('data.id');

        // 2. Update service
        $updateRes = $this->actingAs($this->admin, 'sanctum')
            ->putJson("/api/v1/admin/services/{$serviceId}", [
                'name' => 'Service Kompor Tanam Premium',
                'base_price' => 175000,
            ]);
        $updateRes->assertOk();
        $this->assertDatabaseHas('service_items', [
            'id' => $serviceId,
            'name' => 'Service Kompor Tanam Premium',
            'base_price' => 175000,
        ]);

        // 3. Toggle active
        $toggleRes = $this->actingAs($this->admin, 'sanctum')
            ->patchJson("/api/v1/admin/services/{$serviceId}/toggle-active");
        $toggleRes->assertOk();
        $this->assertDatabaseHas('service_items', [
            'id' => $serviceId,
            'is_active' => false,
        ]);

        // 4. Delete unused service (hard delete)
        $deleteRes = $this->actingAs($this->admin, 'sanctum')
            ->deleteJson("/api/v1/admin/services/{$serviceId}");
        $deleteRes->assertOk();
        $this->assertDatabaseMissing('service_items', ['id' => $serviceId]);
    }

    public function test_customer_cannot_order_inactive_service()
    {
        $this->service->update(['is_active' => false]);

        $res = $this->actingAs($this->customer, 'sanctum')
            ->postJson('/api/v1/orders', [
                'scheduled_at' => now()->addDay()->format('Y-m-d H:i:s'),
                'address' => 'Jl. Mawar No. 4',
                'problem_description' => 'Pemantik rusak',
                'payment_method' => 'cash',
                'services' => [
                    [
                        'service_item_id' => $this->service->id,
                        'quantity' => 1,
                    ],
                ],
            ]);

        $res->assertStatus(422);
    }

    public function test_catalog_price_update_does_not_alter_historical_order_price()
    {
        // 1. Create order with service at original price Rp75.000
        $order = Order::create([
            'customer_id' => $this->customer->id,
            'order_number' => 'ORD-HIST-001',
            'status' => Order::STATUS_PENDING,
            'payment_status' => 'unpaid',
            'total_amount' => 75000,
            'address' => 'Jl. Kenanga 12',
            'customer_name' => $this->customer->name,
            'customer_phone' => '081234567890',
            'problem_description' => 'Pembersihan',
            'payment_method' => 'cash',
            'scheduled_at' => now()->addDay(),
        ]);

        $orderItem = OrderItem::create([
            'order_id' => $order->id,
            'service_item_id' => $this->service->id,
            'service_name' => $this->service->name,
            'unit_price' => 75000,
            'quantity' => 1,
            'total_price' => 75000,
        ]);

        // 2. Admin updates catalog price to Rp120.000
        $this->actingAs($this->admin, 'sanctum')
            ->putJson("/api/v1/admin/services/{$this->service->id}", [
                'base_price' => 120000,
            ])
            ->assertOk();

        // 3. Historical order item snapshot and total amount remain strictly Rp75.000
        $order->refresh();
        $orderItem->refresh();
        $this->assertEquals(75000, (int) $order->total_amount);
        $this->assertEquals(75000, (int) $orderItem->unit_price);
        $this->assertEquals(75000, (int) $orderItem->total_price);

        // 4. Safe delete check: deleting service used in order uses soft delete, not hard delete
        $this->actingAs($this->admin, 'sanctum')
            ->deleteJson("/api/v1/admin/services/{$this->service->id}")
            ->assertOk();

        $this->assertSoftDeleted('service_items', ['id' => $this->service->id]);
    }

    public function test_non_admin_cannot_manage_service_catalog()
    {
        $res = $this->actingAs($this->customer, 'sanctum')
            ->postJson('/api/v1/admin/services', [
                'service_category_id' => $this->category->id,
                'name' => 'Service Palsu',
                'description' => 'Test',
                'base_price' => 50000,
            ]);

        $res->assertStatus(403);
    }

    /*
    |--------------------------------------------------------------------------
    | F020: Laporan Dinamis & Rekapitulasi Pendapatan
    |--------------------------------------------------------------------------
    */

    public function test_admin_can_view_dynamic_reports_and_calculate_accurate_net_revenue()
    {
        // Setup past transaction: 1 paid (100k), 1 refunded (20k), 1 pending (50k)
        $order1 = Order::create([
            'customer_id' => $this->customer->id,
            'order_number' => 'ORD-REP-001',
            'status' => Order::STATUS_COMPLETED,
            'payment_status' => 'paid',
            'total_amount' => 100000,
            'address' => 'Jl. Laporan 1',
            'customer_name' => $this->customer->name,
            'customer_phone' => '081234567890',
            'problem_description' => 'Test',
            'payment_method' => 'qris',
            'scheduled_at' => now()->addDay(),
        ]);
        Payment::create([
            'order_id' => $order1->id,
            'customer_id' => $this->customer->id,
            'payment_number' => 'PAY-REP-001',
            'payment_method' => 'qris',
            'amount' => 100000,
            'payment_status' => Payment::STATUS_PAID,
            'paid_at' => now(),
            'created_at' => now(),
        ]);

        $order2 = Order::create([
            'customer_id' => $this->customer->id,
            'order_number' => 'ORD-REP-002',
            'status' => Order::STATUS_CANCELLED,
            'payment_status' => 'failed',
            'total_amount' => 20000,
            'address' => 'Jl. Laporan 2',
            'customer_name' => $this->customer->name,
            'customer_phone' => '081234567890',
            'problem_description' => 'Test',
            'payment_method' => 'bank_transfer',
            'scheduled_at' => now()->addDay(),
        ]);
        Payment::create([
            'order_id' => $order2->id,
            'customer_id' => $this->customer->id,
            'payment_number' => 'PAY-REP-002',
            'payment_method' => 'bank_transfer',
            'amount' => 20000,
            'payment_status' => Payment::STATUS_REFUNDED,
            'created_at' => now(),
        ]);

        $order3 = Order::create([
            'customer_id' => $this->customer->id,
            'order_number' => 'ORD-REP-003',
            'status' => Order::STATUS_PENDING,
            'payment_status' => 'unpaid',
            'total_amount' => 50000,
            'address' => 'Jl. Laporan 3',
            'customer_name' => $this->customer->name,
            'customer_phone' => '081234567890',
            'problem_description' => 'Test',
            'payment_method' => 'cash',
            'scheduled_at' => now()->addDay(),
        ]);
        Payment::create([
            'order_id' => $order3->id,
            'customer_id' => $this->customer->id,
            'payment_number' => 'PAY-REP-003',
            'payment_method' => 'cash',
            'amount' => 50000,
            'payment_status' => Payment::STATUS_PENDING,
            'created_at' => now(),
        ]);

        $response = $this->actingAs($this->admin)->get(route('admin.reports'));
        $response->assertOk();

        // Net revenue: 100.000 - 20.000 = 80.000
        $response->assertViewHas('netRevenue', 80000.0);
        $response->assertViewHas('stats', function ($stats) {
            return $stats['completed_orders'] === 1 &&
                   $stats['cancelled_orders'] === 1 &&
                   $stats['pending_payments'] === 1 &&
                   $stats['paid_payments'] === 1 &&
                   $stats['gross_revenue'] == 100000 &&
                   $stats['refunded_amount'] == 20000 &&
                   $stats['net_revenue'] == 80000;
        });

        // Ensure Chart.js datasets are present
        $response->assertViewHas('chartData', function ($chartData) {
            return is_array($chartData['labels']) && is_array($chartData['data']);
        });
    }

    public function test_admin_can_export_reports_to_csv_with_accurate_headers()
    {
        $order = Order::create([
            'customer_id' => $this->customer->id,
            'order_number' => 'ORD-CSV-001',
            'status' => Order::STATUS_COMPLETED,
            'payment_status' => 'paid',
            'total_amount' => 150000,
            'address' => 'Jl. CSV No. 1',
            'customer_name' => $this->customer->name,
            'customer_phone' => '081234567890',
            'problem_description' => 'CSV test',
            'payment_method' => 'qris',
            'scheduled_at' => now()->addDay(),
        ]);

        Payment::create([
            'order_id' => $order->id,
            'customer_id' => $this->customer->id,
            'payment_number' => 'PAY-CSV-001',
            'payment_method' => 'qris',
            'amount' => 150000,
            'payment_status' => Payment::STATUS_PAID,
            'paid_at' => now(),
            'created_at' => now(),
        ]);

        $response = $this->actingAs($this->admin)->get(route('admin.reports.export'));

        $response->assertOk();
        $this->assertStringContainsString('text/csv', $response->headers->get('Content-Type'));
        $this->assertStringContainsString('attachment; filename=', $response->headers->get('Content-Disposition'));
    }
}
