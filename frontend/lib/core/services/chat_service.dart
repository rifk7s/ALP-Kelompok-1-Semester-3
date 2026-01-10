import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/core/storage/storage_service.dart';
import 'package:frontend/core/network/api_config.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> signInToFirebase() async {
    try {
      // Check if already signed in
      if (_auth.currentUser != null) {
        debugPrint('ChatService: Already signed in');
        return true;
      }

      final firebaseToken = await StorageService.getFirebaseToken();
      if (firebaseToken == null) {
        debugPrint('ChatService: No Firebase token found');
        return false;
      }

      await _auth.signInWithCustomToken(firebaseToken);
      debugPrint('ChatService: Successfully signed in to Firebase');
      return true;
    } catch (e) {
      debugPrint('ChatService: Firebase sign-in error: $e');
      // If token is invalid, clear it so it can be refreshed on next login
      if (e.toString().contains('invalid-custom-token')) {
        debugPrint('ChatService: Clearing invalid token');
        await StorageService.deleteFirebaseToken();
      }
      return false;
    }
  }

  static Future<void> signOutFromFirebase() async {
    await _auth.signOut();
  }

  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  static String generateChatId(String id1, String id2) {
    final ids = [id1, id2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  static Future<Map<String, dynamic>?> getChatDocument(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting chat document: $e');
      return null;
    }
  }

  static Stream<QuerySnapshot> getChatRooms() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  static Future<void> sendMessage({
    required String chatId,
    required String text,
    required String recipientId,
    required String recipientName,
    String? recipientImage,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    final user = await StorageService.getUser();
    final senderName = user?['name'] ?? 'Pengguna';

    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [userId, recipientId],
        'participantNames': {userId: senderName, recipientId: recipientName},
        'participantImages': {recipientId: recipientImage ?? ''},
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': userId,
        'unreadCounts': {userId: 0, recipientId: 1},
      });
    } else {
      await chatRef.update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': userId,
        'unreadCounts.$recipientId': FieldValue.increment(1),
      });
    }

    await chatRef.collection('messages').add({
      'senderId': userId,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Send notification to recipient via backend
    try {
      final token = await StorageService.getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/chat/notify'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'recipient_id': recipientId,
            'message': text,
            'chat_id': chatId,
          }),
        );
      }
    } catch (e) {
      debugPrint('Failed to send chat notification: $e');
    }
  }

  static Future<void> markMessagesAsRead(String chatId) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    try {
      // Get all unread messages first, then filter client-side
      final messagesRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('read', isEqualTo: false);

      final snapshot = await messagesRef.get();
      final batch = _firestore.batch();
      int markedCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Only mark messages from OTHER users as read
        if (data['senderId'] != userId) {
          batch.update(doc.reference, {'read': true});
          markedCount++;
        }
      }

      if (markedCount > 0) {
        await batch.commit();
      }

      await _firestore.collection('chats').doc(chatId).set({
        'unreadCounts': {userId: 0},
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('markMessagesAsRead error: $e');
    }
  }

  static Future<String?> getOrCreateChat({
    required String recipientId,
    required String recipientName,
    String? recipientImage,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    final chatId = generateChatId(userId, recipientId);
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      final user = await StorageService.getUser();
      final senderName = user?['name'] ?? 'Pengguna';

      await chatRef.set({
        'participants': [userId, recipientId],
        'participantNames': {userId: senderName, recipientId: recipientName},
        'participantImages': {recipientId: recipientImage ?? ''},
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': '',
        'unreadCounts': {userId: 0, recipientId: 0},
      });
    }

    return chatId;
  }

  // Typing indicator methods
  static Future<void> setTyping(String chatId, bool isTyping) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore.collection('chats').doc(chatId).update({
        'typing.$userId': isTyping,
      });
    } catch (e) {
      debugPrint('setTyping error: $e');
    }
  }

  static Stream<Map<String, bool>> getTypingStream(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      if (data == null || data['typing'] == null) {
        return <String, bool>{};
      }
      final typing = data['typing'] as Map<String, dynamic>;
      return typing.map((key, value) => MapEntry(key, value as bool));
    });
  }

  static bool isOtherUserTyping(Map<String, bool> typingStatus) {
    final userId = getCurrentUserId();
    if (userId == null) return false;

    // Check if any other user is typing
    for (final entry in typingStatus.entries) {
      if (entry.key != userId && entry.value == true) {
        return true;
      }
    }
    return false;
  }
}
