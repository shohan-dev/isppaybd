import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppToastHelper {
  /// Show a custom toast message with different types.
  static void showToast({
    required String message,
    String title = "Notification",
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM, // Show at the bottom
      duration: duration,
      backgroundColor: _getBackgroundColor(type),
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      icon: _getIcon(type),
      shouldIconPulse: false,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  /// Get color based on toast type.
  static Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade600;
      case ToastType.error:
        return Colors.red.shade600;
      case ToastType.warning:
        return Colors.orange.shade700;
      case ToastType.info:
        return Colors.blue.shade600;
    }
  }

  /// Get icon based on toast type.
  static Icon _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Icon(Icons.check_circle, color: Colors.white);
      case ToastType.error:
        return const Icon(Icons.error, color: Colors.white);
      case ToastType.warning:
        return const Icon(Icons.warning, color: Colors.white);
      case ToastType.info:
        return const Icon(Icons.info, color: Colors.white);
    }
  }
}

/// Enum for defining different toast types.
enum ToastType { success, error, warning, info }
