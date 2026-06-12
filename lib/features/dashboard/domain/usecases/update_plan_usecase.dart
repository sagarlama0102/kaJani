import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

class UpdatePlanParams extends Equatable {
  final String planId;
  final Map<String, dynamic> data;

  const UpdatePlanParams({required this.planId, required this.data});

  @override
  List<Object?> get props => [planId, data];
}

final updatePlanUsecaseProvider = Provider<UpdatePlanUsecase>((ref) {
  return UpdatePlanUsecase(repository: ref.read(planRepositoryProvider));
});

class UpdatePlanUsecase
    implements UsecaseWithParams<PlanEntity, UpdatePlanParams> {
  final IPlanRepository _repository;

  UpdatePlanUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PlanEntity>> call(UpdatePlanParams params) {
    return _repository.updatePlan(params.planId, params.data);
  }
}