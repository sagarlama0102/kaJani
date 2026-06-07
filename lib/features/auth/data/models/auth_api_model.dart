import 'package:kajani/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String email;
  final String? password;
  final String? provider;

  const AuthApiModel({
    this.authId,
    required this.email,
    this.password,
    this.provider,
  });

  // fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json['id'] as String?,
      email: json['email'] as String,
      password: json['password'] as String?,
      provider: json['provider'] as String?,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      if (authId != null) 'id': authId,
      'email': email,
      if (password != null) 'password': password,
      if (provider != null) 'provider': provider,
    };
  }

  // toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      email: email,
      password: password,
      provider: provider,
    );
  }

  // fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      authId: entity.authId,
      email: entity.email,
      password: entity.password,
      provider: entity.provider,
    );
  }
}