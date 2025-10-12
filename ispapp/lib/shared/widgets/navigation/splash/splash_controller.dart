import 'package:get/get.dart';
import 'package:ispapp/core/helpers/local_storage/storage_helper.dart';
import 'package:ispapp/core/routes/app_routes.dart';

class SplashScreenController extends GetxController {
  // Timer for splash screen duration
  final RxBool isLoading = true.obs;

  // Storage key for user_id - same as AuthController
  static const String _keyUserId = 'user_id';

  @override
  void onInit() {
    super.onInit();
    _navigateAfterDelay();
  }

  // Navigate after a delay
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final islogin = AppStorageHelper.get(_keyUserId);
      final userId = AppStorageHelper.get<String>(_keyUserId);

      // Debugging output
      print('💾 Storage check - user_id: $userId');
      print('🔐 Is user logged in? $islogin');

      if (islogin != null) {
        print('✅ User authenticated (ID: $userId) → Dashboard');
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        print('❌ User not authenticated → Login');
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      print('💥 SPLASH ERROR: $e');
      print('🔄 Defaulting to login screen');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
