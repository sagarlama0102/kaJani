
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/features/chat/domain/entities/chat_list_entity.dart';
import 'package:kajani/features/chat/presentation/view_model/chat_view_model.dart';
import 'package:kajani/features/dashboard/presentation/pages/bottom_screen_layout/plan_chat_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(userSessionServiceProvider).getUserId() ?? '';
      ref.read(chatViewModelProvider.notifier).startChatListListening(userId);
    });
  }

  @override
  void dispose() {
    ref.read(chatViewModelProvider.notifier).stopChatListListening();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final chatList = chatState.chatList;

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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Messages',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your group chats',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xff1A1A2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Chat List ────────────────────────────────────────
            Expanded(
              child: chatList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: chatList.length,
                      itemBuilder: (context, index) {
                        return _buildChatCard(chatList[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Chat Card ────────────────────────────────────────────────────
  Widget _buildChatCard(ChatListEntity chat) {
    return GestureDetector(
      onTap: () {
        AppRoutes.push(
          context,
          PlanChatScreen(
            planId: chat.planId,
            planTitle: chat.planTitle,
            planCoverImage: chat.planCoverImage,
            memberIds: chat.members,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
        ),
        child: Row(
          children: [
            // ─── Plan Cover Image ──────────────────────────────
            Stack(
              children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: chat.planCoverImage != null
                    ? Image.network(
                        '${ApiEndpoints.baseUrlOnly}${chat.planCoverImage}',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xff22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xff0F0F0F),
                      width: 2,
                    ),
                  ),
                ),
              ),
              ],
            ),

            const SizedBox(width: 12),

            // ─── Chat Info ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.planTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${chat.lastMessageSender}: ${chat.lastMessage}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Members count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: AppColors.primary,
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${chat.members.length}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Icon(Icons.group_rounded, color: Colors.white, size: 26),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary.withOpacity(0.6),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join a plan and start chatting\nwith other members!',
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
