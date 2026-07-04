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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xff1A1A2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // ─── Plan Cover Image ──────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
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

            const SizedBox(width: 12),

            // ─── Chat Info ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.planTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${chat.lastMessageSender}: ${chat.lastMessage}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ─── Time ─────────────────────────────────────────
            Text(
              _formatTime(chat.lastMessageTime),
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Image Placeholder ────────────────────────────────────────────
  Widget _imagePlaceholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.group_outlined,
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
          Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.white.withOpacity(0.2),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No chats yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join a plan and start chatting\nwith other members!',
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
}