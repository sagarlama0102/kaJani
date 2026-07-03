import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderProfilePicture;
  final String text;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.text,
    required this.createdAt,
  });

  // ─── fromFirestore ────────────────────────────────────────────
  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      senderProfilePicture: data['senderProfilePicture'] as String?,
      text: data['text'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // ─── toFirestore ──────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderProfilePicture': senderProfilePicture,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ─── toEntity ─────────────────────────────────────────────────
  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderProfilePicture: senderProfilePicture,
      text: text,
      createdAt: createdAt,
    );
  }

  // ─── toEntityList ─────────────────────────────────────────────
  static List<ChatMessageEntity> toEntityList(List<ChatMessageModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}