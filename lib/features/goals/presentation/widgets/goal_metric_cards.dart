import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../theme/goals_theme_extended.dart';
import '../../domain/entities/goal.dart';

class GoalMetricCards extends StatelessWidget {
  const GoalMetricCards({
    super.key,
    required this.goal,
  });

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final daysPercentage = goal.daysRemaining > 0
        ? (goal.daysRemaining / (goal.deadline.difference(goal.createdAt).inDays)).clamp(0.0, 1.0)
        : 0.0;


    return Row(
      children: [
        Expanded(
          child: _GoalMetricCard(
            title: 'Progress',
            value: goal.progressPercentage,
            displayValue: '${(goal.progressPercentage * 100).toInt()}%',
            icon: Icons.trending_up,
            color: GoalsThemeExtended.goalPrimary,
            subtitle: goal.formattedCurrentAmount,
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GoalMetricCard(
            title: 'Time Left',
            value: daysPercentage,
            displayValue: '${goal.daysRemaining}d',
            icon: Icons.calendar_today,
            color: goal.isOverdue
                ? GoalsThemeExtended.goalWarning
                : GoalsThemeExtended.goalSecondary,
            subtitle: goal.isOverdue ? 'Overdue' : 'Remaining',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms),
        ),
      ],
    );
  }
}

class _GoalMetricCard extends StatefulWidget {
  const _GoalMetricCard({
    required this.title,
    required this.value,
    required this.displayValue,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final String title;
  final double value;
  final String displayValue;
  final IconData icon;
  final Color color;
  final String subtitle;

  @override
  State<_GoalMetricCard> createState() => _GoalMetricCardState();
}

class _GoalMetricCardState extends State<_GoalMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animationValue = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(_GoalMetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animationValue = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
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
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Icon container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 16),

          // Display value
          Text(
            widget.displayValue,
            style: AppTypographyExtended.metricPercentage.copyWith(
              color: widget.color,
            ),
          ),
          const SizedBox(height: 4),

          // Title
          Text(
            widget.title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}