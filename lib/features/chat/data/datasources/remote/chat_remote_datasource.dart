import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/chat/data/models/chat_message_model.dart';
import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';

final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>((ref) {
  return ChatRemoteDatasource();
});

class ChatRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Collection reference for a plan's messages ───────────────────
  CollectionReference _messagesRef(String planId) {
    return _firestore
        .collection('chats')
        .doc(planId)
        .collection('messages');
  }

  // ─── Send Message ─────────────────────────────────────────────────
  Future<void> sendMessage({
    required String planId,
    required String senderId,
    required String senderName,
    String? senderProfilePicture,
    required String text,
  }) async {
    await _messagesRef(planId).add({
      'senderId': senderId,
      'senderName': senderName,
      'senderProfilePicture': senderProfilePicture,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Get Messages Stream (real-time) ──────────────────────────────
  Stream<List<ChatMessageEntity>> getMessagesStream(String planId) {
    return _messagesRef(planId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }
}