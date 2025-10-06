import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  // Text editing controllers
  final clientCodeController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    clientCodeController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> login() async {
    if (clientCodeController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both client code and password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Simple dummy authentication
      if (clientCodeController.text.trim() == 'shohan' &&
          passwordController.text.trim() == 'password') {
        final user = UserModel(
          id: 'user_1',
          clientCode: 'P0002',
          userName: 'shohan',
          fullName: 'Shohan Ahmed',
          email: 'shohan@broadband.com',
          phone: '+8801712345678',
          address: 'Dhaka, Bangladesh',
          status: 'Connected',
          profileImage: '',
          createdAt: DateTime(2024, 1, 15),
          lastLogin: DateTime.now(),
        );

        currentUser.value = user;
        isLoggedIn.value = true;

        // Save login status if remember me is checked
        if (rememberMe.value) {
          // Here you would typically save to secure storage
          // For now, we'll just keep it in memory
        }

        Get.snackbar(
          'Success',
          'Login successful! Welcome ${user.fullName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to home
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Error',
          'Invalid client code or password',
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

  Future<void> logout() async {
    isLoading.value = true;

    try {
      // Simulate logout process
      await Future.delayed(const Duration(seconds: 1));

      currentUser.value = null;
      isLoggedIn.value = false;

      // Clear form
      clientCodeController.clear();
      passwordController.clear();
      rememberMe.value = false;

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error during logout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void checkLoginStatus() {
    // Check if user is already logged in
    // For demo purposes, we'll assume not logged in initially
    isLoggedIn.value = false;
  }

  void forgotPassword() {
    Get.snackbar(
      'Info',
      'Password reset functionality will be available soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void register() {
    Get.snackbar(
      'Info',
      'Registration functionality will be available soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
