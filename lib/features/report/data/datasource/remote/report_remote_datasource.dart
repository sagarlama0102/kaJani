import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/api/api_client.dart';
import 'package:kajani/core/api/api_endpoints.dart';

abstract interface class IReportRemoteDatasource {
  Future<void> submitReport({
    required String reportedUser,
    required String reason,
    String? note,
  });
}

final reportRemoteDatasourceProvider = Provider<IReportRemoteDatasource>((ref) {
  return ReportRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ReportRemoteDatasource implements IReportRemoteDatasource {
  final ApiClient _apiClient;
  ReportRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<void> submitReport({
    required String reportedUser,
    required String reason,
    String? note,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.reports,
      data: {
        'reportedUser': reportedUser,
        'reason': reason,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to submit report');
    }
  }
}