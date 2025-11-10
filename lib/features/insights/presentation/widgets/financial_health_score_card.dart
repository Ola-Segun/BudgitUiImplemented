import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/insight.dart';
import '../providers/insight_providers.dart';

/// Card widget displaying financial health score
class FinancialHealthScoreCard extends ConsumerWidget {
  const FinancialHealthScoreCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthScoreAsync = ref.watch(financialHealthScoreProvider);

    return healthScoreAsync.when(
      data: (healthScore) => healthScore != null ? _buildHealthScoreCard(healthScore) : _buildEmptyState(),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }


  Widget _buildEmptyState() {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.iconXxl,
                  height: AppSpacing.iconXxl,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: AppColors.textSecondary,
                    size: AppSpacing.iconLg,
                  ),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Health Score',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        'Add transactions to see your score',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.iconXxl,
                  height: AppSpacing.iconXxl,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: AppColors.textSecondary,
                    size: AppSpacing.iconLg,
                  ),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Health Score',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        'Calculating...',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.iconXxl,
                  height: AppSpacing.iconXxl,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: AppColors.danger,
                    size: AppSpacing.iconLg,
                  ),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Health Score',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        'Unable to calculate score',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(FinancialHealthScore healthScore) {

    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.iconXxl,
                  height: AppSpacing.iconXxl,
                  decoration: BoxDecoration(
                    color: _getScoreColor(healthScore.grade).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    _getScoreIcon(healthScore.grade),
                    color: _getScoreColor(healthScore.grade),
                    size: AppSpacing.iconLg,
                  ),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Health Score',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        healthScore.grade.displayName,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(healthScore.grade).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    '${healthScore.overallScore}%',
                    style: AppTypography.titleLarge.copyWith(
                      color: _getScoreColor(healthScore.grade),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Gap(AppSpacing.md),
            // Score progress bar
            LinearProgressIndicator(
              value: healthScore.scorePercentage,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(healthScore.grade)),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            Gap(AppSpacing.md),
            // Strengths and weaknesses
            if (healthScore.strengths.isNotEmpty) ...[
              Text(
                'Strengths',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(AppSpacing.xs),
              ...healthScore.strengths.take(2).map((strength) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: AppSpacing.iconSm,
                    ),
                    Gap(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        strength,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            if (healthScore.weaknesses.isNotEmpty) ...[
              Gap(AppSpacing.sm),
              Text(
                'Areas for Improvement',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(AppSpacing.xs),
              ...healthScore.weaknesses.take(2).map((weakness) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppColors.warning,
                      size: AppSpacing.iconSm,
                    ),
                    Gap(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        weakness,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  FinancialHealthScore _getMockHealthScore() {
    // Mock data - replace with real data from provider
    return FinancialHealthScore(
      overallScore: 78,
      grade: FinancialHealthGrade.good,
      componentScores: {
        'savings_rate': 75,
        'budget_adherence': 82,
        'debt_to_income': 65,
        'emergency_fund': 90,
      },
      strengths: [
        'Good savings rate of 15%',
        'Consistent budget adherence',
        'Strong emergency fund coverage',
      ],
      weaknesses: [
        'High debt-to-income ratio',
        'Irregular income sources',
      ],
      recommendations: [
        'Consider debt consolidation',
        'Build additional income streams',
      ],
      calculatedAt: DateTime.now(),
    );
  }

  Color _getScoreColor(FinancialHealthGrade grade) {
    switch (grade) {
      case FinancialHealthGrade.excellent:
        return AppColors.success;
      case FinancialHealthGrade.good:
        return AppColors.primary;
      case FinancialHealthGrade.fair:
        return AppColors.warning;
      case FinancialHealthGrade.poor:
        return AppColors.danger;
      case FinancialHealthGrade.critical:
        return AppColors.danger;
    }
  }

  IconData _getScoreIcon(FinancialHealthGrade grade) {
    switch (grade) {
      case FinancialHealthGrade.excellent:
        return Icons.star;
      case FinancialHealthGrade.good:
        return Icons.trending_up;
      case FinancialHealthGrade.fair:
        return Icons.trending_flat;
      case FinancialHealthGrade.poor:
        return Icons.trending_down;
      case FinancialHealthGrade.critical:
        return Icons.warning;
    }
  }
}