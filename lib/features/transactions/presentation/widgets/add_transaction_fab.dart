import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../providers/transaction_providers.dart';
import 'add_transaction_bottom_sheet.dart';

/// Floating Action Button for adding transactions
class AddTransactionFAB extends ConsumerWidget {
  const AddTransactionFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showAddTransactionSheet(context, ref),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _showAddTransactionSheet(BuildContext context, WidgetRef ref) async {
    print('DEBUG: AddTransactionFAB tapped - showing bottom sheet directly');
    await AppBottomSheet.show(
      context: context,
      child: AddTransactionBottomSheet(
        onSubmit: (transaction) async {
          print('DEBUG: Transaction submitted from bottom sheet');
          print('DEBUG: Transaction details - ID: ${transaction.id}, Amount: ${transaction.amount}, Type: ${transaction.type}, Category: ${transaction.categoryId}, Account: ${transaction.accountId}');
          final success = await ref
              .read(transactionNotifierProvider.notifier)
              .addTransaction(transaction);
          print('DEBUG: Add transaction result: $success');
          if (success && context.mounted) {
            print('DEBUG: Transaction added successfully');
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction added successfully')),
            );
          } else {
            print('DEBUG: Transaction addition failed or context not mounted');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to add transaction')),
              );
            }
          }
        },
      ),
    );
    print('DEBUG: Bottom sheet dismissed');
  }
}