import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/split_transaction.dart';
import '../../domain/services/category_icon_color_service.dart';
import '../providers/transaction_providers.dart';
import '../states/category_state.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../goals/domain/entities/goal_contribution.dart';
import '../../../receipt_scanning/domain/entities/receipt_data.dart';

/// Enhanced add transaction bottom sheet with modern design
class EnhancedAddTransactionBottomSheet extends ConsumerWidget {
  const EnhancedAddTransactionBottomSheet({
    super.key,
    required this.onSubmit,
    this.onSplitSubmit,
    this.initialType,
  });

  final Future<void> Function(Transaction) onSubmit;
  final Future<void> Function(dynamic)? onSplitSubmit; // Can handle SplitTransaction or Transaction
  final TransactionType? initialType;

  // Static flag to prevent multiple instances
  static bool _isShowing = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EnhancedAddTransactionBottomSheetContent(
      onSubmit: onSubmit,
      onSplitSubmit: onSplitSubmit,
      initialType: initialType,
    );
  }

  /// Static method to show the enhanced add transaction bottom sheet
  /// Prevents multiple instances from being shown simultaneously
  static Future<T?> show<T>({
    required BuildContext context,
    required Future<void> Function(Transaction) onSubmit,
    Future<void> Function(dynamic)? onSplitSubmit,
    TransactionType? initialType,
  }) async {
    // Prevent showing multiple instances
    if (_isShowing) {
      return null;
    }

    _isShowing = true;

    try {
      return await showModernBottomSheet<T>(
        context: context,
        builder: (context) => EnhancedAddTransactionBottomSheet(
          onSubmit: onSubmit,
          onSplitSubmit: onSplitSubmit,
          initialType: initialType,
        ),
      );
    } finally {
      // Always reset the flag when the bottom sheet closes, regardless of how it was dismissed
      _isShowing = false;
    }
  }
}

class _EnhancedAddTransactionBottomSheetContent extends ConsumerStatefulWidget {
  const _EnhancedAddTransactionBottomSheetContent({
    required this.onSubmit,
    this.onSplitSubmit,
    this.initialType,
  });

  final Future<void> Function(Transaction) onSubmit;
  final Future<void> Function(dynamic)? onSplitSubmit;
  final TransactionType? initialType;

  @override
  ConsumerState<_EnhancedAddTransactionBottomSheetContent> createState() =>
      _EnhancedAddTransactionBottomSheetState();
}

