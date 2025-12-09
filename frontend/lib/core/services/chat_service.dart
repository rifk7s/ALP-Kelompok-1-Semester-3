import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'storage_service.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> signInToFirebase() async {
    try {
      final firebaseToken = await StorageService.getFirebaseToken();
      if (firebaseToken == null) {
        print('ChatService: No Firebase token found');
        return false;
      }

      print('ChatService: Signing in with Firebase token...');
      await _auth.signInWithCustomToken(firebaseToken);
      print('ChatService: Firebase sign-in success, uid: ${_auth.currentUser?.uid}');
      return true;
    } catch (e) {
      print('ChatService: Firebase sign-in error: $e');
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
    final senderName = user?['name'] ?? 'User';

    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [userId, recipientId],
        'participantNames': {
          userId: senderName,
          recipientId: recipientName,
        },
        'participantImages': {
          recipientId: recipientImage ?? '',
        },
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': userId,
      });
    } else {
      await chatRef.update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': userId,
      });
    }

    await chatRef.collection('messages').add({
      'senderId': userId,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  static Future<void> markMessagesAsRead(String chatId) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    final messagesRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('read', isEqualTo: false);

    final snapshot = await messagesRef.get();
    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
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
      final senderName = user?['name'] ?? 'User';

      await chatRef.set({
        'participants': [userId, recipientId],
        'participantNames': {
          userId: senderName,
          recipientId: recipientName,
        },
        'participantImages': {
          recipientId: recipientImage ?? '',
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': '',
      });
    }

    return chatId;
  }
}
