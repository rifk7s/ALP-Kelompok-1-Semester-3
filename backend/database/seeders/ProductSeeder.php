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
        // Get or create categories
        $gabah = Category::firstOrCreate(['slug' => 'gabah'], ['name' => 'Gabah', 'icon' => '🌾']);
        $buah = Category::firstOrCreate(['slug' => 'buah'], ['name' => 'Buah', 'icon' => '🍎']);
        $sayur = Category::firstOrCreate(['slug' => 'sayur'], ['name' => 'Sayur', 'icon' => '🥬']);
        $padi = Category::firstOrCreate(['slug' => 'padi'], ['name' => 'Padi', 'icon' => '🌾']);
        $cabe = Category::firstOrCreate(['slug' => 'cabe'], ['name' => 'Cabe', 'icon' => '🌶️']);

        // Get or create petani
        $pakJono = PetaniData::firstOrCreate(
            ['name' => 'Pak Jono'],
            ['phone' => '081234567890', 'address' => 'Desa Sumber Makmur, Jawa Timur', 'is_active' => true]
        );
        $buRani = PetaniData::firstOrCreate(
            ['name' => 'Bu Rani'],
            ['phone' => '081234567891', 'address' => 'Desa Tani Sejahtera, Jawa Tengah', 'is_active' => true]
        );
        $pakBudi = PetaniData::firstOrCreate(
            ['name' => 'Pak Budi'],
            ['phone' => '081234567892', 'address' => 'Desa Maju Bersama, Jawa Barat', 'is_active' => true]
        );
        $buSiti = PetaniData::firstOrCreate(
            ['name' => 'Bu Siti'],
            ['phone' => '081234567893', 'address' => 'Desa Subur Makmur, Jawa Timur', 'is_active' => true]
        );
        $pakAhmad = PetaniData::firstOrCreate(
            ['name' => 'Pak Ahmad'],
            ['phone' => '081234567894', 'address' => 'Desa Sukamaju, Jawa Tengah', 'is_active' => true]
        );

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
