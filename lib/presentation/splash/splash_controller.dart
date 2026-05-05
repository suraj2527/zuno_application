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
    final minimumWait = Future.delayed(const Duration(seconds: 2));
    
    try {
      final user = _auth.currentUser;

      if (user == null) {
        await minimumWait;
        Get.offAllNamed(Routes.SIGNIN);
        return;
      }

      final token = await user.getIdToken(true);
      if (token == null || token.isEmpty) {
        await minimumWait;
        Get.offAllNamed(Routes.SIGNIN);
        return;
      }

      // Hit login and profile APIs in parallel for faster startup
      final results = await Future.wait([
        _authRepository.login(token).catchError((_) => <String, dynamic>{}),
        _userApi.getProfile(token).catchError((_) => <String, dynamic>{}),
      ]);

      final loginRes = results[0];
      final profileData = results[1];

      final bool isProfileCompleted = (loginRes["isProfileCompleted"] == true) || 
                                     (profileData.isNotEmpty);

      // Ensure splash screen is visible for at least 2 seconds for UX
      await minimumWait;

      if (isProfileCompleted) {
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.offAllNamed(Routes.ONBOARDING);
      }
    } catch (e) {
      await minimumWait;
      Get.offAllNamed(Routes.SIGNIN);
    }
  }
}
