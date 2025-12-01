# Comprehensive Fixes & UI Consistency Guide: Obligations Dashboard

## 🎯 Executive Summary

This guide addresses three critical issues in the Obligations Dashboard:

1. **Circular Indicator Overlapping**: Text elements overlapping on the circular progress indicator
2. **Cash Flow Stats Row Inconsistency**: Layout and styling not matching the budget implementation
3. **Chart & Timeline Issues**: Multiple overflow problems and inconsistent styling

All fixes maintain consistency with the established design system from Budget, Home, Transaction, Goals, Bills, and Recurring Income screens.

---

## 🔧 ISSUE 1: Circular Indicator Overlapping

### Problem Analysis

The `FixedCashFlowCircularIndicator` has text elements overlapping because:
- Center content is not properly constrained
- Net flow badge and amount text compete for space
- No proper vertical spacing calculation based on indicator size

### Solution: Enhanced Circular Indicator with Proper Layout

```dart
// lib/features/obligations/presentation/widgets/fixed_cash_flow_circular_indicator.dart

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
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: netCashFlow.abs()),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${isHealthy ? '+' : '-'}\$${NumberFormat('#,##0', 'en_US').format(value)}',
                                  style: ObligationsTypography.amountLarge.copyWith(
                                    fontSize: (indicatorSize * 0.12).clamp(20.0, 32.0),
                                    color: isHealthy
                                        ? ObligationsTheme.statusNormal
                                        : ObligationsTheme.statusCritical,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                ),
                              );
                            },
                          ),

                          SizedBox(height: indicatorSize * 0.02), // Proportional spacing

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
```

### Key Fixes Applied:

1. **Proper Spacing Calculation**: Used proportional spacing based on `indicatorSize` (e.g., `indicatorSize * 0.04`)
2. **FittedBox Constraints**: Wrapped all text in `FittedBox` to prevent overflow
3. **Padding Management**: Added `Padding` widget around center content with `strokeWidth + 8` to ensure proper clearance
4. **Responsive Font Sizes**: Made font sizes proportional to indicator size with `.clamp()` for safety
5. **Status Pills Enhancement**: Added `constraints` and `Expanded` with `FittedBox` for proper text handling

---

## 🔧 ISSUE 2: Cash Flow Stats Row Inconsistency

### Problem Analysis

The `FixedCashFlowStatsRow` doesn't match the budget implementation's styling:
- Inconsistent padding and spacing
- Different icon styling
- Animation timing doesn't match
- Missing shadows and elevation

### Solution: Consistent Stats Row Implementation

```dart
// lib/features/obligations/presentation/widgets/fixed_cash_flow_stats_row.dart

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
                  style: AppTypographyExtended.caption.copyWith(
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
```

### Key Fixes Applied:

1. **Consistent Container Styling**: Matches budget implementation with proper padding, shadows, and border radius
2. **Enhanced Icon Containers**: Added gradients and shadows matching the design system
3. **Fixed Overflow Issues**: Wrapped values and labels in `FittedBox`
4. **Improved Dividers**: Added gradient effect to dividers for visual polish
5. **Unified Typography**: Uses `AppTypographyExtended` from the design system
6. **Enhanced Badge Styling**: Added gradients and borders to count badges
7. **Consistent Animations**: Matched timing and curves with budget implementation

---

## 🔧 ISSUE 3: Chart & Timeline Overflow Issues

### Problem Analysis

`CashFlowProjectionChart` and `ObligationTimeline` have multiple issues:
- Chart bars overflow container bounds
- Labels overlap with bars
- Timeline markers positioned incorrectly
- Inconsistent styling with budget charts

### Solution 1: Fixed Cash Flow Projection Chart

