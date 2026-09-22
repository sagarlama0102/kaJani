enum ReportStatus { initial, loading, success, error }

class ReportState {
  final ReportStatus status;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.initial,
    this.errorMessage,
  });

  ReportState copyWith({ReportStatus? status, String? errorMessage}) {
    return ReportState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}