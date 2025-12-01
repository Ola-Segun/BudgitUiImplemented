import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';
import '../../../../core/design_system/widgets/mini_trend_indicator.dart';
import '../../domain/entities/financial_obligation.dart';

class FixedEnhancedObligationCard extends ConsumerWidget {
  const FixedEnhancedObligationCard({
    super.key,
    required this.obligation,
    this.onEdit,
    this.onDelete,
    this.onMarkComplete,
  });

  final FinancialObligation obligation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBill = obligation.type == ObligationType.bill;
    final isOverdue = obligation.isOverdue;
    final isDueToday = obligation.isDueToday;

    // Mock trend data - replace with actual historical data
    final trendData = List.generate(7, (i) => obligation.amount * (0.9 + (i * 0.02)));

    return Slidable(
      key: ValueKey(obligation.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.lightImpact();
              onEdit?.call();
            },
            backgroundColor: ObligationsTheme.trackfinzPrimary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          if (onMarkComplete != null)
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.mediumImpact();
                onMarkComplete?.call();
              },
              backgroundColor: ObligationsTheme.statusNormal,
              foregroundColor: Colors.white,
              icon: Icons.check_circle,
              label: isBill ? 'Pay' : 'Receive',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              onDelete?.call();
            },
            backgroundColor: ObligationsTheme.statusCritical,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            final route = isBill
                ? '/more/cash-flow/bills/${obligation.id}'
                : '/more/cash-flow/incomes/${obligation.id}';
            context.go(route);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: (isOverdue || isDueToday)
                  ? Border.all(
                      color: obligation.urgency.color.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                  : Border.all(
                      color: ObligationsTheme.borderSubtle,
                      width: 1,
                    ),
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
                // Header Row
                Row(
                  children: [
                    // Type indicator with gradient
                    Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                obligation.typeColor,
                                obligation.typeColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: obligation.typeColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            obligation.type.icon,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        // Automation indicator
                        if (obligation.isAutomated == true)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.autorenew,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Obligation name and frequency
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obligation.name,
                            style: ObligationsTypography.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: obligation.typeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: obligation.typeColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  obligation.frequency.displayName,
                                  style: ObligationsTypography.caption.copyWith(
                                    color: obligation.typeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (obligation.isAutomated == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.autorenew,
                                        size: 9,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Auto',
                                        style: ObligationsTypography.caption.copyWith(
                                          color: const Color(0xFF8B5CF6),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Amount and urgency badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          obligation.formattedAmount,
                          style: ObligationsTypography.amountSmall.copyWith(
                            color: obligation.typeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: obligation.urgency.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            obligation.urgency.displayName,
                            style: ObligationsTypography.caption.copyWith(
                              color: obligation.urgency.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress/Status Row
                Row(
                  children: [
                    // Status icon and text
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 15,
                            color: obligation.urgency.color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _getStatusText(),
                              style: ObligationsTypography.bodySmall.copyWith(
                                color: obligation.urgency.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mini trend indicator
                    MiniTrendIndicator(
                      values: trendData,
                      color: obligation.typeColor,
                      width: 50,
                      height: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Due date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 11,
                          color: ObligationsTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(obligation.nextDate),
                          style: ObligationsTypography.caption.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    // Account link indicator
                    if (obligation.accountId != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 11,
                            color: ObligationsTheme.trackfinzSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Linked',
                            style: ObligationsTypography.caption.copyWith(
                              color: ObligationsTheme.trackfinzSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link_off,
                            size: 11,
                            color: ObligationsTheme.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Not linked',
                            style: ObligationsTypography.caption.copyWith(
                              color: ObligationsTheme.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
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
    } else if (obligation.daysUntilNext <= 7) {
      return 'In ${obligation.daysUntilNext}d';
    } else {
      return DateFormat('MMM dd').format(obligation.nextDate);
    }
  }
}