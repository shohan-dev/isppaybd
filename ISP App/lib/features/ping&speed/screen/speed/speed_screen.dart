import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ispapp/core/config/constants/color.dart';
import 'dart:math' as math;
import 'widgets/speed_gauge.dart';
import 'widgets/test_type.dart';
import 'widgets/metrics_row.dart';
import 'widgets/start_test_button.dart';
import '../../controllers/speed_controller.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen>
    with TickerProviderStateMixin {
  late final SpeedTestController _controller;

  double _downloadRate = 0;
  double _uploadRate = 0;
  double _ping = 0;

  String _unitText = 'Mbps';
  bool _testInProgress = false;
  TestType _currentTestType = TestType.none;

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _shimmerController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Smooth animation value for speedometer effect
  double _animatedCurrentSpeed = 0;
  // controller-driven: speed values are updated from `_controller`

  @override
  void initState() {
    super.initState();
    _controller = SpeedTestController();
    // Listen to controller updates and copy values into local state for UI
    _controller.addListener(() {
      if (!mounted) return;
      setState(() {
        _downloadRate = _controller.downloadRate;
        _uploadRate = _controller.uploadRate;
        _ping = _controller.ping;
        _testInProgress = _controller.isTesting;
        _currentTestType = _controller.currentTestType;
        _unitText = 'Mbps';
      });
      // animate gauge when values update
      final activeSpeed =
          _currentTestType == TestType.download
              ? _controller.downloadRate
              : _controller.uploadRate;
      _animateSpeedValue(activeSpeed);
      // control rotation animation
      if (_testInProgress) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _shimmerController.dispose();
    _scaleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startSpeedTest() async {
    if (_testInProgress) return;
    // delegate to controller
    await _controller.startTest();
  }

  // The test logic has been moved to `SpeedTestController`.

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _animateSpeedValue(double targetSpeed) {
    final startSpeed = _animatedCurrentSpeed;
    final duration = const Duration(milliseconds: 600);
    final startTime = DateTime.now().millisecondsSinceEpoch;

    void updateSpeed() {
      if (!mounted) return;

      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
      final progress = (elapsed / duration.inMilliseconds).clamp(0.0, 1.0);

      // Easing function for smooth deceleration
      final easedProgress =
          progress < 0.5
              ? 2 * progress * progress
              : 1 - math.pow(-2 * progress + 2, 2) / 2;

      setState(() {
        _animatedCurrentSpeed =
            startSpeed + (targetSpeed - startSpeed) * easedProgress;
      });

      if (progress < 1.0) {
        Future.delayed(const Duration(milliseconds: 16), updateSpeed);
      }
    }

    updateSpeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Speed Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              AppColors.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Speed Gauge
              Expanded(
                child: Center(
                  child: SpeedGauge(
                    progress:
                        _testInProgress
                            ? (_animatedCurrentSpeed / 100).clamp(0.0, 1.0)
                            : 0,
                    color:
                        _currentTestType == TestType.download
                            ? Colors.green
                            : _currentTestType == TestType.upload
                            ? Colors.blue
                            : AppColors.primary,
                    animatedSpeed:
                        _testInProgress
                            ? _animatedCurrentSpeed
                            : (_currentTestType == TestType.download
                                ? _downloadRate
                                : _uploadRate),
                    testInProgress: _testInProgress,
                    pulseController: _pulseController,
                    rotationController: _rotationController,
                    currentTestType: _currentTestType,
                  ),
                ),
              ),

              // Speed Metrics
              MetricsRow(
                downloadRate: _downloadRate,
                uploadRate: _uploadRate,
                ping: _ping,
                unitText: _unitText,
              ),

              const SizedBox(height: 40),

              // Start Button
              StartTestButton(
                scaleAnimation: _scaleAnimation,
                scaleController: _scaleController,
                testInProgress: _testInProgress,
                onStart: _startSpeedTest,
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // MetricsRow is used directly in the build method; helper removed.
}
