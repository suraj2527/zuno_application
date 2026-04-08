import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:zuno_application/presentation/screens/Dashboard/home/home_controller.dart';
import 'package:zuno_application/utils/constants/app_colors.dart';
import 'package:zuno_application/utils/constants/app_gradients.dart';
import 'package:zuno_application/utils/constants/app_text_styles.dart';
import 'package:zuno_application/widgets/common/shimmer_box.dart';

import '../../../../widgets/common/app_refresh_wrapper.dart';
import '../Chat/widgets/profile_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  HomeController get controller => Get.find<HomeController>();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final headerHeight = size.height * 0.12;
    final actionHeight = size.height * 0.14;
    final availableHeight = size.height - headerHeight - actionHeight - 120;
    final cardHeight = availableHeight.clamp(430.0, 590.0);

    return Container(
      color: isDark ? AppColors.scaffoldDark : AppColors.primary5,
      child: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: AppRefreshWrapper(
              onRefresh: controller.refreshPage,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: cardHeight,
                      child: _buildCardStack(isDark, cardHeight),
                    ),
                    const SizedBox(height: 18),
                    _buildActionButtons(isDark),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.primary.createShader(bounds),
              child: Text(
                'zuno',
                style: AppTextStyles.logo(
                  isDark: false,
                ).copyWith(color: AppColors.white, fontSize: 30, height: 1),
              ),
            ),
            Row(
              children: [
                _headerIcon(
                  icon: Icons.bookmark_border_rounded,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _headerIcon(
                  icon: Icons.groups_2_outlined,
                  badge: '3',
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _headerIcon(
                  icon: Icons.notifications_none_rounded,
                  badge: '5',
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIcon({
    required IconData icon,
    required bool isDark,
    String? badge,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? AppColors.inputFillDark : AppColors.primary5,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        if (badge != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                badge,
                style: AppTextStyles.label(
                  isDark: true,
                ).copyWith(color: AppColors.white, fontSize: 7, height: 1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardStack(bool isDark, double cardHeight) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 12,
              left: 26,
              right: 26,
              child: _stackLayer(opacity: 0.35, isDark: isDark),
            ),
            Positioned(
              top: 6,
              left: 16,
              right: 16,
              child: _stackLayer(opacity: 0.55, isDark: isDark),
            ),
            Positioned.fill(top: 0, child: _buildMainCard(isDark, cardHeight)),
          ],
        );
      }

      if (controller.profiles.isEmpty) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 12,
              left: 26,
              right: 26,
              child: _stackLayer(opacity: 0.35, isDark: isDark),
            ),
            Positioned(
              top: 6,
              left: 16,
              right: 16,
              child: _stackLayer(opacity: 0.55, isDark: isDark),
            ),
            Positioned.fill(top: 0, child: _buildMainCard(isDark, cardHeight)),
          ],
        );
      }

      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 12,
            left: 26,
            right: 26,
            child: _stackLayer(opacity: 0.35, isDark: isDark),
          ),
          Positioned(
            top: 6,
            left: 16,
            right: 16,
            child: _stackLayer(opacity: 0.55, isDark: isDark),
          ),
          Positioned.fill(
            top: 0,
            child: CardSwiper(
              key: ValueKey(controller.profiles.length),
              controller: controller.cardSwiperController,
              cardsCount: controller.profiles.length,
              numberOfCardsDisplayed: controller.profiles.length >= 2
                  ? 2
                  : controller.profiles.length,
              backCardOffset: const Offset(0, -2),
              padding: EdgeInsets.zero,
              isLoop: false,
              scale: 0.96,
              threshold: 35,
              duration: const Duration(milliseconds: 220),
              maxAngle: 18,
              allowedSwipeDirection: const AllowedSwipeDirection.only(
                left: true,
                right: true,
                up: true,
              ),
              onSwipe: (previousIndex, currentIndex, direction) {
                if (direction == CardSwiperDirection.left) {
                  controller.onSwipeLeft(previousIndex);
                } else if (direction == CardSwiperDirection.right) {
                  controller.onSwipeRight(previousIndex);
                } else if (direction == CardSwiperDirection.top) {
                  controller.onSwipeUp(previousIndex);
                }
                return true;
              },
              cardBuilder:
                  (
                    context,
                    index,
                    horizontalThresholdPercentage,
                    verticalThresholdPercentage,
                  ) {
                    final profile = controller.profiles[index];
                    return _buildSwipeCard(isDark, cardHeight, profile);
                  },
            ),
          ),
        ],
      );
    });
  }

  Widget _stackLayer({required double opacity, required bool isDark}) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.cardLight).withOpacity(
          opacity,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(bool isDark, double cardHeight) {
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Obx(() {
          /// 🔥 EMPTY STATE (FULL CARD)
          if (!controller.isLoading.value &&
              controller.currentProfile == null) {
            return _buildFullEmptyState(isDark);
          }

          /// 🔥 NORMAL CARD
          return Column(
            children: [
              Expanded(
                flex: 7,
                child: controller.isLoading.value
                    ? _buildImageSkeleton(isDark)
                    : _buildImageSection(),
              ),
              Expanded(
                flex: 4,
                child: controller.isLoading.value
                    ? _buildSkeletonInfo()
                    : _buildDynamicInfo(isDark),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSwipeCard(
    bool isDark,
    double cardHeight,
    DatingProfile profile,
  ) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProfileDetailsScreen(
            profile: profile,
            heroTag: "profile_${profile.id}",
          ),
        );
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              Expanded(flex: 7, child: _buildSwipeImageSection(profile)),
              Expanded(flex: 4, child: _buildSwipeDynamicInfo(isDark, profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSkeleton(bool isDark) {
    return ShimmerWrapper(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
            ),
          ),
          const Center(child: ShimmerBox(width: 90, height: 90, radius: 45)),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const ShimmerBox(width: 78, height: 12, radius: 20),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const ShimmerBox(width: 54, height: 12, radius: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final profile = controller.currentProfile;

    if (profile == null) {
      return Container();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: profile.profileImageUrl.isNotEmpty
              ? Image.network(profile.profileImageUrl, fit: BoxFit.cover)
              : Container(
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
                    child: Icon(Icons.person, size: 90, color: AppColors.white),
                  ),
                ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 120,
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
        Positioned(
          top: 14,
          left: 14,
          child: _chip(
            text: profile.isActiveNow ? '🟢 Active now' : '⚪ Offline',
            textColor: profile.isActiveNow
                ? AppColors.green
                : AppColors.textHint,
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: _chip(text: profile.distance, textColor: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSwipeImageSection(DatingProfile profile) {
    return Stack(
      children: [
        Positioned.fill(
          child: Hero(
            tag: "profile_${profile.id}",
            child: profile.profileImageUrl.isNotEmpty
                ? Image.network(profile.profileImageUrl, fit: BoxFit.cover)
                : Container(
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
                      child: Icon(
                        Icons.person,
                        size: 90,
                        color: AppColors.white,
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 120,
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
        Positioned(
          top: 14,
          left: 14,
          child: _chip(
            text: profile.isActiveNow ? '🟢 Active now' : '⚪ Offline',
            textColor: profile.isActiveNow
                ? AppColors.green
                : AppColors.textHint,
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: _chip(text: profile.distance, textColor: AppColors.primary),
        ),
      ],
    );
  }

  Widget _chip({required String text, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall().copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSkeletonInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: ShimmerWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                ShimmerBox(width: 120, height: 24, radius: 8),
                SizedBox(width: 8),
                ShimmerBox(width: 26, height: 18, radius: 6),
              ],
            ),
            const SizedBox(height: 10),
            const ShimmerBox(width: double.infinity, height: 12, radius: 6),
            const SizedBox(height: 6),
            const ShimmerBox(width: 220, height: 12, radius: 6),
            const SizedBox(height: 12),
            Row(
              children: const [
                ShimmerBox(width: 16, height: 16, radius: 8),
                SizedBox(width: 6),
                Expanded(
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 11,
                    radius: 6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                ShimmerBox(width: 60, height: 30, radius: 50),
                ShimmerBox(width: 74, height: 30, radius: 50),
                ShimmerBox(width: 68, height: 30, radius: 50),
                ShimmerBox(width: 58, height: 30, radius: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicInfo(bool isDark) {
    final profile = controller.currentProfile;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                profile?.userName ?? '',
                style: AppTextStyles.headingLarge(isDark: isDark),
              ),
              const SizedBox(width: 6),
              Text(
                profile?.age ?? '',
                style: AppTextStyles.headingMedium(isDark: isDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profile?.bio ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium(isDark: isDark),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  profile?.location ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile!.interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.inputFillDark : AppColors.primary5,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  interest,
                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

Widget _buildFullEmptyState(bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : AppColors.white.withOpacity(0.06),
          ),
          child: SizedBox(
            height: 150,
            child: Image.asset(
              'assets/images/dog.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 26),

        /// 🔥 TITLE
        Text(
          "You’re all caught up! 🥳",
          textAlign: TextAlign.center,
          style: AppTextStyles.headingLarge(isDark: isDark).copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        /// 💬 SUBTITLE
        Text(
          "We’re finding more amazing people for you.\nCheck back in a bit.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
            height: 1.4,
            color: isDark
                ? AppColors.textHintDark
                : AppColors.textHint,
          ),
        ),
      ],
    ),
  );
}
  Widget _buildSwipeDynamicInfo(bool isDark, DatingProfile profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                profile.userName,
                style: AppTextStyles.headingLarge(isDark: isDark),
              ),
              const SizedBox(width: 6),
              Text(
                profile.age,
                style: AppTextStyles.headingMedium(isDark: isDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profile.bio,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium(isDark: isDark),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  profile.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.inputFillDark : AppColors.primary5,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  interest,
                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Obx(() {
      final disabled = controller.isLoading.value || !controller.hasProfiles;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _interactiveActionButton(
            onTap: controller.pressDislike,
            pressed: controller.isDislikePressed.value,
            disabled: disabled,
            child: _actionButton(
              icon: Icons.close_rounded,
              isDark: isDark,
              size: 54,
              gradient: null,
              bordered: true,
            ),
          ),
          const SizedBox(width: 16),
          _interactiveActionButton(
            onTap: controller.pressStar,
            pressed: controller.isStarPressed.value,
            disabled: disabled,
            child: _actionButton(
              icon: Icons.star_rounded,
              isDark: isDark,
              size: 46,
              gradient: null,
              bordered: true,
            ),
          ),
          const SizedBox(width: 16),
          _interactiveActionButton(
            onTap: controller.pressLike,
            pressed: controller.isLikePressed.value,
            disabled: disabled,
            child: _actionButton(
              icon: Icons.favorite_rounded,
              isDark: isDark,
              size: 54,
              gradient: AppGradients.primary,
              bordered: false,
              iconColor: AppColors.white,
            ),
          ),
          const SizedBox(width: 16),
          _interactiveActionButton(
            onTap: controller.pressBoost,
            pressed: controller.isBoostPressed.value,
            disabled: disabled,
            child: _actionButton(
              icon: Icons.flash_on_rounded,
              isDark: isDark,
              size: 46,
              gradient: AppGradients.gold,
              bordered: false,
              iconColor: AppColors.goldIcon,
            ),
          ),
        ],
      );
    });
  }

  Widget _interactiveActionButton({
    required VoidCallback onTap,
    required bool pressed,
    required bool disabled,
    required Widget child,
  }) {
    return AnimatedScale(
      scale: pressed ? 0.88 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: disabled ? 0.45 : 1,
        child: IgnorePointer(
          ignoring: disabled,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required bool isDark,
    required double size,
    required bool bordered,
    LinearGradient? gradient,
    Color? iconColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradient == null
            ? (isDark ? AppColors.cardDark : AppColors.cardLight)
            : null,
        gradient: gradient,
        shape: BoxShape.circle,
        border: bordered
            ? Border.all(
                color: isDark ? AppColors.inputBorderDark : AppColors.primary4,
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size == 54 ? 26 : 22,
        color:
            iconColor ??
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
      ),
    );
  }
}
