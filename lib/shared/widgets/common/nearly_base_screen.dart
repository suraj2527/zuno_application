import 'package:flutter/material.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'Nearly_top_bar.dart';

class NearlyBaseScreen extends StatelessWidget {
  final Widget child;
  final bool isDark;

  /// Optional TabBar (for Activity screen etc.)
  final Widget? tabBar;

  const NearlyBaseScreen({
    super.key,
    required this.child,
    required this.isDark,
    this.tabBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.scaffoldDark : AppColors.primary5,
      child: Column(
        children: [
          /// ✅ SAME header as HomeTab
          NearlyTopBar(isDark: isDark),

          /// ✅ Optional TabBar (only where needed)
          // ignore: use_null_aware_elements
          if (tabBar != null) tabBar!,

          /// ✅ Content area (same structure as HomeTab)
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
