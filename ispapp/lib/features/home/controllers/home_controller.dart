import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/helpers/local_storage/storage_helper.dart';
import 'package:ispapp/core/config/constants/api.dart';
import 'package:ispapp/core/services/api_service.dart';
import '../models/dashboard_model.dart';
import '../../auth/models/user_model.dart';
import '../../packages/models/package_model.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<UserPackageModel?> currentPackage = Rx<UserPackageModel?>(null);
  final Rx<DashboardStats?> dashboardStats = Rx<DashboardStats?>(null);
  final Rx<DashboardResponse?> dashboardData = Rx<DashboardResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final userId = AppStorageHelper.get('user_id');

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🚀 Loading dashboard data for user: ${userId}');

      if (userId == null) {
        errorMessage.value = 'User ID not found. Please login again.';
        Get.snackbar('Error', 'User ID not found. Please login again.');
        return;
      }

      // Fetch dashboard data from API
      final response = await ApiService.instance.get(
        '${AppApi.dashboard}/$userId',
      );

      print('📊 Dashboard API Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        // Parse dashboard response
        dashboardData.value = DashboardResponse.fromJson(response.data);

        // Update current user with API data
        final userDetails = dashboardData.value!.details;
        currentUser.value = UserModel(
          userId: userDetails.id,
          fullName: userDetails.name,
          email: userDetails.email,
          phone: userDetails.mobile,
          address: userDetails.address,
          userRole: userDetails.role,
          adminId: userDetails.adminId,
          clientCode: userDetails.code,
          status: userDetails.status,
          createdAt: _parseDate(userDetails.createdAt),
        );

        // Create package from user details
        final packageInfo = PackageModel(
          id: userDetails.packageId,
          name: _getPackageName(userDetails.packageId),
          speed: _getPackageSpeed(userDetails.packageId),
          price: 0.0, // Will be updated when package API is available
          duration: '30 Days',
          description: 'Internet package',
          isActive: userDetails.status == 'active',
          validUntil: _parseDate(userDetails.willExpire),
          packageType: 'Residential',
          features: ['High Speed Internet', '24/7 Support'],
          dataLimit: 1000.0,
          dataUnit: 'GB',
        );

        currentPackage.value = UserPackageModel(
          id: 'up_${userDetails.id}',
          userId: userDetails.id,
          package: packageInfo,
          startDate: _parseDate(userDetails.lastRenewed),
          endDate: _parseDate(userDetails.willExpire),
          uploadUsed: 0.7, // Will be updated when usage API is available
          downloadUsed: 16.7, // Will be updated when usage API is available
          status: _getConnectionStatus(
            userDetails.connStatus,
            userDetails.activity,
          ),
          totalUptime: 6.5, // Will be updated when uptime API is available
        );

        // Generate dashboard stats with real data
        dashboardStats.value = _generateDashboardStatsFromApi();

        print('✅ Dashboard data loaded successfully');
      } else {
        errorMessage.value = 'Failed to load dashboard data';
        Get.snackbar('Error', 'Failed to load dashboard data');
      }
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      errorMessage.value = 'Network error: $e';
      Get.snackbar('Error', 'Failed to load dashboard: $e');

      // Load fallback data
      _loadFallbackData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadFallbackData() {
    print('📋 Loading fallback dashboard data');

    // Load basic user data from auth controller
    currentUser.value = authController.currentUser.value;

    // Create fallback package data
    final fallbackPackage = PackageModel(
      id: 'fallback_pkg',
      name: '20MBPS',
      speed: '20 Mbps',
      price: 1500.0,
      duration: '30 Days',
      description: 'High-speed internet for home use',
      isActive: true,
      validUntil: DateTime(2099, 12, 31),
      packageType: 'Residential',
      features: ['Unlimited Data', '24/7 Support', 'Free Installation'],
      dataLimit: 1000.0,
      dataUnit: 'GB',
    );

    currentPackage.value = UserPackageModel(
      id: 'fallback_up',
      userId: userId?.toString() ?? 'unknown',
      package: fallbackPackage,
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      endDate: DateTime.now().add(const Duration(days: 10)),
      uploadUsed: 0.7,
      downloadUsed: 16.7,
      status: 'Connected (Offline Mode)',
      totalUptime: 6.5,
    );

    // Generate fallback dashboard stats
    dashboardStats.value = _generateDashboardStats();
  }

  Future<void> refreshDashboardData() async {
    isRefreshing.value = true;
    errorMessage.value = ''; // Clear any previous errors

    try {
      await loadDashboardData();

      if (errorMessage.value.isEmpty) {
        Get.snackbar(
          'Success',
          'Dashboard data refreshed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh dashboard data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  DashboardStats _generateDashboardStats() {
    // Generate sample chart data for the last 24 hours
    List<ChartData> chartData = [];
    DateTime now = DateTime.now();

    // Generate realistic data pattern similar to the screenshot
    List<double> downloadPattern = [
      5,
      8,
      12,
      15,
      18,
      25,
      30,
      40,
      50,
      65,
      75,
      85,
      92,
      88,
      78,
      70,
      65,
      60,
      55,
      50,
      45,
      40,
      35,
      30,
    ];
    List<double> uploadPattern = [
      1,
      1,
      2,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      12,
      11,
      10,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
      2,
    ];

    for (int i = 0; i < 24; i++) {
      DateTime date = now.subtract(Duration(hours: 23 - i));
      double download = downloadPattern[i];
      double upload = uploadPattern[i];

      chartData.add(
        ChartData(date: date, upload: upload, download: download, hour: i),
      );
    }

    // Generate sample news
    List<NewsItem> sampleNews = [
      NewsItem(
        id: 'news_1',
        title: 'damaka',
        description: 'coming.....soon',
        publishedAt: DateTime.parse('2025-09-24T14:37:46.527'),
      ),
      NewsItem(
        id: 'news_2',
        title: 'Network Upgrade',
        description: 'Speed improvements coming soon',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return DashboardStats(
      uploadSpeed: 0.0, // Current upload speed
      downloadSpeed: 76.0, // Current download speed in Mb/s
      uptime: 6.48, // Uptime in hours (6h 29m 15s)
      uploadUsage: 0.7, // Upload usage in GB
      downloadUsage: 16.7, // Download usage in GB
      usageChart: chartData,
      recentNews: sampleNews,
    );
  }

  String getFormattedUptime() {
    if (dashboardStats.value != null) {
      double hours = dashboardStats.value!.uptime;
      int wholeHours = hours.floor();
      int minutes = ((hours - wholeHours) * 60).round();
      return 'Up Time (${wholeHours}h ${minutes}m 15s)';
    }
    return 'Up Time (0h 0m 0s)';
  }

  String getUptimeValue() {
    if (dashboardStats.value != null) {
      double hours = dashboardStats.value!.uptime;
      int wholeHours = hours.floor();
      int minutes = ((hours - wholeHours) * 60).round();
      return '${wholeHours}h ${minutes}m 15s';
    }
    return '0h 0m 0s';
  }

  String getPackageExpireDate() {
    if (currentPackage.value != null) {
      DateTime expireDate = currentPackage.value!.endDate;
      return '${expireDate.day.toString().padLeft(2, '0')}-${expireDate.month.toString().padLeft(2, '0')}-${expireDate.year}';
    }
    return '31-Dec-9999';
  }

  double getUploadPercentage() {
    if (currentPackage.value != null) {
      return (currentPackage.value!.uploadUsed / 10.0) *
          100; // Assuming 10GB limit for display
    }
    return 0.0;
  }

  double getDownloadPercentage() {
    if (currentPackage.value != null) {
      return (currentPackage.value!.downloadUsed / 100.0) *
          100; // Assuming 100GB limit for display
    }
    return 0.0;
  }

  // Helper methods for API data parsing
  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
      return DateTime.now();
    }
  }

  String _getPackageName(String packageId) {
    // Map package IDs to names - this should be updated based on your package data
    const packageMap = {
      '39': '20MBPS',
      '42': '50MBPS',
      '1': '10MBPS',
      '2': '25MBPS',
      '3': '100MBPS',
    };
    return packageMap[packageId] ?? '${packageId}MBPS';
  }

  String _getPackageSpeed(String packageId) {
    // Map package IDs to speeds - this should be updated based on your package data
    const speedMap = {
      '39': '20 Mbps',
      '42': '50 Mbps',
      '1': '10 Mbps',
      '2': '25 Mbps',
      '3': '100 Mbps',
    };
    return speedMap[packageId] ?? '${packageId} Mbps';
  }

  String _getConnectionStatus(String connStatus, String activity) {
    if (connStatus == 'conn' && activity == 'active') {
      return 'Connected';
    } else if (connStatus == 'conn' && activity == 'inactive') {
      return 'Connected (Inactive)';
    } else if (connStatus == 'disc') {
      return 'Disconnected';
    } else {
      return 'Unknown';
    }
  }

  DashboardStats _generateDashboardStatsFromApi() {
    if (dashboardData.value == null) {
      return _generateDashboardStats(); // Fallback to dummy data
    }

    // Generate chart data for the last 24 hours with some sample data
    List<ChartData> chartData = [];
    DateTime now = DateTime.now();

    // Generate usage patterns for the last 24 hours
    for (int i = 0; i < 24; i++) {
      DateTime date = now.subtract(Duration(hours: 23 - i));

      // Generate realistic usage patterns based on time of day
      double download = _generateUsageForHour(i);
      double upload = download * 0.1; // Upload is typically 10% of download

      chartData.add(
        ChartData(date: date, upload: upload, download: download, hour: i),
      );
    }

    // Create news items from dashboard data
    List<NewsItem> newsItems = [
      NewsItem(
        id: 'news_1',
        title: 'Account Status',
        description: 'Your account is ${dashboardData.value!.details.status}',
        publishedAt: DateTime.now(),
      ),
      NewsItem(
        id: 'news_2',
        title: 'Connection Status',
        description:
            'Status: ${_getConnectionStatus(dashboardData.value!.details.connStatus, dashboardData.value!.details.activity)}',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    // Calculate uptime based on connection status
    double uptime =
        dashboardData.value!.details.connStatus == 'conn' ? 23.5 : 0.0;

    return DashboardStats(
      uploadSpeed: 0.5, // Mock upload speed
      downloadSpeed: 45.0, // Mock download speed
      uptime: uptime,
      uploadUsage: 1.2, // Mock upload usage
      downloadUsage: 25.8, // Mock download usage
      usageChart: chartData,
      recentNews: newsItems,
    );
  }

  double _generateUsageForHour(int hour) {
    // Generate realistic usage patterns based on time of day
    if (hour >= 0 && hour < 6) {
      return 5 + (hour * 2); // Low usage during night
    } else if (hour >= 6 && hour < 9) {
      return 15 + (hour * 3); // Morning usage increase
    } else if (hour >= 9 && hour < 17) {
      return 30 + (hour * 2); // Daytime moderate usage
    } else if (hour >= 17 && hour < 22) {
      return 50 + ((hour - 17) * 8); // Peak evening hours
    } else {
      return 60 - ((hour - 22) * 10); // Decline after 10 PM
    }
  }

  // Getters for dashboard data
  String get userName =>
      dashboardData.value?.details.name ??
      currentUser.value?.fullName ??
      'Unknown User';
  String get userEmail =>
      dashboardData.value?.details.email ?? currentUser.value?.email ?? '';
  String get userPhone =>
      dashboardData.value?.details.mobile ?? currentUser.value?.phone ?? '';
  String get userAddress =>
      dashboardData.value?.details.address ?? currentUser.value?.address ?? '';
  String get packageExpiry => dashboardData.value?.details.willExpire ?? 'N/A';
  String get lastRenewal => dashboardData.value?.details.lastRenewed ?? 'N/A';
  int get paymentReceived => dashboardData.value?.paymentReceived ?? 0;
  int get paymentPending => dashboardData.value?.paymentPending ?? 0;
  int get supportTickets => dashboardData.value?.totalSupportTicket ?? 0;
  String get accountBalance => dashboardData.value?.details.fund ?? '0.00';
}
