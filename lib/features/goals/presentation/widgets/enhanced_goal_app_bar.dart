import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';
import '../../domain/entities/goal.dart';
import '../theme/goals_theme_extended.dart';

/// Enhanced Goal App Bar - Reusable component using enhanced header patterns
class EnhancedGoalAppBar extends StatelessWidget {
  const EnhancedGoalAppBar({
    super.key,
    required this.goal,
    this.onBackPressed,
    this.onMorePressed,
  });

  final Goal goal;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final healthColor = _getGoalHealthColor(goal);

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: onMorePressed ?? () {
            HapticFeedback.lightImpact();
            // Default more options handler can be implemented here
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          goal.title,
          style: AppTypography.h2.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                healthColor.withValues(alpha: 0.1),
                AppColors.surface,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Hero(
                tag: 'goal_${goal.id}',
                child: CircularBudgetIndicator(
                  percentage: goal.progressPercentage,
                  // spent: goal.currentAmount,
                  // total: goal.targetAmount,
                  size: 120,
                  strokeWidth: 12,
                ),
              ),
            ),
          ),
        ),
      ),
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