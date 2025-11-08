import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/helpers/local_storage/storage_helper.dart';
import 'package:ispapp/core/routes/app_routes.dart';

class SplashScreenController extends GetxController {
  // Timer for splash screen duration
  final RxBool isLoading = true.obs;

  // Storage keys - same as AuthController
  static const String _keyUserId = 'user_id';
  static const String _keyLoginTimestamp = 'login_timestamp';

  @override
  void onInit() {
    super.onInit();
    _navigateAfterDelay();
  }

  // Navigate after a delay
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final userId = AppStorageHelper.get<String>(_keyUserId);
      final loginTimestamp = AppStorageHelper.get<int>(_keyLoginTimestamp);

      // Debugging output
      print('=== SPLASH SCREEN CHECK ===');
      print('💾 Storage check - user_id: $userId');
      print('⏰ Login timestamp: $loginTimestamp');

      // CRITICAL: User must have BOTH user_id AND login_timestamp to be considered logged in
      if (userId != null && userId.isNotEmpty && loginTimestamp != null) {
        // Check if 60 minutes have passed since login
        final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
        final now = DateTime.now();
        final difference = now.difference(loginTime);

        print('⏰ Login time: $loginTime');
        print('⏰ Current time: $now');
        print('⏰ Time elapsed: ${difference.inMinutes} minutes');

        if (difference.inMinutes >= 60) {
          print(
            '⚠️ Session expired (${difference.inMinutes} minutes). Logging out...',
          );

          // Clear session data BUT preserve Remember Me credentials
          AppStorageHelper.delete(_keyUserId);
          AppStorageHelper.delete(_keyLoginTimestamp);
          AppStorageHelper.delete('token');

          // DON'T delete these - they should persist for Remember Me:
          // - 'remember_me'
          // - 'last_login_email'
          // - 'saved_password'

          print('💾 Remember Me credentials preserved');

          // Show session expired message
          Future.delayed(Duration.zero, () {
            Get.snackbar(
              'Session Expired',
              'Your session has expired after 60 minutes. Please login again.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          });

          print('❌ Session expired → Login');
          Get.offAllNamed(AppRoutes.login);
          return;
        } else {
          final remainingMinutes = 60 - difference.inMinutes;
          print('✅ Session valid. Time remaining: $remainingMinutes minutes');
          print('✅ User authenticated (ID: $userId) → Dashboard');
          Get.offAllNamed(AppRoutes.dashboard);
          print('=========================');
          return;
        }
      } else {
        // No valid session - go to login
        if (userId == null || userId.isEmpty) {
          print('❌ No user_id found → Login');
        } else if (loginTimestamp == null) {
          print('❌ No login_timestamp found (invalid session) → Login');
          // Clear invalid session data BUT preserve Remember Me
          AppStorageHelper.delete(_keyUserId);
          AppStorageHelper.delete('token');
          // DON'T delete Remember Me credentials
          print('💾 Remember Me credentials preserved');
        }

        print('❌ User not authenticated → Login');
        Get.offAllNamed(AppRoutes.login);
      }
      print('=========================');
    } catch (e) {
      print('💥 SPLASH ERROR: $e');
      print('🔄 Defaulting to login screen');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
