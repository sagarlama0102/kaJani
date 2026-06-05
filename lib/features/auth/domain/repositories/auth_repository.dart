import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/features/auth/domain/entities/auth_entity.dart';
import 'package:kajani/features/user/domain/entities/user_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity, UserEntity userEntity,);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> signInWithGoogle();
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, String>> uploadPhoto(File photo);
}
