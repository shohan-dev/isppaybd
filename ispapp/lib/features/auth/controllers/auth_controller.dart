import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/helpers/local_storage/storage_helper.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  // Services
  final AuthService _authService = AuthService();

  // Storage keys - simplified to only store user_id
  static const String _keyUserId = 'user_id';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastLoginEmail = 'last_login_email';

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
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Ensure storage is initialized before any operations
      await AppStorageHelper.init();
      _loadSavedCredentials();
      checkLoginStatus();
    } catch (e) {
      print('❌ Auth initialization failed: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _loadSavedCredentials() {
    final savedEmail = AppStorageHelper.get<String>(_keyLastLoginEmail);
    final rememberMeValue =
        AppStorageHelper.get<bool>(_keyRememberMe, defaultValue: false) ??
        false;

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

        // Extract user_id from the API response
        final responseObj = responseData['response'] as Map<String, dynamic>;
        final userId = responseObj['user_id']?.toString() ?? '';
        final userRole = responseObj['user_role']?.toString() ?? 'user';
        final adminId = responseObj['admin_id']?.toString() ?? '';
        final sessionkey = responseObj['file_name']?.toString() ?? '';

        print('Extracted user_id: $userId');
        print('Extracted user_role: $userRole');
        print('Extracted admin_id: $adminId');

        // Ensure storage is ready before saving critical data
        print('🔧 Ensuring storage is ready...');
        await AppStorageHelper.init();

        // Save only the user_id (this indicates user is logged in)
        print('💾 Saving user_id: $userId');
        AppStorageHelper.put(_keyUserId, userId);
        AppStorageHelper.put("token", sessionkey);

        // Update controller state
        isLoggedIn.value = true;

        // Save credentials if remember me is checked
        if (rememberMe.value) {
          AppStorageHelper.put(_keyRememberMe, true);
          AppStorageHelper.put(_keyLastLoginEmail, emailController.text.trim());
        } else {
          AppStorageHelper.put(_keyRememberMe, false);
        }

        // Critical verification step
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow storage to complete
        final savedUserId = AppStorageHelper.get<String>(_keyUserId);
        final rawSavedValue = AppStorageHelper.get(_keyUserId);

        print('🔍 VERIFICATION RESULTS:');
        print('   Raw saved value: $rawSavedValue');
        print('   Typed user_id: $savedUserId');
        print('   Original user_id: $userId');
        print('   Save successful: ${savedUserId == userId}');
        print('   Is null: ${savedUserId == null}');
        print('   Is empty: ${savedUserId?.isEmpty}');
        print('=========================');

        Get.snackbar(
          'Success',
          'Login successful! Welcome User',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to dashboard
        Get.offAllNamed(AppRoutes.dashboard);
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

      // Clear auth data from storage (only user_id)
      AppStorageHelper.logout();

      // Clear form only if remember me is disabled
      final rememberMeValue =
          AppStorageHelper.get<bool>(_keyRememberMe, defaultValue: false) ??
          false;
      if (!rememberMeValue) {
        emailController.clear();
        AppStorageHelper.delete(_keyLastLoginEmail);
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
      final savedUserId = AppStorageHelper.get<String>(_keyUserId);
      print('Stored user_id: $savedUserId');

      if (savedUserId != null && savedUserId.isNotEmpty) {
        isLoggedIn.value = true;
        print('User is logged in with ID: $savedUserId');
        // Don't auto-navigate here since splash already handles it
      } else {
        print('No user_id stored - user not logged in');
        isLoggedIn.value = false;
      }
      print('Final login status: ${isLoggedIn.value}');
      print('========================');
    } catch (e) {
      print('Error checking login status: $e');
      isLoggedIn.value = false;
      await _clearAuthData();
    }
  }

  // Helper method to clear auth data
  Future<void> _clearAuthData() async {
    AppStorageHelper.delete(_keyUserId);
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
