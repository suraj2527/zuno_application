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
import 'package:Nearly/presentation/profile/settings_screen.dart';

class ProfileTab extends StatelessWidget {
  ProfileTab({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.scaffoldDark
            : const Color(0xFFF8F8FB),
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Elegant Header
                  _buildElegantHeader(context, isDark, profile),

                  const SizedBox(height: 24),

                  // 2. Content Sections
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildElegantSectionTitle('About Me'),
                        _buildAboutMeCard(isDark, profile),

                        const SizedBox(height: 32),

                        _buildElegantSectionTitle('Bio'),
                        _buildBioCard(isDark, profile.bio),

                        const SizedBox(height: 32),

                        _buildElegantSectionTitle('Interests'),
                        _buildInterestsCard(isDark, profile.interests),

                        const SizedBox(height: 32),

                        _buildElegantSectionTitle('Gallery'),
                        _buildGallerySection(isDark, profile.imageUrls),

                        // Extra space for Bottom Nav + Safe Area
                        SizedBox(
                          height: 120 + MediaQuery.of(context).padding.bottom,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildElegantHeader(
    BuildContext context,
    bool isDark,
    dynamic profile,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1A1730), const Color(0xFF110F1E)]
                        : [const Color(0xFFF0EFFF), const Color(0xFFE5E2FF)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
              ),

              // Settings Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: GestureDetector(
                  onTap: () => Get.to(() => const SettingsScreen()),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isDark ? 0.05 : 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      size: 20,
                      color: isDark ? Colors.white : AppColors.primary,
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
                          color: isDark ? AppColors.scaffoldDark : Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                profile.location ?? "Location not set",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GestureDetector(
              onTap: () => Get.to(() => EditProfileScreen()),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showLogoutDialog(bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF4D4D),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Sign Out?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Are you sure you want to sign out of your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        controller.logout();
                      },
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4D4D),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
  }

  Widget _buildElegantSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAboutMeCard(bool isDark, dynamic profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.person_outline_rounded,
            "Gender",
            profile.gender ?? "Not set",
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 48),
          _buildInfoRow(
            Icons.favorite_border_rounded,
            "Looking for",
            profile.lookingFor ?? "Not set",
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 48),
          _buildInfoRow(Icons.cake_outlined, "Age", "${profile.age} years"),
          const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 48),
          _buildInfoRow(
            Icons.location_on_outlined,
            "Location",
            profile.location ?? "Not set",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard(bool isDark, String bio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Text(
        bio.isNotEmpty ? bio : "No bio added yet.",
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black54,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildInterestsCard(bool isDark, List<String> interests) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests.map((interest) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            interest,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGallerySection(bool isDark, List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEEEEEE),
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Text(
            "No gallery photos",
            style: TextStyle(color: Colors.black38),
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: images.length,
          options: CarouselOptions(
            height: 240,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enableInfiniteScroll: images.length > 1,
            autoPlay: images.length > 1,
            onPageChanged: (index, reason) =>
                controller.updateCarouselIndex(index),
          ),
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                child: _buildImage(images[index]),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Obx(() {
          final current = controller.currentGalleryIndex.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isActive = current == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(100),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  // ===================== SHIMMER =====================

  Widget _buildProfileShimmer(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            height: 340,
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                const ShimmerBox(
                  width: double.infinity,
                  height: 140,
                  radius: 0,
                ),
                const SizedBox(height: 60),
                const ShimmerBox(width: 200, height: 24),
                const SizedBox(height: 12),
                const ShimmerBox(width: 150, height: 16),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 50,
                    radius: 100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const ShimmerBox(
                  width: double.infinity,
                  height: 200,
                  radius: 16,
                ),
                const SizedBox(height: 24),
                const ShimmerBox(
                  width: double.infinity,
                  height: 100,
                  radius: 16,
                ),
              ],
            ),
          ),
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
