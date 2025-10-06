import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/features/payment/views/payment_view.dart';
import 'core/config/theme/app_theme.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/packages/views/packages_view.dart';
import 'features/packages/controllers/packages_controller.dart';
import 'features/news/views/news_view.dart';
import 'features/news/controllers/news_controller.dart';
import 'features/support/views/support_view.dart';
import 'features/support/controllers/support_controller.dart';
import 'shared/widgets/navigation/bottom_navbar/bottom_navbar_controller.dart';
import 'shared/widgets/navigation/bottom_navbar/bottom_navbar.dart';
import 'shared/widgets/navigation/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ISP Broadband',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      initialBinding: AppBinding(),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => BottomNavBar(),
          bindings: [HomeBinding(), BottomNavBinding()],
        ),
        GetPage(
          name: '/packages',
          page: () => const PackagesView(),
          binding: PackagesBinding(),
        ),
        GetPage(
          name: '/news',
          page: () => const NewsView(),
          binding: NewsBinding(),
        ),
        // payment
        GetPage(
          name: '/payment',
          page: () => const PaymentView(),
          // binding: PaymentBinding(),
        ),
        GetPage(
          name: '/support',
          page: () => const SupportView(),
          binding: SupportBinding(),
        ),
      ],
    );
  }
}

// Bindings for dependency injection
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavBarController>(() => BottomNavBarController());
  }
}

class PackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackagesController>(() => PackagesController());
  }
}

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(() => NewsController());
  }
}

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(() => SupportController());
  }
}
