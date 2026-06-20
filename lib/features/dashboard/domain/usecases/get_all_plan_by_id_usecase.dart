import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

class GetPlanByIdParams extends Equatable {
  final String planId;
  const GetPlanByIdParams({required this.planId});

  @override
  List<Object?> get props => [planId];
}

final getPlanByIdUsecaseProvider = Provider<GetPlanByIdUsecase>((ref) {
  return GetPlanByIdUsecase(repository: ref.read(planRepositoryProvider));
});

class GetPlanByIdUsecase
    implements UsecaseWithParams<PlanEntity, GetPlanByIdParams> {
  final IPlanRepository _repository;

  GetPlanByIdUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PlanEntity>> call(GetPlanByIdParams params) {
    return _repository.getPlanById(params.planId);
  }
}