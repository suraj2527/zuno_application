import 'package:get/get.dart';
import 'package:nearly/presentation/auth/onboarding/onboarding_binding.dart';
import 'package:nearly/presentation/auth/onboarding/onboarding_screen.dart';
import 'package:nearly/presentation/auth/signin/signin_binding.dart';
import 'package:nearly/presentation/auth/signin/signin_screen.dart';
import 'package:nearly/presentation/auth/signup/signup_screen.dart';
import 'package:nearly/presentation/dashboard/dashboard_binding.dart';
import 'package:nearly/presentation/dashboard/dashboard_screen.dart';
import 'package:nearly/presentation/splash/splash_binding.dart';
import 'package:nearly/presentation/splash/splash_screen.dart';
import '../../presentation/auth/signup/signup_binding.dart';
import '../../presentation/chat/chat_detail_screen.dart';
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
