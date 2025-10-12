import 'package:flutter/widgets.dart';
import 'package:ispapp/features/home/models/dashboard_model.dart';

class PaymentChartPainter extends CustomPainter {
  final List<PaymentChartData> data;

  PaymentChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double barWidth = size.width / (data.length * 2);
    final double maxHeight = size.height - 40;

    // Find max value for scaling
    double maxValue = 0;
    for (final item in data) {
      if (item.successful > maxValue) maxValue = item.successful;
      if (item.pending > maxValue) maxValue = item.pending;
    }
    if (maxValue == 0) maxValue = 1;

    final successfulPaint = Paint()..color = const Color(0xFF4CAF50);
    final pendingPaint = Paint()..color = const Color(0xFFFF9800);

    for (int i = 0; i < data.length; i++) {
      double x = i * barWidth * 2;

      // Successful payments bar
      double successfulHeight = (data[i].successful / maxValue) * maxHeight;
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          size.height - successfulHeight,
          barWidth,
          successfulHeight,
        ),
        successfulPaint,
      );

      // Pending payments bar
      double pendingHeight = (data[i].pending / maxValue) * maxHeight;
      canvas.drawRect(
        Rect.fromLTWH(
          x + barWidth,
          size.height - pendingHeight,
          barWidth,
          pendingHeight,
        ),
        pendingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
