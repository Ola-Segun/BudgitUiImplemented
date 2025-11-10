
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
import '../../../../core/design_system/components/optional_fields_toggle.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/split_transaction.dart';
import '../providers/transaction_providers.dart';
import '../../../accounts/presentation/providers/account_providers.dart';

/// Bottom sheet for creating split transactions
class SplitTransactionBottomSheet extends ConsumerWidget {
  const SplitTransactionBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialType,
  });

  final Future<void> Function(SplitTransaction) onSubmit;
  final TransactionType? initialType;

  static bool _isShowing = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SplitTransactionBottomSheetContent(
      onSubmit: onSubmit,
      initialType: initialType,
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Future<void> Function(SplitTransaction) onSubmit,
    TransactionType? initialType,
  }) async {
    if (_isShowing) return null;

    _isShowing = true;

    try {
      return await EnhancedBottomSheet.showForm<T>(
        context: context,
        title: 'Split Transaction',
        subtitle: 'Split a single transaction across multiple categories',
        child: SplitTransactionBottomSheet(
          onSubmit: onSubmit,
          initialType: initialType,
        ),
        actions: const [],
        onClose: () => _isShowing = false,
      );
    } finally {
      _isShowing = false;
    }
  }
}

class _SplitTransactionBottomSheetContent extends ConsumerStatefulWidget {
  const _SplitTransactionBottomSheetContent({
    required this.onSubmit,
    this.initialType,
  });

  final Future<void> Function(SplitTransaction) onSubmit;
  final TransactionType? initialType;

  @override
  ConsumerState<_SplitTransactionBottomSheetContent> createState() =>
      _SplitTransactionBottomSheetState();
}

