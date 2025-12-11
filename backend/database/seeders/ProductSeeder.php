<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Product;
use App\Models\ProductContribution;
use App\Models\Category;
use App\Models\PetaniData;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get categories
        $gabah = Category::where('slug', 'gabah')->first();
        $buah = Category::where('slug', 'buah')->first();
        $sayur = Category::where('slug', 'sayur')->first();
        $padi = Category::where('slug', 'padi')->first();
        $cabe = Category::where('slug', 'cabe')->first();

        // Get petani
        $pakJono = PetaniData::where('name', 'Pak Jono')->first();
        $buRani = PetaniData::where('name', 'Bu Rani')->first();
        $pakBudi = PetaniData::where('name', 'Pak Budi')->first();
        $buSiti = PetaniData::where('name', 'Bu Siti')->first();
        $pakAhmad = PetaniData::where('name', 'Pak Ahmad')->first();

        // Products with stock
        $products = [
            [
                'name' => 'Gabah Kering Premium',
                'category_id' => $gabah->id,
                'variety' => 'Ciherang',
                'harvest_date' => '2025-12-01',
                'storage_days' => 30,
                'price_per_kg' => 6500,
                'stock_kg' => 50,
                'sold_kg' => 0,
                'description' => 'Gabah kering berkualitas tinggi dari petani lokal',
                'status' => 'active',
                'petani_id' => $pakJono->id,
            ],
            [
                'name' => 'Gabah Pertiwi',
                'category_id' => $gabah->id,
                'variety' => 'Pertiwi',
                'harvest_date' => '2025-12-02',
                'storage_days' => 30,
                'price_per_kg' => 6800,
                'stock_kg' => 35,
                'sold_kg' => 0,
                'description' => 'Gabah varietas Pertiwi dengan kualitas unggul',
                'status' => 'active',
                'petani_id' => $buRani->id,
            ],
            [
                'name' => 'Buah Mangga Harum Manis',
                'category_id' => $buah->id,
                'variety' => 'Standard',
                'harvest_date' => '2025-12-05',
                'storage_days' => 7,
                'price_per_kg' => 6100,
                'stock_kg' => 25,
                'sold_kg' => 0,
                'description' => 'Mangga harum manis segar dari kebun',
                'status' => 'active',
                'petani_id' => $pakBudi->id,
            ],
            [
                'name' => 'Sayur Kangkung Segar',
                'category_id' => $sayur->id,
                'variety' => 'Standard',
                'harvest_date' => '2025-12-08',
                'storage_days' => 3,
                'price_per_kg' => 6300,
                'stock_kg' => 15,
                'sold_kg' => 0,
                'description' => 'Kangkung segar organik',
                'status' => 'active',
                'petani_id' => $buSiti->id,
            ],
            [
                'name' => 'Padi Organik',
                'category_id' => $padi->id,
                'variety' => 'Standard',
                'harvest_date' => '2025-11-28',
                'storage_days' => 60,
                'price_per_kg' => 6500,
                'stock_kg' => 80,
                'sold_kg' => 0,
                'description' => 'Padi organik tanpa pestisida',
                'status' => 'active',
                'petani_id' => $pakAhmad->id,
            ],
            // Products with ZERO stock (sold out)
            [
                'name' => 'Gabah Ciherang Habis',
                'category_id' => $gabah->id,
                'variety' => 'Ciherang',
                'harvest_date' => '2025-11-20',
                'storage_days' => 30,
                'price_per_kg' => 6500,
                'stock_kg' => 0,
                'sold_kg' => 40,
                'description' => 'Stok sudah habis terjual',
                'status' => 'sold_out',
                'petani_id' => $pakJono->id,
            ],
            [
                'name' => 'Cabe Merah Keriting Habis',
                'category_id' => $cabe->id,
                'variety' => 'Standard',
                'harvest_date' => '2025-11-25',
                'storage_days' => 5,
                'price_per_kg' => 6900,
                'stock_kg' => 0,
                'sold_kg' => 20,
                'description' => 'Cabe merah sudah laku semua',
                'status' => 'sold_out',
                'petani_id' => $buRani->id,
            ],
            [
                'name' => 'Buah Pisang Cavendish Habis',
                'category_id' => $buah->id,
                'variety' => 'Standard',
                'harvest_date' => '2025-11-22',
                'storage_days' => 7,
                'price_per_kg' => 6100,
                'stock_kg' => 0,
                'sold_kg' => 30,
                'description' => 'Pisang cavendish habis terjual',
                'status' => 'sold_out',
                'petani_id' => $pakBudi->id,
            ],
        ];

        foreach ($products as $productData) {
            $petaniId = $productData['petani_id'];
            unset($productData['petani_id']);

            // Create product
            $product = Product::create($productData);

            // Create product contribution if stock > 0
            if ($product->stock_kg > 0) {
                ProductContribution::create([
                    'product_id' => $product->id,
                    'petani_id' => $petaniId,
                    'contributed_kg' => $product->stock_kg,
                    'remaining_kg' => $product->stock_kg,
                    'entry_date' => now(),
                    'harvest_date' => $product->harvest_date,
                ]);
            }
        }
    }
}
