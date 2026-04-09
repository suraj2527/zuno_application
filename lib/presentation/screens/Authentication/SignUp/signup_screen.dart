import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_gradients.dart';
import '../../../../utils/constants/app_text_styles.dart';
import '../../../../widgets/common/gradient_button.dart';
import 'signup_controller.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.scaffold),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                const _Header(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                  child: _SignUpForm(controller: controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
                  'zuno',
                  style: AppTextStyles.logo().copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Create Account 👋',
                  style: AppTextStyles.headingLarge().copyWith(
                    color: Colors.white,
                    fontFamily: 'Syne',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign up to start your journey with Zuno',
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

class _SignUpForm extends StatelessWidget {
  final SignUpController controller;
  const _SignUpForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InputField(
          controller: controller.nameController,
          hint: 'Enter your full name',
        ),
        const SizedBox(height: 16),
        _InputField(
          controller: controller.emailController,
          hint: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Obx(
          () => _InputField(
            controller: controller.passwordController,
            hint: 'Enter your password',
            obscureText: !controller.passwordVisible.value,
            suffix: GestureDetector(
              onTap: controller.togglePasswordVisibility,
              child: Icon(
                controller.passwordVisible.value
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Row(
            children: [
              Checkbox(
                value: controller.agreedToTerms.value,
                onChanged: (_) => controller.toggleTerms(),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  'I agree to the Terms & Privacy Policy',
                  style: AppTextStyles.bodySmall(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => GradientButton(
            label: 'Sign Up →',
            isLoading: controller.isLoading.value,
            onTap: controller.signUpWithEmail,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: AppTextStyles.bodySmall().copyWith(
                color: AppColors.textHint,
              ),
            ),
            GestureDetector(
              onTap: () {
                 Get.toNamed(Routes.SIGNIN);
              },
              child: Text(
                'Sign In',
                style: AppTextStyles.bodySmall().copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _OrDivider(),
        const SizedBox(height: 16),
        _SocialButton(
          emoji: '🇬',
          label: 'Continue with Google',
          onTap: () {
            controller.googleSignUp;
          },
        ),
      ],
    );
  }
}

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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
