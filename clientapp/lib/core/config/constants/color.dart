import 'package:flutter/material.dart';

class AppColors {
  // ISP Portal Color Palette
  static const Color primary = Color(0xFF2B3674); // Dark blue for sidebar
  static const Color primaryVariant = Color(0xFF1B2559);
  static const Color secondary = Color(0xFF4318FF); // Purple accent
  static const Color secondaryVariant = Color(0xFF3311CC);

  // Status Colors
  static const Color success = Color(
    0xFF05CD99,
  ); // Green for successful payments
  static const Color warning = Color(0xFFFFB547); // Orange for pending
  static const Color error = Color(0xFFEE5D52); // Red for errors
  static const Color info = Color(0xFF3965FF); // Blue for info

  // UI Colors
  static const Color background = Color(
    0xFFF4F7FE,
  ); // Light blue-gray background
  static const Color surface = Colors.white; // Card background
  static const Color cardBorder = Color(0xFFE0E5F2);

  // Text Colors
  static const Color textPrimary = Color(0xFF1B2559);
  static const Color textSecondary = Color(0xFF8F9BBA);
  static const Color textLight = Colors.white;

  // Gradient Colors for Stats Cards
  static const List<Color> blueGradient = [
    Color(0xFF3965FF),
    Color(0xFF1E40AF),
  ];
  static const List<Color> greenGradient = [
    Color(0xFF05CD99),
    Color(0xFF059669),
  ];
  static const List<Color> orangeGradient = [
    Color(0xFFFFB547),
    Color(0xFFEA580C),
  ];
  static const List<Color> purpleGradient = [
    Color(0xFF8B5CF6),
    Color(0xFF7C3AED),
  ];

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF2B3674);
  static const Color darkPrimaryVariant = Color(0xFF1B2559);
  static const Color darkSecondary = Color(0xFF4318FF);
  static const Color darkSecondaryVariant = Color(0xFF3311CC);
  static const Color darkBackground = Color(0xFF0B1437);
  static const Color darkSurface = Color(0xFF1B2559);
  static const Color darkError = Color(0xFFEE5D52);
}
