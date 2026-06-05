import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/auth/data/repositories/auth_repository.dart';
import 'package:kajani/features/auth/domain/entities/auth_entity.dart';
import 'package:kajani/features/auth/domain/repositories/auth_repository.dart';
import 'package:kajani/features/user/domain/entities/user_entity.dart';

class RegisterUsecaseParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String password;
  final String? phoneNumber;

  const RegisterUsecaseParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.password,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        username,
        password,
        phoneNumber,
      ];
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(authRepository: ref.read(authRepositoryProvider));
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final authEntity = AuthEntity(
      email: params.email,
      password: params.password,
      provider: 'traditional',
    );

    final userEntity = UserEntity(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      username: params.username,
      phoneNumber: params.phoneNumber,
    );

    return _authRepository.register(authEntity, userEntity);
  }
}