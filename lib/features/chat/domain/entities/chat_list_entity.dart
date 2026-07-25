import 'package:equatable/equatable.dart';

class ChatListEntity extends Equatable {
  final String planId;
  final String planTitle;
  final String? planCoverImage;
  final String lastMessage;
  final String lastMessageSender;
  final DateTime lastMessageTime;
  final List<String> members;

  const ChatListEntity({
    required this.planId,
    required this.planTitle,
    this.planCoverImage,
    required this.lastMessage,
    required this.lastMessageSender,
    required this.lastMessageTime,
    required this.members,
  });

  @override
  List<Object?> get props => [
        planId,
        planTitle,
        planCoverImage,
        lastMessage,
        lastMessageSender,
        lastMessageTime,
        members,
      ];
}