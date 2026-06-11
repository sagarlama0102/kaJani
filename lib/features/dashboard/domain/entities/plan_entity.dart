import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  final String? planId;
  final String title;
  final String description;
  final String category;
  final String? coverImage;
  final String location;
  final String date;
  final String time;
  final String status;
  final bool isPublic;
  final int? maxMembers;         
  final String? creatorId;       
  final List<String>? members;  
  final List<String>? savedBy; 

  const PlanEntity({
    this.planId,
    required this.title,
    required this.description,
    required this.category,
    this.coverImage,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    this.isPublic = true,
    this.maxMembers,
    this.creatorId,
    this.members,
    this.savedBy,
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [
    planId,
    title,
    description,
    category,
    coverImage,
    location,
    date,
    time,
    status,
    isPublic,
    maxMembers,
    creatorId,
    members,
    savedBy,
  ];
}
