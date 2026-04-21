import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/shared/constants/app_colors.dart';
import 'package:zuno_application/shared/constants/app_text_styles.dart';

import '../../../data/model/chat/chat_user_model.dart';
import '../chat_controller.dart';

class ActiveUserAvatar extends StatelessWidget {
   final ChatUserModel user; // 

  const ActiveUserAvatar({super.key, required this.user});


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatController = Get.find<ChatController>();
    final displayName = chatController.normalizeDisplayName(user.name);

    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.chatHeaderSurfaceDark
                      : AppColors.profileAvatarBackground,
                  border: Border.all(
                    color: isDark
                        ? AppColors.inputBorderDark
                        : AppColors.inputBorderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(isDark ? 0.10 : 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: isDark
                      ? AppColors.cardDark
                      : AppColors.profileAvatarBackground,
                  backgroundImage: user.imageUrl.isNotEmpty
                      ? NetworkImage(user.imageUrl)
                      : null,
                  child: user.imageUrl.isEmpty
                      ? Text(
                          chatController.getInitials(displayName),
                          style: AppTextStyles.bodySmall(isDark: isDark)
                              .copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  height: 14,
                  width: 14,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.chatActiveSurfaceDark
                          : AppColors.chatActiveSurfaceLight,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}