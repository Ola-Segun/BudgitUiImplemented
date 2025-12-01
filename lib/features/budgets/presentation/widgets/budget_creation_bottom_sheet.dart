import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/components/optional_fields_toggle.dart';
import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/widgets/custom_numeric_keyboard.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/services/category_icon_color_service.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_template.dart';
import '../providers/budget_providers.dart';

/// Modern budget creation bottom sheet with split transaction-style UI
class BudgetCreationBottomSheet extends ConsumerWidget {
  const BudgetCreationBottomSheet({
    super.key,
    required this.onSubmit,
  });

  final Future<void> Function(Budget) onSubmit;

  static bool _isShowing = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BudgetCreationContent(onSubmit: onSubmit);
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Future<void> Function(Budget) onSubmit,
  }) async {
    if (_isShowing) {
      debugPrint('BudgetCreationBottomSheet: Already showing, ignoring duplicate call');
      return null;
    }

    if (!context.mounted) {
      debugPrint('BudgetCreationBottomSheet: Context not mounted, cannot show bottom sheet');
      return null;
    }

    _isShowing = true;
    debugPrint('BudgetCreationBottomSheet: Showing bottom sheet');

    try {
      return await showModernBottomSheet<T>(
        context: context,
        builder: (context) => BudgetCreationBottomSheet(onSubmit: onSubmit),
      );
    } catch (e) {
      debugPrint('BudgetCreationBottomSheet: Error showing bottom sheet: $e');
      rethrow;
    } finally {
      _isShowing = false;
      debugPrint('BudgetCreationBottomSheet: Bottom sheet dismissed');
    }
  }
}

class _BudgetCreationContent extends ConsumerStatefulWidget {
  const _BudgetCreationContent({
    required this.onSubmit,
  });

  final Future<void> Function(Budget) onSubmit;

  @override
  ConsumerState<_BudgetCreationContent> createState() => _BudgetCreationState();
}

