import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nearly/shared/constants/app_colors.dart';
import 'package:nearly/shared/constants/app_gradients.dart';
import 'package:nearly/shared/constants/app_text_styles.dart';
import 'package:nearly/shared/widgets/common/app_refresh_wrapper.dart';
import 'package:nearly/shared/widgets/common/gradient_button.dart';
import 'package:nearly/shared/widgets/common/zuno_loader.dart';

import 'profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark.withOpacity(0.8) : Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        title: Text(
          "Edit Profile",
          style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => Stack(
          children: [
            Container(
              color: isDark ? AppColors.scaffoldDark : AppColors.primary5,
              child: Column(
                children: [
                  Expanded(
                    child: AppRefreshWrapper(
                      onRefresh: () async => controller.loadProfileData(),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 60, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMainProfilePhotoSection(isDark),
                            const SizedBox(height: 20),

                            _buildGalleryPhotosSection(isDark),
                            const SizedBox(height: 20),

                            _buildTextFieldCard(
                              isDark: isDark,
                              title: "Name",
                              controller: controller.nameController,
                              hint: "Enter your name",
                            ),
                            const SizedBox(height: 20),

                            _buildTextFieldCard(
                              isDark: isDark,
                              title: "Bio",
                              controller: controller.bioController,
                              hint: "Tell something about yourself",
                              maxLines: 4,
                            ),
                            const SizedBox(height: 20),

                            _buildAgeSection(isDark),
                            const SizedBox(height: 20),

                            _buildGenderSection(isDark),
                            const SizedBox(height: 20),

                            _buildLookingForSection(isDark),
                            const SizedBox(height: 20),

                            _buildInterestsSection(isDark),
                            const SizedBox(height: 100), // Space for sticky button
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Sticky Save Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight).withOpacity(0.0),
                      (isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight).withOpacity(0.9),
                      isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                child: _buildSaveButton(isDark),
              ),
            ),

            ZunoLoader(isVisible: controller.isSaving.value),
          ],
        ),
      ),
    );
  }

  Widget _buildMainProfilePhotoSection(bool isDark) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          Obx(() {
            final image = controller.selectedProfileImage.value;
            return GestureDetector(
              onTap: controller.pickProfileImage,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(child: _buildImage(image)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGalleryPhotosSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      title: "Your Best Pics",
      child: Obx(() {
        final images = controller.selectedGalleryImages;
        // Access length to register the observable with Obx
        final _ = images.length;

        return Row(
          children: List.generate(3, (index) {
            final hasImage = index < images.length;
            final image = hasImage ? images[index] : null;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index != 2 ? 10 : 0),
                child: GestureDetector(
                  onTap: hasImage ? null : controller.pickGalleryImage,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.inputFillDark : AppColors.primary5,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                        width: 1,
                      ),
                    ),
                    child: hasImage
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: _buildImage(image!),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => controller.removeGalleryImage(index),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 28,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Add",
                                style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildTextFieldCard({
    required bool isDark,
    required String title,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return _sectionCard(
      isDark: isDark,
      title: title,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium(isDark: isDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall(isDark: isDark),
          filled: true,
          fillColor: isDark ? AppColors.inputFillDark : AppColors.primary5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAgeSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      title: "Age",
      child: Obx(() {
        return Column(
          children: [
            Text(
              controller.selectedAge.value.round().toString(),
              style: AppTextStyles.headingMedium(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: controller.selectedAge.value,
              min: 18,
              max: 80,
              divisions: 62,
              activeColor: AppColors.primary,
              onChanged: controller.updateAge,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGenderSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      title: "Gender",
      child: Obx(() {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: controller.genderOptions.map((item) {
            final label = item['label']!;
            final emoji = item['emoji']!;
            final isSelected = controller.selectedGender.value == label;

            return GestureDetector(
              onTap: () => controller.selectGender(label),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.primary : null,
                  color: isSelected
                      ? null
                      : (isDark ? AppColors.inputFillDark : AppColors.primary5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  "$emoji $label",
                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                    color: isSelected
                        ? AppColors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildLookingForSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      title: "Looking For",
      child: Obx(() {
        return Column(
          children: controller.lookingForOptions.map((item) {
            final title = item['title']!;
            final subtitle = item['subtitle']!;
            final emoji = item['emoji']!;
            final isSelected = controller.selectedLookingFor.value == title;

            return GestureDetector(
              onTap: () => controller.selectLookingFor(title),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.primary : null,
                  color: isSelected
                      ? null
                      : (isDark ? AppColors.inputFillDark : AppColors.primary5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style:
                                AppTextStyles.bodyMedium(
                                  isDark: !isSelected ? isDark : false,
                                ).copyWith(
                                  color: isSelected
                                      ? AppColors.white
                                      : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style:
                                AppTextStyles.bodySmall(
                                  isDark: !isSelected ? isDark : false,
                                ).copyWith(
                                  color: isSelected
                                      ? AppColors.white.withOpacity(0.9)
                                      : (isDark
                                            ? AppColors.textHintDark
                                            : AppColors.textHint),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildInterestsSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      title: "Interests (Pick at least 3)",
      child: Obx(() {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: controller.allInterests.map((interest) {
            final isSelected = controller.selectedInterests.contains(interest);

            return GestureDetector(
              onTap: () => controller.toggleInterest(interest),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.primary : null,
                  color: isSelected
                      ? null
                      : (isDark ? AppColors.inputFillDark : AppColors.primary5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  interest,
                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                    color: isSelected
                        ? AppColors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return GradientButton(label: "Save Changes", onTap: controller.saveProfile);
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
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.headingSmall(isDark: isDark).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
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
      child: const Center(child: Icon(Icons.person, size: 40)),
    );
  }
}
