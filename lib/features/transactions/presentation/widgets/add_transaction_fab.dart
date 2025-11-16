import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/color_tokens.dart';
import '../providers/transaction_providers.dart';
import 'enhanced_add_transaction_bottom_sheet.dart';

/// Floating Action Button for adding transactions
class AddTransactionFAB extends ConsumerWidget {
  const AddTransactionFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showAddTransactionSheet(context, ref),
      backgroundColor: ColorTokens.teal500,
      foregroundColor: ColorTokens.surfacePrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add, size: 28),
    );
  }

  Future<void> _showAddTransactionSheet(BuildContext context, WidgetRef ref) async {
    await EnhancedAddTransactionBottomSheet.show(
      context: context,
      onSubmit: (transaction) async {
        final success = await ref
            .read(transactionNotifierProvider.notifier)
            .addTransaction(transaction);
        if (success && context.mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction added successfully')),
          );
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add transaction')),
            );
          }
        }
      },
    );
  }
}