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
        'payment_reference',
        'idempotency_key',
        'payment_method',
        'amount',
        'payment_status',
        'gateway_provider',
        'payment_gateway',
        'gateway_order_id',
        'gateway_transaction_id',
        'transaction_id',
        'qris_qr_string',
        'qris_qr_url',
        'sender_bank_name',
        'bank_name',
        'va_number',
        'biller_code',
        'bill_key',
        'sender_account_name',
        'proof_url',
        'proof_uploaded_at',
        'expires_at',
        'expired_at',
        'paid_at',
        'verified_by',
        'verified_at',
        'rejection_reason',
        'transaction_reference',
        'payload',
        'gateway_response',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'integer',
            'proof_uploaded_at' => 'datetime',
            'expires_at' => 'datetime',
            'expired_at' => 'datetime',
            'paid_at' => 'datetime',
            'verified_at' => 'datetime',
            'payload' => 'array',
            'gateway_response' => 'array',
        ];
    }

    protected static function booted(): void
    {
        static::saving(function (Payment $payment) {
            // Sinkronkan nama alias spesifikasi dengan kolom internal
            if (empty($payment->payment_reference) && ! empty($payment->payment_number)) {
                $payment->payment_reference = $payment->payment_number;
            } elseif (empty($payment->payment_number) && ! empty($payment->payment_reference)) {
                $payment->payment_number = $payment->payment_reference;
            }

            if (empty($payment->payment_gateway) && ! empty($payment->gateway_provider)) {
                $payment->payment_gateway = $payment->gateway_provider;
            } elseif (empty($payment->gateway_provider) && ! empty($payment->payment_gateway)) {
                $payment->gateway_provider = $payment->payment_gateway;
            }

            if (empty($payment->transaction_id) && ! empty($payment->gateway_transaction_id)) {
                $payment->transaction_id = $payment->gateway_transaction_id;
            } elseif (empty($payment->gateway_transaction_id) && ! empty($payment->transaction_id)) {
                $payment->gateway_transaction_id = $payment->transaction_id;
            }

            if (empty($payment->expired_at) && ! empty($payment->expires_at)) {
                $payment->expired_at = $payment->expires_at;
            } elseif (empty($payment->expires_at) && ! empty($payment->expired_at)) {
                $payment->expires_at = $payment->expired_at;
            }

            if (empty($payment->gateway_response) && ! empty($payment->payload)) {
                $payment->gateway_response = $payment->payload;
            } elseif (empty($payment->payload) && ! empty($payment->gateway_response)) {
                $payment->payload = $payment->gateway_response;
            }

            if (empty($payment->bank_name) && ! empty($payment->sender_bank_name)) {
                $payment->bank_name = $payment->sender_bank_name;
            }
        });
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
