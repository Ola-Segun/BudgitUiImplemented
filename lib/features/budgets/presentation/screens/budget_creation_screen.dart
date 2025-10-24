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
import '../../domain/entities/budget_template.dart';
import '../providers/budget_providers.dart';
import '../states/budget_state.dart';

/// Screen for creating a new budget
class BudgetCreationScreen extends ConsumerStatefulWidget {
  const BudgetCreationScreen({super.key});

  @override
  ConsumerState<BudgetCreationScreen> createState() => _BudgetCreationScreenState();
}

class _BudgetCreationScreenState extends ConsumerState<BudgetCreationScreen> {
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

   double _totalBudget = 0.0;
   Timer? _debounceTimer;
   bool _isTotalUpdating = false;

   // Reactive validation state
   String? _nameValidationError;
   bool _isValidatingName = false;
   Timer? _nameValidationTimer;
   String _lastValidatedName = '';

  @override
  void initState() {
    super.initState();
    _addCategory();
    _updateTotalBudget();
    _setupNameValidationListener();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _debounceTimer?.cancel();
    _nameValidationTimer?.cancel();
    for (final category in _categories) {
      category.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryNotifierProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    final budgetState = ref.watch(budgetNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Budget'),
      ),
      body: categoryState.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(categoryNotifierProvider.notifier).loadCategories(),
        ),
        data: (state) => _buildForm(context, state.expenseCategories, categoryIconColorService, budgetState),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<TransactionCategory> expenseCategories, CategoryIconColorService categoryIconColorService, AsyncValue<BudgetState> budgetState) {
    _expenseCategories = expenseCategories;
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
          // Show error message if there's a budget creation error (but not duplicate name error)
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
          // if (budgetState.value?.error != null &&
          //     budgetState.value!.error!.contains('Budget names must be unique'))
          //   Container(
          //     margin: const EdgeInsets.only(bottom: 8),
          //     padding: const EdgeInsets.all(8),

          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Row(
          //           children: [
                      
          //             const SizedBox(width: 8),
          //             Expanded(
          //               child: Text(
          //                 'Please choose a different budget name',
          //                 style: TextStyle(
          //                   color: Theme.of(context).colorScheme.error,
          //                   fontSize: 12,
          //                   fontWeight: FontWeight.w400,
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // const Text(
          //   'Start with Template (Optional)',
          //   style: TextStyle(
          //     fontSize: 16,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedTemplate,
            decoration: const InputDecoration(
              labelText: 'Template',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: [
              const DropdownMenuItem(
                value: 'None (Custom)',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('None (Custom)'),
                  ],
                ),
              ),
              const DropdownMenuItem(
                value: '50/30/20 Rule',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('50/30/20 Rule'),
                  ],
                ),
              ),
              // const DropdownMenuItem(
              //   value: 'Zero-Based Budget',
              //   child: Row(
              //     children: [
              //       Icon(Icons.calculate, size: 20, color: Colors.purple),
              //       SizedBox(width: 8),
              //       Text('Zero-Based Budget'),
              //     ],
              //   ),
              // ),
              // const DropdownMenuItem(
              //   value: 'Envelope System',
              //   child: Row(
              //     children: [
              //       Icon(Icons.mail, size: 20, color: Colors.red),
              //       SizedBox(width: 8),
              //       Text('Envelope System'),
              //     ],
              //   ),
              // ),
            ],
            onChanged: _isLoadingTemplate ? null : (value) {
              if (value != null) {
                setState(() {
                  _selectedTemplate = value;
                });
                _onTemplateChanged(value);
              }
            },
          ),
          const SizedBox(height: 16),
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
                autofocus: true,
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

          // // Fixed Creation Date/Time Picker
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
          //     final date = await showDatePicker(
          //       context: context,
          //       initialDate: _createdAt,
          //       firstDate: DateTime.now().subtract(const Duration(days: 365)),
          //       lastDate: DateTime.now().add(const Duration(days: 1)),
          //     );
          //     if (date != null) {
          //       final time = await showTimePicker(
          //         context: context,
          //         initialTime: TimeOfDay.fromDateTime(_createdAt),
          //       );
          //       setState(() {
          //         _createdAt = DateTime(
          //           date.year,
          //           date.month,
          //           date.day,
          //           time?.hour ?? _createdAt.hour,
          //           time?.minute ?? _createdAt.minute,
          //         );
          //       });
          //     }
          //   },
          // ),
          // const SizedBox(height: 8),
          // Text(
          //   'Transactions made after this date/time will be tracked against this budget.',
          //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
          //     color: Theme.of(context).colorScheme.onSurfaceVariant,
          //   ),
          // ),
          // const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Budget Categories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._categories.map((category) => _buildCategoryItem(category, expenseCategories, categoryIconColorService)),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: _isTotalUpdating
                  ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isTotalUpdating
                  ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
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
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _isTotalUpdating
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary,
                          fontSize: _isTotalUpdating ? 18 : 16,
                        ),
                    child: Text(
                      '\$${NumberFormat('#,##0.00').format(_totalBudget)}',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitBudget(expenseCategories),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Budget'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BudgetCategoryFormData category, List<TransactionCategory> expenseCategories, CategoryIconColorService categoryIconColorService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: category.selectedCategoryId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category',
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              items: expenseCategories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Row(
                    children: [
                      Icon(
                        categoryIconColorService.getIconForCategory(cat.id),
                        size: 20,
                        color: categoryIconColorService.getColorForCategory(cat.id),
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
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
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
      _setupCategoryListeners();
      _updateTotalBudget();
    });
  }

  void _removeCategory(BudgetCategoryFormData category) {
    setState(() {
      category.dispose();
      _categories.remove(category);
      _setupCategoryListeners();
      _updateTotalBudget();
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
      _validateBudgetName(name);
    });
  }

  Future<void> _validateBudgetName(String name) async {
    if (!mounted) return;

    try {
      final budgetState = ref.read(budgetNotifierProvider);
      final existingBudgets = budgetState.value?.budgets ?? [];

      // Check for duplicates (case-insensitive)
      final isDuplicate = existingBudgets.any(
        (budget) => budget.name.trim().toLowerCase() == name.toLowerCase(),
      );

      if (mounted) {
        setState(() {
          _isValidatingName = false;
          _lastValidatedName = name;
          _nameValidationError = isDuplicate
              ? 'A budget with this name already exists'
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidatingName = false;
          _nameValidationError = null; // Clear error on failure
        });
      }
    }
  }

  // Handle template changes to reset validation state
  void _onTemplateChanged(String template) async {
    debugPrint('DEBUG: _onTemplateChanged called with template: $template');
    debugPrint('DEBUG: Current _expenseCategories count: ${_expenseCategories.length}');
    for (final cat in _expenseCategories) {
      debugPrint('DEBUG: Available expense category: ${cat.name} (id: ${cat.id})');
    }

    if (template == 'None (Custom)') {
      // Clear any template-based categories and reset to custom
      setState(() {
        _categories.clear();
        _addCategory();
        _selectedType = BudgetType.custom;
        _totalBudget = 0.0;
        // Reset name validation when switching to custom
        _nameValidationError = null;
        _isValidatingName = false;
        _lastValidatedName = '';
      });
      debugPrint('DEBUG: Reset to custom template, categories count: ${_categories.length}');
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

      debugPrint('DEBUG: Selected template: ${selectedTemplate?.name}');
      debugPrint('DEBUG: Template categories count: ${selectedTemplate?.categories.length}');

      if (selectedTemplate != null && mounted) {
        // Clear existing categories
        setState(() {
          _categories.clear();
          _selectedType = selectedTemplate!.type;
          _totalBudget = 0.0;
          // Reset name validation when applying template
          _nameValidationError = null;
          _isValidatingName = false;
          _lastValidatedName = '';
        });

        debugPrint('DEBUG: Cleared categories, now mapping template categories');

        // Map template categories to expense categories
        final unmappedCategories = <String>[];
        int mappedCount = 0;

        for (final templateCategory in selectedTemplate.categories) {
          debugPrint('DEBUG: Processing template category: ${templateCategory.name} (amount: ${templateCategory.amount})');

          // Try to find matching expense category by name similarity
          TransactionCategory? matchedCategory;
          final templateName = templateCategory.name.toLowerCase();

          // First try exact match
          try {
            matchedCategory = _expenseCategories.firstWhere(
              (cat) => cat.name.toLowerCase() == templateName,
            );
            debugPrint('DEBUG: Exact match found for "${templateCategory.name}": ${matchedCategory.name}');
          } catch (e) {
            matchedCategory = null;
            debugPrint('DEBUG: No exact match for "${templateCategory.name}"');
          }

          // If no exact match, try partial match
          if (matchedCategory == null) {
            try {
              matchedCategory = _expenseCategories.firstWhere(
                (cat) => templateName.contains(cat.name.toLowerCase()) ||
                        cat.name.toLowerCase().contains(templateName),
              );
              debugPrint('DEBUG: Partial match found for "${templateCategory.name}": ${matchedCategory.name}');
            } catch (e) {
              matchedCategory = null;
              debugPrint('DEBUG: No partial match for "${templateCategory.name}"');
            }
          }

          // If still no match, try keyword matching
          if (matchedCategory == null) {
            final keywords = templateName.split(' ').where((word) => word.length > 2);
            debugPrint('DEBUG: Trying keyword matching for "${templateCategory.name}" with keywords: $keywords');
            for (final keyword in keywords) {
              try {
                matchedCategory = _expenseCategories.firstWhere(
                  (cat) => cat.name.toLowerCase().contains(keyword),
                );
                debugPrint('DEBUG: Keyword match found for "${templateCategory.name}" with keyword "$keyword": ${matchedCategory?.name}');
                break;
                            } catch (e) {
                continue;
              }
            }
          }

          if (matchedCategory != null) {
            final categoryData = BudgetCategoryFormData();
            categoryData.selectedCategoryId = matchedCategory.id;
            categoryData.amountController.text = templateCategory.amount.toStringAsFixed(2);
            _categories.add(categoryData);
            _totalBudget += templateCategory.amount;
            mappedCount++;
            debugPrint('DEBUG: Successfully mapped category ${templateCategory.name} to ${matchedCategory.name}, total categories now: ${_categories.length}');
          } else {
            unmappedCategories.add(templateCategory.name);
            debugPrint('DEBUG: Could not map category: ${templateCategory.name}');
          }
        }

        debugPrint('DEBUG: Template mapping complete. Mapped: $mappedCount, Unmapped: ${unmappedCategories.length}');
        debugPrint('DEBUG: Final categories count: ${_categories.length}, Total budget: $_totalBudget');

        // Show warning for unmapped categories
        if (unmappedCategories.isNotEmpty && mounted) {
          debugPrint('DEBUG: Showing unmapped categories warning: $unmappedCategories');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Some template categories could not be mapped: ${unmappedCategories.join(', ')}. '
                'Please select appropriate categories manually.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }

        // Update name if it's still default or empty
        if (_nameController.text.isEmpty || _nameController.text == 'Monthly Expenses') {
          _nameController.text = '${selectedTemplate.name} Budget';
          debugPrint('DEBUG: Updated budget name to: ${_nameController.text}');
        }

        // Setup listeners and update total after template loading
        _setupCategoryListeners();
        _updateTotalBudget();
        debugPrint('DEBUG: Setup listeners and updated total budget');
      }
    } catch (e) {
      debugPrint('DEBUG: Error loading template: $e');
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
        debugPrint('DEBUG: Template loading complete, isLoadingTemplate set to false');
      }
    }
  }

  Future<void> _submitBudget(List<TransactionCategory> expenseCategories) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final totalBudget = _totalBudget;
    if (totalBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total budget must be greater than zero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final categories = _categories.map((categoryData) {
        final selectedCategory = expenseCategories.firstWhere(
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

      final success = await ref
          .read(budgetNotifierProvider.notifier)
          .createBudget(budget);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget created successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        // The error message is already handled by the notifier
        // No need to show a generic error message here
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

String _getExistingBudgetNames(AsyncValue<BudgetState> budgetState) {
  if (budgetState.hasValue) {
    final budgets = budgetState.value!.budgets;
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

  void dispose() {
    amountController.dispose();
  }
}

/// Data class for budget creation from template
class BudgetFromTemplateData {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? createdAt;
  final double totalAmount;
  final String? description;

  const BudgetFromTemplateData({
    required this.name,
    required this.startDate,
    required this.endDate,
    this.createdAt,
    required this.totalAmount,
    this.description,
  });
}

/// Dialog for creating budget from template
class BudgetFromTemplateDialog extends StatefulWidget {
  const BudgetFromTemplateDialog({
    super.key,
    required this.template,
    this.initialCreatedAt,
  });

  final BudgetTemplate template;
  final DateTime? initialCreatedAt;

  @override
  State<BudgetFromTemplateDialog> createState() => _BudgetFromTemplateDialogState();
}

class _BudgetFromTemplateDialogState extends State<BudgetFromTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  DateTime _createdAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameController.text = '${widget.template.name} Budget';
    _totalAmountController.text = widget.template.totalBudget.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create ${widget.template.name} Budget'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Budget Name',
                  hintText: 'e.g., Monthly Budget',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a budget name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalAmountController,
                decoration: const InputDecoration(
                  labelText: 'Total Budget Amount',
                  prefixText: '\$',
                  hintText: '0.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total budget amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
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
                        suffixIcon: Icon(Icons.calendar_today, size: 16),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _createdAt,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
                            if (_endDate.isBefore(_createdAt)) {
                              _endDate = _createdAt.add(const Duration(days: 30));
                            }
                          });
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
                        suffixIcon: Icon(Icons.calendar_today, size: 16),
                      ),
                      style: const TextStyle(fontSize: 13),
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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Describe your budget...',
                ),
                maxLength: 200,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final data = BudgetFromTemplateData(
                name: _nameController.text.trim(),
                startDate: _createdAt,
                endDate: _endDate,
                createdAt: _createdAt,
                totalAmount: double.parse(_totalAmountController.text),
                description: _descriptionController.text.trim().isNotEmpty
                    ? _descriptionController.text.trim()
                    : null,
              );
              Navigator.pop(context, data);
            }
          },
          child: const Text('Create Budget'),
        ),
      ],
    );
  }
}