import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
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
   bool _isValidatingName = false;
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
        padding: AppTheme.screenPaddingAll,
        children: [
          // Show error message if there's a budget update error (but not duplicate name error)
          if (budgetState.value?.error != null &&
              !budgetState.value!.error!.contains('Budget names must be unique'))
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      budgetState.value!.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Show name field error highlighting if there's a duplicate name error
          if (budgetState.value?.error != null &&
              budgetState.value!.error!.contains('Budget names must be unique'))
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please choose a different budget name',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Existing budgets: ${_getExistingBudgetNames(budgetState, widget.budget.id)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          // Budget Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Budget Name',
                  hintText: 'e.g., Monthly Expenses',
                  errorStyle: const TextStyle(height: 0.8),
                  errorBorder: (_nameValidationError != null ||
                          (budgetState.value?.error != null &&
                              budgetState.value!.error!.contains('Budget names must be unique')))
                      ? OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        )
                      : null,
                  focusedErrorBorder: (_nameValidationError != null ||
                          (budgetState.value?.error != null &&
                              budgetState.value!.error!.contains('Budget names must be unique')))
                      ? OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        )
                      : null,
                  suffixIcon: _isValidatingName
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
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
                autofocus: false,
              ),
              // Show instant validation feedback
              if (_nameValidationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _nameValidationError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Describe your budget...',
            ),
            maxLength: 200,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

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
          const SizedBox(height: 16),

          // Budget Type
          DropdownButtonFormField<BudgetType>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Budget Type',
            ),
            items: BudgetType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Budget Period (Creation Date to End Date)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: DateFormat('MMM dd, yyyy hh:mm a').format(_createdAt),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Budget Creation Date & Time',
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  onTap: () async {
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
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _createdAt,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_createdAt),
                        );
                        setState(() {
                          _createdAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time?.hour ?? _createdAt.hour,
                            time?.minute ?? _createdAt.minute,
                          );
                          // Auto-adjust end date if it's before creation date
                          if (_endDate.isBefore(_createdAt)) {
                            _endDate = _createdAt.add(const Duration(days: 30));
                          }
                        });
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: DateFormat('MMM dd, yyyy hh:mm a').format(_endDate),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Budget End Date & Time',
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _createdAt,
                      lastDate: _createdAt.add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_endDate),
                      );
                      setState(() {
                        _endDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time?.hour ?? _endDate.hour,
                          time?.minute ?? _endDate.minute,
                        );
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Creation Date/Time Picker (with warning)
          // TextFormField(
          //   readOnly: true,
          //   controller: TextEditingController(
          //     text: DateFormat('MMM dd, yyyy hh:mm a').format(_createdAt),
          //   ),
          //   decoration: const InputDecoration(
          //     labelText: 'Budget Creation Date & Time',
          //     hintText: 'When should transaction tracking start?',
          //     suffixIcon: Icon(Icons.calendar_today, size: 20),
          //   ),
          //   onTap: () async {
          //     final confirmed = await showDialog<bool>(
          //       context: context,
          //       builder: (context) => AlertDialog(
          //         title: const Text('Warning'),
          //         content: const Text(
          //             'Changing the budget creation date will affect which transactions are tracked. '
          //             'Only transactions made after the new creation date will be included in budget calculations. '
          //             'This may significantly change your budget status. Are you sure you want to continue?'),
          //         actions: [
          //           TextButton(
          //             onPressed: () => Navigator.pop(context, false),
          //             child: const Text('Cancel'),
          //           ),
          //           TextButton(
          //             onPressed: () => Navigator.pop(context, true),
          //             child: const Text('Continue'),
          //           ),
          //         ],
          //       ),
          //     );

          //     if (confirmed == true) {
          //       final date = await showDatePicker(
          //         context: context,
          //         initialDate: _createdAt,
          //         firstDate: DateTime.now().subtract(const Duration(days: 365)),
          //         lastDate: DateTime.now().add(const Duration(days: 1)),
          //       );
          //       if (date != null) {
          //         final time = await showTimePicker(
          //           context: context,
          //           initialTime: TimeOfDay.fromDateTime(_createdAt),
          //         );
          //         setState(() {
          //           _createdAt = DateTime(
          //             date.year,
          //             date.month,
          //             date.day,
          //             time?.hour ?? _createdAt.hour,
          //             time?.minute ?? _createdAt.minute,
          //           );
          //         });
          //       }
          //     }
          //   },
          // ),
          // const SizedBox(height: 8),
          // Text(
          //   '⚠️ Changing this date will affect which transactions are tracked against this budget.',
          //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
          //         color: Theme.of(context).colorScheme.error,
          //       ),
          // ),
          // const SizedBox(height: 24),

          // Categories Section
          Row(
            children: [
              Text(
                'Budget Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category List
          ..._categories.map((category) => _buildCategoryItem(
              category, expenseCategories, categoryIconColorService)),
          const SizedBox(height: 16),

          // Total Budget Display
          Card(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Total Budget:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${NumberFormat('#,##0.00').format(_calculateTotalBudget())}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => _submitBudget(expenseCategories),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Budget'),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: category.selectedCategoryId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              items: expenseCategories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Row(
                    children: [
                      Icon(
                        categoryIconColorService.getIconForCategory(cat.id),
                        size: 20,
                        color: categoryIconColorService
                            .getColorForCategory(cat.id),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    category.selectedCategoryId = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Amount Field and Delete Button Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: category.amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                      hintText: '0.00',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
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
                ),
                if (_categories.length > 1) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: IconButton(
                      onPressed: () => _removeCategory(category),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Remove Category',
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
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

  void _setupNameValidationListener() {
    _nameController.addListener(_onNameChanged);
  }

   void _onNameChanged() {
     final name = _nameController.text.trim();

     // Clear validation error if name is empty
     if (name.isEmpty) {
       setState(() {
         _nameValidationError = null;
         _isValidatingName = false;
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
       _isValidatingName = true;
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
           _isValidatingName = false;
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
           _isValidatingName = false;
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
