import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  // Services
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService.instance;

  // Text editing controllers
  final emailController = TextEditingController();
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
    _loadSavedCredentials();
    checkLoginStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _loadSavedCredentials() {
    final savedEmail = _storageService.getLastLoginEmail();
    final rememberMeValue = _storageService.getRememberMe();

    if (savedEmail != null && rememberMeValue) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both email and password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (result['success'] == true) {
        final responseData = result['data'] as Map<String, dynamic>;

        print('=== LOGIN SUCCESS DEBUG ===');
        print('Login response data: $responseData');

        // Create user model from response
        final user = _authService.parseUserFromResponse(responseData);
        currentUser.value = user;
        isLoggedIn.value = true;

        print('User created: ${user.toJson()}');

        // Save all login data
        await _storageService.setLoginStatus(true);
        await _storageService.saveUserData(user.toJson());

        // Save credentials if remember me is checked
        if (rememberMe.value) {
          await _storageService.setRememberMe(true);
          await _storageService.saveLastLoginEmail(emailController.text.trim());
        } else {
          await _storageService.setRememberMe(false);
        }

        // Save token if available
        if (responseData['token'] != null) {
          await _storageService.saveUserToken(responseData['token']);
          print('Token saved: ${responseData['token']}');
        }

        // Verify data was saved
        final savedLoginStatus = _storageService.isLoggedIn();
        final savedUserData = _storageService.getUserData();
        print('Verification - Login status saved: $savedLoginStatus');
        print('Verification - User data saved: ${savedUserData != null}');
        print('=========================');

        Get.snackbar(
          'Success',
          'Login successful! Welcome ${user.fullName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to home
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Login failed',
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
      currentUser.value = null;
      isLoggedIn.value = false;

      // Clear auth data from storage
      await _storageService.clearAuthData();

      // Clear form only if remember me is disabled
      if (!_storageService.getRememberMe()) {
        emailController.clear();
      }
      passwordController.clear();

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.login);
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

  Future<void> checkLoginStatus() async {
    try {
      print('=== CHECK LOGIN STATUS ===');
      final isLoggedInStored = _storageService.isLoggedIn();
      print('Stored login status: $isLoggedInStored');

      if (isLoggedInStored) {
        final userData = _storageService.getUserData();
        final token = await _storageService.getUserToken();

        print('User data exists: ${userData != null}');
        print('Token exists: ${token != null}');

        if (userData != null && token != null) {
          currentUser.value = UserModel.fromJson(userData);
          isLoggedIn.value = true;
          print('User restored: ${currentUser.value?.fullName}');

          // Automatically navigate to home if already logged in
          if (Get.currentRoute == AppRoutes.login ||
              Get.currentRoute == AppRoutes.splash) {
            print('Auto-navigating to home');
            Get.offAllNamed(AppRoutes.home);
          }
        } else {
          // Clear invalid login state
          print('Clearing invalid login data');
          await _storageService.clearAuthData();
          isLoggedIn.value = false;
        }
      } else {
        print('No login status stored');
        isLoggedIn.value = false;
      }
      print('Final login status: ${isLoggedIn.value}');
      print('========================');
    } catch (e) {
      print('Error checking login status: $e');
      isLoggedIn.value = false;
      await _storageService.clearAuthData();
    }
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
