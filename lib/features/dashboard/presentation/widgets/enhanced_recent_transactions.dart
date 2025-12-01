import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../settings/presentation/widgets/formatting_widgets.dart';
import '../../../settings/presentation/widgets/privacy_mode_text.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transaction_detail_bottom_sheet.dart';

class EnhancedRecentTransactions extends ConsumerWidget {
  const EnhancedRecentTransactions({
    super.key,
    required this.recentTransactions,
  });

  final List<Transaction> recentTransactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: AppColorsExtended.budgetPrimary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    context.go('/transactions');
                  }
                },
                child: Text(
                  'See All',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColorsExtended.budgetPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),

          if (recentTransactions.isEmpty)
            _buildEmptyState(context)
          else
            ...recentTransactions.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final transaction = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < recentTransactions.length - 1 ? 8 : 0,
                ),
                child: _EnhancedTransactionCard(
                  transaction: transaction,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * index))
                  .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 50 * index)),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses and\nincome by adding transactions',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EnhancedTransactionCard extends ConsumerWidget {
  const _EnhancedTransactionCard({
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense
        ? AppColorsExtended.statusCritical
        : AppColorsExtended.statusNormal;

    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    final categories = ref.watch(transactionCategoriesProvider);
    final category = categories.where((c) => c.id == transaction.categoryId).firstOrNull;
    final categoryIcon = categoryIconColorService.getIconForCategory(transaction.categoryId);
    final categoryColor = categoryIconColorService.getColorForCategory(transaction.categoryId);
    final categoryName = category?.name ?? 'Unknown Category';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (context.mounted) {
            AppBottomSheet.show(
              context: context,
              child: TransactionDetailBottomSheet(
                transaction: transaction,
                startInEditMode: false,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Category Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  categoryIcon,
                  size: 20,
                  color: categoryColor,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            categoryName,
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: categoryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 10,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        _buildSmartDateText(transaction.date),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isExpense ? '-' : '+',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      PrivacyModeAmount(
                        amount: transaction.amount,
                        currency: transaction.currencyCode ?? '\$',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isExpense ? 'Expense' : 'Income',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: amountColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return SettingsDateText(
        date: date,
        format: 'HH:mm',
        style: AppTypographyExtended.metricLabel.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      );
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return Text(
        'Yesterday',
        style: AppTypographyExtended.metricLabel.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      );
    } else if (now.difference(date).inDays < 7) {
      return SettingsDateText(
        date: date,
        format: 'EEEE',
        style: AppTypographyExtended.metricLabel.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      );
    } else {
      return SettingsDateText(
        date: date,
        format: 'MMM dd',
        style: AppTypographyExtended.metricLabel.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      );
    }
  }

  void _navigateToRecurringTransaction(BuildContext context, Transaction transaction) {
    HapticFeedback.selectionClick();
    // Recurring transaction navigation removed
  }
}