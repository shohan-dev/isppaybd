import 'package:get/get.dart';
import 'package:clientapp/features/packages/controllers/packages_controller.dart';

class PackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackagesController>(() => PackagesController());
  }
}
