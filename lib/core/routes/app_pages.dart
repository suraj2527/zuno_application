import 'package:get/get.dart';
import 'package:zuno_application/presentation/screens/Authentication/Onboarding/onboarding_binding.dart';
import 'package:zuno_application/presentation/screens/Authentication/Onboarding/onboarding_screen.dart';
import 'package:zuno_application/presentation/screens/Authentication/SignIn/signin_binding.dart';
import 'package:zuno_application/presentation/screens/Authentication/SignIn/signin_screen.dart';
import 'package:zuno_application/presentation/screens/Authentication/SignUp/signup_screen.dart';
import 'package:zuno_application/presentation/screens/Dashboard/dashboard_binding.dart';
import 'package:zuno_application/presentation/screens/Dashboard/dashboard_screen.dart';
import 'package:zuno_application/presentation/screens/Splash/splash_binding.dart';
import 'package:zuno_application/presentation/screens/Splash/splash_screen.dart';
import '../../presentation/screens/Authentication/SignUp/signup_binding.dart';
import '../../presentation/screens/Dashboard/Chat/chat_detail_screen.dart';
import '../services/permission_service.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.SIGNIN,
      page: () => const SignInScreen(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
      GetPage(
      name: Routes.CHAT_DETAIL,                  
      page: () => ChatDetailScreen(),            
      transition: Transition.rightToLeft,      
      transitionDuration: const Duration(milliseconds: 300), 
    ),
    GetPage(
      name: Routes.PERMISSION,
      page: () => const PermissionServiceScreen(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => const SignUpScreen(),
      binding: SignUpBinding(),
    ),
  ];
}
