import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/bill.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bill card with urgency indicators and animations
class EnhancedBillCard extends ConsumerWidget {
  const EnhancedBillCard({
    super.key,
    required this.bill,
    this.showDateLabel = false,
  });

  final Bill bill;
  final bool showDateLabel;

  bool get _isSubscription => bill is Subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urgencyColor = _getUrgencyColor();
    final isOverdue = bill.isOverdue;

    return Container(
      margin: EdgeInsets.all(BillsThemeExtended.billCardMargin),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (context.mounted) {
              context.go('/more/bills/${bill.id}');
            }
          },
          borderRadius: BillsThemeExtended.billCardRadius,
          child: Container(
            padding: EdgeInsets.all(BillsThemeExtended.billCardPadding),
            decoration: BoxDecoration(
              color: BillsThemeExtended.billCardBg,
              borderRadius: BillsThemeExtended.billCardRadius,
              border: Border.all(
                color: _isSubscription
                    ? BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.3)
                    : (isOverdue
                        ? urgencyColor.withValues(alpha: 0.3)
                        : BillsThemeExtended.billCardBorder),
                width: _isSubscription ? 2 : (isOverdue ? 2 : 1),
              ),
              boxShadow: BillsThemeExtended.billCardShadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with urgency indicator
                Row(
                  children: [
                    // Urgency indicator
                    Container(
                      width: BillsThemeExtended.billStatusIndicatorSize,
                      height: BillsThemeExtended.billStatusIndicatorSize,
                      decoration: BoxDecoration(
                        color: urgencyColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: urgencyColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing2),

                    // Bill name
                    Expanded(
                      child: Row(
                        children: [
                          if (_isSubscription) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1),
                                borderRadius: BillsThemeExtended.billChipRadius,
                                border: Border.all(
                                  color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'SUB',
                                style: BillsThemeExtended.billStatusText.copyWith(
                                  color: BillsThemeExtended.billStatsPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              bill.name,
                              style: BillsThemeExtended.billTitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount and Auto-Pay Indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.amount),
                          style: BillsThemeExtended.billAmount.copyWith(
                            color: urgencyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (bill.isAutoPay) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BillsThemeExtended.billUrgencyNormal.withValues(alpha: 0.1),
                              borderRadius: BillsThemeExtended.billChipRadius,
                              border: Border.all(
                                color: BillsThemeExtended.billUrgencyNormal.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.autorenew,
                                  size: 12,
                                  color: BillsThemeExtended.billUrgencyNormal,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Auto',
                                  style: BillsThemeExtended.billStatusText.copyWith(
                                    color: BillsThemeExtended.billUrgencyNormal,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                SizedBox(height: AppDimensions.spacing2),

                // Status and due date
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: urgencyColor.withValues(alpha: 0.1),
                        borderRadius: BillsThemeExtended.billChipRadius,
                      ),
                      child: Text(
                        _getStatusText(),
                        style: BillsThemeExtended.billStatusText.copyWith(
                          color: urgencyColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Due date
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 14,
                          color: urgencyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getDueDateText(),
                          style: BillsThemeExtended.billSubtitle.copyWith(
                            color: urgencyColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Progress bar for paid bills
                if (bill.totalPaid > 0) ...[
                  SizedBox(height: AppDimensions.spacing3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Progress',
                            style: BillsThemeExtended.billSubtitle.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.totalPaid)} / ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.amount)}',
                            style: BillsThemeExtended.billAmountSmall.copyWith(
                              color: urgencyColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: (bill.totalPaid / bill.amount).clamp(0.0, 1.0),
                        backgroundColor: AppColors.borderSubtle,
                        valueColor: AlwaysStoppedAnimation<Color>(urgencyColor),
                        borderRadius: BillsThemeExtended.billChipRadius,
                      ),
                    ],
                  ),
                ],

                // Account link indicator
                if (bill.accountId != null) ...[
                  SizedBox(height: AppDimensions.spacing2),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 14,
                        color: BillsThemeExtended.billStatsSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Linked to account',
                        style: BillsThemeExtended.billSubtitle.copyWith(
                          color: BillsThemeExtended.billStatsSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: BillsThemeExtended.billAnimationNormal)
      .slideX(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, curve: BillsThemeExtended.billAnimationCurve);
  }

  Color _getUrgencyColor() {
    if (bill.isOverdue) return BillsThemeExtended.billUrgencyOverdue;
    if (bill.isDueToday) return BillsThemeExtended.billUrgencyDueToday;
    if (bill.isDueSoon) return BillsThemeExtended.billUrgencyDueSoon;
    return BillsThemeExtended.billUrgencyNormal;
  }

  String _getStatusText() {
    if (bill.isPaid) return 'Paid';
    if (bill.isOverdue) return 'Overdue';
    if (bill.isDueToday) return 'Due Today';
    if (bill.isDueSoon) return 'Due Soon';
    return 'Upcoming';
  }

  IconData _getStatusIcon() {
    if (bill.isPaid) return Icons.check_circle;
    if (bill.isOverdue) return Icons.warning_amber_rounded;
    if (bill.isDueToday) return Icons.today;
    if (bill.isDueSoon) return Icons.schedule;
    return Icons.event;
  }

  String _getDueDateText() {
    final daysUntilDue = bill.daysUntilDue;

    if (bill.isPaid) return 'Paid';
    if (daysUntilDue == 0) return 'Today';
    if (daysUntilDue == 1) return 'Tomorrow';
    if (daysUntilDue == -1) return 'Yesterday';
    if (daysUntilDue < 0) return '${daysUntilDue.abs()} days ago';
    return 'In $daysUntilDue days';
  }
}