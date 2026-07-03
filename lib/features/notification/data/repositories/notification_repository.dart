import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/services/connectivity/network_info.dart';
import 'package:kajani/features/notification/data/datasources/remote/notification_remote_datasoruce.dart';
import 'package:kajani/features/notification/data/models/notification_api_model.dart';
import 'package:kajani/features/notification/domain/entities/notification_entity.dart';
import 'package:kajani/features/notification/domain/repositories/notification_repository.dart';


final notificationRepositoryProvider =
    Provider<INotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDatasource: ref.read(notificationRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class NotificationRepositoryImpl implements INotificationRepository {
  final NotificationRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  NotificationRepositoryImpl({
    required NotificationRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  // ─── Get Notifications ───────────────────────────────────────────
  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDatasource.getNotifications();
        return Right(NotificationApiModel.toEntityList(models));
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch notifications',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Mark As Read ────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.markAsRead(notificationId);
        return const Right(null);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to mark as read',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Mark All As Read ────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.markAllAsRead();
        return const Right(null);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to mark all as read',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  // ─── Get Unread Count ────────────────────────────────────────────
  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    if (await _networkInfo.isConnected) {
      try {
        final count = await _remoteDatasource.getUnreadCount();
        return Right(count);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to get unread count',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}