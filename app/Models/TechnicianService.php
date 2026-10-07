<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TechnicianService extends Model
{
    use HasFactory;

    protected $fillable = [
        'technician_profile_id',
        'service_item_id',
        'custom_price',
        'is_offered',
    ];

    protected function casts(): array
    {
        return [
            'custom_price' => 'decimal:2',
            'is_offered' => 'boolean',
        ];
    }

    public function technicianProfile(): BelongsTo
    {
        return $this->belongsTo(TechnicianProfile::class);
    }

    public function serviceItem(): BelongsTo
    {
        return $this->belongsTo(ServiceItem::class);
    }
}