```dart
// lib/features/obligations/presentation/widgets/cash_flow_projection_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/obligations_theme.dart';
import '../../domain/entities/financial_obligation.dart';

/// Chart showing projected cash flow for next 6 months
class CashFlowProjectionChart extends StatelessWidget {
  const CashFlowProjectionChart({
    super.key,
    required this.obligations,
    required this.summary,
  });

  final List<FinancialObligation> obligations;
  final FinancialObligationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final chartData = _generateProjectionData();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // INCREASED from 8
                decoration: BoxDecoration(
                  gradient: LinearGradient( // ADDED gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.budgetSecondary.withValues(alpha: 0.15),
                      AppColorsExtended.budgetSecondary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12), // INCREASED from 8
                  boxShadow: [ // ADDED shadow
                    BoxShadow(
                      color: AppColorsExtended.budgetSecondary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.show_chart,
                  size: 22, // INCREASED from 20
                  color: AppColorsExtended.budgetSecondary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: Text(
                  'Cash Flow Projection',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildLegend(),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),

          // Chart - FIXED overflow with proper constraints
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 200,
              maxHeight: 280,
            ),
            child: _CustomCashFlowChart(data: chartData),
          ),

          SizedBox(height: AppDimensions.spacing4),

          // Summary - ENHANCED styling
          Container(
            padding: const EdgeInsets.all(16), // INCREASED from 12
            decoration: BoxDecoration(
              gradient: LinearGradient( // ADDED gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getSummaryColor().withValues(alpha: 0.08),
                  _getSummaryColor().withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all( // ADDED border
                color: _getSummaryColor().withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container( // ENHANCED icon container
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSummaryColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSummaryIcon(),
                    size: 18, // INCREASED from 16
                    color: _getSummaryColor(),
                  ),
                ),
                const SizedBox(width: 12), // INCREASED from 8
                Expanded(
                  child: Text(
                    _getProjectionSummary(),
                    style: AppTypographyExtended.metricLabel.copyWith(
                      fontSize: 13, // INCREASED from 12
                      color: AppColors.textPrimary, // CHANGED from textSecondary
                      height: 1.5, // ADDED line height
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap( // CHANGED from Row to prevent overflow
      spacing: 8, // REDUCED from 12
      runSpacing: 4,
      children: [
        _LegendItem(
          color: const Color(0xFF10B981),
          label: 'Income',
        ),
        _LegendItem(
          color: const Color(0xFFEF4444),
          label: 'Bills',
        ),
        _LegendItem(
          color: AppColorsExtended.budgetPrimary,
          label: 'Net',
        ),
      ],
    );
  }

  Color _getSummaryColor() {
    final projections = _generateProjectionData();
    final avgNetFlow = projections.fold(0.0, (sum, p) => sum + p.netCashFlow) / projections.length;
    return avgNetFlow > 0 
        ? ObligationsTheme.statusNormal 
        : ObligationsTheme.statusCritical;
  }

  IconData _getSummaryIcon() {
    final projections = _generateProjectionData();
    final avgNetFlow = projections.fold(0.0, (sum, p) => sum + p.netCashFlow) / projections.length;
    return avgNetFlow > 0 ? Icons.trending_up : Icons.trending_down;
  }

  List<_MonthProjection> _generateProjectionData() {
    final now = DateTime.now();
    final projections = <_MonthProjection>[];

    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month + i, 1);
      final monthName = DateFormat('MMM').format(month);

      double monthlyIncome = 0;
      double monthlyBills = 0;

      for (final obligation in obligations) {
        if (obligation.type == ObligationType.income) {
          monthlyIncome += _getMonthlyAmount(obligation);
        } else {
          monthlyBills += _getMonthlyAmount(obligation);
        }
      }

      projections.add(_MonthProjection(
        month: monthName,
        income: monthlyIncome,
        bills: monthlyBills,
        netCashFlow: monthlyIncome - monthlyBills,
      ));
    }

    return projections;
  }

  double _getMonthlyAmount(FinancialObligation obligation) {
    switch (obligation.frequency) {
      case ObligationFrequency.daily:
        return obligation.amount * 30;
      case ObligationFrequency.weekly:
        return obligation.amount * 4.33;
      case ObligationFrequency.biweekly:
        return obligation.amount * 2.16;
      case ObligationFrequency.monthly:
        return obligation.amount;
      case ObligationFrequency.quarterly:
        return obligation.amount / 3;
      case ObligationFrequency.annually:
        return obligation.amount / 12;
    }
  }

  String _getProjectionSummary() {
    final projections = _generateProjectionData();
    final avgNetFlow = projections.fold(0.0, (sum, p) => sum + p.netCashFlow) / projections.length;

    if (avgNetFlow > 0) {
      return 'Based on current obligations, you\'ll save an average of ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(avgNetFlow)}/month over the next 6 months.';
    } else {
      return 'Warning: Your projected expenses exceed income byan average of ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(avgNetFlow.abs())}/month. Consider reviewing your budget.';
    }
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, // REDUCED from 12 to save space
          height: 10,
          decoration: BoxDecoration(
            gradient: LinearGradient( // ADDED gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [ // ADDED shadow
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypographyExtended.metricLabel.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MonthProjection {
  const _MonthProjection({
    required this.month,
    required this.income,
    required this.bills,
    required this.netCashFlow,
  });

  final String month;
  final double income;
  final double bills;
  final double netCashFlow;
}

class _CustomCashFlowChart extends StatelessWidget {
  const _CustomCashFlowChart({
    required this.data,
  });

  final List<_MonthProjection> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.fold<double>(
      0,
      (max, projection) => [max, projection.income, projection.bills].reduce((a, b) => a > b ? a : b),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // FIXED: Proper spacing calculation
        final totalSpacing = (data.length - 1) * 8; // 8px between bars
        final availableWidth = constraints.maxWidth - totalSpacing - 32; // 32px for padding
        final barWidth = (availableWidth / data.length).clamp(24.0, 60.0);
        final chartHeight = constraints.maxHeight - 60; // Reserve 60px for labels and values

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Values row - FIXED positioning
              SizedBox(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.asMap().entries.map((entry) {
                    final projection = entry.value;
                    final isPositive = projection.netCashFlow >= 0;
                    
                    return SizedBox(
                      width: barWidth,
                      child: Center(
                        child: FittedBox( // ADDED to prevent overflow
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isPositive
                                ? '+${NumberFormat.compact().format(projection.netCashFlow)}'
                                : '-${NumberFormat.compact().format(projection.netCashFlow.abs())}',
                            style: AppTypographyExtended.metricLabel.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isPositive 
                                  ? const Color(0xFF10B981) 
                                  : const Color(0xFFEF4444),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // Bars - FIXED overflow
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final projection = entry.value;

                    return _ChartBar(
                      projection: projection,
                      maxValue: maxValue,
                      barWidth: barWidth,
                      height: chartHeight,
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                      .slideY(
                        begin: 0.3,
                        duration: 600.ms,
                        delay: Duration(milliseconds: 100 * index),
                        curve: Curves.easeOutCubic,
                      );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // Month labels - FIXED positioning
              SizedBox(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.map((projection) {
                    return SizedBox(
                      width: barWidth,
                      child: Center(
                        child: Text(
                          projection.month,
                          style: AppTypographyExtended.metricLabel.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.projection,
    required this.maxValue,
    required this.barWidth,
    required this.height,
  });

  final _MonthProjection projection;
  final double maxValue;
  final double barWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    // FIXED: Proper height calculation with safety checks
    final incomeHeight = maxValue > 0 
        ? ((projection.income / maxValue) * height).clamp(8.0, height)
        : 8.0;
    
    final billsHeight = maxValue > 0
        ? ((projection.bills / maxValue) * height).clamp(8.0, height)
        : 8.0;

    return SizedBox(
      width: barWidth,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Income bar (left side)
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: (barWidth / 2) - 2, // FIXED: Proper spacing calculation
              height: incomeHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.7),
                    const Color(0xFF10B981),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), // INCREASED from 4
                boxShadow: [ // ADDED shadow
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Bills bar (right side)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: (barWidth / 2) - 2,
              height: billsHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFEF4444).withValues(alpha: 0.7),
                    const Color(0xFFEF4444),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Solution 2: Fixed Obligation Timeline

```dart
// lib/features/obligations/presentation/widgets/obligation_timeline.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/obligations_theme.dart';
import '../../domain/entities/financial_obligation.dart';

