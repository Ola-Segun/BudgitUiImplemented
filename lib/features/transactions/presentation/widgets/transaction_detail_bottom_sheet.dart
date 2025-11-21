import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/haptic_feedback_utils.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

/// Bottom sheet for viewing and editing transaction details
class TransactionDetailBottomSheet extends ConsumerStatefulWidget {
  const TransactionDetailBottomSheet({
    super.key,
    required this.transaction,
    this.startInEditMode = false,
  });

  final Transaction transaction;
  final bool startInEditMode;

  @override
  ConsumerState<TransactionDetailBottomSheet> createState() => _TransactionDetailBottomSheetState();
}

class _TransactionDetailBottomSheetState extends ConsumerState<TransactionDetailBottomSheet> {
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.startInEditMode;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final content = _isEditing ? _buildEditContent() : _buildDetailContent();

    return SizedBox(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical:24),
          child: content,
        ),
      ),
    );
  }

  Widget _buildDetailContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Amount Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  widget.transaction.signedAmount,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.transaction.isIncome
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.transaction.type.displayName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Transaction Details
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),

        _buildDetailRow('Title', widget.transaction.title),
        _buildDetailRow('Description', widget.transaction.description ?? 'No description'),
        _buildDetailRow('Category', _getCategoryName(widget.transaction.categoryId)),
        _buildDetailRow('Date', DateFormat('EEEE, MMMM dd, yyyy').format(widget.transaction.date)),
        _buildDetailRow('Time', DateFormat('HH:mm').format(widget.transaction.date)),

        if (widget.transaction.receiptUrl != null) ...[
          const SizedBox(height: 16),
          _buildDetailRow('Receipt', 'Available'),
        ],

        if (widget.transaction.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDetailRow('Tags', widget.transaction.tags.join(', ')),
        ],

        // Edit and Delete buttons
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _confirmDeleteTransaction(context),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditContent() {
    final categories = ref.watch(transactionCategoriesProvider);
    final categoryIconColorService = ref.read(categoryIconColorServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Edit Transaction',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update transaction details',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),

        // Edit Form
        EditTransactionForm(
          transaction: widget.transaction,
          categories: categories,
          categoryIconColorService: categoryIconColorService,
          onSave: (updatedTransaction) async {
            final success = await ref
                .read(transactionNotifierProvider.notifier)
                .updateTransaction(updatedTransaction);

            if (success && mounted) {
              setState(() => _isEditing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction updated successfully')),
              );
            }
          },
          onCancel: () => setState(() => _isEditing = false),
        ),

      ],
    );
  }



  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    final categories = ref.read(transactionCategoriesProvider);
    final category = categories.where((c) => c.id == categoryId).firstOrNull;
    return category?.name ?? 'Unknown Category';
  }

  Future<void> _confirmDeleteTransaction(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete "${widget.transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(transactionNotifierProvider.notifier)
          .deleteTransaction(widget.transaction.id);

      if (success && mounted) {
        Navigator.pop(context); // Close the bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    }
  }
}

/// Enhanced form for editing transaction details
class EditTransactionForm extends StatefulWidget {
  const EditTransactionForm({
    super.key,
    required this.transaction,
    required this.categories,
    required this.categoryIconColorService,
    required this.onSave,
    required this.onCancel,
  });

  final Transaction transaction;
  final List<TransactionCategory> categories;
  final dynamic categoryIconColorService;
  final void Function(Transaction) onSave;
  final VoidCallback onCancel;

  @override
  State<EditTransactionForm> createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<EditTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;

  late TransactionType _selectedType;
  late DateTime _selectedDate;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _amountController = TextEditingController(text: widget.transaction.amount.toStringAsFixed(2));

    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;
    _selectedCategoryId = widget.transaction.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Transaction Type Selector
          ModernToggleButton(
            options: const ['Expense', 'Income'],
            selectedIndex: _selectedType == TransactionType.expense ? 0 : 1,
            onChanged: (index) {
              setState(() {
                _selectedType = index == 0 ? TransactionType.expense : TransactionType.income;
                _selectedCategoryId = ''; // Reset category when type changes
              });
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal),

          SizedBox(height: spacing_lg),

          SizedBox(height: FormTokens.sectionGap),

          // Amount Field
          ModernTextField(
            controller: _amountController,
            placeholder: 'Amount',
            prefixIcon: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Title Field
          ModernTextField(
            controller: _titleController,
            placeholder: 'Title',
            prefixIcon: Icons.title,
            maxLength: 100,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Category Selection
          Builder(
            builder: (context) {
              final categories = widget.categories.where((cat) =>
                cat.type == _selectedType || cat.type == TransactionType.transfer
              ).toList();
              final categoryItems = categories.map((cat) => CategoryItem(
                id: cat.id,
                name: cat.name,
                icon: widget.categoryIconColorService.getIconForCategory(cat.id),
                color: widget.categoryIconColorService.getColorForCategory(cat.id).value,
              )).toList();

              return ModernCategorySelector(
                categories: categoryItems,
                selectedId: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
                onChanged: (value) {
                  if (value != null) {
                    HapticFeedbackUtils.light();
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  }
                },
              );
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Date Picker
          ModernDateTimePicker(
            selectedDate: _selectedDate,
            selectedTime: TimeOfDay.fromDateTime(_selectedDate),
            onDateChanged: (date) {
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            onTimeChanged: (time) {
              if (time != null) {
                setState(() {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Description Field
          ModernTextField(
            controller: _descriptionController,
            placeholder: 'Description (optional)',
            prefixIcon: Icons.description_outlined,
            maxLength: 200,
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 450.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 450.ms),

          SizedBox(height: spacing_lg),

          // Action Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                flex: 3,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedbackUtils.light();
                    widget.onCancel();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(
                      color: ModernColors.borderColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius_md),
                    ),
                  ),
                  child: Text('Cancel', style: ModernTypography.labelMedium),
                ),
              ),
              SizedBox(width: spacing_md),
              // Save Button
              Expanded(
                flex: 7,
                child: ModernSlideToConfirm(
                  text: 'Slide to Save',
                  onSlideComplete: _saveTransaction,
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms),
        ],
      ),
    );
  }


  Future<bool> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedbackUtils.error();
      return false;
    }

    HapticFeedbackUtils.success();

    final amount = double.parse(_amountController.text);

    final updatedTransaction = widget.transaction.copyWith(
      title: _titleController.text.trim(),
      amount: amount,
      type: _selectedType,
      date: _selectedDate,
      categoryId: _selectedCategoryId,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );

    widget.onSave(updatedTransaction);
    return true;
  }
}