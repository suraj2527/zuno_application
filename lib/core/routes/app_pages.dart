import 'package:get/get.dart';
import 'package:zuno_application/presentation/screens/Authentication/Onboarding/onboarding_binding.dart';
import 'package:zuno_application/presentation/screens/Authentication/Onboarding/onboarding_screen.dart';
import 'package:zuno_application/presentation/screens/Authentication/SignIn/signin_binding.dart';
import 'package:zuno_application/presentation/screens/Authentication/SignIn/signin_screen.dart';
import 'package:zuno_application/presentation/screens/Dashboard/dashboard_binding.dart';
import 'package:zuno_application/presentation/screens/Dashboard/dashboard_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
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
    ),
  ];
}

