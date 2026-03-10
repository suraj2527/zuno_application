import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/utils/constants/app_colors.dart';
import 'package:zuno_application/utils/constants/app_text_styles.dart';
import 'onboarding_controller.dart';

class OnboardingScreen
    extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

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

                    const SizedBox(height: 40),

                    Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Complete Your Profile",
                      style:
                          AppTextStyles.headingLarge(isDark),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Let’s set up your Zuno account",
                      style:
                          AppTextStyles.body(isDark),
                    ),

                    const SizedBox(height: 40),

                    Container(
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
                                  blurRadius: 30,
                                  offset:
                                      const Offset(
                                          0, 12),
                                )
                              ],
                      ),
                      child: Column(
                        children: [

                          TextField(
                            controller: controller
                                .nameController,
                            decoration:
                                const InputDecoration(
                              hintText:
                                  "Enter your full name",
                            ),
                          ),

                          const SizedBox(height: 24),

                          Obx(() => controller
                                  .isLoading.value
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: controller
                                      .completeProfile,
                                  child: const Text(
                                      "Continue"),
                                )),
                        ],
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