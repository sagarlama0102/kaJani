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

  final String email;
  final String password;


  const RegisterUsecaseParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [

        email,
        password,
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
      email: params.email,
    );

    return _authRepository.register(authEntity, userEntity);
  }
}