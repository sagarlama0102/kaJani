import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

class GetAllPlansParams extends Equatable {
  final int? page;
  final int? size;
  final String? search;
  final String? category;
  final String? status;

  const GetAllPlansParams({
    this.page,
    this.size,
    this.search,
    this.category,
    this.status,
  });

  @override
  List<Object?> get props => [page, size, search, category, status];
}

final getAllPlansUsecaseProvider = Provider<GetAllPlansUsecase>((ref) {
  return GetAllPlansUsecase(repository: ref.read(planRepositoryProvider));
});

class GetAllPlansUsecase
    implements UsecaseWithParams<List<PlanEntity>, GetAllPlansParams> {
  final IPlanRepository _repository;

  GetAllPlansUsecase({required IPlanRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<PlanEntity>>> call(GetAllPlansParams params) {
    return _repository.getAllPlans(
      page: params.page,
      size: params.size,
      search: params.search,
      category: params.category,
      status: params.status,
    );
  }
}