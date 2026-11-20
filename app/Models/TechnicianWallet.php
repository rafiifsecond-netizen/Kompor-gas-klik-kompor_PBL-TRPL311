<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TechnicianWallet extends Model
{
    use HasFactory;

    protected $fillable = [
        'technician_id',
        'balance',
        'pending_balance',
        'bank_name',
        'bank_account_number',
        'bank_account_holder',
    ];

    protected function casts(): array
    {
        return [
            'balance' => 'integer',
            'pending_balance' => 'integer',
        ];
    }

    public function technician(): BelongsTo
    {
        return $this->belongsTo(User::class, 'technician_id');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(WalletTransaction::class, 'wallet_id');
    }

    public function payoutRequests(): HasMany
    {
        return $this->hasMany(PayoutRequest::class, 'wallet_id');
    }
}
