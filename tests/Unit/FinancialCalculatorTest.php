<?php

namespace Tests\Unit;

use App\Services\Payment\FinancialCalculator;
use PHPUnit\Framework\TestCase;

class FinancialCalculatorTest extends TestCase
{
    /**
     * Case 1: QRIS tanpa promo
     * S = 100.000, T = 20.000, D = 0, r = 5%
     * P = 120.000, C = 5.000, N = 115.000, Delta = +5.000
     */
    public function test_case_1_qris_without_promo(): void
    {
        $res = FinancialCalculator::calculate(
            serviceSubtotal: 100000,
            transportFee: 20000,
            discountAmount: 0,
            commissionPercent: '5.00',
            roundingMode: 'round',
            roundingUnit: 1
        );

        $this->assertSame(100000, $res->serviceSubtotal);
        $this->assertSame(20000, $res->transportFee);
        $this->assertSame(0, $res->discountAmount);
        $this->assertSame(100000, $res->discountedSubtotal);
        $this->assertSame(120000, $res->paymentAmount);
        $this->assertSame(5000, $res->commissionAmount);
        $this->assertSame(115000, $res->technicianNetIncome);
        $this->assertSame(5000, $res->delta);
        $this->assertSame('technician_pays_platform', $res->settlementDirection);
        $this->assertSame(5000, $res->settlementAmount);

        // Invarian
        $this->assertSame($res->serviceSubtotal + $res->transportFee, $res->technicianNetIncome + $res->commissionAmount);
        $this->assertSame($res->paymentAmount - $res->technicianNetIncome, $res->commissionAmount - $res->discountAmount);
    }

    /**
     * Case 2: Transfer promo 30rb
     * S = 150.000, T = 25.000, D = 30.000, r = 5%
     * S - D = 120.000, P = 145.000, C = 6.000, N = 169.000, Delta = -24.000
     */
    public function test_case_2_transfer_with_30k_promo(): void
    {
        $res = FinancialCalculator::calculate(
            serviceSubtotal: 150000,
            transportFee: 25000,
            discountAmount: 30000,
            commissionPercent: '5.00',
            roundingMode: 'round',
            roundingUnit: 1
        );

        $this->assertSame(150000, $res->serviceSubtotal);
        $this->assertSame(25000, $res->transportFee);
        $this->assertSame(30000, $res->discountAmount);
        $this->assertSame(120000, $res->discountedSubtotal);
        $this->assertSame(145000, $res->paymentAmount);
        $this->assertSame(6000, $res->commissionAmount);
        $this->assertSame(169000, $res->technicianNetIncome);
        $this->assertSame(-24000, $res->delta);
        $this->assertSame('platform_pays_technician', $res->settlementDirection);
        $this->assertSame(24000, $res->settlementAmount);

        // Invarian
        $this->assertSame($res->serviceSubtotal + $res->transportFee, $res->technicianNetIncome + $res->commissionAmount);
        $this->assertSame($res->paymentAmount - $res->technicianNetIncome, $res->commissionAmount - $res->discountAmount);
    }

    /**
     * Case 3: Cash promo 20rb (Platform bayar teknisi)
     * Customer bayar cash (S - D) + T ke teknisi.
     * Karena D > C, teknisi berhak menerima subsidi dari platform.
     */
    public function test_case_3_cash_with_20k_promo_platform_pays_technician(): void
    {
        $res = FinancialCalculator::calculate(
            serviceSubtotal: 100000,
            transportFee: 20000,
            discountAmount: 20000,
            commissionPercent: '5.00',
            roundingMode: 'round',
            roundingUnit: 1
        );

        $this->assertSame(80000, $res->discountedSubtotal);
        $this->assertSame(100000, $res->paymentAmount); // Customer bayar cash 100.000
        $this->assertSame(4000, $res->commissionAmount); // 5% dari 80.000 = 4.000
        $this->assertSame(116000, $res->technicianNetIncome); // 100k + 20k - 4k = 116.000
        $this->assertSame(-16000, $res->delta); // 4k - 20k = -16.000
        $this->assertSame('platform_pays_technician', $res->settlementDirection);
        $this->assertSame(16000, $res->settlementAmount);

        // Invarian
        $this->assertSame($res->serviceSubtotal + $res->transportFee, $res->technicianNetIncome + $res->commissionAmount);
        $this->assertSame($res->paymentAmount - $res->technicianNetIncome, $res->commissionAmount - $res->discountAmount);
    }

    /**
     * Case 4: Cash tanpa promo (Teknisi bayar platform)
     * Customer bayar cash penuh S + T ke teknisi.
     * Teknisi berutang komisi C ke platform.
     */
    public function test_case_4_cash_without_promo_technician_pays_platform(): void
    {
        $res = FinancialCalculator::calculate(
            serviceSubtotal: 100000,
            transportFee: 20000,
            discountAmount: 0,
            commissionPercent: '5.00',
            roundingMode: 'round',
            roundingUnit: 1
        );

        $this->assertSame(120000, $res->paymentAmount);
        $this->assertSame(5000, $res->commissionAmount);
        $this->assertSame(115000, $res->technicianNetIncome);
        $this->assertSame(5000, $res->delta);
        $this->assertSame('technician_pays_platform', $res->settlementDirection);
        $this->assertSame(5000, $res->settlementAmount);

        // Invarian
        $this->assertSame($res->serviceSubtotal + $res->transportFee, $res->technicianNetIncome + $res->commissionAmount);
        $this->assertSame($res->paymentAmount - $res->technicianNetIncome, $res->commissionAmount - $res->discountAmount);
    }

