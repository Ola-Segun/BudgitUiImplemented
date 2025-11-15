import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../bills/domain/entities/bill.dart';
import '../../../recurring_incomes/domain/entities/recurring_income.dart';

class EnhancedUpcomingPaymentsWidget extends StatelessWidget {
  const EnhancedUpcomingPaymentsWidget({
    super.key,
    required this.upcomingBills,
    required this.upcomingIncomes,
    this.onBillPaymentPressed,
    this.onIncomeReceiptPressed,
    this.onBillDetailPressed,
    this.onIncomeDetailPressed,
  });

  final List<Bill> upcomingBills;
  final List<RecurringIncomeStatus> upcomingIncomes;
  final void Function(Bill bill)? onBillPaymentPressed;
  final void Function(RecurringIncomeStatus incomeStatus)? onIncomeReceiptPressed;
  final void Function(Bill bill)? onBillDetailPressed;
  final void Function(RecurringIncomeStatus incomeStatus)? onIncomeDetailPressed;

  @override
  Widget build(BuildContext context) {
    final combinedItems = _combineAndSortItems();

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsExtended.budgetTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule,
                  size: 20,
                  color: AppColorsExtended.budgetTertiary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  'Upcoming',
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

          if (combinedItems.isEmpty)
            _buildEmptyState()
          else
            ...combinedItems.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < combinedItems.length - 1 ? 8 : 0,
                ),
                child: item.isBill
                    ? _EnhancedBillCard(
                        bill: item.bill!,
                        onPaymentPressed: onBillPaymentPressed != null
                            ? () => onBillPaymentPressed!(item.bill!)
                            : null,
                        onDetailPressed: onBillDetailPressed != null
                            ? () => onBillDetailPressed!(item.bill!)
                            : null,
                      )
                    : _EnhancedIncomeCard(
                        incomeStatus: item.incomeStatus!,
                        onReceiptPressed: onIncomeReceiptPressed != null
                            ? () => onIncomeReceiptPressed!(item.incomeStatus!)
                            : null,
                        onDetailPressed: onIncomeDetailPressed != null
                            ? () => onIncomeDetailPressed!(item.incomeStatus!)
                            : null,
                      ),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * index))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 50 * index));
            }),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final totalBills = upcomingBills.length;
    final totalIncomes = upcomingIncomes.length;
    final totalAmount = _calculateTotalMonthlyAmount();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(
          color: AppColorsExtended.statusCritical,
          label: 'Bills',
          count: totalBills,
        ),
        const SizedBox(width: 12),
        _LegendItem(
          color: AppColorsExtended.statusNormal,
          label: 'Income',
          count: totalIncomes,
        ),
        if (totalAmount > 0) ...[
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalAmount)}/mo',
              style: AppTypographyExtended.metricLabel.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColorsExtended.budgetPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming payments',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add recurring incomes and bills to see upcoming payments here',
            style: AppTypographyExtended.metricLabel.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  // Navigate to bills dashboard
                  // This will be handled by parent widget
                },
                icon: Icon(
                  Icons.receipt,
                  size: 16,
                  color: AppColorsExtended.statusCritical,
                ),
                label: Text(
                  'Add Bills',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    fontSize: 12,
                    color: AppColorsExtended.statusCritical,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  // Navigate to incomes dashboard
                  // This will be handled by parent widget
                },
                icon: Icon(
                  Icons.arrow_downward,
                  size: 16,
                  color: AppColorsExtended.statusNormal,
                ),
                label: Text(
                  'Add Income',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    fontSize: 12,
                    color: AppColorsExtended.statusNormal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_CombinedItem> _combineAndSortItems() {
    final items = <_CombinedItem>[];

    for (final bill in upcomingBills) {
      items.add(_CombinedItem(
        date: bill.calculatedNextDueDate,
        isBill: true,
        bill: bill,
      ));
    }

    for (final incomeStatus in upcomingIncomes) {
      items.add(_CombinedItem(
        date: incomeStatus.income.nextExpectedDate ?? DateTime.now(),
        isBill: false,
        incomeStatus: incomeStatus,
      ));
    }

    items.sort((a, b) {
      final aUrgency = _getItemUrgency(a);
      final bUrgency = _getItemUrgency(b);
      final urgencyComparison = bUrgency.index.compareTo(aUrgency.index);
      if (urgencyComparison != 0) return urgencyComparison;
      return a.date.compareTo(b.date);
    });

    return items;
  }

  double _calculateTotalMonthlyAmount() {
    double total = 0.0;

    // Add bill amounts (only for upcoming bills, not paid ones)
    for (final bill in upcomingBills) {
      if (!bill.isPaid) {
        total += bill.amount;
      }
    }

    // Add income amounts (only for expected incomes, not received ones)
    for (final incomeStatus in upcomingIncomes) {
      if (!incomeStatus.income.hasIncomeHistory ||
          incomeStatus.income.incomeHistory.isEmpty ||
          incomeStatus.isOverdue ||
          incomeStatus.isExpectedToday ||
          incomeStatus.isExpectedSoon) {
        total += incomeStatus.income.amount;
      }
    }

    return total;
  }

  _ItemUrgency _getItemUrgency(_CombinedItem item) {
    if (item.isBill) {
      final bill = item.bill!;
      if (bill.isOverdue) return _ItemUrgency.overdue;
      if (bill.isDueToday) return _ItemUrgency.dueToday;
      if (bill.isDueSoon) return _ItemUrgency.dueSoon;
      return _ItemUrgency.normal;
    } else {
      final incomeStatus = item.incomeStatus!;
      if (incomeStatus.isOverdue) return _ItemUrgency.overdue;
      if (incomeStatus.isExpectedToday) return _ItemUrgency.dueToday;
      if (incomeStatus.isExpectedSoon) return _ItemUrgency.dueSoon;
      return _ItemUrgency.normal;
    }
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.count,
  });

  final Color color;
  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          count != null ? '$label ($count)' : label,
          style: AppTypographyExtended.metricLabel.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CombinedItem {
  const _CombinedItem({
    required this.date,
    required this.isBill,
    this.bill,
    this.incomeStatus,
  });

  final DateTime date;
  final bool isBill;
  final Bill? bill;
  final RecurringIncomeStatus? incomeStatus;
}

