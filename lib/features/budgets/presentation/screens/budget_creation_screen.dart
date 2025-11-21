import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/components/category_button_selector.dart';
import '../../../../core/design_system/components/optional_fields_toggle.dart';
import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/modern/modern_dropdown_selector.dart' as modern_dropdown;
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
   bool _showOptionalFields = false;

   double _totalBudget = 0.0;
   Timer? _debounceTimer;
   bool _isTotalUpdating = false;

  @override
  void initState() {
    super.initState();
    _addCategory();
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
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        children: [
          // Total Budget Display (moved to very top)
          ModernAmountDisplay(
            amount: _totalBudget,
            isEditable: false,
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationNormal),

          SizedBox(height: FormTokens.sectionGap),

          // Show error message if there's a budget creation error (but not duplicate name error)
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
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

          // Budget Categories Section (split-style UI)
          _buildCategoriesSection(expenseCategories, categoryIconColorService),

          SizedBox(height: FormTokens.sectionGap),

          // Optional Fields Toggle
          OptionalFieldsToggle(
            onChanged: (show) {
              setState(() {
                _showOptionalFields = show;
              });
            },
            label: 'Show optional fields',
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

          SizedBox(height: FormTokens.sectionGap),
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
          // Template Selector
         if (_showOptionalFields) ...[
           modern_dropdown.ModernDropdownSelector<String>(
             label: 'Template',
             placeholder: 'Choose a budget template',
             selectedValue: _selectedTemplate,
             items: [
               modern_dropdown.ModernDropdownItem<String>(
                 value: 'None (Custom)',
                 label: 'None (Custom)',
                 icon: Icons.edit,
                 color: ColorTokens.neutral500,
               ),
               modern_dropdown.ModernDropdownItem<String>(
                 value: '50/30/20 Rule',
                 label: '50/30/20 Rule',
                 icon: Icons.account_balance_wallet,
                 color: ColorTokens.success500,
               ),
             ],
             onChanged: (value) {
               if (value != null && !_isLoadingTemplate) {
                 HapticFeedback.lightImpact();
                 setState(() {
                   _selectedTemplate = value;
                 });
                 _onTemplateChanged(value);
               }
             },
           ).animate()
             .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
             .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

           SizedBox(height: FormTokens.sectionGap),
         ],

          SizedBox(height: FormTokens.sectionGap),
          // Budget Name with async validation
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
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 800.ms : 400.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 800.ms : 400.ms),

          SizedBox(height: FormTokens.fieldGapMd),
          // Description
          if (_showOptionalFields) ...[
            ModernTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              placeholder: 'Describe your budget...',
              maxLength: 200,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 900.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 900.ms),

            SizedBox(height: FormTokens.fieldGapMd),
          ],

          // Budget Type
          if (_showOptionalFields) ...[
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
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

            SizedBox(height: FormTokens.sectionGap),
          ],

          // Date Range
          if (_showOptionalFields) ...[
            ModernDateTimePicker(
              selectedDate: _createdAt,
              selectedTime: TimeOfDay.fromDateTime(_createdAt),
              onDateChanged: (date) {
                if (date != null) {
                  setState(() {
                    _createdAt = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _createdAt.hour,
                      _createdAt.minute,
                    );
                    if (_endDate.isBefore(_createdAt)) {
                      _endDate = _createdAt.add(const Duration(days: 30));
                    }
                  });
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
                    if (_endDate.isBefore(_createdAt)) {
                      _endDate = _createdAt.add(const Duration(days: 30));
                    }
                  });
                }
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 700.ms),

            SizedBox(height: FormTokens.sectionGap),
          ],

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
              Expanded(child: _buildSubmitButton()),
            ],
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 1000.ms : 700.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 1000.ms : 700.ms),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BudgetCategoryFormData category, List<TransactionCategory> expenseCategories, CategoryIconColorService categoryIconColorService, int index) {
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
                'Category ${index + 1}',
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
              child: _buildCategoryItem(category, expenseCategories, categoryIconColorService, index),
            );
          }),
        ],
      ),
    );
  }



  Widget _buildSubmitButton() {
    return ModernActionButton(
      text: 'Create Budget',
      isPrimary: true,
      isLoading: _isSubmitting,
      onPressed: _isSubmitting ? null : () => _submitBudget(_expenseCategories),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 900.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 900.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationSm, delay: 900.ms);
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
                debugPrint('DEBUG: Keyword match found for "${templateCategory.name}" with keyword "$keyword": ${matchedCategory.name}');
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
        SnackBar(
          content: Text('Total budget must be greater than zero'),
          backgroundColor: ColorTokens.critical500,
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
          SnackBar(
            content: Text('Budget created successfully'),
            backgroundColor: ColorTokens.success500,
          ),
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
            backgroundColor: ColorTokens.critical500,
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