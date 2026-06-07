import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String email;
  final String? password;
  final String? provider;

  const AuthEntity({
    this.authId,
    required this.email,
    this.password,
    this.provider,
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [
    authId,
    email,
    password,
    provider,
  ];
}
