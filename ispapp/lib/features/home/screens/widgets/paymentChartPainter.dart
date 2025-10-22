import 'package:flutter/material.dart';
import 'package:ispapp/features/home/models/dashboard_model.dart';

class PaymentChartPainter extends CustomPainter {
  final List<PaymentChartData> data;

  PaymentChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      _drawNoDataMessage(canvas, size);
      return;
    }

    // Reserve space for labels at bottom
    final double chartHeight = size.height - 30;
    final double chartWidth = size.width;

    // Calculate spacing and bar widths
    final int visibleMonths = data.length;
    final double groupWidth = chartWidth / visibleMonths;
    final double barSpacing = 4.0;
    final double barWidth =
        (groupWidth - barSpacing * 3) / 2; // 2 bars per group

    // Find max value for scaling
    double maxValue = 0;
    for (final item in data) {
      final maxInMonth =
          item.successful > item.pending ? item.successful : item.pending;
      if (maxInMonth > maxValue) maxValue = maxInMonth;
    }

    // If all values are 0, show a baseline
    if (maxValue == 0) maxValue = 10;

    // Define colors matching the legend
    final successfulPaint =
        Paint()
          ..color = const Color(0xFF64B5F6)
          ..style = PaintingStyle.fill;

    final pendingPaint =
        Paint()
          ..color = const Color(0xFF81C784)
          ..style = PaintingStyle.fill;

    // Draw bars for each month
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final double groupX = i * groupWidth;

      // Calculate bar heights (minimum 2px for visibility even if value is small)
      double successfulHeight =
          item.successful > 0
              ? ((item.successful / maxValue) * chartHeight).clamp(
                2.0,
                chartHeight,
              )
              : 0;

      double pendingHeight =
          item.pending > 0
              ? ((item.pending / maxValue) * chartHeight).clamp(
                2.0,
                chartHeight,
              )
              : 0;

      // Draw successful payments bar (left)
      if (successfulHeight > 0) {
        final successfulRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            groupX + barSpacing,
            chartHeight - successfulHeight,
            barWidth,
            successfulHeight,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(successfulRect, successfulPaint);
      }

      // Draw pending payments bar (right)
      if (pendingHeight > 0) {
        final pendingRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            groupX + barSpacing * 2 + barWidth,
            chartHeight - pendingHeight,
            barWidth,
            pendingHeight,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(pendingRect, pendingPaint);
      }

      // Draw month label
      final textPainter = TextPainter(
        text: TextSpan(
          text: item.month,
          style: const TextStyle(
            color: Color(0xFF757575),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelX = groupX + (groupWidth - textPainter.width) / 2;
      final labelY = chartHeight + 8;
      textPainter.paint(canvas, Offset(labelX, labelY));
    }

    // Draw baseline
    final baselinePaint =
        Paint()
          ..color = const Color(0xFFE0E0E0)
          ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(chartWidth, chartHeight),
      baselinePaint,
    );
  }

  void _drawNoDataMessage(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'No payment data available',
        style: TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(PaymentChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
