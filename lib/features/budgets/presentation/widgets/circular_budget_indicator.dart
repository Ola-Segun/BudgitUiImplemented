import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';

/// A circular progress indicator showing budget usage with animations.
/// Displays percentage completion, spent vs total amount, and color-coded health status.
class CircularBudgetIndicator extends StatefulWidget {
  const CircularBudgetIndicator({
    super.key,
    required this.percentage,
    this.spent,
    this.total,
    this.size = 200,
    this.strokeWidth = 20,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  /// Progress percentage (0.0 to 1.0)
  final double percentage;

  /// Amount spent
  final double? spent;

  /// Total budget amount
  final double? total;

  /// Size of the circular indicator
  final double size;

  /// Width of the progress stroke
  final double strokeWidth;

  /// Animation duration
  final Duration animationDuration;

  @override
  State<CircularBudgetIndicator> createState() => _CircularBudgetIndicatorState();
}

class _CircularBudgetIndicatorState extends State<CircularBudgetIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.percentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularBudgetIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: oldWidget.percentage,
        end: widget.percentage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentPercentage = _animation.value;
        final progressColor = AppColorsExtended.getProgressColor(currentPercentage);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle with pattern
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularBackgroundPainter(
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: AppColorsExtended.pillBgUnselected,
                ),
              ),

              // Progress arc
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularProgressPainter(
                  percentage: currentPercentage,
                  strokeWidth: widget.strokeWidth,
                  progressColor: progressColor,
                  glowIntensity: currentPercentage > 0.75 ? 0.3 : 0.1,
                ),
              ),

              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: currentPercentage * 100),
                    duration: widget.animationDuration,
                    builder: (context, value, child) {
                      return Text(
                        '${value.toInt()}%',
                        style: AppTypographyExtended.circularProgressPercentage.copyWith(
                          color: progressColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  if (widget.spent != null && widget.total != null)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: widget.spent!),
                      duration: widget.animationDuration,
                      builder: (context, value, child) {
                        return RichText(
                          text: TextSpan(
                            style: AppTypographyExtended.circularProgressAmount.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                            children: [
                              TextSpan(
                                text: '\$${value.toInt()}',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: ' / \$${widget.total!.toInt()}',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularBackgroundPainter extends CustomPainter {
  _CircularBackgroundPainter({
    required this.strokeWidth,
    required this.backgroundColor,
  });

  final double strokeWidth;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw subtle pattern lines
    final patternPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 40; i++) {
      final angle = (i * 9) * math.pi / 180;
      final startRadius = radius - strokeWidth / 2 + 2;
      final endRadius = radius + strokeWidth / 2 - 2;

      final start = Offset(
        center.dx + startRadius * math.cos(angle - math.pi / 2),
        center.dy + startRadius * math.sin(angle - math.pi / 2),
      );

      final end = Offset(
        center.dx + endRadius * math.cos(angle - math.pi / 2),
        center.dy + endRadius * math.sin(angle - math.pi / 2),
      );

      canvas.drawLine(start, end, patternPaint);
    }
  }

  @override
  bool shouldRepaint(_CircularBackgroundPainter oldDelegate) => false;
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.progressColor,
    this.glowIntensity = 0.2,
  });

  final double percentage;
  final double strokeWidth;
  final Color progressColor;
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final sweepAngle = 2 * math.pi * percentage;

    // Draw glow effect
    if (glowIntensity > 0) {
      final glowPaint = Paint()
        ..color = progressColor.withValues(alpha: glowIntensity)
        ..strokeWidth = strokeWidth + 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // Draw gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: sweepAngle > 0 ? -math.pi / 2 + sweepAngle : -math.pi / 2 + 0.01,
      colors: [
        progressColor,
        progressColor.withValues(alpha: 0.7),
        progressColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw end cap circle
    if (percentage > 0) {
      final endAngle = -math.pi / 2 + sweepAngle;
      final endCapCenter = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final capPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(endCapCenter, strokeWidth / 2, capPaint);
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.progressColor != progressColor;
  }
}