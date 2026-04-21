import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/shared/constants/app_colors.dart';
import 'package:zuno_application/shared/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/model/chat/chat_preview_model.dart';
import '../chat_controller.dart';

class ChatTile extends StatelessWidget {
  final ChatPreviewModel chat; // <- now uses ChatPreviewModel
  final VoidCallback? onLongPress;

  const ChatTile({super.key, required this.chat, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatController = Get.find<ChatController>();
    final isUnread = chat.unreadCount > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Get.toNamed(Routes.CHAT_DETAIL, arguments: chat);
      },
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark
                    ? AppColors.inputFillDark.withOpacity(0.88)
                    : AppColors.inputFillLight.withOpacity(1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? (isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight)
                : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isDark
                    ? AppColors.chatHeaderSurfaceDark
                    : AppColors.profileAvatarBackground,
                backgroundImage: chat.imageUrl.isNotEmpty
                    ? NetworkImage(chat.imageUrl)
                    : null,
                child: chat.imageUrl.isEmpty
                    ? Text(
                        chatController.getInitials(chat.name),
                        style: AppTextStyles.body(
                          isDark: isDark,
                        ).copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chatController.normalizeDisplayName(chat.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              isDark: isDark,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium(isDark: isDark)
                                .copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                  fontWeight: chat.unreadCount > 0
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (chat.unreadCount > 0)
                          Container(
                            height: 24,
                            width: 24,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Text(
                              chat.unreadCount.toString(),
                              style: AppTextStyles.bodySmall(isDark: false)
                                  .copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                            ),
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                chat.isDelivered || chat.isSeen
                                    ? Icons.done_all_rounded
                                    : Icons.done_rounded,
                                size: 14,
                                color: chat.isSeen
                                    ? const Color(0xFF42A5F5)
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                chat.time,
                                style: AppTextStyles.bodySmall(
                                  isDark: isDark,
                                ).copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
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
    );
  }
}
