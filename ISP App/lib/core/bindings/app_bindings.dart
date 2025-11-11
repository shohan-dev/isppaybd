import 'package:get/get.dart';
import 'package:ispapp/features/auth/controllers/auth_controller.dart';
import 'package:ispapp/features/home/controllers/home_controller.dart';
import 'package:ispapp/features/packages/controllers/packages_controller.dart';
import 'package:ispapp/features/news/controllers/news_controller.dart';
import 'package:ispapp/features/support/controllers/support_controller.dart';
import 'package:ispapp/shared/widgets/navigation/bottom_navbar/bottom_navbar_controller.dart';

// Main app binding - loaded at app startup
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Put auth controller as permanent since it's needed throughout the app
    Get.put(AuthController(), permanent: true);
  }
}

// Authentication binding
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

// Home binding
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

// Bottom navigation binding
class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavBarController>(() => BottomNavBarController());
  }
}

// Packages binding
class PackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackagesController>(() => PackagesController());
  }
}

// News binding
class NewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(() => NewsController());
  }
}

// Support binding
class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(() => SupportController());
  }
}

