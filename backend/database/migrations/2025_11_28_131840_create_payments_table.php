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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->decimal('amount', 12, 2);
            $table->string('proof_image');
            $table->enum('status', ['pending', 'verified', 'rejected'])->default('pending');
            $table->text('notes')->nullable();
            $table->foreignId('order_id')->constrained('orders')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropConstrainedForeignId('order_id');
        });

        Schema::dropIfExists('payments');
    }
};
