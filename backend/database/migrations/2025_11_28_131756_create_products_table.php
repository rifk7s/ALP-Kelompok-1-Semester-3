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
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('variety');
            $table->date('harvest_date');
            $table->integer('storage_days');
            $table->decimal('price_per_kg');
            $table->decimal('stock_kg');
            $table->decimal('sold_kg')->default(0);
            $table->text('description');
            $table->enum('status', ['active', 'sold_out']);

            $table->timestamps();
        });

        Schema::table('products', function (Blueprint $table) {
            $table->foreignId('category_id')->constrained('categories')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');

        Schema::table('products', function (Blueprint $table) {
            // $table->dropConstrainedForeignId('user_id');
            $table->dropConstrainedForeignId('category_id');
        });
    }
};
