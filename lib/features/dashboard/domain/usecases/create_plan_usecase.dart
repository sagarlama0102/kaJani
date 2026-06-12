import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

class CreatePlanParams extends Equatable {
  final String title;
  final String description;
  final String category;
  final String location;
  final String date;
  final String time;
  final bool isPublic;
  final int? maxMembers;
  final String? coverImage;

  const CreatePlanParams({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.time,
    this.isPublic = true,
    this.maxMembers,
    this.coverImage,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        category,
        location,
        date,
        time,
        isPublic,
        maxMembers,
        coverImage,
      ];
}

final createPlanUsecaseProvider = Provider<CreatePlanUsecase>((ref) {
  return CreatePlanUsecase(repository: ref.read(planRepositoryProvider));
});

class CreatePlanUsecase
    implements UsecaseWithParams<PlanEntity, CreatePlanParams> {
  final IPlanRepository _repository;

  CreatePlanUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PlanEntity>> call(CreatePlanParams params) {
    return _repository.createPlan(
      title: params.title,
      description: params.description,
      category: params.category,
      location: params.location,
      date: params.date,
      time: params.time,
      isPublic: params.isPublic,
      maxMembers: params.maxMembers,
      coverImage: params.coverImage,
    );
  }
}