import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ispapp/features/home/models/dashboard_model.dart';

class RealTimeChartPainter extends CustomPainter {
  final List<RealTimeChartData> data;
  final bool isHealthy;

  RealTimeChartPainter(this.data, this.isHealthy);

  @override
  void paint(Canvas canvas, Size size) {
    final double chartHeight = size.height - 40;
    final double chartWidth = size.width - 40;
    final double startX = 20;
    final double startY = 20;

    if (data.isEmpty) {
      // Draw empty state
      final paint =
          Paint()
            ..color = Colors.grey.withOpacity(0.3)
            ..strokeWidth = 1;

      // Draw grid
      for (int i = 0; i <= 5; i++) {
        double y = startY + (chartHeight / 5) * i;
        canvas.drawLine(
          Offset(startX, y),
          Offset(startX + chartWidth, y),
          paint,
        );
      }

      // Draw "No Data" message
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = const TextSpan(
        text: 'Waiting for real-time data...',
        style: TextStyle(color: Color(0xFF757575), fontSize: 14),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
      return;
    }

    // Find max value for scaling
    double maxValue = 0;
    for (final point in data) {
      if (point.download > maxValue) maxValue = point.download;
      if (point.upload > maxValue) maxValue = point.upload;
    }
    if (maxValue == 0) maxValue = 1; // Avoid division by zero

    // Draw grid
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 0.5;

    for (int i = 0; i <= 5; i++) {
      double y = startY + (chartHeight / 5) * i;
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + chartWidth, y),
        gridPaint,
      );
    }

    if (data.length < 2) return;

    // Draw lines
    final downloadPaint =
        Paint()
          ..color = const Color(0xFF64B5F6)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final uploadPaint =
        Paint()
          ..color = const Color(0xFF81C784)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final downloadPath = Path();
    final uploadPath = Path();

    for (int i = 0; i < data.length; i++) {
      double x = startX + (chartWidth / (data.length - 1)) * i;
      double downloadY =
          startY + chartHeight - (data[i].download / maxValue) * chartHeight;
      double uploadY =
          startY + chartHeight - (data[i].upload / maxValue) * chartHeight;

      if (i == 0) {
        downloadPath.moveTo(x, downloadY);
        uploadPath.moveTo(x, uploadY);
      } else {
        downloadPath.lineTo(x, downloadY);
        uploadPath.lineTo(x, uploadY);
      }
    }

    canvas.drawPath(downloadPath, downloadPaint);
    canvas.drawPath(uploadPath, uploadPaint);

    // Draw current values if healthy
    if (isHealthy && data.isNotEmpty) {
      final lastPoint = data.last;
      double lastX = startX + chartWidth;

      // Pulse effect for live data
      final pulsePaint =
          Paint()
            ..color = Colors.green.withOpacity(0.3)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          lastX - 10,
          startY + chartHeight - (lastPoint.download / maxValue) * chartHeight,
        ),
        8,
        pulsePaint,
      );
      canvas.drawCircle(
        Offset(
          lastX - 10,
          startY + chartHeight - (lastPoint.upload / maxValue) * chartHeight,
        ),
        8,
        pulsePaint,
      );
    }

    // Draw scale numbers
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      double value = maxValue - (maxValue / 4) * i;
      double y = startY + (chartHeight / 4) * i;

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(color: Color(0xFF757575), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    // Draw time labels (last 60 seconds)
    for (int i = 0; i <= 6; i++) {
      double x = startX + (chartWidth / 6) * i;
      int secondsAgo = 60 - (i * 10);

      textPainter.text = TextSpan(
        text: '${secondsAgo}s',
        style: const TextStyle(color: Color(0xFF757575), fontSize: 8),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, startY + chartHeight + 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
