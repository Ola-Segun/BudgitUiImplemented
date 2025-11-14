import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';

/// A three-column stats row displaying allotted, used, and remaining budget amounts.
/// Shows animated counters with color-coded values and separators.
/// Now includes dynamic responsiveness to total active budget costs.
class BudgetStatsRow extends StatelessWidget {
  const BudgetStatsRow({
    super.key,
    required this.allotted,
    required this.used,
    required this.remaining,
    this.totalActiveCosts,
  });

  /// Total allotted budget amount
  final double allotted;

  /// Amount used/spent
  final double used;

  /// Remaining budget amount
  final double remaining;

  /// Total active budget costs for enhanced responsiveness
  final double? totalActiveCosts;

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic colors based on total active costs if provided
    final usageRate = allotted > 0 ? used / allotted : 0.0;
    final isOverBudget = totalActiveCosts != null && totalActiveCosts! > allotted * 0.9;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsExtended.cardBgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: isOverBudget ? Border.all(
          color: AppColorsExtended.statusCritical.withValues(alpha: 0.3),
          width: 1,
        ) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _StatColumn(
              label: 'Allotted',
              value: allotted,
              color: const Color(0xFF6B7280),
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatColumn(
              label: 'Used',
              value: used,
              color: usageRate > 0.9 ? AppColorsExtended.statusCritical : AppColorsExtended.statusWarning,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatColumn(
              label: 'Remaining',
              value: remaining,
              color: remaining < 0 ? AppColorsExtended.statusCritical : AppColorsExtended.statusNormal,
            ),
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
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypographyExtended.statsLabel,
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(animatedValue),
              style: AppTypographyExtended.statsValue.copyWith(
                color: color,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE2E8F0),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}