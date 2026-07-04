import 'package:equatable/equatable.dart';
import 'package:kajani/features/chat/domain/entities/chat_list_entity.dart';
import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  sending,
  error,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessageEntity> messages;
  final List<ChatListEntity> chatList;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.chatList = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageEntity>? messages,
    List<ChatListEntity>? chatList,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      chatList: chatList ?? this.chatList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, chatList, errorMessage];
}