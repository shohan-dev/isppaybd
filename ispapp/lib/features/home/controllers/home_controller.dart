import 'package:get/get.dart';
import 'package:ispapp/core/helpers/local_storage/storage_helper.dart';
import '../models/dashboard_model.dart';
import '../../auth/models/user_model.dart';
import '../../packages/models/package_model.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<UserPackageModel?> currentPackage = Rx<UserPackageModel?>(null);
  final Rx<DashboardStats?> dashboardStats = Rx<DashboardStats?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final userId = AppStorageHelper.get('user_id');

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;

    try {
      // Get current user from auth controller
      currentUser.value = authController.currentUser.value;

      if (currentUser.value != null) {
        // Load user package - dummy data
        final dummyPackage = PackageModel(
          id: 'pkg_1',
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
          id: 'up_1',
          userId: 'user_1',
          package: dummyPackage,
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 12, 31),
          uploadUsed: 0.7,
          downloadUsed: 16.7,
          status: 'Connected',
          totalUptime: 6.5,
        );

        // Generate dashboard stats
        dashboardStats.value = _generateDashboardStats();
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboardData() async {
    isRefreshing.value = true;

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    await loadDashboardData();

    isRefreshing.value = false;

    Get.snackbar(
      'Success',
      'Dashboard data refreshed',
      snackPosition: SnackPosition.BOTTOM,
    );
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
}
