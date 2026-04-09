import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/routes/app_routes.dart';

class SignInController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  final AuthService _authService = AuthService();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// ================= Email Login =================
  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password');
      return;
    }

    isLoading.value = true;

    try {
      final userCredential = await _authService.signInWithEmail(email, password);

      // Check if user has a display name (onboarding check)
      if (userCredential.user != null && (userCredential.user!.displayName == null || userCredential.user!.displayName!.isEmpty)) {
        Get.offAllNamed(Routes.ONBOARDING);
      } else {
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= Google Login =================
  Future<void> googleLogin() async {
    isLoading.value = true;

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential.user != null && (userCredential.user!.displayName == null || userCredential.user!.displayName!.isEmpty)) {
        Get.offAllNamed(Routes.ONBOARDING);
      } else {
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } catch (e) {
      Get.snackbar('Google Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}