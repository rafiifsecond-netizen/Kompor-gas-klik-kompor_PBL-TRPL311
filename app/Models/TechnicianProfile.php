<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TechnicianProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'bio',
        'years_of_experience',
        'skills',
        'ktp_number',
        'certificate_url',
        'is_verified',
        'verified_at',
        'verified_by',
        'is_available',
        'current_latitude',
        'current_longitude',
        'last_location_updated_at',
        'rating_avg',
        'reviews_count',
        'jobs_completed_count',
    ];

    protected $hidden = [
        'ktp_number',
    ];

    protected function casts(): array
    {
        return [
            'skills' => 'array',
            'is_verified' => 'boolean',
            'is_available' => 'boolean',
            'verified_at' => 'datetime',
            'last_location_updated_at' => 'datetime',
            'rating_avg' => 'float',
            'current_latitude' => 'float',
            'current_longitude' => 'float',
            'years_of_experience' => 'integer',
            'reviews_count' => 'integer',
            'jobs_completed_count' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function services(): HasMany
    {
        return $this->hasMany(TechnicianService::class);
    }
}