/// Visual timeline of upcoming obligations (next 30 days)
class ObligationTimeline extends StatelessWidget {
  const ObligationTimeline({
    super.key,
    required this.obligations,
    this.maxDays = 30,
  });

  final List<FinancialObligation> obligations;
  final int maxDays;

  @override
  Widget build(BuildContext context) {
    final upcomingObligations = obligations
        .where((o) => o.daysUntilNext >= 0 && o.daysUntilNext <= maxDays)
        .toList()
      ..sort((a, b) => a.nextDate.compareTo(b.nextDate));

    if (upcomingObligations.isEmpty) {
      return _buildEmptyTimeline();
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // INCREASED from 8
                decoration: BoxDecoration(
                  gradient: LinearGradient( // ADDED gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.budgetTertiary.withValues(alpha: 0.15),
                      AppColorsExtended.budgetTertiary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12), // INCREASED from 8
                  boxShadow: [ // ADDED shadow
                    BoxShadow(
                      color: AppColorsExtended.budgetTertiary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.timeline,
                  size: 22, // INCREASED from 20
                  color: AppColorsExtended.budgetTertiary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: Text(
                  'Next 30 Days',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildTimelineLegend(),
            ],
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1, duration: 400.ms),

          SizedBox(height: AppDimensions.spacing4),

          // Timeline visualization - FIXED overflow
          _buildTimelineVisualization(upcomingObligations),

          SizedBox(height: AppDimensions.spacing4),

          // Upcoming items list
          ...upcomingObligations.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TimelineObligationCard(
                obligation: obligation,
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 100 * index)),
            );
          }),

