import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

final getSavedPlansUsecaseProvider = Provider<GetSavedPlansUsecase>((ref) {
  return GetSavedPlansUsecase(repository: ref.read(planRepositoryProvider));
});

class GetSavedPlansUsecase implements UsecaseWithoutParams<List<PlanEntity>> {
  final IPlanRepository _repository;

  GetSavedPlansUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<PlanEntity>>> call() {
    return _repository.getSavedPlans();
  }
}