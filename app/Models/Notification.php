<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Notification extends Model
{
    use HasFactory;

    // Tipe notifikasi yang tersedia di sistem
    public const TYPE_ORDER_UPDATE = 'order_update';

    public const TYPE_PAYMENT = 'payment';

    public const TYPE_CHAT = 'chat';

    public const TYPE_PROMO = 'promo';

    protected $fillable = [
        'user_id',
        'type',
        'title',
        'message',
        'data',
        'read_at',
    ];

    protected function casts(): array
    {
        return [
            'data' => 'array',
            'read_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** Tandai notifikasi sebagai sudah dibaca. */
    public function markAsRead(): void
    {
        if ($this->read_at === null) {
            $this->update(['read_at' => now()]);
        }
    }

    public function isRead(): bool
    {
        return $this->read_at !== null;
    }

    /**
     * Helper statis untuk membuat notifikasi dengan mudah dari mana saja.
     *
     * @param  array{type: string, title: string, message: string, data?: array<string, mixed>}  $attributes
     */
    public static function send(int $userId, array $attributes): self
    {
        return self::create([
            'user_id' => $userId,
            'type' => $attributes['type'],
            'title' => $attributes['title'],
            'message' => $attributes['message'],
            'data' => $attributes['data'] ?? null,
        ]);
    }
}
