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
  static const String _keySavedPassword = 'saved_password';
  static const String _keyLoginTimestamp = 'login_timestamp';

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
      print('🚀 AUTH CONTROLLER: Starting initialization...');
      // Ensure storage is initialized before any operations
      await AppStorageHelper.init();
      print('✅ AUTH CONTROLLER: Storage initialized');
      _loadSavedCredentials();
      print('✅ AUTH CONTROLLER: Credentials loaded');
      checkLoginStatus();
      print('✅ AUTH CONTROLLER: Login status checked');
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
    print('=== LOADING SAVED CREDENTIALS ===');

    final savedEmail = AppStorageHelper.get<String>(_keyLastLoginEmail);
    final savedPassword = AppStorageHelper.get<String>(_keySavedPassword);
    final rememberMeValue =
        AppStorageHelper.get<bool>(_keyRememberMe, defaultValue: false) ??
        false;

    print('📧 Saved Email: $savedEmail (length: ${savedEmail?.length ?? 0})');
    print(
      '🔑 Saved Password: ${savedPassword != null ? "***LENGTH: ${savedPassword.length}***" : "null"}',
    );
    print('💾 Remember Me: $rememberMeValue');

    if (savedEmail != null && savedPassword != null && rememberMeValue) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;
      rememberMe.value = true;
      print('✅ Loaded saved credentials for: $savedEmail');
      print(
        '✅ Email field set to: ${emailController.text} (length: ${emailController.text.length})',
      );
      print(
        '✅ Password field set to: ${passwordController.text.isNotEmpty ? "***LENGTH: ${passwordController.text.length}***" : "EMPTY"}',
      );
    } else {
      print('❌ Not loading credentials because:');
      if (savedEmail == null) print('   - Email is null');
      if (savedPassword == null) print('   - Password is null');
      if (!rememberMeValue) print('   - Remember Me is false');
    }
    print('================================');
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

        // Save login timestamp for 60-minute auto-logout
        final loginTime = DateTime.now().millisecondsSinceEpoch;
        AppStorageHelper.put(_keyLoginTimestamp, loginTime);
        print('⏰ Login timestamp saved: $loginTime');

        // Update controller state
        isLoggedIn.value = true;

        // Save credentials if remember me is checked
        print('=== REMEMBER ME SAVE CHECK ===');
        print('📌 Remember Me Checkbox: ${rememberMe.value}');
        print('📧 Email to save: ${emailController.text.trim()}');
        print(
          '🔑 Password to save: ${passwordController.text.trim().isNotEmpty ? "***EXISTS***" : "EMPTY"}',
        );

        if (rememberMe.value) {
          final emailToSave = emailController.text.trim();
          final passwordToSave = passwordController.text.trim();

          print('💾 Saving Remember Me credentials...');
          print('   Email length: ${emailToSave.length}');
          print('   Password length: ${passwordToSave.length}');

          AppStorageHelper.put(_keyRememberMe, true);
          AppStorageHelper.put(_keyLastLoginEmail, emailToSave);
          AppStorageHelper.put(_keySavedPassword, passwordToSave);
          print('💾 Remember Me: Saved username and password');

          // Verify immediately after saving
          final verifyEmail = AppStorageHelper.get<String>(_keyLastLoginEmail);
          final verifyPassword = AppStorageHelper.get<String>(
            _keySavedPassword,
          );
          final verifyRememberMe = AppStorageHelper.get<bool>(_keyRememberMe);
          print(
            '✅ VERIFY - Email: $verifyEmail (length: ${verifyEmail?.length ?? 0})',
          );
          print(
            '✅ VERIFY - Password: ${verifyPassword != null ? "***LENGTH: ${verifyPassword.length}***" : "null"}',
          );
          print('✅ VERIFY - Remember Me: $verifyRememberMe');
        } else {
          AppStorageHelper.put(_keyRememberMe, false);
          AppStorageHelper.delete(_keyLastLoginEmail);
          AppStorageHelper.delete(_keySavedPassword);
          print('🗑️ Remember Me disabled: Cleared saved credentials');
        }
        print('=============================');

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

      // Clear login timestamp
      AppStorageHelper.delete(_keyLoginTimestamp);

      // Clear form only if remember me is disabled
      final rememberMeValue =
          AppStorageHelper.get<bool>(_keyRememberMe, defaultValue: false) ??
          false;
      if (!rememberMeValue) {
        emailController.clear();
        passwordController.clear();
        AppStorageHelper.delete(_keyLastLoginEmail);
        AppStorageHelper.delete(_keySavedPassword);
      } else {
        // Keep email and password in the fields if remember me is enabled
        final savedEmail = AppStorageHelper.get<String>(_keyLastLoginEmail);
        final savedPassword = AppStorageHelper.get<String>(_keySavedPassword);

        if (savedEmail != null) {
          emailController.text = savedEmail;
        }
        if (savedPassword != null) {
          passwordController.text = savedPassword;
        }

        print('💾 Remember Me enabled - keeping credentials in form');
        print('   Email restored: ${emailController.text}');
        print(
          '   Password restored: ${passwordController.text.isNotEmpty ? "***YES***" : "NO"}',
        );
      }

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
      final loginTimestamp = AppStorageHelper.get<int>(_keyLoginTimestamp);

      print('Stored user_id: $savedUserId');
      print('Stored login_timestamp: $loginTimestamp');

      // CRITICAL: User must have BOTH user_id AND login_timestamp to be logged in
      if (savedUserId != null &&
          savedUserId.isNotEmpty &&
          loginTimestamp != null) {
        // Check if login has expired (60 minutes)
        final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
        final now = DateTime.now();
        final difference = now.difference(loginTime);

        print('⏰ Login time: $loginTime');
        print('⏰ Current time: $now');
        print('⏰ Time elapsed: ${difference.inMinutes} minutes');

        if (difference.inMinutes >= 60) {
          print('⚠️ Session expired (60+ minutes). Auto-logout...');
          await _autoLogout();
          isLoggedIn.value = false;
          return;
        } else {
          print(
            '✅ Session valid. Time remaining: ${60 - difference.inMinutes} minutes',
          );
          isLoggedIn.value = true;
          print('User is logged in with ID: $savedUserId');
        }
      } else {
        // Invalid session - clear everything
        if (savedUserId != null && loginTimestamp == null) {
          print(
            '⚠️ Invalid session: user_id exists but no timestamp. Clearing...',
          );
          await _clearAuthData();
        }
        print('❌ No valid session - user not logged in');
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

  Future<void> _autoLogout() async {
    print('🔐 Auto-logout: Session expired after 60 minutes');
    currentUser.value = null;
    isLoggedIn.value = false;

    // Clear auth data but keep remember me credentials
    AppStorageHelper.delete(_keyUserId);
    AppStorageHelper.delete(_keyLoginTimestamp);
    AppStorageHelper.delete('token');

    // Preserve Remember Me credentials:
    // - _keyRememberMe
    // - _keyLastLoginEmail
    // - _keySavedPassword
    print('💾 Remember Me credentials preserved');

    Get.snackbar(
      'Session Expired',
      'Your session has expired. Please login again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // Helper method to clear auth data (preserves Remember Me)
  Future<void> _clearAuthData() async {
    // Only clear session data, NOT Remember Me credentials
    AppStorageHelper.delete(_keyUserId);
    AppStorageHelper.delete(_keyLoginTimestamp);
    AppStorageHelper.delete('token');
    print('💾 Session cleared, Remember Me credentials preserved');
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
