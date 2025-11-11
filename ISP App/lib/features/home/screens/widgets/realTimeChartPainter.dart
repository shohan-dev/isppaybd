import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ispapp/core/config/constants/color.dart';
import 'package:ispapp/features/home/models/dashboard_model.dart';

class RealTimeChartPainter extends CustomPainter {
  final List<RealTimeChartData> data;
  final bool isHealthy;

  RealTimeChartPainter(this.data, this.isHealthy);

  @override
  void paint(Canvas canvas, Size size) {
    final double chartHeight = size.height - 50;
    final double chartWidth = size.width - 60;
    final double startX = 45;
    final double startY = 20;

    if (data.isEmpty) {
      _drawEmptyState(canvas, size, startX, startY, chartWidth, chartHeight);
      return;
    }

    // Find max value for scaling
    double maxValue = _getMaxValue();
    if (maxValue == 0) maxValue = 1;

    // Draw background gradient
    _drawBackgroundGradient(canvas, size);

    // Draw minimal grid
    _drawGrid(canvas, startX, startY, chartWidth, chartHeight);

    if (data.length < 2) return;

    // Draw gradient fills under curves
    _drawGradientFill(
      canvas,
      startX,
      startY,
      chartWidth,
      chartHeight,
      maxValue,
      isDownload: true,
    );
    _drawGradientFill(
      canvas,
      startX,
      startY,
      chartWidth,
      chartHeight,
      maxValue,
      isDownload: false,
    );

    // Draw smooth curved lines
    _drawSmoothCurve(
      canvas,
      startX,
      startY,
      chartWidth,
      chartHeight,
      maxValue,
      isDownload: true,
    );
    _drawSmoothCurve(
      canvas,
      startX,
      startY,
      chartWidth,
      chartHeight,
      maxValue,
      isDownload: false,
    );

    // Draw data points
    _drawDataPoints(canvas, startX, startY, chartWidth, chartHeight, maxValue);

    // Draw pulse indicators for live data
    if (isHealthy && data.isNotEmpty) {
      _drawPulseIndicators(
        canvas,
        startX,
        startY,
        chartWidth,
        chartHeight,
        maxValue,
      );
    }

    // Draw Y-axis labels (values)
    _drawYAxisLabels(canvas, startX, startY, chartHeight, maxValue);

    // Draw X-axis labels (time)
    _drawXAxisLabels(canvas, startX, startY, chartWidth, chartHeight);
  }

  void _drawEmptyState(
    Canvas canvas,
    Size size,
    double startX,
    double startY,
    double chartWidth,
    double chartHeight,
  ) {
    // Draw minimal grid
    final gridPaint =
        Paint()
          ..color = AppColors.textSecondary.withOpacity(0.1)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 4; i++) {
      double y = startY + (chartHeight / 4) * i;
      final path = Path();
      path.moveTo(startX, y);
      path.lineTo(startX + chartWidth, y);
      canvas.drawPath(_createDashedPath(path, 5, 5), gridPaint);
    }

