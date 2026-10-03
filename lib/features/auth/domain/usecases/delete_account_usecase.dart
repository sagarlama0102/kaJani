import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/auth/data/repositories/auth_repository.dart';
import 'package:kajani/features/auth/domain/repositories/auth_repository.dart';

final deleteAccountUsecaseProvider = Provider<DeleteAccountUsecase>((ref) {
  return DeleteAccountUsecase(authRepository: ref.read(authRepositoryProvider));
});

class DeleteAccountUsecase implements UsecaseWithoutParams<void> {
  final IAuthRepository _authRepository;

  DeleteAccountUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, void>> call() {
    return _authRepository.deleteAccount();
  }
}