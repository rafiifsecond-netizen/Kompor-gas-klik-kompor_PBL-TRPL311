<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\ServiceItem;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class KlikKomporApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_can_retrieve_public_service_categories_and_items(): void
    {
        $response = $this->getJson('/api/v1/categories');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['id', 'name', 'slug', 'description', 'items'],
                ],
            ]);
    }

    public function test_can_search_verified_technicians(): void
    {
        $response = $this->getJson('/api/v1/technicians?search=Agus');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonFragment(['name' => 'Agus Priyanto']);
    }

    public function test_user_can_login_and_receive_token(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'identifier' => 'dewi@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'user' => ['id', 'name', 'email', 'role'],
                    'token',
                    'token_type',
                ],
            ]);
    }

    public function test_customer_can_create_service_order(): void
    {
        $customer = User::where('email', 'dewi@example.com')->first();
        $tech = User::where('email', 'agus.teknisi@klikkompor.com')->first();
        $service = ServiceItem::first();

        $response = $this->actingAs($customer)
            ->postJson('/api/v1/orders', [
                'technician_id' => $tech->id,
                'scheduled_at' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'address' => 'Jl. Kebagusan Raya No. 12',
                'latitude' => -6.305000,
                'longitude' => 106.832000,
                'stove_brand' => 'Rinnai',
                'stove_type' => 'Kompor 2 Tungku',
                'problem_description' => 'Api kecil dan merah',
                'payment_method' => 'cash',
                'services' => [
                    [
                        'service_item_id' => $service->id,
                        'quantity' => 1,
                    ],
                ],
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'pending');

        $this->assertDatabaseHas('orders', [
            'customer_id' => $customer->id,
            'stove_brand' => 'Rinnai',
        ]);
    }

    public function test_technician_can_update_order_status(): void
    {
        $tech = User::where('email', 'agus.teknisi@klikkompor.com')->first();
        $order = Order::where('technician_id', $tech->id)->first();
        $order->update(['status' => Order::STATUS_ACCEPTED]);

        $response = $this->actingAs($tech)
            ->patchJson("/api/v1/orders/{$order->id}/status", [
                'status' => 'on_the_way',
                'note' => 'Sedang menuju lokasi pelanggan',
                'latitude' => -6.229728,
                'longitude' => 106.855850,
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'on_the_way');

        $this->assertDatabaseHas('order_status_logs', [
            'order_id' => $order->id,
            'status_to' => 'on_the_way',
        ]);
    }

    public function test_admin_can_access_dashboard_metrics_and_logs(): void
    {
        $admin = User::where('email', 'admin@klikkompor.com')->first();

        $response = $this->actingAs($admin)
            ->getJson('/api/v1/admin/dashboard-stats');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'metrics' => [
                        'total_orders',
                        'completed_orders',
                        'total_revenue',
                        'total_customers',
                        'total_technicians',
                    ],
                    'recent_orders',
                    'recent_logs',
                ],
            ]);
    }

    public function test_non_admin_cannot_access_admin_dashboard(): void
    {
        $customer = User::where('email', 'dewi@example.com')->first();

        $response = $this->actingAs($customer)
            ->getJson('/api/v1/admin/dashboard-stats');

        $response->assertStatus(403)
            ->assertJsonPath('success', false);
    }
}
