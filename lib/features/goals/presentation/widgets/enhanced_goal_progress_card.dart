import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';
import '../../domain/entities/goal.dart';
import '../theme/goals_theme_extended.dart';

/// Enhanced Goal Progress Card - Reusable component showing goal progress with metrics
class EnhancedGoalProgressCard extends StatelessWidget {
  const EnhancedGoalProgressCard({
    super.key,
    required this.goal,
    this.showMetrics = true,
  });

  final Goal goal;
  final bool showMetrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.all(24),
      // decoration: BoxDecoration(
        // color: Colors.white,
        // borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.04),
        //     blurRadius: 8,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      // ),
      child: Column(
        children: [
          // Progress Indicator
          // Hero(
          //   tag: 'goal_progress_${goal.id}',
          //   child: CircularBudgetIndicator(
          //     percentage: goal.progressPercentage,
          //     spent: goal.currentAmount,
          //     total: goal.targetAmount,
          //     size: 140,
          //     strokeWidth: 16,
          //   ),
          // ).animate()
          //   .fadeIn(duration: 600.ms)
          //   .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),

          // const SizedBox(height: 24),

          // Progress Text
          // Text(
          //   '${(goal.progressPercentage * 100).toInt()}%',
          //   style: AppTypographyExtended.circularProgressPercentage.copyWith(
          //     color: _getGoalHealthColor(goal),
          //   ),
          // ),
          // const SizedBox(height: 8),
          // Text(
          //   'Progress to Goal',
          //   style: AppTypographyExtended.metricLabel.copyWith(
          //     color: AppColors.textSecondary,
          //   ),
          // ),

          if (showMetrics) ...[
            // const SizedBox(height: 32),
            // Metric Cards
            _buildGoalMetricCards(goal),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildGoalMetricCards(Goal goal) {
    // Calculate velocity (how fast the goal is being achieved)
    final totalDays = goal.deadline.difference(goal.createdAt).inDays;
    final elapsedDays = DateTime.now().difference(goal.createdAt).inDays;
    final timeProgress = elapsedDays / totalDays;
    final progressRatio = goal.progressPercentage / (timeProgress == 0 ? 0.01 : timeProgress);
    final velocity = progressRatio.clamp(0.0, 2.0);

    // Calculate pace (current vs required)
    final requiredDailyContribution = goal.remainingAmount / (goal.daysRemaining > 0 ? goal.daysRemaining : 1);
    final actualDailyContribution = goal.currentAmount / (elapsedDays > 0 ? elapsedDays : 1);
    final pace = actualDailyContribution / (requiredDailyContribution == 0 ? 0.01 : requiredDailyContribution);

    return Row(
      children: [
        Expanded(
          child: _GoalMetricCard(
            title: 'Progress Rate',
            percentage: velocity,
            icon: Icons.trending_up,
            isIncreasing: velocity > 1.0,
            subtitle: velocity > 1.0 ? 'Ahead of schedule' : 'Behind schedule',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GoalMetricCard(
            title: 'Daily Pace',
            percentage: pace.clamp(0.0, 2.0),
            icon: Icons.speed,
            isIncreasing: pace > 1.0,
            subtitle: '\$${actualDailyContribution.toStringAsFixed(2)}/day',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms),
        ),
      ],
    );
  }

  Color _getGoalHealthColor(Goal goal) {
    if (goal.isCompleted) return GoalsThemeExtended.goalSuccess;
    if (goal.isOverdue) return GoalsThemeExtended.goalWarning;
    final progress = goal.progressPercentage;
    if (progress >= 0.75) return GoalsThemeExtended.goalPrimary;
    if (progress >= 0.5) return GoalsThemeExtended.goalSecondary;
    return GoalsThemeExtended.goalWarning;
  }
}

/// Goal Metric Card Widget
class _GoalMetricCard extends StatefulWidget {
  const _GoalMetricCard({
    required this.title,
    required this.percentage,
    required this.icon,
    required this.isIncreasing,
    required this.subtitle,
  });

  final String title;
  final double percentage;
  final IconData icon;
  final bool isIncreasing;
  final String subtitle;

  @override
  State<_GoalMetricCard> createState() => _GoalMetricCardState();
}

class _GoalMetricCardState extends State<_GoalMetricCard>
    with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(_GoalMetricCard oldWidget) {
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
    final color = widget.isIncreasing
        ? GoalsThemeExtended.goalSuccess
        : GoalsThemeExtended.goalWarning;

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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '${(_animation.value * 100).toInt()}%',
                style: AppTypographyExtended.metricPercentage.copyWith(
                  color: color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          Text(
            widget.title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            widget.subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}