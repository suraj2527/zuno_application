import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_gradients.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_button.dart';
import '../../../shared/widgets/common/Nearly_loader.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white, // Match profile screen white background
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: controller.currentStep <= 2
                    ? _IntroFlow(controller: controller)
                    : _ProfileFlow(controller: controller),
              ),
              NearlyLoader(isVisible: controller.isLoading.value),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroFlow extends StatelessWidget {
  final OnboardingController controller;
  const _IntroFlow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.scaffold,
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopProgress(controller: controller),
          const Spacer(),
          _buildIntroStep(controller.currentStep),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: 'Skip',
                  onTap: controller.skipIntro,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GradientButton(
                  label: controller.currentStep == 2 ? 'Start →' : 'Next →',
                  onTap: controller.nextStep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntroStep(int step) {
    final slide = controller.introSlides[step];

    return Column(
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.22),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              slide['emoji'] ?? '✨',
              style: const TextStyle(fontSize: 72),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Text(
          slide['title'] ?? '',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingLarge().copyWith(fontFamily: 'Syne'),
        ),
        const SizedBox(height: 14),
        Text(
          slide['description'] ?? '',
          textAlign: TextAlign.center,
          style: AppTextStyles.body().copyWith(
            color: AppColors.textSecondary,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _ProfileFlow extends StatelessWidget {
  final OnboardingController controller;
  const _ProfileFlow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('profile-flow'),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(controller: controller),
          const SizedBox(height: 26),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildStep(controller.currentStep),
            ),
          ),
          const SizedBox(height: 18),

          Obx(() => GradientButton(
                label: controller.getButtonText(),
                onTap: controller.canContinue() ? controller.nextStep : null,
              )),
        ],
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 3:
        return _buildNameStep();
      case 4:
        return _buildBioStep();
      case 5:
        return Obx(() => _buildListSelectionStep('Gender 💫', controller.genderOptions.map((e) => "${e['emoji']} ${e['label']}").toList(), controller.selectedGender, controller.selectGender));
      case 6:
        return _buildAgeStep();
      case 7:
        return Obx(() => _buildListSelectionStep('Looking for 💜', controller.lookingForOptions.map((e) => "${e['emoji']} ${e['title']}").toList(), controller.lookingFor, controller.selectLookingFor));
      case 8:
        return Obx(() => _buildListSelectionStep('Interests 🎯', controller.interests, null, controller.toggleInterest, isMulti: true, selectedItems: controller.selectedInterests.toList()));
      case 9:
        return Obx(() => _buildListSelectionStep('Religion or faith 🕊️', controller.religionOptions, controller.selectedReligion, controller.selectReligion));
      case 10:
        return Obx(() => _buildListSelectionStep('Height 📏', controller.heightOptions, controller.selectedHeight, controller.selectHeight));
      case 11:
        return Obx(() => _buildListSelectionStep('Zodiac Sign 🌟', controller.zodiacOptions, controller.selectedZodiac, controller.selectZodiac));
      case 12:
        return _buildCityStep();
      case 13:
        return _buildImagesStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // =========================
  // NAME STEP
  // =========================
  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitleBlock(
          title: 'What should we call you? ✨',
          subtitle: 'Your first impression starts with your name.',
        ),
        const SizedBox(height: 28),
        _SoftInputContainer(
          child: TextField(
            controller: controller.nameController,
            textCapitalization: TextCapitalization.words,
            onChanged: controller.onNameChanged,
            style: AppTextStyles.bodyMedium().copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              hintStyle: AppTextStyles.bodyMedium().copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // BIO STEP
  // =========================
  Widget _buildBioStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitleBlock(
          title: 'Tell us about yourself 📝',
          subtitle: 'A great bio helps you stand out from the crowd.',
        ),
        const SizedBox(height: 28),
        _SoftInputContainer(
          child: TextField(
            controller: controller.bioController,
            textCapitalization: TextCapitalization.sentences,
            onChanged: controller.onBioChanged,
            maxLines: 5,
            minLines: 3,
            style: AppTextStyles.bodyMedium().copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Write a short bio about yourself...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              hintStyle: AppTextStyles.bodyMedium().copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // LIST SELECTION WIDGET
  // =========================
  Widget _buildListSelectionStep(String title, List<String> items, String? currentVal, Function(String) onSelect, {bool isMulti = false, List<String>? selectedItems}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitleBlock(title: title, subtitle: 'Select your choice.'),
        const SizedBox(height: 24),
        ListView.separated(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
          itemBuilder: (context, index) {
            final item = items[index];
            bool isSelected = false;
            if (isMulti) {
              isSelected = selectedItems?.contains(item) ?? false;
            } else {
              final cleanedItem = item.startsWith(RegExp(r'^\S+\s')) ? item.substring(2).trim() : item;
              isSelected = currentVal == cleanedItem;
            }
            return InkWell(
              onTap: () {
                 if (isMulti) onSelect(item); 
                 else onSelect(item.startsWith(RegExp(r'^\S+\s')) ? item.substring(2).trim() : item);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                    if (isSelected) const Icon(Icons.check, color: Color(0xFF4285F4), size: 20),
                  ],
                ),
              ),
            );
          }
        ),
      ]
    );
  }

  // =========================
  // AGE STEP
  // =========================
  Widget _buildAgeStep() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitleBlock(
            title: 'How old are you? 🎂',
            subtitle: 'This helps us personalize your experience.',
          ),
          const SizedBox(height: 28),

          Center(
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.inputBorderLight,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.selectedAge.round().toString(),
                    style: AppTextStyles.headingLarge().copyWith(
                      color: AppColors.primary,
                      fontSize: 50,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'years old',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary4,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.14),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 6,
            ),
            child: Slider(
              min: 18,
              max: 80,
              divisions: 62,
              value: controller.selectedAge,
              onChanged: controller.updateAge,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Or type manually',
            style: AppTextStyles.label().copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 10),

          _SoftInputContainer(
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              style: AppTextStyles.bodyMedium().copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: controller.selectedAge.round().toString(),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                hintStyle: AppTextStyles.bodyMedium().copyWith(
                  color: AppColors.textHint,
                ),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed >= 18 && parsed <= 80) {
                  controller.updateAge(parsed);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // CITY STEP
  // =========================
  Widget _buildCityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitleBlock(title: 'Where do you live? 📍', subtitle: 'Search your city.'),
        const SizedBox(height: 16),
        TextField(
          controller: controller.citySearchController,
          decoration: InputDecoration(
            hintText: "Search city",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4285F4))),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingCities.value) return const Center(child: CircularProgressIndicator());
          
          final displayList = controller.filteredCities.length > 50 
              ? controller.filteredCities.sublist(0, 50) 
              : controller.filteredCities;

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final city = displayList[index];
              final isSelected = controller.selectedCity == city;
              return InkWell(
                onTap: () => controller.selectCity(city),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(city, style: const TextStyle(fontSize: 15, color: Colors.black87))),
                      if (isSelected) const Icon(Icons.check, color: Color(0xFF4285F4), size: 20),
                    ],
                  ),
                ),
              );
            }
          );
        }),
      ]
    );
  }

  // =========================
  // IMAGES STEP
  // =========================
  Widget _buildImagesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitleBlock(title: 'Upload your photos 📸', subtitle: 'Upload at least 1 main photo to continue.'),
        const SizedBox(height: 24),
        Obx(() {
           return Column(
             children: [
               Row(children: [ Expanded(child: _buildPhotoSlot(index: -1, isMain: true, height: 280)) ]),
               const SizedBox(height: 12),
               Row(children: [
                 Expanded(child: _buildPhotoSlot(index: 0, height: 160)),
                 const SizedBox(width: 12),
                 Expanded(child: _buildPhotoSlot(index: 1, height: 160)),
               ]),
             ]
           );
        }),
      ]
    );
  }

  Widget _buildPhotoSlot({required int index, bool isMain = false, required double height}) {
    String imagePath = '';
    if (isMain) {
      imagePath = controller.selectedProfileImage;
    } else {
      if (index < controller.selectedGalleryImages.length) {
        imagePath = controller.selectedGalleryImages[index];
      }
    }

    final bool hasImage = imagePath.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (!hasImage) {
          if (isMain) controller.pickProfileImage();
          else controller.pickGalleryImage();
        }
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: hasImage ? null : Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
        ),
        child: Stack(
          children: [
            if (hasImage)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
              ),
            if (isMain && hasImage)
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                  child: const Text('Main', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              ),
            if (!hasImage)
              const Center(child: Icon(Icons.add, color: Color(0xFFBBBBBB), size: 32)),
            if (hasImage && !isMain)
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () => controller.removeGalleryImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepTitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepTitleBlock({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headingLarge().copyWith(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTextStyles.body().copyWith(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SoftInputContainer extends StatelessWidget {
  final Widget child;
  const _SoftInputContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1.0,
        ),
      ),
      child: child,
    );
  }
}

class _TopProgress extends StatelessWidget {
  final OnboardingController controller;
  const _TopProgress({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index <= controller.currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
            height: 6,
            decoration: BoxDecoration(
              gradient: active ? AppGradients.primary : null,
              color: active ? null : AppColors.primary4,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final OnboardingController controller;
  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final int profileIndex = controller.currentStep - 2;
    const int totalProfileSteps = 11;
    final double progress = profileIndex / totalProfileSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.currentStep > 3) ...[
          GestureDetector(
            onTap: controller.previousStep,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.inputBorderLight,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.primary4,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Step $profileIndex of $totalProfileSteps',
          style: AppTextStyles.bodySmall().copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SecondaryButton({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium().copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
