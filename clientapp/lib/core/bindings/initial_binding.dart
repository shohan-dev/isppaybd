import 'package:get/get.dart';
import 'package:clientapp/core/services/data_service.dart';
import 'package:clientapp/features/auth/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize data service synchronously first
    Get.put<DataService>(DataService(), permanent: true);

    // Initialize auth controller after data service is available
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
