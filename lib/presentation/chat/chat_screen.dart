import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Nearly/data/model/chat/chat_preview_model.dart';
import 'package:Nearly/presentation/chat/chat_controller.dart';
import 'package:Nearly/presentation/chat/widgets/chat_skeleton.dart';
import 'package:Nearly/presentation/chat/widgets/chat_tile.dart';
import 'package:Nearly/presentation/chat/widgets/empty_chat_view.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_gradients.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';
import 'package:Nearly/shared/widgets/common/app_refresh_wrapper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.find<ChatController>();
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.primary5,
        body: Column(
          children: [
            _buildGradientHeader(isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ChatSkeleton();
                }
                return AppRefreshWrapper(
                  onRefresh: controller.refreshChats,
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
                  child: _buildBody(isDark),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // GRADIENT HEADER
  // ═══════════════════════════════════════════════════════
  Widget _buildGradientHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                    style: AppTextStyles.headingLarge(isDark: false).copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Obx(() {
                    final total = controller.activeChats.length;
                    final unread = controller.activeChats
                        .where((c) => c.unreadCount > 0)
                        .length;
                    if (total == 0) {
                      return Text(
                        'No conversations yet',
                        style: AppTextStyles.bodySmall(isDark: false).copyWith(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                        ),
                      );
                    }
                    return Text(
                      unread > 0
                          ? '$total chats · $unread unread'
                          : '$total conversations',
                      style: AppTextStyles.bodySmall(isDark: false).copyWith(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // BODY
  // ═══════════════════════════════════════════════════════
  Widget _buildBody(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(isDark),
        const SizedBox(height: 20),
        _buildMessagesSection(isDark),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => _searchQuery.value = val.toLowerCase().trim(),
        style: AppTextStyles.bodySmall(isDark: isDark).copyWith(fontSize: 13),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: AppTextStyles.bodySmall(isDark: isDark).copyWith(
            color: isDark ? AppColors.textHintDark : AppColors.textHint,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.textHintDark : AppColors.textHint,
            size: 20,
          ),
          suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _searchQuery.value = '';
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    size: 18,
                  ),
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildMessagesSection(bool isDark) {
    return Obx(() {
      final query = _searchQuery.value;
      final allChats = controller.activeChats;

      final chats = query.isEmpty
          ? allChats
          : allChats
              .where((c) =>
                  c.name.toLowerCase().contains(query) ||
                  c.lastMessage.toLowerCase().contains(query))
              .toList();

      if (allChats.isEmpty) {
        return const EmptyChatView();
      }

      if (chats.isEmpty) {
        // No results for search
        return Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 52,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
                const SizedBox(height: 14),
                Text(
                  'No chats found for "$query"',
                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              query.isEmpty ? 'CONVERSATIONS' : 'RESULTS (${chats.length})',
              style: AppTextStyles.label(isDark: isDark).copyWith(
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            itemCount: chats.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: isDark
                    ? AppColors.inputBorderDark.withOpacity(0.25)
                    : AppColors.inputBorderLight.withOpacity(0.5),
                indent: 80,
                endIndent: 8,
              ),
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
        ],
      );
    });
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
