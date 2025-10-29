import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/config/constants/api.dart';
import '../../../core/services/api_service.dart';
import '../../../core/helpers/toast_helper.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/models/dashboard_model.dart';
import '../model/profile_model.dart';

class ProfileController extends GetxController {
  final HomeController _homeController = Get.find<HomeController>();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable states
  final isLoading = false.obs;
  final isEditMode = false.obs;

  // User data
  Rx<UserDetails?> userDetails = Rx<UserDetails?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    super.onClose();
  }

  /// Load user data from HomeController
  void loadUserData() {
    final user = _homeController.dashboardData.value?.details;
    if (user != null) {
      userDetails.value = user;
      nameController.text = user.name;
      emailController.text = user.email;
      mobileController.text = user.mobile;
      addressController.text = user.address;
    }
  }

  /// Toggle edit mode
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) {
      // Reset to original data if canceling edit
      loadUserData();
    }
  }

  /// Validate and update profile
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Get user ID from home controller
    final userId = userDetails.value?.id;
    if (userId == null || userId.isEmpty) {
      AppToastHelper.showToast(
        message: 'User ID not found',
        title: 'Error',
        type: ToastType.error,
      );
      return;
    }

    isLoading.value = true;

    try {
      final request = ProfileUpdateRequest(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        address: addressController.text.trim(),
      );

      // Build the URL with query parameters
      final url =
          '${AppApi.baseUrl}profile_update?${request.toQueryString(userId)}';

      print('🚀 Updating profile: $url');

      final response = await ApiService.instance.post<ProfileUpdateResponse>(
        url,
        mapper: (data) => ProfileUpdateResponse.fromJson(data),
      );

      print('📊 Profile Update Response: ${response.data}');

      if (response.success) {
        AppToastHelper.showToast(
          message: response.message,
          title: 'Success',
          type: ToastType.success,
        );

        // Refresh dashboard data to get updated user info
        await _homeController.loadDashboardData();

        // Reload user data from home controller
        loadUserData();

        // Exit edit mode
        isEditMode.value = false;
      } else {
        AppToastHelper.showToast(
          message: response.message,
          title: 'Error',
          type: ToastType.error,
        );
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      AppToastHelper.showToast(
        message: 'Error updating profile: ${e.toString()}',
        title: 'Error',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    try {
      await _homeController.loadDashboardData();
      loadUserData();
      AppToastHelper.showToast(
        message: 'Profile data refreshed',
        title: 'Success',
        type: ToastType.success,
      );
    } catch (e) {
      AppToastHelper.showToast(
        message: 'Failed to refresh data',
        title: 'Error',
        type: ToastType.error,
      );
    }
  }

  /// Get formatted subscription status
  String getSubscriptionStatus() {
    final status = userDetails.value?.subscriptionStatus;
    if (status == null || status.isEmpty) return 'Unknown';

    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  /// Get status color
  Color getStatusColor() {
    final status = userDetails.value?.subscriptionStatus.toLowerCase();
    switch (status) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Validate mobile
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    final mobileRegex = RegExp(r'^01[3-9]\d{8}$');
    if (!mobileRegex.hasMatch(value)) {
      return 'Enter a valid Bangladesh mobile number';
    }
    return null;
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  /// Validate address
  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Address must be at least 10 characters';
    }
    return null;
  }
}
