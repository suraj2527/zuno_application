import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    Future.microtask(_navigate);
  }

  Future<void> _navigate() async {
    try {
      // simulate splash delay
      await Future.delayed(const Duration(seconds: 2));

      final user = _auth.currentUser;

      if (user == null) {
        // Not logged in → go to SignIn
        Get.offAllNamed(Routes.SIGNIN);
      } else if (user.displayName == null || user.displayName!.trim().isEmpty) {
        // Logged in but no display name → go to Onboarding
        Get.offAllNamed(Routes.ONBOARDING);
      } else {
        // Logged in with name → go to Dashboard
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } catch (e, stack) {
      // If anything fails → go to SignIn
      Get.offAllNamed(Routes.SIGNIN);
    }
  }
}