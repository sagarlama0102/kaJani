import 'package:kajani/features/user/domain/entities/user_entity.dart';

class UserApiModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? username;
  final String? profilePicture;
  final String? provider;
  final bool? isOnboarded;

  const UserApiModel({
    this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.username,
    this.profilePicture,
    this.provider,
    this.isOnboarded,
  });

  // fromJson
  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      id: json['id'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String,
      username: json['username'] as String?,
      profilePicture: json['profilePicture'] as String?,
      provider: json['provider'] as String?,
      isOnboarded: json['isOnboarded'] as bool?,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'email': email,
      if (username != null) 'username': username,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (provider != null) 'provider': provider,
      if (isOnboarded != null) 'isOnboarded': isOnboarded,
    };
  }

  // toEntity
  UserEntity toEntity() {
    return UserEntity(id: id, email: email, username: username);
  }

  // fromEntity
  factory UserApiModel.fromEntity(UserEntity entity) {
    return UserApiModel(
      id: entity.id,
      email: entity.email,
      username: entity.username,
    );
  }
}
