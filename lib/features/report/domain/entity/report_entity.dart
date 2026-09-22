import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String reportedUser;
  final String reason;
  final String? note;

  const ReportEntity({
    required this.reportedUser,
    required this.reason,
    this.note,
  });

  @override
  List<Object?> get props => [reportedUser, reason, note];
}