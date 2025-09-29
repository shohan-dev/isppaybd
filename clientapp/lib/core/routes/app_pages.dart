import 'package:get/get.dart';
import 'package:clientapp/core/routes/app_routes.dart';
import 'package:clientapp/features/auth/views/splash_screen.dart';
import 'package:clientapp/features/auth/views/login_screen.dart';
import 'package:clientapp/features/dashboard/views/dashboard_screen.dart';
import 'package:clientapp/features/packages/views/packages_screen.dart';
import 'package:clientapp/features/payment/views/payment_screen.dart';
import 'package:clientapp/features/profile/views/profile_screen.dart';
import 'package:clientapp/features/support/views/support_screen.dart';
import 'package:clientapp/features/settings/views/settings_screen.dart';
import 'package:clientapp/features/auth/bindings/auth_binding.dart';
import 'package:clientapp/features/dashboard/bindings/dashboard_binding.dart';
import 'package:clientapp/features/packages/bindings/packages_binding.dart';
import 'package:clientapp/features/payment/bindings/payment_binding.dart';
import 'package:clientapp/features/profile/bindings/profile_binding.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.packages,
      page: () => const PackagesScreen(),
      binding: PackagesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.payments,
      page: () => const PaymentScreen(),
      binding: PaymentBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