    // Draw icon and text
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw emoji icon
    textPainter.text = const TextSpan(text: '', style: TextStyle(fontSize: 12));
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 - 30,
      ),
    );

    // Draw message
    textPainter.text = const TextSpan(
      text: 'Waiting for real-time data...',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 + 30,
      ),
    );
  }

  void _drawBackgroundGradient(Canvas canvas, Size size) {
    // Main background gradient
    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.height),
      [
        AppColors.backgroundGrey.withOpacity(0.5),
        Colors.white.withOpacity(0.9),
        Colors.white,
      ],
      [0.0, 0.5, 1.0],
    );

    final paint = Paint()..shader = gradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add subtle radial glow in center
    final radialGradient = ui.Gradient.radial(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      [AppColors.primary.withOpacity(0.03), Colors.transparent],
    );

    final radialPaint = Paint()..shader = radialGradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), radialPaint);
  }

  void _drawGrid(
    Canvas canvas,
    double startX,
    double startY,
    double chartWidth,
    double chartHeight,
  ) {
    final gridPaint =
        Paint()
          ..color = AppColors.textSecondary.withOpacity(0.15)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Draw only 4 horizontal lines for minimal grid
    for (int i = 0; i <= 4; i++) {
      double y = startY + (chartHeight / 4) * i;
      final path = Path();
      path.moveTo(startX, y);
      path.lineTo(startX + chartWidth, y);
      canvas.drawPath(_createDashedPath(path, 8, 4), gridPaint);
    }
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (distance + length > metric.length) {
          if (draw) {
            dest.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  double _getMaxValue() {
    double maxValue = 0;
    for (final point in data) {
      if (point.download > maxValue) maxValue = point.download;
      if (point.upload > maxValue) maxValue = point.upload;
    }
    return maxValue;
  }

  void _drawGradientFill(
    Canvas canvas,
    double startX,
    double startY,
    double chartWidth,
    double chartHeight,
    double maxValue, {
    required bool isDownload,
  }) {
    final path = Path();
    final List<Offset> points = [];

    // Create points with clamping to prevent going below baseline
    for (int i = 0; i < data.length; i++) {
      double x = startX + (chartWidth / (data.length - 1)) * i;
      double value = isDownload ? data[i].download : data[i].upload;
      // Clamp value to be non-negative and within maxValue
      value = value.clamp(0.0, maxValue);
      double y = startY + chartHeight - (value / maxValue) * chartHeight;
      // Ensure y is within chart bounds
      y = y.clamp(startY, startY + chartHeight);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // Create smooth curve through points
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Close path for gradient fill
    path.lineTo(points.last.dx, startY + chartHeight);
    path.lineTo(points.first.dx, startY + chartHeight);
    path.close();

    final color =
        isDownload ? AppColors.trafficDownload : AppColors.trafficUpload;

    // Create multi-stop gradient for better depth
    final gradient = ui.Gradient.linear(
      Offset(0, startY),
      Offset(0, startY + chartHeight),
      [
        color.withOpacity(0.4),
        color.withOpacity(0.25),
        color.withOpacity(0.1),
        color.withOpacity(0.02),
      ],
      [0.0, 0.3, 0.7, 1.0],
    );

    final paint =
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  void _drawSmoothCurve(
    Canvas canvas,
    double startX,
    double startY,
    double chartWidth,
    double chartHeight,
    double maxValue, {
    required bool isDownload,
  }) {
    final path = Path();
    final List<Offset> points = [];

    // Create points with clamping to prevent going below baseline
    for (int i = 0; i < data.length; i++) {
      double x = startX + (chartWidth / (data.length - 1)) * i;
      double value = isDownload ? data[i].download : data[i].upload;
      // Clamp value to be non-negative and within maxValue
      value = value.clamp(0.0, maxValue);
      double y = startY + chartHeight - (value / maxValue) * chartHeight;
      // Ensure y is within chart bounds
      y = y.clamp(startY, startY + chartHeight);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // Create smooth Catmull-Rom spline curve
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    final color =
        isDownload ? AppColors.trafficDownload : AppColors.trafficUpload;

    // Draw glow effect (outer shadow)
    final glowPaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);

    // Draw main line with gradient
    final paint =
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(startX, startY),
            Offset(startX + chartWidth, startY),
            [color.withOpacity(0.8), color, color],
            [0.0, 0.5, 1.0],
          )
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  void _drawDataPoints(
    Canvas canvas,
    double startX,
    double startY,
    double chartWidth,
    double chartHeight,
    double maxValue,
  ) {
    // Draw only first and last points for cleaner look
    if (data.isEmpty) return;

    for (int idx in [0, data.length - 1]) {
      double x = startX + (chartWidth / (data.length - 1)) * idx;

      // Download point with clamping
      double downloadValue = data[idx].download.clamp(0.0, maxValue);
      double downloadY =
          startY + chartHeight - (downloadValue / maxValue) * chartHeight;
      downloadY = downloadY.clamp(startY, startY + chartHeight);
      _drawPoint(canvas, Offset(x, downloadY), AppColors.trafficDownload);

      // Draw value label for last point
      if (idx == data.length - 1 && data[idx].download > 0) {
        _drawValueLabel(
          canvas,
          Offset(x, downloadY),
          data[idx].download,
          AppColors.trafficDownload,
          isAbove: true,
        );
      }

      // Upload point with clamping
      double uploadValue = data[idx].upload.clamp(0.0, maxValue);
      double uploadY =
          startY + chartHeight - (uploadValue / maxValue) * chartHeight;
      uploadY = uploadY.clamp(startY, startY + chartHeight);
      _drawPoint(canvas, Offset(x, uploadY), AppColors.trafficUpload);

      // Draw value label for last point
      if (idx == data.length - 1 && data[idx].upload > 0) {
        _drawValueLabel(
          canvas,
          Offset(x, uploadY),
          data[idx].upload,
          AppColors.trafficUpload,
          isAbove: false,
        );
      }
    }
  }

  void _drawValueLabel(
    Canvas canvas,
    Offset position,
    double value,
    Color color, {
    required bool isAbove,
  }) {
    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value >= 100) {
      text = value.toStringAsFixed(0);
    } else {
      text = value.toStringAsFixed(1);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 4)],
      ),
    );
    textPainter.layout();

    final offset = Offset(
      position.dx - textPainter.width / 2,
      isAbove ? position.dy - 22 : position.dy + 12,
    );

    // Draw background bubble
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        offset.dx - 4,
        offset.dy - 2,
        textPainter.width + 8,
        textPainter.height + 4,
      ),
      const Radius.circular(6),
    );

    final bubblePaint =
        Paint()
          ..color = color.withOpacity(0.15)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(bubbleRect, bubblePaint);

    // Draw border
    final borderPaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawRRect(bubbleRect, borderPaint);

    textPainter.paint(canvas, offset);
  }

  void _drawPoint(Canvas canvas, Offset position, Color color) {
    // Glow effect
    final glowPaint =
        Paint()
          ..color = color.withOpacity(0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(position, 10, glowPaint);

    // Outer circle with gradient
    final outerGradient = ui.Gradient.radial(position, 10, [
      color.withOpacity(0.4),
      color.withOpacity(0.1),
    ]);
    final outerPaint =
        Paint()
          ..shader = outerGradient
          ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 10, outerPaint);

    // Middle ring
    final middlePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 6, middlePaint);

    // Inner ring (shadow)
    final innerShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 3.5, innerShadowPaint);

    // White center with slight border
    final centerBorderPaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 3, centerBorderPaint);

    final centerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 2.5, centerPaint);
  }

  void _drawPulseIndicators(
    Canvas canvas,
    double startX,
    double startY,
    double chartWidth,
    double chartHeight,
    double maxValue,
  ) {
    if (data.isEmpty) return;

    final lastPoint = data.last;
    double lastX = startX + chartWidth;
    double downloadY =
        startY + chartHeight - (lastPoint.download / maxValue) * chartHeight;
    double uploadY =
        startY + chartHeight - (lastPoint.upload / maxValue) * chartHeight;

    // Animated pulse effect - multiple expanding circles
    for (int i = 0; i < 4; i++) {
      final pulsePaint =
          Paint()
            ..color = AppColors.success.withOpacity(0.2 - (i * 0.04))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 - (i * 0.3);

      canvas.drawCircle(Offset(lastX, downloadY), 10.0 + (i * 5), pulsePaint);
      canvas.drawCircle(Offset(lastX, uploadY), 10.0 + (i * 5), pulsePaint);
    }

    // Glowing background for live indicator
    final glowPaint =
        Paint()
          ..color = AppColors.success.withOpacity(0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(lastX, downloadY), 8, glowPaint);
    canvas.drawCircle(Offset(lastX, uploadY), 8, glowPaint);

    // Live indicator outer ring
    final outerRingPaint =
        Paint()
          ..color = AppColors.success.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(lastX, downloadY), 7, outerRingPaint);
    canvas.drawCircle(Offset(lastX, uploadY), 7, outerRingPaint);

    // Live indicator main dot
    final livePaint =
        Paint()
          ..color = AppColors.success
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(lastX, downloadY), 5, livePaint);
    canvas.drawCircle(Offset(lastX, uploadY), 5, livePaint);

    // White center highlight
    final highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(lastX, downloadY), 2, highlightPaint);
    canvas.drawCircle(Offset(lastX, uploadY), 2, highlightPaint);
  }

  void _drawYAxisLabels(
    Canvas canvas,
    double startX,
    double startY,
    double chartHeight,
    double maxValue,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      double value = maxValue - (maxValue / 4) * i;
      double y = startY + (chartHeight / 4) * i;

      String text;
      if (value >= 1000) {
        text = '${(value / 1000).toStringAsFixed(1)}K';
      } else if (value >= 100) {
        text = value.toStringAsFixed(0);
      } else if (value >= 10) {
        text = value.toStringAsFixed(1);
      } else {
        text = value.toStringAsFixed(2);
      }

      textPainter.text = TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 6));
    }
  }

  void _drawXAxisLabels(
    Canvas canvas,
    double startX,
    double startY,
    double chartWidth,
    double chartHeight,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw fewer labels for cleaner look (every 15 seconds)
    for (int i = 0; i <= 4; i++) {
      double x = startX + (chartWidth / 4) * i;
      int secondsAgo = 60 - (i * 15);

      textPainter.text = TextSpan(
        text: '${secondsAgo}s',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, startY + chartHeight + 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
