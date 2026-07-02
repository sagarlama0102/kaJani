import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/notification/data/repositories/notification_repository.dart';
import 'package:kajani/features/notification/domain/repositories/notification_repository.dart';


final markAllReadUsecaseProvider = Provider<MarkAllReadUsecase>((ref) {
  return MarkAllReadUsecase(
    repository: ref.read(notificationRepositoryProvider),
  );
});

class MarkAllReadUsecase implements UsecaseWithoutParams<void> {
  final INotificationRepository _repository;

  MarkAllReadUsecase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call() {
    return _repository.markAllAsRead();
  }
}