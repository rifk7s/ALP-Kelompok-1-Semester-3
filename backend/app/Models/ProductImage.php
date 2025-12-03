<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProductImage extends Model
{
    protected $fillable = [
        'image_path',
        'order',

        // Foreign keys
        'product_id',
    ];

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'product_id');
    }

}
