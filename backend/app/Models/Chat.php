<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Chat extends Model
{
    protected $fillable = [
        'user1_id',
        'user2_id',
        'firebase_chat_id',
        'last_message',
    ];

    // If you want to use timestamps (created_at, updated_at) it's enabled by default.

    public function user1(): BelongsTo
    {
        return $this->belongsTo(\App\Models\User::class, 'user1_id');
    }

    public function user2(): BelongsTo
    {
        return $this->belongsTo(\App\Models\User::class, 'user2_id');
    }

    /**
     * Return the "other" participant for a given user id.
     */
    public function otherUser($userId)
    {
        return $this->user1_id == $userId ? $this->user2 : $this->user1;
    }
}
