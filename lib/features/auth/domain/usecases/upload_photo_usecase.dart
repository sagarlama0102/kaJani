import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/auth/data/repositories/auth_repository.dart';
import 'package:kajani/features/auth/domain/repositories/auth_repository.dart';

class UploadPhotoParams extends Equatable {
  final File photo;

  const UploadPhotoParams({required this.photo});

  @override
  List<Object?> get props => [photo];
}

final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  return UploadPhotoUsecase(authRepository: ref.read(authRepositoryProvider));
});

class UploadPhotoUsecase
    implements UsecaseWithParams<String, UploadPhotoParams> {
  final IAuthRepository _authRepository;

  UploadPhotoUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, String>> call(UploadPhotoParams params) {
    return _authRepository.uploadPhoto(params.photo);
  }
}