<?php

namespace App\Http\Controllers;
use App\Models\Chat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ChatListController extends Controller
{
    public function getChatList()
    {
        $userId = Auth::id();

        $chats = Chat::where('user1_id', $userId)
                    ->orWhere('user2_id', $userId)
                    ->with(['user1:id,name,profile_photo', 'user2:id,name,profile_photo'])
                    ->orderBy('updated_at', 'desc')
                    ->get()
                    ->map(function ($chat) use ($userId) {
                        $other = $chat->otherUser($userId);
                        return [
                            'id' => $chat->id,
                            'firebase_chat_id' => $chat->firebase_chat_id,
                            'other_user' => [
                                'id' => $other->id,
                                'name' => $other->name,
                                'profile_photo' => $other->profile_photo ?? null,
                            ],
                            'last_message' => $chat->last_message,
                            'updated_at' => $chat->updated_at->toDateTimeString(),
                        ];
                    });

        return response()->json($chats);
    }

    public function createChat(Request $request)
    {
        $userId = Auth::id();
        $otherUserId = (int) $request->other_user_id;

        if ($userId === $otherUserId) {
            return response()->json(['error' => 'Cannot chat with yourself'], 422);
        }

        $chat = Chat::where(function ($q) use ($userId, $otherUserId) {
            $q->where('user1_id', $userId)->where('user2_id', $otherUserId);
        })->orWhere(function ($q) use ($userId, $otherUserId) {
            $q->where('user1_id', $otherUserId)->where('user2_id', $userId);
        })->first();

        if ($chat) {
            return response()->json($chat);
        }

        $firebaseId = 'chat_' . $userId . '_' . $otherUserId;

        $chat = Chat::create([
            'user1_id' => $userId,
            'user2_id' => $otherUserId,
            'firebase_chat_id' => $firebaseId,
        ]);

        return response()->json($chat, 201);
    }
    public function deleteChat($chatId)
    {
        $userId = Auth::id();

        $chat = Chat::where('id', $chatId)
                    ->where(function ($q) use ($userId) {
                        $q->where('user1_id', $userId)
                        ->orWhere('user2_id', $userId);
                    })->first();

        if (! $chat) {
            return response()->json(['error' => 'Chat not found'], 404);
        }

        $chat->delete();

        return response()->json(['message' => 'Chat deleted successfully'], 204);
    }
}
