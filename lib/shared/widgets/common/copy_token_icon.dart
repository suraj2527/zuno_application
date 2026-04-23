import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../constants/app_colors.dart';

class CopyTokenIcon extends StatelessWidget {
  final bool isDark;

  const CopyTokenIcon({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final user = AuthService().currentUser;

        if (user == null) {
          Get.snackbar('Error', 'User not logged in');
          return;
        }

        try {
          final token = await user.getIdToken(true);

          if (token == null) {
            Get.snackbar('Error', 'Token not found');
            return;
          }

          await Clipboard.setData(ClipboardData(text: token));

          debugPrint("🔥 TOKEN: $token");

          Get.snackbar('Copied', 'Token copied');
        } catch (e) {
          Get.snackbar('Error', 'Failed to copy token');
        }
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? AppColors.inputFillDark : AppColors.primary5,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.key_rounded, // 🔑 token icon
          size: 20,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
    );
  }
}
