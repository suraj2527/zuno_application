import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_gradients.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';

class ExplorePlansScreen extends StatelessWidget {
  const ExplorePlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 32),
                  _buildPlanCard(
                    isDark: isDark,
                    title: "Nearly Plus",
                    price: "\$4.99/mo",
                    description: "Get the basics to stand out.",
                    features: [
                      "Unlimited Likes",
                      "5 Super Likes per day",
                      "See who likes you",
                    ],
                    gradient: AppGradients.primary,
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    isDark: isDark,
                    title: "Nearly Premium",
                    price: "\$12.99/mo",
                    description: "Our most popular plan for serious daters.",
                    features: [
                      "Everything in Plus",
                      "Unlimited Direct Messages",
                      "Global Passport",
                      "Weekly Profile Boost",
                    ],
                    gradient: AppGradients.gold,
                    isPopular: true,
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    isDark: isDark,
                    title: "Nearly Platinum",
                    price: "\$24.99/mo",
                    description: "The ultimate experience for the elite.",
                    features: [
                      "Everything in Premium",
                      "Priority Likes",
                      "Message before matching",
                      "Incognito Mode",
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF4B5563)],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTermsInfo(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : Colors.black87),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Premium Plans",
          style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppGradients.gold.createShader(bounds),
          child: Text(
            "Elevate Your Experience",
            style: AppTextStyles.headingLarge(isDark: isDark).copyWith(
              fontSize: 28,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Unlock exclusive features and find your perfect match faster than ever.",
          style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
            color: isDark ? AppColors.textHintDark : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required bool isDark,
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required LinearGradient gradient,
    bool isPopular = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isPopular ? AppColors.roseGold.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: const BoxDecoration(
                color: AppColors.roseGold,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Text(
                "MOST POPULAR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 18, color: isPopular ? AppColors.roseGold : AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f,
                          style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Get.snackbar("Success", "Welcome to $title!", snackPosition: SnackPosition.BOTTOM);
                    Get.back();
                  },
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: isPopular ? AppGradients.gold : AppGradients.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Center(
                      child: Text(
                        "Choose Plan",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsInfo(bool isDark) {
    return Column(
      children: [
        Text(
          "Subscriptions will automatically renew unless canceled 24 hours prior to the end of the current period.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.black38,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _textLink("Terms of Service"),
            const SizedBox(width: 20),
            _textLink("Privacy Policy"),
          ],
        ),
      ],
    );
  }

  Widget _textLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          "Secure payment via App Store or Google Play",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
