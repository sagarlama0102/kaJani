import 'package:equatable/equatable.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';

enum PlanStatus {
  initial,
  loading,
  loaded,
  created,
  updated,
  deleted,
  joined,
  left,
  saved,
  error,
}

class PlanState extends Equatable {
  final PlanStatus status;
  final List<PlanEntity> plans;          // all plans / explore
  final List<PlanEntity> myPlans;        // plans user created
  final List<PlanEntity> joinedPlans;    // plans user joined
  final List<PlanEntity> savedPlans;     // plans user saved
  final PlanEntity? selectedPlan;        // single plan details
  final String? errorMessage;
  final bool? isSaved;                   // for toggle save feedback

  const PlanState({
    this.status = PlanStatus.initial,
    this.plans = const [],
    this.myPlans = const [],
    this.joinedPlans = const [],
    this.savedPlans = const [],
    this.selectedPlan,
    this.errorMessage,
    this.isSaved,
  });

  PlanState copyWith({
    PlanStatus? status,
    List<PlanEntity>? plans,
    List<PlanEntity>? myPlans,
    List<PlanEntity>? joinedPlans,
    List<PlanEntity>? savedPlans,
    PlanEntity? selectedPlan,
    String? errorMessage,
    bool? isSaved,
  }) {
    return PlanState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      myPlans: myPlans ?? this.myPlans,
      joinedPlans: joinedPlans ?? this.joinedPlans,
      savedPlans: savedPlans ?? this.savedPlans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
        status,
        plans,
        myPlans,
        joinedPlans,
        savedPlans,
        selectedPlan,
        errorMessage,
        isSaved,
      ];
}