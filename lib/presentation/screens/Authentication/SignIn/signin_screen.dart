import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_gradients.dart';
import '../../../../utils/constants/app_text_styles.dart';
import '../../../../widgets/common/gradient_button.dart';
import 'signin_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

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
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: controller.isOtpSent.value
                          ? _OtpStep(controller: controller)
                          : _LoginSelection(controller: controller),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                  'zuno',
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
// LOGIN SELECTION
// ─────────────────────────────────────────────────

class _LoginSelection extends StatelessWidget {
  final SignInController controller;
  const _LoginSelection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('login-selection'),
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

        const SizedBox(height: 20),

        // Tabs
        Obx(
          () => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.inputFillLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    title: 'Email',
                    selected: controller.selectedLoginTab.value == 0,
                    onTap: () => controller.switchTab(0),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    title: 'Phone',
                    selected: controller.selectedLoginTab.value == 1,
                    onTap: () => controller.switchTab(1),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        Obx(
          () => controller.selectedLoginTab.value == 0
              ? _EmailStep(controller: controller)
              : _PhoneStep(controller: controller),
        ),
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
      key: const ValueKey('email-step'),
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
// PHONE STEP
// ─────────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  final SignInController controller;
  const _PhoneStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('phone-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MOBILE NUMBER', style: AppTextStyles.label()),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFillLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.inputBorderLight,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: AppColors.inputBorderLight,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(
                  '+91',
                  style: AppTextStyles.bodyMedium().copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: AppTextStyles.bodyMedium().copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter mobile number',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    hintStyle: AppTextStyles.bodyMedium().copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Obx(
          () => GradientButton(
            label: 'Send OTP →',
            isLoading: controller.isLoading.value,
            onTap: controller.sendOtp,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// OTP STEP
// ─────────────────────────────────────────────────

class _OtpStep extends StatelessWidget {
  final SignInController controller;
  const _OtpStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: AppTextStyles.headingMedium().copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inputBorderLight,
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primary4,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primary4,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary3, width: 1.5),
      ),
    );

    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => controller.isOtpSent.value = false,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.inputBorderLight),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text('Enter OTP 🔐', style: AppTextStyles.headingLarge()),
        const SizedBox(height: 8),

        Obx(
          () => Text(
            'We sent a 6-digit code to +91 ${controller.phoneController.text}',
            style: AppTextStyles.body().copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 32),

        Center(
          child: Pinput(
            length: 6,
            controller: controller.otpController,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            onCompleted: (_) => controller.verifyOtp(),
          ),
        ),
        const SizedBox(height: 32),

        Obx(
          () => GradientButton(
            label: 'Verify OTP',
            isLoading: controller.isLoading.value,
            onTap: controller.verifyOtp,
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: Obx(() {
            final secs = controller.secondsRemaining.value;
            return GestureDetector(
              onTap: secs == 0 ? controller.resendOtp : null,
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium().copyWith(
                    color: AppColors.textHint,
                  ),
                  children: [
                    const TextSpan(text: "Didn't receive it? "),
                    TextSpan(
                      text: secs == 0 ? 'Resend OTP' : 'Resend in ${secs}s',
                      style: TextStyle(
                        color: secs == 0
                            ? AppColors.primary
                            : AppColors.textHint,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// REUSABLES
// ─────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primary : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium().copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
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
        border: Border.all(
          color: AppColors.inputBorderLight,
          width: 1.5,
        ),
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

  const _SocialButton({
    required this.emoji,
    required this.label,
    this.onTap,
  });

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
          border: Border.all(
            color: AppColors.inputBorderLight,
            width: 1.5,
          ),
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