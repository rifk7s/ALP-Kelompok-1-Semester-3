<?php

namespace App\Helpers;

use App\Models\Notification;

class NotificationHelper
{
    public static function sendNotification($userId, $title, $message, $type, $relatedId)
    {
        return Notification::create([
            'user_id' => $userId,
            'title' => $title,
            'message' => $message,
            'type' => $type,
            'related_id' => $relatedId,
            'is_read' => false,
        ]);
    }
}