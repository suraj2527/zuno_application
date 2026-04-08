import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  // ================= Controllers =================

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // ================= State =================

  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final secondsRemaining = 0.obs;
  final isPasswordVisible = false.obs;
  final selectedLoginTab = 0.obs; // 0 = Email, 1 = Phone

  Timer? _timer;

  // ================= UI Actions =================

  void switchTab(int index) {
    selectedLoginTab.value = index;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // ================= Auth Logic =================

  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Missing Fields', 'Please enter email and password');
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    final bool userExists = _mockUserExists(email: email);

    isLoading.value = false;

    if (userExists) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/onboarding');
    }
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.length != 10) {
      Get.snackbar('Invalid Number', 'Please enter a valid 10-digit number');
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;

    isOtpSent.value = true;
    startResendTimer();

    Get.snackbar('OTP Sent', 'A 6-digit OTP has been sent to +91 $phone');
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      Get.snackbar('Invalid OTP', 'Please enter a valid 6-digit OTP');
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    final bool userExists = _mockUserExists(phone: phoneController.text.trim());

    isLoading.value = false;

    if (userExists) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/onboarding');
    }
  }

  Future<void> resendOtp() async {
    otpController.clear();
    await sendOtp();
  }

  Future<void> googleLogin() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;

    final bool userExists = true;

    if (userExists) {
      Get.offAllNamed('/onboarding');
    } 
  }

  // ================= Helpers =================

  void startResendTimer() {
    secondsRemaining.value = 30;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value == 0) {
        timer.cancel();
      } else {
        secondsRemaining.value--;
      }
    });
  }

  bool _mockUserExists({String? email, String? phone}) {
    // Dummy test users:
    // Existing email: demo@zuno.com
    // Existing phone: 9999999999

    if (email != null && email == 'demo@zuno.com') return true;
    if (phone != null && phone == '9999999999') return true;

    return false;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }
}