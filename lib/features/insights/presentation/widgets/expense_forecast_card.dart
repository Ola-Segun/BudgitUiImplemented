import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../settings/presentation/widgets/privacy_mode_text.dart';

/// Card widget for expense forecasting
class ExpenseForecastCard extends ConsumerWidget {
  const ExpenseForecastCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual forecast data from provider
    final forecast = _getMockForecast();

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
                    Icons.trending_up,
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
                        'Expense Forecast',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        'Projected spending for next 3 months',
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

            // Current month
            _buildForecastRow('This Month', forecast.currentMonth, AppColors.textPrimary),
            Gap(AppSpacing.sm),

            // Next month
            _buildForecastRow('Next Month', forecast.nextMonth, _getForecastColor(forecast.nextMonthChange)),
            Gap(AppSpacing.sm),

            // Month after next
            _buildForecastRow('In 2 Months', forecast.monthAfterNext, AppColors.textPrimary),
            Gap(AppSpacing.lg),

            // Trend indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTrendColor(forecast.overallTrend).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTrendIcon(forecast.overallTrend),
                    color: _getTrendColor(forecast.overallTrend),
                    size: AppSpacing.iconMd,
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    forecast.overallTrend.displayName,
                    style: AppTypography.bodyMedium.copyWith(
                      color: _getTrendColor(forecast.overallTrend),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Gap(AppSpacing.md),

            // Key insights
            Text(
              'Key Insights',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(AppSpacing.sm),
            ...forecast.insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: AppColors.info,
                    size: AppSpacing.iconSm,
                  ),
                  Gap(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      insight,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastRow(String label, double amount, Color amountColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        PrivacyModeAmount(
          amount: amount,
          currency: '\$',
          style: AppTypography.bodyMedium.copyWith(
            color: amountColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getForecastColor(double change) {
    if (change > 10) return AppColors.danger;
    if (change < -10) return AppColors.success;
    return AppColors.textPrimary;
  }

  Color _getTrendColor(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.increasing:
        return AppColors.danger;
      case TrendDirection.decreasing:
        return AppColors.success;
      case TrendDirection.stable:
        return AppColors.warning;
    }
  }

  IconData _getTrendIcon(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.increasing:
        return Icons.trending_up;
      case TrendDirection.decreasing:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  ExpenseForecast _getMockForecast() {
    // Mock data - replace with real forecast calculation
    return ExpenseForecast(
      currentMonth: 2850.0,
      nextMonth: 3120.0,
      monthAfterNext: 2980.0,
      nextMonthChange: 9.5,
      overallTrend: TrendDirection.increasing,
      insights: [
        'Housing costs expected to rise 5% next month',
        'Groceries trending 12% higher than last quarter',
        'Transportation costs stable with slight decrease',
        'Consider adjusting budget for utilities increase',
      ],
    );
  }
}

/// Expense forecast data
class ExpenseForecast {
  const ExpenseForecast({
    required this.currentMonth,
    required this.nextMonth,
    required this.monthAfterNext,
    required this.nextMonthChange,
    required this.overallTrend,
    required this.insights,
  });

  final double currentMonth;
  final double nextMonth;
  final double monthAfterNext;
  final double nextMonthChange;
  final TrendDirection overallTrend;
  final List<String> insights;
}

/// Trend direction enum (reuse from insight.dart)
enum TrendDirection {
  increasing('Increasing'),
  decreasing('Decreasing'),
  stable('Stable');

  const TrendDirection(this.displayName);

  final String displayName;
}