class _BudgetCreationState extends ConsumerState<_BudgetCreationContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  BudgetType _selectedType = BudgetType.custom;
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  DateTime _createdAt = DateTime.now();
  final List<BudgetCategoryFormData> _categories = [];
  List<TransactionCategory> _expenseCategories = [];

  bool _isSubmitting = false;
  String _selectedTemplate = 'None (Custom)';
  bool _isLoadingTemplate = false;
  bool _showOptionalFields = false;

  double _totalBudget = 0.0;
  Timer? _debounceTimer;
  bool _isTotalUpdating = false;

  // Editing flags to prevent controller updates during user input
  int? _editingAmountIndex;
  int? _editingPercentageIndex;

  // Split management for amount/percentage
  final Map<int, TextEditingController> _amountControllers = {};
  final Map<int, TextEditingController> _percentageControllers = {};

  @override
  void initState() {
    super.initState();
    _addCategory();
    _syncControllers();
    _updateTotalBudget();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _debounceTimer?.cancel();
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
      _setupCategoryListeners();
      _updateTotalBudget();
    });
    _syncControllers();
  }

  void _removeCategory(BudgetCategoryFormData category) {
    setState(() {
      category.dispose();
      _categories.remove(category);
      _syncControllers();
      _setupCategoryListeners();
      _updateTotalBudget();
    });
  }

  void _updateCategoryAmount(int index, String value) {
    _editingAmountIndex = index;

    final amount = double.tryParse(value) ?? 0.0;
    final totalAmount = _totalBudget;
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
    final totalAmount = _totalBudget;
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
        _isTotalUpdating = true;
        _totalBudget = newTotal;
      });

      // Update percentages for all categories
      _updatePercentages();

      // Reset the updating flag after animation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isTotalUpdating = false;
          });
        }
      });
    }
  }

  void _updatePercentages() {
    if (_totalBudget > 0) {
      for (int i = 0; i < _categories.length; i++) {
        final amount = double.tryParse(_categories[i].amountController.text) ?? 0.0;
        final percentage = (amount / _totalBudget) * 100;

        // Only update percentage controller if not currently being edited
        if (_editingPercentageIndex != i) {
          _percentageControllers[i]?.text = percentage > 0 ? percentage.toStringAsFixed(1) : '';
        }
      }
    }
  }

  void _debouncedUpdateTotalBudget() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _updateTotalBudget();
    });
  }

  void _setupCategoryListeners() {
    for (final category in _categories) {
      category.amountController.removeListener(_debouncedUpdateTotalBudget);
      category.amountController.addListener(_debouncedUpdateTotalBudget);
    }
  }

  void _syncControllers() {
    _amountControllers.clear();
    _percentageControllers.clear();
    for (int i = 0; i < _categories.length; i++) {
      final amount = double.tryParse(_categories[i].amountController.text) ?? 0;
      _amountControllers[i] = TextEditingController(text: amount.toStringAsFixed(2));
      final percentage = _totalBudget > 0 ? (amount / _totalBudget) * 100 : 0;
      _percentageControllers[i] = TextEditingController(text: percentage.toStringAsFixed(1));
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

  void _onTemplateChanged(String template) async {
    if (template == 'None (Custom)') {
      setState(() {
        _categories.clear();
        _addCategory();
        _selectedType = BudgetType.custom;
        _totalBudget = 0.0;
      });
      return;
    }

    setState(() => _isLoadingTemplate = true);

    try {
      BudgetTemplate? selectedTemplate;
      switch (template) {
        case '50/30/20 Rule':
          selectedTemplate = BudgetTemplates.fiftyThirtyTwenty;
          break;
        case 'Zero-Based Budget':
          selectedTemplate = BudgetTemplates.zeroBased;
          break;
        case 'Envelope System':
          selectedTemplate = BudgetTemplates.envelope;
          break;
      }

      if (selectedTemplate != null && mounted) {
        setState(() {
          _categories.clear();
          _selectedType = selectedTemplate!.type;
          _totalBudget = 0.0;
        });

        for (final templateCategory in selectedTemplate.categories) {
          TransactionCategory? matchedCategory;
          final templateName = templateCategory.name.toLowerCase();

          // Try exact match
          try {
            matchedCategory = _expenseCategories.firstWhere(
              (cat) => cat.name.toLowerCase() == templateName,
            );
          } catch (e) {
            matchedCategory = null;
          }

          // If no exact match, try partial match
          if (matchedCategory == null) {
            try {
              matchedCategory = _expenseCategories.firstWhere(
                (cat) => templateName.contains(cat.name.toLowerCase()) ||
                        cat.name.toLowerCase().contains(templateName),
              );
            } catch (e) {
              matchedCategory = null;
            }
          }

          if (matchedCategory != null) {
            final categoryData = BudgetCategoryFormData();
            categoryData.selectedCategoryId = matchedCategory.id;
            categoryData.amountController.text = templateCategory.amount.toStringAsFixed(2);
            _categories.add(categoryData);
            _totalBudget += templateCategory.amount;
          }
        }

        if (_nameController.text.isEmpty || _nameController.text == 'Monthly Expenses') {
          _nameController.text = '${selectedTemplate.name} Budget';
        }

        _setupCategoryListeners();
        _updateTotalBudget();
        _syncControllers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading template: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingTemplate = false);
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
                      Icons.account_balance_wallet,
                      color: ModernColors.accentGreen,
                      size: 24,
                    ),
                    const SizedBox(width: spacing_sm),
                    Text(
                      'Create Budget',
                      style: ModernTypography.titleLarge.copyWith(
                        color: ModernColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Total Budget Display
              ModernAmountDisplay(
                amount: _totalBudget,
                isEditable: true,
                onAmountChanged: (amount) {
                  // Update total budget and redistribute percentages
                  final oldTotal = _totalBudget;
                  setState(() {
                    _totalBudget = amount ?? 0;
                  });

                  if (oldTotal > 0 && amount > 0) {
                    // Redistribute amounts proportionally
                    for (int i = 0; i < _categories.length; i++) {
                      final currentAmount = double.tryParse(_categories[i].amountController.text) ?? 0;
                      final newAmount = (currentAmount / oldTotal) * amount;
                      _categories[i].amountController.text = newAmount.toStringAsFixed(2);
                      final percentage = (newAmount / amount) * 100;

                      // Only update controllers if not currently being edited
                      if (_editingAmountIndex != i) {
                        _amountControllers[i]?.text = newAmount > 0 ? newAmount.toStringAsFixed(2) : '';
                      }
                      if (_editingPercentageIndex != i) {
                        _percentageControllers[i]?.text = percentage > 0 ? percentage.toStringAsFixed(1) : '';
                      }
                    }
                  }
                },
                onTap: () async {
                  final result = await showCustomNumericKeyboard(
                    context: context,
                    initialValue: _totalBudget.toStringAsFixed(0),
                    showDecimal: false,
                  );
                  if (result != null) {
                    final amount = double.tryParse(result) ?? 0;
                    setState(() {
                      _totalBudget = amount;
                      _updateTotalBudget();
                    });
                  }
                },
              ),

              const SizedBox(height: spacing_lg),

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
                  for (final category in _categories) {
                    if (category.selectedCategoryId == null && state.expenseCategories.isNotEmpty) {
                      category.selectedCategoryId = state.expenseCategories.first.id;
                    }
                  }

                  return _buildCategoriesSection(state.expenseCategories, categoryIconColorService);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error loading categories: $error'),
              ),

              const SizedBox(height: spacing_lg),

              // Optional Fields Toggle
              OptionalFieldsToggle(
                onChanged: (show) {
                  setState(() {
                    _showOptionalFields = show;
                  });
                },
                label: 'Show optional fields',
              ),

              const SizedBox(height: spacing_lg),

              // Template Selector
              if (_showOptionalFields) ...[
                // Budget Template Label
                Padding(
                  padding: const EdgeInsets.only(bottom: spacing_xs),
                  child: Text(
                    'Budget Template',
                    style: ModernTypography.labelMedium.copyWith(
                      color: ModernColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                ModernIconToggleButton(
                  options: const [
                    IconToggleOption(
                      label: 'Custom',
                      icon: Icons.edit,
                      color: ColorTokens.neutral500,
                      value: 'None (Custom)',
                    ),
                    IconToggleOption(
                      label: '50/30/20',
                      icon: Icons.account_balance_wallet,
                      color: ModernColors.accentGreen,
                      value: '50/30/20 Rule',
                    ),
                    IconToggleOption(
                      label: 'Zero-Based',
                      icon: Icons.tune,
                      color: ModernColors.accentGreen,
                      value: 'Zero-Based Budget',
                    ),
                    IconToggleOption(
                      label: 'Envelope',
                      icon: Icons.mail,
                      color: ModernColors.accentGreen,
                      value: 'Envelope System',
                    ),
                  ],
                  selectedValue: _selectedTemplate,
                  onChanged: (value) {
                    if (!_isLoadingTemplate) {
                      setState(() {
                        _selectedTemplate = value;
                      });
                      _onTemplateChanged(value);
                    }
                  },
                ),

                const SizedBox(height: spacing_lg),
              ],

              // Budget Name
              ModernTextField(
                controller: _nameController,
                prefixIcon: Icons.title,
                // label: 'Budget Name',
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
              ),

              const SizedBox(height: spacing_sm),

              // Description
              if (_showOptionalFields) ...[
                ModernTextField(
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                  // label: 'Description (optional)',
                  placeholder: 'Describe your budget...',
                  maxLength: 200,
                ),

                const SizedBox(height: spacing_sm),
              ],

              // Budget Type
              // if (_showOptionalFields) ...[
              //   modern_dropdown.ModernDropdownSelector<BudgetType>(
              //     label: 'Budget Type',
              //     selectedValue: _selectedType,
              //     items: BudgetType.values.map((type) {
              //       return modern_dropdown.ModernDropdownItem<BudgetType>(
              //         value: type,
              //         label: type.displayName,
              //         icon: _getBudgetTypeIcon(type),
              //         color: ColorTokens.purple600,
              //       );
              //     }).toList(),
              //     onChanged: (value) {
              //       if (value != null) {
              //         HapticFeedback.lightImpact();
              //         setState(() {
              //           _selectedType = value;
              //         });
              //       }
              //     },
              //   ),

              //   const SizedBox(height: spacing_lg),
              // ],

              // Date Range
              if (_showOptionalFields) ...[
                // Start Date to End Date
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
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _createdAt,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _createdAt = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  _createdAt.hour,
                                  _createdAt.minute,
                                );
                                if (_endDate.isBefore(_createdAt)) {
                                  _endDate = _createdAt.add(const Duration(days: 30));
                                }
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
                            if (picked != null) {
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
              ],

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
                      text: 'Create Budget',
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
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Add Category',
                ),
              ),
            ],
          ),

          const SizedBox(height: spacing_sm),

          // Category items
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                children: _categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  return Padding(
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
                child: Semantics(
                  label: 'Amount for category ${index + 1}',
                  child: ModernTextField(
                    controller: _amountControllers[index] ??= TextEditingController(text: category.amountController.text),
                    placeholder: 'Amount',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateCategoryAmount(index, value ?? ''),
                  ),
                ),
              ),

              const SizedBox(width: spacing_sm),

              // Percentage input
              Expanded(
                child: Semantics(
                  label: 'Percentage for category ${index + 1}',
                  child: ModernTextField(
                    controller: _percentageControllers[index] ??= TextEditingController(),
                    placeholder: 'Percentage',
                    prefixIcon: Icons.percent,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => _updateCategoryPercentage(index, value ?? ''),
                  ),
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

    final totalBudget = _totalBudget;
    if (totalBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total budget must be greater than zero'),
          backgroundColor: ModernColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final categories = _categories.map((categoryData) {
        final selectedCategory = _expenseCategories.firstWhere(
          (cat) => cat.id == categoryData.selectedCategoryId,
        );
        return BudgetCategory(
          id: selectedCategory.id,
          name: selectedCategory.name,
          amount: double.parse(categoryData.amountController.text),
        );
      }).toList();

      final budget = Budget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        startDate: _createdAt,
        endDate: _endDate,
        createdAt: _createdAt,
        categories: categories,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        isActive: true,
        allowRollover: false,
      );

      await widget.onSubmit(budget);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  void dispose() {
    amountController.dispose();
  }
}