import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:Nearly/data/sources/local/local_storage.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class SignInController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final verificationId = ''.obs;

  final AuthService _authService = AuthService();
  final AuthRepository _authRepository = AuthRepository();

  /// ================= Phone Login =================
  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar('Error', 'Please enter a valid phone number');
      return;
    }

    isLoading.value = true;

    try {
      // Adding +91 if not present (Assuming India based on previous context, or general +)
      String formattedPhone = phone;
      if (!phone.startsWith('+')) {
        formattedPhone = '+91$phone'; 
      }

      await _authService.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        onCodeSent: (id) {
          verificationId.value = id;
          isOtpSent.value = true;
          isLoading.value = false;
          Get.snackbar('Success', 'OTP sent to $formattedPhone');
        },
        onError: (error) {
          isLoading.value = false;
          Get.snackbar('Error', error);
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length < 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP');
      return;
    }

    isLoading.value = true;

    try {
      final userCredential = await _authService.signInWithOtp(
        verificationId.value,
        otp,
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

      /// ✅ NAVIGATION
      if (isProfileCompleted) {
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.offAllNamed(Routes.ONBOARDING);
      }
    } catch (e) {
      Get.snackbar('Verification Failed', e.toString());
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
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
