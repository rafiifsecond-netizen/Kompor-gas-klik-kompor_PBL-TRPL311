<?php

namespace Database\Seeders;

use App\Models\AdditionalCost;
use App\Models\Order;
use App\Models\OrderStatusLog;
use App\Models\Payment;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class ResetDemoOngoingOrderSeeder extends Seeder
{
    private const ORDER_NUMBER = 'KP-DEMO-ONGOING-20261021';

    public function run(): void
    {
        DB::transaction(function (): void {
            $order = Order::where('order_number', self::ORDER_NUMBER)
                ->lockForUpdate()
                ->first();

            if (! $order) {
                throw new RuntimeException(
                    'Order demo tidak ditemukan. Import database/demo_ongoing_order.sql terlebih dahulu.'
                );
            }

            $serviceSubtotal = (float) $order->items()->sum('total_price');
            $discount = round($serviceSubtotal * 0.10, 2);

            AdditionalCost::where('order_id', $order->id)->delete();
            OrderStatusLog::where('order_id', $order->id)->delete();
            Payment::where('order_id', $order->id)->delete();

            $order->forceFill([
                'status' => Order::STATUS_PENDING,
                'scheduled_at' => now()->addHour(),
                'subtotal' => $serviceSubtotal,
                'discount' => $discount,
                'total_amount' => $serviceSubtotal + (float) $order->transport_fee - $discount,
                'payment_status' => 'unpaid',
                'completed_at' => null,
                'cancellation_reason' => null,
                'cancelled_by' => null,
            ])->save();

            OrderStatusLog::create([
                'order_id' => $order->id,
                'actor_id' => $order->customer_id,
                'actor_role' => 'customer',
                'status_from' => null,
                'status_to' => Order::STATUS_PENDING,
                'note' => 'Order demo direset untuk menguji alur dari Pesanan Masuk.',
            ]);
        });

        $this->command?->info(
            'Order demo siap diuji dari Pesanan Masuk: '.self::ORDER_NUMBER
        );
    }
}
