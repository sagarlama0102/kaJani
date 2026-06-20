import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

class ToggleSavePlanParams extends Equatable {
  final String planId;
  const ToggleSavePlanParams({required this.planId});

  @override
  List<Object?> get props => [planId];
}

final toggleSavePlanUsecaseProvider = Provider<ToggleSavePlanUsecase>((ref) {
  return ToggleSavePlanUsecase(repository: ref.read(planRepositoryProvider));
});

class ToggleSavePlanUsecase
    implements UsecaseWithParams<bool, ToggleSavePlanParams> {
  final IPlanRepository _repository;

  ToggleSavePlanUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(ToggleSavePlanParams params) {
    return _repository.toggleSavePlan(params.planId);
  }
}