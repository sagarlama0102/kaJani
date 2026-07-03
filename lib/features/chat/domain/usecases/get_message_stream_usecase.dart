import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/chat/data/repositories/chat_repository.dart';
import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';
import 'package:kajani/features/chat/domain/repositories/chat_repository.dart';

final getMessagesStreamUsecaseProvider =
    Provider<GetMessagesStreamUsecase>((ref) {
  return GetMessagesStreamUsecase(
    repository: ref.read(chatRepositoryProvider),
  );
});

class GetMessagesStreamUsecase {
  final IChatRepository _repository;

  GetMessagesStreamUsecase({required IChatRepository repository})
      : _repository = repository;

  Stream<List<ChatMessageEntity>> call(String planId) {
    return _repository.getMessagesStream(planId);
  }
}