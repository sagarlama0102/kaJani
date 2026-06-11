
import 'package:dartz/dartz.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';

abstract interface class IPlanRepository {

  Future<Either<Failure, PlanEntity>> createPlan({
    required String title,
    required String description,
    required String category,
    required String location,
    required String date,
    required String time,
    bool isPublic,
    int? maxMembers,
    String? coverImage,
  });
  Future<Either<Failure, List<PlanEntity>>> getAllPlans({
    int? page,
    int? size,
    String? search,
    String? category,
    String? status,
  });
  Future<Either<Failure, PlanEntity>> getPlanById(String planId);
  Future<Either<Failure, PlanEntity>> updatePlan(String planId, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deletePlan(String planId);

  Future<Either<Failure, List<PlanEntity>>> getMyPlans();
  Future<Either<Failure, List<PlanEntity>>> getJoinedPlans();
  Future<Either<Failure, List<PlanEntity>>> getSavedPlans();

  Future<Either<Failure, PlanEntity>> joinPlan(String planId);
  Future<Either<Failure, PlanEntity>> leavePlan(String planId);


  Future<Either<Failure, bool>> toggleSavePlan(String planId);
}