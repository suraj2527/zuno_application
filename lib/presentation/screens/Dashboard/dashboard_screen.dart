import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/utils/constants/app_colors.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final pages = [
      const Center(child: Text("Home")),
      const Center(child: Text("Activity")),
      const Center(child: Text("Wallet")),
      const Center(child: Text("Profile")),
    ];

    return Scaffold(
      extendBody: true,

      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white12
                      : Colors.black12,
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: List.generate(
                  4,
                  (index) => _navItem(
                    index: index,
                    icon: _icons[index],
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.bar_chart_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.person_rounded,
  ];

  Widget _navItem({
    required int index,
    required IconData icon,
    required bool isDark,
  }) {
    return Obx(() {
      final isSelected =
          controller.currentIndex.value == index;

      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? (isDark
                    ? AppColors.primaryDark.withOpacity(0.2)
                    : AppColors.primaryLight.withOpacity(0.15))
                : Colors.transparent,
          ),
          child: AnimatedScale(
            scale: isSelected ? 1.25 : 1,
            duration:
                const Duration(milliseconds: 300),
            child: Icon(
              icon,
              size: 26,
              color: isSelected
                  ? (isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight)
                  : (isDark
                      ? Colors.white38
                      : Colors.black38),
            ),
          ),
        ),
      );
    });
  }
}