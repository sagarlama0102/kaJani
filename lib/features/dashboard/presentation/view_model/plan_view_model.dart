import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/usecases/create_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/delete_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/get_all_plan_by_id_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/get_all_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/get_join_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/get_my_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/get_saved_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/join_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/leave_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/toggle_save_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/update_plan_usecase.dart';
import 'package:kajani/features/dashboard/presentation/state/plan_state.dart';

final planViewModelProvider = NotifierProvider<PlanViewModel, PlanState>(() {
  return PlanViewModel();
});

class PlanViewModel extends Notifier<PlanState> {
  late final GetAllPlansUsecase _getAllPlansUsecase;
  late final GetPlanByIdUsecase _getPlanByIdUsecase;
  late final CreatePlanUsecase _createPlanUsecase;
  late final UpdatePlanUsecase _updatePlanUsecase;
  late final DeletePlanUsecase _deletePlanUsecase;
  late final GetMyPlansUsecase _getMyPlansUsecase;
  late final GetJoinedPlansUsecase _getJoinedPlansUsecase;
  late final GetSavedPlansUsecase _getSavedPlansUsecase;
  late final JoinPlanUsecase _joinPlanUsecase;
  late final LeavePlanUsecase _leavePlanUsecase;
  late final ToggleSavePlanUsecase _toggleSavePlanUsecase;

  @override
  PlanState build() {
    _getAllPlansUsecase = ref.read(getAllPlansUsecaseProvider);
    _getPlanByIdUsecase = ref.read(getPlanByIdUsecaseProvider);
    _createPlanUsecase = ref.read(createPlanUsecaseProvider);
    _updatePlanUsecase = ref.read(updatePlanUsecaseProvider);
    _deletePlanUsecase = ref.read(deletePlanUsecaseProvider);
    _getMyPlansUsecase = ref.read(getMyPlansUsecaseProvider);
    _getJoinedPlansUsecase = ref.read(getJoinedPlansUsecaseProvider);
    _getSavedPlansUsecase = ref.read(getSavedPlansUsecaseProvider);
    _joinPlanUsecase = ref.read(joinPlanUsecaseProvider);
    _leavePlanUsecase = ref.read(leavePlanUsecaseProvider);
    _toggleSavePlanUsecase = ref.read(toggleSavePlanUsecaseProvider);
    return const PlanState();
  }

  // ─── Get All Plans ───────────────────────────────────────────────
  Future<void> getAllPlans({
    int? page,
    int? size,
    String? search,
    String? category,
    String? status,
  }) async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _getAllPlansUsecase(
      GetAllPlansParams(
        page: page,
        size: size,
        search: search,
        category: category,
        status: status,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (plans) => state = state.copyWith(
        status: PlanStatus.loaded,
        plans: plans,
      ),
    );
  }

  // ─── Get Plan By ID ──────────────────────────────────────────────
  Future<void> getPlanById(String planId) async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _getPlanByIdUsecase(
      GetPlanByIdParams(planId: planId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (plan) => state = state.copyWith(
        status: PlanStatus.loaded,
        selectedPlan: plan,
      ),
    );
  }

  // ─── Create Plan ─────────────────────────────────────────────────
  Future<void> createPlan({
    required String title,
    required String description,
    required String category,
    required String location,
    required String date,
    required String time,
    required String endTime,
    required String endDate,
    bool isPublic = true,
    int? maxMembers,
    String? coverImage,
  }) async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _createPlanUsecase(
      CreatePlanParams(
        title: title,
        description: description,
        category: category,
        location: location,
        date: date,
        time: time,
        endTime: endTime,
        endDate: endDate,
        isPublic: isPublic,
        maxMembers: maxMembers,
        coverImage: coverImage,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (plan) => state = state.copyWith(
        status: PlanStatus.created,
        plans: [plan, ...state.plans], // add new plan to top of list
        myPlans: [plan, ...state.myPlans],
      ),
    );
  }

