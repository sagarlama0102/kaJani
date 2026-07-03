import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/features/notification/domain/entities/notification_entity.dart';
import 'package:kajani/features/notification/domain/usecases/get_notification_usecase.dart';
import 'package:kajani/features/notification/domain/usecases/get_unread_count_usecase.dart';
import 'package:kajani/features/notification/domain/usecases/mark_all_read_usecase.dart';
import 'package:kajani/features/notification/domain/usecases/mark_as_read_usecase.dart';
import 'package:kajani/features/notification/presentation/state/notification_state.dart';


final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
  () => NotificationViewModel(),
);

class NotificationViewModel extends Notifier<NotificationState> {
  late final GetNotificationsUsecase _getNotificationsUsecase;
  late final MarkAsReadUsecase _markAsReadUsecase;
  late final MarkAllReadUsecase _markAllReadUsecase;
  late final GetUnreadCountUsecase _getUnreadCountUsecase;

  @override
  NotificationState build() {
    _getNotificationsUsecase = ref.read(getNotificationsUsecaseProvider);
    _markAsReadUsecase = ref.read(markAsReadUsecaseProvider);
    _markAllReadUsecase = ref.read(markAllReadUsecaseProvider);
    _getUnreadCountUsecase = ref.read(getUnreadCountUsecaseProvider);
    return const NotificationState();
  }

  // ─── Get Notifications ───────────────────────────────────────────
  Future<void> getNotifications() async {
    state = state.copyWith(status: NotificationStatus.loading);

    final result = await _getNotificationsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      ),
      (notifications) => state = state.copyWith(
        status: NotificationStatus.loaded,
        notifications: notifications,
        unreadCount: notifications.where((n) => !n.isRead).length,
      ),
    );
  }

  // ─── Mark As Read ────────────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    final result = await _markAsReadUsecase(
      MarkAsReadParams(notificationId: notificationId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        // update locally — mark the notification as read
        final updated = state.notifications.map((n) {
          return n.id == notificationId
              ? NotificationEntity(
                  id: n.id,
                  recipientId: n.recipientId,
                  senderFirstName: n.senderFirstName,
                  senderLastName: n.senderLastName,
                  senderProfilePicture: n.senderProfilePicture,
                  type: n.type,
                  planId: n.planId,
                  planTitle: n.planTitle,
                  planCoverImage: n.planCoverImage,
                  message: n.message,
                  isRead: true, // 👈 mark as read
                  createdAt: n.createdAt,
                )
              : n;
        }).toList();

        state = state.copyWith(
          notifications: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        );
      },
    );
  }

  // ─── Mark All As Read ────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    final result = await _markAllReadUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        // mark all as read locally
        final updated = state.notifications.map((n) {
          return NotificationEntity(
            id: n.id,
            recipientId: n.recipientId,
            senderFirstName: n.senderFirstName,
            senderLastName: n.senderLastName,
            senderProfilePicture: n.senderProfilePicture,
            type: n.type,
            planId: n.planId,
            planTitle: n.planTitle,
            planCoverImage: n.planCoverImage,
            message: n.message,
            isRead: true, // 👈 all marked as read
            createdAt: n.createdAt,
          );
        }).toList();

        state = state.copyWith(
          notifications: updated,
          unreadCount: 0,
        );
      },
    );
  }

  // ─── Get Unread Count ────────────────────────────────────────────
  Future<void> getUnreadCount() async {
    final result = await _getUnreadCountUsecase();

    result.fold(
      (failure) => null, // silent fail for count
      (count) => state = state.copyWith(unreadCount: count),
    );
  }

  // ─── Reset Error ─────────────────────────────────────────────────
  void resetError() {
    state = state.copyWith(
      status: NotificationStatus.initial,
      errorMessage: null,
    );
  }
}