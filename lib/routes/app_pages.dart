import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/getx_login_screen.dart';
import '../screens/auth/getx_register_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/home/getx_modern_home_screen.dart';
import '../screens/practice/getx_modern_setup_screen.dart';
import '../screens/practice/getx_modern_practice_screen.dart';
import '../screens/practice/getx_modern_result_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../models/practice_session.dart';
import '../bindings/app_bindings.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.MAIN_NAVIGATION,
      page: () => const MainNavigationScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const ModernHomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.STATISTICS,
      page: () => const StatisticsScreen(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.PRACTICE_SETUP,
      page: () => const ModernSetupScreen(mode: PracticeMode.interview),
      binding: PracticeBinding(),
    ),
    GetPage(
      name: AppRoutes.PRACTICE_SESSION,
      page: () => const ModernPracticeScreen(),
      binding: PracticeBinding(),
    ),
    GetPage(
      name: AppRoutes.PRACTICE_RESULT,
      page: () => const ModernResultScreen(),
      binding: PracticeBinding(),
    ),
  ];
}
