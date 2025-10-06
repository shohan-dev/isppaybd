import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/package_model.dart';

class PackagesController extends GetxController {
  final RxList<PackageModel> availablePackages = <PackageModel>[].obs;
  final Rx<PackageModel?> currentUserPackage = Rx<PackageModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPackages();
  }

  Future<void> loadPackages() async {
    isLoading.value = true;

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Dummy package data
    final packages = [
      PackageModel(
        id: 'pkg_1',
        name: '20MBPS',
        speed: '20 Mbps',
        price: 1500.0,
        duration: '30 Days',
        description:
            'Perfect for home users. Stream, browse, and work from home with reliable high-speed internet.',
        isActive: true,
        validUntil: DateTime(2099, 12, 31),
        packageType: 'Residential',
        features: [
          'Unlimited Data',
          '24/7 Support',
          'Free Installation',
          'WiFi Router',
        ],
        dataLimit: 1000.0,
        dataUnit: 'GB',
      ),
      PackageModel(
        id: 'pkg_2',
        name: '50MBPS',
        speed: '50 Mbps',
        price: 3000.0,
        duration: '30 Days',
        description:
            'Ideal for power users and small businesses. Ultra-fast internet for heavy usage.',
        isActive: true,
        validUntil: DateTime(2099, 12, 31),
        packageType: 'Business',
        features: [
          'Unlimited Data',
          'Priority Support',
          'Static IP',
          'Advanced Router',
          'Backup Connection',
        ],
        dataLimit: 2000.0,
        dataUnit: 'GB',
      ),
      PackageModel(
        id: 'pkg_3',
        name: '100MBPS',
        speed: '100 Mbps',
        price: 5000.0,
        duration: '30 Days',
        description:
            'Enterprise-grade solution with maximum speed and reliability for businesses.',
        isActive: true,
        validUntil: DateTime(2099, 12, 31),
        packageType: 'Enterprise',
        features: [
          'Unlimited Data',
          'Dedicated Support',
          'Multiple Static IPs',
          'Enterprise Router',
          '99.9% Uptime SLA',
        ],
        dataLimit: 5000.0,
        dataUnit: 'GB',
      ),
      PackageModel(
        id: 'pkg_4',
        name: '10MBPS',
        speed: '10 Mbps',
        price: 800.0,
        duration: '30 Days',
        description: 'Budget-friendly option for basic internet needs.',
        isActive: true,
        validUntil: DateTime(2099, 12, 31),
        packageType: 'Basic',
        features: ['500GB Data', 'Standard Support', 'Basic Router'],
        dataLimit: 500.0,
        dataUnit: 'GB',
      ),
    ];

    // Sort packages by price for better display
    packages.sort((a, b) => a.price.compareTo(b.price));

    availablePackages.assignAll(packages);

    // Set current user package (assuming they have the 20MBPS package)
    currentUserPackage.value = packages.firstWhere(
      (pkg) => pkg.name == '20MBPS',
      orElse: () => packages.first,
    );

    isLoading.value = false;
  }

  void requestPackageUpgrade(PackageModel package) {
    Get.dialog(
      AlertDialog(
        title: const Text('Package Upgrade Request'),
        content: Text(
          'Do you want to upgrade to ${package.name} package for ৳${package.price.toInt()}/month?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _processUpgradeRequest(package);
            },
            child: const Text('Request Upgrade'),
          ),
        ],
      ),
    );
  }

  void _processUpgradeRequest(PackageModel package) {
    Get.snackbar(
      'Request Submitted',
      'Your upgrade request for ${package.name} has been submitted. Our team will contact you soon.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  String getPackageRecommendation(PackageModel package) {
    switch (package.packageType.toLowerCase()) {
      case 'basic':
        return 'Good for light browsing and basic needs';
      case 'residential':
        return 'Recommended for families and home users';
      case 'business':
        return 'Perfect for small businesses and power users';
      case 'enterprise':
        return 'Best for large businesses and enterprises';
      default:
        return 'High-quality internet service';
    }
  }

  bool isCurrentPackage(PackageModel package) {
    return currentUserPackage.value?.id == package.id;
  }

  void showPackageDetails(PackageModel package) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.wifi, color: const Color(0xFF4A90E2), size: 28),
            const SizedBox(width: 8),
            Text(
              package.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90E2),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Speed: ${package.speed}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: ৳${package.price.toInt()}/${package.duration}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Description:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(package.description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              Text(
                'Features:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...package.features
                  .map<Widget>(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
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
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  String getPackageIcon(String packageType) {
    switch (packageType.toLowerCase()) {
      case 'basic':
        return '🏠';
      case 'residential':
        return '🏡';
      case 'business':
        return '🏢';
      case 'enterprise':
        return '🏭';
      default:
        return '📶';
    }
  }
}
