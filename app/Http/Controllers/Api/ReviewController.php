<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Notification;
use App\Models\Order;
use App\Models\Review;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    /**
     * Customer leaves a review for completed order (Fitur 11: Rating dan Ulasan).
     */
    public function store(Request $request, int $orderId): JsonResponse
    {
        $user = $request->user();
        $order = Order::findOrFail($orderId);

        if ($order->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Anda hanya dapat mengulas pesanan Anda sendiri.'], 403);
        }

        if ($order->status !== Order::STATUS_COMPLETED) {
            return response()->json(['success' => false, 'message' => 'Ulasan hanya dapat diberikan setelah servis selesai dikerjakan.'], 422);
        }

        if ($order->review()->exists()) {
            return response()->json(['success' => false, 'message' => 'Anda sudah memberikan ulasan untuk pesanan ini.'], 422);
        }

        if (! $order->technician_id) {
            return response()->json(['success' => false, 'message' => 'Pesanan ini tidak memiliki teknisi yang ditugaskan untuk diulas.'], 422);
        }

        $validated = $request->validate([
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string', 'max:1000'],
            'photos' => ['nullable', 'array'],
        ]);

        $review = Review::create([
            'order_id' => $order->id,
            'customer_id' => $user->id,
            'technician_id' => $order->technician_id,
            'rating' => $validated['rating'],
            'comment' => $validated['comment'] ?? null,
            'photos' => $validated['photos'] ?? null,
        ]);

        // Recalculate average rating & review count for technician
        $techUser = User::find($order->technician_id);
        if ($techUser && $techUser->technicianProfile) {
            $avg = Review::where('technician_id', $order->technician_id)->avg('rating');
            $count = Review::where('technician_id', $order->technician_id)->count();

            $techUser->technicianProfile->update([
                'rating_avg' => round((float) $avg, 2),
                'reviews_count' => $count,
            ]);
        }

        Notification::send($order->technician_id, [
            'type' => Notification::TYPE_ORDER_UPDATE,
            'title' => 'Ulasan Baru Diterima',
            'message' => "Pelanggan memberikan rating {$validated['rating']} bintang untuk pesanan #{$order->order_number}.",
            'data' => ['order_id' => $order->id, 'review_id' => $review->id],
        ]);

        ActivityLog::logEvent(
            eventName: 'review.submitted',
            description: "Pelanggan memberikan rating {$validated['rating']} bintang untuk teknisi",
            entity: $review,
            newValues: $review->toArray(),
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Terima kasih atas ulasan Anda.',
            'data' => $review,
        ], 201);
    }
}
