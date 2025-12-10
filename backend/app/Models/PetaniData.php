<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

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
}
