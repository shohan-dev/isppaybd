import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clientapp/core/services/data_service.dart';
import 'package:clientapp/shared/models/app_models.dart';

class PackagesController extends GetxController {
  final DataService _dataService = Get.find<DataService>();

  final isLoading = false.obs;
  final packages = <Package>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPackages();
  }

  Future<void> loadPackages() async {
    isLoading.value = true;

    try {
      final packagesData = _dataService.packages;
      packages.assignAll(
        packagesData.map((item) => Package.fromJson(item)).toList(),
      );
    } catch (e) {
      print('Error loading packages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void activatePackage(int packageId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Activate Package'),
        content: const Text('Are you sure you want to activate this package?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Package activation request sent!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }
}
