import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/services/connectivity/network_info.dart';
import 'package:kajani/features/dashboard/data/datasources/remote/plan_remote_datasource.dart';
import 'package:kajani/features/dashboard/data/models/plan_api_model.dart';
import 'package:kajani/features/dashboard/data/repositories/plan_repository.dart';

class MockPlanRemoteDatasource extends Mock implements PlanRemoteDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockPlanRemoteDatasource mockRemote;
  late MockNetworkInfo mockNetworkInfo;
  late PlanRepositoryImpl repository;

  setUp(() {
    mockRemote = MockPlanRemoteDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = PlanRepositoryImpl(
      remoteDatasource: mockRemote,
      networkInfo: mockNetworkInfo,
    );
  });

  const tPlanId = 'plan123';

  const tModel = PlanApiModel(
    planId: tPlanId,
    title: 'Trek to Shivapuri',
    description: 'A fun trekking trip for beginners',
    category: 'outdoor',
    location: 'Shivapuri, Kathmandu',
    date: '2026-07-15',
    time: '06:00',
    status: 'upcoming',
  );

  group('getPlanById', () {
    test('returns a PlanEntity when online and the call succeeds', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.getPlanById(any()))
          .thenAnswer((_) async => tModel);

      // act
      final result = await repository.getPlanById(tPlanId);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected a plan, got a failure'),
        (plan) {
          expect(plan.planId, tPlanId);
          expect(plan.title, 'Trek to Shivapuri');
        },
      );
      verify(() => mockRemote.getPlanById(tPlanId)).called(1);
    });

    test('returns NetworkFailure when offline and never hits the datasource',
        () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getPlanById(tPlanId);

      // assert
      expect(result, const Left(NetworkFailure(message: 'No internet connection')));
      verifyNever(() => mockRemote.getPlanById(any()));
    });

    test('maps a DioException to an ApiFailure with the server message',
        () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.getPlanById(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/plans/$tPlanId'),
          response: Response(
            requestOptions: RequestOptions(path: '/plans/$tPlanId'),
            statusCode: 404,
            data: {'success': false, 'message': 'Plan not found'},
          ),
        ),
      );

      // act
      final result = await repository.getPlanById(tPlanId);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, 'Plan not found');
        },
        (_) => fail('expected a failure, got a plan'),
      );
    });
  });

  group('deletePlan', () {
    test('returns true when the delete succeeds', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.deletePlan(any())).thenAnswer((_) async => true);

      // act
      final result = await repository.deletePlan(tPlanId);

      // assert
      expect(result, const Right(true));
      verify(() => mockRemote.deletePlan(tPlanId)).called(1);
    });

    test('returns ApiFailure with a 403 when a non-creator tries to delete',
        () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.deletePlan(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/plans/$tPlanId'),
          response: Response(
            requestOptions: RequestOptions(path: '/plans/$tPlanId'),
            statusCode: 403,
            data: {
              'success': false,
              'message': 'Only the creator can delete this plan',
            },
          ),
        ),
      );

      // act
      final result = await repository.deletePlan(tPlanId);

      // assert
      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, 'Only the creator can delete this plan');
          expect((failure as ApiFailure).statusCode, 403);
        },
        (_) => fail('expected a failure'),
      );
    });
  });
}