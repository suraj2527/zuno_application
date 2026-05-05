import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_button.dart';
import 'privacy_policy_controller.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrivacyPolicyController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Applying the existing app color theme
    final bgColor = isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textDim = isDark ? AppColors.textHintDark : AppColors.textHint;
    final dividerColor = isDark ? Colors.white10 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Screen padding equivalent to CSS: padding: 4px 24px 28px;
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                child: Column(
                  children: [
                    // --- Logo ---
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Nearly',
                                  style: AppTextStyles.logo().copyWith(
                                    color: textColor,
                                    fontSize: 32,
                                    height: 1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: '.',
                                  style: AppTextStyles.logo().copyWith(
                                    color: AppColors.primary,
                                    fontSize: 32,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find your spark',
                            style: TextStyle(
                              fontSize: 10,
                              color: textDim,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // --- Divider ---
                    Container(
                      height: 0.5,
                      color: dividerColor,
                    ),
                    const SizedBox(height: 12),
                    
                    // --- Section label ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PRIVACY POLICY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: textDim,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- Policy scroll ---
                    Expanded(
                      child: ListView(
                        controller: controller.scrollController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _PolicySection(
                            title: 'Introduction',
                            content: 'Welcome to Nearly. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our dating application.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Information We Collect',
                            content: 'We collect information you provide directly — including your name, age, gender, photos, location, bio, preferences, and any messages sent through Nearly. We also automatically collect device identifiers, usage analytics, interaction data, and crash reports to improve our service.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'How We Use Your Data',
                            content: 'Your data is used to match you with compatible people nearby, personalise your experience, improve our matching algorithms, send relevant notifications, and maintain the safety and security of our platform. We may also use anonymised data for research and product development.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Location Data',
                            content: 'Nearly uses your approximate location to show you people in your area. We never share your precise GPS coordinates with other users — only a general distance is shown. You may disable location access at any time in your device settings, though some features may be limited.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Photos & Profile Content',
                            content: 'Photos and content you upload are stored securely on our servers. Profile photos may be visible to other users within your discovery area. You can delete any photos or your entire profile at any time from the app settings.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Sharing With Third Parties',
                            content: 'We do not sell your personal data. We may share anonymised, aggregated data with analytics partners. We work with third-party providers for cloud storage, analytics, and payment processing — all bound by strict data agreements and our privacy standards.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Your Rights',
                            content: 'You have the right to access, correct, download, or delete your personal data at any time. You may also withdraw consent for data processing. To make a request, contact us at privacy@nearly.app. We will respond within 30 days.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Data Retention',
                            content: 'We retain your data for as long as your account is active, or as required by applicable law. Upon account deletion, your personal data is removed within 30 days, except where legal obligations require otherwise.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Security',
                            content: 'We use industry-standard encryption (TLS in transit, AES-256 at rest) and rigorous security practices to protect your personal data. However, no method of internet transmission is 100% secure, and we cannot guarantee absolute security.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Cookies & Tracking',
                            content: 'We use cookies and similar tracking technologies to improve app performance, remember your preferences, and personalise content. You can manage cookie preferences through your device or browser settings at any time.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Children\'s Privacy',
                            content: 'Nearly is strictly for users aged 18 and older. We do not knowingly collect data from anyone under 18. If we discover that a minor has registered, we will immediately delete their account and associated data.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Changes to This Policy',
                            content: 'We may update this Privacy Policy from time to time. We will notify you of significant changes via email or in-app notification. Continued use of Nearly after changes constitutes your acceptance of the updated policy.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          _PolicySection(
                            title: 'Contact Us',
                            content: 'For questions or concerns about this Privacy Policy, reach us at privacy@nearly.app or write to Nearly Inc., 123 Connection Lane, Mumbai 400001, India.',
                            titleColor: AppColors.primary,
                            textColor: textMuted,
                          ),
                          const SizedBox(height: 36), // Space for scroll fade effect equivalent
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // --- Footer ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
              child: Column(
                children: [
                  Text(
                    'Last updated: May 2026',
                    style: TextStyle(
                      fontSize: 10,
                      color: textDim,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: controller.isButtonEnabled.value ? 1.0 : 0.5,
                      child: IgnorePointer(
                        ignoring: !controller.isButtonEnabled.value,
                        child: GradientButton(
                          label: 'Agree & Continue',
                          onTap: controller.agreeAndContinue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: textDim,
                          ),
                        ),
                        const TextSpan(
                          text: ' and confirm you have read our Privacy Policy. You must be 18 or older to use Nearly.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.6,
                      color: textDim,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  final Color titleColor;
  final Color textColor;

  const _PolicySection({
    required this.title,
    required this.content,
    required this.titleColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: titleColor,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.7,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
