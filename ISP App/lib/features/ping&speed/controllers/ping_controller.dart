import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/constants/api.dart';
import '../../../core/helpers/local_storage/storage_helper.dart';
import '../../../core/helpers/network_helper.dart';
import '../models/ping_model.dart';

class PingController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final isPinging = false.obs;
  final pingResponse = Rxn<PingResponse>();
  final errorMessage = ''.obs;

  // User info
  String? routerId;
  String? userName;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  /// Load user info from storage and fetch dashboard data
  Future<void> _loadUserInfo() async {
    try {
      isLoading.value = true;

      // Get user_id from storage
      userId = AppStorageHelper.get<String>('user_id');

      if (userId == null) {
        print('Error: User ID not found in storage');
        return;
      }

      // Fetch dashboard data to get router_id and name
      final response = await ApiService.instance.get<Map<String, dynamic>>(
        '${AppApi.dashboard}/$userId',
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final details = data['details'] as Map<String, dynamic>?;

        if (details != null) {
          routerId = details['router_id']?.toString();
          userName = data["pppoe"]?.toString();
          print('✅ Loaded user info - Router ID: $routerId, Name: $userName');
        }
      } else {
        print('❌ Failed to load dashboard data');
      }
    } catch (e) {
      print('❌ Error loading user info: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Run ping test
  Future<void> runPingTest() async {
    if (isPinging.value) {
      Get.snackbar(
        'Please Wait',
        'Ping test is already running...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Validate user info
    if (routerId == null || userName == null) {
      Get.snackbar(
        'Error',
        'User information not found. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isPinging.value = true;
      errorMessage.value = '';
      pingResponse.value = null;

      Get.snackbar(
        'Running Ping Test',
        'This may take up to 1 minute...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        showProgressIndicator: true,
      );

      // Make API call with extended timeout (90 seconds)
      // Using a custom implementation to handle long-running ping requests
      final response = await _makePingRequest(routerId!, userName!);

      if (response.success && response.data != null) {
        pingResponse.value = response.data;

        Get.snackbar(
          'Success',
          'Ping test completed successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          errorMessage.value.isEmpty
              ? 'Failed to run ping test'
              : errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to run ping test: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isPinging.value = false;
    }
  }

  /// Get ping status color based on packet loss
  String getPingStatus() {
    if (pingResponse.value == null) return 'Not tested';

    final lossPercentage = pingResponse.value!.packets.lossPercentage;

    if (lossPercentage == 0) return 'Excellent';
    if (lossPercentage < 10) return 'Good';
    if (lossPercentage < 30) return 'Fair';
    if (lossPercentage < 100) return 'Poor';
    return 'No Connection';
  }

  /// Get status color
  int getStatusColor() {
    if (pingResponse.value == null) return 0xFF9E9E9E;

    final lossPercentage = pingResponse.value!.packets.lossPercentage;

    if (lossPercentage == 0) return 0xFF4CAF50; // Green
    if (lossPercentage < 10) return 0xFF8BC34A; // Light Green
    if (lossPercentage < 30) return 0xFFFFC107; // Amber
    if (lossPercentage < 100) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  /// Make ping request with custom timeout
  Future<ApiResponse<PingResponse>> _makePingRequest(
    String routerId,
    String userName,
  ) async {
    try {
      // Import Dio for custom timeout
      final dio = Dio(
        BaseOptions(
          baseUrl: AppApi.baseUrl,
          connectTimeout: const Duration(seconds: 90), // Extended timeout
          receiveTimeout: const Duration(seconds: 90), // Extended timeout
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      print('🌐 Making ping request to: ${AppApi.pingUser}');
      print('📍 Parameters: router_id=$routerId, name=$userName');

      final response = await dio.get(
        AppApi.pingUser,
        queryParameters: {'router_id': routerId, 'name': userName},
        // queryParameters: {'router_id': "49", 'name': "trust20"},
      );

      print('✅ Ping response received: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      // Parse response
      if (response.statusCode == 200 && response.data != null) {
        final pingData = PingResponse.fromJson(response.data);
        print('✅ Ping data parsed successfully');
        print(
          '📊 Packets sent: ${pingData.packets.sent}, received: ${pingData.packets.received}',
        );
        print('📊 Data items: ${pingData.data.length}');

        return ApiResponse(
          status: 200,
          success: true,
          message: 'Ping test completed successfully',
          data: pingData,
        );
      } else {
        print('❌ Invalid response status: ${response.statusCode}');
        return ApiResponse(
          status: response.statusCode ?? 500,
          success: false,
          message: 'Failed to get ping response',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse(
          status: 408,
          success: false,
          message: 'Request timeout. Please try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return ApiResponse(
          status: 0,
          success: false,
          message: 'No internet connection',
        );
      } else {
        return ApiResponse(
          status: e.response?.statusCode ?? 500,
          success: false,
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 500,
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }
}
