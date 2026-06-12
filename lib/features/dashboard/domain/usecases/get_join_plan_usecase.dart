import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

final getJoinedPlansUsecaseProvider = Provider<GetJoinedPlansUsecase>((ref) {
  return GetJoinedPlansUsecase(repository: ref.read(planRepositoryProvider));
});

class GetJoinedPlansUsecase implements UsecaseWithoutParams<List<PlanEntity>> {
  final IPlanRepository _repository;

  GetJoinedPlansUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<PlanEntity>>> call() {
    return _repository.getJoinedPlans();
  }
}