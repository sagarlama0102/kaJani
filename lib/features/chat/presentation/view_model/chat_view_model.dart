import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';
import 'package:kajani/features/chat/domain/usecases/get_message_stream_usecase.dart';
import 'package:kajani/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:kajani/features/chat/presentation/state/chat_state.dart';

final chatViewModelProvider =
    NotifierProvider<ChatViewModel, ChatState>(() => ChatViewModel());

class ChatViewModel extends Notifier<ChatState> {
  late final SendMessageUsecase _sendMessageUsecase;
  late final GetMessagesStreamUsecase _getMessagesStreamUsecase;
  StreamSubscription<List<ChatMessageEntity>>? _messagesSubscription;

  @override
  ChatState build() {
    _sendMessageUsecase = ref.read(sendMessageUsecaseProvider);
    _getMessagesStreamUsecase = ref.read(getMessagesStreamUsecaseProvider);
    return const ChatState();
  }

  // ─── Start listening to messages ─────────────────────────────────
  void startListening(String planId) {
    state = state.copyWith(status: ChatStatus.loading);

    // cancel any existing subscription
    _messagesSubscription?.cancel();

    _messagesSubscription = _getMessagesStreamUsecase(planId).listen(
      (messages) {
        state = state.copyWith(
          status: ChatStatus.loaded,
          messages: messages,
        );
      },
      onError: (error) {
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: error.toString(),
        );
      },
    );
  }

  // ─── Stop listening ───────────────────────────────────────────────
  void stopListening() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    state = const ChatState();
  }

  // ─── Send Message ─────────────────────────────────────────────────
  Future<void> sendMessage({
    required String planId,
    required String senderId,
    required String senderName,
    String? senderProfilePicture,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(status: ChatStatus.sending);

    try {
      await _sendMessageUsecase(
        SendMessageParams(
          planId: planId,
          senderId: senderId,
          senderName: senderName,
          senderProfilePicture: senderProfilePicture,
          text: text.trim(),
        ),
      );
      state = state.copyWith(status: ChatStatus.loaded);
    } catch (e) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ─── Reset Error ──────────────────────────────────────────────────
  void resetError() {
    state = state.copyWith(
      status: ChatStatus.initial,
      errorMessage: null,
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
  }
}