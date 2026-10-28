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
            'description' => self::sanitizeText($description),
            'entity_type' => $entity ? class_basename($entity) : null,
            'entity_id' => $entity?->getKey(),
            'ip_address' => $req?->ip() ?? '127.0.0.1',
            'user_agent' => $req?->userAgent(),
            'platform' => $platform,
            'old_values' => self::sanitizeValues($oldValues),
            'new_values' => self::sanitizeValues($newValues),
            'status' => $status,
            'created_at' => now(),
        ]);
    }

    /**
     * Audit records must not become a secondary store for credentials or PII.
     *
     * @param  array<string, mixed>|null  $values
     * @return array<string, mixed>|null
     */
    private static function sanitizeValues(?array $values): ?array
    {
        if ($values === null) {
            return null;
        }

        $sensitiveKeys = [
            'password',
            'password_confirmation',
            'token',
            'access_token',
            'remember_token',
            'email',
            'phone',
            'address',
            'full_address',
            'recipient_name',
            'customer_name',
            'customer_phone',
            'ktp_number',
            'latitude',
            'longitude',
            'current_latitude',
            'current_longitude',
            'proof_url',
            'transaction_reference',
            'payload',
            'message',
            'user_agent',
        ];

        $sanitize = function (mixed $value, ?string $key = null) use (&$sanitize, $sensitiveKeys): mixed {
            if ($key !== null && in_array(strtolower($key), $sensitiveKeys, true)) {
                return '[REDACTED]';
            }

            if (is_array($value)) {
                $result = [];
                foreach ($value as $childKey => $childValue) {
                    $result[$childKey] = $sanitize($childValue, is_string($childKey) ? $childKey : null);
                }

                return $result;
            }

            return $value;
        };

        return $sanitize($values);
    }

    private static function sanitizeText(?string $text): ?string
    {
        if ($text === null) {
            return null;
        }

        return preg_replace(
            '/((?:email|identifier|phone|telepon|alamat|address)\s*[:=]\s*)([^,\s;]+)/i',
            '$1[REDACTED]',
            $text
        ) ?? '[REDACTED]';
    }
}
