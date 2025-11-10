import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';

/// Dual metric cards showing usage rate and allotment rate with animations.
/// Displays percentage values with trend indicators and contextual colors.
class BudgetMetricCards extends StatelessWidget {
  const BudgetMetricCards({
    super.key,
    required this.usageRate,
    required this.allotmentRate,
  });

  /// Usage rate (0.0 to 1.0) - how much of budget has been spent
  final double usageRate;

  /// Allotment rate (0.0 to 1.0) - spending rate vs time progress
  final double allotmentRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 48), // Ensure minimum touch target
            child: _MetricCard(
              title: 'Usage Rate',
              percentage: usageRate,
              icon: Icons.trending_up,
              isIncreasing: true,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 48), // Ensure minimum touch target
            child: _MetricCard(
              title: 'Allotment Rate',
              percentage: allotmentRate,
              icon: Icons.trending_down,
              isIncreasing: false,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatefulWidget {
  const _MetricCard({
    required this.title,
    required this.percentage,
    required this.icon,
    required this.isIncreasing,
  });

  final String title;
  final double percentage;
  final IconData icon;
  final bool isIncreasing;

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
  void didUpdateWidget(_MetricCard oldWidget) {
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
    final trendColor = widget.isIncreasing
        ? AppColorsExtended.statusNormal
        : AppColorsExtended.statusCritical;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: trendColor,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '${(_animation.value * 100).toInt()}%',
                style: AppTypographyExtended.metricPercentage.copyWith(
                  color: const Color(0xFF0F172A),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            widget.title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}