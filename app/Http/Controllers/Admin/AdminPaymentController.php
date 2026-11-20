<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Order;
use App\Models\Payment;
use App\Models\PayoutRequest;
use App\Models\PlatformSetting;
use App\Models\TechnicianProfile;
use App\Models\User;
use App\Models\WebhookEvent;
use App\Services\Payment\PaymentService;
use App\Services\Payment\WalletService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AdminPaymentController extends Controller
{
    public function __construct(
        protected PaymentService $paymentService,
        protected WalletService $walletService
    ) {}

    /**
     * Tampilan daftar pembayaran (Web Blade & JSON API).
     */
    public function index(Request $request)
    {
        $query = Payment::with(['order.customer', 'customer', 'verifier']);

        if ($request->filled('status')) {
            $query->where('payment_status', $request->query('status'));
        }

        if ($request->filled('method')) {
            $query->where('payment_method', $request->query('method'));
        }

        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('payment_number', 'like', "%{$search}%")
                    ->orWhereHas('customer', fn ($c) => $c->where('name', 'like', "%{$search}%"))
                    ->orWhereHas('order', fn ($o) => $o->where('order_number', 'like', "%{$search}%"));
            });
        }

        $payments = $query->latest()->paginate(20)->withQueryString();

        if ($request->wantsJson()) {
            return response()->json([
                'success' => true,
                'data' => $payments,
            ]);
        }

        $stats = [
            'total_users' => User::where('role', 'customer')->count(),
            'total_technicians' => TechnicianProfile::count(),
            'today_orders' => Order::whereDate('created_at', today())->count(),
            'completed_orders' => Order::where('status', 'completed')->count(),
        ];

        return view('admin.payments', compact('stats', 'payments'));
    }

    /**
     * Dapatkan Signed URL 30 Menit untuk Melihat Bukti Transfer Privat.
     */
    public function getProofSignedUrl(int $id): JsonResponse
    {
        $payment = Payment::findOrFail($id);

        if (! $payment->proof_url) {
            return response()->json(['success' => false, 'message' => 'Bukti transfer belum diunggah.'], 404);
        }

        $signedUrl = URL::temporarySignedRoute(
            'admin.payments.view_proof_signed',
            now()->addMinutes(30),
            ['id' => $payment->id]
        );

        return response()->json([
            'success' => true,
            'data' => [
                'signed_url' => $signedUrl,
                'expires_at' => now()->addMinutes(30)->toIso8601String(),
            ],
        ]);
    }

    /**
     * Stream file bukti transfer privat menggunakan Signed URL atau sesi admin aktif.
     */
    public function viewProof(Request $request, int $id)
    {
        $payment = Payment::findOrFail($id);

        if (! $payment->proof_url) {
            abort(404, 'Bukti transfer tidak ditemukan.');
        }

        if (! Storage::disk('local')->exists($payment->proof_url)) {
            abort(404, 'File bukti transfer fisik tidak ditemukan di disk server.');
        }

        return response()->file(Storage::disk('local')->path($payment->proof_url));
    }

    /**
     * Verifikasi Transfer Manual (Approve / Reject).
     */
    public function verifyTransfer(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();

        $validated = $request->validate([
            'approved' => ['required', 'boolean'],
            'rejection_reason' => ['nullable', 'string', 'max:255'],
        ]);

        $payment = Payment::findOrFail($id);

        try {
            $updated = $this->paymentService->verifyManualTransfer(
                payment: $payment,
                admin: $admin,
                isApproved: (bool) $validated['approved'],
                rejectionReason: $validated['rejection_reason'] ?? null
            );

            return response()->json([
                'success' => true,
                'message' => $validated['approved'] ? 'Transfer manual disetujui.' : 'Transfer manual ditolak.',
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
     * Verifikasi Pembayaran Tunai / Cash (Approve / Reject) oleh Admin.
     */
    public function verifyCash(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();

        $validated = $request->validate([
            'approved' => ['required', 'boolean'],
            'notes' => ['nullable', 'string', 'max:255'],
        ]);

        $payment = Payment::findOrFail($id);

        try {
            $updated = $this->paymentService->verifyCashPaymentByAdmin(
                payment: $payment,
                admin: $admin,
                isApproved: (bool) $validated['approved'],
                notes: $validated['notes'] ?? null
            );

            return response()->json([
                'success' => true,
                'message' => $validated['approved'] ? 'Pembayaran tunai berhasil disetujui.' : 'Pembayaran tunai ditolak.',
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
     * Refund Pembayaran (Hanya Admin).
     */
    public function refund(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();

        $validated = $request->validate([
            'reason' => ['required', 'string', 'max:255'],
        ]);

        $payment = Payment::findOrFail($id);

        try {
            $refunded = $this->paymentService->refund(
                payment: $payment,
                admin: $admin,
                reason: $validated['reason']
            );

            return response()->json([
                'success' => true,
                'message' => 'Pembayaran berhasil di-refund.',
                'data' => $refunded,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Daftar Transaksi Webhook Terlambat yang Memerlukan Refund Manual.
     */
    public function flaggedRefunds(): JsonResponse
    {
        $flagged = WebhookEvent::with(['order.customer', 'payment'])
            ->where('flagged_for_manual_refund', true)
            ->latest('created_at')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $flagged,
        ]);
    }

    /**
     * Ekspor Data Pembayaran ke CSV.
     */
    public function exportCsv(Request $request): StreamedResponse
    {
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="payments-'.date('Y-m-d').'.csv"',
        ];

        return response()->stream(function () {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, [
                'No. Transaksi',
                'No. Pesanan',
                'Pelanggan',
                'Metode',
                'Jumlah (Rp)',
                'Status',
                'Waktu Bayar',
                'Dibuat Pada',
            ]);

            Payment::with(['order', 'customer'])
                ->chunk(100, function ($payments) use ($handle) {
                    foreach ($payments as $p) {
                        fputcsv($handle, [
                            $p->payment_number,
                            $p->order?->order_number ?? '-',
                            $p->customer?->name ?? '-',
                            strtoupper($p->payment_method),
                            $p->amount,
                            $p->payment_status,
                            $p->paid_at?->toDateTimeString() ?? '-',
                            $p->created_at->toDateTimeString(),
                        ]);
                    }
                });

            fclose($handle);
        }, 200, $headers);
    }

    /**
     * Admin menyetujui penarikan saldo teknisi (Payout).
     * Wajib melampirkan bukti transfer.
     */
    public function approvePayout(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();

        $request->validate([
            'proof' => ['required', 'file', 'mimes:jpeg,png,jpg,webp,pdf', 'max:2048'],
            'admin_notes' => ['nullable', 'string', 'max:255'],
        ]);

        $payout = PayoutRequest::findOrFail($id);

        try {
            $path = $request->file('proof')->store('payout_proofs', 'local');

            $approved = $this->walletService->approvePayout(
                payout: $payout,
                admin: $admin,
                transferProofUrl: $path,
                adminNotes: $request->input('admin_notes')
            );

            return response()->json([
                'success' => true,
                'message' => 'Penarikan dana berhasil disetujui.',
                'data' => $approved,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Admin menolak penarikan saldo teknisi (Payout).
     * Saldo dikembalikan ke dompet teknisi.
     */
    public function rejectPayout(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();

        $validated = $request->validate([
            'reason' => ['required', 'string', 'max:255'],
        ]);

        $payout = PayoutRequest::findOrFail($id);

        try {
            $rejected = $this->walletService->rejectPayout(
                payout: $payout,
                admin: $admin,
                reason: $validated['reason']
            );

            return response()->json([
                'success' => true,
                'message' => 'Penarikan dana ditolak dan saldo telah dikembalikan ke dompet teknisi.',
                'data' => $rejected,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Kelola Pengaturan Platform Finansial.
     */
    public function updateSetting(Request $request): JsonResponse
    {
        $admin = $request->user();

        $validated = $request->validate([
            'key' => ['required', 'string', 'max:50', 'exists:platform_settings,key'],
            'value' => ['required', 'string'],
        ]);

        $oldValue = PlatformSetting::get($validated['key']);
        PlatformSetting::set($validated['key'], $validated['value'], $admin->id);

        ActivityLog::logEvent(
            eventName: 'platform_setting.updated',
            description: "Admin mengubah pengaturan {$validated['key']} dari '{$oldValue}' menjadi '{$validated['value']}'",
            oldValues: ['value' => $oldValue],
            newValues: ['value' => $validated['value']],
            actor: $admin
        );

        return response()->json([
            'success' => true,
            'message' => "Pengaturan {$validated['key']} berhasil diperbarui.",
            'data' => [
                'key' => $validated['key'],
                'value' => $validated['value'],
            ],
        ]);
    }
}
