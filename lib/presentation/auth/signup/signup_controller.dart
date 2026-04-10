import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class SignUpController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final passwordVisible = false.obs;
  final agreedToTerms = false.obs;

  final AuthService _authService = AuthService();

  void togglePasswordVisibility() =>
      passwordVisible.value = !passwordVisible.value;

  void toggleTerms() => agreedToTerms.value = !agreedToTerms.value;

  Future<void> signUpWithEmail() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Oops', 'Please enter your name');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Oops', 'Email and password cannot be empty');
      return;
    }

    if (password.length < 6) {
      Get.snackbar('Oops', 'Password should be at least 6 characters');
      return;
    }

    if (!agreedToTerms.value) {
      Get.snackbar('Oops', 'Please accept the Terms & Privacy Policy');
      return;
    }

    try {
      isLoading.value = true;

      await _authService.signUpWithEmail(email, password);
      await _authService.updateDisplayName(name);

      Get.offAllNamed(Routes.ONBOARDING);
    } catch (e) {
      Get.snackbar('Sign Up Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> googleSignUp() async {
    if (!agreedToTerms.value) {
      Get.snackbar('Oops', 'Please accept the Terms & Privacy Policy');
      return;
    }

    try {
      isLoading.value = true;

      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential.user;

      if (user != null &&
          (user.displayName == null || user.displayName!.trim().isEmpty)) {
        Get.offAllNamed(Routes.ONBOARDING);
      } else {
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } catch (e) {
      Get.snackbar('Google Sign Up Failed', e.toString());
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