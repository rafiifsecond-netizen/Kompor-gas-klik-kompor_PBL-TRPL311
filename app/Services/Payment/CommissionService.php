<?php

namespace App\Services\Payment;

use App\Models\CommissionRecord;
use App\Models\Order;
use App\Models\Payment;
use App\Models\PlatformSetting;

class CommissionService
{
    /**
     * Buat dan simpan snapshot catatan komisi pesanan.
     * Snapshot ini mengunci nilai persentase komisi dan aturan pembulatan
     * sehingga perubahan setting di masa depan tidak mempengaruhi transaksi lama.
     */
    public function createCommissionRecord(
        Order $order,
        string $paymentMethod,
        ?Payment $payment = null,
        ?int $discountAmount = null
    ): ?CommissionRecord {
        if (! $order->technician_id) {
            return null;
        }

        $commissionPercent = PlatformSetting::get('platform_commission_percent', '5.00');
        $roundingMode = PlatformSetting::get('rounding_mode', 'round');
        $roundingUnit = (int) PlatformSetting::get('rounding_unit', 1);

        $discount = $discountAmount ?? (int) ($order->discount ?? 0);

        $calc = FinancialCalculator::calculate(
            serviceSubtotal: (int) $order->subtotal,
            transportFee: (int) $order->transport_fee,
            discountAmount: $discount,
            commissionPercent: $commissionPercent,
            roundingMode: $roundingMode,
            roundingUnit: $roundingUnit
        );

        return CommissionRecord::updateOrCreate(
            ['order_id' => $order->id],
            [
                'technician_id' => $order->technician_id,
                'payment_id' => $payment?->id,
                'service_subtotal' => $calc->serviceSubtotal,
                'transport_fee' => $calc->transportFee,
                'discount_amount' => $calc->discountAmount,
                'final_order_amount' => $calc->paymentAmount,
                'commission_percentage' => $calc->commissionPercentage,
                'commission_amount' => $calc->commissionAmount,
                'platform_subsidy' => $calc->platformSubsidy,
                'technician_net_income' => $calc->technicianNetIncome,
                'payment_method' => $paymentMethod,
                'settlement_direction' => $calc->settlementDirection,
                'settlement_amount' => $calc->settlementAmount,
                'settlement_status' => CommissionRecord::STATUS_UNSETTLED,
                'rounding_mode_snapshot' => $roundingMode,
                'rounding_unit_snapshot' => $roundingUnit,
            ]
        );
    }
}
