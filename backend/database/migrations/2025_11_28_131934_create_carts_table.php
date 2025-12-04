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
        Schema::create('carts', function (Blueprint $table) {
            $table->id();
            $table->decimal('quantity_kg');
            $table->foreignId('product_id')->constrained('products')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('carts', function (Blueprint $table) {
            // $table->dropConstrainedForeignId('user_id');
            $table->dropConstrainedForeignId('product_id');
            $table->dropConstrainedForeignId('user_id');
        });

        Schema::dropIfExists('carts');
    }
};
