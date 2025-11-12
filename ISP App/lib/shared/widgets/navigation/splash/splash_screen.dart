import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/config/constants/color.dart';
import 'package:ispapp/shared/widgets/navigation/splash/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashScreenController>(
      init: SplashScreenController(), // Initialize controller
      builder: (controller) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.headerGradient,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern with subtle overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [AppColors.overlay10, Colors.transparent],
                      ),
                    ),
                  ),
                ),
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo Section with animation-ready container
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.overlay12,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.borderLight,
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            'assets/img/logo.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Tagline
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlay10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          'CONNECTING YOU WITH NETWORK OF TRUST',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite70,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Loading indicator with glow effect
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.textWhite.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          // Progress indicator
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textWhite,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textWhite70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Version info at bottom
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlay10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textWhite70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
