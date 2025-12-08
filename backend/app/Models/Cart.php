<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Cart extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */

    protected $fillable = [
        'quantity_kg',

        // Foreign keys
        'user_id',
        'product_id'     
    ];

    public function user(): Belongsto
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function product(): Belongsto
    {
        return $this->belongsTo(Product::class, 'product_id');
    }
}
