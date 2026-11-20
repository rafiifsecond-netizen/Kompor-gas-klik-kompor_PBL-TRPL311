<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Order;
use App\Models\Promo;
use App\Services\Payment\PromoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class PromoController extends Controller
{
    public function __construct(
        protected PromoService $promoService
    ) {}

    /**
     * Pelanggan mengecek validitas dan estimasi potongan promo untuk pesanannya.
     */
    public function validateCode(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'order_id' => ['required', 'exists:orders,id'],
            'promo_code' => ['required', 'string', 'max:30'],
            'payment_method' => ['required', 'string', 'in:qris,cash'],
        ]);

        $order = Order::findOrFail($validated['order_id']);

        if ($request->user()->id !== $order->customer_id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Anda bukan pemilik pesanan ini.',
            ], 403);
        }

        try {
            $result = $this->promoService->validateAndCalculate(
                order: $order,
                code: $validated['promo_code'],
                paymentMethod: $validated['payment_method']
            );

            $promo = $result['promo'];
            $discount = $result['discount_amount'];

            return response()->json([
                'success' => true,
                'data' => [
                    'code' => $promo->code,
                    'name' => $promo->name,
                    'discount_amount' => $discount,
                    'type' => $promo->type,
                    'original_subtotal' => (int) $order->subtotal,
                    'discounted_subtotal' => max(0, (int) $order->subtotal - $discount),
                ],
            ]);
        } catch (ValidationException $ve) {
            return response()->json([
                'success' => false,
                'message' => $ve->getMessage(),
                'errors' => $ve->errors(),
            ], 422);
        }
    }

    /**
     * Daftar promo yang sedang aktif dan dapat digunakan pelanggan.
     */
    public function index(Request $request): JsonResponse
    {
        $now = now();
        $promos = Promo::where('is_active', true)
            ->where('start_date', '<=', $now)
            ->where('end_date', '>=', $now)
            ->get()
            ->filter(fn (Promo $p) => $p->remainingQuota() > 0)
            ->values();

        return response()->json([
            'success' => true,
            'data' => $promos,
        ]);
    }

    /**
     * Admin: List semua promo (aktif & nonaktif) dengan hitungan sisa kuota dinamis.
     */
    public function adminIndex(): JsonResponse
    {
        $promos = Promo::withCount(['usages as active_usages_count' => function ($q) {
            $q->whereIn('status', ['reserved', 'used']);
        }])->latest()->get();

        return response()->json([
            'success' => true,
            'data' => $promos,
        ]);
    }

    /**
     * Admin: Buat promo baru.
     */
    public function adminStore(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'code' => ['required', 'string', 'max:30', 'unique:promos,code'],
            'name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'type' => ['required', 'string', 'in:percentage,fixed'],
            'discount_amount' => [
                'required',
                'integer',
                'min:1',
                function ($attribute, $value, $fail) use ($request) {
                    if ($request->input('type') === 'percentage' && $value > 100) {
                        $fail('Diskon persentase tidak boleh melebihi 100%.');
                    }
                },
            ],
            'max_discount' => ['nullable', 'integer', 'min:0'],
            'min_order_amount' => ['nullable', 'integer', 'min:0'],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after_or_equal:start_date'],
            'total_quota' => ['required', 'integer', 'min:1'],
            'quota_per_user' => ['required', 'integer', 'min:1'],
            'applicable_payment_methods' => ['nullable', 'array'],
            'applicable_payment_methods.*' => ['string', 'in:qris,cash'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $validated['code'] = strtoupper(trim($validated['code']));
        $validated['is_active'] = $validated['is_active'] ?? true;
        $validated['min_order_amount'] = $validated['min_order_amount'] ?? 0;

        $promo = Promo::create($validated);

        ActivityLog::logEvent(
            eventName: 'promo.created',
            description: "Admin membuat promo baru: {$promo->code}",
            entity: $promo,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Promo berhasil ditambahkan.',
            'data' => $promo,
        ], 201);
    }

    /**
     * Admin: Ubah data promo.
     */
    public function adminUpdate(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $promo = Promo::findOrFail($id);

        $validated = $request->validate([
            'code' => ['required', 'string', 'max:30', Rule::unique('promos', 'code')->ignore($promo->id)],
            'name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'type' => ['required', 'string', 'in:percentage,fixed'],
            'discount_amount' => [
                'required',
                'integer',
                'min:1',
                function ($attribute, $value, $fail) use ($request) {
                    if ($request->input('type') === 'percentage' && $value > 100) {
                        $fail('Diskon persentase tidak boleh melebihi 100%.');
                    }
                },
            ],
            'max_discount' => ['nullable', 'integer', 'min:0'],
            'min_order_amount' => ['nullable', 'integer', 'min:0'],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after_or_equal:start_date'],
            'total_quota' => ['required', 'integer', 'min:1'],
            'quota_per_user' => ['required', 'integer', 'min:1'],
            'applicable_payment_methods' => ['nullable', 'array'],
            'applicable_payment_methods.*' => ['string', 'in:qris,cash'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $validated['code'] = strtoupper(trim($validated['code']));

        $old = $promo->toArray();
        $promo->update($validated);

        ActivityLog::logEvent(
            eventName: 'promo.updated',
            description: "Admin memperbarui promo: {$promo->code}",
            entity: $promo,
            oldValues: $old,
            newValues: $promo->toArray(),
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Promo berhasil diperbarui.',
            'data' => $promo,
        ]);
    }

    /**
     * Admin: Hapus promo (hanya jika belum pernah dipakai).
     */
    public function adminDestroy(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $promo = Promo::findOrFail($id);

        if ($promo->usages()->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Promo tidak dapat dihapus karena sudah memiliki riwayat pemakaian. Anda dapat menonaktifkannya.',
            ], 422);
        }

        $code = $promo->code;
        $promo->delete();

        ActivityLog::logEvent(
            eventName: 'promo.deleted',
            description: "Admin menghapus promo: {$code}",
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Promo berhasil dihapus.',
        ]);
    }
}
