<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CommissionRecord extends Model
{
    use HasFactory;

    public const DIRECTION_TECH_PAYS_PLATFORM = 'technician_pays_platform';

    public const DIRECTION_PLATFORM_PAYS_TECH = 'platform_pays_technician';

    public const DIRECTION_NONE = 'none';

    public const STATUS_SETTLED = 'settled';

    public const STATUS_UNSETTLED = 'unsettled';

    public const STATUS_WAIVED = 'waived';

    protected $fillable = [
        'order_id',
        'technician_id',
        'payment_id',
        'service_subtotal',
        'transport_fee',
        'discount_amount',
        'final_order_amount',
        'commission_percentage',
        'commission_amount',
        'platform_subsidy',
        'technician_net_income',
        'payment_method',
        'settlement_direction',
        'settlement_amount',
        'settlement_status',
        'rounding_mode_snapshot',
        'rounding_unit_snapshot',
        'settled_at',
        'settled_by',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'service_subtotal' => 'integer',
            'transport_fee' => 'integer',
            'discount_amount' => 'integer',
            'final_order_amount' => 'integer',
            'commission_amount' => 'integer',
            'platform_subsidy' => 'integer',
            'technician_net_income' => 'integer',
            'settlement_amount' => 'integer',
            'rounding_unit_snapshot' => 'integer',
            'settled_at' => 'datetime',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function technician(): BelongsTo
    {
        return $this->belongsTo(User::class, 'technician_id');
    }

    public function payment(): BelongsTo
    {
        return $this->belongsTo(Payment::class);
    }

    public function settledBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'settled_by');
    }
}
