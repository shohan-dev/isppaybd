import 'package:get/get.dart';
import 'package:clientapp/core/services/data_service.dart';

class PaymentController extends GetxController {
  final DataService _dataService = Get.find<DataService>();

  final isLoading = false.obs;
  final payments = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments() async {
    isLoading.value = true;

    try {
      final paymentsData = _dataService.payments;
      payments.assignAll(paymentsData.cast<Map<String, dynamic>>());
    } catch (e) {
      print('Error loading payments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        return 'success';
      case 'pending':
        return 'warning';
      case 'failed':
        return 'error';
      default:
        return 'info';
    }
  }
}
