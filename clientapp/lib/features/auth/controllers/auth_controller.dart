import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:clientapp/core/services/data_service.dart';
import 'package:clientapp/core/routes/app_routes.dart';
import 'package:clientapp/shared/models/user_model.dart';

class AuthController extends GetxController {
  final DataService _dataService = Get.find<DataService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Don't call checkAuthStatus here to avoid setState during build
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    // if (!_validateInputs()) return;

    isLoading.value = true;

    try {
      final success = await _dataService.login(
        // emailController.text.trim(),
        // passwordController.text.trim(),
        "34003395@gmail.com",
        "123456",
      );

      if (success) {
        // Load user data
        final userData = _dataService.user;
        currentUser.value = User.fromJson(userData);

        // Navigate to dashboard
        Get.offAllNamed(AppRoutes.dashboard);

        // Show success message
        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    currentUser.value = null;
    emailController.clear();
    passwordController.clear();
    Get.offAllNamed(AppRoutes.login);

    Get.snackbar(
      'Logged Out',
      'You have been logged out successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> checkAuthStatus() async {
    // In a real app, you would check for stored auth tokens here
    // For now, we'll just assume user is not logged in and navigate to login

    // Add a small delay to ensure the widget tree is built
    await Future.delayed(const Duration(milliseconds: 100));

    // For demo purposes, let's check if we have user data
    try {
      final userData = _dataService.user;
      if (userData.isNotEmpty) {
        currentUser.value = User.fromJson(userData);
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      // If there's any error, go to login
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // Helper method to fill demo credentials
  void fillDemoCredentials() {
    emailController.text = '34003395@gmail.com';
    passwordController.text = '123456';
  }
}
