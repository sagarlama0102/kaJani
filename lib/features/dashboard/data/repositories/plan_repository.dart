import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/services/connectivity/network_info.dart';
import 'package:kajani/features/dashboard/data/datasources/remote/plan_remote_datasource.dart';

import 'package:kajani/features/dashboard/data/models/plan_api_model.dart';
import 'package:kajani/features/dashboard/domain/entities/plan_entity.dart';
import 'package:kajani/features/dashboard/domain/repositories/plan_repository.dart';

final planRepositoryProvider = Provider<IPlanRepository>((ref) {
  final planRemoteDatasource = ref.read(planRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return PlanRepositoryImpl(
    remoteDatasource: planRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class PlanRepositoryImpl implements IPlanRepository {
  final PlanRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  PlanRepositoryImpl({
    required PlanRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<PlanEntity>>> getAllPlans({
    int? page,
    int? size,
    String? search,
    String? category,
    String? status,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDatasource.getAllPlans(
          page: page,
          size: size,
          search: search,
          category: category,
          status: status,
        );
        return Right(PlanApiModel.toEntityList(models));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch plans',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Get Plan By ID ──────────────────────────────────────────────
  @override
  Future<Either<Failure, PlanEntity>> getPlanById(String planId) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDatasource.getPlanById(planId);
        return Right(model.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch plan',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Create Plan ─────────────────────────────────────────────────
  @override
  Future<Either<Failure, PlanEntity>> createPlan({
    required String title,
    required String description,
    required String category,
    required String location,
    required String date,
    required String endTime,
    required String endDate,
    required String time,
    bool isPublic = true,
    int? maxMembers,
    String? coverImage,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDatasource.createPlan(
          title: title,
          description: description,
          category: category,
          location: location,
          date: date,
          time: time,
          endTime:endTime,
          endDate: endDate,
          isPublic: isPublic,
          maxMembers: maxMembers,
          coverImage: coverImage,
        );
        return Right(model.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to create plan',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Update Plan ─────────────────────────────────────────────────
  @override
  Future<Either<Failure, PlanEntity>> updatePlan(
    String planId,
    Map<String, dynamic> data,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDatasource.updatePlan(planId, data);
        return Right(model.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to update plan',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Delete Plan ─────────────────────────────────────────────────
  @override
  Future<Either<Failure, bool>> deletePlan(String planId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.deletePlan(planId);
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to delete plan',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Get My Plans ────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<PlanEntity>>> getMyPlans() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDatasource.getMyPlans();
        return Right(PlanApiModel.toEntityList(models));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch my plans',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Get Joined Plans ────────────────────────────────────────────
  @override
  Future<Either<Failure, List<PlanEntity>>> getJoinedPlans() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDatasource.getJoinedPlans();
        return Right(PlanApiModel.toEntityList(models));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to fetch joined plans',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Get Saved Plans ─────────────────────────────────────────────
  @override
  Future<Either<Failure, List<PlanEntity>>> getSavedPlans() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDatasource.getSavedPlans();
        return Right(PlanApiModel.toEntityList(models));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to fetch saved plans',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Join Plan ───────────────────────────────────────────────────
  @override
  Future<Either<Failure, PlanEntity>> joinPlan(String planId) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDatasource.joinPlan(planId);
        return Right(model.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to join plan',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Leave Plan ──────────────────────────────────────────────────
  @override
  Future<Either<Failure, PlanEntity>> leavePlan(String planId) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDatasource.leavePlan(planId);
        return Right(model.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to leave plan',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Toggle Save Plan ────────────────────────────────────────────
  @override
  Future<Either<Failure, bool>> toggleSavePlan(String planId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.toggleSavePlan(planId);
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to save plan',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