enum _ItemUrgency {
  overdue,
  dueToday,
  dueSoon,
  normal,
}

class _EnhancedBillCard extends StatelessWidget {
  const _EnhancedBillCard({
    required this.bill,
    this.onPaymentPressed,
    this.onDetailPressed,
  });

  final Bill bill;
  final VoidCallback? onPaymentPressed;
  final VoidCallback? onDetailPressed;

  @override
  Widget build(BuildContext context) {
    final daysUntilDue = bill.daysUntilDue;
    final isOverdue = bill.isOverdue;
    final isDueSoon = bill.isDueSoon;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isOverdue) {
      statusColor = AppColorsExtended.statusOverBudget;
      statusText = '${daysUntilDue.abs()}d overdue';
      statusIcon = Icons.error_outline;
    } else if (daysUntilDue == 0) {
      statusColor = AppColorsExtended.statusCritical;
      statusText = 'Due today';
      statusIcon = Icons.warning_amber_rounded;
    } else if (daysUntilDue == 1) {
      statusColor = AppColorsExtended.statusWarning;
      statusText = 'Tomorrow';
      statusIcon = Icons.access_time;
    } else if (isDueSoon) {
      statusColor = AppColorsExtended.statusWarning;
      statusText = 'In ${daysUntilDue}d';
      statusIcon = Icons.access_time;
    } else {
      statusColor = AppColors.primary;
      statusText = 'In ${daysUntilDue}d';
      statusIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
        border: isOverdue
            ? Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Status indicator line
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Bill icon with tap feedback
          GestureDetector(
            onTap: onDetailPressed ?? () {
              HapticFeedback.selectionClick();
              // Navigate to bill detail - handled by parent
            },
            child: Semantics(
              label: 'View bill details for ${bill.name}',
              button: true,
              child: Container(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                decoration: BoxDecoration(
                  color: AppColorsExtended.statusCritical.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt,
                  size: 18,
                  color: AppColorsExtended.statusCritical,
                ),
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Bill details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount and action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.amount),
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColorsExtended.statusCritical,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onPaymentPressed ?? () {
                  HapticFeedback.lightImpact();
                  // Handle bill payment - this would trigger payment recording
                },
                child: Semantics(
                  label: 'Record payment for ${bill.name}',
                  button: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    decoration: BoxDecoration(
                      color: AppColorsExtended.statusNormal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: AppColorsExtended.statusNormal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pay',
                          style: AppTypographyExtended.metricLabel.copyWith(
                            color: AppColorsExtended.statusNormal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnhancedIncomeCard extends StatelessWidget {
  const _EnhancedIncomeCard({
    required this.incomeStatus,
    this.onReceiptPressed,
    this.onDetailPressed,
  });

  final RecurringIncomeStatus incomeStatus;
  final VoidCallback? onReceiptPressed;
  final VoidCallback? onDetailPressed;

  @override
  Widget build(BuildContext context) {
    final daysUntilExpected = incomeStatus.daysUntilExpected;
    final isOverdue = incomeStatus.isOverdue;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isOverdue) {
      statusColor = AppColorsExtended.statusWarning;
      statusText = '${daysUntilExpected.abs()}d overdue';
      statusIcon = Icons.warning_amber_rounded;
    } else if (daysUntilExpected == 0) {
      statusColor = AppColorsExtended.statusNormal;
      statusText = 'Expected today';
      statusIcon = Icons.check_circle_outline;
    } else if (daysUntilExpected == 1) {
      statusColor = AppColorsExtended.statusNormal;
      statusText = 'Tomorrow';
      statusIcon = Icons.access_time;
    } else {
      statusColor = AppColors.primary;
      statusText = 'In ${daysUntilExpected}d';
      statusIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Status indicator line
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Income icon with tap feedback
          GestureDetector(
            onTap: onDetailPressed ?? () {
              HapticFeedback.selectionClick();
              // Navigate to income detail - handled by parent
            },
            child: Semantics(
              label: 'View income details for ${incomeStatus.income.name}',
              button: true,
              child: Container(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                decoration: BoxDecoration(
                  color: AppColorsExtended.statusNormal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_downward,
                  size: 18,
                  color: AppColorsExtended.statusNormal,
                ),
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Income details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incomeStatus.income.name,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount and action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(incomeStatus.income.amount)}',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColorsExtended.statusNormal,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onReceiptPressed ?? () {
                  HapticFeedback.lightImpact();
                  // Handle income recording - this would trigger income recording
                },
                child: Semantics(
                  label: 'Record receipt for ${incomeStatus.income.name}',
                  button: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
                    decoration: BoxDecoration(
                      color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 12,
                          color: AppColorsExtended.budgetPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Record',
                          style: AppTypographyExtended.metricLabel.copyWith(
                            color: AppColorsExtended.budgetPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}