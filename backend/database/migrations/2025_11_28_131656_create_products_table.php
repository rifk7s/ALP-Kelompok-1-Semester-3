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
            // $table->decimal('committed_kg')->default(0); // How many kgs are already pre-ordered
            // $table->decimal('available_kg')->storedAs('stock_kg - committed_kg');; // stock_kg - committed_kg
            // $table->enum('sale_type', ['pre_order', 'ready_stock']);
            // $table->integer('lead_time_days')->nullable(); // Relevant for pre_order type
            $table->text('description');
            $table->enum('status', ['active', 'sold_out']);
            // $table->boolean('managed_by_bumdes')->default(false);
            // $table->enum('seller_type', ['bumdes', 'petani']);
            // $table->string('seller_display');
            $table->decimal('sold_kg')->default(0);
            $table->timestamps();
        });

        // Schema::table('products', function (Blueprint $table) {
        //     $table->foreignId('user_id')->constrained()->onDelete('cascade');
        //     $table->foreignId('category_id')->constrained()->onDelete('cascade');
        // });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');

        // Schema::table('products', function (Blueprint $table) {
        //     $table->dropConstrainedForeignId('user_id');
        //     // $table->dropConstrainedForeignId('created_by');
        //     // $table->dropConstrainedForeignId('category_id');
        //     // $table->dropConstrainedForeignId('seller_id');
        // });
    }
};
