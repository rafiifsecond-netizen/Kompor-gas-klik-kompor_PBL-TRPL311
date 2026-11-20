<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Promo extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'name',
        'description',
        'type',
        'discount_amount',
        'max_discount',
        'min_order_amount',
        'start_date',
        'end_date',
        'total_quota',
        'quota_per_user',
        'applicable_payment_methods',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'discount_amount' => 'integer',
            'max_discount' => 'integer',
            'min_order_amount' => 'integer',
            'start_date' => 'datetime',
            'end_date' => 'datetime',
            'total_quota' => 'integer',
            'quota_per_user' => 'integer',
            'applicable_payment_methods' => 'array',
            'is_active' => 'boolean',
        ];
    }

    public function usages(): HasMany
    {
        return $this->hasMany(PromoUsage::class);
    }

    /**
     * Hitung kuota yang sedang terpakai (status 'reserved' atau 'used').
     */
    public function activeUsagesCount(): int
    {
        return $this->usages()
            ->whereIn('status', ['reserved', 'used'])
            ->count();
    }

    public function remainingQuota(): int
    {
        return max(0, $this->total_quota - $this->activeUsagesCount());
    }

    public function isAvailableForUser(User $user, ?string $paymentMethod = null): bool
    {
        if (! $this->is_active) {
            return false;
        }

        $now = now();
        if ($now->lt($this->start_date) || $now->gt($this->end_date)) {
            return false;
        }

        if ($this->remainingQuota() <= 0) {
            return false;
        }

        if ($paymentMethod && ! empty($this->applicable_payment_methods)) {
            if (! in_array($paymentMethod, $this->applicable_payment_methods, true)) {
                return false;
            }
        }

        $userUsageCount = $this->usages()
            ->where('user_id', $user->id)
            ->whereIn('status', ['reserved', 'used'])
            ->count();

        return $userUsageCount < $this->quota_per_user;
    }
}
