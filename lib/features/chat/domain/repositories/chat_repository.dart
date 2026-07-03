import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';

abstract interface class IChatRepository {
  Future<void> sendMessage({
    required String planId,
    required String senderId,
    required String senderName,
    String? senderProfilePicture,
    required String text,
  });

  Stream<List<ChatMessageEntity>> getMessagesStream(String planId);
}