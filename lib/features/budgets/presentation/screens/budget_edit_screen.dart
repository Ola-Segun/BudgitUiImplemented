import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/components/category_button_selector.dart';
import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/modern/modern_dropdown_selector.dart' as modern_dropdown;
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/services/category_icon_color_service.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';
import '../states/budget_state.dart';

/// Screen for editing an existing budget
class BudgetEditScreen extends ConsumerStatefulWidget {
  const BudgetEditScreen({
    super.key,
    required this.budget,
  });

  final Budget budget;

  @override
  ConsumerState<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends ConsumerState<BudgetEditScreen> {
   final _formKey = GlobalKey<FormState>();
   final _nameController = TextEditingController();
   final _descriptionController = TextEditingController();

   BudgetType _selectedType = BudgetType.custom;
   DateTime _endDate = DateTime.now().add(const Duration(days: 30));
   DateTime _createdAt = DateTime.now();
   final List<BudgetCategoryFormData> _categories = [];
   bool _allowRollover = false;

   bool _isSubmitting = false;

   // Reactive validation state
   String? _nameValidationError;
   Timer? _nameValidationTimer;
   String _lastValidatedName = '';

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

    // Categories will be initialized in _buildForm when expenseCategories are available
    _setupNameValidationListener();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameValidationTimer?.cancel();
    for (final category in _categories) {
      category.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryNotifierProvider);
    final categoryIconColorService =
        ref.watch(categoryIconColorServiceProvider);
    // Watch for category changes to refresh the form when categories are updated
    final _ = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Budget'),
      ),
      body: categoryState.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.read(categoryNotifierProvider.notifier).loadCategories(),
        ),
        data: (state) {
          // Check if categories are empty and show appropriate error
          if (state.expenseCategories.isEmpty) {
            return ErrorView(
              message:
                  'No expense categories available. Please create categories first.',
              onRetry: () =>
                  ref.read(categoryNotifierProvider.notifier).loadCategories(),
            );
          }
          return _buildForm(
              context, state.expenseCategories, categoryIconColorService);
        },
      ),
    );
  }

  Widget _buildForm(
      BuildContext context,
      List<TransactionCategory> expenseCategories,
      CategoryIconColorService categoryIconColorService) {
    final budgetState = ref.watch(budgetNotifierProvider);

    // Initialize categories if not already done
    if (_categories.isEmpty) {
      for (final category in widget.budget.categories) {
        _categories.add(
            BudgetCategoryFormData.fromDomain(category, expenseCategories));
      }

      if (_categories.isEmpty) {
        _addCategory();
      }
    }

    // Initialize categories with default selections if needed
    for (final category in _categories) {
      if (category.selectedCategoryId == null && expenseCategories.isNotEmpty) {
        category.selectedCategoryId = expenseCategories.first.id;
      }
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        children: [
          // Total Budget Display (moved to very top)
          ModernAmountDisplay(
            amount: _calculateTotalBudget(),
            isEditable: false,
          ),

          SizedBox(height: FormTokens.sectionGap),

          // Show error message if there's a budget update error (but not duplicate name error)
          if (budgetState.value?.error != null &&
              !budgetState.value!.error!.contains('Budget names must be unique'))
            Container(
              margin: EdgeInsets.only(bottom: FormTokens.sectionGap),
              padding: EdgeInsets.all(DesignTokens.spacing3),
              decoration: BoxDecoration(
                color: ColorTokens.critical500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
                border: Border.all(
                  color: ColorTokens.critical500.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: ColorTokens.critical500,
                    size: DesignTokens.iconMd,
                  ),
                  SizedBox(width: DesignTokens.spacing2),
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

          // Budget Categories Section (split-style UI)
          _buildCategoriesSection(expenseCategories, categoryIconColorService),

          SizedBox(height: FormTokens.sectionGap),

          // Budget Name
          ModernTextField(
            controller: _nameController,
            label: 'Budget Name',
            placeholder: 'e.g., Monthly Expenses',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a budget name';
              }
              // Basic client-side validation - full uniqueness check happens in use case
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

          SizedBox(height: FormTokens.fieldGapMd),

          // Description
          ModernTextField(
            controller: _descriptionController,
            label: 'Description (optional)',
            placeholder: 'Describe your budget...',
            maxLength: 200,
          ),

          SizedBox(height: FormTokens.fieldGapMd),

          // Allow Rollover Toggle
          SwitchListTile(
            title: const Text('Allow Budget Rollover'),
            subtitle:
                const Text('Carry over unused funds to the next budget period'),
            value: _allowRollover,
            onChanged: (value) {
              setState(() {
                _allowRollover = value;
              });
            },
          ),

          SizedBox(height: FormTokens.fieldGapMd),

          // Budget Type
          modern_dropdown.ModernDropdownSelector<BudgetType>(
            label: 'Budget Type',
            selectedValue: _selectedType,
            items: BudgetType.values.map((type) {
              return modern_dropdown.ModernDropdownItem<BudgetType>(
                value: type,
                label: type.displayName,
                icon: _getBudgetTypeIcon(type),
                color: ColorTokens.purple600,
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedType = value;
                });
              }
            },
          ),

          SizedBox(height: FormTokens.fieldGapMd),

          // Budget Period (Creation Date to End Date)
          ModernDateTimePicker(
            selectedDate: _createdAt,
            selectedTime: TimeOfDay.fromDateTime(_createdAt),
            onDateChanged: (date) async {
              if (date != null) {
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
                  setState(() {
                    _createdAt = DateTime(
                      date.year,
                      date.month,
                      date.day,
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
            onTimeChanged: (time) {
              if (time != null) {
                setState(() {
                  _createdAt = DateTime(
                    _createdAt.year,
                    _createdAt.month,
                    _createdAt.day,
                    time.hour,
                    time.minute,
                  );
                  // Auto-adjust end date if it's before creation date
                  if (_endDate.isBefore(_createdAt)) {
                    _endDate = _createdAt.add(const Duration(days: 30));
                  }
                });
              }
            },
          ),

          SizedBox(height: FormTokens.sectionGap),

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
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: ModernActionButton(
                  text: 'Update Budget',
                  isPrimary: true,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : () => _submitBudget(expenseCategories),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      BudgetCategoryFormData category,
      List<TransactionCategory> expenseCategories,
      CategoryIconColorService categoryIconColorService) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.borderSecondary,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with remove button
          Row(
            children: [
              Text(
                'Category ${_categories.indexOf(category) + 1}',
                style: TypographyTokens.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const Spacer(),
              if (_categories.length > 1)
                IconButton(
                  onPressed: () => _removeCategory(category),
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: ColorTokens.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Remove Category',
                ),
            ],
          ),

          SizedBox(height: DesignTokens.spacing2),

          // Category selection
          CategoryButtonSelector(
            categories: expenseCategories,
            selectedCategoryId: category.selectedCategoryId,
            onCategorySelected: (value) {
              if (value != null) {
                setState(() {
                  category.selectedCategoryId = value;
                });
              }
            },
            categoryIconColorService: categoryIconColorService,
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
          ),

          SizedBox(height: DesignTokens.spacing3),

          // Amount input
          ModernTextField(
            controller: category.amountController,
            placeholder: 'Amount',
            prefixIcon: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount < 0) {
                return 'Invalid';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _addCategory() {
    setState(() {
      _categories.add(BudgetCategoryFormData());
    });
  }

  void _removeCategory(BudgetCategoryFormData category) {
    setState(() {
      category.dispose();
      _categories.remove(category);
    });
  }

  double _calculateTotalBudget() {
    return _categories.fold(0.0, (total, category) {
      final amount = double.tryParse(category.amountController.text) ?? 0.0;
      return total + amount;
    });
  }

  Widget _buildCategoriesSection(List<TransactionCategory> expenseCategories, CategoryIconColorService categoryIconColorService) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.borderSecondary,
          width: 1.5,
        ),
        boxShadow: DesignTokens.elevationLow,
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
                color: ColorTokens.teal500,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Text(
                'Budget Categories',
                style: TypographyTokens.heading6.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: ColorTokens.teal500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    size: DesignTokens.iconMd,
                    color: ColorTokens.teal500,
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

          SizedBox(height: FormTokens.groupGap),

          // Category items
          ..._categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _categories.length - 1 ? DesignTokens.spacing3 : 0,
              ),
              child: _buildCategoryItem(category, expenseCategories, categoryIconColorService),
            );
          }),
        ],
      ),
    );
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
       debugPrint('DEBUG: Validating budget name (edit): "$name"');
       _validateBudgetName(name);
     });
   }
   Future<void> _validateBudgetName(String name) async {
     if (!mounted) return;

     debugPrint('DEBUG: Starting budget name validation (edit) for: "$name"');

     try {
       final budgetState = ref.read(budgetNotifierProvider);
       final existingBudgets = budgetState.value?.budgets ?? [];

       debugPrint('DEBUG: Found ${existingBudgets.length} existing budgets');

       // Check for duplicates (case-insensitive), excluding current budget
       final isDuplicate = existingBudgets.any(
         (budget) => budget.id != widget.budget.id &&
                    budget.name.trim().toLowerCase() == name.toLowerCase(),
       );

       debugPrint('DEBUG: Validation result - isDuplicate: $isDuplicate');

       if (mounted) {
         setState(() {
           _lastValidatedName = name;
           _nameValidationError = isDuplicate
               ? 'A budget with this name already exists'
               : null;
         });
         debugPrint('DEBUG: Validation completed (edit) - error: ${_nameValidationError ?? "none"}');
       }
     } catch (e) {
       debugPrint('DEBUG: Validation error (edit): $e');
       if (mounted) {
         setState(() {
           _nameValidationError = null; // Clear error on failure
         });
       }
     }
   }

  Future<void> _submitBudget(
      List<TransactionCategory> expenseCategories) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that total budget is greater than 0
    final totalBudget = _calculateTotalBudget();
    if (totalBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total budget must be greater than zero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate that all categories have valid selections
    for (final categoryData in _categories) {
      if (categoryData.selectedCategoryId == null ||
          !expenseCategories
              .any((cat) => cat.id == categoryData.selectedCategoryId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please select valid categories for all budget items'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final categories = _categories.map((categoryData) {
        final selectedCategory = expenseCategories.firstWhere(
          (cat) => cat.id == categoryData.selectedCategoryId,
          orElse: () => throw Exception(
              'Category not found: ${categoryData.selectedCategoryId}'),
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

      debugPrint('[DEBUG] Attempting to update budget with name: "${updatedBudget.name}"');
      final success = await ref
          .read(budgetNotifierProvider.notifier)
          .updateBudget(updatedBudget);

      if (success && mounted) {
        debugPrint('[DEBUG] Budget update successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget updated successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        // Show specific error message if available, otherwise generic message
        final currentBudgetState = ref.read(budgetNotifierProvider);
        final errorMessage = currentBudgetState.value?.error ?? 'Failed to update budget. Please try again.';
        debugPrint('[DEBUG] Budget update failed with error: "$errorMessage"');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('[DEBUG] Budget update threw exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating budget: ${e.toString()}'),
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

String _getExistingBudgetNames(AsyncValue<BudgetState> budgetState, String currentBudgetId) {
  if (budgetState.hasValue) {
    final budgets = budgetState.value!.budgets.where((b) => b.id != currentBudgetId).toList();
    if (budgets.length <= 5) {
      return budgets.map((b) => b.name).join(', ');
    } else {
      final firstFew = budgets.take(3).map((b) => b.name).join(', ');
      return '$firstFew, and ${budgets.length - 3} more';
    }
  }
  return 'Loading...';
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
