<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */

    protected $fillable = [
        'name',
        'variety',
        'harvest_date',
        'storage_days',
        'price_per_kg',
        'stock_kg',
        'sold_kg',
        'description',
        'status',

        // Foreign keys
        // 'user_id',
        // 'category_id',
    ];
}
