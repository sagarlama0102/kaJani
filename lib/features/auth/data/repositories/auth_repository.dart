import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/services/connectivity/network_info.dart';
import 'package:kajani/features/auth/data/datasources/auth_datasource.dart';
import 'package:kajani/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:kajani/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kajani/features/auth/data/models/auth_hive_model.dart';
import 'package:kajani/features/auth/domain/entities/auth_entity.dart';
import 'package:kajani/features/auth/domain/repositories/auth_repository.dart';
import 'package:kajani/features/user/domain/entities/user_entity.dart';

// ─── Provider ─────────────────────────────────────────────────────
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepositoryImpl(
    localDatasource: authDatasource,
    remoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthLocalDatasource _localDatasource;
  final IAuthRemoteDataSource _remoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required IAuthLocalDatasource localDatasource,
    required IAuthRemoteDataSource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> register(
    AuthEntity authEntity,
    UserEntity userEntity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final (authModel, userModel) = await _remoteDatasource.register(
          email: authEntity.email,
          password: authEntity.password!,
        );

        // Cache auth data locally in Hive
        final hiveModel = AuthHiveModel.fromEntity(authModel.toEntity());
        await _localDatasource.register(hiveModel);

        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Login ─────────────────────────────────────────────────────
  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final (authModel, userModel) = await _remoteDatasource.login(
          email: email,
          password: password,
        );

        // Cache auth data locally in Hive
        final hiveModel = AuthHiveModel.fromEntity(authModel.toEntity());
        await _localDatasource.register(hiveModel);

        return Right(authModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline — try local cache
      try {
        final localUser = await _localDatasource.login(email, password);
        if (localUser != null) {
          return Right(localUser.toEntity());
        }
        return const Left(
          LocalDatabaseFailure(message: 'No cached user found'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  // ─── Google Sign In ────────────────────────────────────────────
  @override
  Future<Either<Failure, AuthEntity>> signInWithGoogle() async {
    if (await _networkInfo.isConnected) {
      try {
        final (authModel, userModel) = await _remoteDatasource
            .signInWithGoogle();

        // Cache auth data locally in Hive
        final hiveModel = AuthHiveModel.fromEntity(authModel.toEntity());
        await _localDatasource.register(hiveModel);

        return Right(authModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Google sign in failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Get Current User ──────────────────────────────────────────
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      // First try local cache
      final localUser = await _localDatasource.getCurrentUser();
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // If no local user, try remote
      if (await _networkInfo.isConnected) {
        final userModel = await _remoteDatasource.getCurrentUser();
        return Right(
          AuthEntity(
            authId: userModel.id,
            email: userModel.email,
            provider: userModel.provider,
          ),
        );
      }

      return const Left(LocalDatabaseFailure(message: 'No user found'));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to get user',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ─── Logout ────────────────────────────────────────────────────
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _remoteDatasource.logout();
      await _localDatasource.logout();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ─── Upload Photo ──────────────────────────────────────────────
  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) async {
    if (await _networkInfo.isConnected) {
      try {
        final photoUrl = await _remoteDatasource.uploadPhoto(
          photo,
        ); // 👈 actually call it
        return Right(photoUrl);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> completeProfile({
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final (authModel, userModel) = await _remoteDatasource.completeProfile(
          firstName: firstName,
          lastName: lastName,
          username: username,
        );

        final hiveModel = AuthHiveModel.fromEntity(authModel.toEntity());
        await _localDatasource.register(hiveModel);

        return Right(authModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to complete profile',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
