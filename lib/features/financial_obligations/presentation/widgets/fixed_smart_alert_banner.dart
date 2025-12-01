import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
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
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
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
        message: 'Your bills exceed income by ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(summary.netCashFlow.abs())}. Consider reviewing your budget.',
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