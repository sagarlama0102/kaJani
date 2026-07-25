import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajani/features/dashboard/domain/usecases/get_all_plan_by_id_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/get_my_plan_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';
import 'package:kajani/features/dashboard/domain/usecases/delete_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/join_plan_usecase.dart';
import 'package:kajani/features/dashboard/domain/usecases/toggle_save_plan_usecase.dart';

class MockPlanRepository extends Mock implements IPlanRepository {}

void main() {
  late MockPlanRepository mockRepository;

  setUp(() {
    mockRepository = MockPlanRepository();
  });

  const tPlanId = 'plan123';

  const tPlan = PlanEntity(
    planId: tPlanId,
    title: 'Trek to Shivapuri',
    description: 'A fun trekking trip for beginners',
    category: 'outdoor',
    location: 'Shivapuri, Kathmandu',
    date: '2026-07-15',
    time: '06:00',
    status: 'upcoming',
  );

  group('GetPlanByIdUsecase', () {
    test('returns the plan from the repository', () async {
      // arrange
      final usecase = GetPlanByIdUsecase(repository: mockRepository);
      when(() => mockRepository.getPlanById(any()))
          .thenAnswer((_) async => const Right(tPlan));

      // act
      final result =
          await usecase(const GetPlanByIdParams(planId: tPlanId));

      // assert
      expect(result, const Right(tPlan));
      verify(() => mockRepository.getPlanById(tPlanId)).called(1);
    });

    test('passes the failure through when the plan is not found', () async {
      // arrange
      final usecase = GetPlanByIdUsecase(repository: mockRepository);
      const tFailure = ApiFailure(message: 'Plan not found');
      when(() => mockRepository.getPlanById(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result =
          await usecase(const GetPlanByIdParams(planId: tPlanId));

      // assert
      expect(result, const Left(tFailure));
    });
  });

  group('GetMyPlansUsecase', () {
    test('returns the list of plans the user created', () async {
      // arrange
      final usecase = GetMyPlansUsecase(repository: mockRepository);
      when(() => mockRepository.getMyPlans())
          .thenAnswer((_) async => const Right([tPlan]));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right([tPlan]));
      verify(() => mockRepository.getMyPlans()).called(1);
    });

    test('returns an empty list when the user has created no plans', () async {
      // arrange
      final usecase = GetMyPlansUsecase(repository: mockRepository);
      when(() => mockRepository.getMyPlans())
          .thenAnswer((_) async => const Right(<PlanEntity>[]));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right(<PlanEntity>[]));
    });
  });

  group('JoinPlanUsecase', () {
    test('returns the updated plan after joining', () async {
      // arrange
      final usecase = JoinPlanUsecase(repository: mockRepository);
      when(() => mockRepository.joinPlan(any()))
          .thenAnswer((_) async => const Right(tPlan));

      // act
      final result = await usecase(const JoinPlanParams(planId: tPlanId));

      // assert
      expect(result, const Right(tPlan));
      verify(() => mockRepository.joinPlan(tPlanId)).called(1);
    });

    test('surfaces the failure when the plan is already full', () async {
      // arrange
      final usecase = JoinPlanUsecase(repository: mockRepository);
      const tFailure = ApiFailure(message: 'This plan is already full');
      when(() => mockRepository.joinPlan(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const JoinPlanParams(planId: tPlanId));

      // assert
      result.fold(
        (failure) => expect(failure.message, 'This plan is already full'),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('DeletePlanUsecase', () {
    test('returns true when the delete succeeds', () async {
      // arrange
      final usecase = DeletePlanUsecase(repository: mockRepository);
      when(() => mockRepository.deletePlan(any()))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await usecase(const DeletePlanParams(planId: tPlanId));

      // assert
      expect(result, const Right(true));
      verify(() => mockRepository.deletePlan(tPlanId)).called(1);
    });

    test('surfaces the failure when a non-creator tries to delete', () async {
      // arrange
      final usecase = DeletePlanUsecase(repository: mockRepository);
      const tFailure =
          ApiFailure(message: 'Only the creator can delete this plan');
      when(() => mockRepository.deletePlan(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const DeletePlanParams(planId: tPlanId));

      // assert
      expect(result, const Left(tFailure));
    });
  });

  group('ToggleSavePlanUsecase', () {
    test('returns true when the plan gets saved', () async {
      // arrange
      final usecase = ToggleSavePlanUsecase(repository: mockRepository);
      when(() => mockRepository.toggleSavePlan(any()))
          .thenAnswer((_) async => const Right(true));

      // act
      final result =
          await usecase(const ToggleSavePlanParams(planId: tPlanId));

      // assert
      expect(result, const Right(true));
    });

    test('returns false when the plan gets unsaved', () async {
      // arrange
      final usecase = ToggleSavePlanUsecase(repository: mockRepository);
      when(() => mockRepository.toggleSavePlan(any()))
          .thenAnswer((_) async => const Right(false));

      // act
      final result =
          await usecase(const ToggleSavePlanParams(planId: tPlanId));

      // assert
      expect(result, const Right(false));
      verify(() => mockRepository.toggleSavePlan(tPlanId)).called(1);
    });
  });
}