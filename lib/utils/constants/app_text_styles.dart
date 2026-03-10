import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle headingLarge(bool isDark) => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
      );

  static TextStyle headingMedium(bool isDark) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
      );

  static TextStyle body(bool isDark) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      );

  static TextStyle bodySmall(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark
            ? AppColors.textHintDark
            : AppColors.textHintLight,
      );

  static const TextStyle button = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );
}