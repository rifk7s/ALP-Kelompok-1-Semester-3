<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PetaniData extends Model
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'petani_data';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'phone',
        'address',
        'is_active',
    ];

    public function productContributions(): HasMany
    {
        return $this->hasMany(ProductContribution::class);
    }
}
