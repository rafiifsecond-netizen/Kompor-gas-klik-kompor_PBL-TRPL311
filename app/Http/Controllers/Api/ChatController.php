<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Chat;
use App\Models\Notification;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ChatController extends Controller
{
    /**
     * Retrieve chat room details and message history for an order.
     */
    public function show(Request $request, int $orderId): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($orderId);

        if (! $this->canAccessChat($user, $order)) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        if (! $order->technician_id) {
            return response()->json([
                'success' => false,
                'message' => 'Ruang chat belum tersedia karena pesanan belum memiliki teknisi.',
            ], 422);
        }

        $chat = Chat::firstOrCreate(
            ['order_id' => $order->id],
            [
                'customer_id' => $order->customer_id,
                'technician_id' => $order->technician_id,
            ]
        );

        // Mark incoming unread messages as read
        $chat->messages()
            ->where('sender_id', '!=', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        $chat->load([
            'customer:id,name,avatar_url',
            'technician:id,name,avatar_url',
            'messages.sender:id,name,avatar_url,role',
        ]);

        return response()->json([
            'success' => true,
            'data' => $chat,
        ]);
    }

    /**
     * Send a new message inside the order chat room.
     */
    public function sendMessage(Request $request, int $orderId): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($orderId);

        if (! $this->canAccessChat($user, $order)) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        if (! $order->technician_id) {
            return response()->json([
                'success' => false,
                'message' => 'Ruang chat belum tersedia karena pesanan belum memiliki teknisi.',
            ], 422);
        }

        $validated = $request->validate([
            'message' => ['nullable', 'string', 'max:2000'],
            'message_type' => ['sometimes', 'string', 'in:text,image,system'],
            'attachment_url' => ['nullable', 'string'],
        ]);

        if (empty($validated['message']) && empty($validated['attachment_url'])) {
            return response()->json([
                'success' => false,
                'message' => 'Pesan teks atau tautan lampiran wajib diisi.',
            ], 422);
        }

        $chat = Chat::firstOrCreate(
            ['order_id' => $order->id],
            [
                'customer_id' => $order->customer_id,
                'technician_id' => $order->technician_id,
            ]
        );

        $message = $chat->messages()->create([
            'sender_id' => $user->id,
            'message' => $validated['message'] ?? null,
            'message_type' => $validated['message_type'] ?? 'text',
            'attachment_url' => $validated['attachment_url'] ?? null,
        ]);

        // Send push/in-app notification to the recipient
        $recipientId = $user->id === $order->customer_id ? $order->technician_id : $order->customer_id;
        if ($recipientId) {
            Notification::send($recipientId, [
                'type' => Notification::TYPE_CHAT,
                'title' => "Pesan dari {$user->name}",
                'message' => Str::limit($validated['message'] ?? '[Lampiran Gambar]', 80),
                'data' => [
                    'order_id' => $order->id,
                    'chat_id' => $chat->id,
                    'message_id' => $message->id,
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Pesan berhasil dikirim.',
            'data' => $message->load('sender:id,name,avatar_url,role'),
        ], 201);
    }

    /**
     * Mark unread messages in chat room as read.
     */
    public function markAsRead(Request $request, int $orderId): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($orderId);

        if (! $this->canAccessChat($user, $order)) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $chat = Chat::where('order_id', $order->id)->first();
        if ($chat) {
            $chat->messages()
                ->where('sender_id', '!=', $user->id)
                ->whereNull('read_at')
                ->update(['read_at' => now()]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Pesan telah ditandai sebagai sudah dibaca.',
        ]);
    }

    /**
     * Helper to verify if user can participate in the chat.
     */
    private function canAccessChat($user, Order $order): bool
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
