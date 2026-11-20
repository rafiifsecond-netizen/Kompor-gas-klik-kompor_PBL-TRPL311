<?php

namespace App\Services\Payment;

use InvalidArgumentException;
use LogicException;

class FinancialCalculator
{
    /**
     * Hitung diskon promo dari subtotal jasa (S).
     * Aturan:
     * - Promo persen dihitung dari S: floor((S * percent) / 100)
     * - D = min(hasil_promo, max_discount, S)
     * - Diskon tidak boleh melebihi S dan tidak boleh negatif.
     */
    public static function calculateDiscount(
        int $serviceSubtotal,
        string $promoType,
        int $promoValue,
        ?int $maxDiscount = null
    ): int {
        if ($serviceSubtotal <= 0 || $promoValue <= 0) {
            return 0;
        }

        if ($promoType === 'percentage') {
            // Persentase promo maksimal 100%
            $percent = min(100, $promoValue);
            // Floor integer arithmetic via bcmul/bcdiv
            $rawDiscount = (int) bcdiv(
                bcmul((string) $serviceSubtotal, (string) $percent, 0),
                '100',
                0
            );
        } else {
            // Fixed discount
            $rawDiscount = $promoValue;
        }

        if ($maxDiscount !== null && $maxDiscount > 0) {
            $rawDiscount = min($rawDiscount, $maxDiscount);
        }

        // Capped pada subtotal jasa (S): D <= S
        $finalDiscount = min($rawDiscount, $serviceSubtotal);

        return max(0, $finalDiscount);
    }

    /**
     * Hitung komisi platform dari subtotal jasa setelah diskon (S - D).
     * Aturan:
     * - Basis perhitungan: S - D
     * - Mode pembulatan: round (half-up), floor, ceil
     * - Satuan pembulatan: unit 1 rupiah atau 100 rupiah
     * - Menggunakan bcmath/integer murni tanpa float.
     */
    public static function calculateCommission(
        int $discountedSubtotal,
        string|int $commissionPercent = '5.00',
        string $roundingMode = 'round',
        int $roundingUnit = 1
    ): int {
        if ($discountedSubtotal <= 0) {
            return 0;
        }

        $percentStr = (string) $commissionPercent;
        if (bccomp($percentStr, '0', 4) <= 0) {
            return 0;
        }

        $unit = max(1, $roundingUnit);

        // Komisi eksak sebelum pembulatan = (S - D) * (percent / 100)
        // Hitung skala ke unit pembulatan: raw / unit
        $exactVal = bcdiv(
            bcmul((string) $discountedSubtotal, $percentStr, 6),
            '100',
            6
        );

        // Nilai dalam satuan unit: e.g. 3750 / 100 = 37.500000
        $unitScaled = bcdiv($exactVal, (string) $unit, 6);

        // Pisahkan bagian integer dan pecahan (presisi 6 desimal)
        $parts = explode('.', $unitScaled);
        $intPart = (int) $parts[0];
        $fractionStr = $parts[1] ?? '0';
        $hasFraction = (int) $fractionStr > 0;
        // Cek apakah pecahan >= 0.5 (setengah dari skala 1.000000 adalah 500000)
        $isHalfOrMore = ((int) str_pad(substr($fractionStr, 0, 6), 6, '0')) >= 500000;

        switch (strtolower($roundingMode)) {
            case 'ceil':
                $unitsRounded = $hasFraction ? ($intPart + 1) : $intPart;
                break;
            case 'floor':
                $unitsRounded = $intPart;
                break;
            case 'round':
            default:
                // Half-up: >= 0.5 naik
                $unitsRounded = $isHalfOrMore ? ($intPart + 1) : $intPart;
                break;
        }

        $result = $unitsRounded * $unit;

        // Komisi tidak boleh melebihi basisnya (S - D)
        return min($result, $discountedSubtotal);
    }

    /**
     * Hitung struktur finansial lengkap dan verifikasi invarian matematis.
     *
     * Rumus:
     * S = Subtotal jasa (service subtotal)
     * T = Biaya transport (100% hak teknisi)
     * D = Diskon promo (ditanggung platform)
     * P = (S - D) + T (Tagihan ke customer)
     * C = round_policy(r * (S - D)) (Komisi platform)
     * N = S + T - C (Hak bersih teknisi)
     * delta = C - D (Selisih komisi vs subsidi diskon)
     *
     * Invarian Wajib:
     * 1. N + C === S + T
     * 2. P - N === C - D
     */
    public static function calculate(
        int $serviceSubtotal,
        int $transportFee,
        int $discountAmount = 0,
        string|int $commissionPercent = '5.00',
        string $roundingMode = 'round',
        int $roundingUnit = 1
    ): FinancialCalculationResult {
        $S = max(0, $serviceSubtotal);
        $T = max(0, $transportFee);
        $D = min(max(0, $discountAmount), $S); // Diskon tidak boleh > S

        $discountedSubtotal = $S - $D;
        $P = $discountedSubtotal + $T;

        $percentStr = bcadd((string) $commissionPercent, '0', 2);
        $C = self::calculateCommission($discountedSubtotal, $percentStr, $roundingMode, $roundingUnit);

        // Hak teknisi: N = S + T - C
        $N = $S + $T - $C;

        // Delta settlement: delta = C - D
        $delta = $C - $D;

        if ($delta > 0) {
            $settlementDirection = 'technician_pays_platform';
            $settlementAmount = $delta;
        } elseif ($delta < 0) {
            $settlementDirection = 'platform_pays_technician';
            $settlementAmount = -$delta;
        } else {
            $settlementDirection = 'none';
            $settlementAmount = 0;
        }

        // Verifikasi Invarian 1: N + C === S + T
        if (($N + $C) !== ($S + $T)) {
            throw new LogicException(
                "Invariant 1 violated: N + C (" . ($N + $C) . ") !== S + T (" . ($S + $T) . ")"
            );
        }

        // Verifikasi Invarian 2: P - N === C - D
        if (($P - $N) !== ($C - $D)) {
            throw new LogicException(
                "Invariant 2 violated: P - N (" . ($P - $N) . ") !== C - D (" . ($C - $D) . ")"
            );
        }

        return new FinancialCalculationResult(
            serviceSubtotal: $S,
            transportFee: $T,
            discountAmount: $D,
            discountedSubtotal: $discountedSubtotal,
            paymentAmount: $P,
            commissionPercentage: $percentStr,
            commissionAmount: $C,
            technicianNetIncome: $N,
            delta: $delta,
            settlementDirection: $settlementDirection,
            settlementAmount: $settlementAmount,
            platformSubsidy: $D,
            roundingMode: $roundingMode,
            roundingUnit: $roundingUnit
        );
    }
}
