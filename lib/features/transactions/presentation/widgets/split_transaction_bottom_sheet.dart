
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/widgets/custom_numeric_keyboard.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/split_transaction.dart';
import '../../domain/services/category_icon_color_service.dart';
import '../providers/transaction_providers.dart';
import '../states/category_state.dart';
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
      return await showModernBottomSheet<T>(
        context: context,
        builder: (context) => SplitTransactionBottomSheet(
          onSubmit: onSubmit,
          initialType: initialType,
        ),
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
  final DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  bool _isSubmitting = false;

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

    return ModernBottomSheet(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: spacing_md),
                child: Row(
                  children: [
                    Icon(
                      Icons.call_split,
                      color: ModernColors.accentGreen,
                      size: 24,
                    ),
                    const SizedBox(width: spacing_sm),
                    Text(
                      'Split Transaction',
                      style: ModernTypography.titleLarge.copyWith(
                        color: ModernColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction Type Toggle
              ModernToggleButton(
                options: const ['Expense', 'Income'],
                selectedIndex: _selectedType == TransactionType.expense ? 0 : 1,
                onChanged: (index) {
                  setState(() {
                    _selectedType = index == 0 ? TransactionType.expense : TransactionType.income;
                  });
                },
              ),

              const SizedBox(height: spacing_lg),

              // Total Amount Display
              ModernAmountDisplay(
                amount: double.tryParse(_totalAmountController.text) ?? 0,
                isEditable: true,
                onAmountChanged: (amount) {
                  _totalAmountController.text = amount.toStringAsFixed(0) ?? '0';
                  _updateRemainingAmount();
                },
                onTap: () async {
                  final result = await showCustomNumericKeyboard(
                    context: context,
                    initialValue: _totalAmountController.text,
                    showDecimal: false,
                  );
                  if (result != null) {
                    setState(() {
                      _totalAmountController.text = result;
                      _updateRemainingAmount();
                    });
                  }
                },
              ),

              const SizedBox(height: spacing_lg),

              // Account Selection
              accountsAsync.when(
                data: (accounts) {
                  return ModernDropdownSelector<String>(
                    label: 'Account',
                    selectedValue: _selectedAccountId,
                    items: accounts.map((account) => ModernDropdownItem<String>(
                      value: account.id,
                      label: '${account.displayName} - \$${(account.balance ?? 0).toStringAsFixed(2)}',
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedAccountId = value);
                      }
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error loading accounts: $error'),
              ),

              const SizedBox(height: spacing_lg),

              // Split Configuration
              _buildSplitConfiguration(categoryState, categoryIconColorService),

              const SizedBox(height: spacing_lg),

              // Description
              ModernTextField(
                controller: _descriptionController,
                placeholder: 'Description (optional)',
                prefixIcon: Icons.description_outlined,
                maxLength: 200,
              ),

              const SizedBox(height: spacing_lg),

              // Action Button
              ModernActionButton(
                text: 'Create Split Transaction',
                onPressed: _isSubmitting ? null : _submitSplitTransaction,
                isLoading: _isSubmitting,
              ),

              const SizedBox(height: spacing_lg),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSplitConfiguration(
    AsyncValue<CategoryState> categoryState,
    CategoryIconColorService categoryIconColorService,
  ) {
    return Container(
      padding: const EdgeInsets.all(spacing_md),
      decoration: BoxDecoration(
        color: ModernColors.primaryGray,
        borderRadius: BorderRadius.circular(radius_md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.call_split,
                size: 20,
                color: ModernColors.accentGreen,
              ),
              const SizedBox(width: spacing_sm),
              Text(
                'Split Details',
                style: ModernTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_splits.length} split${_splits.length == 1 ? '' : 's'}',
                style: ModernTypography.labelMedium.copyWith(
                  color: ModernColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: spacing_md),

          // Remaining amount indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: spacing_sm, vertical: spacing_xs),
            decoration: BoxDecoration(
              color: _remainingAmount >= 0 ? ModernColors.accentGreen.withValues(alpha: 0.1) : ModernColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(radius_sm),
            ),
            child: Row(
              children: [
                Icon(
                  _remainingAmount >= 0 ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: _remainingAmount >= 0 ? ModernColors.accentGreen : ModernColors.error,
                ),
                const SizedBox(width: spacing_xs),
                Text(
                  'Remaining: \$${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_remainingAmount.abs())}',
                  style: ModernTypography.labelMedium.copyWith(
                    color: _remainingAmount >= 0 ? ModernColors.accentGreen : ModernColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: spacing_md),

          // Split items
          ..._splits.asMap().entries.map((entry) {
            final index = entry.key;
            final split = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < _splits.length - 1 ? spacing_sm : 0),
              child: _buildSplitItem(index, split, categoryState, categoryIconColorService),
            );
          }),

          const SizedBox(height: spacing_md),

          // Add split button
          OutlinedButton.icon(
            onPressed: _splits.length >= 10 ? null : _addSplit,
            icon: Icon(Icons.add, size: 18),
            label: Text('Add Split', style: ModernTypography.labelMedium),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              side: BorderSide(
                color: _splits.length >= 10 ? ModernColors.borderColor : ModernColors.accentGreen,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius_md),
              ),
              foregroundColor: _splits.length >= 10 ? ModernColors.textSecondary : ModernColors.accentGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitItem(
    int index,
    TransactionSplit split,
    AsyncValue<CategoryState> categoryState,
    CategoryIconColorService categoryIconColorService,
  ) {
    return Container(
      padding: const EdgeInsets.all(spacing_sm),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_md),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with remove button
          Row(
            children: [
              Text(
                'Split ${index + 1}',
                style: ModernTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_splits.length > 1)
                IconButton(
                  onPressed: () => _removeSplit(index),
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: ModernColors.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          const SizedBox(height: spacing_xs),

          // Category selection
          categoryState.when(
            data: (state) {
              final categories = state.getCategoriesByType(_selectedType).cast<TransactionCategory>();
              final categoryItems = categories.map((cat) => CategoryItem(
                id: cat.id,
                name: cat.name,
                icon: categoryIconColorService.getIconForCategory(cat.id),
                color: categoryIconColorService.getColorForCategory(cat.id).value,
              )).toList();

              return ModernCategorySelector(
                categories: categoryItems,
                selectedId: split.categoryId.isNotEmpty ? split.categoryId : null,
                onChanged: (categoryId) {
                  if (categoryId != null) {
                    final updatedSplit = split.copyWith(categoryId: categoryId);
                    setState(() {
                      _splits[index] = updatedSplit;
                    });
                  }
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading categories: $error'),
          ),

          const SizedBox(height: spacing_sm),

          // Amount and percentage inputs
          Row(
            children: [
              // Amount input
              Expanded(
                child: ModernTextField(
                  controller: _amountControllers[index] ??= TextEditingController(text: split.amount > 0 ? split.amount.toStringAsFixed(0) : ''),
                  placeholder: 'Amount',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateSplitAmount(index, value),
                ),
              ),

              const SizedBox(width: spacing_sm),

              // Percentage input
              Expanded(
                child: ModernTextField(
                  controller: _percentageControllers[index] ??= TextEditingController(text: split.percentage > 0 ? split.percentage.toStringAsFixed(1) : ''),
                  placeholder: 'Percentage',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => _updateSplitPercentage(index, value),
                ),
              ),
            ],
          ),
        ],
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
        title: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text
            : 'Split Transaction',
        totalAmount: totalAmount,
        type: _selectedType,
        date: _selectedDate,
        accountId: _selectedAccountId!,
        splits: _splits,
        description: _descriptionController.text.trim().isNotEmpty
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