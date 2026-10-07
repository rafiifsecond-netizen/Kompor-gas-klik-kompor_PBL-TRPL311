<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Chat;
use App\Models\Notification;
use App\Models\Order;
use App\Models\OrderStatusLog;
use App\Models\Payment;
use App\Models\ServiceItem;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class OrderController extends Controller
{
    /**
     * List orders filtered by role (Fitur 6 & 12).
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Order::with(['items', 'technician:id,name,phone,avatar_url', 'customer:id,name,phone,avatar_url', 'payment']);

        if ($user->isCustomer()) {
            $query->where('customer_id', $user->id);
        } elseif ($user->isTechnician()) {
            $query->where('technician_id', $user->id);
        }
        // Admin sees all orders

        if ($request->has('status')) {
            $query->where('status', $request->query('status'));
        }

        $orders = $query->latest()->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $orders,
        ]);
    }

    /**
     * Create a new booking / service order (Fitur 4 & 5).
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user->isCustomer()) {
            return response()->json(['success' => false, 'message' => 'Hanya pelanggan yang dapat memesan jasa service.'], 403);
        }

        $validated = $request->validate([
            'technician_id' => [
                'nullable',
                Rule::exists('users', 'id')->where(function ($query) {
                    $query->where('role', 'technician')->where('is_active', true);
                }),
            ],
            'scheduled_at' => ['required', 'date', 'after:now'],
            'address' => ['required', 'string'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'stove_brand' => ['nullable', 'string', 'max:100'],
            'stove_type' => ['nullable', 'string', 'max:100'],
            'problem_description' => ['required', 'string'],
            'payment_method' => ['required', 'string', 'in:cash,qris,transfer'],
            'services' => ['required', 'array', 'min:1'],
            'services.*.service_item_id' => ['required', 'exists:service_items,id'],
            'services.*.quantity' => ['required', 'integer', 'min:1'],
        ]);

        return DB::transaction(function () use ($validated, $user, $request) {
            $subtotal = 0;
            $itemsData = [];

            foreach ($validated['services'] as $srv) {
                $serviceItem = ServiceItem::findOrFail($srv['service_item_id']);
                $itemTotal = $serviceItem->base_price * $srv['quantity'];
                $subtotal += $itemTotal;

                $itemsData[] = [
                    'service_item_id' => $serviceItem->id,
                    'service_name' => $serviceItem->name,
                    'unit_price' => $serviceItem->base_price,
                    'quantity' => $srv['quantity'],
                    'total_price' => $itemTotal,
                ];
            }

            $transportFee = 15000; // Flat transport fee estimasi
            $totalAmount = $subtotal + $transportFee;

            $orderNumber = 'KP-'.date('Ymd').'-'.strtoupper(Str::random(5));

            $order = Order::create([
                'order_number' => $orderNumber,
                'customer_id' => $user->id,
                'technician_id' => $validated['technician_id'] ?? null,
                'status' => Order::STATUS_PENDING,
                'scheduled_at' => $validated['scheduled_at'],
                'customer_name' => $user->name,
                'customer_phone' => $user->phone ?? '-',
                'address' => $validated['address'],
                'latitude' => $validated['latitude'] ?? null,
                'longitude' => $validated['longitude'] ?? null,
                'stove_brand' => $validated['stove_brand'] ?? null,
                'stove_type' => $validated['stove_type'] ?? null,
                'problem_description' => $validated['problem_description'],
                'subtotal' => $subtotal,
                'transport_fee' => $transportFee,
                'discount' => 0,
                'total_amount' => $totalAmount,
                'payment_method' => $validated['payment_method'],
                'payment_status' => 'unpaid',
            ]);

            foreach ($itemsData as $item) {
                $order->items()->create($item);
            }

            if ($order->technician_id) {
                Chat::firstOrCreate(
                    ['order_id' => $order->id],
                    [
                        'customer_id' => $order->customer_id,
                        'technician_id' => $order->technician_id,
                    ]
                );

                Notification::send($order->technician_id, [
                    'type' => Notification::TYPE_ORDER_UPDATE,
                    'title' => 'Pesanan Baru Masuk',
                    'message' => "Anda menerima pesanan baru #{$order->order_number} dari {$user->name}.",
                    'data' => ['order_id' => $order->id],
                ]);
            }

            OrderStatusLog::create([
                'order_id' => $order->id,
                'actor_id' => $user->id,
                'actor_role' => 'customer',
                'status_from' => null,
                'status_to' => Order::STATUS_PENDING,
                'note' => 'Pesanan berhasil dibuat oleh pelanggan.',
            ]);

            ActivityLog::logEvent(
                eventName: 'order.created',
                description: "Pelanggan membuat pesanan baru: {$order->order_number}",
                entity: $order,
                newValues: $order->toArray(),
                request: $request,
                actor: $user
            );

            return response()->json([
                'success' => true,
                'message' => 'Pesanan berhasil dibuat.',
                'data' => $order->load(['items', 'technician']),
            ], 201);
        });
    }

    /**
     * Get order detail.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $order = Order::with([
            'items',
            'technician.technicianProfile',
            'customer',
            'statusLogs.actor:id,name,role',
            'payment',
            'review',
        ])->findOrFail($id);

        // Authorization check
        if ($user->isCustomer() && $order->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }
        if ($user->isTechnician() && $order->technician_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        // Sensitive PII Access Logging (Matriks Keamanan No 16)
        if ($user->isTechnician() || $user->isAdmin()) {
            ActivityLog::logEvent(
                eventName: 'customer_pii.accessed',
                description: "Aktor {$user->name} mengakses detail PII pesanan {$order->order_number}",
                entity: $order,
                request: $request,
                actor: $user
            );
        }

        return response()->json([
            'success' => true,
            'data' => $order,
        ]);
    }

    /**
     * Technician or Admin updates order status (Fitur 6: Manajemen Order).
     * Flow: pending -> accepted -> on_the_way -> in_progress -> completed
     */
    public function updateStatus(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($id);

        if ($user->isCustomer()) {
            return response()->json(['success' => false, 'message' => 'Pelanggan tidak dapat mengubah status pengerjaan.'], 403);
        }

        if ($user->isTechnician() && $order->technician_id && $order->technician_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Anda bukan teknisi yang menangani pesanan ini.'], 403);
        }

        if ($order->status === Order::STATUS_COMPLETED) {
            return response()->json(['success' => false, 'message' => 'Pesanan sudah selesai dan status tidak dapat diubah lagi.'], 422);
        }

        if ($order->status === Order::STATUS_CANCELLED) {
            return response()->json(['success' => false, 'message' => 'Pesanan sudah dibatalkan dan status tidak dapat diubah lagi.'], 422);
        }

        $validated = $request->validate([
            'status' => ['required', 'string', 'in:accepted,on_the_way,in_progress,completed,rejected'],
            'note' => ['nullable', 'string'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
        ]);

        $statusTo = $validated['status'];
        $oldStatus = $order->status;

        if (! $order->technician_id && $statusTo !== 'accepted' && ! $user->isAdmin()) {
            return response()->json(['success' => false, 'message' => 'Pesanan harus diterima (accepted) terlebih dahulu oleh teknisi.'], 422);
        }

        if ($statusTo === 'rejected') {
            $order->update([
                'status' => Order::STATUS_CANCELLED,
                'cancellation_reason' => $validated['note'] ?? 'Ditolak oleh teknisi.',
                'cancelled_by' => $user->id,
            ]);

            OrderStatusLog::create([
                'order_id' => $order->id,
                'actor_id' => $user->id,
                'actor_role' => $user->role,
                'status_from' => $oldStatus,
                'status_to' => Order::STATUS_CANCELLED,
                'note' => $validated['note'] ?? 'Pesanan ditolak oleh teknisi.',
                'latitude' => $validated['latitude'] ?? null,
                'longitude' => $validated['longitude'] ?? null,
            ]);

            ActivityLog::logEvent(
                eventName: 'order.technician_responded',
                description: "Teknisi menolak pesanan {$order->order_number}",
                entity: $order,
                oldValues: ['status' => $oldStatus],
                newValues: ['status' => 'cancelled', 'reason' => $validated['note'] ?? null],
                request: $request,
                actor: $user
            );

            Notification::send($order->customer_id, [
                'type' => Notification::TYPE_ORDER_UPDATE,
                'title' => 'Pesanan Ditolak',
                'message' => "Pesanan #{$order->order_number} ditolak oleh teknisi. Alasan: ".($validated['note'] ?? 'Teknisi berhalangan'),
                'data' => ['order_id' => $order->id],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pesanan ditolak.',
                'data' => $order,
            ]);
        }

        // If assigning/accepting order
        if ($statusTo === 'accepted') {
            $order->technician_id = $user->id;

            Chat::firstOrCreate(
                ['order_id' => $order->id],
                [
                    'customer_id' => $order->customer_id,
                    'technician_id' => $user->id,
                ]
            );

            Notification::send($order->customer_id, [
                'type' => Notification::TYPE_ORDER_UPDATE,
                'title' => 'Teknisi Menerima Pesanan',
                'message' => "Teknisi {$user->name} telah menerima pesanan #{$order->order_number}.",
                'data' => ['order_id' => $order->id],
            ]);

            ActivityLog::logEvent(
                eventName: 'order.technician_responded',
                description: "Teknisi {$user->name} menerima pesanan {$order->order_number}",
                entity: $order,
                request: $request,
                actor: $user
            );
        }

        if ($statusTo === 'on_the_way') {
            Notification::send($order->customer_id, [
                'type' => Notification::TYPE_ORDER_UPDATE,
                'title' => 'Teknisi Menuju Lokasi',
                'message' => "Teknisi sedang dalam perjalanan menuju lokasi Anda untuk pesanan #{$order->order_number}.",
                'data' => ['order_id' => $order->id],
            ]);
        }

        if ($statusTo === 'in_progress') {
            Notification::send($order->customer_id, [
                'type' => Notification::TYPE_ORDER_UPDATE,
                'title' => 'Servis Sedang Dikerjakan',
                'message' => "Teknisi mulai melakukan servis kompor gas untuk pesanan #{$order->order_number}.",
                'data' => ['order_id' => $order->id],
            ]);
        }

        if ($statusTo === 'completed') {
            $order->completed_at = now();
            // Increment technician jobs completed count
            if ($order->technician_id) {
                User::find($order->technician_id)?->technicianProfile()?->increment('jobs_completed_count');
            }

            Notification::send($order->customer_id, [
                'type' => Notification::TYPE_ORDER_UPDATE,
                'title' => 'Servis Telah Selesai',
                'message' => "Servis untuk pesanan #{$order->order_number} telah selesai. Silakan lakukan pembayaran dan berikan ulasan Anda.",
                'data' => ['order_id' => $order->id],
            ]);
        }

        $order->status = $statusTo;
        $order->save();

        OrderStatusLog::create([
            'order_id' => $order->id,
            'actor_id' => $user->id,
            'actor_role' => $user->role,
            'status_from' => $oldStatus,
            'status_to' => $statusTo,
            'note' => $validated['note'] ?? null,
            'latitude' => $validated['latitude'] ?? null,
            'longitude' => $validated['longitude'] ?? null,
        ]);

        ActivityLog::logEvent(
            eventName: 'order.status_transition',
            description: "Perubahan status pesanan {$order->order_number} dari {$oldStatus} ke {$statusTo}",
            entity: $order,
            oldValues: ['status' => $oldStatus],
            newValues: ['status' => $statusTo],
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => "Status pesanan berhasil diperbarui menjadi {$statusTo}.",
            'data' => $order,
        ]);
    }

    /**
     * Reschedule visit (Fitur 7: Penjadwalan Kunjungan).
     */
    public function reschedule(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($id);

        if ($user->isCustomer() && $order->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        if ($user->isTechnician() && $order->technician_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak. Anda bukan teknisi pesanan ini.'], 403);
        }

        if (in_array($order->status, [Order::STATUS_COMPLETED, Order::STATUS_CANCELLED], true)) {
            return response()->json(['success' => false, 'message' => 'Pesanan yang sudah selesai atau dibatalkan tidak dapat dijadwalkan ulang.'], 422);
        }

        $validated = $request->validate([
            'scheduled_at' => ['required', 'date', 'after:now'],
            'reason' => ['nullable', 'string'],
        ]);

        $oldSchedule = $order->scheduled_at->toDateTimeString();
        $order->update(['scheduled_at' => $validated['scheduled_at']]);

        OrderStatusLog::create([
            'order_id' => $order->id,
            'actor_id' => $user->id,
            'actor_role' => $user->role,
            'status_from' => $order->status,
            'status_to' => $order->status,
            'note' => "Penjadwalan ulang dari {$oldSchedule} ke {$validated['scheduled_at']}. Alasan: ".($validated['reason'] ?? '-'),
        ]);

        ActivityLog::logEvent(
            eventName: 'order.schedule_rescheduled',
            description: "Perubahan jadwal pesanan {$order->order_number}",
            entity: $order,
            oldValues: ['scheduled_at' => $oldSchedule],
            newValues: ['scheduled_at' => $validated['scheduled_at']],
            request: $request,
            actor: $user
        );

        $recipientId = $user->id === $order->customer_id ? $order->technician_id : $order->customer_id;
        if ($recipientId) {
            Notification::send($recipientId, [
                'type' => Notification::TYPE_ORDER_UPDATE,
                'title' => 'Jadwal Kunjungan Diubah',
                'message' => "Jadwal kunjungan pesanan #{$order->order_number} diubah menjadi {$validated['scheduled_at']}.",
                'data' => ['order_id' => $order->id, 'scheduled_at' => $validated['scheduled_at']],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Jadwal kunjungan berhasil diubah.',
            'data' => $order,
        ]);
    }

    /**
     * Process payment (Fitur 10: Pembayaran).
     */
    public function pay(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($id);

        if ($user->isCustomer() && $order->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        if ($user->isTechnician()) {
            return response()->json(['success' => false, 'message' => 'Hanya pelanggan atau admin yang dapat memproses konfirmasi pembayaran.'], 403);
        }

        if ($order->status === Order::STATUS_CANCELLED) {
            return response()->json(['success' => false, 'message' => 'Pesanan telah dibatalkan.'], 422);
        }

        if ($order->payment_status === 'paid') {
            return response()->json(['success' => false, 'message' => 'Pesanan ini sudah lunas dibayar.'], 422);
        }

        $validated = $request->validate([
            'payment_method' => ['required', 'string', 'in:cash,qris,transfer'],
            'proof_url' => ['nullable', 'string'],
        ]);

        $paymentNumber = 'PAY-'.date('Ymd').'-'.strtoupper(Str::random(5));

        $payment = Payment::updateOrCreate(
            ['order_id' => $order->id],
            [
                'customer_id' => $order->customer_id,
                'payment_number' => $paymentNumber,
                'payment_method' => $validated['payment_method'],
                'amount' => $order->total_amount,
                'payment_status' => 'paid',
                'paid_at' => now(),
                'proof_url' => $validated['proof_url'] ?? null,
                'transaction_reference' => 'TXN-'.Str::random(10),
            ]
        );

        $order->update([
            'payment_method' => $validated['payment_method'],
            'payment_status' => 'paid',
        ]);

        ActivityLog::logEvent(
            eventName: 'payment.processed',
            description: 'Pembayaran lunas sebesar Rp '.number_format($order->total_amount, 0, ',', '.')." untuk pesanan {$order->order_number}",
            entity: $payment,
            newValues: $payment->toArray(),
            request: $request,
            actor: $user
        );

        if ($order->technician_id) {
            Notification::send($order->technician_id, [
                'type' => Notification::TYPE_PAYMENT,
                'title' => 'Pembayaran Diterima',
                'message' => "Pembayaran pesanan #{$order->order_number} sebesar Rp ".number_format($order->total_amount, 0, ',', '.').' telah dikonfirmasi.',
                'data' => ['order_id' => $order->id, 'payment_id' => $payment->id],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil dikonfirmasi.',
            'data' => [
                'order' => $order,
                'payment' => $payment,
            ],
        ]);
    }
}
