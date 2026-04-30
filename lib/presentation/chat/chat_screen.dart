import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Nearly/data/model/chat/chat_preview_model.dart';
import 'package:Nearly/presentation/chat/chat_controller.dart';
import 'package:Nearly/presentation/chat/widgets/chat_skeleton.dart';
import 'package:Nearly/presentation/chat/widgets/chat_tile.dart';
import 'package:Nearly/presentation/chat/widgets/empty_chat_view.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
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
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : const Color(0xFFF8F8FB),
        body: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ChatSkeleton();
                }
                return AppRefreshWrapper(
                  onRefresh: controller.refreshChats,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
  // CLEAN WHITE HEADER
  // ═══════════════════════════════════════════════════════
  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.inputBorderDark : const Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messages',
                      style: AppTextStyles.headingLarge(isDark: isDark).copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
                      final total = controller.activeChats.length;
                      final unread = controller.activeChats
                          .where((c) => c.unreadCount > 0)
                          .length;
                      final label = total == 0
                          ? 'No conversations yet'
                          : unread > 0
                              ? '$total chats · $unread unread'
                              : '$total conversations';
                      return Text(
                        label,
                        style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                          fontSize: 12,
                          color: unread > 0
                              ? AppColors.primary
                              : (isDark ? AppColors.textHintDark : AppColors.textHint),
                          fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // Compose button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
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
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.inputBorderDark : const Color(0xFFEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => _searchQuery.value = val.toLowerCase().trim(),
        style: AppTextStyles.bodySmall(isDark: isDark).copyWith(fontSize: 14),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: AppTextStyles.bodySmall(isDark: isDark).copyWith(
            color: isDark ? AppColors.textHintDark : AppColors.textHint,
            fontSize: 14,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
        return Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 36,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No results for "$query"',
                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Try a different name or keyword',
                  style: AppTextStyles.bodySmall(isDark: isDark),
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
            padding: const EdgeInsets.only(left: 4, bottom: 12),
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
          // Use spacing instead of hard dividers
          ...List.generate(chats.length, (index) {
            final chat = chats[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChatTile(
                chat: chat,
                onLongPress: () => _showChatActionsSheet(
                  context: context,
                  chat: chat,
                ),
              ),
            );
          }),
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
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Wrap(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  ),
                  title: const Text(
                    "Delete Chat",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
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
