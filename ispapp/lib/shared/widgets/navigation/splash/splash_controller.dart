import 'package:get/get.dart';
import 'package:ispapp/core/services/storage_service.dart';
import 'package:ispapp/core/routes/app_routes.dart';

class SplashScreenController extends GetxController {
  // Timer for splash screen duration
  final RxBool isLoading = true.obs;
  final StorageService _storageService = StorageService.instance;

  @override
  void onInit() {
    super.onInit();
    _navigateAfterDelay();
  }

  // Navigate after a delay
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Check if user is logged in using StorageService
      final isLoggedIn = _storageService.isLoggedIn();
      final userData = _storageService.getUserData();
      final token = await _storageService.getUserToken();

      print('=== SPLASH DEBUG ===');
      print('User logged in: $isLoggedIn');
      print('User data exists: ${userData != null}');
      print('Token exists: ${token != null}');
      print('==================');

      // User is considered logged in if they have both login status and user data
      if (isLoggedIn) {
        print('Navigating to home screen');
        Get.offNamed(AppRoutes.home);
      } else {
        print('Navigating to login screen');
        // Clear any invalid data
        Get.offNamed(AppRoutes.login);
      }
    } catch (e) {
      print('Error checking login status: $e');
      // On error, navigate to login
      Get.offNamed(AppRoutes.login);
    }
  }
}
