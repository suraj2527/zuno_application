import 'package:flutter/material.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';

class EmptyChatView extends StatelessWidget {
  const EmptyChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withOpacity(0.65)
            : AppColors.cardLight.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.inputBorderDark
              : AppColors.inputBorderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mark_chat_unread_rounded,
            size: 38,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          Text(
            'No chats yet',
            style: AppTextStyles.headingMedium(isDark: isDark),
          ),
          const SizedBox(height: 6),
          Text(
            'When you match with someone, your conversations will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(isDark: isDark),
          ),
        ],
      ),
    );
  }
}
