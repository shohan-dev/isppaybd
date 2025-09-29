import 'package:get/get.dart';
import 'package:clientapp/core/services/data_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put DataService synchronously so it's available immediately
    Get.put<DataService>(DataService()..init());
  }
}
