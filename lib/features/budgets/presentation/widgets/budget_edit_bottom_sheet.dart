import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/modern/modern.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/services/category_icon_color_service.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';

/// Modern budget edit bottom sheet with split transaction-style UI
class BudgetEditBottomSheet extends ConsumerWidget {
  const BudgetEditBottomSheet({
    super.key,
    required this.budget,
    required this.onSubmit,
  });

  final Budget budget;
  final Future<void> Function(Budget) onSubmit;

  static bool _isShowing = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BudgetEditContent(budget: budget, onSubmit: onSubmit);
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Budget budget,
    required Future<void> Function(Budget) onSubmit,
  }) async {
    if (_isShowing) {
      debugPrint('BudgetEditBottomSheet: Already showing, ignoring duplicate call');
      return null;
    }

    if (!context.mounted) {
      debugPrint('BudgetEditBottomSheet: Context not mounted, cannot show bottom sheet');
      return null;
    }

    _isShowing = true;
    debugPrint('BudgetEditBottomSheet: Showing bottom sheet for budget: ${budget.id}');

    try {
      return await showModernBottomSheet<T>(
        context: context,
        builder: (context) => BudgetEditBottomSheet(
          budget: budget,
          onSubmit: onSubmit,
        ),
      );
    } catch (e) {
      debugPrint('BudgetEditBottomSheet: Error showing bottom sheet: $e');
      rethrow;
    } finally {
      _isShowing = false;
      debugPrint('BudgetEditBottomSheet: Bottom sheet dismissed');
    }
  }
}

class _BudgetEditContent extends ConsumerStatefulWidget {
  const _BudgetEditContent({
    required this.budget,
    required this.onSubmit,
  });

  final Budget budget;
  final Future<void> Function(Budget) onSubmit;

  @override
  ConsumerState<_BudgetEditContent> createState() => _BudgetEditState();
}

