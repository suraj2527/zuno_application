import 'package:get/get.dart';
import 'package:Nearly/core/services/theme_service.dart';
import '../services/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<ThemeService>(ThemeService(), permanent: true);
  }
}
