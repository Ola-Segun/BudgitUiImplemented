import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bill status banner showing financial health and alerts
class EnhancedBillStatusBanner extends StatelessWidget {
  const EnhancedBillStatusBanner({
    super.key,
    required this.overdueCount,
    required this.dueThisMonth,
    required this.paidThisMonth,
    required this.totalMonthly,
    required this.unpaidAmount,
  });

  final int overdueCount;
  final int dueThisMonth;
  final int paidThisMonth;
  final double totalMonthly;
  final double unpaidAmount;

  String _getStatusMessage() {
    if (overdueCount > 0) {
      return 'You have $overdueCount overdue bill${overdueCount > 1 ? 's' : ''} totaling \$${unpaidAmount.toStringAsFixed(2)}';
    } else if (dueThisMonth > paidThisMonth) {
      final remaining = dueThisMonth - paidThisMonth;
      return '$remaining bill${remaining > 1 ? 's' : ''} remaining this month';
    } else if (paidThisMonth == dueThisMonth && dueThisMonth > 0) {
      return 'All bills paid for this month! 🎉';
    } else {
      return 'No bills due this month';
    }
  }

  Color _getStatusColor() {
    if (overdueCount > 0) return BillsThemeExtended.billStatusOverdue;
    if (dueThisMonth > paidThisMonth) return BillsThemeExtended.billStatusDueSoon;
    if (paidThisMonth == dueThisMonth && dueThisMonth > 0) return BillsThemeExtended.billStatusNormal;
    return AppColors.primary;
  }

  String _getStatusLabel() {
    if (overdueCount > 0) return 'Overdue';
    if (dueThisMonth > paidThisMonth) return 'Pending';
    if (paidThisMonth == dueThisMonth && dueThisMonth > 0) return 'Complete';
    return 'No Bills';
  }

  IconData _getStatusIcon() {
    if (overdueCount > 0) return Icons.warning_amber_rounded;
    if (dueThisMonth > paidThisMonth) return Icons.schedule;
    if (paidThisMonth == dueThisMonth && dueThisMonth > 0) return Icons.check_circle;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isUrgent = overdueCount > 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BillsThemeExtended.billBannerBg,
        borderRadius: BillsThemeExtended.billCardRadius,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: isUrgent ? [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BillsThemeExtended.billChipRadius,
            ),
            child: Icon(
              _getStatusIcon(),
              size: 18,
              color: statusColor,
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Status content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: BillsThemeExtended.billStatusText.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Status message
                Text(
                  _getStatusMessage(),
                  style: AppTypographyExtended.statusMessage.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                // Progress indicator for this month
                if (dueThisMonth > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: paidThisMonth / dueThisMonth,
                          backgroundColor: AppColors.borderSubtle,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          borderRadius: BillsThemeExtended.billChipRadius,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$paidThisMonth/$dueThisMonth',
                        style: BillsThemeExtended.billStatusText.copyWith(
                          color: statusColor,
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

          // Amount display (if applicable)
          if (totalMonthly > 0) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${totalMonthly.toStringAsFixed(0)}',
                  style: BillsThemeExtended.billAmount.copyWith(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'this month',
                  style: BillsThemeExtended.billSubtitle.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: BillsThemeExtended.billAnimationNormal)
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, curve: BillsThemeExtended.billAnimationCurve);
  }
}