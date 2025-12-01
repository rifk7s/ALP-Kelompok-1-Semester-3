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
        // 'committed_kg',
        // 'available_kg',
        // 'sale_type',
        // 'lead_time_days',
        'description',
        'status',
        // 'managed_by_bumdes',
        // 'seller_type',
        // 'seller_display',
        'sold_kg',

        // Foreign keys
        // 'user_id',
        // 'created_by',
        // 'category_id',
        // 'seller_id',
    ];
}
