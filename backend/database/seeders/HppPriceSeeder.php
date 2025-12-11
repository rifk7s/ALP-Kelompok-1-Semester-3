<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\HppPrice;
use App\Models\Category;

class HppPriceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = Category::all();

        foreach ($categories as $category) {
            if ($category->name === 'Gabah') {
                // Gabah with varieties
                HppPrice::create([
                    'category_id' => $category->id,
                    'variety' => 'Ciherang',
                    'price_per_kg' => 6500,
                    'source' => 'Market Research',
                    'effective_date' => now(),
                ]);

                HppPrice::create([
                    'category_id' => $category->id,
                    'variety' => 'Pertiwi',
                    'price_per_kg' => 6800,
                    'source' => 'Market Research',
                    'effective_date' => now(),
                ]);
            } else {
                // Other categories without variety
                $prices = [
                    'Buah' => 6200,
                    'Sayur' => 6100,
                    'Padi' => 6700,
                    'Cabe' => 6900,
                ];

                HppPrice::create([
                    'category_id' => $category->id,
                    'variety' => 'Standard',
                    'price_per_kg' => $prices[$category->name] ?? 6000,
                    'source' => 'Market Research',
                    'effective_date' => now(),
                ]);
            }
        }
    }
}
