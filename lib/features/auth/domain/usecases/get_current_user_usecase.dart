import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/auth/data/repositories/auth_repository.dart';
import 'package:kajani/features/auth/domain/entities/auth_entity.dart';
import 'package:kajani/features/auth/domain/repositories/auth_repository.dart';

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(
    authRepository: ref.read(authRepositoryProvider),
  );
});

class GetCurrentUserUsecase implements UsecaseWithoutParams<AuthEntity> {
  final IAuthRepository _authRepository;

  GetCurrentUserUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return _authRepository.getCurrentUser();
  }
}