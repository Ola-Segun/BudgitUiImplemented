import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/design_system/widgets/mini_trend_indicator.dart';
import '../../domain/entities/financial_obligation.dart';

/// Enhanced unified card for both bills and recurring income
class EnhancedObligationCard extends ConsumerWidget {
  const EnhancedObligationCard({
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
        children: [
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.lightImpact();
              onEdit?.call();
            },
            backgroundColor: AppColorsExtended.budgetPrimary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onMarkComplete != null)
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.mediumImpact();
                onMarkComplete?.call();
              },
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              icon: Icons.check_circle,
              label: isBill ? 'Pay' : 'Receive',
              borderRadius: BorderRadius.circular(12),
            ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              onDelete?.call();
            },
            backgroundColor: const Color(0xFFEF4444),
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
            final route = isBill ? '/more/bills/${obligation.id}' : '/more/incomes/${obligation.id}';
            context.go(route);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: (isOverdue || isDueToday)
                  ? Border.all(
                      color: obligation.urgency.color.withValues(alpha: 0.3),
                      width: 2,
                    )
                  : Border.all(
                      color: AppColors.borderSubtle,
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                obligation.typeColor,
                                obligation.typeColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: obligation.typeColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            obligation.type.icon,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                        // Automation indicator
                        if (obligation.isAutomated == true)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.autorenew,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: AppDimensions.spacing3),

                    // Obligation name and frequency
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obligation.name,
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                  style: AppTypographyExtended.metricLabel.copyWith(
                                    color: obligation.typeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (obligation.isAutomated == true) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.autorenew,
                                        size: 10,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Auto',
                                        style: AppTypographyExtended.metricLabel.copyWith(
                                          color: const Color(0xFF8B5CF6),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
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
                    ),

                    // Amount and urgency badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          obligation.formattedAmount,
                          style: AppTypographyExtended.statsValue.copyWith(
                            fontSize: 18,
                            color: obligation.typeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: obligation.urgency.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            obligation.urgency.displayName,
                            style: AppTypographyExtended.metricLabel.copyWith(
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

                SizedBox(height: AppDimensions.spacing4),

                // Progress/Status Row
                Row(
                  children: [
                    // Status icon and text
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 16,
                            color: obligation.urgency.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(),
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: obligation.urgency.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mini trend indicator
                    MiniTrendIndicator(
                      values: trendData,
                      color: obligation.typeColor,
                      width: 60,
                      height: 24,
                    ),
                  ],
                ),

                SizedBox(height: AppDimensions.spacing3),

                // Footer Row
                Row(
                  children: [
                    // Due date
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(obligation.nextDate),
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),

                    const Spacer(),

                    // Account link indicator
                    if (obligation.accountId != null) ...[
                      Icon(
                        Icons.account_balance_wallet,
                        size: 12,
                        color: AppColorsExtended.budgetSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Linked',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColorsExtended.budgetSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.link_off,
                        size: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Not linked',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
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
      return '${obligation.daysUntilNext.abs()} days overdue';
    } else if (obligation.isDueToday) {
      return 'Due today';
    } else if (obligation.daysUntilNext == 1) {
      return 'Tomorrow';
    } else if (obligation.daysUntilNext <= 7) {
      return 'In ${obligation.daysUntilNext} days';
    } else {
      return DateFormat('MMM dd').format(obligation.nextDate);
    }
  }
}