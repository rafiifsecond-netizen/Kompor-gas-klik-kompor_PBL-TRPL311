<?php

namespace App\Services\Payment;

class FinancialCalculationResult
{
    public function __construct(
        public readonly int $serviceSubtotal,
        public readonly int $transportFee,
        public readonly int $discountAmount,
        public readonly int $discountedSubtotal,
        public readonly int $paymentAmount,
        public readonly string $commissionPercentage,
        public readonly int $commissionAmount,
        public readonly int $technicianNetIncome,
        public readonly int $delta,
        public readonly string $settlementDirection,
        public readonly int $settlementAmount,
        public readonly int $platformSubsidy,
        public readonly string $roundingMode,
        public readonly int $roundingUnit
    ) {}

    public function toArray(): array
    {
        return [
            'service_subtotal' => $this->serviceSubtotal,
            'transport_fee' => $this->transportFee,
            'discount_amount' => $this->discountAmount,
            'discounted_subtotal' => $this->discountedSubtotal,
            'payment_amount' => $this->paymentAmount,
            'commission_percentage' => $this->commissionPercentage,
            'commission_amount' => $this->commissionAmount,
            'technician_net_income' => $this->technicianNetIncome,
            'delta' => $this->delta,
            'settlement_direction' => $this->settlementDirection,
            'settlement_amount' => $this->settlementAmount,
            'platform_subsidy' => $this->platformSubsidy,
            'rounding_mode' => $this->roundingMode,
            'rounding_unit' => $this->roundingUnit,
        ];
    }
}
