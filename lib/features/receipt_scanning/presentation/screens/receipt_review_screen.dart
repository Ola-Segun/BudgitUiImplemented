import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../features/transactions/domain/entities/transaction.dart';
import '../../../../features/transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/receipt_data.dart';
import '../widgets/receipt_image_preview.dart';

/// Screen for reviewing and editing extracted receipt data
class ReceiptReviewScreen extends ConsumerStatefulWidget {
  const ReceiptReviewScreen({
    super.key,
    required this.receiptData,
  });

  final ReceiptData receiptData;

  @override
  ConsumerState<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _categoryController;

  String? _selectedCategory; // Will be set when categories are loaded

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.receiptData.merchant);
    _amountController = TextEditingController(text: widget.receiptData.amount.toStringAsFixed(2));
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.receiptData.date),
    );
    _categoryController = TextEditingController(text: widget.receiptData.suggestedCategory ?? 'food');
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt image preview
            if (widget.receiptData.imagePath != null)
              ReceiptImagePreview(imagePath: widget.receiptData.imagePath!),

            const SizedBox(height: AppSpacing.lg),

            // Extracted data form
            Text(
              'Extracted Information',
              style: AppTypography.headlineSmall,
            ),

            const SizedBox(height: AppSpacing.md),

            // Merchant field
            TextFormField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Merchant',
                hintText: 'Enter merchant name',
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Amount field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Date field
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date',
                hintText: 'YYYY-MM-DD',
              ),
              readOnly: true,
              onTap: _selectDate,
            ),

            const SizedBox(height: AppSpacing.md),

            // Category field
            categoryState.when(
              data: (state) {
                final expenseCategories = state.getCategoriesByType(TransactionType.expense);

                // Set default category if not set
                if (_selectedCategory == null && expenseCategories.isNotEmpty) {
                  _selectedCategory = _getSmartDefaultCategoryId(expenseCategories, widget.receiptData.suggestedCategory);
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: expenseCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                );
              },
              loading: () => const LoadingView(),
              error: (error, stack) => ErrorView(
                message: 'Failed to load categories',
                onRetry: () => ref.read(categoryNotifierProvider.notifier).loadCategories(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Items list (if available)
            if (widget.receiptData.items.isNotEmpty) ...[
              Text(
                'Items',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...widget.receiptData.items.map((item) => _buildItemTile(item)),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text('Save Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildItemTile(ReceiptItem item) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPaddingAll,
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: AppTypography.bodyMedium,
              ),
            ),
            Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get smart default category ID for expense transactions
  String _getSmartDefaultCategoryId(List<TransactionCategory> expenseCategories, String? suggestedCategory) {
    if (expenseCategories.isEmpty) {
      // Fallback to default categories if no user categories exist
      final defaultCategories = TransactionCategory.defaultCategories.where((cat) => cat.type == TransactionType.expense).toList();
      return defaultCategories.isNotEmpty ? defaultCategories.first.id : 'other';
    }

    // First try the suggested category
    if (suggestedCategory != null) {
      final suggestedCat = expenseCategories.firstWhere(
        (cat) => cat.id == suggestedCategory,
        orElse: () => expenseCategories.first,
      );
      if (suggestedCat.id == suggestedCategory) {
        return suggestedCategory;
      }
    }

    // Prefer commonly used expense categories
    final preferredIds = ['food', 'transport', 'shopping'];
    for (final preferredId in preferredIds) {
      final preferredCategory = expenseCategories.firstWhere(
        (cat) => cat.id == preferredId,
        orElse: () => expenseCategories.first,
      );
      if (preferredCategory.id == preferredId) {
        return preferredId;
      }
    }

    // Return first expense category
    return expenseCategories.first.id;
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.receiptData.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _saveTransaction() async {
    try {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      final date = DateFormat('yyyy-MM-dd').parse(_dateController.text);

      // Create updated receipt data
      final updatedReceiptData = widget.receiptData.copyWith(
        merchant: _merchantController.text,
        amount: amount,
        date: date,
        suggestedCategory: _selectedCategory,
      );

      // Return the updated receipt data instead of saving directly
      context.pop(updatedReceiptData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing receipt data: $e')),
      );
    }
  }
}