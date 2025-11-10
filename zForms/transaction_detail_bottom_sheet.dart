import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/components/enhanced_bottom_sheet.dart';
import '../../../../core/design_system/components/enhanced_text_field.dart';
import '../../../../core/design_system/components/enhanced_dropdown_field.dart';
import '../../../../core/design_system/components/category_button_selector.dart';
import '../../../../core/design_system/haptic_feedback_utils.dart';
import '../../../../core/design_system/components/optional_fields_toggle.dart';
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
    // Show bottom sheet based on editing state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_isEditing) {
          _showEditBottomSheet();
        } else {
          _showDetailBottomSheet();
        }
      }
    });

    // Return empty container since bottom sheet is shown via callback
    return const SizedBox.shrink();
  }

  void _showDetailBottomSheet() {
    EnhancedBottomSheet.showScrollable(
      context: context,
      title: 'Transaction Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }

  void _showEditBottomSheet() {
    final categories = ref.watch(transactionCategoriesProvider);
    final categoryIconColorService = ref.read(categoryIconColorServiceProvider);

    EnhancedBottomSheet.showForm(
      context: context,
      title: 'Edit Transaction',
      subtitle: 'Update transaction details',
      child: EditTransactionForm(
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
      actions: [
        OutlinedButton(
          onPressed: () => setState(() => _isEditing = false),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, FormTokens.fieldHeightMd),
            side: BorderSide(
              color: ColorTokens.borderPrimary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
            ),
          ),
          child: Text('Cancel', style: TypographyTokens.labelMd),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: ColorTokens.gradientPrimary,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
          child: ElevatedButton(
            onPressed: () => _confirmDeleteTransaction(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: Size(0, FormTokens.fieldHeightMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
              ),
            ),
            child: Text(
              'Delete',
              style: TypographyTokens.labelMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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
  bool _showOptionalFields = false;

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
          // Optional Fields Toggle
          OptionalFieldsToggle(
            onChanged: (show) {
              setState(() {
                _showOptionalFields = show;
              });
            },
            label: 'Show optional fields',
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal),

          SizedBox(height: FormTokens.sectionGap),

          // Transaction Type Selector with enhanced design
          _buildTypeSelector().animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

          SizedBox(height: FormTokens.sectionGap),

          // Amount Field
          EnhancedTextField(
            controller: _amountController,
            label: 'Amount',
            hint: '0.00',
            prefix: Icon(
              Icons.attach_money,
              color: FormTokens.iconColor,
              size: DesignTokens.iconMd,
            ),
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
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Title Field
          EnhancedTextField(
            controller: _titleController,
            label: 'Title',
            hint: 'Transaction title',
            prefix: Icon(
              Icons.title,
              color: FormTokens.iconColor,
              size: DesignTokens.iconMd,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Category Selection
          CategoryButtonSelector(
            categories: widget.categories,
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (value) {
              if (value != null) {
                HapticFeedbackUtils.light();
                setState(() {
                  _selectedCategoryId = value;
                });
              }
            },
            categoryIconColorService: widget.categoryIconColorService,
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Date Picker
          _buildDatePicker().animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Description Field
          if (_showOptionalFields) ...[
            EnhancedTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'Additional details...',
              maxLength: 200,
              maxLines: 3,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms),

            SizedBox(height: FormTokens.sectionGap),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedbackUtils.light();
                    widget.onCancel();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, FormTokens.fieldHeightMd),
                    side: BorderSide(
                      color: ColorTokens.borderPrimary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
                    ),
                  ),
                  child: Text('Cancel', style: TypographyTokens.labelMd),
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: ColorTokens.gradientPrimary,
                    borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
                  ),
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: Size(0, FormTokens.fieldHeightMd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TypographyTokens.labelMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 700.ms : 600.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 700.ms : 600.ms),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.borderSecondary,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.expense,
              icon: Icons.remove_circle_outline,
              label: 'Expense',
              color: ColorTokens.critical500,
            ),
          ),
          Container(
            width: 1.5,
            height: 48,
            color: ColorTokens.borderSecondary,
          ),
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.income,
              icon: Icons.add_circle_outline,
              label: 'Income',
              color: ColorTokens.success500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedbackUtils.light();
          setState(() {
            _selectedType = type;
            _selectedCategoryId = ''; // Reset category when type changes
          });
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: AnimatedContainer(
          duration: DesignTokens.durationSm,
          curve: DesignTokens.curveEaseOut,
          padding: EdgeInsets.symmetric(
            vertical: DesignTokens.spacing3,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: DesignTokens.iconMd,
                color: isSelected ? color : ColorTokens.textSecondary,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Text(
                label,
                style: TypographyTokens.labelMd.copyWith(
                  color: isSelected ? color : ColorTokens.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
      .scaleXY(
        begin: 1.0,
        end: 1.02,
        duration: DesignTokens.durationSm,
      );
  }

  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticFeedbackUtils.light();
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null && mounted) {
            setState(() {
              _selectedDate = date;
            });
          }
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: FormTokens.fieldPaddingH,
            vertical: FormTokens.fieldPaddingV,
          ),
          decoration: BoxDecoration(
            color: FormTokens.fieldBackground,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
            border: Border.all(
              color: FormTokens.fieldBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: DesignTokens.iconMd,
                color: FormTokens.iconColor,
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Date',
                      style: TypographyTokens.captionMd.copyWith(
                        color: FormTokens.labelColor,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing05),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                      style: TypographyTokens.labelMd,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: DesignTokens.iconMd,
                color: FormTokens.iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedbackUtils.error();
      return;
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
  }
}