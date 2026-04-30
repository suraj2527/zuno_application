import 'package:flutter/material.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';

class EmptyChatView extends StatelessWidget {
  const EmptyChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Placeholder
          Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset('assets/images/dog.jpg', fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 32),

          Text(
            "You don't have any messages right now",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textHintDark : Colors.black54,
            ),
          ),

          const SizedBox(height: 48),

          // Browse Profiles CTA
          GestureDetector(
            onTap: () {
              // Navigation to Home/Explore
            },
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'BROWSE PROFILES',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