class _SplitTransactionBottomSheetState
    extends ConsumerState<_SplitTransactionBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TransactionType _selectedType;
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  bool _isSubmitting = false;
  bool _showOptionalFields = false;

  // Split management
  final List<TransactionSplit> _splits = [];
  double _remainingAmount = 0.0;

  // Controllers for split items to persist user input
  final Map<int, TextEditingController> _amountControllers = {};
  final Map<int, TextEditingController> _percentageControllers = {};

  // Track which field is currently being edited to prevent circular updates
  int? _editingAmountIndex;
  int? _editingPercentageIndex;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
    // Initialize with one empty split
    _addSplit();
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _descriptionController.dispose();
    // Dispose all split controllers
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    for (final controller in _percentageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureValidDefaults();
  }

  void _ensureValidDefaults() {
    final accountsAsync = ref.watch(filteredAccountsProvider);

    accountsAsync.whenData((accounts) {
      if (_selectedAccountId == null && accounts.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedAccountId = accounts.first.id;
            });
          }
        });
      }
    });
  }

  void _addSplit() {
    setState(() {
      _splits.add(TransactionSplit(
        categoryId: '',
        amount: 0.0,
        percentage: 0.0,
      ));
      // Initialize controllers for the new split
      _amountControllers[_splits.length - 1] = TextEditingController();
      _percentageControllers[_splits.length - 1] = TextEditingController();
      _updateRemainingAmount();
    });
  }

  void _removeSplit(int index) {
    setState(() {
      _splits.removeAt(index);
      // Dispose and remove controllers for the removed split
      _amountControllers[index]?.dispose();
      _percentageControllers[index]?.dispose();
      _amountControllers.remove(index);
      _percentageControllers.remove(index);
      // Update controller indices for remaining splits
      final newAmountControllers = <int, TextEditingController>{};
      final newPercentageControllers = <int, TextEditingController>{};
      for (int i = 0; i < _splits.length; i++) {
        newAmountControllers[i] = _amountControllers[i] ?? TextEditingController();
        newPercentageControllers[i] = _percentageControllers[i] ?? TextEditingController();
      }
      _amountControllers.clear();
      _percentageControllers.clear();
      _amountControllers.addAll(newAmountControllers);
      _percentageControllers.addAll(newPercentageControllers);
      _updateRemainingAmount();
    });
  }

  void _updateSplit(int index, TransactionSplit split) {
    setState(() {
      _splits[index] = split;
      _updateRemainingAmount();
    });
  }

  void _updateSplitAmount(int index, String value) {
    // Mark this field as being edited to prevent circular updates
    _editingAmountIndex = index;

    final amount = double.tryParse(value) ?? 0.0;
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    final percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0.0;
    final updatedSplit = _splits[index].copyWith(amount: amount, percentage: percentage);
    _updateSplit(index, updatedSplit);

    // Only update percentage controller if it's not currently being edited
    if (_editingPercentageIndex != index) {
      _percentageControllers[index]?.text = percentage > 0 ? percentage.toStringAsFixed(1) : '';
    }

    // Clear the editing flag after a short delay to allow the update to complete
    Future.delayed(const Duration(milliseconds: 10), () {
      _editingAmountIndex = null;
    });
  }

  void _updateSplitPercentage(int index, String value) {
    // Mark this field as being edited to prevent circular updates
    _editingPercentageIndex = index;

    final percentage = double.tryParse(value) ?? 0.0;
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    final amount = (percentage / 100) * totalAmount;
    final updatedSplit = _splits[index].copyWith(amount: amount, percentage: percentage);
    _updateSplit(index, updatedSplit);

    // Only update amount controller if it's not currently being edited
    if (_editingAmountIndex != index) {
      _amountControllers[index]?.text = amount > 0 ? amount.toStringAsFixed(2) : '';
    }

    // Clear the editing flag after a short delay to allow the update to complete
    Future.delayed(const Duration(milliseconds: 10), () {
      _editingPercentageIndex = null;
    });
  }

  void _recalculateAllPercentages() {
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    if (totalAmount > 0) {
      setState(() {
        for (int i = 0; i < _splits.length; i++) {
          final split = _splits[i];
          final percentage = (split.amount / totalAmount) * 100;
          _splits[i] = split.copyWith(percentage: percentage);
        }
      });
    }
  }

  void _updateRemainingAmount() {
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    final allocatedAmount = _splits.fold<double>(0.0, (sum, split) => sum + split.amount);
    _remainingAmount = totalAmount - allocatedAmount;

    // Update all percentages when total amount changes
    if (totalAmount > 0) {
      for (int i = 0; i < _splits.length; i++) {
        final split = _splits[i];
        final percentage = (split.amount / totalAmount) * 100;
        _splits[i] = split.copyWith(percentage: percentage);

        // Only update controller texts if the field is not currently being edited
        if (_editingAmountIndex != i) {
          _amountControllers[i]?.text = split.amount > 0 ? split.amount.toStringAsFixed(2) : '';
        }
        if (_editingPercentageIndex != i) {
          _percentageControllers[i]?.text = percentage > 0 ? percentage.toStringAsFixed(1) : '';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryNotifierProvider);
    final accountsAsync = ref.watch(filteredAccountsProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
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

            // Transaction Type Selector
            _buildTypeSelector().animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

            SizedBox(height: FormTokens.sectionGap),

            // Total Amount Field
            EnhancedTextField(
              controller: _totalAmountController,
              label: 'Total Amount',
              hint: '0.00',
              prefix: Icon(
                Icons.attach_money,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (_) {
                _updateRemainingAmount();
                _recalculateAllPercentages();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              autofocus: true,
            ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Account Dropdown
            accountsAsync.when(
              data: (accounts) {
                return EnhancedDropdownField<String>(
                  label: 'Account',
                  hint: 'Select an account',
                  items: accounts.map((account) {
                    return DropdownItem<String>(
                      value: account.id,
                      label: account.displayName,
                      subtitle: account.formattedAvailableBalance,
                      icon: Icons.account_balance_wallet,
                      iconColor: Color(account.type.color),
                    );
                  }).toList(),
                  value: _selectedAccountId,
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  },
                  selectedItemBuilder: (item) => Text(
                    item.label,
                    style: TypographyTokens.bodyMd,
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an account';
                    }
                    return null;
                  },
                ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                    .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading accounts: $error'),
            ),

            SizedBox(height: FormTokens.fieldGapMd),

            // Split Configuration
            _buildSplitConfiguration(categoryState, categoryIconColorService)
                .animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

            // Optional Fields Section
            if (_showOptionalFields) ...[
              SizedBox(height: FormTokens.fieldGapMd),

              // Date Picker
              _buildDatePicker().animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

              SizedBox(height: FormTokens.fieldGapMd),

              // Description Field
              EnhancedTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                hint: 'e.g., Restaurant bill split',
                prefix: Icon(
                  Icons.description_outlined,
                  color: FormTokens.iconColor,
                  size: DesignTokens.iconMd,
                ),
                maxLength: 100,
              ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms),
            ],

            SizedBox(height: FormTokens.fieldGapMd),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitSplitTransaction,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, FormTokens.fieldHeightMd),
                backgroundColor: ColorTokens.teal500,
                foregroundColor: ColorTokens.surfacePrimary,
                disabledBackgroundColor: ColorTokens.teal500.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: DesignTokens.iconMd,
                      width: DesignTokens.iconMd,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.surfacePrimary),
                      ),
                    )
                  : Text(
                      'Create Split Transaction',
                      style: TypographyTokens.labelMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 700.ms : 500.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 700.ms : 500.ms),

            SizedBox(height: FormTokens.sectionGap),
          ],
        ),
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
          HapticFeedback.lightImpact();
          setState(() {
            _selectedType = type;
          });
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: AnimatedContainer(
          duration: DesignTokens.durationSm,
          curve: DesignTokens.curveEaseOut,
          constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
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

  Widget _buildSplitConfiguration(
    AsyncValue categoryState,
    dynamic categoryIconColorService,
  ) {
    return Container(
      padding: EdgeInsets.all(FormTokens.fieldPaddingH),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.borderSecondary,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.call_split,
                size: DesignTokens.iconMd,
                color: ColorTokens.teal500,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Text(
                'Split Configuration',
                style: TypographyTokens.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_splits.length} split${_splits.length == 1 ? '' : 's'}',
                style: TypographyTokens.captionMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: FormTokens.fieldGapMd),

          // Remaining amount indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing3,
              vertical: DesignTokens.spacing2,
            ),
            decoration: BoxDecoration(
              color: _remainingAmount >= 0 ? ColorTokens.success500.withValues(alpha: 0.1) : ColorTokens.critical500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  _remainingAmount >= 0 ? Icons.check_circle : Icons.warning,
                  size: DesignTokens.iconSm,
                  color: _remainingAmount >= 0 ? ColorTokens.success500 : ColorTokens.critical500,
                ),
                SizedBox(width: DesignTokens.spacing2),
                Text(
                  'Remaining: \$${NumberFormat.currency(symbol: '', decimalDigits: 2).format(_remainingAmount.abs())}',
                  style: TypographyTokens.captionMd.copyWith(
                    color: _remainingAmount >= 0 ? ColorTokens.success500 : ColorTokens.critical500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: FormTokens.fieldGapMd),

          // Split items
          ..._splits.asMap().entries.map((entry) {
            final index = entry.key;
            final split = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < _splits.length - 1 ? FormTokens.fieldGapMd : 0),
              child: _buildSplitItem(
                index: index,
                split: split,
                categoryState: categoryState,
                categoryIconColorService: categoryIconColorService,
              ),
            );
          }),

          SizedBox(height: FormTokens.fieldGapMd),

          // Add split button
          OutlinedButton.icon(
            onPressed: _splits.length >= 10 ? null : _addSplit,
            icon: Icon(Icons.add, size: DesignTokens.iconMd),
            label: Text('Add Split', style: TypographyTokens.labelMd),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, FormTokens.fieldHeightSm),
              side: BorderSide(
                color: _splits.length >= 10 ? ColorTokens.borderSecondary : ColorTokens.borderPrimary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
              ),
              foregroundColor: _splits.length >= 10 ? ColorTokens.textSecondary : ColorTokens.teal500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitItem({
    required int index,
    required TransactionSplit split,
    required AsyncValue categoryState,
    required dynamic categoryIconColorService,
  }) {
    return Container(
      padding: EdgeInsets.all(FormTokens.fieldPaddingH),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.borderSecondary,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Split ${index + 1}',
                style: TypographyTokens.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const Spacer(),
              if (_splits.length > 1)
                IconButton(
                  onPressed: () => _removeSplit(index),
                  icon: Icon(
                    Icons.remove_circle_outline,
                    size: DesignTokens.iconMd,
                    color: ColorTokens.critical500,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: FormTokens.fieldGapSm),

          // Category selection
          categoryState.when(
            data: (state) {
              final categories = state.getCategoriesByType(_selectedType);
              return CategoryButtonSelector(
                categories: categories,
                selectedCategoryId: split.categoryId.isNotEmpty ? split.categoryId : null,
                onCategorySelected: (categoryId) {
                  if (categoryId != null) {
                    final updatedSplit = split.copyWith(categoryId: categoryId);
                    _updateSplit(index, updatedSplit);
                  }
                },
                categoryIconColorService: categoryIconColorService,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading categories: $error'),
          ),

          SizedBox(height: FormTokens.fieldGapSm),

          // Amount and percentage row
          Row(
            children: [
              Expanded(
                child: EnhancedTextField(
                  controller: _amountControllers[index] ??= TextEditingController(text: split.amount > 0 ? split.amount.toStringAsFixed(2) : ''),
                  label: 'Amount',
                  hint: '0.00',
                  prefix: Icon(
                    Icons.attach_money,
                    color: FormTokens.iconColor,
                    size: DesignTokens.iconSm,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (value) => _updateSplitAmount(index, value ?? ''),
                ),
              ),
              SizedBox(width: FormTokens.fieldGapSm),
              Expanded(
                child: EnhancedTextField(
                  controller: _percentageControllers[index] ??= TextEditingController(text: split.percentage > 0 ? split.percentage.toStringAsFixed(1) : ''),
                  label: 'Percentage',
                  hint: '0.0',
                  suffix: Text('%', style: TypographyTokens.captionMd),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                  ],
                  onChanged: (value) => _updateSplitPercentage(index, value ?? ''),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            setState(() {
              _selectedDate = date;
            });
          }
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48.0),
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

  Future<void> _submitSplitTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate splits
    if (_splits.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Split transactions require at least 2 splits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_splits.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 splits allowed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if all splits have categories
    for (final split in _splits) {
      if (split.categoryId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category for all splits'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Check for zero or negative amounts
    for (int i = 0; i < _splits.length; i++) {
      if (_splits[i].amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Split ${i + 1} must have a positive amount'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Check if amounts are valid
    if (_remainingAmount.abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Split amounts must total \$${NumberFormat.currency(symbol: '', decimalDigits: 2).format(double.parse(_totalAmountController.text))}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check percentage sum
    final totalPercentage = _splits.fold<double>(0.0, (sum, split) => sum + split.percentage);
    if ((totalPercentage - 100.0).abs() > 0.1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Split percentages must total 100%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final totalAmount = double.parse(_totalAmountController.text);

      final splitTransaction = SplitTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'Split Transaction',
        totalAmount: totalAmount,
        type: _selectedType,
        date: _selectedDate,
        accountId: _selectedAccountId!,
        splits: _splits,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      await widget.onSubmit(splitTransaction);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}