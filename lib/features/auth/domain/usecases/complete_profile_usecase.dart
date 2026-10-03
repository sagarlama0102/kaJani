import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/auth/data/repositories/auth_repository.dart';
import 'package:kajani/features/auth/domain/entities/auth_entity.dart';
import 'package:kajani/features/auth/domain/repositories/auth_repository.dart';

class CompleteProfileParams extends Equatable {
  final String firstName;
  final String lastName;
  final String username;

  const CompleteProfileParams({
    required this.firstName,
    required this.lastName,
    required this.username,
  });
  @override
  List<Object?> get props => [firstName, lastName, username];
}

final completeProfileUsecaseProvider = Provider<CompleteProfileUsecase>((ref) {
  return CompleteProfileUsecase(
    authRepository: ref.read(authRepositoryProvider),
  );
});

class CompleteProfileUsecase
    implements UsecaseWithParams<AuthEntity, CompleteProfileParams> {
  final IAuthRepository _authRepository;
  CompleteProfileUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(CompleteProfileParams params) {
    return _authRepository.completeProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      username: params.username,
    );
  }
}
