import 'package:kajani/features/notification/domain/entities/notification_entity.dart';

class NotificationApiModel {
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

  const NotificationApiModel({
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

  // ─── fromJson ─────────────────────────────────────────────────
  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    final plan = json['planId'] as Map<String, dynamic>?;

    return NotificationApiModel(
      id: json['_id'] as String,
      recipientId: json['recipient'] as String? ?? '',
      senderFirstName: sender?['firstName'] as String?,
      senderLastName: sender?['lastName'] as String?,
      senderProfilePicture: sender?['profilePicture'] as String?,
      type: json['type'] as String,
      planId: plan?['_id'] as String? ?? '',
      planTitle: plan?['title'] as String?,
      planCoverImage: plan?['coverImage'] as String?,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // ─── toEntity ─────────────────────────────────────────────────
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      recipientId: recipientId,
      senderFirstName: senderFirstName,
      senderLastName: senderLastName,
      senderProfilePicture: senderProfilePicture,
      type: type,
      planId: planId,
      planTitle: planTitle,
      planCoverImage: planCoverImage,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  // ─── toEntityList ─────────────────────────────────────────────
  static List<NotificationEntity> toEntityList(
      List<NotificationApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}