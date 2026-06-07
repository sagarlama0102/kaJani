import 'dart:io';

import 'package:kajani/features/auth/data/models/auth_api_model.dart';
import 'package:kajani/features/auth/data/models/auth_hive_model.dart';
import 'package:kajani/features/user/data/models/user_api_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<AuthHiveModel?> getUserById(String authId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> updateUser(AuthHiveModel user);
  Future<bool> deleteUser(String authId);

  //get email exists
  Future<bool> isEmailExists(String email);
}

// ─── Remote Datasource Interface ──────────────────────────────────
abstract interface class IAuthRemoteDataSource {
  Future<(AuthApiModel, UserApiModel)> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    String? phoneNumber,
  });

  Future<(AuthApiModel, UserApiModel)> login({
    required String email,
    required String password,
  });

  Future<(AuthApiModel, UserApiModel)> signInWithGoogle();

  Future<UserApiModel> getCurrentUser();

  Future<void> logout();

  Future<String> uploadPhoto(File photo);
}