import 'package:get/get.dart';
import 'package:clientapp/core/services/data_service.dart';
import 'package:clientapp/shared/models/app_models.dart';
import 'package:clientapp/shared/models/user_model.dart';

class DashboardController extends GetxController {
  final DataService _dataService = Get.find<DataService>();

  // Observable variables
  final isLoading = false.obs;
  final currentUser = Rxn<User>();
  final dashboardStats = Rxn<DashboardStats>();
  final networkUsage = <NetworkUsage>[].obs;
  final packages = <Package>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;

    try {
      // Load user data
      final userData = _dataService.user;
      if (userData.isNotEmpty) {
        currentUser.value = User.fromJson(userData);
      }

      // Load dashboard stats
      final statsData = _dataService.dashboardStats;
      if (statsData.isNotEmpty) {
        dashboardStats.value = DashboardStats.fromJson(statsData);
      }

      // Load network usage data
      final usageData = _dataService.networkUsage;
      networkUsage.assignAll(
        usageData.map((item) => NetworkUsage.fromJson(item)).toList(),
      );

      // Load packages
      final packagesData = _dataService.packages;
      packages.assignAll(
        packagesData.map((item) => Package.fromJson(item)).toList(),
      );
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  String formatCurrency(int amount) {
    return '৳$amount';
  }

  String formatDataUsage(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  Package? get activePackage {
    try {
      return packages.firstWhere((package) => package.isActive);
    } catch (e) {
      return null;
    }
  }
}
