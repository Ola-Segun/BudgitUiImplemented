// lib/features/transactions/presentation/widgets/enhanced_transaction_stats_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../states/transaction_state.dart';

class EnhancedTransactionStatsCard extends StatelessWidget {
  const EnhancedTransactionStatsCard({
    super.key,
    required this.stats,
  });

  final TransactionStats stats;

  @override
  Widget build(BuildContext context) {
    final savingsRate = stats.totalIncome > 0
        ? (stats.totalIncome - stats.totalExpenses) / stats.totalIncome
        : 0.0;

    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.budgetPrimary,
            AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                'This Month',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1, duration: 400.ms),

          SizedBox(height: AppDimensions.spacing4),

          // Main Stats Row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Income',
                  amount: stats.totalIncome,
                  icon: Icons.arrow_downward,
                  color: Colors.white,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 100.ms),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Expenses',
                  amount: stats.totalExpenses,
                  icon: Icons.arrow_upward,
                  color: Colors.white,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 200.ms),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.spacing4),

          // Savings Rate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      savingsRate > 0 ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: AppDimensions.spacing2),
                    Text(
                      'Savings Rate',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: savingsRate),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '${(value * 100).toInt()}%',
                      style: AppTypographyExtended.statsValue.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 300.ms),

          SizedBox(height: AppDimensions.spacing3),

          // Transaction Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Transactions',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stats.transactionCount}',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: 400.ms, delay: 400.ms),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: color.withValues(alpha: 0.8),
            ),
            SizedBox(width: AppDimensions.spacing1),
            Text(
              label,
              style: AppTypographyExtended.metricLabel.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing2),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: amount),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value),
              style: AppTypographyExtended.statsValue.copyWith(
                fontSize: 22,
                color: color,
              ),
            );
          },
        ),
      ],
    );
  }
}