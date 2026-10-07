<?php

namespace Tests\Feature;

use App\Models\AdditionalCost;
use App\Models\Address;
use App\Models\Notification;
use App\Models\Order;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class KlikKomporExtendedFeaturesTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_technician_profile_hides_ktp_number_on_public_endpoint(): void
    {
        $tech = User::where('email', 'agus.teknisi@klikkompor.com')->first();

        $response = $this->getJson("/api/v1/technicians/{$tech->id}");

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonMissing(['ktp_number']);
    }

    public function test_customer_address_book_crud_and_default(): void
    {
        $customer = User::where('email', 'dewi@example.com')->first();

        // 1. Create first address (should be default automatically)
        $response = $this->actingAs($customer)
            ->postJson('/api/v1/addresses', [
                'label' => 'Rumah',
                'recipient_name' => 'Dewi Sartika',
                'phone' => '081299887766',
                'full_address' => 'Jl. Tebet Barat No. 10',
                'latitude' => -6.230000,
                'longitude' => 106.850000,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.is_default', true);

        $address1Id = $response->json('data.id');

        // 2. Create second address with is_default = true
        $response2 = $this->actingAs($customer)
            ->postJson('/api/v1/addresses', [
                'label' => 'Kantor',
                'recipient_name' => 'Dewi Kantor',
                'phone' => '081299887766',
                'full_address' => 'Gedung Wisma 46 Lt. 12',
                'is_default' => true,
            ]);

        $response2->assertStatus(201)
            ->assertJsonPath('data.is_default', true);

        $address2Id = $response2->json('data.id');

        // Address 1 should no longer be default
        $this->assertFalse(Address::find($address1Id)->is_default);

        // 3. Switch default back to address 1
        $this->actingAs($customer)
            ->patchJson("/api/v1/addresses/{$address1Id}/default")
            ->assertStatus(200)
            ->assertJsonPath('data.is_default', true);

        $this->assertTrue(Address::find($address1Id)->is_default);
        $this->assertFalse(Address::find($address2Id)->is_default);

        // 4. Delete address 2
        $this->actingAs($customer)
            ->deleteJson("/api/v1/addresses/{$address2Id}")
            ->assertStatus(200);

        $this->assertDatabaseMissing('addresses', ['id' => $address2Id]);
    }

    public function test_order_in_app_chat_and_messaging(): void
    {
        $customer = User::where('email', 'dewi@example.com')->first();
        $tech = User::where('email', 'agus.teknisi@klikkompor.com')->first();
        $order = Order::where('customer_id', $customer->id)->first();
        $order->update(['technician_id' => $tech->id, 'status' => Order::STATUS_ACCEPTED]);

        // Customer sends a message
        $response = $this->actingAs($customer)
            ->postJson("/api/v1/orders/{$order->id}/chat/messages", [
                'message' => 'Halo Pak Agus, apakah alat pengganti sudah siap?',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.message', 'Halo Pak Agus, apakah alat pengganti sudah siap?');

        // Technician receives message in chat and views it (auto marks read)
        $techChat = $this->actingAs($tech)
            ->getJson("/api/v1/orders/{$order->id}/chat");

        $techChat->assertStatus(200)
            ->assertJsonPath('success', true);

        // Unauthorized user cannot access this order chat
        $unrelatedUser = User::where('email', 'rian@example.com')->first();
        $this->actingAs($unrelatedUser)
            ->getJson("/api/v1/orders/{$order->id}/chat")
            ->assertStatus(403);
    }

    public function test_in_app_notifications_workflow(): void
    {
        $customer = User::where('email', 'dewi@example.com')->first();

        // Send a test notification
        $notification = Notification::send($customer->id, [
            'type' => Notification::TYPE_ORDER_UPDATE,
            'title' => 'Status Berubah',
            'message' => 'Teknisi sedang menuju lokasi.',
        ]);

        // Check unread count
        $this->actingAs($customer)
            ->getJson('/api/v1/notifications/unread-count')
            ->assertStatus(200)
            ->assertJsonPath('data.unread_count', 1);

        // Mark single notification as read
        $this->actingAs($customer)
            ->patchJson("/api/v1/notifications/{$notification->id}/read")
            ->assertStatus(200);

        $this->assertTrue($notification->fresh()->isRead());

        // Create another notification and mark all as read
        Notification::send($customer->id, [
            'type' => Notification::TYPE_PROMO,
            'title' => 'Promo Diskon Servis',
            'message' => 'Diskon 10% minggu ini.',
        ]);

        $this->actingAs($customer)
            ->postJson('/api/v1/notifications/read-all')
            ->assertStatus(200);

        $this->assertEquals(0, $customer->notifications()->whereNull('read_at')->count());
    }

    public function test_additional_costs_proposal_approval_and_rejection(): void
    {
        $customer = User::where('email', 'dewi@example.com')->first();
        $tech = User::where('email', 'agus.teknisi@klikkompor.com')->first();
        $order = Order::where('customer_id', $customer->id)->first();
        $order->update([
            'technician_id' => $tech->id,
            'status' => Order::STATUS_IN_PROGRESS,
            'subtotal' => 100000,
            'transport_fee' => 15000,
            'total_amount' => 115000,
        ]);

        $initialTotal = (float) $order->total_amount;

        // 1. Technician proposes additional sparepart cost
        $response = $this->actingAs($tech)
            ->postJson("/api/v1/orders/{$order->id}/additional-costs", [
                'item_name' => 'Seal Regulator & Selang Gas LPG',
                'description' => 'Selang lama sudah getas dan retak, membahayakan.',
                'quantity' => 1,
                'unit_price' => 45000,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.subtotal', '45000.00');

        $costId = $response->json('data.id');

        // 2. Customer approves additional cost -> order total must increase by 45,000
        $approveResponse = $this->actingAs($customer)
            ->patchJson("/api/v1/orders/{$order->id}/additional-costs/{$costId}/approve");

        $approveResponse->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.additional_cost.status', AdditionalCost::STATUS_APPROVED);

        $order->refresh();
        $this->assertEquals($initialTotal + 45000, (float) $order->total_amount);

        // 3. Propose another cost and customer rejects it
        $cost2Response = $this->actingAs($tech)
            ->postJson("/api/v1/orders/{$order->id}/additional-costs", [
                'item_name' => 'Knob Putaran Kompor Tambahan',
                'quantity' => 2,
                'unit_price' => 20000,
            ]);

        $cost2Id = $cost2Response->json('data.id');

        $this->actingAs($customer)
            ->patchJson("/api/v1/orders/{$order->id}/additional-costs/{$cost2Id}/reject")
            ->assertStatus(200)
            ->assertJsonPath('data.status', AdditionalCost::STATUS_REJECTED);

        // Order total remains unchanged after rejection
        $order->refresh();
        $this->assertEquals($initialTotal + 45000, (float) $order->total_amount);
    }

    public function test_cannot_update_status_of_completed_or_cancelled_order(): void
    {
        $tech = User::where('email', 'agus.teknisi@klikkompor.com')->first();
        $order = Order::where('technician_id', $tech->id)->first();
        $order->update(['status' => Order::STATUS_COMPLETED]);

        $response = $this->actingAs($tech)
            ->patchJson("/api/v1/orders/{$order->id}/status", [
                'status' => 'on_the_way',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('success', false);
    }

    public function test_technician_rejection_logs_status_and_notifies_customer(): void
    {
        $customer = User::where('email', 'dewi@example.com')->first();
        $tech = User::where('email', 'agus.teknisi@klikkompor.com')->first();
        $order = Order::where('customer_id', $customer->id)->first();
        $order->update(['technician_id' => $tech->id, 'status' => Order::STATUS_PENDING]);

        $response = $this->actingAs($tech)
            ->patchJson("/api/v1/orders/{$order->id}/status", [
                'status' => 'rejected',
                'note' => 'Jadwal bentrok dengan pekerjaan lain.',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true);

        $this->assertDatabaseHas('order_status_logs', [
            'order_id' => $order->id,
            'status_to' => Order::STATUS_CANCELLED,
        ]);

        $this->assertDatabaseHas('notifications', [
            'user_id' => $customer->id,
            'type' => Notification::TYPE_ORDER_UPDATE,
        ]);
    }

    public function test_unauthorized_user_cannot_reschedule_or_pay_order(): void
    {
        $customer = User::where('email', 'dewi@example.com')->first();
        $otherCustomer = User::where('email', 'rian@example.com')->first();
        $order = Order::where('customer_id', $customer->id)->first();
        $order->update(['status' => Order::STATUS_PENDING, 'payment_status' => 'unpaid']);

        // Other customer tries to pay Dewi's order
        $this->actingAs($otherCustomer)
            ->postJson("/api/v1/orders/{$order->id}/pay", [
                'payment_method' => 'cash',
            ])
            ->assertStatus(403);

        // Other customer tries to reschedule Dewi's order
        $this->actingAs($otherCustomer)
            ->patchJson("/api/v1/orders/{$order->id}/reschedule", [
                'scheduled_at' => now()->addDays(3)->format('Y-m-d H:i:s'),
            ])
            ->assertStatus(403);
    }

    public function test_role_change_to_technician_creates_technician_profile(): void
    {
        $admin = User::where('email', 'admin@klikkompor.com')->first();
        $customer = User::where('email', 'rian@example.com')->first();

        // Customer has no technician profile
        $this->assertNull($customer->technicianProfile);

        // Admin changes role to technician
        $response = $this->actingAs($admin)
            ->patchJson("/api/v1/admin/users/{$customer->id}/role", [
                'role' => 'technician',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true);

        $customer->refresh();
        $this->assertNotNull($customer->technicianProfile);

        // New technician can now update availability without silent failure
        $this->actingAs($customer)
            ->patchJson('/api/v1/technician/availability', [
                'is_available' => false,
            ])
            ->assertStatus(200)
            ->assertJsonPath('data.is_available', false);

        $this->assertFalse($customer->fresh()->technicianProfile->is_available);
    }
}
