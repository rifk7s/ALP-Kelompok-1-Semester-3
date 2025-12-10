<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('product_contributions', function (Blueprint $table) {
            $table->id();
            $table->decimal('contributed_kg', 10, 2);
            $table->decimal('remaining_kg', 10, 2);
            $table->date('entry_date');
            $table->date('harvest_date');
            $table->timestamps();
            //Git branch saya brokey

            // Foreign keys
            $table->foreignId('product_id')->constrained('products')->onDelete('cascade');
            $table->foreignId('petani_id')->constrained('petani_data')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('product_contributions', function (Blueprint $table) {
            $table->dropConstrainedForeignId('product_id');
            $table->dropConstrainedForeignId('petani_id');
        });

        Schema::dropIfExists('product_contributions');
    }
};
