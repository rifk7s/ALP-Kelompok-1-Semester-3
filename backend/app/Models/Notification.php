<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Notification extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */

    protected $fillable = [
        'title',
        'message',
        'type',
        'related_id',
        'is_read',

        // Foreign keys
        'user_id',     
    ];

    public function user(): Belongsto
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
