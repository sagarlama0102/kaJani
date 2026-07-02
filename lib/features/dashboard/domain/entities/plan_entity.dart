import 'package:equatable/equatable.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_memeber_entity.dart';

class PlanEntity extends Equatable {
  final String? planId;
  final String title;
  final String description;
  final String category;
  final String? coverImage;
  final String location;
  final String date;
  final String time;
  final String? endTime;
  final String? endDate;
  final String status;
  final bool isPublic;
  final int? maxMembers;         
  final String? creatorId;       
  final List<String>? members;  
  final List<String>? savedBy;
  final List<PlanMemberEntity>? memberDetails; 

  const PlanEntity({
    this.planId,
    required this.title,
    required this.description,
    required this.category,
    this.coverImage,
    required this.location,
    required this.date,
    required this.time,
    this.endTime,
    this.endDate,
    required this.status,
    this.isPublic = true,
    this.maxMembers,
    this.creatorId,
    this.members,
    this.savedBy,
    this.memberDetails
    
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
    endTime,
    endDate,
    status,
    isPublic,
    maxMembers,
    creatorId,
    members,
    savedBy,
    memberDetails
  ];
}
