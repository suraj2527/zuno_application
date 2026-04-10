import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/shared/constants/app_colors.dart';
import 'package:zuno_application/shared/constants/app_text_styles.dart';
import 'package:zuno_application/shared/constants/app_gradients.dart';
import 'package:zuno_application/data/model/chat/chat_preview_model.dart';

import '../home/home_controller.dart';
import 'chat_controller.dart';
import 'widgets/profile_detail_screen.dart';

class ChatDetailScreen extends StatelessWidget {
  final ChatPreviewModel chat;
  final ChatController controller = Get.find<ChatController>();

  ChatDetailScreen({super.key}) : chat = Get.arguments as ChatPreviewModel;

  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profiles = Get.find<HomeController>().allProfiles;
    final profile = profiles.where((p) => p.id == chat.id).isNotEmpty
        ? profiles.firstWhere((p) => p.id == chat.id)
        : null;

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
            GestureDetector(
              onTap: () {
                Get.to(
                  () => ProfileDetailsScreen(
                    profile: profile,
                    heroTag: "profile_${profile?.id}",
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.25),
                backgroundImage: chat.imageUrl.isNotEmpty
                    ? NetworkImage(chat.imageUrl)
                    : null,
                child: chat.imageUrl.isEmpty
                    ? Text(
                        controller.getInitials(chat.name),
                        style: AppTextStyles.bodyMedium(
                          isDark: false,
                        ).copyWith(color: Colors.white),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
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
            child: Builder(
              builder: (_) {
                final messages = [
                  {
                    'text': 'Hey! Saw you nearby. 👋',
                    'isMe': false,
                    'time': '2:15 PM',
                  },
                  {
                    'text': 'Hey there! 😁 That was quick!',
                    'isMe': true,
                    'time': '2:16 PM',
                  },
                  {
                    'text': 'Yeah, thought why not. What are you up to?',
                    'isMe': false,
                    'time': '2:17 PM',
                  },
                  {
                    'text': 'Just grabbing a coffee ☕',
                    'isMe': true,
                    'time': '2:18 PM',
                  },
                  {
                    'text': 'Nice! Maybe I’ll join you. 🐱',
                    'isMe': false,
                    'time': '2:19 PM',
                  },
                ];

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message['isMe'] as bool;

                    final TextStyle messageStyle = isMe
                        ? AppTextStyles.bodyMedium(isDark: false)
                            .copyWith(color: Colors.white)
                        : AppTextStyles.bodyMedium(isDark: isDark)
                            .copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.95)
                                  : Colors.black.withOpacity(0.87),
                            );

                    final TextStyle timeStyle = isMe
                        ? AppTextStyles.bodySmall(isDark: false)
                            .copyWith(color: Colors.white.withOpacity(0.85))
                        : AppTextStyles.bodySmall(isDark: isDark)
                            .copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.70)
                                  : Colors.black.withOpacity(0.60),
                            );

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                        decoration: BoxDecoration(
                          gradient: isMe ? AppGradients.primary : null,
                          color: isMe
                              ? null
                              : (isDark
                                  ? AppColors.chatTileHoverDark
                                  : AppColors.chatTileHoverLight),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isMe
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message['text'].toString(),
                              style: messageStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['time'].toString(),
                              style: timeStyle,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
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
              onTap: () {
                if (messageController.text.trim().isNotEmpty) {
                  messageController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Animated Send Button Widget
class _AnimatedSendButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedSendButton({required this.onTap});

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
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.send,
            color: AppColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}