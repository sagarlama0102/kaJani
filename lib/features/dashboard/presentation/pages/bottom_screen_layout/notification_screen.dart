import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/features/dashboard/presentation/pages/plan_details_page.dart';
import 'package:kajani/features/notification/domain/entities/notification_entity.dart';
import 'package:kajani/features/notification/presentation/state/notification_state.dart';
import 'package:kajani/features/notification/presentation/view_model/notification_view_model.dart';


class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationViewModelProvider.notifier).getNotifications();
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dateTime.day} ${_monthName(dateTime.month)}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear all notifications?',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Text(
          'This will remove all your notifications permanently.',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: implement clear all in backend
              // ref.read(notificationViewModelProvider.notifier).clearAll();
            },
            child: Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  // ─── Actions ──────────────────────────────────
                  Row(
                    children: [
                      if (notificationState.unreadCount > 0)
                        GestureDetector(
                          onTap: () => ref
                              .read(notificationViewModelProvider.notifier)
                              .markAllAsRead(),
                          child: Text(
                            'Mark all read',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (notificationState.notifications.isNotEmpty) ...[
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: _showClearAllDialog,
                          child: Text(
                            'Clear all',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Notifications List ────────────────────────────────
            Expanded(
              child: notificationState.status == NotificationStatus.loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : notificationState.notifications.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: const Color(0xff1A1A2E),
                          onRefresh: () async => ref
                              .read(notificationViewModelProvider.notifier)
                              .getNotifications(),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount:
                                notificationState.notifications.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationRow(
                                notificationState.notifications[index],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Notification Row ─────────────────────────────────────────────
  Widget _buildNotificationRow(NotificationEntity notification) {
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          ref
              .read(notificationViewModelProvider.notifier)
              .markAsRead(notification.id);
        }
        if (notification.planId.isNotEmpty) {
          AppRoutes.push(
            context,
            PlanDetailPage(planId: notification.planId),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.transparent
              : AppColors.primary.withOpacity(0.04),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Plan Cover Image ──────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: notification.planCoverImage != null
                  ? Image.network(
                      '${ApiEndpoints.baseUrlOnly}${notification.planCoverImage}',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _senderAvatar(notification),
            ),

            const SizedBox(width: 14),

            // ─── Content ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text with bold plan name
                  _buildMessageText(notification),

                  const SizedBox(height: 5),

                  // Time
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ─── Unread dot ─────────────────────────────────────
            if (!isRead)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            else
              const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // ─── Message Text with bold plan name ────────────────────────────
  Widget _buildMessageText(NotificationEntity notification) {
    final message = notification.message;
    final planTitle = notification.planTitle ?? '';

    if (planTitle.isNotEmpty && message.contains(planTitle)) {
      final parts = message.split(planTitle);
      return RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
            height: 1.4,
          ),
          children: [
            TextSpan(text: parts[0]),
            TextSpan(
              text: planTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }

    return Text(
      message,
      style: TextStyle(
        color: Colors.white.withOpacity(0.85),
        fontSize: 14,
        height: 1.4,
      ),
    );
  }

  // ─── Sender Avatar (fallback) ─────────────────────────────────────
  Widget _senderAvatar(NotificationEntity notification) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary,
      backgroundImage: notification.senderProfilePicture != null
          ? NetworkImage(
              notification.senderProfilePicture!.startsWith('http')
                  ? notification.senderProfilePicture!
                  : '${ApiEndpoints.baseUrlOnly}${notification.senderProfilePicture}',
            )
          : null,
      child: notification.senderProfilePicture == null
          ? Text(
              notification.senderFirstName?.isNotEmpty == true
                  ? notification.senderFirstName![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )
          : null,
    );
  }

  // ─── Image Placeholder ────────────────────────────────────────────
  Widget _imagePlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.event_outlined,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              color: AppColors.primary.withOpacity(0.5),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No notifications yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When someone joins your plan\nyou\'ll see it here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}