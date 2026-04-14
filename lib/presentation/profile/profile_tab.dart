import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/presentation/profile/edit_profile_screen.dart';
import 'package:zuno_application/presentation/profile/profile_controller.dart';
import 'package:zuno_application/shared/constants/app_colors.dart';
import 'package:zuno_application/shared/constants/app_gradients.dart';
import 'package:zuno_application/shared/constants/app_text_styles.dart';
import 'package:zuno_application/shared/widgets/common/app_refresh_wrapper.dart';
import 'package:zuno_application/shared/widgets/common/zuno_base_screen.dart';
import 'package:zuno_application/shared/widgets/shimmers/shimmer_box.dart';

class ProfileTab extends StatelessWidget {
  ProfileTab({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ZunoBaseScreen(
      isDark: isDark,
      child: Material(
        color: Colors.transparent,
        child: AppRefreshWrapper(
          onRefresh: () async => controller.loadProfileData(),
          child: Obx(() {
            final profile = controller.profile.value;

            if (controller.isLoading.value || profile == null) {
              if (!controller.isLoading.value) {
                Future.microtask(() => controller.loadProfileData());
              }
              return _buildProfileShimmer(isDark);
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(isDark, profile),
                  const SizedBox(height: 18),
                  _buildGallerySection(isDark, profile.imageUrls),
                  const SizedBox(height: 18),
                  _buildBioCard(isDark, profile.bio),
                  const SizedBox(height: 14),
                  _buildInfoCard(
                    isDark: isDark,
                    title: "Location",
                    value: profile.location,
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildInfoCard(
                    isDark: isDark,
                    title: "Gender",
                    value: (profile.gender ?? '').isNotEmpty
                        ? profile.gender!
                        : "Not added",
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildInfoCard(
                    isDark: isDark,
                    title: "Looking For",
                    value: (profile.lookingFor ?? '').isNotEmpty
                        ? profile.lookingFor!
                        : "Not added",
                    icon: Icons.favorite_border_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildInterestsCard(isDark, profile.interests),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, dynamic profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// ⚙️ SETTINGS (TOP RIGHT)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),

          /// 🎯 CENTERED CONTENT
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: "my_profile_avatar",
                  child: Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.primary,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: _buildImage(
                        controller.selectedProfileImage.value.isNotEmpty
                            ? controller.selectedProfileImage.value
                            : profile.profileImageUrl,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  "${controller.nameController.text.isNotEmpty ? controller.nameController.text : profile.userName}, ${profile.age}",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingLarge(
                    isDark: isDark,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 12),

                /// ✏️ EDIT BUTTON
                GestureDetector(
                  onTap: () => Get.to(() => EditProfileScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.inputFillDark
                          : AppColors.primary5,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_outlined, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "Edit Profile",
                          style: AppTextStyles.bodySmall(
                            isDark: isDark,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 🚪 LOGOUT BUTTON
                GestureDetector(
                  onTap: () => controller.logout(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Logout",
                          style: AppTextStyles.bodySmall(isDark: isDark)
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(bool isDark, List<String> images) {
    return _sectionCard(
      isDark: isDark,
      title: "Photos",
      child: images.isEmpty
          ? Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputFillDark : AppColors.primary5,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "No gallery photos added yet",
                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                CarouselSlider.builder(
                  itemCount: images.length,
                  options: CarouselOptions(
                    height: 240,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: images.length > 1,
                    autoPlay: images.length > 1,
                    onPageChanged: (index, reason) {
                      controller.updateCarouselIndex(index);
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildImage(images[index]),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final current = controller.currentGalleryIndex.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
                      final isActive = current == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: isActive ? AppGradients.primary : null,
                          color: isActive
                              ? null
                              : (isDark
                                    ? AppColors.inputFillDark
                                    : AppColors.primary5),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildBioCard(bool isDark, String bio) {
    return _sectionCard(
      isDark: isDark,
      title: "Bio",
      child: Text(
        bio.isNotEmpty ? bio : "No bio added yet",
        style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(height: 1.55),
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return _sectionCard(
      isDark: isDark,
      title: title,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsCard(bool isDark, List<String> interests) {
    return _sectionCard(
      isDark: isDark,
      title: "Interests",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: interests.map((interest) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.inputFillDark : AppColors.primary5,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              interest,
              style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionCard({
    required bool isDark,
    required String title,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.headingMedium(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  // ===================== SHIMMER (USES YOUR WIDGET) =====================

  Widget _buildProfileShimmer(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      child: Column(
        children: [
          /// Profile Header shimmer
          ShimmerWrapper(
            isLoading: true,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  const ShimmerBox(width: 118, height: 118, radius: 100),
                  const SizedBox(height: 14),
                  const ShimmerBox(width: 180, height: 16),
                  const SizedBox(height: 12),
                  const ShimmerBox(width: 120, height: 34, radius: 50),
                  const SizedBox(height: 10),
                  const ShimmerBox(width: 120, height: 34, radius: 50),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// Gallery shimmer
          ShimmerWrapper(
            isLoading: true,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const ShimmerBox(radius: 22),
            ),
          ),

          const SizedBox(height: 18),

          /// Cards shimmer
          _shimmerCard(isDark),
          const SizedBox(height: 14),
          _shimmerCard(isDark),
          const SizedBox(height: 14),
          _shimmerCard(isDark),
          const SizedBox(height: 14),
          _shimmerCard(isDark),
        ],
      ),
    );
  }

  Widget _shimmerCard(bool isDark) {
    return ShimmerWrapper(
      isLoading: true,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerBox(width: 120, height: 14),
            SizedBox(height: 14),
            ShimmerBox(width: double.infinity, height: 50, radius: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith("http")) {
      return Image.network(imagePath, fit: BoxFit.cover);
    }

    if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return Image.file(File(imagePath), fit: BoxFit.cover);
    }

    return Container(
      color: AppColors.primary5,
      child: const Icon(Icons.person, size: 40),
    );
  }
}
