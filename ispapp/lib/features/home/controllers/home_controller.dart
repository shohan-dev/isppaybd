import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/helpers/local_storage/storage_helper.dart';
import 'package:ispapp/core/config/constants/api.dart';
import 'package:ispapp/core/services/api_service.dart';
import 'package:ispapp/features/packages/controllers/packages_controller.dart';
import '../models/dashboard_model.dart';
import '../../auth/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  // Track last successful real-time fetch
  DateTime? _lastTrafficSuccess;
  final AuthController authController = Get.find<AuthController>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<DashboardStats?> dashboardStats = Rx<DashboardStats?>(null);
  final Rx<DashboardResponse?> dashboardData = Rx<DashboardResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final userId = AppStorageHelper.get('user_id');

  // Real-time traffic data
  final Rx<RealTimeTrafficData?> currentTrafficData = Rx<RealTimeTrafficData?>(
    null,
  );
  final RxList<RealTimeChartData> realTimeChartData = <RealTimeChartData>[].obs;
  final RxBool isRealTimeActive = false.obs;
  final RxBool isTrafficLoading = false.obs;
  final RxInt trafficErrorCount = 0.obs;
  Timer? _trafficTimer;

  // Production settings
  static const int maxErrorCount = 3;
  static const int maxDataPoints =
      120; // 2 minutes of data at 1-second intervals
  static const Duration fetchInterval = Duration(seconds: 1);

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
      final response = await ApiService.instance.get<DashboardResponse>(
        '${AppApi.dashboard}/$userId',
        // '${AppApi.dashboard}/10854',
        mapper: (data) => DashboardResponse.fromJson(data),
      );

      print('📊 Dashboard API Response: ${response.data}');

      if (response.success && response.data != null) {
        // Parse dashboard response
        dashboardData.value = response.data;

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

        // Generate dashboard stats with real data
        dashboardStats.value = _generateDashboardStatsFromApi();

        // Start real-time traffic monitoring
        _startRealTimeTrafficMonitoring();

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

    // Show error message - data should come from API
    errorMessage.value = 'Unable to load dashboard data. Please try again.';
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
    // Get from dashboard API data
    return dashboardData.value?.details.willExpire ?? 'N/A';
  }

  double getUploadPercentage() {
    // Will be calculated from real-time usage data when available
    return 0.0;
  }

  double getDownloadPercentage() {
    // Will be calculated from real-time usage data when available
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
      // Return empty stats if no data
      return DashboardStats(
        uploadSpeed: 0.0,
        downloadSpeed: 0.0,
        uptime: 0.0,
        uploadUsage: 0.0,
        downloadUsage: 0.0,
        usageChart: [],
        recentNews: [],
      );
    }

    // Initialize with empty chart data - will be populated by real-time traffic
    List<ChartData> chartData = _generateEmptyChartData();

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
      uploadSpeed: 0.0, // Will be updated by real-time data
      downloadSpeed: 0.0, // Will be updated by real-time data
      uptime: uptime,
      uploadUsage: 0.0, // Will be updated when usage API is available
      downloadUsage: 0.0, // Will be updated when usage API is available
      usageChart: chartData,
      recentNews: newsItems,
    );
  }

  List<ChartData> _generateEmptyChartData() {
    List<ChartData> chartData = [];
    DateTime now = DateTime.now();

    // Generate 24 hours of empty data points
    for (int i = 0; i < 24; i++) {
      DateTime date = now.subtract(Duration(hours: 23 - i));
      chartData.add(ChartData(date: date, upload: 0.0, download: 0.0, hour: i));
    }

    return chartData;
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

  // New getters for home_view to replace currentPackage
  String get connectionStatus {
    if (dashboardData.value?.details != null) {
      return _getConnectionStatus(
        dashboardData.value!.details.connStatus,
        dashboardData.value!.details.activity,
      );
    }
    return 'Unknown';
  }

  String get packageName {
    // Return package name
    final packageName =
        Get.find<PackagesController>().currentUserPackage.value?.packageName;

    return packageName ?? 'N/A';
  }

  double get uploadUsed {
    // Usage data not yet available from API
    return 0.0;
  }

  double get downloadUsed {
    // Usage data not yet available from API
    return 0.0;
  }

  int get paymentPending => dashboardData.value?.paymentPending ?? 0;
  int get supportTickets => dashboardData.value?.totalSupportTicket ?? 0;
  String get accountBalance => dashboardData.value?.details.fund ?? '0.00';

  // Real-time traffic monitoring methods
  void _startRealTimeTrafficMonitoring() {
    if (dashboardData.value?.details.routerId == null ||
        dashboardData.value?.pppoe == null) {
      print('❌ Cannot start real-time monitoring: Missing router ID or PPPoE');
      return;
    }

    print('🚀 Starting real-time traffic monitoring');
    isRealTimeActive.value = true;
    trafficErrorCount.value = 0;

    // Initialize last success time to now (give 10 seconds grace period)
    _lastTrafficSuccess = DateTime.now();

    // Initialize chart data with empty values
    realTimeChartData.clear();

    // Start fetching data with production-ready timer
    _trafficTimer = Timer.periodic(fetchInterval, (timer) async {
      if (!isRealTimeActive.value) {
        timer.cancel();
        return;
      }

      // Stop monitoring if too many errors
      if (trafficErrorCount.value >= maxErrorCount) {
        print('⚠️ Stopping real-time monitoring due to excessive errors');
        _stopRealTimeTrafficMonitoring();
        return;
      }

      await _fetchRealTimeTrafficData();
    });
  }

  void _stopRealTimeTrafficMonitoring() {
    print('⏹️ Stopping real-time traffic monitoring');
    _trafficTimer?.cancel();
    _trafficTimer = null;
    isRealTimeActive.value = false;
    isTrafficLoading.value = false;
    trafficErrorCount.value = 0;
    _lastTrafficSuccess = null; // Reset on stop
  }

  Future<void> _fetchRealTimeTrafficData() async {
    // Prevent multiple simultaneous calls
    if (isTrafficLoading.value) return;

    // Auto-offline: Check if more than 10 seconds since last success
    if (_lastTrafficSuccess != null) {
      final secondsSinceLastSuccess =
          DateTime.now().difference(_lastTrafficSuccess!).inSeconds;

      print("⏱️ Seconds since last success: ${secondsSinceLastSuccess}s");

      if (secondsSinceLastSuccess > 10) {
        print(
          '⚠️ No successful traffic fetch in ${secondsSinceLastSuccess}s, going offline',
        );
        _stopRealTimeTrafficMonitoring();
        return;
      }
    }

    isTrafficLoading.value = true;

    try {
      // Validate required data
      if (dashboardData.value?.details.routerId == null ||
          dashboardData.value?.pppoe == null) {
        trafficErrorCount.value++;
        return;
      }

      final routerId = dashboardData.value!.details.routerId;
      final pppoeId = dashboardData.value!.pppoe;

      // Skip if PPPoE is empty (common case)
      if (pppoeId.isEmpty) {
        // Don't increment error count for empty PPPoE, just skip silently
        return;
      }

      // Construct the API URL
      final trafficUrl = '${AppApi.rx_tx_data}/$routerId?pppoe_name=$pppoeId';

      // Make API call with timeout
      final response = await ApiService.instance
          .get<RealTimeTrafficData>(
            trafficUrl,
            mapper: (data) => RealTimeTrafficData.fromJson(data),
          )
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              throw TimeoutException(
                'Traffic API request timed out',
                const Duration(seconds: 3),
              );
            },
          );

      if (response.success && response.data != null) {
        // Reset error count on successful response
        trafficErrorCount.value = 0;
        // Update last success time on EVERY successful fetch
        _lastTrafficSuccess = DateTime.now();

        // Parse traffic data
        final trafficData = response.data!;

        // Validate data sanity
        if (trafficData.uploadSpeed >= 0 && trafficData.downloadSpeed >= 0) {
          currentTrafficData.value = trafficData;

          // Add to chart data with efficient list management
          realTimeChartData.add(
            RealTimeChartData(
              time: trafficData.timestamp,
              upload: trafficData.uploadSpeed,
              download: trafficData.downloadSpeed,
            ),
          );

          // Maintain optimal data size for performance
          if (realTimeChartData.length > maxDataPoints) {
            realTimeChartData.removeRange(
              0,
              realTimeChartData.length - maxDataPoints,
            );
          }

          // Update dashboard stats efficiently (avoid unnecessary rebuilds)
          _updateDashboardStatsWithRealTimeData();

          print(
            '📈 Traffic: ↑${trafficData.uploadSpeed.toStringAsFixed(2)} ↓${trafficData.downloadSpeed.toStringAsFixed(2)} Mbps',
          );
        }
      } else {
        // API failed - DON'T update last success time
        trafficErrorCount.value++;
        if (trafficErrorCount.value <= 2) {
          // Only log first few errors to avoid spam
          print(
            '⚠️ Traffic API error: ${response.status} - ${response.message}',
          );
        }
      }
    } catch (e) {
      // API failed - DON'T update last success time
      trafficErrorCount.value++;
      if (trafficErrorCount.value <= 2) {
        // Only log first few errors
        print('⚠️ Traffic fetch error: ${e.toString().substring(0, 50)}...');
      }
    } finally {
      isTrafficLoading.value = false;
    }
  }

  void _updateDashboardStatsWithRealTimeData() {
    if (dashboardStats.value != null && currentTrafficData.value != null) {
      // Only update if we have meaningful data change (avoid excessive rebuilds)
      final currentStats = dashboardStats.value!;
      final realTimeData = currentTrafficData.value!;

      // Check if speeds actually changed significantly (0.1 Mbps threshold)
      final speedChanged =
          (currentStats.uploadSpeed - realTimeData.uploadSpeed).abs() > 0.1 ||
          (currentStats.downloadSpeed - realTimeData.downloadSpeed).abs() > 0.1;

      if (speedChanged || realTimeChartData.length <= 1) {
        dashboardStats.value = DashboardStats(
          uploadSpeed: realTimeData.uploadSpeed,
          downloadSpeed: realTimeData.downloadSpeed,
          uptime: currentStats.uptime,
          uploadUsage: currentStats.uploadUsage,
          downloadUsage: currentStats.downloadUsage,
          usageChart: _generateRealTimeChartData(),
          recentNews: currentStats.recentNews,
        );
      }
    }
  }

  List<ChartData> _generateRealTimeChartData() {
    if (realTimeChartData.isEmpty) {
      return _generateEmptyChartData();
    }

    // Use the most recent 60 data points for optimal chart performance
    final dataToShow =
        realTimeChartData.length > 60
            ? realTimeChartData.sublist(realTimeChartData.length - 60)
            : realTimeChartData;

    return dataToShow
        .map(
          (data) => ChartData(
            date: data.time,
            upload: data.upload,
            download: data.download,
            hour: data.time.hour,
          ),
        )
        .toList();
  }

  // Getters for real-time data display
  String get currentUploadSpeed =>
      currentTrafficData.value?.uploadSpeed.toStringAsFixed(2) ?? '0.00';

  String get currentDownloadSpeed =>
      currentTrafficData.value?.downloadSpeed.toStringAsFixed(2) ?? '0.00';

  String get trafficUnit => currentTrafficData.value?.unit ?? 'Mbps';

  // Production-ready status indicators
  bool get hasTrafficData => realTimeChartData.isNotEmpty;
  bool get isTrafficHealthy => trafficErrorCount.value < maxErrorCount;
  String get trafficStatusText {
    if (!isRealTimeActive.value) return 'Offline';
    if (!isTrafficHealthy) return 'Connection Issues';
    if (!hasTrafficData) return 'Initializing...';
    return 'Live';
  }

  Color get trafficStatusColor {
    if (!isRealTimeActive.value) return Colors.grey;
    if (!isTrafficHealthy) return Colors.red;
    if (!hasTrafficData) return Colors.blue;
    return Colors.green;
  }

  // Override onClose to cleanup timer
  @override
  void onClose() {
    print('🧹 HomeController closing, cleaning up real-time monitoring');
    _stopRealTimeTrafficMonitoring();
    super.onClose();
  }

  // Lifecycle methods for proper cleanup
  void pauseRealTimeMonitoring() {
    if (_trafficTimer != null && _trafficTimer!.isActive) {
      print('⏸️ Pausing real-time monitoring');
      _trafficTimer?.cancel();
    }
  }

  void resumeRealTimeMonitoring() {
    if (isRealTimeActive.value &&
        (_trafficTimer == null || !_trafficTimer!.isActive)) {
      print('▶️ Resuming real-time monitoring');
      _startRealTimeTrafficMonitoring();
    }
  }

  // Method to manually toggle real-time monitoring
  void toggleRealTimeMonitoring() {
    if (isRealTimeActive.value) {
      _stopRealTimeTrafficMonitoring();
      Get.snackbar(
        'Info',
        'Real-time monitoring stopped',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      if (dashboardData.value?.details.routerId != null) {
        _startRealTimeTrafficMonitoring();
        Get.snackbar(
          'Info',
          'Real-time monitoring started',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Unable to start monitoring: Router information not available',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Payment statistics methods
  List<PaymentChartData> getPaymentChartData() {
    if (dashboardData.value?.statistics == null) {
      return _getDefaultPaymentChartData();
    }

    final stats = dashboardData.value!.statistics;
    List<PaymentChartData> chartData = [];

    for (int i = 0; i < stats.months.length; i++) {
      chartData.add(
        PaymentChartData(
          month: stats.months[i],
          monthIndex: i,
          successful: stats.successful[i].toDouble(),
          pending: stats.pending[i].toDouble(),
          failed: stats.failed[i].toDouble(),
        ),
      );
    }

    return chartData;
  }

  List<PaymentChartData> _getDefaultPaymentChartData() {
    // Return empty list if no data available
    return [];
  }

  // Get payment summary text
  String getPaymentSummary() {
    final data = getPaymentChartData();
    final totalSuccessful = data.fold(
      0.0,
      (sum, item) => sum + item.successful,
    );
    final totalPending = data.fold(0.0, (sum, item) => sum + item.pending);
    final totalFailed = data.fold(0.0, (sum, item) => sum + item.failed);

    return 'Total: ${totalSuccessful.toInt()} successful, ${totalPending.toInt()} pending, ${totalFailed.toInt()} failed';
  }

  // Dynamic getters that update with real API data
  String get dynamicPaymentReceived =>
      dashboardData.value?.paymentReceived.toString() ?? '0';
  String get dynamicPaymentPending =>
      dashboardData.value?.paymentPending.toString() ?? '0';
  String get dynamicSupportTickets =>
      dashboardData.value?.totalSupportTicket.toString() ?? '0';
}
