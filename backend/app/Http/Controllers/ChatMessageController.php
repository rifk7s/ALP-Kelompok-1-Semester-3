<?php

namespace App\Http\Controllers;

use App\Models\Chat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

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

        Chat::where('firebase_chat_id', $chatId)->update([
            'last_message' => $request->message,
            'updated_at' => now(),
        ]);

        return response()->json([
            'status' => 'sent',
            'message_id' => $messageId,
        ]);
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
