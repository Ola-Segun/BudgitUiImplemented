import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/cards/app_card.dart';
import '../states/transaction_state.dart';

/// Widget for displaying transaction statistics
class TransactionStatsCard extends StatelessWidget {
  const TransactionStatsCard({
    super.key,
    required this.stats,
  });

  final TransactionStats stats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: AppCardElevation.low,
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic),
          SizedBox(height: AppDimensions.spacing3),

          // Stats Row
          Row(
            children: [
              // Income
              Expanded(
                child: _buildStatItem(
                  context,
                  'Income',
                  '\$${stats.totalIncome.toStringAsFixed(2)}',
                  AppColors.success,
                  Icons.arrow_upward,
                ).animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.1, duration: 500.ms, delay: 100.ms, curve: Curves.easeOutCubic),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Expenses
              Expanded(
                child: _buildStatItem(
                  context,
                  'Expenses',
                  '\$${stats.totalExpenses.toStringAsFixed(2)}',
                  AppColors.error,
                  Icons.arrow_downward,
                ).animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.1, duration: 500.ms, delay: 200.ms, curve: Curves.easeOutCubic),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Net Amount
              Expanded(
                child: _buildStatItem(
                  context,
                  'Net',
                  '${stats.netAmount >= 0 ? '+' : ''}\$${stats.netAmount.toStringAsFixed(2)}',
                  stats.netAmount >= 0 ? AppColors.success : AppColors.error,
                  stats.netAmount >= 0 ? Icons.trending_up : Icons.trending_down,
                ).animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.1, duration: 500.ms, delay: 300.ms, curve: Curves.easeOutCubic),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.spacing3),

          // Savings Rate
          if (stats.totalIncome > 0) ...[
            Row(
              children: [
                Icon(
                  stats.savingsRate >= 0.2 ? Icons.thumb_up : Icons.thumb_down,
                  size: AppDimensions.iconSm,
                  color: stats.savingsRate >= 0.2 ? AppColors.success : AppColors.warning,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, delay: 400.ms, curve: Curves.elasticOut),
                SizedBox(width: AppDimensions.spacing2),
                Text(
                  'Savings Rate: ${(stats.savingsRate * 100).toStringAsFixed(1)}%',
                  style: AppTypography.caption.copyWith(
                    color: stats.savingsRate >= 0.2 ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 450.ms)
                  .slideX(begin: 0.1, duration: 400.ms, delay: 450.ms, curve: Curves.easeOutCubic),
              ],
            ),
          ],

          // Transaction Count
          SizedBox(height: AppDimensions.spacing2),
          Text(
            '${stats.transactionCount} transactions',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate()
            .fadeIn(duration: 350.ms, delay: 300.ms)
            .slideY(begin: 0.05, duration: 400.ms, delay: 500.ms, curve: Curves.easeOut),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.05, duration: 250.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSm,
            color: color,
          ),
          SizedBox(height: AppDimensions.spacing1),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppDimensions.spacing1),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}