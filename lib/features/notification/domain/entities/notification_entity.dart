import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String recipientId;
  final String? senderFirstName;
  final String? senderLastName;
  final String? senderProfilePicture;
  final String type;
  final String planId;
  final String? planTitle;
  final String? planCoverImage;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    this.senderFirstName,
    this.senderLastName,
    this.senderProfilePicture,
    required this.type,
    required this.planId,
    this.planTitle,
    this.planCoverImage,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        recipientId,
        senderFirstName,
        senderLastName,
        senderProfilePicture,
        type,
        planId,
        planTitle,
        planCoverImage,
        message,
        isRead,
        createdAt,
      ];
}