import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/data/model/chat/chat_message_model.dart';
import 'package:zuno_application/shared/constants/app_colors.dart';
import 'package:zuno_application/shared/constants/app_text_styles.dart';
import 'package:zuno_application/shared/constants/app_gradients.dart';
import 'package:zuno_application/data/model/chat/chat_preview_model.dart';

import '../home/home_controller.dart';
import 'chat_controller.dart';
import 'widgets/profile_detail_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatPreviewModel chat;
  final ChatController controller = Get.find<ChatController>();

  _ChatDetailScreenState() : chat = Get.arguments as ChatPreviewModel;

  final TextEditingController messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    controller.loadConversationMessages(chat.id);
  }

  @override
  void dispose() {
    controller.clearActiveConversation(chat.id);
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = _buildProfileFromChat(chat);
    final displayName = controller.normalizeDisplayName(chat.name);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.chatSectionSurfaceDark
          : AppColors.chatSectionSurfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
          ),
        ),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.to(
                    () => ProfileDetailsScreen(
                      profile: profile,
                      heroTag: "profile_${profile.id}",
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      backgroundImage: chat.imageUrl.isNotEmpty
                          ? NetworkImage(chat.imageUrl)
                          : null,
                      child: chat.imageUrl.isEmpty
                          ? Text(
                              controller.getInitials(displayName),
                              style: AppTextStyles.bodyMedium(
                                isDark: false,
                              ).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: AppTextStyles.headingMedium(
                              isDark: false,
                            ).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            chat.isOnline ? 'Online now' : 'Offline',
                            style: AppTextStyles.bodySmall(
                              isDark: false,
                            ).copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Modern Smooth Three-Dot Menu (No Snackbars)
            MenuAnchor(
              builder: (BuildContext context, MenuController menuController, Widget? child) {
                return IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    if (menuController.isOpen) {
                      menuController.close();
                    } else {
                      menuController.open();
                    }
                  },
                  tooltip: 'More options',
                );
              },
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () {
                    // Snackbar removed as requested
                  },
                  child: const Text('Clear Chat'),
                ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.notifications_off_outlined, size: 20),
                  onPressed: () {
                    // Snackbar removed as requested
                  },
                  child: const Text('Mute Notifications'),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = controller.getConversationMessages(chat.id);
              if (controller.isMessagesLoading.value && messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    "No messages yet. Say hi 👋",
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final ChatMessageModel message =
                      messages[messages.length - 1 - index];
                  final isMe = message.isMe;
                  final hasOlderMessage = index < messages.length - 1;
                  final olderMessage = hasOlderMessage
                      ? messages[messages.length - 2 - index]
                      : null;
                  final isSenderChanged =
                      olderMessage == null || olderMessage.isMe != isMe;
                  final isDateChanged =
                      olderMessage == null ||
                      !_isSameDay(message.createdAt, olderMessage.createdAt);
                  final maxBubbleWidth = MediaQuery.of(context).size.width * 0.62;

                  final TextStyle messageStyle = isMe
                      ? AppTextStyles.bodyMedium(isDark: false).copyWith(
                          color: Colors.white,
                        )
                      : AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                          color: isDark
                              ? Colors.white.withOpacity(0.95)
                              : Colors.black.withOpacity(0.87),
                        );

                  final TextStyle timeStyle = isMe
                      ? AppTextStyles.bodySmall(isDark: false).copyWith(
                          color: Colors.white.withOpacity(0.85),
                        )
                      : AppTextStyles.bodySmall(isDark: isDark).copyWith(
                          color: isDark
                              ? Colors.white.withOpacity(0.70)
                              : Colors.black.withOpacity(0.60),
                        );

                  return Column(
                    children: [
                      if (isDateChanged)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.inputFillDark
                                  : AppColors.inputFillLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _dayLabel(message.createdAt),
                              style: AppTextStyles.bodySmall(
                                isDark: isDark,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: isSenderChanged ? 8 : 2,
                              bottom: 2,
                              left: isMe ? 56 : 8,
                              right: isMe ? 8 : 56,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? (isDark
                                          ? AppColors.primary2
                                          : AppColors.primary3)
                                      : (isDark
                                          ? AppColors.inputFillDark
                                          : AppColors.cardLight),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 16),
                                  ),
                                  border: isMe
                                      ? null
                                      : Border.all(
                                          color: isDark
                                              ? AppColors.inputBorderDark
                                              : AppColors.inputBorderLight,
                                        ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.22 : 0.07,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Align(
                                        alignment: isMe
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(message.text, style: messageStyle),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            controller.formatMessageTime(
                                              message.createdAt,
                                            ),
                                            style: timeStyle,
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              message.isDelivered || message.isSeen
                                                  ? Icons.done_all_rounded
                                                  : Icons.done_rounded,
                                              size: 14,
                                              color: message.isSeen
                                                  ? const Color(0xFF42A5F5)
                                                  : Colors.white.withOpacity(0.9),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // Fully Responsive Message Input with Animated Send Button
          _buildMessageInput(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        color: isDark
            ? AppColors.chatHeaderSurfaceDark
            : AppColors.chatHeaderSurfaceLight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                style: AppTextStyles.body(isDark: isDark),
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.bodySmall(isDark: isDark),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.inputFillDark
                      : AppColors.inputFillLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Animated Send Button
            _AnimatedSendButton(
              isLoading: _isSending,
              onTap: _isSending
                  ? null
                  : () async {
                      if (_isSending || messageController.text.trim().isEmpty) {
                        return;
                      }
                      final text = messageController.text.trim();
                      messageController.clear();
                      setState(() => _isSending = true);
                      try {
                        await controller.sendMessage(chat.id, text);
                      } finally {
                        if (mounted) {
                          setState(() => _isSending = false);
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  DatingProfile _buildProfileFromChat(ChatPreviewModel chat) {
    return DatingProfile(
      id: chat.id,
      userName: controller.normalizeDisplayName(chat.name),
      age: "",
      bio: chat.lastMessage.trim().isNotEmpty ? chat.lastMessage : "No bio added yet",
      location: "",
      interests: const <String>[],
      profileImageUrl: chat.imageUrl,
      isActiveNow: chat.isOnline,
      distance: "",
      imageUrls: chat.imageUrl.trim().isNotEmpty
          ? <String>[chat.imageUrl]
          : const <String>[],
      gender: null,
      lookingFor: null,
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dayLabel(DateTime? date) {
    if (date == null) return "Today";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    return "${date.day}/${date.month}/${date.year}";
  }
}

// Animated Send Button Widget
class _AnimatedSendButton extends StatefulWidget {
  final Future<void> Function()? onTap;
  final bool isLoading;

  const _AnimatedSendButton({required this.onTap, this.isLoading = false});

  @override
  State<_AnimatedSendButton> createState() => _AnimatedSendButtonState();
}

class _AnimatedSendButtonState extends State<_AnimatedSendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    final callback = widget.onTap;
    if (callback != null) {
      callback();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null || widget.isLoading;
    return GestureDetector(
      onTapDown: isDisabled ? null : _handleTapDown,
      onTapUp: isDisabled ? null : _handleTapUp,
      onTapCancel: isDisabled ? null : _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: widget.isLoading
                ? const SizedBox(
                    key: ValueKey("send_loading"),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Icon(
                    Icons.send,
                    key: ValueKey("send_icon"),
                    color: AppColors.white,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}