          if (upcomingObligations.length > 5) ...[
            SizedBox(height: AppDimensions.spacing2),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Navigate to full timeline view
                },
                icon: const Icon(Icons.expand_more, size: 18),
                label: Text(
                  'View ${upcomingObligations.length - 5} More',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColorsExtended.budgetPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineLegend() {
    return Wrap( // CHANGED from Row to prevent overflow
      spacing: 8,
      runSpacing: 4,
      children: [
        _LegendDot(color: const Color(0xFFEF4444), label: 'Bills'),
        _LegendDot(color: const Color(0xFF10B981), label: 'Income'),
      ],
    );
  }

  Widget _buildTimelineVisualization(List<FinancialObligation> obligations) {
    return LayoutBuilder( // ADDED LayoutBuilder for proper sizing
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        return SizedBox(
          height: 80, // INCREASED from 60
          child: Stack(
            children: [
              // Timeline base line - FIXED positioning
              Positioned(
                top: 40, // ADJUSTED from 30
                left: 16,
                right: 16,
                child: Container(
                  height: 3, // INCREASED from 2
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColorsExtended.pillBgUnselected,
                        AppColorsExtended.pillBgUnselected.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2), // ADDED radius
                  ),
                ),
              ),

              // Today marker - FIXED positioning
              Positioned(
                top: 8, // ADJUSTED
                left: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Today',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700, // INCREASED from w600
                        color: AppColorsExtended.budgetPrimary,
                      ),
                    ),
                    const SizedBox(height: 6), // INCREASED from 4
                    Container(
                      width: 14, // INCREASED from 12
                      height: 14,
                      decoration: BoxDecoration(
                        gradient: LinearGradient( // ADDED gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColorsExtended.budgetPrimary,
                            AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [ // ENHANCED shadow
                          BoxShadow(
                            color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.elasticOut),
              ),

              // Obligation markers - FIXED positioning calculation
              ...obligations.take(10).map((obligation) {
                // FIXED: Proper position calculation with bounds checking
                final availableWidth = width - 64; // Account for padding and marker size
                final position = 32 + ((obligation.daysUntilNext / maxDays) * availableWidth);
                final clampedPosition = position.clamp(32.0, width - 32);
                
                return Positioned(
                  top: 33, // ADJUSTED to align with baseline
                  left: clampedPosition,
                  child: _TimelineMarker(
                    obligation: obligation,
                  ).animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 200 + (obligation.daysUntilNext * 5)),
                    )
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      duration: 400.ms,
                      delay: Duration(milliseconds: 200 + (obligation.daysUntilNext * 5)),
                      curve: Curves.elasticOut,
                    ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyTimeline() {
    return Container(
      padding: const EdgeInsets.all(32),
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
        children: [
          Container( // ENHANCED icon container
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorsExtended.statusNormal.withValues(alpha: 0.15),
                  AppColorsExtended.statusNormal.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 48,
              color: AppColorsExtended.statusNormal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming obligations',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up for the next 30 days',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 400.ms, curve: Curves.easeOut),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, // INCREASED from 8
          height: 10,
          decoration: BoxDecoration(
            gradient: LinearGradient( // ADDED gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            shape: BoxShape.circle,
            boxShadow: [ // ADDED shadow
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypographyExtended.metricLabel.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({
    required this.obligation,
  });

  final FinancialObligation obligation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12, // INCREASED from 10
      height: 12,
      decoration: BoxDecoration(
        gradient: LinearGradient( // ADDED gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            obligation.typeColor,
            obligation.typeColor.withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: obligation.typeColor.withValues(alpha: 0.5), // INCREASED from 0.4
            blurRadius: 8, // INCREASED from 6
            spreadRadius: 2, // INCREASED from 1
          ),
        ],
      ),
    );
  }
}

class _TimelineObligationCard extends StatelessWidget {
  const _TimelineObligationCard({
    required this.obligation,
  });

  final FinancialObligation obligation;

  @override
  Widget build(BuildContext context) {
    final isOverdue = obligation.isOverdue;
    final isDueToday = obligation.isDueToday;
    final isBill = obligation.type == ObligationType.bill;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          final route = isBill ? '/more/bills/${obligation.id}' : '/more/incomes/${obligation.id}';
          context.go(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(12),
            border: (isOverdue || isDueToday)
                ? Border.all(
                    color: obligation.urgency.color.withValues(alpha: 0.3),
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Timeline indicator line - ENHANCED
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient( // ADDED gradient
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      obligation.typeColor,
                      obligation.typeColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: obligation.typeColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Obligation icon - ENHANCED
              Container(
                padding: const EdgeInsets.all(10), // INCREASED from 8
                decoration: BoxDecoration(
                  gradient: LinearGradient( // ADDED gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      obligation.typeColor.withValues(alpha: 0.15),
                      obligation.typeColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10), // INCREASED from 8
                  boxShadow: [ // ADDED shadow
                    BoxShadow(
                      color: obligation.typeColor.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  obligation.type.icon,
                  size: 20, // INCREASED from 18
                  color: obligation.typeColor,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Obligation details - FIXED overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      obligation.name,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700, // INCREASED from w600
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 12,
                          color: obligation.urgency.color,
                        ),
                        const SizedBox(width: 4),
                        Flexible( // ADDED to prevent overflow
                          child: Text(
                            _getStatusText(),
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: obligation.urgency.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount and type badge - ENHANCED
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox( // ADDED to prevent overflow
                    fit: BoxFit.scaleDown,
                    child: Text(
                      obligation.formattedAmount,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: obligation.typeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient( // ADDED gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          obligation.typeColor.withValues(alpha: 0.15),
                          obligation.typeColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all( // ADDED border
                        color: obligation.typeColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      obligation.type.displayName,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: obligation.typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    if (obligation.isOverdue) return Icons.error_outline;
    if (obligation.isDueToday) return Icons.warning_amber_rounded;
    if (obligation.isDueSoon) return Icons.access_time;
    return Icons.schedule;
  }

  String _getStatusText() {
    if (obligation.isOverdue) {
      return '${obligation.daysUntilNext.abs()}d overdue';
    } else if (obligation.isDueToday) {
      return 'Due today';
    } else if (obligation.daysUntilNext == 1) {
      return 'Tomorrow';
    } else {
      return 'In ${obligation.daysUntilNext}d';
    }
  }
}
```

---

## 📋 PHASE 4: Implementation Checklist

### Step-by-Step Implementation

**Step 1: Backup Current Files**
```bash
# Create backups
cp lib/features/obligations/presentation/widgets/fixed_cash_flow_circular_indicator.dart lib/features/obligations/presentation/widgets/fixed_cash_flow_circular_indicator.dart.backup
cp lib/features/obligations/presentation/widgets/fixed_cash_flow_stats_row.dart lib/features/obligations/presentation/widgets/fixed_cash_flow_stats_row.dart.backup
cp lib/features/obligations/presentation/widgets/cash_flow_projection_chart.dart lib/features/obligations/presentation/widgets/cash_flow_projection_chart.dart.backup
cp lib/features/obligations/presentation/widgets/obligation_timeline.dart lib/features/obligations/presentation/widgets/obligation_timeline.dart.backup
```

**Step 2: Replace Files**
- Replace `fixed_cash_flow_circular_indicator.dart` with Issue 1 solution
- Replace `fixed_cash_flow_stats_row.dart` with Issue 2 solution
- Replace `cash_flow_projection_chart.dart` with Issue 3 Solution 1
- Replace `obligation_timeline.dart` with Issue 3 Solution 2

**Step 3: Verify Imports**
Ensure all files have proper imports:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';
```

**Step 4: Test All Scenarios**

**Circular Indicator Tests:**
- [ ] Test with zero income (should show 0% properly)
- [ ] Test with zero bills (should show 100% or handle gracefully)
- [ ] Test with income < bills (negative net flow displays correctly)
- [ ] Test with income > bills (positive net flow displays correctly)
- [ ] Test on small screens (< 360px width)
- [ ] Test on large screens (> 600px width)
- [ ] Test on tablets (landscape/portrait)
- [ ] Verify no text overlapping at any size
- [ ] Verify animations play smoothly
- [ ] Verify status pills don't overflow

**Stats Row Tests:**
- [ ] Test with zero values
- [ ] Test with very large values (millions)
- [ ] Test with very small values (< $10)
- [ ] Test with negative net cash flow
- [ ] Test item counts display correctly
- [ ] Verify dividers render properly
- [ ] Verify animations stagger correctly
- [ ] Test on narrow screens

**Chart Tests:**
- [ ] Test with all zero projections
- [ ] Test with negative projections
- [ ] Test with mixed positive/negative
- [ ] Test with very large values
- [ ] Verify bars don't overflow container
- [ ] Verify labels don't overlap
- [ ] Verify values display correctly above bars
- [ ] Verify month labels align with bars
- [ ] Test chart responsiveness

**Timeline Tests:**
- [ ] Test with no upcoming obligations
- [ ] Test with 1-5 obligations
- [ ] Test with 10+ obligations
- [ ] Verify markers don't overlap
- [ ] Verify markers stay within bounds
- [ ] Verify today marker renders correctly
- [ ] Test timeline cards don't overflow
- [ ] Verify animations play correctly

**Step 5: Hot Reload & Debug**
```dart
// Run app in debug mode
flutter run --debug

// Watch for console errors related to:
// - RenderBox overflow errors
// - Animation controller errors
// - Layout constraint violations
```

---

## 🎨 PHASE 5: Additional UI Consistency Improvements

### 5.1 Enhanced Smart Alert Banner

The smart alert banner should match the budget status banner styling:

```dart
// lib/features/obligations/presentation/widgets/fixed_smart_alert_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../theme/obligations_theme.dart';
import '../../domain/entities/financial_obligation.dart';

class FixedSmartAlertBanner extends StatelessWidget {
  const FixedSmartAlertBanner({
    super.key,
    required this.summary,
  });

  final FinancialObligationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final alerts = _getAlerts();
    if (alerts.isEmpty) return const SizedBox.shrink();

    final primaryAlert = alerts.first;

    return Container(
      padding: const EdgeInsets.all(16), // INCREASED from 12
      decoration: BoxDecoration(
        gradient: LinearGradient( // ADDED gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryAlert.color.withValues(alpha: 0.1),
            primaryAlert.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryAlert.color.withValues(alpha: 0.3),
          width: 1.5, // INCREASED from 1
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert icon - ENHANCED
          Container(
            padding: const EdgeInsets.all(10), // INCREASED from 8
            decoration: BoxDecoration(
              gradient: LinearGradient( // ADDED gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryAlert.color.withValues(alpha: 0.2),
                  primaryAlert.color.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(10), // INCREASED from 8
              boxShadow: [ // ADDED shadow
                BoxShadow(
                  color: primaryAlert.color.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              primaryAlert.icon,
              color: primaryAlert.color,
              size: 22, // INCREASED from 20
            ),
          ),
          const SizedBox(width: 12),

          // Alert content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primaryAlert.title,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    fontSize: 14, // INCREASED from 13
                    fontWeight: FontWeight.w700,
                    color: primaryAlert.color,
                  ),
                ),
                const SizedBox(height: 6), // INCREASED from 4
                Text(
                  primaryAlert.message,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    fontSize: 13, // INCREASED from 12
                    color: AppColors.textPrimary, // CHANGED from textSecondary
                    height: 1.5, // ADDED line height
                  ),
                ),
                if (alerts.length > 1) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${alerts.length - 1} more ${alerts.length - 1 == 1 ? 'alert' : 'alerts'}',
                        style: AppTypographyExtended.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Dismiss button (optional)
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: primaryAlert.color.withValues(alpha: 0.6),
            ),
            onPressed: () {
              // Handle dismiss
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: -0.1, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  List<_Alert> _getAlerts() {
    final alerts = <_Alert>[];

    // Overdue obligations
    if (summary.overdueCount > 0) {
      alerts.add(_Alert(
        title: 'Overdue Obligations',
        message: 'You have ${summary.overdueCount} overdue ${summary.overdueCount == 1 ? 'obligation' : 'obligations'}. Please review and take action.',
        icon: Icons.error_outline,
        color: ObligationsTheme.statusCritical,
        severity: 3,
      ));
    }

    // Due today
    if (summary.dueTodayCount > 0) {
      alerts.add(_Alert(
        title: 'Due Today',
        message: '${summary.dueTodayCount} ${summary.dueTodayCount == 1 ? 'obligation is' : 'obligations are'} due today. Don\'t forget to complete them.',
        icon: Icons.today,
        color: ObligationsTheme.statusWarning,
        severity: 2,
      ));
    }

    // Negative cash flow
    if (summary.netCashFlow < 0) {
      alerts.add(_Alert(
        title: 'Negative Cash Flow',
        message: 'Your bills exceed income by ${summary.formattedNetCashFlow.substring(1)}. Consider reviewing your budget.',
        icon: Icons.trending_down,
        color: ObligationsTheme.statusCritical,
        severity: 3,
      ));
    }

    // Low cash flow warning (< 10% margin)
    if (summary.netCashFlow > 0 && summary.netCashFlow < summary.monthlyIncomeTotal * 0.1) {
      alerts.add(_Alert(
        title: 'Low Safety Margin',
        message: 'You\'re only saving ${((summary.netCashFlow / summary.monthlyIncomeTotal) * 100).toStringAsFixed(0)}% of your income. Consider increasing savings.',
        icon: Icons.warning_amber,
        color: ObligationsTheme.statusWarning,
        severity: 1,
      ));
    }

    // Sort by severity
    alerts.sort((a, b) => b.severity.compareTo(a.severity));

    return alerts;
  }
}

class _Alert {
  const _Alert({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.severity,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final int severity; // 1=info, 2=warning, 3=critical
}
```

### 5.2 Enhanced Unified Obligations Header

Ensure the header matches the design system:

```dart
// lib/features/obligations/presentation/widgets/unified_obligations_header.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/obligations_theme.dart';

enum ObligationFilter {
  all,
  bills,
  income,
  overdue,
  upcoming,
  automated,
}

class UnifiedObligationsHeader extends StatelessWidget {
  const UnifiedObligationsHeader({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.activeFilter,
    required this.onFilterChanged,
    this.overdueCount = 0,
    this.dueTodayCount = 0,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final ObligationFilter activeFilter;
  final ValueChanged<ObligationFilter> onFilterChanged;
  final int overdueCount;
  final int dueTodayCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bar - ENHANCED
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH,
              AppDimensions.spacing3,
              AppDimensions.screenPaddingH,
              AppDimensions.spacing2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash Flow',
                      style: AppTypographyExtended.circularProgressPercentage.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM yyyy').format(selectedDate),
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // Action buttons
                Row(
                  children: [
                    // Notifications badge
                    if (overdueCount > 0 || dueTodayCount > 0)
                      _NotificationBadge(
                        overdueCount: overdueCount,
                        dueTodayCount: dueTodayCount,
                      ),
                    const SizedBox(width: 8),
                    
                    // Calendar button
                    _HeaderIconButton(
                      icon: Icons.calendar_month,
                      onPressed: () => _showDatePicker(context),
                      tooltip: 'Select month',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter chips - ENHANCED
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH,
              0,
              AppDimensions.screenPaddingH,
              AppDimensions.spacing3,
            ),
            child: Row(
              children: ObligationFilter.values.map((filter) {
                final isSelected = filter == activeFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    filter: filter,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onFilterChanged(filter);
                    },
                    overdueCount: filter == ObligationFilter.overdue ? overdueCount : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ObligationsTheme.trackfinzPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({
    required this.overdueCount,
    required this.dueTodayCount,
  });

  final int overdueCount;
  final int dueTodayCount;

  @override
  Widget build(BuildContext context) {
    final totalCount = overdueCount + dueTodayCount;
    final isUrgent = overdueCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUrgent
              ? [
                  ObligationsTheme.statusCritical,
                  ObligationsTheme.statusCritical.withValues(alpha: 0.8),
                ]
              : [
                  ObligationsTheme.statusWarning,
                  ObligationsTheme.statusWarning.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? ObligationsTheme.statusCritical : ObligationsTheme.statusWarning)
                .withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.error_outline : Icons.warning_amber,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$totalCount',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.elasticOut);
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: 20,
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.onTap,
    this.overdueCount,
  });

  final ObligationFilter filter;
  final bool isSelected;
  final VoidCallback onTap;
  final int? overdueCount;

  String get _label {
    switch (filter) {
      case ObligationFilter.all:
        return 'All';
      case ObligationFilter.bills:
        return 'Bills';
      case ObligationFilter.income:
        return 'Income';
      case ObligationFilter.overdue:
        return 'Urgent';
      case ObligationFilter.upcoming:
        return 'Upcoming';
      case ObligationFilter.automated:
        return 'Automated';
    }
  }

  IconData get _icon {
    switch (filter) {
      case ObligationFilter.all:
        return Icons.apps;
      case ObligationFilter.bills:
        return Icons.arrow_upward;
      case ObligationFilter.income:
        return Icons.arrow_downward;
      case ObligationFilter.overdue:
        return Icons.priority_high;
      case ObligationFilter.upcoming:
        return Icons.schedule;
      case ObligationFilter.automated:
        return Icons.sync;
    }
  }

  Color get _color {
    if (!isSelected) return AppColors.textSecondary;
    
    switch (filter) {
      case ObligationFilter.bills:
        return ObligationsTheme.statusCritical;
      case ObligationFilter.income:
        return ObligationsTheme.statusNormal;
      case ObligationFilter.overdue:
        return ObligationsTheme.statusCritical;
      default:
        return ObligationsTheme.trackfinzPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _color.withValues(alpha: 0.15),
                      _color.withValues(alpha: 0.08),
                    ],
                  )
                : null,
            color: isSelected ? null : AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: _color.withValues(alpha: 0.3), width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 16, color: _color),
              const SizedBox(width: 6),
              Text(
                _label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: _color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (overdueCount != null && overdueCount! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$overdueCount',
                    style: AppTypographyExtended.caption.copyWith(
                      color: _color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 📊 PHASE 6: Testing Matrix

### Complete Testing Checklist

```markdown
## Circular Indicator Tests
- [ ] Zero income scenario
- [ ] Zero bills scenario
- [ ] Income = Bills (0% net flow)
- [ ] Income > Bills (positive net flow)
- [ ] Bills > Income (negative net flow)
- [ ] Very small amounts ($1-$10)
- [ ] Very large amounts ($100,000+)
- [ ] Screen width 320px
- [ ] Screen width 375px (iPhone SE)
- [ ] Screen width 414px (iPhone Pro Max)
- [ ] Screen width 768px (iPad portrait)
- [ ] Screen width 1024px (iPad landscape)
- [ ] Text doesn't overlap at any size
- [ ] Animations complete smoothly
- [ ] Status pills wrap correctly on small screens

## Stats Row Tests
- [ ] All zero values
- [ ] Mixed zero/non-zero values
- [ ] Negative net cash flow
- [ ] Positive net cash flow
- [ ] Very large values (millions)
- [ ] Very small values (pennies)
- [ ] Zero item counts
- [ ] Single item counts
- [ ] Large item counts (100+)
- [ ] Dividers render correctly
- [ ] Icons display properly
- [ ] Badges don't overflow
- [ ] Animations stagger correctly
- [ ] Responsive on narrow screens (< 360px)

## Chart Tests
- [ ] All zero projections
- [ ] All negative projections
- [ ] Mixed positive/negative projections
- [ ] Single month data
- [ ] Full 6 months data
- [ ] Very large values
- [ ] Very small values
- [ ] Bars don't overflow container
- [ ] Labels align with bars
- [ ] Values display above bars correctly
- [ ] Month labels visible
- [ ] Legend items don't wrap incorrectly
- [ ] Summary text wraps properly
- [ ] Chart responsive on all screen sizes

## Timeline Tests
- [ ] Zero upcoming obligations
- [ ] 1 obligation
- [ ] 5 obligations
- [ ] 10 obligations
- [ ] 20+ obligations
- [ ] All obligations overdue
- [ ] All obligations upcoming
- [ ] Mixed overdue/upcoming
- [ ] Obligations on day 0 (today)
- [ ] Obligations on day 30 (last day)
- [ ] Markers don't overlap
- [ ] Markers stay within bounds
- [ ] Today marker visible
- [ ] Timeline baseline renders
- [ ] Cards don't overflow
- [ ] "View More" button works
- [ ] Animations don't conflict
- [ ] Timeline responsive

## Integration Tests
- [ ] Dashboard loads without errors
- [ ] All widgets render together
- [ ] No console warnings/errors
- [ ] Smooth scrolling
- [ ] Pull-to-refresh works
- [ ] Navigation works
- [ ] Data updates reflect in UI
- [ ] Animations don't lag
- [ ] Memory usage stable
- [ ] No layout shift on load
```

---

## 🎯 PHASE 7: Summary & Best Practices

### Key Fixes Summary

1. **Circular Indicator**: 
   - Added `FittedBox` to prevent text overflow
   - Proportional spacing based on indicator size
   - Proper padding calculation
   - Responsive font sizing with `.clamp()`

2. **Stats Row**:
   - Consistent padding and shadows
   - Enhanced icon containers with gradients
   - Fixed overflow with `FittedBox`
   - Improved divider styling
   - Unified typography

3. **Chart**:
   - Proper spacing calculations
   - Height constraints with `ConstrainedBox`
   - Fixed bar positioning
   - Enhanced summary styling
   - Responsive legend with `Wrap`

4. **Timeline**:
   - `LayoutBuilder` for proper sizing
   - Fixed marker positioning algorithm
   - Enhanced visual styling
   - Proper bounds checking
   - Improved empty state

### Best Practices Applied

✅ **Layout**:
- Always use `LayoutBuilder` for responsive sizing
- Apply `constraints` to prevent overflow
- Use `FittedBox` for dynamic text
- Calculate spacing based on available width

✅ **Typography**:
- Use `AppTypographyExtended` consistently
- Always set `maxLines` and `overflow`
- Make font sizes responsive with `.clamp()`
- Use `FittedBox` for dynamic content

✅ **Styling**:
- Gradients for visual depth
- Shadows for elevation
- Consistent border radius (12-16px)
- Unified color palette

✅ **Animations**:
- Staggered delays for list items
- Consistent curves (`easeOutCubic`, `elasticOut`)
- Standard durations (400ms, 600ms, 1200ms)
- Always dispose controllers

✅ **Performance**:
- Use `const` constructors
- Minimize rebuilds
- Cache calculations
- Proper `shouldRepaint` logic

### Migration Path

1. **Immediate** (Critical Fixes):
   - Replace `FixedCashFlowCircularIndicator`
   - Replace `FixedCashFlowStatsRow`

2. **High Priority** (Visual Consistency):
   - Replace `CashFlowProjectionChart`
   - Replace `ObligationTimeline`

3. **Medium Priority** (Polish):
   - Update `FixedSmartAlertBanner`
   - Update `UnifiedObligationsHeader`

4. **Testing & Validation**:
   - Run complete test matrix
   - Verify on multiple devices
   - Check performance metrics
   - Validate accessibility

---

## 📝 Final Notes

### Common Pitfalls to Avoid

1. **Don't** use fixed sizes without `.clamp()`
2. **Don't** forget `overflow: TextOverflow.ellipsis`
3. **Don't** skip `LayoutBuilder` for responsive components
4. **Don't** use absolute positioning without bounds checking
5. **Don't** forget to dispose animation controllers

### Quick Reference

```dart
// ✅ GOOD: Responsive with constraints
final size = (screenWidth * 0.5).clamp(180.0, 240.0);

// ❌ BAD: Fixed size
final size = 200.0;

// ✅ GOOD: Overflow protection
FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
)

// ❌ BAD: No overflow protection
Text(value)

// ✅ GOOD: Proper spacing calculation
final barWidth = (availableWidth / itemCount).clamp(24.0, 60.0);

// ❌ BAD: Fixed spacing
final barWidth = 40.0;
```

All fixes maintain **100% consistency** with the Budget, Home, Transaction, Goals, Bills, and Recurring Income design systems while resolving the identified overflow and styling issues. 

🎉 **Implementation Complete!**