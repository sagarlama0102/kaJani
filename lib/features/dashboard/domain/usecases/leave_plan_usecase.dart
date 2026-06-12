import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

class LeavePlanParams extends Equatable {
  final String planId;
  const LeavePlanParams({required this.planId});

  @override
  List<Object?> get props => [planId];
}

final leavePlanUsecaseProvider = Provider<LeavePlanUsecase>((ref) {
  return LeavePlanUsecase(repository: ref.read(planRepositoryProvider));
});

class LeavePlanUsecase
    implements UsecaseWithParams<PlanEntity, LeavePlanParams> {
  final IPlanRepository _repository;

  LeavePlanUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PlanEntity>> call(LeavePlanParams params) {
    return _repository.leavePlan(params.planId);
  }
}