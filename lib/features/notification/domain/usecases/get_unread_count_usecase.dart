import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/notification/data/repositories/notification_repository.dart';
import 'package:kajani/features/notification/domain/repositories/notification_repository.dart';


final getUnreadCountUsecaseProvider = Provider<GetUnreadCountUsecase>((ref) {
  return GetUnreadCountUsecase(
    repository: ref.read(notificationRepositoryProvider),
  );
});

class GetUnreadCountUsecase implements UsecaseWithoutParams<int> {
  final INotificationRepository _repository;

  GetUnreadCountUsecase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, int>> call() {
    return _repository.getUnreadCount();
  }
}