import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nearly/data/model/chat/chat_message_model.dart';
import 'package:nearly/data/model/chat/chat_preview_model.dart';
import 'package:nearly/shared/constants/app_colors.dart';
import 'package:nearly/shared/constants/app_gradients.dart';
import 'package:nearly/shared/constants/app_text_styles.dart';
import 'package:nearly/shared/widgets/common/app_refresh_wrapper.dart';

import '../home/home_controller.dart';
import 'chat_controller.dart';
import 'widgets/profile_detail_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  final ChatPreviewModel chat;
  final ChatController controller = Get.find<ChatController>();

  _ChatDetailScreenState() : chat = Get.arguments as ChatPreviewModel;

  final TextEditingController messageController = TextEditingController();
  bool _isSending = false;
  bool _showScrollButton = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.loadConversationMessages(chat.id);
    _scrollController.addListener(() {
      final show = _scrollController.offset > 200;
      if (show != _showScrollButton) {
        setState(() => _showScrollButton = show);
      }
    });
  }

  @override
  void dispose() {
    controller.clearActiveConversation(chat.id);
    messageController.dispose();
    _scrollController.dispose();
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
          : const Color(0xFFF4F1FC), // soft lavender tint for light mode
      appBar: _buildAppBar(isDark, displayName, profile),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Obx(() {
                  final messages = controller.getConversationMessages(chat.id);
                  if (controller.isMessagesLoading.value && messages.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (messages.isEmpty) {
                    return _buildEmptyState(isDark, displayName);
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.loadConversationMessages(chat.id),
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
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
                        final isDateChanged = olderMessage == null ||
                            !_isSameDay(
                                message.createdAt, olderMessage.createdAt);

                        return _buildMessageItem(
                          context: context,
                          isDark: isDark,
                          message: message,
                          isMe: isMe,
                          isSenderChanged: isSenderChanged,
                          isDateChanged: isDateChanged,
                        );
                      },
                    ),
                  );
                }),
              ),
              _buildMessageInput(context, isDark),
            ],
          ),

          // Scroll to bottom FAB
          if (_showScrollButton)
            Positioned(
              right: 16,
              bottom: 80,
              child: AnimatedScale(
                scale: _showScrollButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: () => _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    bool isDark,
    String displayName,
    DatingProfile profile,
  ) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppGradients.primary),
      ),
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),

          // Avatar with online ring
          GestureDetector(
            onTap: () => Get.to(
              () => ProfileDetailsScreen(
                profile: profile,
                heroTag: "profile_${profile.id}",
                openedFrom: ProfileOpenedFrom.chat,
              ),
            ),
            child: Stack(
              children: [
                // Ring glow when online
                if (chat.isOnline)
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.green,
                        width: 2.5,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(chat.isOnline ? 3 : 0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    backgroundImage: chat.imageUrl.isNotEmpty
                        ? NetworkImage(chat.imageUrl)
                        : null,
                    child: chat.imageUrl.isEmpty
                        ? Text(
                            controller.getInitials(displayName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Name + status
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(
                () => ProfileDetailsScreen(
                  profile: profile,
                  heroTag: "profile_${profile.id}",
                  openedFrom: ProfileOpenedFrom.chat,
                ),
              ),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.headingMedium(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    children: [
                      if (chat.isOnline)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      Text(
                        chat.isOnline ? 'Online now' : 'Tap to view profile',
                        style: AppTextStyles.bodySmall(isDark: false).copyWith(
                          color: chat.isOnline
                              ? Colors.greenAccent.shade100
                              : Colors.white.withOpacity(0.65),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Three-dot menu
          MenuAnchor(
            builder: (context, menuController, child) {
              return IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  if (menuController.isOpen) {
                    menuController.close();
                  } else {
                    menuController.open();
                  }
                },
              );
            },
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () {},
                child: const Text('Clear Chat'),
              ),
              MenuItemButton(
                leadingIcon:
                    const Icon(Icons.notifications_off_outlined, size: 20),
                onPressed: () {},
                child: const Text('Mute Notifications'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Message Item ─────────────────────────────────────────────────────────
  Widget _buildMessageItem({
    required BuildContext context,
    required bool isDark,
    required ChatMessageModel message,
    required bool isMe,
    required bool isSenderChanged,
    required bool isDateChanged,
  }) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.72;

    return Column(
      children: [
        // Date separator — styled pill
        if (isDateChanged)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark
                        ? AppColors.inputBorderDark.withOpacity(0.4)
                        : AppColors.inputBorderLight,
                    thickness: 0.8,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.inputFillDark
                        : AppColors.primary5,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.inputBorderDark
                          : AppColors.inputBorderLight,
                    ),
                  ),
                  child: Text(
                    _dayLabel(message.createdAt),
                    style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textHintDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark
                        ? AppColors.inputBorderDark.withOpacity(0.4)
                        : AppColors.inputBorderLight,
                    thickness: 0.8,
                  ),
                ),
              ],
            ),
          ),

        // Bubble row
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Their avatar shown for first message in a group
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 6, bottom: 2),
                child: isSenderChanged
                    ? CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.profileAvatarBackground,
                        backgroundImage: chat.imageUrl.isNotEmpty
                            ? NetworkImage(chat.imageUrl)
                            : null,
                        child: chat.imageUrl.isEmpty
                            ? Text(
                                controller.getInitials(
                                    controller.normalizeDisplayName(chat.name)),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      )
                    : const SizedBox(width: 34),
              ),

            Container(
              margin: EdgeInsets.only(
                top: isSenderChanged ? 10 : 2,
                bottom: 2,
                left: isMe ? 60 : 0,
                right: isMe ? 8 : 60,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    // Me: gradient bubble  |  Them: plain card
                    gradient: isMe ? AppGradients.primary : null,
                    color: isMe
                        ? null
                        : (isDark
                            ? AppColors.inputFillDark
                            : AppColors.cardLight),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    border: isMe
                        ? null
                        : Border.all(
                            color: isDark
                                ? AppColors.inputBorderDark
                                : AppColors.inputBorderLight,
                            width: 0.8,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? AppColors.primary.withOpacity(0.25)
                            : Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                        blurRadius: isMe ? 12 : 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: AppTextStyles.bodyMedium(isDark: isMe ? false : isDark).copyWith(
                            color: isMe
                                ? Colors.white
                                : (isDark
                                    ? Colors.white.withOpacity(0.93)
                                    : Colors.black.withOpacity(0.85)),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              controller.formatMessageTime(message.createdAt),
                              style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                color: isMe
                                    ? Colors.white.withOpacity(0.75)
                                    : (isDark
                                        ? AppColors.textHintDark
                                        : AppColors.textHint),
                                fontSize: 10,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                message.isDelivered || message.isSeen
                                    ? Icons.done_all_rounded
                                    : Icons.done_rounded,
                                size: 13,
                                color: message.isSeen
                                    ? Colors.lightBlueAccent
                                    : Colors.white.withOpacity(0.75),
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
  }

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark, String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppGradients.soft,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text('👋', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (b) => AppGradients.primary.createShader(b),
            child: Text(
              "Say hi to $name!",
              style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You matched! Start the conversation 🎉",
            style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Message Input ─────────────────────────────────────────────────────────
  Widget _buildMessageInput(BuildContext context, bool isDark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.chatHeaderSurfaceDark
              : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.inputBorderDark.withOpacity(0.5)
                  : AppColors.inputBorderLight,
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Emoji button
            Padding(
              padding: const EdgeInsets.only(bottom: 6, right: 4),
              child: Icon(
                Icons.emoji_emotions_outlined,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
                size: 24,
              ),
            ),
            Expanded(
              child: TextField(
                controller: messageController,
                style: AppTextStyles.body(isDark: isDark),
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.inputFillDark
                      : AppColors.inputFillLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.inputBorderDark
                          : AppColors.inputBorderLight,
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _AnimatedSendButton(
              isLoading: _isSending,
              onTap: _isSending
                  ? null
                  : () async {
                      if (_isSending ||
                          messageController.text.trim().isEmpty) {
                        return;
                      }
                      final text = messageController.text.trim();
                      messageController.clear();
                      setState(() => _isSending = true);
                      try {
                        await controller.sendMessage(chat.id, text);
                      } finally {
                        if (mounted) setState(() => _isSending = false);
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
      bio: chat.lastMessage.trim().isNotEmpty
          ? chat.lastMessage
          : "No bio added yet",
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

// ─── Animated Send Button ─────────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null || widget.isLoading;
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled
          ? null
          : (_) {
              _controller.reverse();
              widget.onTap?.call();
            },
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: const BoxDecoration(
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Icon(
                    Icons.send_rounded,
                    key: ValueKey("send_icon"),
                    color: AppColors.white,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}