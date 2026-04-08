import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  /// Main brand gradient  #6C3BFF → #9B59FF → #C084FC
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C3BFF), Color(0xFF9B59FF), Color(0xFFC084FC)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Softer two-tone brand
  static const LinearGradient primary2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary2, Color(0xFFC084FC)],
  );

  /// Light/soft lavender background
  static const LinearGradient soft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary4, AppColors.primary5],
  );

  /// Gold accent
  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent, AppColors.accent2],
  );

  /// Page background (body gradient)
  static const LinearGradient scaffold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.5, 1.0),
    colors: [Color(0xFFEAE4FF), Color(0xFFF0EDFF), Color(0xFFE8F4FF)],
    stops: [0.0, 0.4, 1.0],
  );
}