class _BudgetEditState extends ConsumerState<_BudgetEditContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  BudgetType _selectedType = BudgetType.custom;
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  DateTime _createdAt = DateTime.now();
  final List<BudgetCategoryFormData> _categories = [];
  List<TransactionCategory> _expenseCategories = [];
  bool _allowRollover = false;

  bool _isSubmitting = false;

  double _totalBudget = 0.0;

  // Reactive validation state
  String? _nameValidationError;
  Timer? _nameValidationTimer;
  String _lastValidatedName = '';

  // Split management for amount/percentage
  final Map<int, TextEditingController> _amountControllers = {};
  final Map<int, TextEditingController> _percentageControllers = {};

  // Editing flags to prevent controller updates during user input
  int? _editingAmountIndex;
  int? _editingPercentageIndex;

  // Scroll controller for auto-scrolling to new categories
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize form with existing budget data
    _nameController.text = widget.budget.name;
    _descriptionController.text = widget.budget.description ?? '';
    _selectedType = widget.budget.type;
    _endDate = widget.budget.endDate;
    _createdAt = widget.budget.createdAt;
    _allowRollover = widget.budget.allowRollover;

    // Initialize validation state with current name
    _lastValidatedName = widget.budget.name;

    _setupNameValidationListener();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameValidationTimer?.cancel();
    _scrollController.dispose();
    for (final category in _categories) {
      category.dispose();
    }
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    for (final controller in _percentageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCategory() {
    setState(() {
      _categories.add(BudgetCategoryFormData());
      final index = _categories.length - 1;
      _amountControllers[index] = TextEditingController();
      _percentageControllers[index] = TextEditingController();
      _setupCategoryListeners();
      _updateTotalBudget();
    });

    // Auto-scroll to the newly added category after the next frame
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeCategory(BudgetCategoryFormData category) {
    final index = _categories.indexOf(category);
    setState(() {
      category.dispose();
      _categories.remove(category);
      _amountControllers[index]?.dispose();
      _percentageControllers[index]?.dispose();
      _amountControllers.remove(index);
      _percentageControllers.remove(index);

      // Shift controllers down
      for (int i = index; i < _categories.length; i++) {
        _amountControllers[i] = _amountControllers[i + 1]!;
        _percentageControllers[i] = _percentageControllers[i + 1]!;
      }
      _amountControllers.remove(_categories.length);
      _percentageControllers.remove(_categories.length);

      _setupCategoryListeners();
      _updateTotalBudget();
    });
  }

  void _updateCategoryAmount(int index, String value) {
    _editingAmountIndex = index;

    final amount = double.tryParse(value) ?? 0.0;
    final totalAmount = _calculateTotalBudget();
    final percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0.0;

    setState(() {
      _categories[index].amountController.text = amount.toStringAsFixed(2);
      _updateTotalBudget();
    });

    if (_editingPercentageIndex != index) {
      if (_percentageControllers[index] != null) {
        _percentageControllers[index]!.text = percentage > 0 ? percentage.toStringAsFixed(1) : '';
      }
    }

    Future.delayed(const Duration(milliseconds: 10), () {
      _editingAmountIndex = null;
    });
  }

  void _updateCategoryPercentage(int index, String value) {
    _editingPercentageIndex = index;

    final percentage = double.tryParse(value) ?? 0.0;
    final totalAmount = _calculateTotalBudget();
    final amount = (percentage / 100) * totalAmount;

    setState(() {
      _categories[index].amountController.text = amount.toStringAsFixed(2);
      _updateTotalBudget();
    });

    if (_editingAmountIndex != index) {
      if (_amountControllers[index] != null) {
        _amountControllers[index]!.text = amount > 0 ? amount.toStringAsFixed(2) : '';
      }
    }

    Future.delayed(const Duration(milliseconds: 10), () {
      _editingPercentageIndex = null;
    });
  }

  double _calculateTotalBudget() {
    return _categories.fold(0.0, (total, category) {
      final text = category.amountController.text.trim();
      if (text.isEmpty) return total;
      final amount = double.tryParse(text) ?? 0.0;
      return total + (amount >= 0 ? amount : 0.0);
    });
  }

  void _updateTotalBudget() {
    final newTotal = _calculateTotalBudget();
    if (_totalBudget != newTotal) {
      setState(() {
        _totalBudget = newTotal;
      });
      // Update percentages for all categories
      _updatePercentages();
    }
  }

  void _updatePercentages() {
    final totalAmount = _calculateTotalBudget();
    if (totalAmount > 0) {
      for (int i = 0; i < _categories.length; i++) {
        final amount = double.tryParse(_categories[i].amountController.text) ?? 0.0;
        final percentage = (amount / totalAmount) * 100;

        // Only update percentage controller if not currently being edited
        if (_editingPercentageIndex != i) {
          _percentageControllers[i]?.text = percentage > 0 ? percentage.toStringAsFixed(1) : '';
        }
      }
    }
  }

  void _setupCategoryListeners() {
    for (final category in _categories) {
      category.amountController.removeListener(_updateTotalBudget);
      category.amountController.addListener(_updateTotalBudget);
    }
  }

  IconData _getBudgetTypeIcon(BudgetType type) {
    switch (type) {
      case BudgetType.zeroBased:
        return Icons.account_balance_wallet;
      case BudgetType.fiftyThirtyTwenty:
        return Icons.pie_chart;
      case BudgetType.envelope:
        return Icons.mail;
      case BudgetType.custom:
        return Icons.tune;
    }
  }

  void _setupNameValidationListener() {
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final name = _nameController.text.trim();

    // Clear validation error if name is empty
    if (name.isEmpty) {
      setState(() {
        _nameValidationError = null;
      });
      _nameValidationTimer?.cancel();
      return;
    }

    // Don't validate if name hasn't changed
    if (name == _lastValidatedName) {
      return;
    }

    // Cancel previous timer
    _nameValidationTimer?.cancel();

    // Set validating state
    setState(() {
      _nameValidationError = null;
    });

    // Debounce validation
    _nameValidationTimer = Timer(const Duration(milliseconds: 500), () {
      _validateBudgetName(name);
    });
  }

  Future<void> _validateBudgetName(String name) async {
    if (!mounted) return;

    try {
      final budgetState = ref.read(budgetNotifierProvider);
      final existingBudgets = budgetState.value?.budgets ?? [];

      // Check for duplicates (case-insensitive), excluding current budget
      final isDuplicate = existingBudgets.any(
        (budget) => budget.id != widget.budget.id &&
                   budget.name.trim().toLowerCase() == name.toLowerCase(),
      );

      if (mounted) {
        setState(() {
          _lastValidatedName = name;
          _nameValidationError = isDuplicate
              ? 'A budget with this name already exists'
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nameValidationError = null; // Clear error on failure
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryNotifierProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    final budgetState = ref.watch(budgetNotifierProvider);

    return Form(
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
                      Icons.edit,
                      color: ModernColors.accentGreen,
                      size: 24,
                    ),
                    const SizedBox(width: spacing_sm),
                    Text(
                      'Edit Budget',
                      style: ModernTypography.titleLarge.copyWith(
                        color: ModernColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              if (budgetState.value?.error != null &&
                  !budgetState.value!.error!.contains('Budget names must be unique'))
                Container(
                  margin: const EdgeInsets.only(bottom: spacing_md),
                  padding: const EdgeInsets.all(spacing_sm),
                  decoration: BoxDecoration(
                    color: ModernColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(radius_md),
                    border: Border.all(
                      color: ModernColors.error.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: ModernColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: spacing_xs),
                      Expanded(
                        child: Text(
                          budgetState.value!.error!,
                          style: TypographyTokens.bodyMd.copyWith(
                            color: ColorTokens.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Budget Categories Section
              categoryState.when(
                data: (state) {
                  _expenseCategories = state.expenseCategories;

                  // Initialize categories if not already done
                  if (_categories.isEmpty) {
                    for (final category in widget.budget.categories) {
                      _categories.add(
                          BudgetCategoryFormData.fromDomain(category, state.expenseCategories));
                    }

                    if (_categories.isEmpty) {
                      _addCategory();
                    } else {
                      // Initialize controllers for existing categories
                      for (int i = 0; i < _categories.length; i++) {
                        _amountControllers[i] = TextEditingController(text: _categories[i].amountController.text);
                        _percentageControllers[i] = TextEditingController();
                      }
                      _setupCategoryListeners();
                      // Calculate initial total from existing budget categories
                      _totalBudget = widget.budget.categories.fold(0.0, (sum, cat) => sum + cat.amount);
                      _updatePercentages();
                    }
                  }

                  // Initialize categories with default selections if needed
                  for (final category in _categories) {
                    if (category.selectedCategoryId == null && state.expenseCategories.isNotEmpty) {
                      category.selectedCategoryId = state.expenseCategories.first.id;
                    }
                  }

                  return Column(
                    children: [
                      // Total Budget Display
                      ModernAmountDisplay(
                        amount: _totalBudget,
                        isEditable: false,
                      ),

                      const SizedBox(height: spacing_lg),

                      // Budget Categories Section
                      _buildCategoriesSection(state.expenseCategories, categoryIconColorService),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error loading categories: $error'),
              ),

              const SizedBox(height: spacing_lg),

              // Budget Name
              ModernTextField(
                controller: _nameController,
                // label: 'Budget Name',
                prefixIcon: Icons.title,
                placeholder: 'e.g., Monthly Expenses',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a budget name';
                  }
                  if (value.trim().length < 2) {
                    return 'Budget name must be at least 2 characters';
                  }
                  return null;
                },
                errorText: _nameValidationError ?? (budgetState.value?.error != null &&
                        budgetState.value!.error!.contains('Budget names must be unique')
                    ? 'A budget with this name already exists'
                    : null),
              ),

              const SizedBox(height: spacing_sm),

              // Description
              ModernTextField(
                controller: _descriptionController,
                prefixIcon: Icons.description,
                // label: 'Description (optional)',
                placeholder: 'Describe your budget...',
                maxLength: 200,
              ),

              const SizedBox(height: spacing_sm),

              // Allow Rollover Toggle
              SwitchListTile(
                title: const Text('Allow Budget Rollover'),
                // subtitle:
                //     const Text('Carry over unused funds to the next budget period'),
                value: _allowRollover,
                onChanged: (value) {
                  setState(() {
                    _allowRollover = value;
                  });
                },
              ),

              const SizedBox(height: spacing_sm),

              // Budget Type Label
              Padding(
                padding: const EdgeInsets.only(bottom: spacing_xs),
                child: Text(
                  'Budget Type',
                  style: ModernTypography.labelMedium.copyWith(
                    color: ModernColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Budget Type
              ModernIconToggleButton(
                options: BudgetType.values.map((type) {
                  return IconToggleOption(
                    label: type.displayName,
                    icon: _getBudgetTypeIcon(type),
                    color: ModernColors.accentGreen,
                    value: type.toString(),
                  );
                }).toList(),
                selectedValue: _selectedType.toString(),
                onChanged: (value) {
                  final selectedType = BudgetType.values.firstWhere(
                    (type) => type.toString() == value,
                    orElse: () => BudgetType.custom,
                  );
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedType = selectedType;
                  });
                },
              ),

              const SizedBox(height: spacing_lg),

              // Date Range - Start Date to End Date
              Row(
                children: [
                  // Start Date
                  Expanded(
                    child: Semantics(
                      label: 'Select start date',
                      button: true,
                      value: '${_createdAt.day}/${_createdAt.month}/${_createdAt.year}',
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Warning'),
                              content: const Text(
                                  'Changing the budget creation date will affect which transactions are tracked. '
                                  'Only transactions made after the new creation date will be included in budget calculations. '
                                  'This may significantly change your budget status. Are you sure you want to continue?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Continue'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _createdAt,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null && mounted) {
                              setState(() {
                                _createdAt = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  _createdAt.hour,
                                  _createdAt.minute,
                                );
                                // Auto-adjust end date if it's before creation date
                                if (_endDate.isBefore(_createdAt)) {
                                  _endDate = _createdAt.add(const Duration(days: 30));
                                }
                              });
                            }
                          }
                        },
                        child: Container(
                          height: 48.0,
                          padding: const EdgeInsets.symmetric(horizontal: spacing_md),
                          decoration: BoxDecoration(
                            color: ModernColors.primaryGray,
                            borderRadius: BorderRadius.circular(radius_md),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: ModernColors.textSecondary,
                              ),
                              const SizedBox(width: spacing_sm),
                              Expanded(
                                child: Text(
                                  'Start Date',
                                  style: ModernTypography.bodyLarge.copyWith(
                                    color: ModernColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // "to" text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: spacing_sm),
                    child: Text(
                      'to',
                      style: ModernTypography.bodyLarge.copyWith(
                        color: ModernColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // End Date
                  Expanded(
                    child: Semantics(
                      label: 'Select end date',
                      button: true,
                      value: '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: _createdAt,
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && mounted) {
                            setState(() {
                              _endDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                _endDate.hour,
                                _endDate.minute,
                              );
                            });
                          }
                        },
                        child: Container(
                          height: 48.0,
                          padding: const EdgeInsets.symmetric(horizontal: spacing_md),
                          decoration: BoxDecoration(
                            color: ModernColors.primaryGray,
                            borderRadius: BorderRadius.circular(radius_md),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: ModernColors.textSecondary,
                              ),
                              const SizedBox(width: spacing_sm),
                              Expanded(
                                child: Text(
                                  'End Date',
                                  style: ModernTypography.bodyLarge.copyWith(
                                    color: ModernColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: spacing_lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ModernActionButton(
                      text: 'Cancel',
                      isPrimary: false,
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: spacing_sm),
                  Expanded(
                    child: ModernActionButton(
                      text: 'Update Budget',
                      isPrimary: true,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : () => _submitBudget(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: spacing_lg),
            ],
          ),
        ),
      
    );
  }

  Widget _buildCategoriesSection(List<TransactionCategory> expenseCategories, CategoryIconColorService categoryIconColorService) {
    return Container(
      padding: const EdgeInsets.all(spacing_sm),
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
                Icons.account_balance_wallet,
                size: 20,
                color: ModernColors.accentGreen,
              ),
              const SizedBox(width: spacing_sm),
              Text(
                'Budget Categories',
                style: ModernTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: ModernColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 16,
                    color: ModernColors.accentGreen,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _addCategory();
                  },
                  tooltip: 'Add Category',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),

          const SizedBox(height: spacing_sm),

          // Category items
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: _categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  return Padding(
                    key: ValueKey(category),
                    padding: EdgeInsets.only(
                      bottom: index < _categories.length - 1 ? spacing_sm : 0,
                    ),
                    child: _buildCategoryItem(category, expenseCategories, categoryIconColorService, index),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BudgetCategoryFormData category, List<TransactionCategory> expenseCategories, CategoryIconColorService categoryIconColorService, int index) {
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
                'Category ${index + 1}',
                style: ModernTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_categories.length > 1)
                IconButton(
                  onPressed: () => _removeCategory(category),
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: ModernColors.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Remove Category',
                ),
            ],
          ),

          const SizedBox(height: spacing_xs),

          // Category selection
          Builder(
            builder: (context) {
              final categoryItems = expenseCategories.map((cat) => CategoryItem(
                id: cat.id,
                name: cat.name,
                icon: categoryIconColorService.getIconForCategory(cat.id),
                color: categoryIconColorService.getColorForCategory(cat.id).value,
              )).toList();

              return ModernCategorySelector(
                categories: categoryItems,
                selectedId: category.selectedCategoryId,
                onChanged: (value) {
                  setState(() {
                    category.selectedCategoryId = value;
                  });
                },
              );
            },
          ),

          // const SizedBox(height: spacing_sm),

          // Amount and percentage inputs
          Row(
            children: [
              // Amount input
              Expanded(
                child: ModernTextField(
                  controller: _amountControllers[index] ??= TextEditingController(text: category.amountController.text),
                  placeholder: 'Amount',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateCategoryAmount(index, value ?? ''),
                ),
              ),

              const SizedBox(width: spacing_sm),

              // Percentage input
              Expanded(
                child: ModernTextField(
                  controller: _percentageControllers[index] ??= TextEditingController(),
                  placeholder: 'Percentage',
                  prefixIcon: Icons.percent,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => _updateCategoryPercentage(index, value ?? ''),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that total budget is greater than 0
    final totalBudget = _calculateTotalBudget();
    if (totalBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total budget must be greater than zero'),
          backgroundColor: ModernColors.error,
        ),
      );
      return;
    }

    // Validate that all categories have valid selections
    for (final categoryData in _categories) {
      if (categoryData.selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select valid categories for all budget items'),
            backgroundColor: ModernColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final categories = _categories.map((categoryData) {
        final selectedCategory = _expenseCategories.firstWhere(
          (cat) => cat.id == categoryData.selectedCategoryId,
          orElse: () => throw Exception('Category not found: ${categoryData.selectedCategoryId}'),
        );
        return BudgetCategory(
          id: selectedCategory.id,
          name: selectedCategory.name,
          amount: double.parse(categoryData.amountController.text),
        );
      }).toList();

      final updatedBudget = widget.budget.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        startDate: _createdAt,
        endDate: _endDate,
        createdAt: _createdAt,
        categories: categories,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        allowRollover: _allowRollover,
      );

      await widget.onSubmit(updatedBudget);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating budget: ${e.toString()}'),
            backgroundColor: ModernColors.error,
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

/// Helper class for category form data
class BudgetCategoryFormData {
  String? selectedCategoryId;
  final TextEditingController amountController = TextEditingController();
  final String? id;

  BudgetCategoryFormData({this.id, this.selectedCategoryId});

  factory BudgetCategoryFormData.fromDomain(
      BudgetCategory category, List<TransactionCategory> expenseCategories) {
    final data = BudgetCategoryFormData(id: category.id);

    // First try to find matching category by ID
    TransactionCategory? matchingCategoryById;
    try {
      matchingCategoryById = expenseCategories.firstWhere(
        (cat) => cat.id == category.id,
      );
    } catch (e) {
      matchingCategoryById = null;
    }

    if (matchingCategoryById != null) {
      // Category still exists, use it
      data.selectedCategoryId = matchingCategoryById.id;
    } else {
      // Category was deleted or ID changed, try to find by name for backward compatibility
      final matchingCategoryByName = expenseCategories.firstWhere(
        (cat) => cat.name.toLowerCase() == category.name.toLowerCase(),
        orElse: () => expenseCategories.isNotEmpty
            ? expenseCategories.first
            : throw Exception('No categories available'),
      );
      data.selectedCategoryId = matchingCategoryByName.id;
    }

    data.amountController.text = category.amount.toString();
    return data;
  }

  void dispose() {
    amountController.dispose();
  }
}