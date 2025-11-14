import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../../../features/transactions/domain/entities/transaction.dart';
import '../../../features/transactions/presentation/providers/transaction_providers.dart';

/// Enhanced transaction card pattern with modern UI
///
/// Features:
/// - Gradient category icon background
/// - Swipe actions (edit/delete)
/// - Status badges
/// - Improved typography and spacing
/// - Haptic feedback
/// - Consistent design tokens
///
/// Usage:
/// ```dart
/// EnhancedTransactionCardPattern(
///   transaction: transaction,
///   showDateLabel: false,
/// )
/// ```
class EnhancedTransactionCardPattern extends ConsumerWidget {
  const EnhancedTransactionCardPattern({
    super.key,
    required this.transaction,
    this.showDateLabel = false,
  });

  final Transaction transaction;
  final bool showDateLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense
        ? ColorTokens.transactionExpense
        : ColorTokens.transactionIncome;

    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    final categories = ref.watch(transactionCategoriesProvider);
    final category = categories.where((c) => c.id == transaction.categoryId).firstOrNull;
    final categoryIcon = categoryIconColorService.getIconForCategory(transaction.categoryId);
    final categoryColor = categoryIconColorService.getColorForCategory(transaction.categoryId);
    final categoryName = category?.name ?? 'Unknown Category';

    return Slidable(
      key: ValueKey(transaction.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editTransaction(context, transaction),
            backgroundColor: ColorTokens.budgetPrimary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteTransaction(context, ref, transaction),
            backgroundColor: ColorTokens.transactionExpense,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (context.mounted) {
              context.go('/transactions/${transaction.id}');
            }
          },
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          child: Container(
            padding: EdgeInsets.all(DesignTokens.cardPaddingMd),
            decoration: BoxDecoration(
              color: ColorTokens.surfacePrimary,
              borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
              border: Border.all(
                color: ColorTokens.borderPrimary,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Category Icon with gradient background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        categoryColor,
                        ColorTokens.darken(categoryColor, 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    boxShadow: DesignTokens.elevationColored(
                      categoryColor,
                      alpha: 0.3,
                    ),
                  ),
                  child: Icon(
                    categoryIcon,
                    size: DesignTokens.iconMd,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: DesignTokens.spacing3),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? 'Transaction',
                        style: TypographyTokens.bodyMd.copyWith(
                          color: ColorTokens.textPrimary,
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
                              color: ColorTokens.withOpacity(categoryColor, 0.1),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              border: Border.all(
                                color: ColorTokens.withOpacity(categoryColor, 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              categoryName,
                              style: TypographyTokens.captionSm.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 11,
                            color: ColorTokens.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(transaction.date),
                            style: TypographyTokens.captionSm.copyWith(
                              color: ColorTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount with badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '-' : '+'}${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(transaction.amount)}',
                      style: TypographyTokens.numericMd.copyWith(
                        fontSize: 16,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColorTokens.withOpacity(amountColor, 0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 10,
                            color: amountColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isExpense ? 'OUT' : 'IN',
                            style: TypographyTokens.overlineSm.copyWith(
                              color: amountColor,
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
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context, Transaction transaction) {
    HapticFeedback.lightImpact();
    // Navigate to edit
    // TODO: Implement edit transaction
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: ColorTokens.transactionExpense,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(transactionNotifierProvider.notifier)
          .deleteTransaction(transaction.id);

      if (success && context.mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    }
  }
}