class _EnhancedAddTransactionBottomSheetState
    extends ConsumerState<_EnhancedAddTransactionBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _selectedType;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedAccountId;

  bool _isSubmitting = false;
  // Remove recurring state since we're using transaction type toggle

  // Goal allocation state
  List<GoalContribution> _goalAllocations = [];

  // Split transaction mode
  bool _isSplitMode = false;

  // Split transaction state
  final List<TransactionSplit> _splits = [];
  final Map<int, TextEditingController> _amountControllers = {};
  final Map<int, TextEditingController> _percentageControllers = {};
  int? _editingAmountIndex;
  int? _editingPercentageIndex;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
    // Add listener to amount controller to trigger rebuilds when amount changes
    _amountController.addListener(_onAmountChanged);

    // Initialize with one empty split
    _addSplit();
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    for (final controller in _percentageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onAmountChanged() {
    // Trigger rebuild when amount changes to show/hide goal allocation section
    setState(() {});
  }

  void _addSplit() {
    setState(() {
      _splits.add(TransactionSplit(
        categoryId: '',
        amount: 0.0,
        percentage: 0.0,
      ));
      _amountControllers[_splits.length - 1] = TextEditingController();
      _percentageControllers[_splits.length - 1] = TextEditingController();
      _updateRemainingAmount();
    });
  }

  void _removeSplit(int index) {
    setState(() {
      _splits.removeAt(index);
      _amountControllers[index]?.dispose();
      _percentageControllers[index]?.dispose();
      _amountControllers.remove(index);
      _percentageControllers.remove(index);

      // Reindex controllers
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

  void _updateSplitAmount(int index, String value) {
    _editingAmountIndex = index;

    final amount = double.tryParse(value) ?? 0.0;
    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    final percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0.0;

    final updatedSplit = _splits[index].copyWith(amount: amount, percentage: percentage);
    setState(() {
      _splits[index] = updatedSplit;
      _updateRemainingAmount();
    });

    if (_editingPercentageIndex != index) {
      _percentageControllers[index]?.text = percentage > 0 ? percentage.toStringAsFixed(1) : '';
    }

    Future.delayed(const Duration(milliseconds: 10), () {
      _editingAmountIndex = null;
    });
  }

  void _updateSplitPercentage(int index, String value) {
    _editingPercentageIndex = index;

    final percentage = double.tryParse(value) ?? 0.0;
    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    final amount = (percentage / 100) * totalAmount;

    final updatedSplit = _splits[index].copyWith(amount: amount, percentage: percentage);
    setState(() {
      _splits[index] = updatedSplit;
      _updateRemainingAmount();
    });

    if (_editingAmountIndex != index) {
      _amountControllers[index]?.text = amount > 0 ? amount.toStringAsFixed(0) : '';
    }

    Future.delayed(const Duration(milliseconds: 10), () {
      _editingPercentageIndex = null;
    });
  }

  void _updateRemainingAmount() {
    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (totalAmount > 0) {
      for (int i = 0; i < _splits.length; i++) {
        final split = _splits[i];
        final percentage = (split.amount / totalAmount) * 100;
        _splits[i] = split.copyWith(percentage: percentage);

        if (_editingAmountIndex != i) {
          _amountControllers[i]?.text = split.amount > 0 ? split.amount.toStringAsFixed(0) : '';
        }
        if (_editingPercentageIndex != i) {
          _percentageControllers[i]?.text = percentage > 0 ? percentage.toStringAsFixed(1) : '';
        }
      }
    }
  }

  double get _remainingAmount {
    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    final allocatedAmount = _splits.fold<double>(0.0, (sum, split) => sum + split.amount);
    return totalAmount - allocatedAmount;
  }

  Widget _buildSplitConfiguration(
    AsyncValue<CategoryState> categoryState,
    AsyncValue<List<Account>> accountsAsync,
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
                        // Remaining amount indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: spacing_sm, vertical: spacing_xs),
            decoration: BoxDecoration(
              color: _remainingAmount >= 0 ? ModernColors.accentGreen.withOpacity(0.1) : ModernColors.error.withOpacity(0.1),
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
              const SizedBox(width: spacing_sm),
              Text(
                // '${_splits.length} split${_splits.length == 1 ? '' : 's'}',
                '${_splits.length}',
                style: ModernTypography.labelMedium.copyWith(
                  color: ModernColors.textSecondary,
                ),
              ),
            ],
          ),

          // const SizedBox(height: spacing_md),

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

          // const SizedBox(height: spacing_sm),

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
                  onChanged: (value) => _updateSplitAmount(index, value ?? ''),
                ),
              ),

              const SizedBox(width: spacing_sm),

              // Percentage input
              Expanded(
                child: ModernTextField(
                  controller: _percentageControllers[index] ??= TextEditingController(text: split.percentage > 0 ? split.percentage.toStringAsFixed(1) : ''),
                  placeholder: 'Percentage',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => _updateSplitPercentage(index, value ?? ''),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure we have valid defaults when dependencies change
    _ensureValidDefaults();
  }

  void _ensureValidDefaults() {
    final categoryState = ref.watch(categoryNotifierProvider);
    final accountsAsync = ref.watch(filteredAccountsProvider);

    categoryState.whenData((state) {
      final categories = state.getCategoriesByType(_selectedType);
      if (_selectedCategoryId == null && categories.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final defaultCategoryId = _getSmartDefaultCategoryId(categories);
            developer.log('Setting default categoryId: $defaultCategoryId for type: $_selectedType');
            setState(() {
              _selectedCategoryId = defaultCategoryId;
            });
          }
        });
      }
    });

    accountsAsync.whenData((accounts) {
      if (_selectedAccountId == null && accounts.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final defaultAccountId = accounts.first.id;
            developer.log('Setting default accountId: $defaultAccountId');
            setState(() {
              _selectedAccountId = defaultAccountId;
            });
          }
        });
      }
    });
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
            // Transaction Type Selector (Income/Expense)
            ModernToggleButton(
              options: const ['Expense', 'Income'],
              selectedIndex: _selectedType == TransactionType.expense ? 0 : 1,
              onChanged: (index) {
                setState(() {
                  _selectedType = index == 0 ? TransactionType.expense : TransactionType.income;
                  // Reset category when type changes so it gets the new default
                  _selectedCategoryId = null;
                });
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal),

            SizedBox(height: spacing_lg),

            // Amount Display (Amount-first design)
ModernAmountDisplay(
  amount: _amountController.text.isEmpty
    ? 0
    : double.parse(_amountController.text),
  isEditable: true,
  onAmountChanged: (newAmount) {
    setState(() {
      _amountController.text = newAmount.toStringAsFixed(0);
    });
  },
).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

            SizedBox(height: spacing_lg),

            // Split Transaction Toggle (only show when amount is entered)
            if (double.tryParse(_amountController.text) != null && double.tryParse(_amountController.text)! > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: spacing_md, vertical: spacing_sm),
                decoration: BoxDecoration(
                  color: ModernColors.primaryGray,
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.call_split,
                      size: 20,
                      color: ModernColors.accentGreen,
                    ),
                    const SizedBox(width: spacing_sm),
                    Expanded(
                      child: Text(
                        'Split across multiple categories',
                        style: ModernTypography.bodyLarge.copyWith(
                          color: ModernColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isSplitMode,
                      onChanged: (value) {
                        setState(() {
                          _isSplitMode = value;
                          if (value) {
                            // Reset category and account when switching to split mode
                            _selectedCategoryId = null;
                            _selectedAccountId = null;
                          }
                        });
                      },
                      activeThumbColor: ModernColors.accentGreen,
                      activeTrackColor: ModernColors.accentGreen.withOpacity(0.3),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing_lg),
            ],

            // Split Configuration (only show when in split mode)
            if (_isSplitMode) ...[
              _buildSplitConfiguration(categoryState, accountsAsync, categoryIconColorService),
              SizedBox(height: spacing_lg),
            ],

            // Category Selection (only show when not in split mode)
            if (!_isSplitMode) ...[
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
                selectedId: _selectedCategoryId,
                onChanged: (value) {
                  developer.log('Category selected: $value');
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms);
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading categories: $error'),
          ),

          SizedBox(height: spacing_md),
            ],

            // Account Selection (show in both regular and split modes)
            accountsAsync.when(
              data: (accounts) {
                return ModernDropdownSelector<String>(
                  label: '',
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
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading accounts: $error'),
            ),

            SizedBox(height: spacing_lg),

            // Date and Time Picker (show in both regular and split modes)
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

            SizedBox(height: spacing_lg),

            // Title Field (show in both regular and split modes)
            ModernTextField(
              controller: _titleController,
              placeholder: 'Title',
              prefixIcon: Icons.title,
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

            SizedBox(height: spacing_lg),

            // Description Field (show in both regular and split modes)
            ModernTextField(
              controller: _descriptionController,
              placeholder: 'Description (optional)',
              prefixIcon: Icons.description_outlined,
              maxLength: 200,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 450.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 450.ms),

            SizedBox(height: spacing_lg),

            // Goal Allocation Selector (only for income transactions and regular mode)
            if (_selectedType == TransactionType.income && !_isSplitMode) ...[
              Builder(
                builder: (context) {
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  // Only show goal allocation if amount is valid and positive
                  if (amount <= 0) {
                    return const SizedBox.shrink();
                  }
                  return ModernGoalAllocationSelector(
                    transactionAmount: amount,
                    transactionType: _selectedType,
                    onAllocationsChanged: (allocations) {
                      setState(() {
                        _goalAllocations = allocations;
                      });
                    },
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms);
                },
              ),

              SizedBox(height: spacing_lg),
            ],

            // Scan Receipt and Confirm Buttons Row (show in both regular and split modes)
            Row(
              children: [
                // Scan Receipt Button (30% - icon only)
                Expanded(
                  flex: 2,
                  child: IconButton(
                    onPressed: _scanReceipt,
                    icon: const Icon(Icons.camera_alt),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    tooltip: 'Scan Receipt',
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms),
                ),

                SizedBox(width: spacing_md),

                // Slide to Confirm (70%)
                Expanded(
                  flex: 7,
                  child: ModernSlideToConfirm(
                    text: 'Slide to Save',
                    onSlideComplete: _isSubmitting ? null : _handleSlideComplete,
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 700.ms),
                ),
              ],
            ),

            // Extra bottom padding to ensure button visibility
            SizedBox(height: spacing_xl),
          ],
        ),
        ),
    );
  }





  String _getSmartDefaultCategoryId(List<TransactionCategory> categories) {
    if (categories.isEmpty) return '';

    final preferredIds = _selectedType == TransactionType.expense
        ? ['food', 'transport', 'shopping']
        : ['salary', 'freelance'];

    for (final preferredId in preferredIds) {
      final category = categories.firstWhere(
        (cat) => cat.id == preferredId,
        orElse: () => categories.first,
      );
      if (category.id == preferredId) return preferredId;
    }

    return categories.first.id;
  }

  Future<void> _scanReceipt() async {
    try {
      // Navigate to receipt scanning screen and wait for result
      final result = await context.push('/scan-receipt');

      if (result != null && result is ReceiptData && mounted) {
        // Populate form fields with receipt data
        setState(() {
          _amountController.text = result.amount.toStringAsFixed(2);
          _titleController.text = result.merchant;
          _selectedDate = result.date;

          // Set category if suggested category is available
          if (result.suggestedCategory != null) {
            _selectedCategoryId = result.suggestedCategory;
          }
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receipt data loaded successfully'),
              backgroundColor: ColorTokens.success500,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning receipt: $e'),
            backgroundColor: ColorTokens.critical500,
          ),
        );
      }
    }
  }


  Future<bool> _handleSlideComplete() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    // Validate amount is a valid double
    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
      }
      return false;
    }

    setState(() => _isSubmitting = true);

    try {
      bool success;
      if (_isSplitMode) {
        success = await _submitSplitTransaction();
      } else {
        success = await _submitRegularTransaction();
      }
      return success;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ColorTokens.critical500,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }


  Future<bool> _submitRegularTransaction() async {
    developer.log('Validation check - selectedAccountId: $_selectedAccountId, selectedCategoryId: $_selectedCategoryId');
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an account and category'),
          backgroundColor: ColorTokens.critical500,
        ),
      );
      return false;
    }

    final amount = double.parse(_amountController.text);

    // Create regular transaction
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Transaction',
      amount: amount,
      type: _selectedType,
      date: _selectedDate,
      categoryId: _selectedCategoryId!,
      accountId: _selectedAccountId!,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      goalAllocations: _goalAllocations.isNotEmpty ? _goalAllocations : null,
    );

    await widget.onSubmit(transaction);

    if (mounted) {
      Navigator.pop(context);
    }
    return true;
  }

  Future<bool> _submitSplitTransaction() async {
    // Validate splits
    if (_splits.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Split transactions require at least 2 splits')),
      );
      return false;
    }

    if (_splits.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 splits allowed')),
      );
      return false;
    }

    // Check categories
    for (final split in _splits) {
      if (split.categoryId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category for all splits')),
        );
        return false;
      }
    }

    // Check amounts
    for (int i = 0; i < _splits.length; i++) {
      if (_splits[i].amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Split ${i + 1} must have a positive amount')),
        );
        return false;
      }
    }

    // Check total
    if (_remainingAmount.abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Split amounts must total the transaction amount')),
      );
      return false;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return false;
    }

    final totalAmount = double.parse(_amountController.text);

    final splitTransaction = SplitTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.isNotEmpty
          ? _titleController.text
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

    if (widget.onSplitSubmit != null) {
      await widget.onSplitSubmit!(splitTransaction);
    } else {
      // Use the transaction notifier to handle split transactions
      final success = await ref
          .read(transactionNotifierProvider.notifier)
          .addSplitTransaction(splitTransaction);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Split transaction added successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add split transaction')),
        );
        return false;
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
    return true;
  }
}