import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/chat/data/models/chat_message_model.dart';
import 'package:kajani/features/chat/domain/entities/chat_list_entity.dart';
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
    required String planTitle,
    String? planCoverImage,
    required List<String> memberIds,
  }) async {
    await _messagesRef(planId).add({
      'senderId': senderId,
      'senderName': senderName,
      'senderProfilePicture': senderProfilePicture,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update parent chat document
    await _firestore.collection('chats').doc(planId).set({
      'planId': planId,
      'planTitle': planTitle,
      'planCoverImage': planCoverImage,
      'lastMessage': text,
      'lastMessageSender': senderName,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'members': memberIds,
    }, SetOptions(merge: true));
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
  // ─── Get Chat List Stream ─────────────────────────────────────────
  Stream<List<ChatListEntity>> getChatListStream(String userId) {
    return _firestore
        .collection('chats')
        .where('members', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatListEntity(
          planId: data['planId'] as String,
          planTitle: data['planTitle'] as String,
          planCoverImage: data['planCoverImage'] as String?,
          lastMessage: data['lastMessage'] as String,
          lastMessageSender: data['lastMessageSender'] as String,
          lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
          members: List<String>.from(data['members'] ?? []),
        );
      }).toList();
    });
  }
}