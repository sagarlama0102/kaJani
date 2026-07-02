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

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (notificationState.unreadCount > 0)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(notificationViewModelProvider.notifier)
                            .markAllAsRead();
                      },
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Unread count badge ────────────────────────────────
            if (notificationState.unreadCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${notificationState.unreadCount} unread',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

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
                          onRefresh: () async {
                            ref
                                .read(notificationViewModelProvider.notifier)
                                .getNotifications();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: notificationState.notifications.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationCard(
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

  // ─── Notification Card ────────────────────────────────────────────
  Widget _buildNotificationCard(NotificationEntity notification) {
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: () {
        // mark as read
        if (!isRead) {
          ref
              .read(notificationViewModelProvider.notifier)
              .markAsRead(notification.id);
        }
        // navigate to plan detail
        if (notification.planId.isNotEmpty) {
          AppRoutes.push(
            context,
            PlanDetailPage(planId: notification.planId),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? const Color(0xff1A1A2E)
              : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Sender Avatar ──────────────────────────────────
            CircleAvatar(
              radius: 22,
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
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // ─── Content ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight:
                          isRead ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Plan card (if available)
                  if (notification.planTitle != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff0F0F0F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Plan cover image
                          if (notification.planCoverImage != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                '${ApiEndpoints.baseUrlOnly}${notification.planCoverImage}',
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _planImagePlaceholder(),
                              ),
                            )
                          else
                            _planImagePlaceholder(),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              notification.planTitle!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.3),
                            size: 12,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 6),

                  // Time
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Unread dot ─────────────────────────────────────
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            color: Colors.white.withOpacity(0.2),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When someone joins your plan\nyou\'ll see it here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Plan Image Placeholder ───────────────────────────────────────
  Widget _planImagePlaceholder() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.image_outlined, color: AppColors.primary, size: 16),
    );
  }

  // ─── Format Time ──────────────────────────────────────────────────
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}