import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class SplashController extends GetxController {
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
  }

  @override
  void onReady() {
    super.onReady();
    Future.microtask(_navigate);
  }

  Future<void> _navigate() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final user = _authService.currentUser;


      if (user == null) {
        Get.offAllNamed(Routes.SIGNIN);
      } else if (user.displayName == null || user.displayName!.trim().isEmpty) {
        Get.offAllNamed(Routes.ONBOARDING);
      } else {
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } catch (e, stack) {
      Get.offAllNamed(Routes.SIGNIN);
    }
  }
}