import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderProfilePicture;
  final String text;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderProfilePicture,
        text,
        createdAt,
      ];
}