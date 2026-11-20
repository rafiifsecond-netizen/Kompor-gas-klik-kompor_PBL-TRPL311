<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Chat;
use App\Models\CommissionRecord;
use App\Models\Notification;
use App\Models\Order;
use App\Models\OrderStatusLog;
use App\Models\Payment;
use App\Models\ServiceItem;
use App\Models\User;
use App\Services\Payment\FinancialCalculator;
use App\Services\Payment\PaymentService;
use App\Services\Payment\PromoService;
use App\Services\Payment\WalletService;
use App\Services\TravelFeeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class OrderController extends Controller
{
    public function __construct(
        protected TravelFeeService $travelFeeService
    ) {}

    public function travelEstimate(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'technician_id' => ['nullable', 'integer', 'exists:users,id'],
        ]);

        $technician = ! empty($validated['technician_id'])
            ? User::with('technicianProfile')->find($validated['technician_id'])
            : null;

        $travel = $this->travelFeeService->calculate(
            (float) $validated['latitude'],
            (float) $validated['longitude'],
            $technician?->technicianProfile?->current_latitude,
            $technician?->technicianProfile?->current_longitude,
        );

        return response()->json([
            'success' => true,
            'data' => $travel,
        ]);
    }

    /**
     * List orders filtered by role (Fitur 6 & 12).
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Order::with([
            'items.serviceItem',
            'additionalCosts',
            'technician' => function ($q) {
                $q->select('id', 'name', 'phone', 'avatar_url')
                    ->with('technicianProfile');
            },
            'customer:id,name,phone,avatar_url',
            'payment',
        ]);

        if ($user->isCustomer()) {
            $query->where('customer_id', $user->id);
        } elseif ($user->isTechnician()) {
            $query->where(function ($query) use ($user) {
                $query->where('technician_id', $user->id)
                    ->orWhere(function ($query) {
                        $query->whereNull('technician_id')
                            ->where('status', Order::STATUS_PENDING);
                    });
            });
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
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'stove_brand' => ['nullable', 'string', 'max:100'],
            'stove_type' => ['nullable', 'string', 'max:100'],
            'problem_description' => ['required', 'string'],
            'payment_method' => ['required', 'string', 'in:cash,qris'],
            'services' => ['required', 'array', 'min:1'],
            'services.*.service_item_id' => ['required', 'exists:service_items,id'],
            'services.*.quantity' => ['required', 'integer', 'min:1'],
        ]);

        return DB::transaction(function () use ($validated, $user, $request) {
            $subtotal = 0;
            $itemsData = [];

            foreach ($validated['services'] as $srv) {
                $serviceItem = ServiceItem::findOrFail($srv['service_item_id']);

                if (! $serviceItem->is_active) {
                    throw ValidationException::withMessages([
                        'services' => ["Layanan '{$serviceItem->name}' saat ini sedang tidak aktif dan tidak dapat dipesan."],
                    ]);
                }

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

            $technician = ! empty($validated['technician_id'])
                ? User::with('technicianProfile')->find($validated['technician_id'])
                : null;
            $travel = $this->travelFeeService->calculate(
                isset($validated['latitude']) ? (float) $validated['latitude'] : null,
                isset($validated['longitude']) ? (float) $validated['longitude'] : null,
                $technician?->technicianProfile?->current_latitude,
                $technician?->technicianProfile?->current_longitude,
            );
            $transportFee = $travel['fee'];
            $totalAmount = $subtotal + $transportFee;

            $orderNumber = 'KP-'.date('Ymd').'-'.strtoupper(Str::random(5));

            $orderData = [
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
            ];

            $travelSnapshotColumns = [
                'technician_latitude',
                'technician_longitude',
                'travel_distance_km',
                'travel_duration_minutes',
                'travel_fee_source',
            ];
            $hasTravelSnapshotColumns = collect($travelSnapshotColumns)
                ->every(fn (string $column): bool => Schema::hasColumn('orders', $column));

            if ($hasTravelSnapshotColumns) {
                $orderData += [
                    'technician_latitude' => $technician?->technicianProfile?->current_latitude,
                    'technician_longitude' => $technician?->technicianProfile?->current_longitude,
                    'travel_distance_km' => $travel['distance_km'],
                    'travel_duration_minutes' => $travel['duration_minutes'],
                    'travel_fee_source' => $travel['source'],
                ];
            } else {
                Log::warning('Travel snapshot columns are unavailable; creating order without travel snapshot fields.', [
                    'order_number' => $orderNumber,
                    'migration' => '2026_11_21_020000_add_travel_pricing_snapshots',
                ]);
            }

            $order = Order::create($orderData);

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
                'data' => $order->load([
                    'items',
                    'technician.technicianProfile',
                ]),
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
            'items.serviceItem',
            'technician.technicianProfile',
            'customer',
            'statusLogs.actor:id,name,role',
            'payment',
            'review',
            'additionalCosts',
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

    /** Replace the service items on an active technician order. */
    public function updateServices(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $order = Order::with('items')->findOrFail($id);

        if ($user->isTechnician() && $order->technician_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Anda bukan teknisi yang menangani pesanan ini.'], 403);
        }

        if (! in_array($order->status, [Order::STATUS_ACCEPTED, Order::STATUS_ON_THE_WAY, Order::STATUS_IN_PROGRESS], true)) {
            return response()->json(['success' => false, 'message' => 'Layanan hanya dapat diubah saat pesanan sedang berjalan.'], 422);
        }

        $validated = $request->validate([
            'services' => ['required', 'array', 'min:1'],
            'services.*.service_item_id' => [
                'required',
                Rule::exists('service_items', 'id')->where('is_active', true),
            ],
            'services.*.quantity' => ['required', 'integer', 'min:1'],
        ]);

        return DB::transaction(function () use ($order, $validated, $request, $user) {
            $oldItems = $order->items->map(fn ($item) => [
                'service_item_id' => $item->service_item_id,
                'quantity' => $item->quantity,
            ])->all();
            $serviceSubtotal = 0;
            $replacementItems = [];

            foreach ($validated['services'] as $serviceData) {
                $serviceItem = ServiceItem::where('is_active', true)
                    ->findOrFail($serviceData['service_item_id']);
                $quantity = (int) $serviceData['quantity'];
                $lineTotal = (int) $serviceItem->base_price * $quantity;
                $serviceSubtotal += $lineTotal;
                $replacementItems[] = [
                    'service_item_id' => $serviceItem->id,
                    'service_name' => $serviceItem->name,
                    'unit_price' => (int) $serviceItem->base_price,
                    'quantity' => $quantity,
                    'total_price' => $lineTotal,
                ];
            }

            $approvedAdditionalCosts = (int) $order->additionalCosts()
                ->where('status', 'approved')
                ->sum('subtotal');

            $order->items()->delete();
            $order->items()->createMany($replacementItems);
            $order->subtotal = $serviceSubtotal + $approvedAdditionalCosts;

            // Hitung ulang diskon & total dengan FinancialCalculator (integer rupiah)
            $calculation = FinancialCalculator::calculate(
                serviceSubtotal: (int) $order->subtotal,
                transportFee: (int) $order->transport_fee,
                discountAmount: (int) ($order->discount ?? 0)
            );
            $order->discount = $calculation->discountAmount;
            $order->total_amount = $calculation->paymentAmount;
            $order->save();

            ActivityLog::logEvent(
                eventName: 'order.services.updated',
                description: "Teknisi mengubah layanan pesanan {$order->order_number}",
                entity: $order,
                oldValues: ['items' => $oldItems],
                newValues: ['items' => $replacementItems],
                request: $request,
                actor: $user
            );

            return response()->json([
                'success' => true,
                'message' => 'Layanan pesanan berhasil diperbarui.',
                'data' => $order->fresh()->load(['items', 'additionalCosts']),
            ]);
        });
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
            'status' => ['required', 'string', 'in:accepted,on_the_way,arrived,in_progress,completed,cancelled,rejected'],
            'note' => ['nullable', 'string'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
        ]);

        $statusTo = $validated['status'];
        $oldStatus = $order->status;

        // Validasi aturan transisi sekuensial status pengerjaan (F014)
        $allowedTransitions = [
            Order::STATUS_PENDING => [Order::STATUS_ACCEPTED, Order::STATUS_CANCELLED, 'rejected'],
            Order::STATUS_ACCEPTED => [Order::STATUS_ON_THE_WAY, Order::STATUS_CANCELLED, 'rejected'],
            Order::STATUS_ON_THE_WAY => [Order::STATUS_ARRIVED, Order::STATUS_IN_PROGRESS, Order::STATUS_CANCELLED],
            Order::STATUS_ARRIVED => [Order::STATUS_IN_PROGRESS, Order::STATUS_CANCELLED],
            Order::STATUS_IN_PROGRESS => [Order::STATUS_COMPLETED, Order::STATUS_CANCELLED],
            Order::STATUS_COMPLETED => [],
            Order::STATUS_CANCELLED => [],
        ];

        if ($statusTo !== $oldStatus && ! in_array($statusTo, $allowedTransitions[$oldStatus] ?? [], true)) {
            return response()->json([
                'success' => false,
                'message' => "Transisi status pengerjaan dari '{$oldStatus}' ke '{$statusTo}' tidak diizinkan. Tahapan harus berurutan.",
            ], 422);
        }

        return DB::transaction(function () use ($order, $user, $validated, $request, $statusTo, $oldStatus) {
            // Auto-assign technician if order has no technician_id assigned yet
            if (! $order->technician_id && $user->isTechnician()) {
                $order->technician_id = $user->id;
                Chat::firstOrCreate(
                    ['order_id' => $order->id],
                    [
                        'customer_id' => $order->customer_id,
                        'technician_id' => $user->id,
                    ]
                );
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

                $travel = $this->travelFeeService->calculate(
                    $order->latitude !== null ? (float) $order->latitude : null,
                    $order->longitude !== null ? (float) $order->longitude : null,
                    $user->technicianProfile?->current_latitude,
                    $user->technicianProfile?->current_longitude,
                );
                $transportFee = (int) $travel['fee'];
                $orderData = [
                    'transport_fee' => $transportFee,
                    'total_amount' => max(0, (int) $order->subtotal - (int) $order->discount + $transportFee),
                ];
                if (Schema::hasColumns('orders', [
                    'technician_latitude',
                    'technician_longitude',
                    'travel_distance_km',
                    'travel_duration_minutes',
                    'travel_fee_source',
                ])) {
                    $orderData += [
                        'technician_latitude' => $user->technicianProfile?->current_latitude,
                        'technician_longitude' => $user->technicianProfile?->current_longitude,
                        'travel_distance_km' => $travel['distance_km'],
                        'travel_duration_minutes' => $travel['duration_minutes'],
                        'travel_fee_source' => $travel['source'],
                    ];
                }
                $order->fill($orderData);

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

            if ($statusTo === 'arrived') {
                $order->arrived_at = now();
                Notification::send($order->customer_id, [
                    'type' => Notification::TYPE_ORDER_UPDATE,
                    'title' => 'Teknisi Telah Tiba',
                    'message' => "Teknisi telah tiba di lokasi Anda untuk pesanan #{$order->order_number}.",
                    'data' => ['order_id' => $order->id],
                ]);
            }

            if ($statusTo === 'in_progress') {
                $order->started_at = now();
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
                    $techUser = User::find($order->technician_id);
                    $techUser?->technicianProfile()?->increment('jobs_completed_count');

                    // Rilis escrow ke dompet teknisi jika pembayaran non-cash sudah lunas
                    $activePayment = $order->activePayment;
                    if ($techUser && $activePayment && $activePayment->payment_status === Payment::STATUS_PAID && $activePayment->payment_method === 'qris') {
                        $commissionRecord = CommissionRecord::where('order_id', $order->id)->first();
                        $netIncome = $commissionRecord ? (int) $commissionRecord->technician_net_income : (int) $activePayment->amount;
                        app(WalletService::class)->releaseEscrowToBalance(
                            technician: $techUser,
                            order: $order,
                            technicianNetIncome: $netIncome,
                            escrowAmountToRelease: (int) $activePayment->amount
                        );
                        if ($commissionRecord) {
                            $commissionRecord->update([
                                'settlement_status' => \App\Models\CommissionRecord::STATUS_SETTLED,
                                'settled_at' => now(),
                            ]);
                        }
                    }
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
        });
    }

    /**
     * Cancel an active order (Customer, Technician, or Admin).
     */
    public function cancel(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($id);

        if ($user->isCustomer() && $order->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        if ($user->isTechnician() && $order->technician_id && $order->technician_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak. Anda bukan teknisi pesanan ini.'], 403);
        }

        if (in_array($order->status, [Order::STATUS_COMPLETED, Order::STATUS_CANCELLED], true)) {
            return response()->json(['success' => false, 'message' => 'Pesanan sudah selesai atau telah dibatalkan sebelumnya.'], 422);
        }

        if ($user->isCustomer() && in_array($order->status, [Order::STATUS_IN_PROGRESS], true)) {
            return response()->json(['success' => false, 'message' => 'Pesanan tidak dapat dibatalkan karena teknisi sedang mengerjakan servis.'], 422);
        }

        $validated = $request->validate([
            'reason' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string', 'max:255'],
        ]);

        $reason = $validated['reason'] ?? $validated['note'] ?? ($user->isCustomer() ? 'Dibatalkan oleh pelanggan.' : 'Dibatalkan oleh pihak penyedia jasa.');
        $oldStatus = $order->status;

        return DB::transaction(function () use ($order, $user, $reason, $oldStatus, $request) {
            $order->update([
                'status' => Order::STATUS_CANCELLED,
                'cancellation_reason' => $reason,
                'cancelled_by' => $user->id,
            ]);

            OrderStatusLog::create([
                'order_id' => $order->id,
                'actor_id' => $user->id,
                'actor_role' => $user->role,
                'status_from' => $oldStatus,
                'status_to' => Order::STATUS_CANCELLED,
                'note' => $reason,
            ]);

            // Reversal escrow & release promo
            if ($order->technician_id) {
                $techUser = User::find($order->technician_id);
                $activePayment = $order->activePayment;
                if ($techUser && $activePayment && $activePayment->payment_status === Payment::STATUS_PAID) {
                    app(WalletService::class)->reverseEscrow($techUser, (int) $activePayment->amount);
                }
            }
            app(PromoService::class)->releasePromo($order);

            ActivityLog::logEvent(
                eventName: 'order.cancelled',
                description: "Pesanan {$order->order_number} dibatalkan oleh {$user->name} ({$user->role})",
                entity: $order,
                oldValues: ['status' => $oldStatus],
                newValues: ['status' => Order::STATUS_CANCELLED, 'reason' => $reason],
                request: $request,
                actor: $user
            );

            // Notify counterpart
            $targetUserId = $user->id === $order->customer_id ? $order->technician_id : $order->customer_id;
            if ($targetUserId) {
                Notification::send($targetUserId, [
                    'type' => Notification::TYPE_ORDER_UPDATE,
                    'title' => 'Pesanan Dibatalkan',
                    'message' => "Pesanan #{$order->order_number} telah dibatalkan. Alasan: {$reason}",
                    'data' => ['order_id' => $order->id],
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Pesanan berhasil dibatalkan.',
                'data' => $order->fresh(),
            ]);
        });
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

        return DB::transaction(function () use ($order, $user, $validated, $request) {
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
        });
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
            'promo_code' => ['nullable', 'string', 'max:30'],
            'sender_bank_name' => ['nullable', 'string', 'max:50'],
            'proof_url' => ['nullable', 'string'],
        ]);

        try {
            $paymentService = app(PaymentService::class);
            $payment = $paymentService->checkout(
                order: $order,
                paymentMethod: $validated['payment_method'],
                promoCode: $validated['promo_code'] ?? null,
                senderBankName: $validated['sender_bank_name'] ?? null
            );

            return response()->json([
                'success' => true,
                'message' => $payment->payment_method === 'cash'
                    ? 'Pesanan berhasil dibuat dengan metode tunai. Harap serahkan pembayaran ke teknisi.'
                    : 'Instruksi pembayaran berhasil dibuat. Silakan selesaikan pembayaran.',
                'data' => [
                    'order' => $order->fresh(),
                    'payment' => $payment,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }
}
