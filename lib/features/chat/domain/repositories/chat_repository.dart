import 'package:kajani/features/chat/domain/entities/chat_list_entity.dart';
import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';

abstract interface class IChatRepository {
  Future<void> sendMessage({
    required String planId,
    required String senderId,
    required String senderName,
    String? senderProfilePicture,
    required String text,
    required String planTitle,
    String? planCoverImage,
    required List<String> memberIds,
  });

  Stream<List<ChatMessageEntity>> getMessagesStream(String planId);
  Stream<List<ChatListEntity>> getChatListStream(String userId);
}