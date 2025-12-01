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
      return 'Warning: Your projected expenses exceed income by an average of ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(avgNetFlow.abs())}/month. Consider reviewing your budget.';
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