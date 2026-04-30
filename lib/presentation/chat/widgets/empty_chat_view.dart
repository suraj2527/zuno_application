import 'package:flutter/material.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';

class EmptyChatView extends StatelessWidget {
  const EmptyChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular glow background with chat icon
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.06),
                ),
              ),
              // Inner glow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.12),
                ),
              ),
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.cardDark : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.20),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            'No messages yet',
            style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Start connecting with your matches!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.textHintDark : const Color(0xFF888888),
            ),
          ),

          const SizedBox(height: 28),

          // Browse Profiles CTA
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                // Navigate to Explore/Home
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.favorite_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Browse Profiles',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
