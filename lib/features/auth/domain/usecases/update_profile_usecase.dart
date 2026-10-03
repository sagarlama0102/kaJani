import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/auth/data/repositories/auth_repository.dart';
import 'package:kajani/features/auth/domain/repositories/auth_repository.dart';
import 'package:kajani/features/user/domain/entities/user_entity.dart';

class UpdateProfileParams extends Equatable {
  final String? username;
  final File? photo;

  const UpdateProfileParams({this.username, this.photo});
  @override
  List<Object?> get props => [username, photo];
}

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  return UpdateProfileUsecase(authRepository: ref.read(authRepositoryProvider));
});

class UpdateProfileUsecase implements UsecaseWithParams<UserEntity, UpdateProfileParams> {
  final IAuthRepository _authRepository;

  UpdateProfileUsecase({
    required IAuthRepository authRepository
  }) 
  : _authRepository = authRepository;

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return _authRepository.updateProfile(
      username: params.username,
      photo: params.photo,
    );
  }
}