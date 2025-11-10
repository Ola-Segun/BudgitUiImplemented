import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/insight.dart';

/// Card widget to display spending insights and anomalies
class SpendingInsightsCard extends ConsumerWidget {
  const SpendingInsightsCard({
    super.key,
    this.maxInsights = 5,
  });

  final int maxInsights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.insights,
                    color: AppColors.warning,
                    size: AppSpacing.iconLg,
                  ),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending Insights',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        'AI-powered analysis of your spending patterns',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(AppSpacing.lg),
            _buildInsightsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsList() {
    // Sample insights - in real implementation, this would come from a provider
    final sampleInsights = _generateSampleInsights();

    if (sampleInsights.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: sampleInsights.take(maxInsights).map((insight) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _buildInsightItem(insight),
        );
      }).toList(),
    );
  }

  Widget _buildInsightItem(Insight insight) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _getInsightBackgroundColor(insight.priority),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: _getInsightBorderColor(insight.priority),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getInsightIcon(insight.type),
            color: _getInsightIconColor(insight.priority),
            size: AppSpacing.iconMd,
          ),
          Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(AppSpacing.xs),
                Text(
                  insight.message,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (insight.amount != null) ...[
                  Gap(AppSpacing.xs),
                  Text(
                    '\$${insight.amount!.toStringAsFixed(2)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: _getInsightIconColor(insight.priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getPriorityBadgeColor(insight.priority),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              insight.priority.displayName,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.textSecondary,
            size: AppSpacing.iconXxl,
          ),
          Gap(AppSpacing.md),
          Text(
            'No insights available',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(AppSpacing.xs),
          Text(
            'Add more transactions to see spending insights',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getInsightBackgroundColor(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.low:
        return AppColors.success.withValues(alpha: 0.05);
      case InsightPriority.medium:
        return AppColors.warning.withValues(alpha: 0.05);
      case InsightPriority.high:
        return AppColors.error.withValues(alpha: 0.05);
      case InsightPriority.urgent:
        return AppColors.error.withValues(alpha: 0.1);
    }
  }

  Color _getInsightBorderColor(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.low:
        return AppColors.success.withValues(alpha: 0.3);
      case InsightPriority.medium:
        return AppColors.warning.withValues(alpha: 0.3);
      case InsightPriority.high:
        return AppColors.error.withValues(alpha: 0.3);
      case InsightPriority.urgent:
        return AppColors.error.withValues(alpha: 0.5);
    }
  }

  Color _getInsightIconColor(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.low:
        return AppColors.success;
      case InsightPriority.medium:
        return AppColors.warning;
      case InsightPriority.high:
        return AppColors.error;
      case InsightPriority.urgent:
        return AppColors.error;
    }
  }

  Color _getPriorityBadgeColor(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.low:
        return AppColors.success;
      case InsightPriority.medium:
        return AppColors.warning;
      case InsightPriority.high:
        return AppColors.error;
      case InsightPriority.urgent:
        return AppColors.error;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.spendingTrend:
        return Icons.show_chart;
      case InsightType.budgetAlert:
        return Icons.warning;
      case InsightType.savingsOpportunity:
        return Icons.savings;
      case InsightType.unusualActivity:
        return Icons.warning_amber;
      case InsightType.goalProgress:
        return Icons.flag;
      case InsightType.billReminder:
        return Icons.receipt;
      case InsightType.categoryAnalysis:
        return Icons.category;
      case InsightType.monthlySummary:
        return Icons.calendar_month;
      case InsightType.comparison:
        return Icons.compare;
      case InsightType.recommendation:
        return Icons.lightbulb;
    }
  }

  List<Insight> _generateSampleInsights() {
    return [
      Insight(
        id: 'trend_1',
        title: 'Increasing spending in Food & Dining',
        message: 'Your spending in Food & Dining has increased by 15.3% compared to last month. Consider reviewing your dining expenses.',
        type: InsightType.spendingTrend,
        generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        categoryId: 'food',
        amount: 245.67,
        percentage: 15.3,
        priority: InsightPriority.medium,
      ),
      Insight(
        id: 'anomaly_1',
        title: 'Unusual transaction detected',
        message: 'A transaction of \$89.99 appears unusually high for the Utilities category. This might be worth reviewing.',
        type: InsightType.unusualActivity,
        generatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        categoryId: 'utilities',
        transactionId: 'txn_123',
        amount: 89.99,
        priority: InsightPriority.high,
      ),
      Insight(
        id: 'comparison_1',
        title: 'Monthly spending decreased',
        message: 'Great job! Your total expenses decreased by 8.2% compared to last month. Current spending: \$1,245.67.',
        type: InsightType.comparison,
        generatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        amount: -102.34,
        percentage: -8.2,
        priority: InsightPriority.low,
      ),
      Insight(
        id: 'savings_1',
        title: 'Savings opportunity identified',
        message: 'You could save \$45.50 monthly by reducing entertainment spending by 20%. This would improve your savings rate.',
        type: InsightType.savingsOpportunity,
        generatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        categoryId: 'entertainment',
        amount: 45.50,
        percentage: 20.0,
        priority: InsightPriority.medium,
      ),
    ];
  }
}