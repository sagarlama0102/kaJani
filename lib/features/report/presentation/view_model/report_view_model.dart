import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/report/domain/usecases/submit_report_usecase.dart';
import 'package:kajani/features/report/presentation/state/report_state.dart';

final reportViewModelProvider =
    NotifierProvider<ReportViewModel, ReportState>(() => ReportViewModel());

class ReportViewModel extends Notifier<ReportState> {
  late final SubmitReportUsecase _submitReportUsecase;

  @override
  ReportState build() {
    _submitReportUsecase = ref.read(submitReportUsecaseProvider);
    return const ReportState();
  }

  Future<void> submitReport({
    required String reportedUser,
    required String reason,
    String? note,
  }) async {
    state = state.copyWith(status: ReportStatus.loading);
    final result = await _submitReportUsecase(
      SubmitReportParams(reportedUser: reportedUser, reason: reason, note: note),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: ReportStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: ReportStatus.success),
    );
  }

  void reset() => state = const ReportState();
}