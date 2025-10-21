import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/config/constants/api.dart';
import 'package:ispapp/core/helpers/local_storage/storage_helper.dart';
import '../models/payment_model.dart';

class PaymentController extends GetxController {
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final userId = AppStorageHelper.get('user_id');

  // Filter options
  final RxString selectedFilter = 'all'.obs;
  final RxList<String> filterOptions =
      ['all', 'successful', 'pending', 'failed'].obs;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('💳 Loading payments for user: $userId');

      if (userId == null) {
        errorMessage.value = 'User ID not found. Please login again.';
        return;
      }

      // final response = await ApiService.instance.get<List<dynamic>>(
      //   AppApi.payment + userId.toString(),
      final response = await Dio().get<List<dynamic>>(
        AppApi.payment + userId.toString(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      print('🔍 Response success: ${response.statusCode == 200}');
      print('🔍 Response data length: ${response.data?.length}');
      print('🔍 Response message: ${response.statusMessage}');

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data!.isNotEmpty) {
        final paymentList = response.data!;

        print('🔄 Processing ${paymentList.length} payment items...');

        try {
          payments.value =
              paymentList.map((json) {
                print('🔍 Processing item: $json');
                return PaymentModel.fromJson(json as Map<String, dynamic>);
              }).toList();

          // Sort by paid date (newest first)
          payments.sort((a, b) => b.paidAt.compareTo(a.paidAt));

          errorMessage.value = ''; // Clear error on success
          print('✅ Successfully loaded ${payments.length} payment records');
        } catch (parseError) {
          print('❌ Error parsing payment data: $parseError');
          errorMessage.value = 'Error parsing payment data';
          payments.value = [];
        }
      } else if (response.statusCode == 200 &&
          (response.data == null || response.data!.isEmpty)) {
        print('ℹ️ No payments found for user');
        payments.value = [];
        errorMessage.value = ''; // Clear any previous errors
      } else {
        errorMessage.value =
            (response.statusMessage!.isNotEmpty
                ? response.statusMessage
                : 'Failed to load payments')!;
        print('⚠️ Failed to load payments: ${response.statusMessage}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Error loading payments: $e';
      print('❌ Error loading payments: $e');
      print('📍 Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPayments() async {
    await loadPayments();
  }

  // Filtered payments based on selected filter
  List<PaymentModel> get filteredPayments {
    if (selectedFilter.value == 'all') {
      return payments;
    }
    return payments.where((payment) {
      return payment.status.toLowerCase() == selectedFilter.value;
    }).toList();
  }

  // Statistics
  double get totalPaid {
    return payments
        .where((p) => p.isSuccessful)
        .fold(0.0, (sum, payment) => sum + payment.payAmount);
  }

  double get totalPending {
    return payments
        .where((p) => p.isPending)
        .fold(0.0, (sum, payment) => sum + payment.payAmount);
  }

  int get successfulCount {
    return payments.where((p) => p.isSuccessful).length;
  }

  int get pendingCount {
    return payments.where((p) => p.isPending).length;
  }

  int get failedCount {
    return payments.where((p) => p.isFailed).length;
  }

  // Group payments by month
  Map<String, List<PaymentModel>> get paymentsByMonth {
    Map<String, List<PaymentModel>> grouped = {};

    for (var payment in payments) {
      String key = '${payment.month} ${payment.paidAt.year}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(payment);
    }

    return grouped;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
}
