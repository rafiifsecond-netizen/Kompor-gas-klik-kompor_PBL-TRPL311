<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Order extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';

    public const STATUS_ACCEPTED = 'accepted';

    public const STATUS_ON_THE_WAY = 'on_the_way';

    public const STATUS_ARRIVED = 'arrived';

    public const STATUS_IN_PROGRESS = 'in_progress';

    public const STATUS_COMPLETED = 'completed';

    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'order_number',
        'customer_id',
        'technician_id',
        'status',
        'scheduled_at',
        'arrived_at',
        'started_at',
        'customer_name',
        'customer_phone',
        'address',
        'latitude',
        'longitude',
        'stove_brand',
        'stove_type',
        'problem_description',
        'subtotal',
        'transport_fee',
        'discount',
        'total_amount',
        'payment_method',
        'payment_status',
        'cancellation_reason',
        'cancelled_by',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'scheduled_at' => 'datetime',
            'arrived_at' => 'datetime',
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
            'latitude' => 'float',
            'longitude' => 'float',
            'subtotal' => 'integer',
            'transport_fee' => 'integer',
            'discount' => 'integer',
            'total_amount' => 'integer',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function technician(): BelongsTo
    {
        return $this->belongsTo(User::class, 'technician_id');
    }

    public function cancelledByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'cancelled_by');
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function statusLogs(): HasMany
    {
        return $this->hasMany(OrderStatusLog::class)->orderBy('created_at', 'asc');
    }

    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class)->latestOfMany();
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function activePayment(): HasOne
    {
        return $this->hasOne(Payment::class)
            ->whereIn('payment_status', [
                Payment::STATUS_PENDING,
                Payment::STATUS_AWAITING_VERIFICATION,
                Payment::STATUS_PAID,
            ]);
    }

    public function commissionRecord(): HasOne
    {
        return $this->hasOne(CommissionRecord::class);
    }

    public function promoUsage(): HasOne
    {
        return $this->hasOne(PromoUsage::class);
    }

    public function review(): HasOne
    {
        return $this->hasOne(Review::class);
    }

    public function additionalCosts(): HasMany
    {
        return $this->hasMany(AdditionalCost::class);
    }

    public function chat(): HasOne
    {
        return $this->hasOne(Chat::class);
    }
}
