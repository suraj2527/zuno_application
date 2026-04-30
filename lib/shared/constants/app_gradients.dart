import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  /// Main brand gradient  #5B4CDB → #7B6EE8 → #A49DF0
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B4CDB), Color(0xFF7B6EE8), Color(0xFFA49DF0)],
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

  /// Premium accent (Indigo to Rose Gold)
  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B4CDB), Color(0xFFE8857A)], // Indigo to Rose Gold
  );

  /// Page background (body gradient)
  static const LinearGradient scaffold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.5, 1.0),
    colors: [Color(0xFFEAE4FF), Color(0xFFF0EDFF), Color(0xFFE8F4FF)],
    stops: [0.0, 0.4, 1.0],
  );
}
