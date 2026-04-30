import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Nearly/presentation/profile/edit_profile_screen.dart';
import 'package:Nearly/presentation/profile/profile_controller.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_gradients.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';
import 'package:Nearly/shared/widgets/common/app_refresh_wrapper.dart';
import 'package:Nearly/shared/widgets/shimmers/shimmer_box.dart';

class ProfileTab extends StatelessWidget {
  ProfileTab({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : const Color(0xFFF8F8FB),
        body: Obx(() {
          final profile = controller.profile.value;

          if (controller.isLoading.value || profile == null) {
            if (!controller.isLoading.value) {
              Future.microtask(() => controller.loadProfileData());
            }
            return _buildProfileShimmer(isDark);
          }

          return AppRefreshWrapper(
            onRefresh: () async => controller.loadProfileData(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Scrolls away / 'Wraps up')
                _buildProfileHeader(isDark, profile),
                
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGallerySection(isDark, profile.imageUrls),
                      const SizedBox(height: 24),
                      _buildBioCard(isDark, profile.bio),
                      const SizedBox(height: 20),
                      _buildPersonalInfoGrid(isDark, profile),
                      const SizedBox(height: 20),
                      _buildInterestsCard(isDark, profile.interests),
                      // Extra space for Bottom Nav + Safe Area
                      SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, dynamic profile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Header Background
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1730) : const Color(0xFFEEEBFB),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
              ),
              
              // Settings Button
              Positioned(
                top: MediaQuery.of(Get.context!).padding.top + 10,
                right: 20,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Avatar
              Positioned(
                bottom: -50,
                left: 0,
                right: 0,
                child: Center(
                  child: Hero(
                    tag: "my_profile_avatar",
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildImage(
                          controller.selectedProfileImage.value.isNotEmpty
                              ? controller.selectedProfileImage.value
                              : profile.profileImageUrl,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 60),

          Text(
            "${controller.nameController.text.isNotEmpty ? controller.nameController.text : profile.userName}, ${profile.age}",
            textAlign: TextAlign.center,
            style: AppTextStyles.headingLarge(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            profile.location ?? "Location not set",
            style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.to(() => EditProfileScreen()),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Logout?",
                                style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Are you sure you want to sign out?",
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Get.back(),
                                      child: Container(
                                        height: 44,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.inputFillDark : AppColors.primary5,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "No",
                                          style: TextStyle(
                                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.back();
                                        controller.logout();
                                      },
                                      child: Container(
                                        height: 44,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: AppGradients.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          "Logout",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
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
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: Colors.red,
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

  Widget _buildPersonalInfoGrid(bool isDark, dynamic profile) {
    return _sectionCard(
      isDark: isDark,
      title: "About Me",
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: [
          _buildInfoItem(
            isDark: isDark,
            label: "Gender",
            value: (profile.gender ?? '').isNotEmpty ? profile.gender! : "Not set",
            icon: Icons.person_outline_rounded,
          ),
          _buildInfoItem(
            isDark: isDark,
            label: "Looking For",
            value: (profile.lookingFor ?? '').isNotEmpty ? profile.lookingFor! : "Not set",
            icon: Icons.favorite_border_rounded,
          ),
          _buildInfoItem(
            isDark: isDark,
            label: "Age",
            value: "${profile.age} years",
            icon: Icons.cake_outlined,
          ),
          _buildInfoItem(
            isDark: isDark,
            label: "Location",
            value: profile.location ?? "Not set",
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.primary5,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textHintDark : AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.format_quote_rounded,
              size: 60,
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            ),
          ),
          Text(
            bio.isNotEmpty ? bio : "Write something interesting about yourself to attract more matches!",
            style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
              height: 1.6,
              letterSpacing: 0.2,
              fontStyle: bio.isEmpty ? FontStyle.italic : null,
              color: bio.isEmpty 
                  ? (isDark ? AppColors.textHintDark : AppColors.textHint)
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.headingMedium(
                  isDark: isDark,
                ).copyWith(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
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
