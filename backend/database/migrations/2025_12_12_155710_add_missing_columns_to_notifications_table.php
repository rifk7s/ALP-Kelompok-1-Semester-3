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
        Schema::table('notifications', function (Blueprint $table) {
            if (!Schema::hasColumn('notifications', 'title')) {
                $table->string('title')->after('id');
            }
            if (!Schema::hasColumn('notifications', 'message')) {
                $table->text('message')->after('title');
            }
            if (!Schema::hasColumn('notifications', 'type')) {
                $table->enum('type', ['order', 'payment', 'product', 'chat'])->default('order')->after('message');
            }
            if (!Schema::hasColumn('notifications', 'related_id')) {
                $table->bigInteger('related_id')->nullable()->after('type');
            }
            if (!Schema::hasColumn('notifications', 'is_read')) {
                $table->boolean('is_read')->default(false)->after('related_id');
            }
            if (!Schema::hasColumn('notifications', 'user_id')) {
                $table->foreignId('user_id')->after('is_read')->constrained('users')->onDelete('cascade');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('notifications', function (Blueprint $table) {
            $table->dropColumn(['title', 'message', 'type', 'related_id', 'is_read']);
            if (Schema::hasColumn('notifications', 'user_id')) {
                $table->dropConstrainedForeignId('user_id');
            }
        });
    }
};
