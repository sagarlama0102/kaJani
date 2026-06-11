import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';

class PlanApiModel {
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

  const PlanApiModel({
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

  factory PlanApiModel.fromJson(Map<String, dynamic> json) {
    return PlanApiModel(
      planId: json['_id'] as String? ?? json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      coverImage: json['coverImage'] as String?,
      location: json['location'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
      isPublic: json['isPublic'] as bool? ?? true,
      maxMembers: json['maxMembers'] as int?,
      // creator can be a full object (populated) or just an ID string
      creatorId: json['creator'] is Map
          ? (json['creator'] as Map<String, dynamic>)['_id'] as String?
          : json['creator'] as String?,
      // members can be a list of objects (populated) or list of ID strings
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => e is Map ? e['_id'] as String : e as String)
          .toList(),
      savedBy: (json['savedBy'] as List<dynamic>?)
          ?.map((e) => e is Map ? e['_id'] as String : e as String)
          .toList(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (planId != null) 'id': planId,
      'title': title,
      'description': description,
      'category': category,
      if (coverImage != null) 'coverImage': coverImage,
      'location': location,
      'date': date,
      'time': time,
      'status': status,
      'isPublic': isPublic,
      if (maxMembers != null) 'maxMembers': maxMembers,
    };
  }

  // ─── toEntity 
  PlanEntity toEntity() {
    return PlanEntity(
      planId: planId,
      title: title,
      description: description,
      category: category,
      coverImage: coverImage,
      location: location,
      date: date,
      time: time,
      status: status,
      isPublic: isPublic,
      maxMembers: maxMembers,
      creatorId: creatorId,
      members: members,
      savedBy: savedBy,
    );
  }

  // ─── fromEntity 
  factory PlanApiModel.fromEntity(PlanEntity entity) {
    return PlanApiModel(
      planId: entity.planId,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      coverImage: entity.coverImage,
      location: entity.location,
      date: entity.date,
      time: entity.time,
      status: entity.status,
      isPublic: entity.isPublic,
      maxMembers: entity.maxMembers,
      creatorId: entity.creatorId,
      members: entity.members,
      savedBy: entity.savedBy,
    );
  }

  // ─── toEntityList 
  static List<PlanEntity> toEntityList(List<PlanApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}