import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Mini trend indicator widget for showing small sparkline charts
class MiniTrendIndicator extends StatelessWidget {
  const MiniTrendIndicator({
    super.key,
    required this.values,
    required this.color,
    this.width = 60,
    this.height = 24,
    this.strokeWidth = 2,
    this.showPoints = false,
  });

  final List<double> values;
  final Color color;
  final double width;
  final double height;
  final double strokeWidth;
  final bool showPoints;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _MiniTrendPainter(
          values: values,
          color: color,
          strokeWidth: strokeWidth,
          showPoints: showPoints,
        ),
      ).animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2, duration: 400.ms),
    );
  }
}

class _MiniTrendPainter extends CustomPainter {
  _MiniTrendPainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
    required this.showPoints,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;
  final bool showPoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final path = Path();
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) {
      // All values are the same, draw a horizontal line
      final y = size.height / 2;
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    } else {
      final stepX = size.width / (values.length - 1);

      for (int i = 0; i < values.length; i++) {
        final x = i * stepX;
        final normalizedValue = (values[i] - minValue) / range;
        final y = size.height - (normalizedValue * size.height);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        if (showPoints) {
          canvas.drawCircle(
            Offset(x, y),
            strokeWidth * 0.8,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          );
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MiniTrendPainter oldDelegate) {
    return oldDelegate.values != values ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.showPoints != showPoints;
  }
}