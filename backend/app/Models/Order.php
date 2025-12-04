<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

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
        'payment_deadline',
        'estimated_delivery',

        // Foreign keys
        'buyer_id',
    ];

    public function payments(): HasOne
    {
        return $this->hasOne(Payment::class);
    }

    public function orderItems(): HasOne
    {
        return $this->hasOne(OrderItems::class);
    }

    public function buyer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'buyer_id');
    }
}
