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
  final RxString _selectedTab = 'Mutual'.obs;
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
        backgroundColor: isDark ? AppColors.scaffoldDark : Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              _buildTabSelector(isDark),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const ChatSkeleton();
                  }

                  // Filter based on tab and search
                  final chats = _getFilteredChats();

                  if (chats.isEmpty) {
                    return const EmptyChatView();
                  }

                  return AppRefreshWrapper(
                    key: ValueKey('chats_${_selectedTab.value}_${_searchQuery.value}'),
                    onRefresh: controller.refreshChats,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        sliver: SliverToBoxAdapter(
                          child: _buildPremiumSearchBar(isDark),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : const Color(0xFFEEEEEE),
                              ),
                            ),
                            child: _buildMessagesList(chats, isDark),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    final tabs = ['Mutual', 'Chat requests'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: tabs.map((tab) {
          return Obx(() {
            final isSelected = _selectedTab.value == tab;
            return GestureDetector(
              onTap: () => _selectedTab.value = tab,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? AppColors.primary.withOpacity(0.2)
                            : const Color(0xFFE6F0FF))
                      : (isDark ? AppColors.cardDark : const Color(0xFFF6F6F6)),
                  borderRadius: BorderRadius.circular(100),
                  border: isSelected && isDark
                      ? Border.all(color: AppColors.primary.withOpacity(0.5))
                      : null,
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark
                              ? AppColors.primaryDark
                              : const Color(0xFF3B82F6))
                        : (isDark ? Colors.white54 : Colors.black54),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  List<ChatPreviewModel> _getFilteredChats() {
    final query = _searchQuery.value;
    // In a real app, 'Mutual' vs 'Requests' would be a field in the model.
    // For now we'll just show the same list or filter based on a dummy condition.
    final allChats = controller.activeChats;

    // Logic: Mutual = chats with messages/matches, Requests = chats from non-matches (placeholder logic)
    var filtered = allChats;
    if (_selectedTab.value == 'Chat requests') {
      // Mock: show nothing or special requests
      filtered = [];
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (c) =>
                c.name.toLowerCase().contains(query) ||
                c.lastMessage.toLowerCase().contains(query),
          )
          .toList();
    }
    return filtered;
  }

  Widget _buildPremiumSearchBar(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(100),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => _searchQuery.value = val.toLowerCase().trim(),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search people or messages',
          hintStyle: TextStyle(
            color: isDark ? Colors.white24 : Colors.black26,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white24 : Colors.black26,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildMessagesList(List<ChatPreviewModel> chats, bool isDark) {
    if (chats.isEmpty && _searchQuery.value.isNotEmpty) {
      return _buildNoResults(_searchQuery.value);
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chats.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 0.8,
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF5F5F5),
        indent: 88,
      ),
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatTile(
          chat: chat,
          onLongPress: () =>
              _showChatActionsSheet(context: context, chat: chat),
        );
      },
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
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
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
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
