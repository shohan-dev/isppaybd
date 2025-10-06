import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  // Timer for splash screen duration
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _navigateAfterDelay();
  }

  // Navigate after a delay
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    // Always navigate to login for now
    Get.offNamed('/login');
  }
}
