import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/widgets/empty_state.dart';
import 'package:kajani/core/widgets/skeleton_box.dart';
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
    Future.microtask(() {
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear all notifications?',
          style: TextStyle(color: context.textPrimary, fontSize: 16),
        ),
        content: Text(
          'This will remove all your notifications permanently.',
          style: TextStyle(color: context.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
      backgroundColor: context.surfaceColor,
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
                  Text(
                    'Notifications',
                    style: TextStyle(
                      color: context.textPrimary,
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
                              color: context.textSecondary,
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
              child:
                  (notificationState.status == NotificationStatus.loading ||
                      notificationState.status == NotificationStatus.initial)
                  ? _buildNotificationSkeleton()
                  : notificationState.notifications.isEmpty
                  ? RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => ref
                          .read(notificationViewModelProvider.notifier)
                          .getNotifications(),

                      child: ListView(
                        children: [
                          SizedBox(height: 80),
                          SizedBox(
                            width: double.infinity,
                            child: EmptyState(
                              imagePath: 'assets/images/notification_empty.png',
                              title: "No notifications yet",
                              message:
                                  "When someone joins your plan, you'll see it here.",
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => ref
                          .read(notificationViewModelProvider.notifier)
                          .getNotifications(),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: notificationState.notifications.length,
                        itemBuilder: (context, index) => _buildNotificationRow(
                          notificationState
                              .notifications[index], //pass the notification
                        ),
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
          AppRoutes.push(context, PlanDetailPage(planId: notification.planId));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.transparent
              : AppColors.primary.withOpacity(0.04),
          border: Border(
            bottom: BorderSide(color: context.textSecondary, width: 1),
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
                      color: context.textSecondary,
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
            color: context.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
          children: [
            TextSpan(text: parts[0]),
            TextSpan(
              text: planTitle,
              style: TextStyle(
                color: context.textSecondary,
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
      style: TextStyle(color: context.textSecondary, fontSize: 14, height: 1.4),
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
              style:  TextStyle(
                color: context.textPrimary,
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

  // ─── Skeleton while notifications load ──────────────────────────
  Widget _buildNotificationSkeleton() {
    return SkeletonShimmer(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 56, height: 56, radius: 10), // thumbnail
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 13, radius: 4), // message line 1
                    SizedBox(height: 6),
                    SkeletonBox(
                      width: 180,
                      height: 13,
                      radius: 4,
                    ), // message line 2
                    SizedBox(height: 8),
                    SkeletonBox(width: 60, height: 10, radius: 4), // time
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
