import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajani/core/api/api_client.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/token_service.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/features/auth/data/datasources/auth_datasource.dart';
import 'package:kajani/features/auth/data/models/auth_api_model.dart';
import 'package:kajani/features/user/data/models/user_api_model.dart';
import 'package:kajani/core/error/exceptions.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  // ─── Traditional Register ───────────────────────────────────────
  @override
  Future<(AuthApiModel, UserApiModel)> register({
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password, 'confirmPassword': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;

      await _tokenService.saveToken(token);
      await _userSessionService.saveUserSession(
        userId: userJson['id'],
        email: userJson['email'],
        username: userJson['username'],
        firstName: userJson['firstName'],
        lastName: userJson['lastName'],
        phoneNumber: userJson['phoneNumber'],
        token: token,
        isOnboarded: false,
        profilePicture: userJson['profilePicture'],
      );

      final authModel = AuthApiModel(
        authId: userJson['id'],
        email: userJson['email'],
        provider: userJson['provider'],
      );
      final userModel = UserApiModel.fromJson(userJson);

      return (authModel, userModel);
    }

    throw Exception(response.data['message'] ?? 'Registration failed');
  }

  // ─── Traditional Login ──────────────────────────────────────────
  @override
  Future<(AuthApiModel, UserApiModel)> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final token = response.data['token'] as String;
      final userJson = response.data['data'] as Map<String, dynamic>;

      await _tokenService.saveToken(token);
      await _userSessionService.saveUserSession(
        userId: userJson['id'],
        email: userJson['email'],
        username: userJson['username'],
        firstName: userJson['firstName'],
        lastName: userJson['lastName'],
        phoneNumber: userJson['phoneNumber'],
        token: token,
        isOnboarded: userJson['isOnboarded'] ?? false,
        profilePicture: userJson['profilePicture'],
      );

      final authModel = AuthApiModel(
        authId: userJson['id'],
        email: userJson['email'],
        provider: userJson['provider'],
      );
      final userModel = UserApiModel.fromJson(userJson);

      return (authModel, userModel);
    }

    throw Exception(response.data['message'] ?? 'Login failed');
  }

  @override
  Future<(AuthApiModel, UserApiModel)> signInWithGoogle() async {
    try {
    
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();
   
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate(scopeHint: ['email', 'profile']);
  
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final googleIdToken = googleAuth.idToken;
 
      if (googleIdToken == null) {
        throw Exception('Failed to get Google ID token');
      }
      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw Exception('Sign-in timed out - connection issue'),
          );

      final firebaseIdToken = await userCredential.user?.getIdToken(true);

      if (firebaseIdToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      final response = await _apiClient.post(
        ApiEndpoints.googleSignIn,
        data: {'idToken': firebaseIdToken},
      );


      if (response.data['success'] == true) {
        final token = response.data['token'] as String;
        final userJson = response.data['data'] as Map<String, dynamic>;

        await _tokenService.saveToken(token);
        await _userSessionService.saveUserSession(
          userId: userJson['id'],
          email: userJson['email'],
          username: userJson['username'],
          firstName: userJson['firstName'],
          lastName: userJson['lastName'],
          phoneNumber: userJson['phoneNumber'],
          token: token,
          isOnboarded: userJson['isOnboarded'] ?? false,
          profilePicture: userJson['profilePicture'],
        );

        final authModel = AuthApiModel(
          authId: userJson['id'],
          email: userJson['email'],
          provider: userJson['provider'],
        );
        final userModel = UserApiModel.fromJson(userJson);

        return (authModel, userModel);
      }

      throw Exception(response.data['message'] ?? 'Google sign in failed');
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const GoogleSignInCancelledException();
      }
      throw Exception('Google sign in error: ${e.description}');
    } catch (e) {
      rethrow;
    }
  }

  // ─── Get Current User ───────────────────────────────────────────
  @override
  Future<UserApiModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.whoAmI);
    if (response.data['success'] == true) {
      final userJson = response.data['data']['user'] as Map<String, dynamic>;

      // 👈 refresh the saved session with the latest backend truth
      final currentToken = _userSessionService.getToken() ?? '';
      await _userSessionService.saveUserSession(
        userId: userJson['id'],
        email: userJson['email'],
        username: userJson['username'],
        firstName: userJson['firstName'],
        lastName: userJson['lastName'],
        phoneNumber: userJson['phoneNumber'],
        token: currentToken,
        isOnboarded: userJson['isOnboarded'] ?? false,
        profilePicture: userJson['profilePicture'],
      );

      return UserApiModel.fromJson(userJson);
    }
    throw Exception(response.data['message'] ?? 'Failed to get user');
  }

  // ─── Logout ─────────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    await _tokenService.deleteToken();
    await _userSessionService.clearUserSession();
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
  }

  // ─── Upload Photo ────────────────────────────────────────────────
  @override
  Future<String> uploadPhoto(File photo) async {
    final fileName = photo.path.split('/').last;
    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(
        photo.path,
        filename: fileName,
      ),
    });

    final response = await _apiClient.uploadFile(
      ApiEndpoints.userUploadPhoto,
      formData: formData,
    );

    if (response.data['success'] == true) {
      final profilePicture =
          response.data['data']['user']['profilePicture'] as String;

      final currentUserId = _userSessionService.getUserId() ?? '';
      final currentEmail = _userSessionService.getUserEmail() ?? '';
      final currentUsername = _userSessionService.getUsername() ?? '';
      final currentFirstName = _userSessionService.getUserFirstName() ?? '';
      final currentLastName = _userSessionService.getUserLastName() ?? '';
      final currentPhone = _userSessionService.getUserPhoneNumber();
      final currentToken = _userSessionService.getToken() ?? '';
      final currentIsOnboarded = _userSessionService.isOnboarded();

      await _userSessionService.saveUserSession(
        userId: currentUserId,
        email: currentEmail,
        username: currentUsername,
        firstName: currentFirstName,
        lastName: currentLastName,
        phoneNumber: currentPhone,
        token: currentToken,
        isOnboarded: currentIsOnboarded,
        profilePicture: profilePicture,
      );

      return profilePicture;
    }

    throw Exception(response.data['message'] ?? 'Upload failed');
  }

  @override
  Future<(AuthApiModel, UserApiModel)> completeProfile({
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.completeProfile,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
      },
    );

    if (response.data['success'] == true) {
      final token = response.data['token'] as String;
      final userJson = response.data['data'] as Map<String, dynamic>;

      await _tokenService.saveToken(token);
      await _userSessionService.saveUserSession(
        userId: userJson['id'],
        email: userJson['email'],
        username: userJson['username'],
        firstName: userJson['firstName'],
        lastName: userJson['lastName'],
        phoneNumber: userJson['phoneNumber'],
        token: token,
        isOnboarded: userJson['isOnboarded'] ?? true, //
        profilePicture: userJson['profilePicture'],
      );
      final authModel = AuthApiModel(
        authId: userJson['id'],
        email: userJson['email'],
        provider: userJson['provider'],
      );
      final userModel = UserApiModel.fromJson(userJson);

      return (authModel, userModel);
    }
    throw Exception(response.data['message'] ?? 'Failed to complete profile');
  }
}
