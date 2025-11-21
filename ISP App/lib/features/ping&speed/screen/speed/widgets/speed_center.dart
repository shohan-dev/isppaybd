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
        // Icon with rotation animation
        if (testInProgress)
          AnimatedBuilder(
            animation: rotationController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (currentTestType == TestType.download
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3))
                      .withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: (currentTestType == TestType.download
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF2196F3))
                          .withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.speed_rounded,
                  size: 32,
                  color:
                      currentTestType == TestType.download
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3),
                ),
              );
            },
          )
        else
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Colors.white.withOpacity(0.05),
          //     border: Border.all(
          //       color: Colors.white.withOpacity(0.1),
          //       width: 1.5,
          //     ),
          //   ),
          //   child: Icon(
          //     Icons.speed_rounded,
          //     size: 32,
          //     color: Colors.white.withOpacity(0.4),
          //   ),
          // ),
          const SizedBox(height: 24),

        // Speed value
        // Text(
        //   animatedValue.toStringAsFixed(2),
        //   style: TextStyle(
        //     fontSize: 64,
        //     fontWeight: FontWeight.w800,
        //     color: Colors.white,
        //     letterSpacing: -3,
        //     height: 1.0,
        //     shadows: [
        //       Shadow(
        //         color: (currentTestType == TestType.download
        //                 ? const Color(0xFF4CAF50)
        //                 : currentTestType == TestType.upload
        //                 ? const Color(0xFF2196F3)
        //                 : AppColors.primary)
        //             .withOpacity(0.4),
        //         blurRadius: 20,
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 4),

        // Unit text
        Text(
          unitText,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 16),

        // Status text
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
                  ? Container(
                    key: ValueKey(currentTestType),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Text(
                      currentTestType == TestType.download
                          ? 'Measuring Download'
                          : currentTestType == TestType.upload
                          ? 'Measuring Upload'
                          : 'Initializing',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                  : const SizedBox(height: 28),
        ),
      ],
    );
  }
}

// Note: TestType is defined in speed_screen.dart; import where used.
