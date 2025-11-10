import 'package:flutter/material.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';
import '../theme/goals_theme_extended.dart';
import '../../domain/entities/goal.dart';

/// Wrapper around CircularBudgetIndicator customized for goals
class CircularGoalIndicator extends StatelessWidget {
  const CircularGoalIndicator({
    super.key,
    required this.goal,
    this.size = 200,
    this.strokeWidth = 20,
  });

  final Goal goal;
  final double size;
  final double strokeWidth;


  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Reuse budget's circular indicator
        CircularBudgetIndicator(
          percentage: goal.progressPercentage,
          spent: goal.currentAmount,
          total: goal.targetAmount,
          size: size,
          strokeWidth: strokeWidth,
        ),

        // Optional: Goal-specific overlay
        if (goal.isCompleted)
          Positioned(
            bottom: size * 0.15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: GoalsThemeExtended.goalSuccess,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: GoalsThemeExtended.goalSuccess.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Completed!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}