import 'package:equatable/equatable.dart';

class PlanMemberEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String username;

  const PlanMemberEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    required this.username,
  });

  @override
  List<Object?> get props => [id, firstName, lastName, profilePicture, username];
}