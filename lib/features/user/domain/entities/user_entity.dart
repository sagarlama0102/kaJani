import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? id;
  final String email;
  final String? username;


  const UserEntity({
    this.id,
    required this.email,
     this.username,
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [
    id,
    email,
    username,

  ];
}
