<?php

namespace App\Services\Payment;

use App\Models\Order;
use App\Models\Promo;
use App\Models\PromoUsage;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PromoService
{
    /**
     * Validasi promo dan hitung nominal diskon untuk pesanan tertentu.
     */
    public function validateAndCalculate(Order $order, string $code, string $paymentMethod): array
    {
        $code = strtoupper(trim($code));
        $promo = Promo::where('code', $code)->first();

        if (! $promo || ! $promo->is_active) {
            throw ValidationException::withMessages([
                'promo_code' => ['Kode promo tidak valid atau sudah tidak aktif.'],
            ]);
        }

        $now = now();
        if ($now->lt($promo->start_date) || $now->gt($promo->end_date)) {
            throw ValidationException::withMessages([
                'promo_code' => ['Kode promo telah kedaluwarsa atau belum dimulai.'],
            ]);
        }

        if (! empty($promo->applicable_payment_methods)) {
            if (! in_array($paymentMethod, $promo->applicable_payment_methods, true)) {
                $allowed = implode(', ', $promo->applicable_payment_methods);
                throw ValidationException::withMessages([
                    'promo_code' => ["Kode promo hanya berlaku untuk metode pembayaran: {$allowed}."],
                ]);
            }
        }

        $serviceSubtotal = (int) $order->subtotal;
        if ($serviceSubtotal < $promo->min_order_amount) {
            throw ValidationException::withMessages([
                'promo_code' => [
                    'Minimum subtotal jasa untuk promo ini adalah Rp '.number_format($promo->min_order_amount, 0, ',', '.').'.',
                ],
            ]);
        }

        // Cek kuota global secara dinamis dari tabel promo_usages
        $usedGlobal = PromoUsage::where('promo_id', $promo->id)
            ->whereIn('status', [PromoUsage::STATUS_RESERVED, PromoUsage::STATUS_USED])
            ->count();

        if ($usedGlobal >= $promo->total_quota) {
            throw ValidationException::withMessages([
                'promo_code' => ['Kuota promo ini sudah habis.'],
            ]);
        }

        // Cek kuota per user
        $usedByUser = PromoUsage::where('promo_id', $promo->id)
            ->where('user_id', $order->customer_id)
            ->whereIn('status', [PromoUsage::STATUS_RESERVED, PromoUsage::STATUS_USED])
            ->where('order_id', '!=', $order->id)
            ->count();

        if ($usedByUser >= $promo->quota_per_user) {
            throw ValidationException::withMessages([
                'promo_code' => ['Anda telah mencapai batas maksimum penggunaan promo ini.'],
            ]);
        }

        $discount = FinancialCalculator::calculateDiscount(
            serviceSubtotal: $serviceSubtotal,
            promoType: $promo->type,
            promoValue: $promo->discount_amount,
            maxDiscount: $promo->max_discount
        );

        return [
            'promo' => $promo,
            'discount_amount' => $discount,
        ];
    }

    /**
     * Reservasi kuota promo untuk pesanan dalam transaksi DB dengan lockForUpdate.
     * Mencegah race condition ketika banyak pengguna berebut sisa kuota terakhir.
     */
    public function reservePromo(Order $order, string $code, string $paymentMethod): PromoUsage
    {
        return DB::transaction(function () use ($order, $code) {
            $code = strtoupper(trim($code));

            // Lock baris promo
            $promo = Promo::where('code', $code)
                ->lockForUpdate()
                ->first();

            if (! $promo || ! $promo->is_active) {
                throw ValidationException::withMessages(['promo_code' => ['Kode promo tidak valid atau sudah tidak aktif.']]);
            }

            // Hitung sisa kuota di dalam lock
            $activeUsagesCount = PromoUsage::where('promo_id', $promo->id)
                ->whereIn('status', [PromoUsage::STATUS_RESERVED, PromoUsage::STATUS_USED])
                ->where('order_id', '!=', $order->id)
                ->lockForUpdate()
                ->count();

            if ($activeUsagesCount >= $promo->total_quota) {
                throw ValidationException::withMessages(['promo_code' => ['Kuota promo telah habis.']]);
            }

            $userUsagesCount = PromoUsage::where('promo_id', $promo->id)
                ->where('user_id', $order->customer_id)
                ->whereIn('status', [PromoUsage::STATUS_RESERVED, PromoUsage::STATUS_USED])
                ->where('order_id', '!=', $order->id)
                ->lockForUpdate()
                ->count();

            if ($userUsagesCount >= $promo->quota_per_user) {
                throw ValidationException::withMessages(['promo_code' => ['Batas penggunaan promo untuk akun Anda telah tercapai.']]);
            }

            $discount = FinancialCalculator::calculateDiscount(
                serviceSubtotal: (int) $order->subtotal,
                promoType: $promo->type,
                promoValue: $promo->discount_amount,
                maxDiscount: $promo->max_discount
            );

            // Jika pesanan ini sebelumnya sudah memiliki catatan promo (misal pernah reserve lalu released saat expire)
            $existing = PromoUsage::where('order_id', $order->id)->first();
            if ($existing) {
                $existing->update([
                    'promo_id' => $promo->id,
                    'user_id' => $order->customer_id,
                    'discount_applied' => $discount,
                    'status' => PromoUsage::STATUS_RESERVED,
                    'reserved_at' => now(),
                    'released_at' => null,
                    'used_at' => null,
                ]);

                return $existing;
            }

            return PromoUsage::create([
                'promo_id' => $promo->id,
                'user_id' => $order->customer_id,
                'order_id' => $order->id,
                'discount_applied' => $discount,
                'status' => PromoUsage::STATUS_RESERVED,
                'reserved_at' => now(),
            ]);
        });
    }

    /**
     * Tandai promo telah digunakan secara final (saat pembayaran settlement/lunas).
     * Idempoten: aman dipanggil berulang kali.
     */
    public function markUsed(Order $order): void
    {
        PromoUsage::where('order_id', $order->id)
            ->where('status', PromoUsage::STATUS_RESERVED)
            ->update([
                'status' => PromoUsage::STATUS_USED,
                'used_at' => now(),
            ]);
    }

    /**
     * Lepas reservasi promo (saat pembayaran expired, dicancel, atau refund).
     * Idempoten: aman dipanggil berulang kali.
     */
    public function releasePromo(Order $order): void
    {
        PromoUsage::where('order_id', $order->id)
            ->whereIn('status', [PromoUsage::STATUS_RESERVED, PromoUsage::STATUS_USED])
            ->update([
                'status' => PromoUsage::STATUS_RELEASED,
                'released_at' => now(),
            ]);
    }
}
