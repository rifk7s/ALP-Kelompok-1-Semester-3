<?php

namespace App\Http\Controllers;

use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\Request;
use App\Models\Notification;

#[Group('Notifications', 'Notifikasi user', weight: 60)]
class NotificationController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', $request->user()->id)
                                    ->orderBy('created_at', 'desc')
                                    ->get();

        return response()->json($notifications);
    }

     /**
     * Get unread count
     */
    public function unreadCount(Request $request)
    {
        $count = Notification::where('user_id', $request->user()->id)
                            ->where('is_read', false)
                            ->count();

        return response()->json(['unread_count' => $count]);
    }

    /**
     * Mark notification as read
     */
    public function markAsRead(Request $request, Notification $notification)
    {
        // Verify notification belongs to user
        if ($notification->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $notification->update(['is_read' => true]);

        return response()->json(['message' => 'Notification marked as read']);
    }

    /**
     * Mark all as read
     */
    public function markAllAsRead(Request $request)
    {
        Notification::where('user_id', $request->user()->id)
                   ->where('is_read', false)
                   ->update(['is_read' => true]);

        return response()->json(['message' => 'All notifications marked as read']);
    }
}
