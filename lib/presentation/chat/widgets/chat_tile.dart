import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nearly/shared/constants/app_colors.dart';
import 'package:nearly/shared/constants/app_gradients.dart';
import 'package:nearly/shared/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/model/chat/chat_preview_model.dart';
import '../chat_controller.dart';

class ChatTile extends StatefulWidget {
  final ChatPreviewModel chat;
  final VoidCallback? onLongPress;

  const ChatTile({super.key, required this.chat, this.onLongPress});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Pulse badge once on load if unread
    if (widget.chat.unreadCount > 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _pulseController.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatController = Get.find<ChatController>();
    final isUnread = widget.chat.unreadCount > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Get.toNamed(Routes.CHAT_DETAIL, arguments: widget.chat);
      },
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          // Unread tiles get a subtle brand tint, read tiles are plain
          color: isUnread
              ? (isDark
                  ? const Color(0xFF1E1B30) // warm dark violet tint
                  : AppColors.primary5)     // soft lavender tint
              : (isDark ? AppColors.inputFillDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withOpacity(isDark ? 0.35 : 0.20)
                : (isDark
                    ? AppColors.inputBorderDark
                    : AppColors.inputBorderLight),
            width: isUnread ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? AppColors.primary.withOpacity(0.10)
                  : Colors.black.withOpacity(isDark ? 0.12 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar for unread
              if (isUnread)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isUnread ? 10 : 14,
                    10,
                    14,
                    10,
                  ),
                  child: Row(
                    children: [
                      // Avatar with online indicator
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: isDark
                                ? AppColors.chatHeaderSurfaceDark
                                : AppColors.profileAvatarBackground,
                            backgroundImage: widget.chat.imageUrl.isNotEmpty
                                ? NetworkImage(widget.chat.imageUrl)
                                : null,
                            child: widget.chat.imageUrl.isEmpty
                                ? Text(
                                    chatController.getInitials(widget.chat.name),
                                    style: AppTextStyles.body(
                                      isDark: isDark,
                                    ).copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          // Online dot with subtle outer glow ring
                          if (widget.chat.isOnline)
                            Positioned(
                              right: 1,
                              bottom: 1,
                              child: _OnlinePulse(isDark: isDark),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Name + last message
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chatController.normalizeDisplayName(widget.chat.name),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body(isDark: isDark).copyWith(
                                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 14,
                                      color: isUnread
                                          ? (isDark ? Colors.white : AppColors.textPrimary)
                                          : (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textSecondary),
                                    ),
                                  ),
                                ),
                                // Time
                                Text(
                                  widget.chat.time,
                                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                    fontSize: 11,
                                    fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                                    color: isUnread
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.textHintDark
                                            : AppColors.textHint),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                // Tick icons for sent messages
                                if (!isUnread)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      widget.chat.isDelivered || widget.chat.isSeen
                                          ? Icons.done_all_rounded
                                          : Icons.done_rounded,
                                      size: 13,
                                      color: widget.chat.isSeen
                                          ? const Color(0xFF42A5F5)
                                          : (isDark
                                              ? AppColors.textHintDark
                                              : AppColors.textHint),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    widget.chat.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                                      fontSize: 12,
                                      color: isUnread
                                          ? (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textPrimary)
                                          : (isDark
                                              ? AppColors.textHintDark
                                              : AppColors.textHint),
                                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Pulsing unread badge
                                if (isUnread)
                                  ScaleTransition(
                                    scale: _pulseAnim,
                                    child: Container(
                                      height: 22,
                                      width: 22,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        gradient: AppGradients.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        widget.chat.unreadCount > 9
                                            ? '9+'
                                            : widget.chat.unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10,
                                        ),
                                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Online Pulse Indicator ───────────────────────────────────────────────────
class _OnlinePulse extends StatefulWidget {
  final bool isDark;
  const _OnlinePulse({required this.isDark});

  @override
  State<_OnlinePulse> createState() => _OnlinePulseState();
}

class _OnlinePulseState extends State<_OnlinePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.isDark ? AppColors.inputFillDark : Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
