<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AdditionalCost extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';

    public const STATUS_APPROVED = 'approved';

    public const STATUS_REJECTED = 'rejected';

    protected $fillable = [
        'order_id',
        'technician_id',
        'item_name',
        'description',
        'quantity',
        'unit_price',
        'subtotal',
        'photo_url',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'quantity' => 'integer',
            'unit_price' => 'integer',
            'subtotal' => 'integer',
        ];
    }

    /** Hitung dan simpan subtotal dari quantity × unit_price. */
    public function recalculateSubtotal(): void
    {
        $this->subtotal = (int) $this->quantity * (int) $this->unit_price;
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function technician(): BelongsTo
    {
        return $this->belongsTo(User::class, 'technician_id');
    }
}
