<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Update existing orders to set appropriate timestamps based on their status
        $orders = DB::table('orders')->get();
        
        foreach ($orders as $order) {
            $updates = [];
            
            // Set pending_payment_at for all orders (they all started here)
            if ($order->pending_payment_at === null) {
                $updates['pending_payment_at'] = $order->created_at;
            }
            
            // Set timestamps based on current status
            switch ($order->status) {
                case 'completed':
                    if ($order->completed_at === null) {
                        $updates['completed_at'] = $order->updated_at;
                    }
                    if ($order->shipped_at === null) {
                        $updates['shipped_at'] = $order->updated_at;
                    }
                    if ($order->processing_at === null) {
                        $updates['processing_at'] = $order->updated_at;
                    }
                    if ($order->paid_at === null) {
                        $updates['paid_at'] = $order->updated_at;
                    }
                    break;
                    
                case 'shipped':
                    if ($order->shipped_at === null) {
                        $updates['shipped_at'] = $order->updated_at;
                    }
                    if ($order->processing_at === null) {
                        $updates['processing_at'] = $order->updated_at;
                    }
                    if ($order->paid_at === null) {
                        $updates['paid_at'] = $order->updated_at;
                    }
                    break;
                    
                case 'processing':
                    if ($order->processing_at === null) {
                        $updates['processing_at'] = $order->updated_at;
                    }
                    if ($order->paid_at === null) {
                        $updates['paid_at'] = $order->updated_at;
                    }
                    break;
                    
                case 'paid':
                    if ($order->paid_at === null) {
                        $updates['paid_at'] = $order->updated_at;
                    }
                    break;
            }
            
            if (!empty($updates)) {
                DB::table('orders')
                    ->where('id', $order->id)
                    ->update($updates);
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // No need to reverse - timestamps are useful historical data
    }
};
