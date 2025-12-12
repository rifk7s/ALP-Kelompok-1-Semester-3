<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */

    protected $fillable = [
        'order_number',
        'subtotal',
        'shipping_cost',
        'total',
        'status',
        'shipping_address',
        'notes',
        'payment_deadline',
        'estimated_delivery',
        'pending_payment_at',
        'paid_at',
        'processing_at',
        'shipped_at',
        'completed_at',
        'rejected_at',

        // Foreign keys
        'buyer_id',
    ];

    public function payments(): HasOne
    {
        return $this->hasOne(Payment::class);
    }

    public function orderItems(): HasMany
    {
        return $this->hasMany(OrderItems::class);
    }

    public function buyer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'buyer_id');
    }
}
