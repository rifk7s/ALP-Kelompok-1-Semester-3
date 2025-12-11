<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */

    protected $fillable = [
        'name',
        'slug',
        'icon'     
    ];

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function hppPrices(): HasMany
    {
        return $this->hasMany(HppPrice::class);
    }
}
