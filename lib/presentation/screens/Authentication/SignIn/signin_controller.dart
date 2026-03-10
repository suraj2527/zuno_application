import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';

class SignInController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final secondsRemaining = 30.obs;

  Timer? _timer;

  /* ================= SEND OTP ================= */

  Future<void> sendOtp() async {
    try {
      isLoading.value = true;

      await _authService.sendOtp(
        phoneNumber: "+91${phoneController.text.trim()}",
        codeSent: (_) {
          isOtpSent.value = true;
          startTimer();
        },
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /* ================= VERIFY OTP ================= */

 Future<void> verifyOtp() async {
  try {
    isLoading.value = true;
    await _authService.verifyOtp(otpController.text.trim());

    final user = _authService.currentUser;

    final isNewUser = user?.displayName == null;

    if (isNewUser) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/dashboard');
    }
  } finally {
    isLoading.value = false;
  }
}

  /* ================= TIMER ================= */

  void startTimer() {
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

  void resendOtp() {
    if (secondsRemaining.value == 0) {
      sendOtp();
    }
  }

  /* ================= GOOGLE ================= */

  Future<void> googleLogin() async {
    try {
    isLoading.value = true;
    await _authService.verifyOtp(otpController.text.trim());

    final user = _authService.currentUser;

    final isNewUser = user?.displayName == null;

    if (isNewUser) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/dashboard');
    }
  } finally {
    isLoading.value = false;
  }
  }


  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }
}