import 'package:flutter/material.dart';

class AppColors {
  // ── Primary brand ──────────────────────────────
  static const Color primary = Color(0xFF5B4CDB); // Deep Indigo (redesign)
  static const Color primary2 = Color(0xFF7B6EE8);
  static const Color primary3 = Color(0xFFA49DF0);
  static const Color primary4 = Color(0xFFECEAFB); // Soft Lavender
  static const Color primary5 = Color(0xFFF3F2FD);

  // ── Secondary accent ───────────────────────────
  static const Color roseGold = Color(0xFFE8857A); // Warm rose gold (CTAs / highlights)

  // For CHAT

  static const Color chatHeaderSurfaceLight = Color(0xFFFFFFFF);
  static const Color chatHeaderSurfaceDark = Color(0xFF171A22);
  static const Color profileAvatarBackground = Color(0xFFF0EDFF);
  
  static const Color chatSectionSurfaceLight = Color(0xFFFFFFFF);
  static const Color chatSectionSurfaceDark = Color(0xFF1B1F2A);

  static const Color chatTileHoverLight = Color(0xFFF7F5FF);
  static const Color chatTileHoverDark = Color(0xFF242938);

  static const Color chatActiveSurfaceLight = Color(0xFFF8F6FF);
  static const Color chatActiveSurfaceDark = Color(0xFF1E2330);

  static const Color subtlePurpleLight = Color(0xFFE7DFFF);
  static const Color subtlePurpleDark = Color(0xFF2C2347);

  // ── Accent gold ────────────────────────────────
  static const Color accent = Color(0xFFF59E0B);
  static const Color accent2 = Color(0xFFFCD34D);

  // ── Semantic ───────────────────────────────────
  static const Color green = Color(0xFF10B981);
  static const Color error = Color(0xFFE74C3C);

  // ── Light theme ────────────────────────────────
  static const Color scaffoldLight = Color(0xFFF8F8FB); // Clean off-white (redesign)
  static const Color cardLight = Colors.white;
  static const Color textPrimary = Color(0xFF0F0A1E);
  static const Color textSecondary = Color(0xFF5B4C8A);
  static const Color textHint = Color(0xFFA89BC9);
  static const Color inputFillLight = Color(0xFFF5F3FF);
  static const Color inputBorderLight = Color(0xFFEDE9FE);

  // ── Dark theme ─────────────────────────────────
  static const Color scaffoldDark = Color(0xFF0F111A);
  static const Color cardDark = Color(0xFF1C1F2A);
  static const Color primaryDark = Color(0xFF8B7CF6);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B3C7);
  static const Color textHintDark = Color(0xFF7C7F99);
  static const Color inputFillDark = Color(0xFF252836);
  static const Color inputBorderDark = Color(0xFF2E3245);

  // ── Backward-compat aliases ────────────────────
  static const Color primaryLight = primary;
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryLight = textSecondary;
  static const Color textHintLight = textHint;

  // Extra
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  static const Color profilePlaceholderStart = Color(0xFFDDD6FE);
  static const Color profilePlaceholderEnd = Color(0xFFC4B5FD);

  static const Color chipBackground = Color(0xEBFFFFFF); // ~ white 92%
  static const Color swipeOverlayDark = Color(0x73000000); // ~ black 45%

  static const Color goldIcon = Color(0xFF78350F);
}
