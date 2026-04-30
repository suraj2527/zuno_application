import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:Nearly/presentation/home/home_controller.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_gradients.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';
import 'package:Nearly/shared/widgets/shimmers/shimmer_box.dart';

import '../../shared/widgets/common/app_refresh_wrapper.dart';
import '../../shared/widgets/common/Nearly_base_screen.dart';
import 'package:Nearly/core/routes/app_routes.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../chat/widgets/profile_detail_screen.dart';
import '../profile/explore_plans_screen.dart';

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final headerHeight = size.height * 0.12;
    final actionHeight = size.height * 0.14;
    final availableHeight = size.height - headerHeight - actionHeight - 120;
    final cardHeight = availableHeight.clamp(430.0, 590.0);

    return NearlyBaseScreen(
      isDark: isDark,
      child: SafeArea(
        bottom: false,
        child: AppRefreshWrapper(
          onRefresh: controller.refreshPage,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
              ],
            ),
          ),
        ),
      ),
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
    if (profile == null) return Container();

    return Stack(
      children: [
        Positioned.fill(
          child: Hero(
            tag: "profile_${profile.id}",
            child: profile.profileImageUrl.isNotEmpty
                ? Image.network(
                    profile.profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _profilePlaceholder(),
                  )
                : _profilePlaceholder(),
          ),
        ),
        _buildImageOverlay(profile),
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
                ? Image.network(
                    profile.profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _profilePlaceholder(),
                  )
                : _profilePlaceholder(),
          ),
        ),
        _buildImageOverlay(profile),
      ],
    );
  }

  Widget _buildImageOverlay(DatingProfile profile) {
    return Stack(
      children: [
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
    final hasLocation = _hasText(profile?.location);
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
          if (hasLocation) ...[
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
          ],
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
                  Image.asset('assets/images/dog.jpg', fit: BoxFit.cover),
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

          /// 🔥 TITLE
          Text(
            "You’re all caught up! 🥳",
            textAlign: TextAlign.center,
            style: AppTextStyles.headingLarge(
              isDark: isDark,
            ).copyWith(fontSize: 22, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 10),

          /// 💬 SUBTITLE
          Text(
            "We’re finding more amazing people for you.\nCheck back in a bit.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
              height: 1.4,
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeDynamicInfo(bool isDark, DatingProfile profile) {
    final hasLocation = _hasText(profile.location);
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
          if (hasLocation) ...[
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
          ],
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
              icon: Icons.keyboard_double_arrow_up_rounded,
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
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: _interactiveActionButton(
              onTap: () {
                final profile = controller.currentProfile;
                if (profile != null) {
                  if (controller.messagesSentCount.value >=
                      controller.directMessageLimit.value) {
                    _showSubscriptionDialog();
                  } else {
                    controller.pressGoldenChat(profile, _showGoldenChatDialog);
                  }
                }
              },
              pressed: controller.isGoldenChatPressed.value,
              disabled: disabled,
              child: _actionButton(
                icon: Icons.chat_bubble_rounded,
                isDark: isDark,
                size: 46,
                gradient: AppGradients.gold,
                bordered: false,
                iconColor: Colors.white,
              ),
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

  void _showGoldenChatDialog(DatingProfile profile) {
    final TextEditingController msgController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40), // More horizontal padding to make it smaller
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 80, // Smaller header
                    decoration: const BoxDecoration(
                      gradient: AppGradients.gold,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                  Positioned(
                    top: 25,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 32, // Smaller avatar
                        backgroundImage: profile.profileImageUrl.isNotEmpty
                            ? NetworkImage(profile.profileImageUrl)
                            : null,
                        backgroundColor: AppColors.primary5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      "Message ${profile.userName}",
                      style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: msgController,
                      maxLines: 3,
                      style: AppTextStyles.body(isDark: isDark).copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Write a message...",
                        hintStyle: AppTextStyles.bodySmall(isDark: isDark),
                        filled: true,
                        fillColor: isDark ? AppColors.inputFillDark : const Color(0xFFF6F7FB),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.inputBorderDark : const Color(0xFFEEEEEE),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Obx(() {
                      final remaining = controller.directMessageLimit.value - controller.messagesSentCount.value;
                      final isOutOfLimit = remaining <= 0;
                      
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (isOutOfLimit) {
                                Get.back();
                                _showSubscriptionDialog();
                                return;
                              }
                              final text = msgController.text.trim();
                              if (text.isEmpty) return;
                              
                              final success = await controller.sendDirectMessage(profile.id, text);
                              if (success) {
                                Get.back();
                                Get.snackbar(
                                  "Sent!", 
                                  "Your message is on its way ✨",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.primary,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: isOutOfLimit ? null : AppGradients.gold,
                                color: isOutOfLimit ? Colors.grey.shade400 : null,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  isOutOfLimit ? "Upgrade to Nearly Premium" : "Send Premium Message",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (!isOutOfLimit)
                            Text(
                              "$remaining free messages left",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.roseGold.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      transitionDuration: const Duration(milliseconds: 200),
      transitionCurve: Curves.easeOutCubic,
    );
  }

  void _showSubscriptionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, size: 60, color: AppColors.roseGold),
              const SizedBox(height: 16),
              Text(
                "Nearly Premium",
                style: AppTextStyles.headingLarge(isDark: isDark).copyWith(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                "Upgrade to send unlimited direct messages and boost your visibility!",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(isDark: isDark),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.to(() => const ExplorePlansScreen());
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Center(
                    child: Text(
                      "Explore Plans",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Not Now",
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
      transitionDuration: const Duration(milliseconds: 200),
      transitionCurve: Curves.easeOutCubic,
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

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
        child: Icon(Icons.person, size: 90, color: AppColors.white),
      ),
    );
  }
}


