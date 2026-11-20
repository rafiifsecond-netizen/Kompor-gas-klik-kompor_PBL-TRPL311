<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WebhookEvent extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'order_id',
        'payment_id',
        'gateway_provider',
        'gateway_order_id',
        'gateway_transaction_id',
        'transaction_status',
        'signature_valid',
        'is_processed',
        'flagged_for_manual_refund',
        'payload',
        'processed_at',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'signature_valid' => 'boolean',
            'is_processed' => 'boolean',
            'flagged_for_manual_refund' => 'boolean',
            'payload' => 'array',
            'processed_at' => 'datetime',
            'created_at' => 'datetime',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function payment(): BelongsTo
    {
        return $this->belongsTo(Payment::class);
    }
}
