import 'package:kajani/features/user/domain/entities/user_entity.dart';

class UserApiModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? phoneNumber;
  final String? profilePicture;
  final List<String>? interests;
  final String? provider;
  final bool? isOnboarded;

  const UserApiModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.profilePicture,
    this.interests,
    this.provider,
    this.isOnboarded,
  });

  // fromJson
  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      id: json['id'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profilePicture: json['profilePicture'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      provider: json['provider'] as String?,
      isOnboarded: json['isOnboarded'] as bool?,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (interests != null) 'interests': interests,
      if (provider != null) 'provider': provider,
      if (isOnboarded != null) 'isOnboarded': isOnboarded,
    };
  }

  // toEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      interests: interests,
    );
  }

  // fromEntity
  factory UserApiModel.fromEntity(UserEntity entity) {
    return UserApiModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      username: entity.username,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
      interests: entity.interests,
    );
  }
}

