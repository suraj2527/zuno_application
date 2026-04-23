import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_gradients.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_button.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.scaffold,
        ),
        child: SafeArea(
          child: Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: controller.currentStep <= 2
                  ? _IntroFlow(controller: controller)
                  : _ProfileFlow(controller: controller),
            ),
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
    return Padding(
      key: const ValueKey('intro-flow'),
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

          /// ONLY button rebuild
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
        return _buildGenderStep();
      case 5:
        return _buildAgeStep();
      case 6:
        return _buildLookingForStep();
      case 7:
        return _buildInterestStep();
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
  // GENDER STEP
  // =========================
  Widget _buildGenderStep() {
    return Obx(() {
      final selectedGender = controller.selectedGender;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitleBlock(
            title: 'How do you identify? 💫',
            subtitle: 'Choose the option that feels most like you.',
          ),
          const SizedBox(height: 24),
          GridView.builder(
            itemCount: controller.genderOptions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.02,
            ),
            itemBuilder: (_, i) {
              final item = controller.genderOptions[i];
              final selected = selectedGender == item['label'];

              return GestureDetector(
                onTap: () => controller.selectGender(item['label']!),
                child: _SelectableCard(
                  selected: selected,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['emoji'] ?? '✨',
                        style: const TextStyle(fontSize: 34),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['label'] ?? '',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium().copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
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
  // LOOKING FOR STEP
  // =========================
  Widget _buildLookingForStep() {
    return Obx(() {
      final selectedLookingFor = controller.lookingFor;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitleBlock(
            title: 'What are you looking for? 💜',
            subtitle: 'Choose what feels right for you right now.',
          ),
          const SizedBox(height: 22),
          ListView.separated(
            itemCount: controller.lookingForOptions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final item = controller.lookingForOptions[i];
              final selected = selectedLookingFor == item['title'];

              return GestureDetector(
                onTap: () => controller.selectLookingFor(item['title']!),
                child: _SelectableCard(
                  selected: selected,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  radius: 18,
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withOpacity(0.18)
                              : AppColors.inputFillLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            item['emoji'] ?? '✨',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] ?? '',
                              style: AppTextStyles.bodyMedium().copyWith(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'] ?? '',
                              style: AppTextStyles.bodySmall().copyWith(
                                color: selected
                                    ? Colors.white.withOpacity(0.88)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  // =========================
  // INTEREST STEP
  // =========================
  Widget _buildInterestStep() {
    return Obx(() {
      final selectedInterests = controller.selectedInterests;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitleBlock(
            title: 'Pick your interests 🎯',
            subtitle: 'Select at least 3 so we can match your vibe better.',
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.interests.map((tag) {
              final sel = selectedInterests.contains(tag);

              return GestureDetector(
                onTap: () => controller.toggleInterest(tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    gradient: sel ? AppGradients.primary : null,
                    color: sel ? null : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: sel
                          ? Colors.transparent
                          : AppColors.inputBorderLight,
                      width: 1.3,
                    ),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.18),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.bodyMedium().copyWith(
                      color: sel ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${selectedInterests.length} selected',
              style: AppTextStyles.bodySmall().copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    });
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
            height: 1.15,
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
        color: AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.inputBorderLight,
          width: 1.4,
        ),
      ),
      child: child,
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final bool selected;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const _SelectableCard({
    required this.selected,
    required this.child,
    this.padding,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: selected ? AppGradients.primary : null,
        color: selected ? null : AppColors.cardLight,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: selected ? Colors.transparent : AppColors.inputBorderLight,
          width: 1.4,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ]
            : [],
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
    const int totalProfileSteps = 5;
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
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.inputBorderLight,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium().copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