    /**
     * Edge case: S - D = 0 (Jasa diskon 100%)
     * Komisi platform harus 0, customer hanya bayar transport fee.
     */
    public function test_edge_case_service_subtotal_minus_discount_is_zero(): void
    {
        $res = FinancialCalculator::calculate(
            serviceSubtotal: 100000,
            transportFee: 25000,
            discountAmount: 100000,
            commissionPercent: '5.00'
        );

        $this->assertSame(0, $res->discountedSubtotal);
        $this->assertSame(25000, $res->paymentAmount);
        $this->assertSame(0, $res->commissionAmount);
        $this->assertSame(125000, $res->technicianNetIncome);
        $this->assertSame(-100000, $res->delta);
        $this->assertSame('platform_pays_technician', $res->settlementDirection);
        $this->assertSame(100000, $res->settlementAmount);

        // Invarian
        $this->assertSame(125000, $res->technicianNetIncome + $res->commissionAmount);
        $this->assertSame($res->paymentAmount - $res->technicianNetIncome, $res->commissionAmount - $res->discountAmount);
    }

    /**
     * Edge case: Diskon promo melebihi S (harus di-capped di S, tidak boleh negatif).
     */
    public function test_edge_case_discount_exceeds_service_subtotal(): void
    {
        $res = FinancialCalculator::calculate(
            serviceSubtotal: 50000,
            transportFee: 15000,
            discountAmount: 90000,
            commissionPercent: '5.00'
        );

        $this->assertSame(50000, $res->discountAmount);
        $this->assertSame(0, $res->discountedSubtotal);
        $this->assertSame(15000, $res->paymentAmount);
        $this->assertSame(0, $res->commissionAmount);
        $this->assertSame(65000, $res->technicianNetIncome);

        // Invarian
        $this->assertSame(65000, $res->technicianNetIncome + $res->commissionAmount);
    }

    /**
     * Edge case: Pembulatan dengan unit 100 (round, floor, ceil).
     * S - D = 75.000, 5% = 3.750.
     * unit = 100:
     * - round -> 3.800
     * - floor -> 3.700
     * - ceil  -> 3.800
     */
    public function test_rounding_modes_with_unit_100(): void
    {
        $discounted = 75000;

        $cRound = FinancialCalculator::calculateCommission($discounted, '5.00', 'round', 100);
        $this->assertSame(3800, $cRound);

        $cFloor = FinancialCalculator::calculateCommission($discounted, '5.00', 'floor', 100);
        $this->assertSame(3700, $cFloor);

        $cCeil = FinancialCalculator::calculateCommission($discounted, '5.00', 'ceil', 100);
        $this->assertSame(3800, $cCeil);
    }

    /**
     * Test perhitungan diskon promo: persentase vs fixed, min order & max discount.
     */
    public function test_discount_calculation(): void
    {
        // 10% dari 150.000 = 15.000
        $d1 = FinancialCalculator::calculateDiscount(150000, 'percentage', 10);
        $this->assertSame(15000, $d1);

        // 10% dari 150.000 dengan max discount 10.000 = 10.000
        $d2 = FinancialCalculator::calculateDiscount(150000, 'percentage', 10, 10000);
        $this->assertSame(10000, $d2);

        // Fixed 25.000
        $d3 = FinancialCalculator::calculateDiscount(100000, 'fixed', 25000);
        $this->assertSame(25000, $d3);

        // Fixed 150.000 saat subtotal hanya 80.000 -> capped di 80.000
        $d4 = FinancialCalculator::calculateDiscount(80000, 'fixed', 150000);
        $this->assertSame(80000, $d4);
    }

    /**
     * Invarian tes komprehensif acak: N + C = S + T dan P - N = C - D selalu terpenuhi.
     */
    public function test_invariants_hold_across_random_ranges(): void
    {
        $modes = ['round', 'floor', 'ceil'];
        $units = [1, 100];

        for ($i = 0; $i < 50; $i++) {
            $S = rand(10000, 500000);
            $T = rand(5000, 50000);
            $D = rand(0, $S + 10000);
            $r = rand(1, 15).'.00';
            $mode = $modes[array_rand($modes)];
            $unit = $units[array_rand($units)];

            $res = FinancialCalculator::calculate($S, $T, $D, $r, $mode, $unit);

            $this->assertSame(
                $res->serviceSubtotal + $res->transportFee,
                $res->technicianNetIncome + $res->commissionAmount,
                "Invariant 1 violated for S=$S, T=$T, D=$D, r=$r"
            );
            $this->assertSame(
                $res->paymentAmount - $res->technicianNetIncome,
                $res->commissionAmount - $res->discountAmount,
                "Invariant 2 violated for S=$S, T=$T, D=$D, r=$r"
            );
        }
    }
}
