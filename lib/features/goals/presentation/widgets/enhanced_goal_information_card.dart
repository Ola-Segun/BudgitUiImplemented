import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/settings/presentation/widgets/privacy_mode_text.dart';
import '../theme/goals_theme_extended.dart';
import '../../domain/entities/goal.dart';

/// Enhanced Goal Information Card - Reusable component using _InfoRow pattern from budget screens
class EnhancedGoalInformationCard extends ConsumerWidget {
  const EnhancedGoalInformationCard({
    super.key,
    required this.goal,
    this.categoryName,
    this.categoryColor,
  });

  final Goal goal;
  final String? categoryName;
  final Color? categoryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayCategoryName = categoryName ?? goal.categoryId.replaceAll('_', ' ').toUpperCase();
    final displayCategoryColor = categoryColor ?? GoalsThemeExtended.goalPrimary;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GoalsThemeExtended.goalTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: GoalsThemeExtended.goalTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Goal Information',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _InfoRow(
            label: 'Category',
            value: Text(displayCategoryName),
            icon: Icons.category_outlined,
            valueColor: displayCategoryColor,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Priority',
            value: Text(goal.priority.displayName),
            icon: Icons.flag_outlined,
            valueColor: _getPriorityColor(goal.priority),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Target Amount',
            value: PrivacyModeAmount(
              amount: goal.targetAmount,
            ),
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Monthly Required',
            value: PrivacyModeAmount(
              amount: goal.requiredMonthlyContribution,
            ),
            icon: Icons.calendar_month,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Status',
            value: Text(goal.isCompleted ? 'Completed' : goal.isOverdue ? 'Overdue' : 'In Progress'),
            icon: goal.isCompleted ? Icons.check_circle_outline : Icons.pending_outlined,
            valueColor: goal.isCompleted
                ? GoalsThemeExtended.goalSuccess
                : goal.isOverdue
                    ? GoalsThemeExtended.goalWarning
                    : GoalsThemeExtended.goalPrimary,
          ),

          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorsExtended.pillBgUnselected,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Description',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    goal.description,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ],

          if (goal.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tags',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: goal.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppTypography.caption.copyWith(
                      color: GoalsThemeExtended.goalPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 600.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 600.ms);
  }

  Color _getPriorityColor(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.high:
        return GoalsThemeExtended.priorityHigh;
      case GoalPriority.medium:
        return GoalsThemeExtended.priorityMedium;
      case GoalPriority.low:
        return GoalsThemeExtended.priorityLow;
    }
  }
}

/// Info Row Widget - Reusable pattern from budget screens
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final Widget value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DefaultTextStyle(
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
          child: value,
        ),
      ],
    );
  }
}