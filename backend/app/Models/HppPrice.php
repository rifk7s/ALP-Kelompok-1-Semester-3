<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HppPrice extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */

    protected $fillable = [
        'category_id',
        'variety',
        'price_per_kg',
        'source',
        'effective_date',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}
