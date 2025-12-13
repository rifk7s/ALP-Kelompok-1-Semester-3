<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    private function rebuildOrdersTableForSqlite(array $allowedStatuses): void
    {
        if (!Schema::hasTable('orders')) {
            return;
        }

        $statusListSql = implode("','", $allowedStatuses);

        DB::statement('PRAGMA foreign_keys=OFF');

        // Rebuild table to update the CHECK constraint on `status`.
        // Include all current columns on `orders`.
        DB::statement('DROP TABLE IF EXISTS orders__tmp');

        DB::statement(
            "CREATE TABLE orders__tmp (\n"
            ."    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,\n"
            ."    order_number VARCHAR NOT NULL UNIQUE,\n"
            ."    subtotal NUMERIC NOT NULL,\n"
            ."    shipping_cost NUMERIC NOT NULL,\n"
            ."    total NUMERIC NOT NULL,\n"
            ."    status TEXT NOT NULL DEFAULT 'pending_payment' CHECK (status IN ('$statusListSql')),\n"
            ."    pending_payment_at DATETIME NULL,\n"
            ."    paid_at DATETIME NULL,\n"
            ."    processing_at DATETIME NULL,\n"
            ."    shipped_at DATETIME NULL,\n"
            ."    completed_at DATETIME NULL,\n"
            ."    rejected_at DATETIME NULL,\n"
            ."    shipping_address TEXT NOT NULL,\n"
            ."    notes TEXT NULL,\n"
            ."    payment_deadline DATETIME NULL,\n"
            ."    estimated_delivery DATE NULL,\n"
            ."    buyer_id INTEGER NOT NULL,\n"
            ."    created_at DATETIME NULL,\n"
            ."    updated_at DATETIME NULL,\n"
            ."    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE\n"
            .")"
        );

        DB::statement(
            "INSERT INTO orders__tmp (id, order_number, subtotal, shipping_cost, total, status, pending_payment_at, paid_at, processing_at, shipped_at, completed_at, rejected_at, shipping_address, notes, payment_deadline, estimated_delivery, buyer_id, created_at, updated_at)\n"
            ."SELECT id, order_number, subtotal, shipping_cost, total, status, pending_payment_at, paid_at, processing_at, shipped_at, completed_at, rejected_at, shipping_address, notes, payment_deadline, estimated_delivery, buyer_id, created_at, updated_at\n"
            ."FROM orders"
        );

        DB::statement('DROP TABLE orders');
        DB::statement('ALTER TABLE orders__tmp RENAME TO orders');

        DB::statement('PRAGMA foreign_keys=ON');
    }

    public function up(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver !== 'sqlite') {
            return;
        }

        $this->rebuildOrdersTableForSqlite([
            'pending_payment',
            'paid',
            'processing',
            'shipped',
            'completed',
            'cancelled',
            'rejected',
        ]);
    }

    public function down(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver !== 'sqlite') {
            return;
        }

        $this->rebuildOrdersTableForSqlite([
            'pending_payment',
            'paid',
            'processing',
            'shipped',
            'completed',
            'cancelled',
        ]);
    }
};
