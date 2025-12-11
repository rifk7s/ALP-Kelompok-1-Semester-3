<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Category;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            ['name' => 'Gabah', 'slug' => 'gabah', 'icon' => '🌾'],
            ['name' => 'Buah', 'slug' => 'buah', 'icon' => '🍎'],
            ['name' => 'Sayur', 'slug' => 'sayur', 'icon' => '🥬'],
            ['name' => 'Padi', 'slug' => 'padi', 'icon' => '🌾'],
            ['name' => 'Cabe', 'slug' => 'cabe', 'icon' => '🌶️'],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
