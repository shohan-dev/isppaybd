import 'package:get/get.dart';
import 'package:ispapp/core/routes/app_routes.dart';
import 'package:ispapp/core/bindings/app_bindings.dart';
import 'package:ispapp/features/auth/screens/login_view.dart';
import 'package:ispapp/features/packages/screens/packages_view.dart';
import 'package:ispapp/features/news/screens/news_view.dart';
import 'package:ispapp/features/payment/screens/payment_view.dart';
import 'package:ispapp/features/profile/screen/profile_screen.dart';
import 'package:ispapp/features/subscription/screen/subscription_screen.dart';
import 'package:ispapp/features/support/screens/support_view.dart';
import 'package:ispapp/shared/widgets/navigation/bottom_navbar/bottom_navbar.dart';
import 'package:ispapp/shared/widgets/navigation/splash/splash_screen.dart';

class AppPages {
  static final List<GetPage> pages = [
    // Splash Screen
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),

    // Authentication Routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    // Main Navigation Routes
    GetPage(
      name: AppRoutes.home,
      page: () => BottomNavBar(),
      bindings: [HomeBinding(), BottomNavBinding()],
    ),

    // Dashboard Route (same as home)
    GetPage(
      name: AppRoutes.dashboard,
      page: () => BottomNavBar(),
      bindings: [HomeBinding(), BottomNavBinding()],
    ),

    // Subscription Route
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      // binding: SubscriptionBinding(),
    ),

    // Feature Routes
    GetPage(
      name: AppRoutes.packages,
      page: () => const PackagesView(),
      binding: PackagesBinding(),
    ),

    GetPage(
      name: AppRoutes.news,
      page: () => const NewsView(),
      binding: NewsBinding(),
    ),

    GetPage(
      name: AppRoutes.payment,
      page: () => const PaymentView(),
      // TODO: Add PaymentBinding when created
    ),

    GetPage(
      name: AppRoutes.support,
      page: () => const SupportView(),
      binding: SupportBinding(),
    ),

    // TODO: Add more routes as needed
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      // binding: ProfileBinding(),
    ),
  ];
}
