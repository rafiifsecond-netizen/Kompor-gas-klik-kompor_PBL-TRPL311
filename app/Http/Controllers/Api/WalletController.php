<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PlatformSetting;
use App\Services\Payment\WalletService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class WalletController extends Controller
{
    public function __construct(
        protected WalletService $walletService
    ) {}

    /**
     * Dapatkan ringkasan saldo dompet teknisi, status penahanan escrow, dan limit utang cash.
     */
    public function getWallet(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user->isTechnician()) {
            return response()->json(['success' => false, 'message' => 'Hanya teknisi yang memiliki akses ke dompet ini.'], 403);
        }

        $wallet = $this->walletService->getOrCreateWallet($user);
        $minPayout = (int) PlatformSetting::get('min_payout_amount', 50000);
        $maxCashDebt = (int) PlatformSetting::get('max_cash_debt_limit', 200000);

        return response()->json([
            'success' => true,
            'data' => [
                'wallet_id' => $wallet->id,
                'balance' => (int) $wallet->balance,
                'pending_balance' => (int) $wallet->pending_balance,
                'is_suspended_from_orders' => (bool) $user->is_suspended_from_orders,
                'bank_details' => [
                    'bank_name' => $wallet->bank_name,
                    'bank_account_number' => $wallet->bank_account_number,
                    'bank_account_holder' => $wallet->bank_account_holder,
                ],
                'rules' => [
                    'min_payout_amount' => $minPayout,
                    'max_cash_debt_limit' => $maxCashDebt,
                ],
            ],
        ]);
    }

    /**
     * Teknisi mengajukan penarikan saldo (Payout).
     */
    public function requestPayout(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user->isTechnician()) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $validated = $request->validate([
            'amount' => ['required', 'integer', 'min:1'],
            'bank_name' => ['required', 'string', 'max:50'],
            'bank_account_number' => ['required', 'string', 'max:50'],
            'bank_account_holder' => ['required', 'string', 'max:150'],
        ]);

        try {
            $payout = $this->walletService->requestPayout(
                technician: $user,
                amount: (int) $validated['amount'],
                bankDetails: [
                    'bank_name' => $validated['bank_name'],
                    'bank_account_number' => $validated['bank_account_number'],
                    'bank_account_holder' => $validated['bank_account_holder'],
                ]
            );

            return response()->json([
                'success' => true,
                'message' => 'Pengajuan penarikan dana berhasil dibuat dan sedang menunggu verifikasi admin.',
                'data' => $payout,
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
     * Riwayat mutasi dompet teknisi.
     */
    public function getTransactions(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user->isTechnician()) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak.'], 403);
        }

        $wallet = $this->walletService->getOrCreateWallet($user);

        $transactions = $wallet->transactions()
            ->latest('created_at')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $transactions,
        ]);
    }
}
