import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/notification/data/repositories/notification_repository.dart';
import 'package:kajani/features/notification/domain/repositories/notification_repository.dart';


class MarkAsReadParams extends Equatable {
  final String notificationId;
  const MarkAsReadParams({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

final markAsReadUsecaseProvider = Provider<MarkAsReadUsecase>((ref) {
  return MarkAsReadUsecase(
    repository: ref.read(notificationRepositoryProvider),
  );
});

class MarkAsReadUsecase implements UsecaseWithParams<void, MarkAsReadParams> {
  final INotificationRepository _repository;

  MarkAsReadUsecase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) {
    return _repository.markAsRead(params.notificationId);
  }
}