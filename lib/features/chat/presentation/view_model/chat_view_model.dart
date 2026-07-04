import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/chat/domain/entities/chat_list_entity.dart';
import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';
import 'package:kajani/features/chat/domain/usecases/get_chat_list_usecase.dart';
import 'package:kajani/features/chat/domain/usecases/get_message_stream_usecase.dart';
import 'package:kajani/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:kajani/features/chat/presentation/state/chat_state.dart';

final chatViewModelProvider =
    NotifierProvider<ChatViewModel, ChatState>(() => ChatViewModel());

class ChatViewModel extends Notifier<ChatState> {
  late final SendMessageUsecase _sendMessageUsecase;
  late final GetMessagesStreamUsecase _getMessagesStreamUsecase;
  late final GetChatListUsecase _getChatListUsecase;

  StreamSubscription<List<ChatMessageEntity>>? _messagesSubscription;
  StreamSubscription<List<ChatListEntity>>? _chatListSubscription;

  @override
  ChatState build() {
    _sendMessageUsecase = ref.read(sendMessageUsecaseProvider);
    _getMessagesStreamUsecase = ref.read(getMessagesStreamUsecaseProvider);
    _getChatListUsecase = ref.read(getChatListUsecaseProvider);
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

   // ─── Start listening to chat list ────────────────────────────────
  void startChatListListening(String userId) {
    _chatListSubscription?.cancel();

    _chatListSubscription = _getChatListUsecase(userId).listen(
      (chats) => state = state.copyWith(chatList: chats),
      onError: (error) => print('Chat list error: $error'),
    );
  }

  // ─── Stop listening ───────────────────────────────────────────────
  void stopListening() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    state = const ChatState();
  }
  void stopChatListListening() {
    _chatListSubscription?.cancel();
    _chatListSubscription = null;
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
          planTitle: planTitle,
          planCoverImage: planCoverImage,
          memberIds: memberIds,
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