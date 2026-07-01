import 'package:kajani/features/dashboard/data/models/plan_api_model.dart';

abstract interface class IPlanRemoteDatasource {
  Future<List<PlanApiModel>> getAllPlans({
    int? page,
    int? size,
    String? search,
    String? category,
    String? status,
  });

  Future<PlanApiModel> getPlanById(String planId);

  Future<PlanApiModel> createPlan({
    required String title,
    required String description,
    required String category,
    required String location,
    required String date,
    required String time,
    required String endTime,
    bool isPublic,
    int? maxMembers,
    String? coverImage,
  });

  Future<PlanApiModel> updatePlan(String planId, Map<String, dynamic> data);

  Future<bool> deletePlan(String planId);

  Future<List<PlanApiModel>> getMyPlans();

  Future<List<PlanApiModel>> getJoinedPlans();

  Future<List<PlanApiModel>> getSavedPlans();

  Future<PlanApiModel> joinPlan(String planId);

  Future<PlanApiModel> leavePlan(String planId);

  Future<bool> toggleSavePlan(String planId);
}