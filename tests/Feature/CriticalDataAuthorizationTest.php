<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class CriticalDataAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_cannot_validate_promo_for_another_customers_order(): void
    {
        $this->seed();
        $owner = User::where('email', 'dewi@example.com')->firstOrFail();
        $otherCustomer = User::factory()->create(['role' => 'customer']);
        $order = Order::where('customer_id', $owner->id)->firstOrFail();

        $this->actingAs($otherCustomer)
            ->postJson('/api/v1/promos/validate', [
                'order_id' => $order->id,
                'promo_code' => 'WELCOME10',
                'payment_method' => 'cash',
            ])
            ->assertForbidden();
    }

    public function test_technician_cannot_read_or_upload_an_unrelated_payment(): void
    {
        $this->seed();
        $owner = User::where('email', 'dewi@example.com')->firstOrFail();
        $technician = User::factory()->create(['role' => 'technician']);
        $order = Order::where('customer_id', $owner->id)->firstOrFail();
        $payment = Payment::create([
            'order_id' => $order->id,
            'customer_id' => $owner->id,
            'payment_number' => 'PAY-AUTH-'.uniqid(),
            'payment_method' => 'qris',
            'amount' => 100000,
            'payment_status' => Payment::STATUS_PENDING,
        ]);

        $this->actingAs($technician)
            ->getJson("/api/v1/payments/{$payment->id}/status")
            ->assertForbidden();

        $this->actingAs($technician)
            ->postJson("/api/v1/payments/{$payment->id}/upload-proof")
            ->assertForbidden();
    }

    public function test_admin_settings_persist_tariff_and_commission_values(): void
    {
        $this->seed();
        $admin = User::where('email', 'admin@klikkompor.com')->firstOrFail();

        $this->actingAs($admin)
            ->post('/admin/settings', [
                'travel_base_fee' => 12000,
                'travel_free_km' => 3,
                'travel_rate_per_km' => 2500,
                'platform_commission_percent' => '15.00',
            ])
            ->assertRedirect();

        $this->assertDatabaseHas('platform_settings', [
            'key' => 'travel_base_fee',
            'value' => '12000',
        ]);
        $this->assertDatabaseHas('platform_settings', [
            'key' => 'platform_commission_percent',
            'value' => '15.00',
        ]);
    }

    public function test_paid_order_cannot_create_a_second_payment(): void
    {
        $this->seed();
        $customer = User::where('email', 'dewi@example.com')->firstOrFail();
        $order = Order::where('customer_id', $customer->id)->firstOrFail();
        $order->update(['payment_status' => 'paid']);

        $this->actingAs($customer)
            ->postJson('/api/v1/payments/checkout', [
                'order_id' => $order->id,
                'payment_method' => 'cash',
            ])
            ->assertStatus(422)
            ->assertJsonPath('success', false);
    }

    public function test_midtrans_refund_is_requested_before_local_refund_state(): void
    {
        $this->seed();
        config(['services.midtrans.server_key' => 'SB-Mid-server-test']);
        Http::fake([
            'https://api.sandbox.midtrans.com/v2/*/refund' => Http::response([
                'status_code' => '200',
                'transaction_status' => 'refund',
            ]),
        ]);

        $admin = User::where('email', 'admin@klikkompor.com')->firstOrFail();
        $customer = User::where('email', 'dewi@example.com')->firstOrFail();
        $order = Order::where('customer_id', $customer->id)->firstOrFail();
        $payment = Payment::create([
            'order_id' => $order->id,
            'customer_id' => $customer->id,
            'payment_number' => 'PAY-REFUND-'.uniqid(),
            'payment_method' => 'qris',
            'amount' => 100000,
            'payment_status' => Payment::STATUS_PAID,
            'gateway_provider' => 'midtrans',
            'gateway_order_id' => 'KP-REFUND-TEST',
        ]);

        $this->actingAs($admin)
            ->postJson("/api/v1/admin/payments/{$payment->id}/refund", [
                'reason' => 'Customer cancellation',
            ])
            ->assertOk();

        Http::assertSent(fn ($request) => str_ends_with($request->url(), '/v2/KP-REFUND-TEST/refund'));
        $this->assertDatabaseHas('payments', [
            'id' => $payment->id,
            'payment_status' => Payment::STATUS_REFUNDED,
        ]);
    }
}
