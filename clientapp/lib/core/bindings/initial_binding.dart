import 'package:get/get.dart';
import 'package:clientapp/core/services/data_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<DataService>(() => DataService().init());
  }
}
