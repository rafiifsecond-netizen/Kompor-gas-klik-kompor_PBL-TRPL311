<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\AdditionalCost;
use App\Models\Notification;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdditionalCostController extends Controller
{
    /**
     * List all additional costs submitted for an order.
     */
    public function index(Request $request, int $orderId): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($orderId);

        if (! $this->canAccessOrder($user, $order)) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $costs = $order->additionalCosts()
            ->with('technician:id,name,phone')
            ->latest('id')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $costs,
        ]);
    }

    /**
     * Technician proposes an additional cost/sparepart during repair.
     */
    public function store(Request $request, int $orderId): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($orderId);

        if ($user->isCustomer()) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya teknisi yang menangani pesanan yang dapat mengajukan biaya tambahan.',
            ], 403);
        }

        if ($user->isTechnician() && $order->technician_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Anda bukan teknisi yang menangani pesanan ini.',
            ], 403);
        }

        if (! in_array($order->status, [Order::STATUS_ACCEPTED, Order::STATUS_ON_THE_WAY, Order::STATUS_IN_PROGRESS], true)) {
            return response()->json([
                'success' => false,
                'message' => 'Biaya tambahan hanya dapat diajukan saat pesanan sedang berjalan.',
            ], 422);
        }

        $validated = $request->validate([
            'item_name' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'quantity' => ['required', 'integer', 'min:1'],
            'unit_price' => ['required', 'numeric', 'min:0'],
            'photo_url' => ['nullable', 'string'],
        ]);

        $subtotal = $validated['quantity'] * $validated['unit_price'];

        $cost = $order->additionalCosts()->create([
            'technician_id' => $user->id,
            'item_name' => $validated['item_name'],
            'description' => $validated['description'] ?? null,
            'quantity' => $validated['quantity'],
            'unit_price' => $validated['unit_price'],
            'subtotal' => $subtotal,
            'photo_url' => $validated['photo_url'] ?? null,
            'status' => AdditionalCost::STATUS_PENDING,
        ]);

        Notification::send($order->customer_id, [
            'type' => Notification::TYPE_ORDER_UPDATE,
            'title' => 'Pengajuan Biaya Tambahan',
            'message' => "Teknisi mengajukan biaya tambahan: {$cost->item_name} sebesar Rp ".number_format($subtotal, 0, ',', '.').'. Harap konfirmasi persetujuan.',
            'data' => [
                'order_id' => $order->id,
                'additional_cost_id' => $cost->id,
            ],
        ]);

        ActivityLog::logEvent(
            eventName: 'order.additional_cost_proposed',
            description: "Teknisi mengajukan biaya tambahan: {$cost->item_name} (Rp ".number_format($subtotal, 0, ',', '.').") pada pesanan {$order->order_number}",
            entity: $cost,
            newValues: $cost->toArray(),
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Biaya tambahan berhasil diajukan dan menunggu persetujuan pelanggan.',
            'data' => $cost,
        ], 201);
    }

    /**
     * Customer approves an additional cost proposal.
     */
    public function approve(Request $request, int $orderId, int $costId): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($orderId);

        if ($user->isCustomer() && $order->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        if ($user->isTechnician()) {
            return response()->json(['success' => false, 'message' => 'Hanya pelanggan atau admin yang dapat menyetujui biaya tambahan.'], 403);
        }

        $cost = $order->additionalCosts()->findOrFail($costId);

        if ($cost->status !== AdditionalCost::STATUS_PENDING) {
            return response()->json([
                'success' => false,
                'message' => 'Biaya tambahan ini sudah diproses sebelumnya.',
            ], 422);
        }

        $cost->update(['status' => AdditionalCost::STATUS_APPROVED]);

        // Recalculate order subtotal and total amount
        $order->subtotal += $cost->subtotal;
        $order->total_amount += $cost->subtotal;
        $order->save();

        if ($order->technician_id) {
            Notification::send($order->technician_id, [
                'type' => Notification::TYPE_ORDER_UPDATE,
                'title' => 'Biaya Tambahan Disetujui',
                'message' => "Pelanggan menyetujui biaya tambahan: {$cost->item_name} (Rp ".number_format($cost->subtotal, 0, ',', '.').').',
                'data' => [
                    'order_id' => $order->id,
                    'additional_cost_id' => $cost->id,
                ],
            ]);
        }

        ActivityLog::logEvent(
            eventName: 'order.additional_cost_approved',
            description: "Pelanggan menyetujui biaya tambahan: {$cost->item_name} (Rp ".number_format($cost->subtotal, 0, ',', '.').") pada pesanan {$order->order_number}",
            entity: $cost,
            newValues: ['status' => AdditionalCost::STATUS_APPROVED],
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Biaya tambahan disetujui. Total tagihan pesanan telah diperbarui.',
            'data' => [
                'additional_cost' => $cost->fresh(),
                'order' => $order->fresh(),
            ],
        ]);
    }

    /**
     * Customer rejects an additional cost proposal.
     */
    public function reject(Request $request, int $orderId, int $costId): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($orderId);

        if ($user->isCustomer() && $order->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        if ($user->isTechnician()) {
            return response()->json(['success' => false, 'message' => 'Hanya pelanggan atau admin yang dapat menolak biaya tambahan.'], 403);
        }

        $cost = $order->additionalCosts()->findOrFail($costId);

        if ($cost->status !== AdditionalCost::STATUS_PENDING) {
            return response()->json([
                'success' => false,
                'message' => 'Biaya tambahan ini sudah diproses sebelumnya.',
            ], 422);
        }

        $cost->update(['status' => AdditionalCost::STATUS_REJECTED]);

        if ($order->technician_id) {
            Notification::send($order->technician_id, [
                'type' => Notification::TYPE_ORDER_UPDATE,
                'title' => 'Biaya Tambahan Ditolak',
                'message' => "Pelanggan menolak pengajuan biaya tambahan: {$cost->item_name}.",
                'data' => [
                    'order_id' => $order->id,
                    'additional_cost_id' => $cost->id,
                ],
            ]);
        }

        ActivityLog::logEvent(
            eventName: 'order.additional_cost_rejected',
            description: "Pelanggan menolak biaya tambahan: {$cost->item_name} pada pesanan {$order->order_number}",
            entity: $cost,
            newValues: ['status' => AdditionalCost::STATUS_REJECTED],
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Biaya tambahan ditolak.',
            'data' => $cost->fresh(),
        ]);
    }

    /**
     * Helper to verify if user can view order additional costs.
     */
    private function canAccessOrder($user, Order $order): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        if ($user->isCustomer() && $order->customer_id === $user->id) {
            return true;
        }

        if ($user->isTechnician() && $order->technician_id === $user->id) {
            return true;
        }

        return false;
    }
}
