import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';

class OnboardingController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final nameController = TextEditingController();
  final isLoading = false.obs;

  Future<void> completeProfile() async {
    try {
      isLoading.value = true;

      await _authService.updateDisplayName(
        nameController.text.trim(),
      );

      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}