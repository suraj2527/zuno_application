import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeService extends GetxController {
  final Rx<ThemeMode> _themeMode = ThemeMode.light.obs;

  ThemeMode get theme => _themeMode.value;

  bool get isDark => _themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    if (_themeMode.value == ThemeMode.light) {
      _themeMode.value = ThemeMode.dark;
    } else {
      _themeMode.value = ThemeMode.light;
    }
    Get.changeThemeMode(_themeMode.value);
  }

  void setLightMode() {
    _themeMode.value = ThemeMode.light;
    Get.changeThemeMode(ThemeMode.light);
  }

  void setDarkMode() {
    _themeMode.value = ThemeMode.dark;
    Get.changeThemeMode(ThemeMode.dark);
  }
}
