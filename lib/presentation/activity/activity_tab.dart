import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Nearly/presentation/home/home_controller.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_gradients.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';
import 'package:Nearly/shared/widgets/common/app_refresh_wrapper.dart';
import '../../shared/widgets/shimmers/shimmer_box.dart';
import '../chat/widgets/profile_detail_screen.dart';
import 'activity_controller.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  ActivityController get controller => Get.find<ActivityController>();
  final RxString _selectedTab = 'Likes'.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.markAllActivitiesSeen();
    });
  }

  @override
  void dispose() {
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
                  'Activity',
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
                  final isLikes = _selectedTab.value == 'Likes';
                  final profiles = isLikes
                      ? controller.likedProfiles
                      : controller.matchedProfiles;

                  if (controller.isLoading.value) {
                    return AppRefreshWrapper(
                      onRefresh: controller.refreshActivity,
                      child: _buildGrid(isDark, isLoading: true, profiles: []),
                    );
                  }

                  if (profiles.isEmpty) {
                    return _buildElegantEmptyState(isDark, isLikes: isLikes);
                  }

                  return AppRefreshWrapper(
                    onRefresh: controller.refreshActivity,
                    child: _buildGrid(
                      isDark,
                      isLoading: false,
                      profiles: profiles,
                      type: isLikes ? 'like' : 'match',
                    ),
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
    final tabs = ['Likes', 'Matches'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: tabs.map((tab) {
          return Obx(() {
            final isSelected = _selectedTab.value == tab;
            final count = tab == 'Likes'
                ? controller.likedProfiles.length
                : controller.matchedProfiles.length;
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
                child: Row(
                  children: [
                    Text(
                      tab,
                      style: TextStyle(
                        color: isSelected
                            ? (isDark
                                  ? AppColors.primaryDark
                                  : const Color(0xFF3B82F6))
                            : (isDark ? Colors.white54 : Colors.black54),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      _tabBadge(count),
                    ],
                  ],
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _tabBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildContentTab(bool isDark, {required bool isLikes}) {
    return Obx(() {
      final profiles = isLikes
          ? controller.likedProfiles
          : controller.matchedProfiles;

      if (controller.isLoading.value) {
        return AppRefreshWrapper(
          onRefresh: controller.refreshActivity,
          child: _buildGrid(isDark, isLoading: true, profiles: []),
        );
      }

      if (profiles.isEmpty) {
        return _buildElegantEmptyState(isDark, isLikes: isLikes);
      }

      return AppRefreshWrapper(
        onRefresh: controller.refreshActivity,
        child: _buildGrid(
          isDark,
          isLoading: false,
          profiles: profiles,
          type: isLikes ? 'like' : 'match',
        ),
      );
    });
  }

  Widget _buildGrid(
    bool isDark, {
    required bool isLoading,
    required List<DatingProfile> profiles,
    String type = 'like',
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: isLoading ? 6 : profiles.length,
      itemBuilder: (context, index) {
        if (isLoading) return _buildGridSkeletonCard(isDark);
        return _buildElegantGridCard(isDark, profiles[index], type);
      },
    );
  }

  Widget _buildElegantGridCard(
    bool isDark,
    DatingProfile profile,
    String type,
  ) {
    return GestureDetector(
      onTap: () {
        controller.markActivitySeen(type, profile);
        Get.to(
          () => ProfileDetailsScreen(
            profile: profile,
            heroTag: "${type}_${profile.id}",
            isFromMatches: type == 'match',
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: Hero(
                  tag: "${type}_${profile.id}",
                  child: profile.profileImageUrl.isNotEmpty
                      ? Image.network(
                          profile.profileImageUrl,
                          fit: BoxFit.cover,
                        )
                      : _profilePlaceholder(),
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Info
              Positioned(
                bottom: 12,
                left: 12,
                right: type == 'like' ? 48 : 12, // Leave space for like button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${profile.userName}, ${profile.age}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 10,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.location.isNotEmpty
                                ? profile.location
                                : "Nearby",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (type == 'like')
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Obx(() {
                    final isLiked = controller.likedProfileIds.contains(
                      profile.id,
                    );
                    return _LikeButton(
                      isLiked: isLiked,
                      onTap: isLiked
                          ? null
                          : () => controller.likeProfile(profile),
                    );
                  }),
                ),

              if (!controller.isActivitySeen(type, profile))
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridSkeletonCard(bool isDark) {
    return ShimmerWrapper(
      isLoading: true,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const ShimmerBox(radius: 24),
      ),
    );
  }

  Widget _profilePlaceholder() {
    return Container(
      color: const Color(0xFFF2F4FF),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
      ),
    );
  }

  Widget _buildElegantEmptyState(bool isDark, {required bool isLikes}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLikes
                    ? Icons.favorite_border_rounded
                    : Icons.flash_on_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isLikes ? "No likes yet" : "No matches yet",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isLikes
                  ? "Keep swiping! Your profile is being seen by many potential matches."
                  : "The magic happens when both of you like each other. Keep exploring!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black45,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ANIMATED LIKE BUTTON WIDGET =================
class _LikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback? onTap;

  const _LikeButton({required this.isLiked, this.onTap});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    _anim.forward(from: 0);
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLiked ? null : _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: widget.isLiked ? null : AppGradients.primary,
            color: widget.isLiked ? Colors.grey.withOpacity(0.3) : null,
            shape: BoxShape.circle,
            boxShadow: widget.isLiked
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
