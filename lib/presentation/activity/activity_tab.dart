import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nearly/presentation/home/home_controller.dart';
import 'package:nearly/shared/constants/app_colors.dart';
import 'package:nearly/shared/constants/app_gradients.dart';
import 'package:nearly/shared/constants/app_text_styles.dart';
import 'package:nearly/shared/widgets/common/app_refresh_wrapper.dart';
import '../../shared/widgets/shimmers/shimmer_box.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.primary5,
        body: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Obx(() {
                    if (controller.isLoading.value) {
                      return AppRefreshWrapper(
                        onRefresh: controller.refreshActivity,
                        child: _buildLikesTab(isDark),
                      );
                    }
                    if (controller.likedProfiles.isEmpty) {
                      return AppRefreshWrapper(
                        onRefresh: controller.refreshActivity,
                        child: _buildFullEmptyState(isDark, isLikes: true),
                      );
                    }
                    return AppRefreshWrapper(
                      onRefresh: controller.refreshActivity,
                      child: _buildLikesTab(isDark),
                    );
                  }),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return AppRefreshWrapper(
                        onRefresh: controller.refreshActivity,
                        child: _buildMatchesTab(isDark),
                      );
                    }
                    if (controller.matchedProfiles.isEmpty) {
                      return AppRefreshWrapper(
                        onRefresh: controller.refreshActivity,
                        child: _buildFullEmptyState(isDark, isLikes: false),
                      );
                    }
                    return AppRefreshWrapper(
                      onRefresh: controller.refreshActivity,
                      child: _buildMatchesTab(isDark),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= GRADIENT HEADER =================
  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity',
                        style: AppTextStyles.headingLarge(isDark: false).copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Obx(() {
                        final likes = controller.likedProfiles.length;
                        final matches = controller.matchedProfiles.length;
                        return Text(
                          '$likes new likes · $matches matches',
                          style: AppTextStyles.bodySmall(isDark: false).copyWith(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 11,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Custom tab bar on gradient
            TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.55),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.white, width: 2.5),
                insets: EdgeInsets.symmetric(horizontal: 20),
              ),
              tabs: [
                Obx(() => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Likes'),
                      if (controller.likedProfiles.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _tabBadge(controller.likedProfiles.length),
                      ],
                    ],
                  ),
                )),
                Obx(() => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Matches'),
                      if (controller.matchedProfiles.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _tabBadge(controller.matchedProfiles.length),
                      ],
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ================= LIKES TAB =================
  Widget _buildLikesTab(bool isDark) {
    if (controller.isLoading.value) {
      return _buildGridWrapper(
        children: List.generate(6, (_) => _buildGridSkeletonCard(isDark)),
      );
    }

    return _buildGridWrapper(
      children: controller.likedProfiles.map((profile) {
        return _buildGridCard(isDark, profile, type: 'like');
      }).toList(),
    );
  }

  Widget _buildGridWrapper({required List<Widget> children}) {
    final width = MediaQuery.of(context).size.width;
    final itemWidth = (width - 48) / 2;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: children.map((child) {
          return SizedBox(
            width: itemWidth,
            child: AspectRatio(
              aspectRatio: 0.62,
              child: child,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= MATCHES TAB =================
  Widget _buildMatchesTab(bool isDark) {
    if (controller.isLoading.value) {
      return _buildGridWrapper(
        children: List.generate(6, (_) => _buildGridSkeletonCard(isDark)),
      );
    }

    return _buildGridWrapper(
      children: controller.matchedProfiles.map((profile) {
        return _buildGridCard(isDark, profile, type: 'match');
      }).toList(),
    );
  }

  // ================= GRID CARD =================
  Widget _buildGridCard(bool isDark, DatingProfile profile, {required String type}) {
    return GestureDetector(
      onTap: () {
        controller.markActivitySeen(type, profile);
        Get.to(
          () => ProfileDetailsScreen(
            profile: profile,
            heroTag: "${type}_${profile.id}",
            openedFrom: type == 'like'
                ? ProfileOpenedFrom.likes
                : ProfileOpenedFrom.matches,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Expanded(flex: 8, child: _buildGridImageSection(profile, type)),
              Expanded(flex: 4, child: _buildGridDynamicInfo(isDark, profile, type)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridImageSection(DatingProfile profile, String type) {
    return Stack(
      children: [
        Positioned.fill(
          child: Hero(
            tag: "${type}_${profile.id}",
            child: profile.profileImageUrl.isNotEmpty
                ? Image.network(
                    profile.profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _profilePlaceholder(),
                  )
                : _profilePlaceholder(),
          ),
        ),
        // Bottom gradient for text legibility
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.transparent, AppColors.swipeOverlayDark],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridDynamicInfo(bool isDark, DatingProfile profile, String type) {
    final hasLocation = _hasText(profile.location);
    final showLikeButton = type == 'like';

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.inputFillDark
            : AppColors.primary5,
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 8, showLikeButton ? 38 : 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headingLarge(isDark: isDark).copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      profile.age,
                      style: AppTextStyles.headingMedium(isDark: isDark).copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  profile.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(fontSize: 10),
                ),
                if (hasLocation) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 10,
                        color: isDark ? AppColors.textHintDark : AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          profile.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall(isDark: isDark).copyWith(fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          /// 🔥 ANIMATED LIKE BUTTON
          if (showLikeButton)
            Positioned(
              right: 8,
              bottom: 8,
              child: Obx(() {
                final isLiked = controller.likedProfileIds.contains(profile.id);
                return _LikeButton(
                  isLiked: isLiked,
                  onTap: isLiked ? null : () => controller.likeProfile(profile.id),
                );
              }),
            ),
        ],
      ),
    );
  }

  // ================= SKELETON =================
  Widget _buildGridSkeletonCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: ShimmerWrapper(
                child: Container(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                color: isDark ? AppColors.inputFillDark : AppColors.primary5,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: ShimmerWrapper(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 70, height: 13, radius: 4),
                      SizedBox(height: 6),
                      ShimmerBox(width: double.infinity, height: 9, radius: 4),
                      SizedBox(height: 4),
                      ShimmerBox(width: 80, height: 9, radius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasText(String? text) => text != null && text.trim().isNotEmpty;

  Widget _profilePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.profilePlaceholderStart,
            AppColors.profilePlaceholderEnd,
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 60, color: AppColors.white),
      ),
    );
  }

  // ================= EMPTY =================
  Widget _buildFullEmptyState(bool isDark, {bool isLikes = true}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/dog.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 28),
          ShaderMask(
            shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
            child: Text(
              isLikes ? "No likes yet! 🐾" : "No matches yet! 🐾",
              style: AppTextStyles.headingLarge(isDark: isDark).copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isLikes
                ? "Keep swiping, someone will like you!"
                : "Keep swiping to find your match!",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
            ),
          ),
        ],
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
          child: Icon(
            widget.isLiked ? Icons.favorite_rounded : Icons.favorite_rounded,
            size: 18,
            color: widget.isLiked ? Colors.white54 : Colors.white,
          ),
        ),
      ),
    );
  }
}
