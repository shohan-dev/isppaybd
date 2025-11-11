import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/constants/api.dart';
import '../../../core/config/constants/color.dart';
import '../../../core/services/api_service.dart';
import '../../../core/helpers/local_storage/storage_helper.dart';
import '../models/package_model.dart';

class PackagesController extends GetxController {
  final ApiService _apiService = ApiService.instance;
  static const String _keyUserId = 'user_id';

  final RxList<PackageModel> availablePackages = <PackageModel>[].obs;
  final Rx<PackageModel?> currentUserPackage = Rx<PackageModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentPackageId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPackages();
  }

  Future<void> loadPackages() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get user ID from storage
      final userId = AppStorageHelper.get<String>(_keyUserId);
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'User ID not found. Please login again.';
        isLoading.value = false;
        return;
      }

      print('📦 Fetching packages for user: $userId');

      // Fetch packages from API
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppApi.packages}$userId',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📦 API Response - Success: ${response.success}');
      print('📦 API Response - Data: ${response.data}');

      if (response.success && response.data != null) {
        final packagesResponse = PackagesResponse.fromJson(response.data!);

        // Update current package ID
        currentPackageId.value = packagesResponse.currentPackageId ?? '';

        // Filter only visible and active packages
        final visiblePackages =
            packagesResponse.packages
                .where((pkg) => pkg.isVisible && pkg.isActive)
                .toList();

        // Sort packages by bandwidth
        visiblePackages.sort(
          (a, b) => a.bandwidthValue.compareTo(b.bandwidthValue),
        );

        availablePackages.assignAll(visiblePackages);

        // Set current user package
        if (currentPackageId.value.isNotEmpty) {
          try {
            currentUserPackage.value = visiblePackages.firstWhere(
              (pkg) => pkg.id == currentPackageId.value,
            );
          } catch (e) {
            currentUserPackage.value =
                visiblePackages.isNotEmpty ? visiblePackages.first : null;
          }
        }

        print('📦 Loaded ${availablePackages.length} packages');
        print('📦 Current package ID: ${currentPackageId.value}');
        print(
          '📦 Current package name: ${currentUserPackage.value?.packageName ?? "None"}',
        );
      } else {
        errorMessage.value = response.message;
        print('❌ Error: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'Error loading packages: ${e.toString()}';
      print('❌ Exception: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void requestPackageUpgrade(PackageModel package) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.upgrade, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            const Text('Package Upgrade'),
          ],
        ),
        content: Text(
          'Do you want to upgrade to ${package.packageName} package (${package.bandwidth}MB) for ৳${package.priceValue.toInt()}/${package.pricingType}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _processUpgradeRequest(package);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Request Upgrade'),
          ),
        ],
      ),
    );
  }

  void _processUpgradeRequest(PackageModel package) {
    Get.snackbar(
      'Request Submitted',
      'Your upgrade request for ${package.packageName} has been submitted. Our team will contact you soon.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  String getPackageRecommendation(PackageModel package) {
    final bandwidth = package.bandwidthValue;
    print('📦 Bandwidth: $bandwidth Mbps');
    if (bandwidth <= 10) {
      return 'Good for light browsing and basic needs';
    } else if (bandwidth <= 20) {
      return 'Recommended for families and home users';
    } else if (bandwidth <= 50) {
      return 'Perfect for streaming and moderate usage';
    } else {
      return 'Best for heavy usage and businesses';
    }
  }

  bool isCurrentPackage(PackageModel package) {
    return currentPackageId.value == package.id;
  }

  void showPackageDetails(PackageModel package) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.wifi, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                package.packageName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Speed',
                '${package.bandwidth} Mbps',
                Icons.speed,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Price',
                '৳${package.priceValue.toInt()}/${package.pricingType}',
                Icons.attach_money,
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Status', package.status, Icons.info_outline),
              const SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('High-speed internet connection'),
              _buildFeatureItem('24/7 customer support'),
              _buildFeatureItem('Reliable and stable connection'),
              _buildFeatureItem('Easy billing and payment options'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          if (!isCurrentPackage(package))
            ElevatedButton(
              onPressed: () {
                Get.back();
                requestPackageUpgrade(package);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Color getPackageColor(PackageModel package) {
    final bandwidth = package.bandwidthValue;
    return AppColors.getBandwidthColor(bandwidth);
  }

  IconData getPackageIcon(PackageModel package) {
    final bandwidth = package.bandwidthValue;
    if (bandwidth == 0 || bandwidth <= 10) {
      return Icons.wifi_2_bar_rounded;
    } else if (bandwidth <= 20) {
      return Icons.wifi;
    } else if (bandwidth <= 50) {
      return Icons.speed;
    } else if (bandwidth <= 100) {
      return Icons.rocket_launch;
    }

    return Icons.bolt;
  }
}
