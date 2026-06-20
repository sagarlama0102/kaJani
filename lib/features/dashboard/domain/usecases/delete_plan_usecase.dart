import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

class DeletePlanParams extends Equatable {
  final String planId;
  const DeletePlanParams({required this.planId});

  @override
  List<Object?> get props => [planId];
}

final deletePlanUsecaseProvider = Provider<DeletePlanUsecase>((ref) {
  return DeletePlanUsecase(repository: ref.read(planRepositoryProvider));
});

class DeletePlanUsecase implements UsecaseWithParams<bool, DeletePlanParams> {
  final IPlanRepository _repository;

  DeletePlanUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeletePlanParams params) {
    return _repository.deletePlan(params.planId);
  }
}