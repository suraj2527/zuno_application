import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/data/model/chat/chat_preview_model.dart';
import 'package:zuno_application/presentation/chat/chat_controller.dart';
import 'package:zuno_application/presentation/chat/widgets/active_user_avatar.dart';
import 'package:zuno_application/presentation/chat/widgets/chat_skeleton.dart';
import 'package:zuno_application/presentation/chat/widgets/chat_tile.dart';
import 'package:zuno_application/presentation/chat/widgets/empty_chat_view.dart';
import 'package:zuno_application/shared/constants/app_colors.dart';
import 'package:zuno_application/shared/constants/app_text_styles.dart';
import 'package:zuno_application/shared/widgets/common/app_refresh_wrapper.dart';
import '../../shared/widgets/common/zuno_base_screen.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ZunoBaseScreen(
      isDark: isDark,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const ChatSkeleton();
        }

        return AppRefreshWrapper(
          onRefresh: controller.refreshChats,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: _buildActiveTab(isDark),
        );
      }),
    );
  }

  Widget _buildActiveTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActiveNowSection(isDark),
        const SizedBox(height: 24),
        _buildMessagesSection(isDark),
      ],
    );
  }

  Widget _buildActiveNowSection(bool isDark) {
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

  Widget _buildMessagesSection(bool isDark) {
    final chats = controller.activeChats;
    if (chats.isEmpty) {
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
            itemCount: chats.length,
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
              final chat = chats[index];
              return ChatTile(
                chat: chat,
                onLongPress: () => _showChatActionsSheet(
                  context: context,
                  chat: chat,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showChatActionsSheet({
    required BuildContext context,
    required ChatPreviewModel chat,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    "Delete Chat",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => Navigator.of(context).pop("delete"),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == "delete") {
      await controller.deleteChat(chat);
    }
  }
}