import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/financial_obligation.dart';

/// Three-column stats showing bills, income, and net cash flow
class CashFlowStatsRow extends StatelessWidget {
  const CashFlowStatsRow({
    super.key,
    required this.summary,
  });

  final FinancialObligationsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
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
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              label: 'Monthly Bills',
              value: summary.monthlyBillTotal,
              icon: Icons.arrow_upward,
              color: const Color(0xFFEF4444),
              count: summary.totalBills,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.2, duration: 400.ms, delay: 100.ms),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.borderSubtle,
          ),
          Expanded(
            child: _StatColumn(
              label: 'Monthly Income',
              value: summary.monthlyIncomeTotal,
              icon: Icons.arrow_downward,
              color: const Color(0xFF10B981),
              count: summary.totalIncome,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, duration: 400.ms, delay: 200.ms),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.borderSubtle,
          ),
          Expanded(
            child: _StatColumn(
              label: 'Net Cash Flow',
              value: summary.netCashFlow,
              icon: summary.netCashFlow >= 0 ? Icons.trending_up : Icons.trending_down,
              color: summary.netCashFlow >= 0
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              isNet: true,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(begin: 0.2, duration: 400.ms, delay: 300.ms),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.count,
    this.isNet = false,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final int? count;
  final bool isNet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        SizedBox(height: AppDimensions.spacing2),

        // Value
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Text(
              isNet && value >= 0
                  ? NumberFormat.currency(symbol: '+\$', decimalDigits: 0).format(animatedValue)
                  : NumberFormat.currency(symbol: isNet ? '-\$' : '\$', decimalDigits: 0).format(animatedValue.abs()),
              style: AppTypographyExtended.statsValue.copyWith(
                fontSize: 20,
                color: color,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
        const SizedBox(height: 4),

        // Label
        Text(
          label,
          style: AppTypographyExtended.statsLabel.copyWith(
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Count badge (if provided)
        if (count != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}