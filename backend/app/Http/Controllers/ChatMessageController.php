<?php

namespace App\Http\Controllers;

use Dedoc\Scramble\Attributes\Group;
use App\Models\Chat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Services\NotificationService;

#[Group('Chat', 'Kirim dan kelola pesan chat', weight: 70)]
class ChatMessageController extends Controller
{
    protected $db;

    public function __construct()
    {
        $this->db = app('firebase.database');
    }

    public function sendMessage(Request $request)
    {
        $request->validate([
            'chat_id' => 'required|string',
            'message' => 'required|string',
        ]);

        $chatId = $request->chat_id;
        $userId = Auth::id();

        $messageRef = $this->db->getReference("chats/{$chatId}/messages")->push();
        $messageId = $messageRef->getKey();

        $messageRef->set([
            'senderId'  => $userId,
            'text'      => $request->message,
            'timestamp' => now()->timestamp,
        ]);

        // Chat::where('firebase_chat_id', $chatId)->update([
        //     'last_message' => $request->message,
        //     'updated_at' => now(),
        // ]);
        /*
            F
        */
        // fetch chat info for creating notification requirements
        $chat= Chat::where('firebase_chat_id', $chatId)->first();
        
        $chat->update([
            'last_message' => $request->message,
            'updated_at' => now(),
        ]);

        // Send notification to receiver
        $receiverId = $chat->user1_id === $userId ? $chat->user2_id : $chat->user1_id;
        $senderName = Auth::user()->name;
        
        \Log::info('Sending chat notification', [
            'recipient_id' => $receiverId,
            'sender_name' => $senderName,
            'message' => $request->message,
            'chat_id' => $chat->id
        ]);
        
        NotificationService::notifyChatMessage(
            $receiverId,
            $senderName,
            $request->message,
            $chat->id
        );

        return response()->json([
            'status' => 'sent',
            'message_id' => $messageId,
        ]);
    }

    public function notifyMessage(Request $request)
    {
        $request->validate([
            'recipient_id' => 'required|integer',
            'message' => 'required|string',
            'chat_id' => 'nullable|string',
        ]);

        $senderName = Auth::user()->name;
        
        NotificationService::notifyChatMessage(
            $request->recipient_id,
            $senderName,
            $request->message,
            $request->chat_id
        );

        return response()->json(['status' => 'notification sent']);
    }

    public function getMessages($chatId)
    {
        $messages = $this->db
            ->getReference("chats/{$chatId}/messages")
            ->orderByChild('timestamp')
            ->getValue();

        return response()->json($messages ?? []);
    }

    public function deleteMessage($chatId, $messageId)
    {
        $this->db->getReference("chats/{$chatId}/messages/{$messageId}")->remove();

        return response()->json(['status' => 'deleted']);
    }
}
