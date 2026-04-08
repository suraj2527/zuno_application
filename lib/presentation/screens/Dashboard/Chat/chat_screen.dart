import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/presentation/screens/Dashboard/Chat/chat_controller.dart';
import 'package:zuno_application/presentation/screens/Dashboard/Chat/widgets/active_user_avatar.dart';
import 'package:zuno_application/presentation/screens/Dashboard/Chat/widgets/chat_skeleton.dart';
import 'package:zuno_application/presentation/screens/Dashboard/Chat/widgets/chat_tile.dart';
import 'package:zuno_application/presentation/screens/Dashboard/Chat/widgets/empty_chat_view.dart';
import 'package:zuno_application/utils/constants/app_colors.dart';
import 'package:zuno_application/utils/constants/app_text_styles.dart';
import 'package:zuno_application/widgets/common/app_refresh_wrapper.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Obx(() {
          return AppRefreshWrapper(
            onRefresh: controller.refreshChats,
            child: controller.isLoading.value
                ? const ChatSkeleton()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      // parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, isDark),
                        const SizedBox(height: 24),
                        _buildActiveNowSection(context, isDark),
                        const SizedBox(height: 24),
                        _buildMessagesSection(context, isDark),
                      ],
                    ),
                  ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: AppTextStyles.headingLarge(
                  isDark: isDark,
                ).copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                'Stay connected with your matches',
                style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          // onTap: controller.openSearch,
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.chatHeaderSurfaceDark
                  : AppColors.chatHeaderSurfaceLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppColors.inputBorderDark
                    : AppColors.inputBorderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(isDark ? 0.14 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveNowSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.chatActiveSurfaceDark
            : AppColors.chatActiveSurfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.inputBorderDark
              : AppColors.inputBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(isDark ? 0.10 : 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACTIVE NOW', style: AppTextStyles.label(isDark: isDark)),
          const SizedBox(height: 14),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.activeUsers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final user = controller.activeUsers[index];
                return ActiveUserAvatar(user: user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesSection(BuildContext context, bool isDark) {
    if (controller.chatList.isEmpty) {
      return const EmptyChatView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MESSAGES', style: AppTextStyles.label(isDark: isDark)),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.chatSectionSurfaceDark
                : AppColors.chatSectionSurfaceLight,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? AppColors.inputBorderDark
                  : AppColors.inputBorderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(isDark ? 0.12 : 0.045),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ListView.separated(
            itemCount: controller.chatList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AppColors.inputBorderDark.withOpacity(0.55)
                  : AppColors.inputBorderLight,
              indent: 78,
              endIndent: 18,
            ),
            itemBuilder: (context, index) {
              final chat = controller.chatList[index];
              return ChatTile(chat: chat);
            },
          ),
        ),
      ],
    );
  }
}
