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
  bool shouldRepaint(covariant SpeedGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
