import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ispapp/core/config/constants/color.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen>
    with TickerProviderStateMixin {
  final Dio _dio = Dio();

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

  // Speed calculation tracking
  final List<double> _downloadSpeeds = [];
  final List<double> _uploadSpeeds = [];
  final List<double> _pingValues = [];

  // Test URLs - using reliable CDN endpoints
  final List<String> _downloadTestUrls = [
    'https://speed.cloudflare.com/__down?bytes=10000000', // 10MB
    'https://proof.ovh.net/files/10Mb.dat',
    'https://ash-speed.hetzner.com/10MB.bin',
  ];

  final String _uploadTestUrl = 'https://speed.cloudflare.com/__up';

  final List<String> _pingTestUrls = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://www.amazon.com',
  ];

  @override
  void initState() {
    super.initState();
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
    _dio.close();
    super.dispose();
  }

  Future<void> _startSpeedTest() async {
    if (_testInProgress) return;

    setState(() {
      _testInProgress = true;
      _downloadRate = 0;
      _uploadRate = 0;
      _ping = 0;
      _currentTestType = TestType.download;
    });

    // Clear previous results
    _downloadSpeeds.clear();
    _uploadSpeeds.clear();
    _pingValues.clear();

    _rotationController.repeat();

    try {
      // Test ping multiple times for accuracy
      setState(() => _currentTestType = TestType.none);
      await _testPing();

      // Test download speed
      setState(() => _currentTestType = TestType.download);
      await _testDownloadSpeed();

      // Test upload speed
      setState(() => _currentTestType = TestType.upload);
      await _testUploadSpeed();

      // Calculate final averages
      setState(() {
        if (_downloadSpeeds.isNotEmpty) {
          _downloadRate =
              _downloadSpeeds.reduce((a, b) => a + b) / _downloadSpeeds.length;
        }
        if (_uploadSpeeds.isNotEmpty) {
          _uploadRate =
              _uploadSpeeds.reduce((a, b) => a + b) / _uploadSpeeds.length;
        }
        if (_pingValues.isNotEmpty) {
          _ping = _pingValues.reduce((a, b) => a + b) / _pingValues.length;
        }
        _testInProgress = false;
        _currentTestType = TestType.none;
      });
    } catch (e) {
      setState(() {
        _testInProgress = false;
        _currentTestType = TestType.none;
      });
      _showError('Speed test error: ${e.toString()}');
    } finally {
      _rotationController.stop();
    }
  }

  Future<void> _testPing() async {
    // Test ping 3 times to each URL and get average
    for (final url in _pingTestUrls) {
      try {
        final stopwatch = Stopwatch()..start();
        await _dio.head(
          url,
          options: Options(
            receiveTimeout: const Duration(seconds: 5),
            sendTimeout: const Duration(seconds: 5),
          ),
        );
        stopwatch.stop();
        final pingMs = stopwatch.elapsedMilliseconds.toDouble();
        if (pingMs > 0 && pingMs < 5000) {
          _pingValues.add(pingMs);
          setState(() {
            _ping = _pingValues.reduce((a, b) => a + b) / _pingValues.length;
          });
        }
      } catch (e) {
        debugPrint('Ping test error for $url: $e');
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _testDownloadSpeed() async {
    // Test download speed from multiple sources
    for (int i = 0; i < _downloadTestUrls.length && i < 2; i++) {
      try {
        final url = _downloadTestUrls[i];
        final stopwatch = Stopwatch()..start();
        int totalBytes = 0;
        int lastReceivedBytes = 0;
        int lastTimestamp = 0;

        final response = await _dio.get(
          url,
          options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(seconds: 20),
          ),
          onReceiveProgress: (received, total) {
            totalBytes = received;
            final currentTime = stopwatch.elapsedMilliseconds;

            // Calculate instantaneous speed every 500ms
            if (currentTime - lastTimestamp >= 500) {
              final bytesInInterval = received - lastReceivedBytes;
              final timeInterval = (currentTime - lastTimestamp) / 1000;

              if (timeInterval > 0) {
                // Speed in Mbps = (bytes * 8 / 1,000,000) / seconds
                final speedMbps =
                    (bytesInInterval * 8 / 1000000) / timeInterval;

                if (speedMbps > 0 && speedMbps < 1000) {
                  _downloadSpeeds.add(speedMbps);
                  setState(() {
                    _downloadRate = speedMbps;
                    _unitText = 'Mbps';
                  });
                  _animateSpeedValue(_downloadRate);
                }
              }

              lastReceivedBytes = received;
              lastTimestamp = currentTime;
            }
          },
        );

        // Consume the stream
        await response.data.stream.drain();

        stopwatch.stop();

        // Calculate final speed for this test
        final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000;
        if (elapsedSeconds > 0 && totalBytes > 0) {
          final speedMbps = (totalBytes * 8 / 1000000) / elapsedSeconds;
          if (speedMbps > 0 && speedMbps < 1000) {
            _downloadSpeeds.add(speedMbps);
          }
        }

        // Small delay between tests
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Download test error: $e');
      }
    }

    // Update with average
    if (_downloadSpeeds.isNotEmpty) {
      setState(() {
        _downloadRate =
            _downloadSpeeds.reduce((a, b) => a + b) / _downloadSpeeds.length;
      });
    }
  }

  Future<void> _testUploadSpeed() async {
    // Test upload speed twice for better accuracy
    for (int testRun = 0; testRun < 2; testRun++) {
      try {
        // Generate 3MB of random data
        final uploadSize = 3 * 1024 * 1024; // 3MB
        final randomData = List.generate(
          uploadSize,
          (i) => math.Random().nextInt(256),
        );

        final stopwatch = Stopwatch()..start();
        int lastSentBytes = 0;
        int lastTimestamp = 0;

        await _dio.post(
          _uploadTestUrl,
          data: Stream.fromIterable(randomData.map((e) => [e])),
          options: Options(
            headers: {
              'Content-Length': uploadSize,
              'Content-Type': 'application/octet-stream',
            },
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
          onSendProgress: (sent, total) {
            final currentTime = stopwatch.elapsedMilliseconds;

            // Calculate instantaneous speed every 500ms
            if (currentTime - lastTimestamp >= 500) {
              final bytesInInterval = sent - lastSentBytes;
              final timeInterval = (currentTime - lastTimestamp) / 1000;

              if (timeInterval > 0) {
                // Speed in Mbps = (bytes * 8 / 1,000,000) / seconds
                final speedMbps =
                    (bytesInInterval * 8 / 1000000) / timeInterval;

                if (speedMbps > 0 && speedMbps < 1000) {
                  _uploadSpeeds.add(speedMbps);
                  setState(() {
                    _uploadRate = speedMbps;
                    _unitText = 'Mbps';
                  });
                  _animateSpeedValue(_uploadRate);
                }
              }

              lastSentBytes = sent;
              lastTimestamp = currentTime;
            }
          },
        );

        stopwatch.stop();

        // Calculate final speed for this test
        final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000;
        if (elapsedSeconds > 0 && uploadSize > 0) {
          final speedMbps = (uploadSize * 8 / 1000000) / elapsedSeconds;
          if (speedMbps > 0 && speedMbps < 1000) {
            _uploadSpeeds.add(speedMbps);
          }
        }

        // Small delay between tests
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Upload test error: $e');
      }
    }

    // Update with average
    if (_uploadSpeeds.isNotEmpty) {
      setState(() {
        _uploadRate =
            _uploadSpeeds.reduce((a, b) => a + b) / _uploadSpeeds.length;
      });
    }
  }

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
              Expanded(child: Center(child: _buildSpeedGauge())),

              // Speed Metrics
              _buildMetricsRow(),

              const SizedBox(height: 40),

              // Start Button
              _buildStartButton(),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedGauge() {
    final currentSpeed =
        _testInProgress
            ? _animatedCurrentSpeed
            : (_currentTestType == TestType.download
                ? _downloadRate
                : _currentTestType == TestType.upload
                ? _uploadRate
                : _downloadRate);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Single clean pulse ring
        if (_testInProgress)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 300 + (_pulseController.value * 30),
                height: 300 + (_pulseController.value * 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (_currentTestType == TestType.download
                            ? Colors.green
                            : _currentTestType == TestType.upload
                            ? Colors.blue
                            : AppColors.primary)
                        .withOpacity(0.3 * (1 - _pulseController.value)),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),

        // Main gauge circle
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          tween: Tween<double>(
            begin: 0,
            end: _testInProgress ? (currentSpeed / 100).clamp(0.0, 1.0) : 0,
          ),
          builder: (context, animatedProgress, child) {
            return Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CustomPaint(
                painter: _SpeedGaugePainter(
                  progress: animatedProgress,
                  color:
                      _currentTestType == TestType.download
                          ? Colors.green
                          : _currentTestType == TestType.upload
                          ? Colors.blue
                          : AppColors.primary,
                ),
              ),
            );
          },
        ),

        // Center content
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_testInProgress)
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
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
              tween: Tween<double>(begin: 0, end: currentSpeed),
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
              _unitText,
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
                  _testInProgress
                      ? Text(
                        _currentTestType == TestType.download
                            ? 'Testing Download...'
                            : _currentTestType == TestType.upload
                            ? 'Testing Upload...'
                            : 'Preparing...',
                        key: ValueKey(_currentTestType),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      : const SizedBox(height: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildMetricCard(
              icon: Icons.download,
              label: 'Download',
              value: _downloadRate.toStringAsFixed(2),
              unit: _unitText,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.upload,
              label: 'Upload',
              value: _uploadRate.toStringAsFixed(2),
              unit: _unitText,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.network_ping,
              label: 'Ping',
              value: _ping.toStringAsFixed(0),
              unit: 'ms',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            tween: Tween<double>(begin: 0, end: double.tryParse(value) ?? 0),
            builder: (context, animatedValue, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animatedValue.toStringAsFixed(unit == 'ms' ? 0 : 2),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTapDown: (_) => _testInProgress ? null : _scaleController.forward(),
      onTapUp: (_) => _testInProgress ? null : _scaleController.reverse(),
      onTapCancel: () => _testInProgress ? null : _scaleController.reverse(),
      onTap: _testInProgress ? null : _startSpeedTest,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 220,
              height: 64,
              decoration: BoxDecoration(
                gradient:
                    _testInProgress
                        ? LinearGradient(
                          colors: [Colors.grey.shade600, Colors.grey.shade700],
                        )
                        : LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withBlue(220),
                          ],
                        ),
                borderRadius: BorderRadius.circular(32),
                boxShadow:
                    _testInProgress
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _testInProgress ? 'TESTING...' : 'START TEST',
                    key: ValueKey(_testInProgress),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum TestType { none, download, upload }

class _SpeedGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SpeedGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background arc
    final bgPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Progress arc with subtle glow
    if (progress > 0) {
      // Subtle outer glow
      final glowPaint =
          Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 16
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        -math.pi * 0.75,
        math.pi * 1.5 * progress,
        false,
        glowPaint,
      );

      // Main progress arc with gradient
      final progressPaint =
          Paint()
            ..shader = LinearGradient(
              colors: [color.withOpacity(0.7), color, color],
            ).createShader(Rect.fromCircle(center: center, radius: radius))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12
            ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        -math.pi * 0.75,
        math.pi * 1.5 * progress,
        false,
        progressPaint,
      );

      // End cap dot
      final angle = -math.pi * 0.75 + math.pi * 1.5 * progress;
      final endCapX = center.dx + (radius - 6) * math.cos(angle);
      final endCapY = center.dy + (radius - 6) * math.sin(angle);

      final endCapPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(endCapX, endCapY), 4, endCapPaint);
    }
  }

  @override
  bool shouldRepaint(_SpeedGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
