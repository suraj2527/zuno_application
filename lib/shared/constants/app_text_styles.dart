import 'package:flutter/material.dart';
import 'app_colors.dart';

/// All text styles match the Zuno design system.
/// Headings use Syne (800/700), body uses Outfit (300-700).
/// Install both via pubspec: google_fonts package.
class AppTextStyles {
  // ── Display / Logo ──────────────────────────────
  static TextStyle logo({bool isDark = false}) => TextStyle(
        fontFamily: 'Syne',
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      );

  // ── Headings ────────────────────────────────────
  static TextStyle headingXL({bool isDark = false}) => TextStyle(
        fontFamily: 'Syne',
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      );

  static TextStyle headingLarge({bool isDark = false}) => TextStyle(
        fontFamily: 'Syne',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      );

  static TextStyle headingMedium({bool isDark = false}) => TextStyle(
        fontFamily: 'Syne',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      );

  static TextStyle headingSmall({bool isDark = false}) => TextStyle(
        fontFamily: 'Syne',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      );

  // ── Body ────────────────────────────────────────
  static TextStyle body({bool isDark = false}) => TextStyle(
        fontFamily: 'Outfit',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      );

  static TextStyle bodyMedium({bool isDark = false}) => TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      );

  static TextStyle bodySmall({bool isDark = false}) => TextStyle(
        fontFamily: 'Outfit',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textHintDark : AppColors.textHint,
      );

  // ── Labels / Caps ───────────────────────────────
  static TextStyle label({bool isDark = false}) => TextStyle(
        fontFamily: 'Outfit',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: isDark ? AppColors.textHintDark : AppColors.textSecondary,
      );

  // ── Button ──────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  // ── Backwards-compat overloads (positional bool) ─
  // ignore: non_constant_identifier_names
  static TextStyle headingLarge_compat(bool isDark) =>
      headingLarge(isDark: isDark);
  // ignore: non_constant_identifier_names
  static TextStyle headingMedium_compat(bool isDark) =>
      headingMedium(isDark: isDark);
  // ignore: non_constant_identifier_names
  static TextStyle body_compat(bool isDark) => body(isDark: isDark);
  // ignore: non_constant_identifier_names
  static TextStyle bodySmall_compat(bool isDark) =>
      bodySmall(isDark: isDark);
}
