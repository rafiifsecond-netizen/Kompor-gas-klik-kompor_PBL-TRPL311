<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Payment;
use App\Services\Payment\MidtransService;
use App\Services\Payment\PaymentService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class PaymentController extends Controller
{
    public function __construct(
        protected PaymentService $paymentService,
        protected MidtransService $midtransService
    ) {}

    /**
     * Checkout Pembayaran (QRIS, Transfer Manual, Cash).
     * Menerima header opsional: Idempotency-Key.
     */
    public function checkout(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'order_id' => ['required', 'exists:orders,id'],
            'payment_method' => ['required', 'string', 'in:qris,transfer,cash'],
            'promo_code' => ['nullable', 'string', 'max:30'],
            'sender_bank_name' => ['nullable', 'string', 'max:50'],
            'sender_account_name' => ['nullable', 'string', 'max:150'],
        ]);

        $order = Order::findOrFail($validated['order_id']);

        // Otorisasi: Hanya customer yang dapat membuat checkout untuk pesanannya sendiri
        if (! $user->isCustomer()) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya pelanggan yang dapat melakukan pembayaran pesanan.',
            ], 403);
        }

        if ($order->customer_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Anda bukan pemilik pesanan ini.',
            ], 403);
        }

        $idempotencyKey = $request->header('Idempotency-Key') ?? $request->input('idempotency_key');

        try {
            $payment = $this->paymentService->checkout(
                order: $order,
                paymentMethod: $validated['payment_method'],
                promoCode: $validated['promo_code'] ?? null,
                idempotencyKey: $idempotencyKey,
                senderBankName: $validated['sender_bank_name'] ?? null,
                senderAccountName: $validated['sender_account_name'] ?? null
            );

            return response()->json([
                'success' => true,
                'message' => 'Instruksi pembayaran berhasil dibuat.',
                'data' => [
                    'payment' => $payment->load(['order.customer']),
                    'qris' => $payment->payment_method === 'qris' ? [
                        'qr_string' => $payment->qris_qr_string,
                        'qr_url' => $payment->qris_qr_url,
                        'expires_at' => $payment->expires_at?->toIso8601String(),
                    ] : null,
                    'va' => $payment->payment_method === 'transfer' ? [
                        'bank' => strtoupper($payment->bank_name ?? 'BCA'),
                        'va_number' => $payment->va_number,
                        'biller_code' => $payment->biller_code,
                        'bill_key' => $payment->bill_key,
                        'expires_at' => $payment->expires_at?->toIso8601String(),
                    ] : null,
                ],
            ], 201);
        } catch (ValidationException $ve) {
            return response()->json([
                'success' => false,
                'message' => $ve->getMessage(),
                'errors' => $ve->errors(),
            ], 422);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Polling Status Pembayaran.
     */
    public function status(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $payment = Payment::with(['order'])->findOrFail($id);

        if ($user->isCustomer() && $payment->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        // Sinkronisasi status ke Midtrans Core API jika transaksi gateway pending
        if (in_array($payment->payment_method, ['qris', 'transfer'], true) && $payment->payment_status === Payment::STATUS_PENDING && $payment->gateway_order_id) {
            if ($payment->expires_at && now()->gt($payment->expires_at)) {
                $payment->update(['payment_status' => Payment::STATUS_EXPIRED]);
            } else {
                $statusData = $this->midtransService->checkStatus($payment->gateway_order_id);
                $gwStatus = $statusData['transaction_status'] ?? null;
                if ($gwStatus === 'settlement' || $gwStatus === 'capture') {
                    $this->paymentService->handleWebhook($statusData);
                    $payment->refresh();
                } elseif (in_array($gwStatus, ['expire', 'cancel', 'deny'], true)) {
                    $payment->update(['payment_status' => ($gwStatus === 'expire') ? Payment::STATUS_EXPIRED : Payment::STATUS_FAILED]);
                }
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'payment_id' => $payment->id,
                'payment_number' => $payment->payment_number,
                'payment_status' => $payment->payment_status,
                'payment_method' => $payment->payment_method,
                'amount' => $payment->amount,
                'va_number' => $payment->va_number,
                'bank_name' => $payment->bank_name,
                'expires_at' => $payment->expires_at?->toIso8601String(),
                'paid_at' => $payment->paid_at?->toIso8601String(),
                'is_expired' => $payment->expires_at ? now()->gt($payment->expires_at) : false,
            ],
        ]);
    }

    /**
     * Upload Bukti Transfer Manual.
     * Validasi: MIME (jpeg, png, webp), max 2048 KB.
     */
    public function uploadProof(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $payment = Payment::findOrFail($id);

        if ($user->isCustomer() && $payment->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $request->validate([
            'proof' => ['required', 'file', 'mimes:jpeg,png,jpg,webp', 'max:2048'],
            'sender_bank_name' => ['nullable', 'string', 'max:50'],
            'sender_account_name' => ['nullable', 'string', 'max:150'],
        ]);

        try {
            $updated = $this->paymentService->uploadTransferProof(
                payment: $payment,
                file: $request->file('proof'),
                senderBankName: $request->input('sender_bank_name'),
                senderAccountName: $request->input('sender_account_name')
            );

            return response()->json([
                'success' => true,
                'message' => 'Bukti transfer berhasil diunggah. Menunggu verifikasi admin.',
                'data' => $updated,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Konfirmasi Penerimaan Pembayaran Tunai (Hanya Teknisi).
     */
    public function confirmCash(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        if (! $user->isTechnician()) {
            return response()->json(['success' => false, 'message' => 'Hanya teknisi yang dapat mengonfirmasi uang tunai.'], 403);
        }

        $request->validate([
            'amount_received' => ['required', 'integer', 'min:1'],
        ]);

        $payment = Payment::findOrFail($id);

        try {
            $updated = $this->paymentService->confirmCashPayment(
                payment: $payment,
                technician: $user,
                amountReceived: (int) $request->input('amount_received')
            );

            return response()->json([
                'success' => true,
                'message' => 'Pembayaran tunai berhasil dikonfirmasi.',
                'data' => $updated,
            ]);
        } catch (ValidationException $ve) {
            return response()->json([
                'success' => false,
                'message' => $ve->getMessage(),
                'errors' => $ve->errors(),
            ], 422);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Retry Pembayaran: Membuat pembayaran baru dengan membatalkan attempt lama.
     */
    public function retry(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $oldPayment = Payment::findOrFail($id);

        if ($user->isCustomer() && $oldPayment->customer_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $validated = $request->validate([
            'payment_method' => ['required', 'string', 'in:qris,transfer,cash'],
            'promo_code' => ['nullable', 'string', 'max:30'],
        ]);

        $order = Order::findOrFail($oldPayment->order_id);

        try {
            $newPayment = $this->paymentService->checkout(
                order: $order,
                paymentMethod: $validated['payment_method'],
                promoCode: $validated['promo_code'] ?? null
            );

            return response()->json([
                'success' => true,
                'message' => 'Percobaan pembayaran baru berhasil dibuat.',
                'data' => $newPayment,
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Endpoint Publik Webhook Midtrans (Tanpa Token Auth, diverifikasi via Signature SHA-512).
     */
    public function webhook(Request $request): JsonResponse
    {
        $payload = $request->all();

        $result = $this->paymentService->handleWebhook($payload);

        $code = $result['code'] ?? ($result['success'] ? 200 : 400);

        return response()->json($result, $code);
    }
}
