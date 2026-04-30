import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/model/chat/chat_preview_model.dart';
import '../chat_controller.dart';

class ChatTile extends StatelessWidget {
  final ChatPreviewModel chat;
  final VoidCallback? onLongPress;

  const ChatTile({super.key, required this.chat, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatController = Get.find<ChatController>();
    final isUnread = chat.unreadCount > 0;

    return InkWell(
      onTap: () => Get.toNamed(Routes.CHAT_DETAIL, arguments: chat),
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFF2F4FF),
                  backgroundImage: chat.imageUrl.isNotEmpty
                      ? NetworkImage(chat.imageUrl)
                      : null,
                  child: chat.imageUrl.isEmpty
                      ? Text(
                          chatController.getInitials(chat.name),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: _OnlinePulse(isDark: isDark),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        chat.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnread ? AppColors.primary : (isDark ? Colors.white38 : Colors.black38),
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUnread 
                                ? (isDark ? Colors.white70 : Colors.black87) 
                                : (isDark ? Colors.white38 : Colors.black45),
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
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
