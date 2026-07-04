import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kajani/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:kajani/features/chat/domain/entities/chat_list_entity.dart';
import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';
import 'package:kajani/features/chat/domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return ChatRepositoryImpl(
    remoteDatasource: ref.read(chatRemoteDatasourceProvider),
  );
});

class ChatRepositoryImpl implements IChatRepository {
  final ChatRemoteDatasource _remoteDatasource;

  ChatRepositoryImpl({required ChatRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
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
    await _remoteDatasource.sendMessage(
      planId: planId,
      senderId: senderId,
      senderName: senderName,
      senderProfilePicture: senderProfilePicture,
      text: text,
      planTitle: planTitle,
      planCoverImage: planCoverImage,
      memberIds: memberIds,
    );
  }

  @override
  Stream<List<ChatMessageEntity>> getMessagesStream(String planId) {
    return _remoteDatasource.getMessagesStream(planId);
  }
  @override
  Stream<List<ChatListEntity>> getChatListStream(String userId) {
    return _remoteDatasource.getChatListStream(userId);
}
}