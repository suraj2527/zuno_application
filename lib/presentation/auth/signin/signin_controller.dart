import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nearly/data/sources/local/local_storage.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class SignInController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  final AuthService _authService = AuthService();
  final AuthRepository _authRepository = AuthRepository();

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
      final userCredential = await _authService.signInWithEmail(
        email,
        password,
      );

      final token = await userCredential.user?.getIdToken(true);
      if (token == null) throw "Token not found";

      /// ✅ Health check
      final isBackendOk = await _authRepository.verifyBackend(token);
      if (!isBackendOk) {
        Get.snackbar('Error', 'Server not responding');
        return;
      }

      /// ✅ Login API call
      final response = await _authRepository.login(token);
      final user = userCredential.user;

      /// ✅ SAVE USER DATA
      LocalStorage.saveUser(
        firebaseUid: user!.uid,
        name: user.displayName,
        email: user.email,
        photo: user.photoURL,
        backendUserId: response["userId"]?.toString() ?? '',
      );

      bool isProfileCompleted = response["isProfileCompleted"] == true;

      /// 🔥 SAFE FALLBACK (IMPORTANT FIX)
      if (!isProfileCompleted) {
        try {
          final profileRes = await _authRepository.login(token);
          isProfileCompleted = profileRes["isProfileCompleted"] == true;
        } catch (_) {}
      }

      /// ✅ NAVIGATION
      if (isProfileCompleted) {
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.offAllNamed(Routes.ONBOARDING);
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

      final token = await userCredential.user?.getIdToken(true);
      if (token == null) throw "Token not found";

      /// ✅ Health check
      final isBackendOk = await _authRepository.verifyBackend(token);
      if (!isBackendOk) {
        Get.snackbar('Error', 'Server not responding');
        return;
      }

      /// ✅ Login API call
      final response = await _authRepository.login(token);
      final user = userCredential.user;

      LocalStorage.saveUser(
        firebaseUid: user!.uid,
        name: user.displayName,
        email: user.email,
        photo: user.photoURL,
        backendUserId: response["userId"]?.toString() ?? '',
      );

      bool isProfileCompleted = response["isProfileCompleted"] == true;

      if (!isProfileCompleted) {
        try {
          final profileRes = await _authRepository.login(token);
          isProfileCompleted = profileRes["isProfileCompleted"] == true;
        } catch (_) {}
      }

      /// ✅ NAVIGATION
      if (isProfileCompleted) {
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.offAllNamed(Routes.ONBOARDING);
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
