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
        if (testInProgress)
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return Container(
                width: 300 + (pulseController.value * 30),
                height: 300 + (pulseController.value * 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (currentTestType == TestType.download
                            ? Colors.green
                            : currentTestType == TestType.upload
                            ? Colors.blue
                            : Colors.blue)
                        .withOpacity(0.3 * (1 - pulseController.value)),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),

        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.1), Colors.transparent],
            ),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: CustomPaint(
            painter: SpeedGaugePainter(progress: progress, color: color),
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
