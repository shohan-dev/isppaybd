import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ispapp/core/config/constants/api.dart';
import 'package:ispapp/core/helpers/local_storage/storage_helper.dart';
import 'package:ispapp/core/services/api_service.dart';
import 'package:ispapp/core/helpers/toast_helper.dart';
import '../models/subscription_model.dart';

class SubscriptionController extends GetxController {
  final Rx<SubscriptionModel?> subscription = Rx<SubscriptionModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRenewing = false.obs;
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

  /// Show confirmation dialog before renewing subscription
  Future<void> showRenewConfirmation(BuildContext context) async {
    final selectedPkg = selectedPackage.value;

    if (selectedPkg == null) {
      AppToastHelper.showToast(
        message: 'Please select a package first',
        title: 'Warning',
        type: ToastType.warning,
      );
      return;
    }

    final isCurrent = isCurrentPackage(selectedPkg);
    final days = daysRemaining;

    // Build confirmation message
    String message;
    String actionText;
    Color actionColor;

    if (isCurrent && days > 0) {
      // Renewing current package with days remaining
      message =
          'You have $days days remaining on your current package.\n\n'
          'Are you sure you want to renew now?\n\n'
          'Package: ${selectedPkg.packageName}\n'
          'Speed: ${selectedPkg.formattedBandwidth}\n'
          'Price: ${selectedPkg.formattedPrice}';
      actionText = 'Yes, Renew Now';
      actionColor = Colors.orange;
    } else if (!isCurrent && days > 0) {
      // Changing to different package with days remaining
      message =
          'You have $days days remaining on your current package.\n\n'
          'Changing package will forfeit remaining days.\n\n'
          'New Package: ${selectedPkg.packageName}\n'
          'Speed: ${selectedPkg.formattedBandwidth}\n'
          'Price: ${selectedPkg.formattedPrice}\n\n'
          'Do you want to continue?';
      actionText = 'Yes, Change Package';
      actionColor = Colors.red;
    } else {
      // No days remaining or expired
      message =
          'Confirm subscription renewal:\n\n'
          'Package: ${selectedPkg.packageName}\n'
          'Speed: ${selectedPkg.formattedBandwidth}\n'
          'Price: ${selectedPkg.formattedPrice}\n\n'
          'Do you want to proceed?';
      actionText = 'Yes, Proceed';
      actionColor = Colors.green;
    }

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              days > 0 ? Icons.warning_amber_rounded : Icons.info_outline,
              color: actionColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirm Renewal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 14, height: 1.5)),
              if (days > 0 && !isCurrent) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Warning: You will lose $days days of service',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(actionText),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      await renewSubscription();
    }
  }

  /// Renew subscription with selected package
  Future<void> renewSubscription() async {
    final selectedPkg = selectedPackage.value;

    if (selectedPkg == null) {
      AppToastHelper.showToast(
        message: 'Please select a package',
        title: 'Error',
        type: ToastType.error,
      );
      return;
    }

    if (userId == null) {
      AppToastHelper.showToast(
        message: 'User ID not found',
        title: 'Error',
        type: ToastType.error,
      );
      return;
    }

    isRenewing.value = true;

    try {
      final request = SubscriptionRenewRequest(
        role: 'user',
        packageId: selectedPkg.id,
        customer: userId.toString(),
      );

      final url = '${AppApi.subscriptionRenew}?${request.toQueryString()}';

      print('🔄 Renewing subscription: $url');

      final response = await ApiService.instance
          .post<SubscriptionRenewResponse>(
            url,
            mapper: (data) => SubscriptionRenewResponse.fromJson(data),
          );

      print('📊 Renewal Response: ${response.data}');

      if (response.success) {
        AppToastHelper.showToast(
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Subscription renewed successfully!',
          title: 'Success',
          type: ToastType.success,
          duration: const Duration(seconds: 4),
        );

        // Refresh subscription data
        await loadSubscription();

        // Show success dialog
        _showSuccessDialog(selectedPkg);
      } else {
        AppToastHelper.showToast(
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to renew subscription',
          title: 'Error',
          type: ToastType.error,
        );
      }
    } catch (e) {
      print('❌ Error renewing subscription: $e');
      AppToastHelper.showToast(
        message: 'Error: ${e.toString()}',
        title: 'Error',
        type: ToastType.error,
      );
    } finally {
      isRenewing.value = false;
    }
  }

  /// Show success dialog after renewal
  void _showSuccessDialog(PackageModel package) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Renewal Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your subscription has been renewed successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    package.packageName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${package.formattedBandwidth} • ${package.formattedPrice}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
