import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_gradients.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_button.dart';
import '../../../shared/widgets/common/zuno_loader.dart';
import 'signin_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ZunoLoader(isVisible: controller.isLoading.value),
          ],
        ),
      ),
    );
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
                  'nearly',
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: AppTextStyles.bodySmall().copyWith(
                color: AppColors.textHint,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(Routes.SIGNUP); // Navigate to SignUpScreen
              },
              child: Text(
                'Sign Up',
                style: AppTextStyles.bodySmall().copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
