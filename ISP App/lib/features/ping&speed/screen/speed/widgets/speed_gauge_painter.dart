import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpeedGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  SpeedGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background arc with gradient
    final bgPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.06),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Progress arc with glow effects
    if (progress > 0) {
      // Outer glow
      final outerGlowPaint =
          Paint()
            ..color = color.withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 20
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        -math.pi * 0.75,
        math.pi * 1.5 * progress,
        false,
        outerGlowPaint,
      );

      // Inner glow
      final innerGlowPaint =
          Paint()
            ..color = color.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 16
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        -math.pi * 0.75,
        math.pi * 1.5 * progress,
        false,
        innerGlowPaint,
      );

      // Main progress arc with gradient
      final progressPaint =
          Paint()
            ..shader = LinearGradient(
              colors: [color.withOpacity(0.6), color, color.withAlpha(255)],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(Rect.fromCircle(center: center, radius: radius))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 14
            ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        -math.pi * 0.75,
        math.pi * 1.5 * progress,
        false,
        progressPaint,
      );

      // End cap with glow
      final angle = -math.pi * 0.75 + math.pi * 1.5 * progress;
      final endCapX = center.dx + (radius - 8) * math.cos(angle);
      final endCapY = center.dy + (radius - 8) * math.sin(angle);

      // Glow for end cap
      final endCapGlowPaint =
          Paint()
            ..color = color.withOpacity(0.5)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(endCapX, endCapY), 8, endCapGlowPaint);

      // Solid end cap
      final endCapPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(endCapX, endCapY), 5, endCapPaint);

      // Inner ring for end cap
      final endCapInnerPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(endCapX, endCapY), 3, endCapInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SpeedGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
