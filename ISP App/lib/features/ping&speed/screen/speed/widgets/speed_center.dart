import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:ispapp/core/config/constants/color.dart';
import 'test_type.dart';

class SpeedCenter extends StatelessWidget {
  final double animatedSpeed;
  final String unitText;
  final bool testInProgress;
  final AnimationController rotationController;
  final TestType currentTestType;

  const SpeedCenter({
    Key? key,
    required this.animatedSpeed,
    required this.unitText,
    required this.testInProgress,
    required this.rotationController,
    required this.currentTestType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (testInProgress)
          AnimatedBuilder(
            animation: rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: rotationController.value * 2 * math.pi,
                child: Icon(
                  Icons.speed,
                  size: 40,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              );
            },
          )
        else
          Icon(
            Icons.speed,
            size: 40,
            color: AppColors.primary.withOpacity(0.3),
          ),

        const SizedBox(height: 20),

        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          tween: Tween<double>(begin: 0, end: animatedSpeed),
          builder: (context, animatedValue, child) {
            return Text(
              animatedValue.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -2,
                height: 1.0,
              ),
            );
          },
        ),

        Text(
          unitText,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          child:
              testInProgress
                  ? Text(
                    currentTestType == TestType.download
                        ? 'Testing Download...'
                        : currentTestType == TestType.upload
                        ? 'Testing Upload...'
                        : 'Preparing...',
                    key: ValueKey(currentTestType),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.background,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                  : const SizedBox(height: 20),
        ),
      ],
    );
  }
}

// Note: TestType is defined in speed_screen.dart; import where used.
