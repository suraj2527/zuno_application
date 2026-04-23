import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nearly/presentation/home/home_controller.dart';
import 'package:nearly/shared/constants/app_colors.dart';
import 'package:nearly/shared/constants/app_gradients.dart';
import 'package:nearly/shared/constants/app_text_styles.dart';

import 'copy_token_icon.dart';

class ZunoTopBar extends StatelessWidget {
  final bool isDark;

  const ZunoTopBar({super.key, required this.isDark});

  HomeController get controller => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// 🔥 LOGO
            ShaderMask(
              shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
              child: Text(
                'nearly',
                style: AppTextStyles.logo(isDark: false)
                    .copyWith(color: AppColors.white, fontSize: 30, height: 1),
              ),
            ),

            /// 🔥 ICONS WITH BADGES
            Row(
              children: [
                CopyTokenIcon(isDark: isDark),
                const SizedBox(width: 10),
                _headerIcon(icon: Icons.groups_2_outlined, badge: '3'),
                const SizedBox(width: 10),
                _headerIcon(icon: Icons.notifications_none_rounded, badge: '5'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 UNIVERSAL ICON WITH OPTIONAL BADGE
  Widget _headerIcon({
    required IconData icon,
    String? badge,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? AppColors.inputFillDark : AppColors.primary5,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        if (badge != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                badge,
                style: AppTextStyles.label(isDark: true)
                    .copyWith(color: AppColors.white, fontSize: 7, height: 1),
              ),
            ),
          ),
      ],
    );
  }
}