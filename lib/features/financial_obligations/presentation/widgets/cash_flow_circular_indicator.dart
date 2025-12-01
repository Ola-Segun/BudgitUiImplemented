import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';

/// Circular indicator showing net cash flow (income - bills)
class CashFlowCircularIndicator extends StatelessWidget {
  const CashFlowCircularIndicator({
    super.key,
    required this.monthlyIncome,
    required this.monthlyBills,
    this.size = 240,
    this.strokeWidth = 24,
  });

  final double monthlyIncome;
  final double monthlyBills;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final netCashFlow = monthlyIncome - monthlyBills;
    final billPercentage = monthlyIncome > 0 ? monthlyBills / monthlyIncome : 0.0;
    final isHealthy = netCashFlow > 0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Base circular indicator (reusing budget component)
        CircularBudgetIndicator(
          percentage: billPercentage.clamp(0.0, 1.0),
          spent: monthlyBills,
          total: monthlyIncome > 0 ? monthlyIncome : monthlyBills,
          size: size,
          strokeWidth: strokeWidth,
        ),

        // Center content - Net Cash Flow
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Net cash flow label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isHealthy
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHealthy
                      ? const Color(0xFF10B981).withValues(alpha: 0.3)
                      : const Color(0xFFEF4444).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isHealthy ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: isHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Net Flow',
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: isHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 400.ms, delay: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, delay: 600.ms),

            const SizedBox(height: 12),

            // Net amount
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: netCashFlow),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  NumberFormat.currency(symbol: isHealthy ? '+\$' : '-\$', decimalDigits: 0)
                      .format(value.abs()),
                  style: AppTypographyExtended.circularProgressPercentage.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: isHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            // Percentage of income saved/overspent
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: (netCashFlow / monthlyIncome).clamp(-1.0, 1.0)),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  '${(value * 100).abs().toInt()}% ${isHealthy ? 'saved' : 'over'}',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                );
              },
            ),
          ],
        ),

        // Status indicators around the circle
        _buildStatusIndicators(context),
      ],
    );
  }

  Widget _buildStatusIndicators(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Income indicator (top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _StatusPill(
                label: 'Income',
                amount: monthlyIncome,
                icon: Icons.arrow_downward,
                color: const Color(0xFF10B981),
              ).animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: -0.3, duration: 400.ms, delay: 200.ms, curve: Curves.elasticOut),
            ),
          ),

          // Bills indicator (bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _StatusPill(
                label: 'Bills',
                amount: monthlyBills,
                icon: Icons.arrow_upward,
                color: const Color(0xFFEF4444),
              ).animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.3, duration: 400.ms, delay: 400.ms, curve: Curves.elasticOut),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount),
                style: AppTypographyExtended.metricLabel.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}