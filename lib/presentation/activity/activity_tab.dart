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
          .map((profile) => _buildLikeItem(profile, isDark))
          .toList(),
    );
  }

  Widget _buildLikeItem(DatingProfile profile, bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Get.to(
              () => ProfileDetailsScreen(
                profile: profile,
                heroTag: "liked_${profile.id}",
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(14),

              /// ✅ NEW: subtle border
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.06),
                width: 1,
              ),

              /// ✅ Improved shadow (less muddy, more lifted)
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.35)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                /// Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(profile.profileImageUrl),
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
                        ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall(
                          isDark: isDark,
                        ).copyWith(fontSize: 12),
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

                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.red,
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
          .map((profile) => _buildLikeItem(profile, isDark))
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
            const SizedBox(height: 40),
            const Icon(Icons.hourglass_empty, size: 80),
            const SizedBox(height: 20),
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