  // ─── Update Plan ─────────────────────────────────────────────────
  Future<void> updatePlan(String planId, Map<String, dynamic> data) async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _updatePlanUsecase(
      UpdatePlanParams(planId: planId, data: data),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (updated) => state = state.copyWith(
        status: PlanStatus.updated,
        selectedPlan: updated,
        // update plan in lists
        plans: state.plans
            .map((p) => p.planId == planId ? updated : p)
            .toList(),
        myPlans: state.myPlans
            .map((p) => p.planId == planId ? updated : p)
            .toList(),
      ),
    );
  }

  // ─── Delete Plan ─────────────────────────────────────────────────
  Future<void> deletePlan(String planId) async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _deletePlanUsecase(
      DeletePlanParams(planId: planId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: PlanStatus.deleted,
        plans: state.plans.where((p) => p.planId != planId).toList(),
        myPlans: state.myPlans.where((p) => p.planId != planId).toList(),
      ),
    );
  }

  // ─── Get My Plans ────────────────────────────────────────────────
  Future<void> getMyPlans() async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _getMyPlansUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (plans) => state = state.copyWith(
        status: PlanStatus.loaded,
        myPlans: plans,
      ),
    );
  }

  // ─── Get Joined Plans ────────────────────────────────────────────
  Future<void> getJoinedPlans() async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _getJoinedPlansUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (plans) => state = state.copyWith(
        status: PlanStatus.loaded,
        joinedPlans: plans,
      ),
    );
  }

  // ─── Get Saved Plans ─────────────────────────────────────────────
  Future<void> getSavedPlans() async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _getSavedPlansUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (plans) => state = state.copyWith(
        status: PlanStatus.loaded,
        savedPlans: plans,
      ),
    );
  }

  // ─── Join Plan ───────────────────────────────────────────────────
  Future<void> joinPlan(String planId) async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _joinPlanUsecase(
      JoinPlanParams(planId: planId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (plan) => state = state.copyWith(
        status: PlanStatus.joined,
        selectedPlan: plan,
        joinedPlans: [plan, ...state.joinedPlans],
      ),
    );
  }

  // ─── Leave Plan ──────────────────────────────────────────────────
  Future<void> leavePlan(String planId) async {
    state = state.copyWith(status: PlanStatus.loading);

    final result = await _leavePlanUsecase(
      LeavePlanParams(planId: planId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PlanStatus.error,
        errorMessage: failure.message,
      ),
      (plan) => state = state.copyWith(
        status: PlanStatus.left,
        selectedPlan: plan,
        joinedPlans: state.joinedPlans
            .where((p) => p.planId != planId)
            .toList(),
      ),
    );
  }

  // ─── Toggle Save Plan ────────────────────────────────────────────
Future<void> toggleSavePlan(String planId, {String? currentUserId}) async {
  state = state.copyWith(status: PlanStatus.loading);

  final result = await _toggleSavePlanUsecase(
    ToggleSavePlanParams(planId: planId),
  );

  result.fold(
    (failure) => state = state.copyWith(
      status: PlanStatus.error,
      errorMessage: failure.message,
    ),
    (isSaved) {
      // update plans list locally
      List<PlanEntity> updateList(List<PlanEntity> plans) {
        return plans.map((p) {
          if (p.planId == planId && currentUserId != null) {
            final currentSavedBy = List<String>.from(p.savedBy ?? []);
            if (isSaved) {
              if (!currentSavedBy.contains(currentUserId)) {
                currentSavedBy.add(currentUserId);
              }
            } else {
              currentSavedBy.remove(currentUserId);
            }
            return PlanEntity(
              planId: p.planId,
              title: p.title,
              description: p.description,
              category: p.category,
              coverImage: p.coverImage,
              location: p.location,
              date: p.date,
              time: p.time,
              endTime: p.endTime,
              endDate: p.endDate,
              status: p.status,
              isPublic: p.isPublic,
              maxMembers: p.maxMembers,
              creatorId: p.creatorId,
              members: p.members,
              memberDetails: p.memberDetails,
              savedBy: currentSavedBy,
            );
          }
          return p;
        }).toList();
      }

      state = state.copyWith(
        status: PlanStatus.saved,
        isSaved: isSaved,
        plans: updateList(state.plans),
        savedPlans: updateList(state.savedPlans),
      );
    },
  );
}

  // ─── Reset Error ─────────────────────────────────────────────────
  void resetError() {
    state = state.copyWith(
      status: PlanStatus.initial,
      errorMessage: null,
    );
  }
}