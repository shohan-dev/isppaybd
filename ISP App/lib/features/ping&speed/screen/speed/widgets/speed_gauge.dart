import 'package:flutter/material.dart';
import 'speed_gauge_painter.dart';
import 'speed_center.dart';
import 'test_type.dart';

class SpeedGauge extends StatelessWidget {
  final double progress; // 0..1 normalized
  final Color color;
  final double animatedSpeed;
  final bool testInProgress;
  final AnimationController pulseController;
  final AnimationController rotationController;
  final TestType currentTestType;

  const SpeedGauge({
    Key? key,
    required this.progress,
    required this.color,
    required this.animatedSpeed,
    required this.testInProgress,
    required this.pulseController,
    required this.rotationController,
    required this.currentTestType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse rings
        if (testInProgress)
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return Container(
                width: 320 + (pulseController.value * 40),
                height: 320 + (pulseController.value * 40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (currentTestType == TestType.download
                            ? const Color(0xFF4CAF50)
                            : currentTestType == TestType.upload
                            ? const Color(0xFF2196F3)
                            : color)
                        .withOpacity(0.25 * (1 - pulseController.value)),
                    width: 2,
                  ),
                ),
              );
            },
          ),

        // Middle glow ring
        if (testInProgress)
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

        // Main gauge container
        Container(
          width: 290,
          height: 290,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.08),
                color.withOpacity(0.03),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
          ),
          child: CustomPaint(
            painter: SpeedGaugePainter(progress: progress, color: color),
          ),
        ),

        // Inner shadow circle
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.black.withOpacity(0.3), Colors.transparent],
            ),
          ),
        ),

        // Center content
        SpeedCenter(
          animatedSpeed: animatedSpeed,
          unitText: 'Mbps',
          testInProgress: testInProgress,
          rotationController: rotationController,
          currentTestType: currentTestType,
        ),
      ],
    );
  }
}

// Note: TestType is defined in speed_screen.dart; import where used.
