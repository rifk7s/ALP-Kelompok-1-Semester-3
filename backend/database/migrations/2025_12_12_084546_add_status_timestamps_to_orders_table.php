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
        Schema::table('orders', function (Blueprint $table) {
            $table->timestamp('pending_payment_at')->nullable()->after('status');
            $table->timestamp('paid_at')->nullable()->after('pending_payment_at');
            $table->timestamp('processing_at')->nullable()->after('paid_at');
            $table->timestamp('shipped_at')->nullable()->after('processing_at');
            $table->timestamp('completed_at')->nullable()->after('shipped_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'pending_payment_at',
                'paid_at',
                'processing_at',
                'shipped_at',
                'completed_at'
            ]);
        });
    }
};
