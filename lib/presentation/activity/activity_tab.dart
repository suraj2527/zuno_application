import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/presentation/home/home_controller.dart';
import 'package:zuno_application/shared/constants/app_colors.dart';
import 'package:zuno_application/shared/constants/app_text_styles.dart';
import 'package:zuno_application/shared/widgets/common/app_refresh_wrapper.dart';
import '../../shared/widgets/shimmers/shimmer_box.dart';
import '../../shared/widgets/common/zuno_base_screen.dart';
import '../chat/widgets/profile_detail_screen.dart';
import 'activity_controller.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab>
    with SingleTickerProviderStateMixin {
  ActivityController get controller => Get.find<ActivityController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.markAllActivitiesSeen();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ZunoBaseScreen(
      isDark: isDark,
      child: Column(
        children: [
          _buildTabBar(isDark),
      
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Obx(
                  () => AppRefreshWrapper(
                    onRefresh: controller.refreshActivity,
                    child: _buildLikesTab(isDark),
                  ),
                ),
                Obx(
                  () => AppRefreshWrapper(
                    onRefresh: controller.refreshActivity,
                    child: _buildMatchesTab(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ================= TAB BAR =================
  Widget _buildTabBar(bool isDark) {
    return Container(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark
            ? AppColors.textHintDark
            : AppColors.textHint,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Likes'),
          Tab(text: 'Matches'),
        ],
      ),
    );
  }

  // ================= LIKES TAB =================
  Widget _buildLikesTab(bool isDark) {
    if (controller.isLoading.value) {
      return Column(
        children: List.generate(6, (_) => _buildSkeletonItem(isDark)),
      );
    }

    if (controller.likedProfiles.isEmpty) {
      return _buildFullEmptyState(isDark);
    }

    /// ❗ FIX: NO ListView here
    return Column(
      children: controller.likedProfiles
          .map((profile) => _buildLikeItem(profile, isDark, type: 'like'))
          .toList(),
    );
  }

  Widget _buildLikeItem(
    DatingProfile profile,
    bool isDark, {
    required String type,
  }) {
    final isSeen = controller.isActivitySeen(type, profile);
    final bgColor = isDark
        ? AppColors.inputFillDark.withOpacity(isSeen ? 0.38 : 0.88)
        : AppColors.inputFillLight.withOpacity(isSeen ? 0.45 : 1);
    final borderColor = isDark
        ? AppColors.inputBorderDark.withOpacity(isSeen ? 0.4 : 0.9)
        : AppColors.inputBorderLight.withOpacity(isSeen ? 0.55 : 1);
    final textOpacity = isSeen ? 0.72 : 1.0;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            controller.markActivitySeen(type, profile);
            Get.to(
              () => ProfileDetailsScreen(
                profile: profile,
                heroTag: "liked_${profile.id}",
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(isSeen ? 0.18 : 0.28)
                      : Colors.black.withOpacity(isSeen ? 0.03 : 0.06),
                  blurRadius: isSeen ? 8 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                /// Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: profile.profileImageUrl.trim().isNotEmpty
                        ? Image.network(
                            profile.profileImageUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, size: 24),
                          )
                        : const Icon(Icons.person, size: 24),
                  ),
                ),

                const SizedBox(width: 12),

                /// Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${profile.userName} ${profile.age}",
                        style: AppTextStyles.headingMedium(
                          isDark: isDark,
                        ).copyWith(
                          fontSize: 14,
                          fontWeight: isSeen ? FontWeight.w500 : FontWeight.w700,
                          color: (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary)
                              .withOpacity(textOpacity),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall(
                          isDark: isDark,
                        ).copyWith(
                          fontSize: 12,
                          color: (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary)
                              .withOpacity(textOpacity),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Trailing (time + action)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "2h",
                      style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isSeen ? 0 : 1,
                      child: isSeen
                          ? const SizedBox(width: 12, height: 12)
                          : Container(
                              width: 10,
                              height: 10,
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
                  ],
                ),
              ],
            ),
          ),
        ),

        /// Divider (very subtle)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 10,
            thickness: 0.5,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  // ================= MATCHES TAB =================
  Widget _buildMatchesTab(bool isDark) {
    if (controller.isLoading.value) {
      return Column(
        children: List.generate(6, (_) => _buildSkeletonItem(isDark)),
      );
    }

    if (controller.matchedProfiles.isEmpty) {
      return _buildFullEmptyState(isDark);
    }

    return Column(
      children: controller.matchedProfiles
          .map((profile) => _buildLikeItem(profile, isDark, type: 'match'))
          .toList(),
    );
  }

  // ================= SKELETON =================
  Widget _buildSkeletonItem(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: ShimmerWrapper(
        child: Row(
          children: [
            ShimmerBox(width: 64, height: 64, radius: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  ShimmerBox(width: 120, height: 16),
                  const SizedBox(height: 8),
                  ShimmerBox(width: double.infinity, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EMPTY =================
  Widget _buildFullEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 170,
              height: 170,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.28 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: isDark ? AppColors.cardDark : AppColors.white,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/dog.jpg',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            (isDark ? AppColors.cardDark : AppColors.white)
                                .withOpacity(0.12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              "You’re all caught up! 🥳",
              style: AppTextStyles.headingLarge(isDark: isDark),
            ),
            const SizedBox(height: 10),
            Text(
              "Check back later for more activity",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
