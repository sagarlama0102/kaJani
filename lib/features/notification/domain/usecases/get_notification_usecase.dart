import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/notification/data/repositories/notification_repository.dart';
import 'package:kajani/features/notification/domain/entities/notification_entity.dart';
import 'package:kajani/features/notification/domain/repositories/notification_repository.dart';


final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>((ref) {
  return GetNotificationsUsecase(
    repository: ref.read(notificationRepositoryProvider),
  );
});

class GetNotificationsUsecase implements UsecaseWithoutParams<List<NotificationEntity>> {
  final INotificationRepository _repository;

  GetNotificationsUsecase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call() {
    return _repository.getNotifications();
  }
}