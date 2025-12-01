import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/financial_obligation.dart';

/// Smart banner showing proactive alerts and warnings
class SmartAlertBanner extends StatelessWidget {
  const SmartAlertBanner({
    super.key,
    required this.summary,
  });

  final FinancialObligationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final alert = _determineAlert();
    if (alert == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            alert.color.withValues(alpha: 0.15),
            alert.color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: alert.isCritical
            ? [
                BoxShadow(
                  color: alert.color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Alert icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alert.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: alert.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              alert.icon,
              size: 24,
              color: alert.color,
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Alert content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: alert.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        alert.level.displayName,
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: alert.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (alert.subMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    alert.subMessage!,
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action button (optional)
          if (alert.actionLabel != null) ...[
            SizedBox(width: AppDimensions.spacing2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: alert.color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: alert.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                alert.actionLabel!,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: -0.1, duration: 400.ms, curve: Curves.easeOutCubic)
      .then()
      .shimmer(
        duration: 2000.ms,
        color: Colors.white.withValues(alpha: 0.3),
      );
  }

  _AlertData? _determineAlert() {
    // Critical: Overdue items
    if (summary.overdueCount > 0) {
      return _AlertData(
        level: AlertLevel.critical,
        icon: Icons.error_rounded,
        message: 'You have ${summary.overdueCount} overdue ${summary.overdueCount == 1 ? 'item' : 'items'}',
        subMessage: 'Action required to avoid late fees or missed income',
        actionLabel: 'Review',
        isCritical: true,
      );
    }

    // Warning: Due today
    if (summary.dueTodayCount > 0) {
      return _AlertData(
        level: AlertLevel.warning,
        icon: Icons.warning_amber_rounded,
        message: '${summary.dueTodayCount} ${summary.dueTodayCount == 1 ? 'item is' : 'items are'} due today',
        subMessage: 'Total amount: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(_getTodayTotal())}',
        actionLabel: 'View',
        isCritical: false,
      );
    }

    // Info: Negative cash flow
    if (summary.netCashFlow < 0) {
      return _AlertData(
        level: AlertLevel.info,
        icon: Icons.trending_down,
        message: 'Bills exceed income by ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(summary.netCashFlow.abs())}',
        subMessage: 'Consider reviewing your budget or increasing income',
        actionLabel: null,
        isCritical: false,
      );
    }

    // Success: All clear
    if (summary.overdueCount == 0 && summary.dueTodayCount == 0 && summary.netCashFlow > 0) {
      return _AlertData(
        level: AlertLevel.success,
        icon: Icons.check_circle_rounded,
        message: 'All obligations are on track',
        subMessage: 'Next payment due ${_getNextDueText()}',
        actionLabel: null,
        isCritical: false,
      );
    }

    return null;
  }

  double _getTodayTotal() {
    return summary.upcomingBills
        .where((b) => b.isDueToday)
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  String _getNextDueText() {
    final allUpcoming = [
      ...summary.upcomingBills,
      ...summary.upcomingIncome,
    ]..sort((a, b) => a.nextDate.compareTo(b.nextDate));

    if (allUpcoming.isEmpty) return 'None';

    final next = allUpcoming.first;
    if (next.daysUntilNext == 1) return 'tomorrow';
    return 'in ${next.daysUntilNext} days';
  }
}

class _AlertData {
  const _AlertData({
    required this.level,
    required this.icon,
    required this.message,
    this.subMessage,
    this.actionLabel,
    required this.isCritical,
  });

  final AlertLevel level;
  final IconData icon;
  final String message;
  final String? subMessage;
  final String? actionLabel;
  final bool isCritical;

  Color get color => level.color;
}

enum AlertLevel {
  critical,
  warning,
  info,
  success;

  String get displayName {
    switch (this) {
      case AlertLevel.critical:
        return 'CRITICAL';
      case AlertLevel.warning:
        return 'WARNING';
      case AlertLevel.info:
        return 'INFO';
      case AlertLevel.success:
        return 'ALL CLEAR';
    }
  }

  Color get color {
    switch (this) {
      case AlertLevel.critical:
        return const Color(0xFFDC2626); // Red-600
      case AlertLevel.warning:
        return const Color(0xFFEA580C); // Orange-600
      case AlertLevel.info:
        return const Color(0xFF3B82F6); // Blue-500
      case AlertLevel.success:
        return const Color(0xFF10B981); // Green-500
    }
  }
}