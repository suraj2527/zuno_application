import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_gradients.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_button.dart';
import '../../../shared/widgets/common/Nearly_loader.dart';
import 'signin_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmationDialog(context, isDark);
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Obx(
          () => Stack(
            children: [
              Container(
                decoration: const BoxDecoration(gradient: AppGradients.scaffold),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        const _Header(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                          child: _LoginSelection(controller: controller),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              NearlyLoader(isVisible: controller.isLoading.value),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(
      BuildContext context, bool isDark) async {
    return await Get.dialog<bool>(
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
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.exit_to_app_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Exit App?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to close the application?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(result: false),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              "Stay",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(result: true),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: AppGradients.primary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text(
                              "Exit",
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
        ) ??
        false;
  }
}

// ─────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearly',
                  style: AppTextStyles.logo().copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Welcome Back 👋',
                  style: AppTextStyles.headingLarge().copyWith(
                    color: Colors.white,
                    fontFamily: 'Syne',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue finding your spark',
                  style: AppTextStyles.body().copyWith(
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// LOGIN SELECTION (Updated - Removed Phone & OTP)
// ─────────────────────────────────────────────────

class _LoginSelection extends StatelessWidget {
  final SignInController controller;
  const _LoginSelection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SocialButton(
          emoji: '🇬',
          label: 'Continue with Google',
          onTap: controller.googleLogin,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.primary4, thickness: 1.5),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or continue with',
                style: AppTextStyles.bodySmall().copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.primary4, thickness: 1.5),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Only Email Step (No tabs, no phone)
        _EmailStep(controller: controller),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// EMAIL STEP
// ─────────────────────────────────────────────────

class _EmailStep extends StatelessWidget {
  final SignInController controller;
  const _EmailStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EMAIL', style: AppTextStyles.label()),
        const SizedBox(height: 8),
        _InputField(
          controller: controller.emailController,
          hint: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 18),

        Text('PASSWORD', style: AppTextStyles.label()),
        const SizedBox(height: 8),
        Obx(
          () => _InputField(
            controller: controller.passwordController,
            hint: 'Enter your password',
            obscureText: !controller.isPasswordVisible.value,
            suffix: GestureDetector(
              onTap: controller.togglePasswordVisibility,
              child: Icon(
                controller.isPasswordVisible.value
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        Obx(
          () => GradientButton(
            label: 'Login →',
            isLoading: controller.isLoading.value,
            onTap: controller.loginWithEmail,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// REUSABLES (Unchanged)
// ─────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorderLight, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.bodyMedium().copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          hintStyle: AppTextStyles.bodyMedium().copyWith(
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback? onTap;

  const _SocialButton({required this.emoji, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFillLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorderLight, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.bodyMedium().copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
