import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:zuno_application/utils/constants/app_colors.dart';
import 'package:zuno_application/utils/constants/app_text_styles.dart';
import 'signin_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.scaffoldDark,
                    AppColors.cardDark,
                  ]
                : [
                    AppColors.scaffoldLight,
                    Colors.white,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [

                    const SizedBox(height: 20),

                    /// LOGO
                    Icon(
                      Icons.bolt_rounded,
                      size: 60,
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Welcome to Zuno",
                      style:
                          AppTextStyles.headingLarge(isDark),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Secure sign in experience",
                      style: AppTextStyles.body(isDark),
                    ),

                    const SizedBox(height: 40),

                    /// CARD
                    AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 300),
                      padding:
                          const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        borderRadius:
                            BorderRadius.circular(24),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.05),
                                  blurRadius: 25,
                                  offset:
                                      const Offset(0, 10),
                                )
                              ],
                      ),
                      child: Column(
                        children: [

                          /// PHONE
                          if (!controller.isOtpSent.value)
                            TextField(
                              controller:
                                  controller.phoneController,
                              keyboardType:
                                  TextInputType.phone,
                              decoration:
                                  const InputDecoration(
                                prefixText: "+91 ",
                                hintText:
                                    "Enter mobile number",
                              ),
                            ),

                          /// OTP BOXES
                          Obx(() => controller
                                  .isOtpSent.value
                              ? Column(
                                  children: [
                                    const SizedBox(
                                        height: 10),
                                    Pinput(
                                      length: 6,
                                      controller:
                                          controller
                                              .otpController,
                                      onCompleted:
                                          (_) =>
                                              controller
                                                  .verifyOtp(),
                                    ),
                                    const SizedBox(
                                        height: 10),

                                    /// RESEND TIMER
                                    Obx(() => TextButton(
                                          onPressed:
                                              controller
                                                          .secondsRemaining
                                                          .value ==
                                                      0
                                                  ? controller
                                                      .resendOtp
                                                  : null,
                                          child: Text(
                                            controller
                                                        .secondsRemaining
                                                        .value ==
                                                    0
                                                ? "Resend OTP"
                                                : "Resend in ${controller.secondsRemaining.value}s",
                                          ),
                                        )),
                                  ],
                                )
                              : const SizedBox()),

                          const SizedBox(height: 20),

                          /// BUTTON
                          Obx(() => controller
                                  .isLoading.value
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: controller
                                          .isOtpSent.value
                                      ? controller
                                          .verifyOtp
                                      : controller
                                          .sendOtp,
                                  child: Text(
                                    controller
                                            .isOtpSent.value
                                        ? "Verify OTP"
                                        : "Continue",
                                  ),
                                )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// OR
                    const Text("OR"),

                    const SizedBox(height: 20),

                    /// GOOGLE BUTTON
                    OutlinedButton.icon(
                      onPressed:
                          controller.googleLogin,
                      icon: const Icon(Icons.g_mobiledata,
                          size: 28),
                      label: const Text(
                          "Continue with Google"),
                      style: OutlinedButton.styleFrom(
                        minimumSize:
                            const Size(double.infinity, 52),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}