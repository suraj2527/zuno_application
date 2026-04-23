import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Nearly/presentation/chat/chat_screen.dart';
import 'package:Nearly/presentation/chat/chat_controller.dart';
import 'package:Nearly/presentation/profile/profile_tab.dart';
import 'package:Nearly/presentation/activity/activity_tab.dart';
import 'package:Nearly/presentation/activity/activity_controller.dart';
import '../../shared/constants/app_colors.dart';
import 'dashboard_controller.dart';
import '../home/home_tab.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activityController = Get.find<ActivityController>();
    final chatController = Get.find<ChatController>();

    final pages = [
      const HomeTab(),                                        // 0 – Home
      const ChatScreen(),                                    // 1 – Chats
      const ActivityTab(),                    // 2 – Likes
      ProfileTab(),                  // 3 – Profile
    ];

    return Scaffold(
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.white.withOpacity(0.08)
                    : AppColors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? Colors.white12 : AppColors.primary4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  4,
                  (i) => _NavItem(
                    index: i,
                    icon: _icons[i],
                    label: _labels[i],
                    isDark: isDark,
                    controller: controller,
                    activityController: activityController,
                    chatController: chatController,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.chat_bubble_rounded,
    Icons.favorite_rounded,
    Icons.person_rounded,
  ];

  static const List<String> _labels = [
    'Home',
    'Chats',
    'Activity',
    'Profile',
  ];
}

// ─────────────────────────────────────────────────
//  NAV ITEM
// ─────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isDark;
  final DashboardController controller;
  final ActivityController activityController;
  final ChatController chatController;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.controller,
    required this.activityController,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      final activeColor = isDark ? AppColors.primaryDark : AppColors.primary;
      final shouldShowActivityDot =
          index == 2 &&
          activityController.hasUnseenUpdates.value &&
          (activityController.likedProfiles.isNotEmpty ||
              activityController.matchedProfiles.isNotEmpty);
      final unreadChatCount = chatController.totalUnreadCount;
      final shouldShowChatCount = index == 1 && unreadChatCount > 0;

      return GestureDetector(
        onTap: () => controller.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? activeColor.withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 280),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        icon,
                        size: 24,
                        color: isSelected
                            ? activeColor
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                      if (shouldShowActivityDot)
                        Positioned(
                          right: -2,
                          top: -1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.cardDark
                                    : AppColors.white,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      if (shouldShowChatCount)
                        Positioned(
                          right: -9,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.cardDark
                                    : AppColors.white,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              unreadChatCount > 99
                                  ? "99+"
                                  : unreadChatCount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 280),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? activeColor
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
                child: Text(label),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
