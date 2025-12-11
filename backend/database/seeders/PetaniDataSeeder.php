<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\PetaniData;

class PetaniDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $petaniList = [
            [
                'name' => 'Pak Jono',
                'phone' => '081234567890',
                'address' => 'Desa Sumber Makmur, Jawa Timur',
                'is_active' => true,
            ],
            [
                'name' => 'Bu Rani',
                'phone' => '081234567891',
                'address' => 'Desa Tani Sejahtera, Jawa Tengah',
                'is_active' => true,
            ],
            [
                'name' => 'Pak Budi',
                'phone' => '081234567892',
                'address' => 'Desa Maju Bersama, Jawa Barat',
                'is_active' => true,
            ],
            [
                'name' => 'Bu Siti',
                'phone' => '081234567893',
                'address' => 'Desa Subur Makmur, Jawa Timur',
                'is_active' => true,
            ],
            [
                'name' => 'Pak Ahmad',
                'phone' => '081234567894',
                'address' => 'Desa Sukamaju, Jawa Tengah',
                'is_active' => true,
            ],
        ];

        foreach ($petaniList as $petani) {
            PetaniData::create($petani);
        }
    }
}
