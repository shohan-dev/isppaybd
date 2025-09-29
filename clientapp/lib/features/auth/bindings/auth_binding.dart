import 'package:get/get.dart';
import 'package:clientapp/features/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put() instead of Get.lazyPut() to ensure controller is created immediately
    Get.put<AuthController>(AuthController());
  }
}
