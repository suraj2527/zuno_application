import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/utils/constants/app_colors.dart';
import 'package:zuno_application/utils/constants/app_text_styles.dart';
import '../models/chat_preview_model.dart';

class ChatTile extends StatelessWidget {
 final ChatPreviewModel chat; // <- now uses ChatPreviewModel

  const ChatTile({super.key, required this.chat});


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Get.toNamed('/chat-detail', arguments: chat);

        // OR if you're using screen directly:
        // Get.to(() => ChatDetailScreen(chat: chat));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isDark
                  ? AppColors.chatHeaderSurfaceDark
                  : AppColors.profileAvatarBackground,
              backgroundImage:
                  chat.imageUrl.isNotEmpty ? NetworkImage(chat.imageUrl) : null,
              child: chat.imageUrl.isEmpty
                  ? Icon(
                      Icons.person_rounded,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
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
                          chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTextStyles.body(isDark: isDark).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        chat.time,
                        style:
                            AppTextStyles.bodySmall(isDark: isDark).copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
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
                          style:
                              AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 10),
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
                        ),
                      ],
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