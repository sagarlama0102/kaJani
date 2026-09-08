import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:kajani/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:kajani/features/auth/domain/usecases/login_usecase.dart';
import 'package:kajani/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kajani/features/auth/domain/usecases/register_usecase.dart';
import 'package:kajani/features/auth/domain/usecases/upload_photo_usecase.dart';
import 'package:kajani/features/auth/presentation/state/auth_state.dart';
import 'package:kajani/features/auth/domain/usecases/complete_profile_usecase.dart'; //add

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final CompleteProfileUsecase _completeProfileUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final GoogleSignInUsecase _googleSignInUsecase;
  late final UploadPhotoUsecase _uploadPhotoUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _completeProfileUsecase = ref.read(completeProfileUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _googleSignInUsecase = ref.read(googleSignInUsecaseProvider);
    _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);
    return AuthState();
  }

  // ─── Register ──────────────────────────────────────────────────
  Future<void> register({
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  // ─── Complete Profile (Name Capture step) ────────────────────────
Future<void> completeProfile({
  required String firstName,
  required String lastName,
  required String username,
}) async {
  state = state.copyWith(status: AuthStatus.loading);

  final result = await _completeProfileUsecase(
    CompleteProfileParams(
      firstName: firstName,
      lastName: lastName,
      username: username,
    ),
  );

  result.fold(
    (failure) => state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: failure.message,
    ),
    (authEntity) => state = state.copyWith(
      status: AuthStatus.authenticated, 
      authEntity: authEntity,
    ),
  );
}

  // ─── Login ─────────────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
    );
  }

  // ─── Google Sign In ────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _googleSignInUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  // ─── Get Current User ──────────────────────────────────────────
  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
    );
  }

  // ─── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        authEntity: null,
      ),
    );
  }

  // ─── Upload Photo ──────────────────────────────────────────────
  Future<void> uploadPhoto(File photo) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _uploadPhotoUsecase(UploadPhotoParams(photo: photo));

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (url) => state = state.copyWith(
        status: AuthStatus.loaded,
        uploadedPhotoUrl: url,
      ),
    );
  }

  // ─── Reset Error ───────────────────────────────────────────────
  void resetError() {
    state = state.copyWith(status: AuthStatus.initial, errorMessage: null);
  }
}
