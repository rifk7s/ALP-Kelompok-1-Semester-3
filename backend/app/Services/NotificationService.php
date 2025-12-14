<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;

class NotificationService
{
    /**
     * Create notification for new order (for BUMDes)
     */
    public static function notifyNewOrder($order)
    {
        // Get all bumdes users
        $bumdesUsers = User::where('role', 'bumdes')->get();
        
        foreach ($bumdesUsers as $user) {
            Notification::create([
                'user_id' => $user->id,
                'title' => 'Pesanan Baru',
                'message' => "Pesanan baru #{$order->order_number} telah dibuat",
                'type' => 'order',
                'related_id' => $order->id,
                'is_read' => false,
            ]);
        }
    }

    /**
     * Create notification for order status change
     */
    public static function notifyOrderStatusChange($order, $oldStatus, $newStatus)
    {
        // For buyer: notify on all status changes except to 'completed'
        if ($newStatus !== 'completed') {
            $statusMessages = [
                'paid' => 'Pembayaran Anda telah dikonfirmasi',
                'processing' => 'Pesanan Anda sedang dikemas',
                'shipped' => 'Pesanan Anda sedang dalam pengiriman',
                'rejected' => 'Pesanan Anda ditolak',
            ];

            if (isset($statusMessages[$newStatus])) {
                Notification::create([
                    'user_id' => $order->buyer_id,
                    'title' => 'Status Pesanan Diperbarui',
                    'message' => "{$statusMessages[$newStatus]} (#{$order->order_number})",
                    'type' => 'order',
                    'related_id' => $order->id,
                    'is_read' => false,
                ]);
            }
        }

        // For BUMDes: notify when order is completed
        if ($newStatus === 'completed') {
            $bumdesUsers = User::where('role', 'bumdes')->get();
            
            foreach ($bumdesUsers as $user) {
                Notification::create([
                    'user_id' => $user->id,
                    'title' => 'Pesanan Diselesaikan',
                    'message' => "Pesanan #{$order->order_number} telah diselesaikan oleh pembeli",
                    'type' => 'order',
                    'related_id' => $order->id,
                    'is_read' => false,
                ]);
            }
        }
    }

    /**
     * Create notification for chat message
     */
    public static function notifyChatMessage($recipientId, $senderName, $message, $chatId = null)
    {
        Notification::create([
            'user_id' => $recipientId,
            'title' => 'Pesan Baru dari ' . $senderName,
            'message' => substr($message, 0, 50) . (strlen($message) > 50 ? '...' : ''),
            'type' => 'chat',
            'related_id' => $chatId,
            'is_read' => false,
        ]);
    }
}
