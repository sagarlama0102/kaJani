import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:kajani/features/chat/domain/entities/chat_message_entity.dart';
import 'package:kajani/features/chat/presentation/state/chat_state.dart';
import 'package:kajani/features/chat/presentation/view_model/chat_view_model.dart';

class PlanChatScreen extends ConsumerStatefulWidget {
  final String planId;
  final String planTitle;

  const PlanChatScreen({
    super.key,
    required this.planId,
    required this.planTitle,
  });

  @override
  ConsumerState<PlanChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<PlanChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).startListening(widget.planId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    ref.read(chatViewModelProvider.notifier).stopListening();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userSession = ref.read(userSessionServiceProvider);
    final senderId = userSession.getUserId() ?? '';
    final firstName = userSession.getUserFirstName() ?? '';
    final lastName = userSession.getUserLastName() ?? '';
    final senderName = '$firstName $lastName'.trim();
    final profilePicture = userSession.getUserProfilePicture();

    final text = _messageController.text.trim();
    _messageController.clear();

    await ref.read(chatViewModelProvider.notifier).sendMessage(
          planId: widget.planId,
          senderId: senderId,
          senderName: senderName,
          senderProfilePicture: profilePicture,
          text: text,
        );

    // scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final currentUserId = userSession.getUserId() ?? '';

    // scroll to bottom when new messages arrive
    ref.listen<ChatState>(chatViewModelProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length) {
        Future.delayed(
          const Duration(milliseconds: 100),
          _scrollToBottom,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xff1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.planTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Group Chat',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Messages List ────────────────────────────────────────
          Expanded(
            child: chatState.status == ChatStatus.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : chatState.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          final isMe = message.senderId == currentUserId;
                          final showAvatar = index == 0 ||
                              chatState.messages[index - 1].senderId !=
                                  message.senderId;

                          return _buildMessageBubble(
                            message: message,
                            isMe: isMe,
                            showAvatar: showAvatar,
                          );
                        },
                      ),
          ),

          // ─── Message Input ────────────────────────────────────────
          _buildMessageInput(chatState),
        ],
      ),
    );
  }

  // ─── Message Bubble ───────────────────────────────────────────────
  Widget _buildMessageBubble({
    required ChatMessageEntity message,
    required bool isMe,
    required bool showAvatar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ─── Avatar (only for others) ──────────────────────────
          if (!isMe) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                backgroundImage: message.senderProfilePicture != null
                    ? NetworkImage(
                        message.senderProfilePicture!.startsWith('http')
                            ? message.senderProfilePicture!
                            : '${ApiEndpoints.baseUrlOnly}${message.senderProfilePicture}',
                      )
                    : null,
                child: message.senderProfilePicture == null
                    ? Text(
                        message.senderName.isNotEmpty
                            ? message.senderName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],

          // ─── Bubble ────────────────────────────────────────────
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // sender name (only for others, only when avatar shown)
                if (!isMe && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primary
                        : const Color(0xff1A1A2E),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ),

                // timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ─── Message Input ────────────────────────────────────────────────
  Widget _buildMessageInput(ChatState chatState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xff1A1A2E),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff0F0F0F),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: chatState.status == ChatStatus.sending
                  ? null
                  : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: chatState.status == ChatStatus.sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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
            Icons.chat_bubble_outline_rounded,
            color: Colors.white.withOpacity(0.2),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to say something!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Format Time ──────────────────────────────────────────────────
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}