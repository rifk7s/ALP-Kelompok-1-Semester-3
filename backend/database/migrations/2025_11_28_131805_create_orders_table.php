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
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique();
            $table->decimal('subtotal', 12, 2);
            $table->decimal('shipping_cost', 12, 2);
            $table->decimal('total', 12, 2);
            $table->enum('status', ['pending_payment', 'paid', 'processing', 'shipped', 'completed', 'cancelled'])->default('pending_payment');
            $table->text('shipping_address');
            $table->dateTime('payment_deadline')->nullable();
            $table->date('estimated_delivery')->nullable();
            $table->foreignId('buyer_id')->constrained('users')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropConstrainedForeignId('buyer_id');
        });

        Schema::dropIfExists('orders');
    }
};
