import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';
import '../../domain/entities/financial_obligation.dart';

class FixedCashFlowStatsRow extends StatelessWidget {
  const FixedCashFlowStatsRow({
    super.key,
    required this.summary,
  });

  final FinancialObligationsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // CONSISTENT with budget implementation
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // CONSISTENT border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // CONSISTENT shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight( // FIXED: Prevents height overflow
        child: Row(
          children: [
            Expanded(
              child: _StatColumn(
                label: 'Monthly Bills',
                value: summary.monthlyBillTotal,
                icon: Icons.arrow_upward,
                color: ObligationsTheme.statusCritical,
                count: summary.totalBills,
              ).animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(
                  begin: 0.2,
                  duration: 400.ms,
                  delay: 100.ms,
                  curve: Curves.easeOutCubic, // CONSISTENT curve
                ),
            ),

                        Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.borderSubtle.withValues(alpha: 0.3),
                    AppColors.borderSubtle,
                    AppColors.borderSubtle.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _StatColumn(
                label: 'Net Cash Flow',
                value: summary.netCashFlow,
                icon: summary.netCashFlow >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: summary.netCashFlow >= 0
                    ? ObligationsTheme.statusNormal
                    : ObligationsTheme.statusCritical,
                isNet: true,
              ).animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(
                  begin: 0.2,
                  duration: 400.ms,
                  delay: 300.ms,
                  curve: Curves.easeOutCubic,
                ),
            ),

            // CONSISTENT divider styling
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.borderSubtle.withValues(alpha: 0.3),
                    AppColors.borderSubtle,
                    AppColors.borderSubtle.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _StatColumn(
                label: 'Monthly Income',
                value: summary.monthlyIncomeTotal,
                icon: Icons.arrow_downward,
                color: ObligationsTheme.statusNormal,
                count: summary.totalIncome,
              ).animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(
                  begin: 0.2,
                  duration: 400.ms,
                  delay: 200.ms,
                  curve: Curves.easeOutCubic,
                ),
            ),


          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8), // CONSISTENT spacing
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container - CONSISTENT with budget implementation
          Container(
            padding: const EdgeInsets.all(10), // INCREASED from 7
            decoration: BoxDecoration(
              gradient: LinearGradient( // ADDED gradient for consistency
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12), // INCREASED from 9
              boxShadow: [ // ADDED shadow
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: color), // INCREASED from 16
          ),
          const SizedBox(height: 12), // INCREASED from 8

          // Value - FIXED overflow with FittedBox
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: value.abs()),
            duration: const Duration(milliseconds: 1200), // CONSISTENT duration
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isNet && value >= 0
                      ? '+\$${NumberFormat('#,##0', 'en_US').format(animatedValue)}'
                      : isNet
                          ? '-\$${NumberFormat('#,##0', 'en_US').format(animatedValue)}'
                          : '\$${NumberFormat('#,##0', 'en_US').format(animatedValue)}',
                  style: AppTypographyExtended.statsValue.copyWith( // CONSISTENT typography
                    fontSize: 20, // INCREASED from 18
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              );
            },
          ),
          const SizedBox(height: 6), // INCREASED from 4

          // Label - FIXED overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTypographyExtended.statsLabel.copyWith( // CONSISTENT typography
                fontSize: 12, // INCREASED from 10
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),

          // Count badge - ENHANCED styling
          if (count != null) ...[
            const SizedBox(height: 6), // INCREASED from 4
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // INCREASED from 6,2
              decoration: BoxDecoration(
                gradient: LinearGradient( // ADDED gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(8), // INCREASED from 6
                border: Border.all( // ADDED border
                  color: color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$count ${count == 1 ? 'item' : 'items'}',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: color,
                    fontSize: 10, // INCREASED from 9
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}