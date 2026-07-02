import 'package:dartz/dartz.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/features/notification/domain/entities/notification_entity.dart';


abstract interface class INotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, int>> getUnreadCount();
}