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
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->decimal('quantity_kg', 10, 2);
            $table->decimal('price_per_kg', 12, 2);
            $table->decimal('subtotal', 12, 2);
            $table->foreignId('order_id')->constrained('orders')->onDelete('cascade');
            $table->foreignId('product_id')->constrained('products')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('order_items', function (Blueprint $table) {
            $table->dropConstrainedForeignId('order_id');
            $table->dropConstrainedForeignId('product_id');
        });

        Schema::dropIfExists('order_items');
    }
};
