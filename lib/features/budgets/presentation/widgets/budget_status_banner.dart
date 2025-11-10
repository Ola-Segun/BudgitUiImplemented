import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../domain/entities/budget.dart' as budget_entity;

/// A status banner displaying budget health information with contextual messages.
/// Shows remaining amount, health status, and appropriate messaging.
class BudgetStatusBanner extends StatelessWidget {
  const BudgetStatusBanner({
    super.key,
    required this.remainingAmount,
    required this.health,
    this.showDot = true,
  });

  /// Remaining budget amount
  final double remainingAmount;

  /// Current budget health status
  final budget_entity.BudgetHealth health;

  /// Whether to show the status dot indicator
  final bool showDot;

  String _getStatusMessage() {
    if (remainingAmount < 0) {
      return 'Over budget by \$${(-remainingAmount).toStringAsFixed(0)}';
    } else if (remainingAmount < 20) {
      return 'Budget almost exhausted';
    } else {
      return 'You can Spend \$${remainingAmount.toStringAsFixed(0)} More Today';
    }
  }

  Color _getStatusColor() {
    switch (health) {
      case budget_entity.BudgetHealth.healthy:
        return AppColorsExtended.statusNormal;
      case budget_entity.BudgetHealth.warning:
        return AppColorsExtended.statusWarning;
      case budget_entity.BudgetHealth.critical:
        return AppColorsExtended.statusCritical;
      case budget_entity.BudgetHealth.overBudget:
        return AppColorsExtended.statusOverBudget;
    }
  }

  String _getStatusLabel() {
    switch (health) {
      case budget_entity.BudgetHealth.healthy:
        return 'Normal';
      case budget_entity.BudgetHealth.warning:
        return 'Warning';
      case budget_entity.BudgetHealth.critical:
        return 'Critical';
      case budget_entity.BudgetHealth.overBudget:
        return 'Over Budget';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColorsExtended.cardBgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _getStatusMessage(),
              style: AppTypographyExtended.statusMessage.copyWith(
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          if (showDot) const SizedBox(width: 12),
          if (showDot)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusLabel(),
                  style: AppTypographyExtended.statusMessage.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}