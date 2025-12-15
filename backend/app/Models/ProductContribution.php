<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProductContribution extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */

    protected $fillable = [
        'contributed_kg',
        'remaining_kg',
        'entry_date',
        'harvest_date',

        // Foreign keys
        'product_id',
        'petani_id'     
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class, 'product_id');
    }

    public function petani(): BelongsTo
    {
        return $this->belongsTo(PetaniData::class, 'petani_id');
    }
}
