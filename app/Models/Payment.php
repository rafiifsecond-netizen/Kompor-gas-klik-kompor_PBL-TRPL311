<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Payment extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';

    public const STATUS_AWAITING_VERIFICATION = 'awaiting_verification';

    public const STATUS_PAID = 'paid';

    public const STATUS_EXPIRED = 'expired';

    public const STATUS_FAILED = 'failed';

    public const STATUS_REFUNDED = 'refunded';

    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'order_id',
        'customer_id',
        'payment_number',
        'idempotency_key',
        'payment_method',
        'amount',
        'payment_status',
        'gateway_provider',
        'gateway_order_id',
        'gateway_transaction_id',
        'qris_qr_string',
        'qris_qr_url',
        'sender_bank_name',
        'sender_account_name',
        'proof_url',
        'proof_uploaded_at',
        'expires_at',
        'paid_at',
        'verified_by',
        'verified_at',
        'rejection_reason',
        'transaction_reference',
        'payload',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'integer',
            'proof_uploaded_at' => 'datetime',
            'expires_at' => 'datetime',
            'paid_at' => 'datetime',
            'verified_at' => 'datetime',
            'payload' => 'array',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function commissionRecord(): HasOne
    {
        return $this->hasOne(CommissionRecord::class);
    }

    public function webhookEvents(): HasMany
    {
        return $this->hasMany(WebhookEvent::class);
    }
}
