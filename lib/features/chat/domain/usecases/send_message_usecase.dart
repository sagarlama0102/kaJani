import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/chat/data/repositories/chat_repository.dart';
import 'package:kajani/features/chat/domain/repositories/chat_repository.dart';

class SendMessageParams extends Equatable {
  final String planId;
  final String senderId;
  final String senderName;
  final String? senderProfilePicture;
  final String text;

  const SendMessageParams({
    required this.planId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.text,
  });

  @override
  List<Object?> get props => [
        planId,
        senderId,
        senderName,
        senderProfilePicture,
        text,
      ];
}

final sendMessageUsecaseProvider = Provider<SendMessageUsecase>((ref) {
  return SendMessageUsecase(
    repository: ref.read(chatRepositoryProvider),
  );
});

class SendMessageUsecase {
  final IChatRepository _repository;

  SendMessageUsecase({required IChatRepository repository})
      : _repository = repository;

  Future<void> call(SendMessageParams params) {
    return _repository.sendMessage(
      planId: params.planId,
      senderId: params.senderId,
      senderName: params.senderName,
      senderProfilePicture: params.senderProfilePicture,
      text: params.text,
    );
  }
}