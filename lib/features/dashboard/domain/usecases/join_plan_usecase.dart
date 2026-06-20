import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

class JoinPlanParams extends Equatable {
  final String planId;
  const JoinPlanParams({required this.planId});

  @override
  List<Object?> get props => [planId];
}

final joinPlanUsecaseProvider = Provider<JoinPlanUsecase>((ref) {
  return JoinPlanUsecase(repository: ref.read(planRepositoryProvider));
});

class JoinPlanUsecase implements UsecaseWithParams<PlanEntity, JoinPlanParams> {
  final IPlanRepository _repository;

  JoinPlanUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PlanEntity>> call(JoinPlanParams params) {
    return _repository.joinPlan(params.planId);
  }
}