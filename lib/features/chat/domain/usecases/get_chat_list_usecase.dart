import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/chat/data/repositories/chat_repository.dart';
import 'package:kajani/features/chat/domain/entities/chat_list_entity.dart';
import 'package:kajani/features/chat/domain/repositories/chat_repository.dart';

final getChatListUsecaseProvider = Provider<GetChatListUsecase>((ref) {
  return GetChatListUsecase(repository: ref.read(chatRepositoryProvider));
});

class GetChatListUsecase {
  final IChatRepository _repository;

  GetChatListUsecase({required IChatRepository repository})
      : _repository = repository;

  Stream<List<ChatListEntity>> call(String userId) {
    return _repository.getChatListStream(userId);
  }
}