import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/core/usecases/app_usecase.dart';
import 'package:kajani/features/report/data/repository/report_repository.dart';


class SubmitReportParams extends Equatable {
  final String reportedUser;
  final String reason;
  final String? note;

  const SubmitReportParams({required this.reportedUser, required this.reason, this.note});

  @override
  List<Object?> get props => [reportedUser, reason, note];
}

final submitReportUsecaseProvider = Provider<SubmitReportUsecase>((ref) {
  return SubmitReportUsecase(repository: ref.read(reportRepositoryProvider));
});

class SubmitReportUsecase implements UsecaseWithParams<void, SubmitReportParams> {
  final IReportRepository _repository;
  SubmitReportUsecase({required IReportRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, void>> call(SubmitReportParams params) {
    return _repository.submitReport(
      reportedUser: params.reportedUser,
      reason: params.reason,
      note: params.note,
    );
  }
}