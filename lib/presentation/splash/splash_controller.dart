import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/sources/remote/user_api.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();
  final UserApi _userApi = UserApi();

  @override
  void onReady() {
    super.onReady();
    Future.microtask(_navigate);
  }

  Future<void> _navigate() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final user = _auth.currentUser;

      if (user == null) {
        Get.offAllNamed(Routes.SIGNIN);
        return;
      }

      final token = await user.getIdToken(true);
      if (token == null || token.isEmpty) {
        Get.offAllNamed(Routes.SIGNIN);
        return;
      }

      bool isProfileCompleted = false;

      try {
        final loginRes = await _authRepository.login(token);
        isProfileCompleted = loginRes["isProfileCompleted"] == true;
      } catch (_) {}

      if (!isProfileCompleted) {
        // Fallback: if profile exists, treat user as completed.
        try {
          final profileData = await _userApi.getProfile(token);
          isProfileCompleted = profileData.isNotEmpty;
        } catch (_) {}
      }

      if (isProfileCompleted) {
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.offAllNamed(Routes.ONBOARDING);
      }
    } catch (_) {
      Get.offAllNamed(Routes.SIGNIN);
    }
  }
}