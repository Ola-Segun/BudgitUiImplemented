import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';

class FixedCashFlowCircularIndicator extends StatelessWidget {
  const FixedCashFlowCircularIndicator({
    super.key,
    required this.monthlyIncome,
    required this.monthlyBills,
  });

  final double monthlyIncome;
  final double monthlyBills;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing to prevent overflow
    final indicatorSize = (screenWidth * 0.55).clamp(180.0, 240.0);
    final strokeWidth = (indicatorSize * 0.1).clamp(16.0, 24.0);

    final netCashFlow = monthlyIncome - monthlyBills;
    final billPercentage = monthlyIncome > 0
        ? (monthlyBills / monthlyIncome).clamp(0.0, 1.0)
        : 0.0;
    final isHealthy = netCashFlow > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular indicator
              SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base circular indicator
                    CircularBudgetIndicator(
                      percentage: billPercentage,
                      spent: monthlyBills,
                      total: monthlyIncome > 0 ? monthlyIncome : monthlyBills,
                      size: indicatorSize,
                      strokeWidth: strokeWidth,
                    ),

                    // Center content - FIXED LAYOUT
                    Padding(
                      padding: EdgeInsets.all(strokeWidth + 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Net flow label - CONSTRAINED
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isHealthy
                                    ? ObligationsTheme.statusNormal.withValues(alpha: 0.1)
                                    : ObligationsTheme.statusCritical.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isHealthy
                                      ? ObligationsTheme.statusNormal.withValues(alpha: 0.3)
                                      : ObligationsTheme.statusCritical.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isHealthy ? Icons.trending_up : Icons.trending_down,
                                    size: 10,
                                    color: isHealthy
                                        ? ObligationsTheme.statusNormal
                                        : ObligationsTheme.statusCritical,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Net Flow',
                                    style: ObligationsTypography.caption.copyWith(
                                      color: isHealthy
                                          ? ObligationsTheme.statusNormal
                                          : ObligationsTheme.statusCritical,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate()
                              .fadeIn(duration: 400.ms, delay: 600.ms)
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                duration: 400.ms,
                                delay: 600.ms,
                              ),
                          ),

                          SizedBox(height: indicatorSize * 0.04), // Proportional spacing

                          // Net amount - CONSTRAINED & RESPONSIVE
                          // TweenAnimationBuilder<double>(
                          //   tween: Tween(begin: 0.0, end: netCashFlow.abs()),
                          //   duration: const Duration(milliseconds: 1200),
                          //   curve: Curves.easeOutCubic,
                          //   builder: (context, value, child) {
                          //     return FittedBox(
                          //       fit: BoxFit.scaleDown,
                          //       child: Text(
                          //         '${isHealthy ? '+' : '-'}\$${NumberFormat('#,##0', 'en_US').format(value)}',
                          //         style: ObligationsTypography.amountLarge.copyWith(
                          //           fontSize: (indicatorSize * 0.12).clamp(20.0, 32.0),
                          //           color: isHealthy
                          //               ? ObligationsTheme.statusNormal
                          //               : ObligationsTheme.statusCritical,
                          //         ),
                          //         textAlign: TextAlign.center,
                          //         maxLines: 1,
                          //       ),
                          //     );
                          //   },
                          // ),

                          SizedBox(height: indicatorSize * 0.34), // Proportional spacing

                          // Percentage saved/over - CONSTRAINED
                          if (monthlyIncome > 0)
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0.0,
                                end: (netCashFlow / monthlyIncome).abs().clamp(0.0, 1.0),
                              ),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${(value * 100).toInt()}% ${isHealthy ? 'saved' : 'over'}',
                                    style: ObligationsTypography.bodySmall.copyWith(
                                      color: ObligationsTheme.textSecondary,
                                      fontSize: (indicatorSize * 0.05).clamp(10.0, 14.0),
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status pills - Income and Bills
              _buildStatusPills(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusPills() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // Income pill
        _StatusPill(
          label: 'Income',
          amount: monthlyIncome,
          icon: Icons.arrow_downward,
          color: ObligationsTheme.statusNormal,
        ).animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .slideY(
            begin: 0.3,
            duration: 400.ms,
            delay: 200.ms,
            curve: Curves.elasticOut,
          ),

        // Bills pill
        _StatusPill(
          label: 'Bills',
          amount: monthlyBills,
          icon: Icons.arrow_upward,
          color: ObligationsTheme.statusCritical,
        ).animate()
          .fadeIn(duration: 400.ms, delay: 400.ms)
          .slideY(
            begin: 0.3,
            duration: 400.ms,
            delay: 400.ms,
            curve: Curves.elasticOut,
          ),
      ],
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
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 160,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: ObligationsTypography.caption.copyWith(
                    color: ObligationsTheme.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount),
                    style: ObligationsTypography.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}