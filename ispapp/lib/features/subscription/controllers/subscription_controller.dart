import 'package:get/get.dart';
import 'package:ispapp/core/config/constants/api.dart';
import 'package:ispapp/core/helpers/local_storage/storage_helper.dart';
import 'package:ispapp/core/services/api_service.dart';
import '../models/subscription_model.dart';

class SubscriptionController extends GetxController {
  final Rx<SubscriptionModel?> subscription = Rx<SubscriptionModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final userId = AppStorageHelper.get('user_id');

  // Selected package for upgrade/downgrade
  final Rx<PackageModel?> selectedPackage = Rx<PackageModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadSubscription();
  }

  Future<void> loadSubscription() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('📦 Loading subscription for user: $userId');

      if (userId == null) {
        errorMessage.value = 'User ID not found. Please login again.';
        return;
      }

      final response = await ApiService.instance.get<Map<String, dynamic>>(
        AppApi.subscription + userId.toString(),
        mapper: (data) {
          print('📦 Raw subscription response: $data');
          if (data is Map) {
            return data as Map<String, dynamic>;
          }
          return {};
        },
      );

      print('🔍 Response success: ${response.success}');
      print('🔍 Response data: ${response.data}');

      if (response.success && response.data != null) {
        subscription.value = SubscriptionModel.fromJson(response.data!);

        // Set current package as selected by default
        selectedPackage.value = subscription.value?.currentPackage;

        errorMessage.value = '';
        print('✅ Subscription loaded successfully');
      } else {
        errorMessage.value =
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load subscription';
        print('⚠️ Failed to load subscription: ${response.message}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Error loading subscription: $e';
      print('❌ Error loading subscription: $e');
      print('📍 Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSubscription() async {
    await loadSubscription();
  }

  void selectPackage(PackageModel package) {
    selectedPackage.value = package;
  }

  // Check if package is currently active
  bool isCurrentPackage(PackageModel package) {
    return subscription.value?.currentPackage?.id == package.id;
  }

  // Check if package is upgrade (higher bandwidth)
  bool isUpgrade(PackageModel package) {
    final current = subscription.value?.currentPackage;
    if (current == null) return false;

    final currentBandwidth = int.tryParse(current.bandwidth) ?? 0;
    final packageBandwidth = int.tryParse(package.bandwidth) ?? 0;

    return packageBandwidth > currentBandwidth;
  }

  // Check if package is downgrade (lower bandwidth)
  bool isDowngrade(PackageModel package) {
    final current = subscription.value?.currentPackage;
    if (current == null) return false;

    final currentBandwidth = int.tryParse(current.bandwidth) ?? 0;
    final packageBandwidth = int.tryParse(package.bandwidth) ?? 0;

    return packageBandwidth < currentBandwidth;
  }

  // Get subscription status color
  bool get isSubscriptionActive {
    return subscription.value?.isActive ?? false;
  }

  // Get days remaining
  int get daysRemaining {
    return subscription.value?.daysRemaining ?? 0;
  }

  // Get percentage remaining
  double get percentageRemaining {
    return subscription.value?.percentageRemaining ?? 0;
  }
}
