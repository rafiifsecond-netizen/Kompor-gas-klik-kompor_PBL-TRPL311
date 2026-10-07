<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Http\Request;

class ActivityLog extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'actor_id',
        'actor_role',
        'event_name',
        'description',
        'entity_type',
        'entity_id',
        'ip_address',
        'user_agent',
        'platform',
        'old_values',
        'new_values',
        'status',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'old_values' => 'array',
            'new_values' => 'array',
            'created_at' => 'datetime',
        ];
    }

    public function actor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'actor_id');
    }

    /**
     * Helper to log audit activity as required by security specifications.
     */
    public static function logEvent(
        string $eventName,
        ?string $description = null,
        ?Model $entity = null,
        ?array $oldValues = null,
        ?array $newValues = null,
        string $status = 'success',
        ?Request $request = null,
        ?User $actor = null
    ): self {
        $req = $request ?? request();
        $user = $actor ?? auth()->user();

        $platform = 'api';
        if ($req) {
            $clientHeader = strtolower((string) $req->header('X-App-Platform', ''));
            if (in_array($clientHeader, ['ios', 'android', 'web_admin'])) {
                $platform = $clientHeader;
            } elseif ($req->is('*admin*')) {
                $platform = 'web_admin';
            }
        }

        return self::create([
            'actor_id' => $user?->id,
            'actor_role' => $user?->role ?? 'system',
            'event_name' => $eventName,
            'description' => $description,
            'entity_type' => $entity ? class_basename($entity) : null,
            'entity_id' => $entity?->getKey(),
            'ip_address' => $req?->ip() ?? '127.0.0.1',
            'user_agent' => $req?->userAgent(),
            'platform' => $platform,
            'old_values' => $oldValues,
            'new_values' => $newValues,
            'status' => $status,
            'created_at' => now(),
        ]);
    }
}
