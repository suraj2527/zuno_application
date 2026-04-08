import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';

class SignUpController extends GetxController {

  final nameController     = TextEditingController();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading        = false.obs;
  final passwordVisible  = false.obs;
  final agreedToTerms    = false.obs;

  void togglePasswordVisibility() =>
      passwordVisible.value = !passwordVisible.value;

  void toggleTerms() => agreedToTerms.value = !agreedToTerms.value;

  Future<void> signUp() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Oops', 'Please enter your name');
      return;
    }
    if (!agreedToTerms.value) {
      Get.snackbar('Oops', 'Please accept the Terms & Privacy Policy');
      return;
    }
    try {
      isLoading.value = true;
      Get.offAllNamed(Routes.ONBOARDING);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
