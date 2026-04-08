import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class SplashController extends GetxController {
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    print('🔥 SplashController onInit called');
    _authService = Get.find<AuthService>();
  }

  @override
  void onReady() {
    super.onReady();
    print('🔥 SplashController onReady called');
    Future.microtask(_navigate);
  }

  Future<void> _navigate() async {
    try {
      print('⏳ Splash navigation started...');
      await Future.delayed(const Duration(seconds: 2));

      final user = _authService.currentUser;

      print('========== SPLASH DEBUG ==========');
      print('User: $user');
      print('UID: ${user?.uid}');
      print('Display Name: ${user?.displayName}');
      print('==================================');

      if (user == null) {
        print('➡️ Going to SIGNIN');
        Get.offAllNamed(Routes.SIGNIN);
      } else if (user.displayName == null || user.displayName!.trim().isEmpty) {
        print('➡️ Going to ONBOARDING');
        Get.offAllNamed(Routes.ONBOARDING);
      } else {
        print('➡️ Going to DASHBOARD');
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } catch (e, stack) {
      print('❌ Splash navigation error: $e');
      print(stack);
      Get.offAllNamed(Routes.SIGNIN);
    }
  }
}