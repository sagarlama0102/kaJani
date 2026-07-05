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
  final String? planCoverImage;
  final List<String> memberIds;

  const PlanChatScreen({
    super.key,
    required this.planId,
    required this.planTitle,
    this.planCoverImage,
    this.memberIds = const [],
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

    await ref
        .read(chatViewModelProvider.notifier)
        .sendMessage(
          planId: widget.planId,
          senderId: senderId,
          senderName: senderName,
          senderProfilePicture: profilePicture,
          text: text,
          planTitle: widget.planTitle,
          planCoverImage: widget.planCoverImage,
          memberIds: widget.memberIds,
        );

    // scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final currentUserId = userSession.getUserId() ?? '';

    ref.listen<ChatState>(chatViewModelProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff0F0F0F),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Plan avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: widget.planCoverImage != null
                        ? Image.network(
                            '${ApiEndpoints.baseUrlOnly}${widget.planCoverImage}',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _appBarPlaceholder(),
                          )
                        : _appBarPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.planTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.memberIds.length} members',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.5),
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.status == ChatStatus.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : chatState.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      final isMe = message.senderId == currentUserId;
                      final isFirst = index == 0;
                      final prevMessage = isFirst
                          ? null
                          : chatState.messages[index - 1];
                      final showAvatar =
                          prevMessage == null ||
                          prevMessage.senderId != message.senderId;
                      final showDate =
                          prevMessage == null ||
                          !_isSameDay(prevMessage.createdAt, message.createdAt);

                      return Column(
                        children: [
                          if (showDate) _buildDateDivider(message.createdAt),
                          _buildMessageBubble(
                            message: message,
                            isMe: isMe,
                            showAvatar: showAvatar,
                          ),
                        ],
                      );
                    },
                  ),
          ),
          _buildMessageInput(chatState),
        ],
      ),
    );
  }

  // ─── App Bar Placeholder ──────────────────────────────────────────
  Widget _appBarPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.group_rounded, color: Colors.white, size: 22),
    );
  }

  // ─── Date Divider ─────────────────────────────────────────────────
  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    String label;
    if (_isSameDay(date, now)) {
      label = 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ─── Message Bubble ───────────────────────────────────────────────
  Widget _buildMessageBubble({
    required ChatMessageEntity message,
    required bool isMe,
    required bool showAvatar,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: showAvatar ? 12 : 2, top: 0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            showAvatar
                ? CircleAvatar(
                    radius: 15,
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
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  )
                : const SizedBox(width: 30),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      message.senderName.split(' ').first,
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : const Color(0xff1E1E35),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : Colors.white.withOpacity(0.92),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        Icon(
                          Icons.done_all_rounded,
                          size: 12,
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ─── Message Input ────────────────────────────────────────────────
  Widget _buildMessageInput(ChatState chatState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xff0F0F0F),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Input field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xff1A1A2E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: chatState.status == ChatStatus.sending
                  ? null
                  : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary.withOpacity(0.5),
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to say something! 👋',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
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
