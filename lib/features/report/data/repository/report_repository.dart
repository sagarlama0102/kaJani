import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/services/connectivity/network_info.dart';
import 'package:kajani/features/report/data/datasource/remote/report_remote_datasource.dart';


abstract interface class IReportRepository {
  Future<Either<Failure, void>> submitReport({
    required String reportedUser,
    required String reason,
    String? note,
  });
}

final reportRepositoryProvider = Provider<IReportRepository>((ref) {
  return ReportRepositoryImpl(
    remoteDatasource: ref.read(reportRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ReportRepositoryImpl implements IReportRepository {
  final IReportRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  ReportRepositoryImpl({
    required IReportRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> submitReport({
    required String reportedUser,
    required String reason,
    String? note,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.submitReport(
          reportedUser: reportedUser,
          reason: reason,
          note: note,
        );
        return const Right(null);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to submit report',
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