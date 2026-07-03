import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/api/api_client.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/features/notification/data/models/notification_api_model.dart';


final notificationRemoteDatasourceProvider =
    Provider<NotificationRemoteDatasource>((ref) {
  return NotificationRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});

class NotificationRemoteDatasource {
  final ApiClient _apiClient;

  NotificationRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ─── Get Notifications ───────────────────────────────────────────
  Future<List<NotificationApiModel>> getNotifications() async {
    final response = await _apiClient.get(ApiEndpoints.notifications);

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => NotificationApiModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch notifications');
  }

  // ─── Mark As Read ────────────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.notifications}/$notificationId/read',
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to mark as read');
    }
  }

  // ─── Mark All As Read ────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    final response = await _apiClient.put(ApiEndpoints.markAllRead);

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to mark all as read');
    }
  }

  // ─── Get Unread Count ────────────────────────────────────────────
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(ApiEndpoints.unreadCount);

    if (response.data['success'] == true) {
      return response.data['data']['count'] as int;
    }
    throw Exception(response.data['message'] ?? 'Failed to get unread count');
  }
}