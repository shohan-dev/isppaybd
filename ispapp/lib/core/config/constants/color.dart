import 'package:flutter/material.dart';

class AppColors {
  // ==================== Primary Brand Colors ====================
  static const Color primary = Color(0xFF282a35); // Dark blue-grey
  static const Color primaryLight = Color(0xFF357ABD); // Medium blue
  static const Color primaryVariant = Color(0xFF7E57C2);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // ==================== Background Colors ====================
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color backgroundGrey = Color(0xFFFAFAFA); // Grey[50]
  static const Color surface = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF); // White

  // ==================== Text Colors ====================
  static const Color textPrimary = Color(0xFF424242); // Dark grey
  static const Color textSecondary = Color(0xFF757575); // Grey
  static const Color textWhite = Color(0xFFFFFFFF); // White
  static const Color textWhite70 = Color(0xB3FFFFFF); // White 70% opacity

  // ==================== Status Colors ====================
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFF81C784); // Light green
  static const Color successDark = Color(0xFF16A34A); // Dark green
  static const Color successLighter = Color(0xFF34D399); // Lighter green

  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color warningLight = Color(0xFFFCD34D); // Yellow
  static const Color warningDark = Color(0xFFF59E0B); // Dark orange

  static const Color error = Color(0xFFF44336); // Red
  static const Color errorLight = Colors.redAccent;

  static const Color info = Color(0xFF2196F3); // Blue
  static const Color infoLight = Color(0xFF64B5F6); // Light blue

  // ==================== Gradient Colors ====================
  // Header Gradient
  static const List<Color> headerGradient = [
    Color(0xFF282a35), // primary
    Color(0xFF357ABD), // primaryLight
  ];

  // Total Payment Card Gradient
  static const List<Color> totalPaymentGradient = [
    Color(0xFF2D4DDB), // Blue
    Color(0xFF6CB8F6), // Light blue
  ];

  // Payment Successful Gradient
  static const List<Color> successGradient = [
    Color(0xFF16A34A), // successDark
    Color(0xFF34D399), // successLighter
  ];

  // Payment Pending Gradient
  static const List<Color> pendingGradient = [
    Color(0xFFF59E0B), // warningDark
    Color(0xFFFCD34D), // warningLight
  ];

  // Support Ticket Gradient
  static const List<Color> supportGradient = [
    Color(0xFF7C3AED), // Purple
    Color(0xFF9F7AEA), // Light purple
  ];

  // ==================== Feature Colors ====================
  // Account Overview
  static const Color receivedColor = Color(0xFF4CAF50); // Green
  static const Color pendingColor = Color(0xFFFF9800); // Orange
  static const Color ticketColor = Color(0xFF2196F3); // Blue

  // Usage Stats
  static const Color uploadColor = Color(0xFF64B5F6); // Light blue
  static const Color downloadColor = Color(0xFF64B5F6); // Light blue
  static const Color uptimeColor = Color(0xFF4DB6AC); // Teal

  // Traffic Chart
  static const Color trafficDownload = Color(0xFF64B5F6); // Light blue
  static const Color trafficUpload = Color(0xFF81C784); // Light green

  // Payment Chart
  static const Color paymentSuccessful = Color(0xFF64B5F6); // Light blue
  static const Color paymentPending = Color(0xFF81C784); // Light green

  // ==================== UI Element Colors ====================
  // Borders
  static const Color borderLight = Color(0x4DFFFFFF); // White 30%
  static const Color borderWhite = Color(0xFFFFFFFF); // White

  // Overlays & Shadows
  static const Color overlay10 = Color(0x1AFFFFFF); // White 10%
  static const Color overlay12 = Color(0x1FFFFFFF); // White 12%
  static const Color overlay18 = Color(0x2EFFFFFF); // White 18%
  static const Color overlay20 = Color(0x33FFFFFF); // White 20%
  static const Color shadowLight = Color(0x14000000); // Black 8%

  // Error Message
  static const Color errorBackground = Color(0x1AFF9800); // Orange 10%
  static const Color errorBorder = Color(0x4DFF9800); // Orange 30%
  static const Color errorIcon = Color(0xFFF57C00); // Orange[600]
  static const Color errorText = Color(0xFFEF6C00); // Orange[700]

  // Badge
  static const Color badgeBackground = Color(0x1A2196F3); // Blue 10%
  static const Color badgeText = Color(0xFF1976D2); // Blue[700]

  // ==================== Package Feature Colors ====================
  // Bandwidth-based colors (from packages feature)
  static const Color bandwidth50Below = Color(0xFF9E9E9E); // Grey
  static const Color bandwidth50to100 = Color(0xFF2196F3); // Blue
  static const Color bandwidth100to200 = Color(0xFFFF9800); // Orange
  static const Color bandwidth200Plus = Color(0xFF9C27B0); // Purple

  // Package Card Border
  static const Color packageBorderActive = Color(0xFF4CAF50); // Green

  // ==================== Dark Theme Colors ====================
  static const Color darkPrimary = Color(0xFF673AB7);
  static const Color darkPrimaryVariant = Color(0xFF512DA8);
  static const Color darkSecondary = Color(0xFF80CBC4);
  static const Color darkSecondaryVariant = Color(0xFF4DB6AC);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkError = Colors.redAccent;

  // ==================== Helper Methods ====================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get bandwidth color based on speed
  static Color getBandwidthColor(int bandwidth) {
    if (bandwidth < 50) {
      return bandwidth50Below;
    } else if (bandwidth >= 50 && bandwidth < 100) {
      return bandwidth50to100;
    } else if (bandwidth >= 100 && bandwidth < 200) {
      return bandwidth100to200;
    } else {
      return bandwidth200Plus;
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'connected':
      case 'success':
      case 'successful':
        return success;
      case 'pending':
      case 'inactive':
        return warning;
      case 'failed':
      case 'disconnected':
      case 'error':
        return error;
      default:
        return info;
    }
  }
}
