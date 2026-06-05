import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? profilePicture;

  final List<String>? interests;

  const UserEntity({
    this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.email,
    required this.username,
    this.profilePicture,
    this.interests,
    
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phoneNumber,
    username,
    profilePicture,
    interests,
  ];
}
