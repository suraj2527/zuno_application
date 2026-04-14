import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/shared/constants/app_colors.dart';
import 'package:zuno_application/shared/constants/app_gradients.dart';
import 'package:zuno_application/shared/constants/app_text_styles.dart';
import 'package:zuno_application/shared/widgets/common/app_refresh_wrapper.dart';
import 'package:zuno_application/shared/widgets/common/zuno_base_screen.dart';
import 'package:zuno_application/shared/widgets/common/gradient_button.dart';
import 'package:zuno_application/shared/widgets/common/zuno_loader.dart';

import 'profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Stack(
        children: [
          ZunoBaseScreen(
            isDark: isDark,
            child: Material(
              color: Colors.transparent,
              child: AppRefreshWrapper(
                onRefresh: () async => controller.loadProfileData(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 40).copyWith(
                    bottom: 32 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainProfilePhotoSection(isDark),
                      const SizedBox(height: 16),

                      _buildGalleryPhotosSection(isDark),
                      const SizedBox(height: 16),

                      _buildTextFieldCard(
                        isDark: isDark,
                        title: "Name",
                        controller: controller.nameController,
                        hint: "Enter your name",
                      ),
                      const SizedBox(height: 14),

                      _buildTextFieldCard(
                        isDark: isDark,
                        title: "Bio",
                        controller: controller.bioController,
                        hint: "Tell something about yourself",
                        maxLines: 4,
                      ),
                      const SizedBox(height: 14),

                      _buildAgeSection(isDark),
                      const SizedBox(height: 14),

                      _buildGenderSection(isDark),
                      const SizedBox(height: 14),

                      _buildLookingForSection(isDark),
                      const SizedBox(height: 14),

                      _buildInterestsSection(isDark),
                      const SizedBox(height: 24),

                      _buildSaveButton(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),

          ZunoLoader(isVisible: controller.isSaving.value),
        ],
      ),
    );
  }

  Widget _buildMainProfilePhotoSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      title: "Edit",
      child: Obx(() {
        final image = controller.selectedProfileImage.value;

        return Center(
          child: GestureDetector(
            onTap: controller.pickProfileImage,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(child: _buildImage(image)),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGalleryPhotosSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      title: "Your Best Pics",
      child: Obx(() {
        final images = controller.selectedGalleryImages;

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
                      color: isDark
                          ? AppColors.inputFillDark
                          : AppColors.primary5,
                      borderRadius: BorderRadius.circular(20),
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
                                  onTap: () =>
                                      controller.removeGalleryImage(index),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.black.withOpacity(0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: AppColors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Icon(
                            Icons.add_a_photo_outlined,
                            size: 30,
                            color: isDark
                                ? AppColors.textHintDark
                                : AppColors.textHint,
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingMedium(isDark: isDark)),
          const SizedBox(height: 14),
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
