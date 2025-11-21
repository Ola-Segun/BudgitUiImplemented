import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/widgets/custom_numeric_keyboard.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/services/category_icon_color_service.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_template.dart';
import '../providers/goal_providers.dart';

/// Screen for creating a new goal
class GoalCreationScreen extends ConsumerStatefulWidget {
  const GoalCreationScreen({super.key, this.selectedTemplate});

  final GoalTemplate? selectedTemplate;

  @override
  ConsumerState<GoalCreationScreen> createState() => _GoalCreationScreenState();
}

class _GoalCreationScreenState extends ConsumerState<GoalCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _targetAmount = 0.0;
  double _currentAmount = 0.0;

  PriorityLevel _selectedPriority = PriorityLevel.medium;

  // Editing flags to prevent controller interference during multi-digit input
  int? _editingTargetAmountIndex;
  int? _editingCurrentAmountIndex;

  // Convert GoalPriority to PriorityLevel for the widget
  PriorityLevel _goalPriorityToPriorityLevel(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.low:
        return PriorityLevel.low;
      case GoalPriority.medium:
        return PriorityLevel.medium;
      case GoalPriority.high:
        return PriorityLevel.high;
    }
  }

  // Convert PriorityLevel to GoalPriority for storage
  GoalPriority _priorityLevelToGoalPriority(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return GoalPriority.low;
      case PriorityLevel.medium:
        return GoalPriority.medium;
      case PriorityLevel.high:
      case PriorityLevel.urgent:
        return GoalPriority.high; // Map high and urgent to high
    }
  }
  String? _selectedCategoryId;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 365));

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields if template is provided
    debugPrint('GoalCreationScreen: initState called with template: ${widget.selectedTemplate?.name ?? 'null'}');
    if (widget.selectedTemplate != null) {
      debugPrint('GoalCreationScreen: Pre-populating fields with template data');
      _titleController.text = widget.selectedTemplate!.name;
      _descriptionController.text = widget.selectedTemplate!.description;
      _targetAmount = widget.selectedTemplate!.suggestedAmount;
      _selectedPriority = _goalPriorityToPriorityLevel(widget.selectedTemplate!.defaultPriority);
      _selectedCategoryId = widget.selectedTemplate!.categoryId;
      _selectedDeadline = widget.selectedTemplate!.suggestedDeadline;
    } else {
      debugPrint('GoalCreationScreen: No template provided, using default values');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Goal'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.screenPaddingAll,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image placeholder (image-first design)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: ModernColors.primaryGray,
                    borderRadius: BorderRadius.circular(radius_md),
                    border: Border.all(
                      color: ModernColors.borderColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: ModernColors.textSecondary,
                      ),
                      const SizedBox(height: spacing_sm),
                      Text(
                        'Add Image',
                        style: ModernTypography.bodyLarge.copyWith(
                          color: ModernColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: spacing_lg),

                // Goal Title
                ModernTextField(
                  controller: _titleController,
                  label: 'Goal Title',
                  placeholder: 'e.g., Emergency Fund',
                  prefixIcon: Icons.flag,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a goal title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: spacing_md),

                // Target Amount
                ModernAmountDisplay(
                  amount: _targetAmount,
                  isEditable: true,
                  onAmountChanged: (value) {
                    _editingTargetAmountIndex = 0;
                    setState(() {
                      _targetAmount = value ?? 0.0;
                    });
                    Future.delayed(const Duration(milliseconds: 10), () {
                      _editingTargetAmountIndex = null;
                    });
                  },
                  onTap: () async {
                    final result = await showCustomNumericKeyboard(
                      context: context,
                      initialValue: _targetAmount.toStringAsFixed(2),
                      showDecimal: true,
                    );
                    if (result != null) {
                      setState(() {
                        _targetAmount = double.tryParse(result) ?? 0.0;
                      });
                    }
                  },
                  currencySymbol: '\$',
                ),
                const SizedBox(height: spacing_md),

                // Deadline
                ModernDateTimePicker(
                  selectedDate: _selectedDeadline,
                  onDateChanged: (date) {
                    if (date != null) {
                      setState(() {
                        _selectedDeadline = date;
                      });
                    }
                  },
                  showTime: false,
                ),
                const SizedBox(height: spacing_md),

                // Description
                ModernTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  placeholder: 'Describe your goal...',
                  maxLength: 200,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: spacing_md),

                // Current Amount (optional)
                ModernAmountDisplay(
                  amount: _currentAmount,
                  isEditable: true,
                  onAmountChanged: (value) {
                    _editingCurrentAmountIndex = 1;
                    setState(() {
                      _currentAmount = value ?? 0.0;
                    });
                    Future.delayed(const Duration(milliseconds: 10), () {
                      _editingCurrentAmountIndex = null;
                    });
                  },
                  onTap: () async {
                    final result = await showCustomNumericKeyboard(
                      context: context,
                      initialValue: _currentAmount.toStringAsFixed(2),
                      showDecimal: true,
                    );
                    if (result != null) {
                      setState(() {
                        _currentAmount = double.tryParse(result) ?? 0.0;
                      });
                    }
                  },
                  currencySymbol: '\$',
                ),
                const SizedBox(height: spacing_md),

                // Category
                Consumer(
                  builder: (context, ref, child) {
                    final categoryStateAsync = ref.watch(categoryNotifierProvider);
                    final categoryService = CategoryIconColorService(ref.read(categoryNotifierProvider.notifier));

                    return categoryStateAsync.when(
                      data: (categoryState) {
                        final categories = categoryState.expenseCategories;
                        if (categories.isEmpty) {
                          return const Text('No categories available');
                        }

                        // Set default category if not set
                        if (_selectedCategoryId == null && categories.isNotEmpty) {
                          _selectedCategoryId = categories.first.id;
                        }

                        return ModernCategorySelector(
                          categories: categories.map((category) {
                            final iconAndColor = categoryService.getIconAndColorForCategory(category.id);
                            return CategoryItem(
                              id: category.id,
                              name: category.name,
                              icon: iconAndColor.icon,
                              color: iconAndColor.color.value,
                            );
                          }).toList(),
                          selectedId: _selectedCategoryId,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            }
                          },
                        );
                      },
                      loading: () => const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ModernColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(radius_md),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: ModernColors.error,
                            ),
                            const SizedBox(width: spacing_md),
                            Expanded(
                              child: Text(
                                'Error loading categories: $error',
                                style: TextStyle(
                                  color: ModernColors.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: spacing_md),

                // Priority
                ModernIconToggleButton(
                  options: PriorityLevel.values.map((priority) {
                    return IconToggleOption(
                      label: _getPriorityDisplayName(priority),
                      icon: _getPriorityIconForLevel(priority),
                      color: _getPriorityColorForLevel(priority),
                      value: priority.toString(),
                    );
                  }).toList(),
                  selectedValue: _selectedPriority.toString(),
                  onChanged: (value) {
                    final selectedPriority = PriorityLevel.values.firstWhere(
                      (priority) => priority.toString() == value,
                      orElse: () => PriorityLevel.medium,
                    );
                    setState(() {
                      _selectedPriority = selectedPriority;
                    });
                  },
                ),

                const SizedBox(height: spacing_xl),

                // Action Button
                ModernActionButton(
                  text: 'Create Goal',
                  onPressed: _isSubmitting ? null : _submitGoal,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: spacing_lg), // Add bottom padding for keyboard
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPriorityDisplayName(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
      case PriorityLevel.urgent:
        return 'Urgent';
    }
  }

  IconData _getPriorityIconForLevel(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return Icons.arrow_downward;
      case PriorityLevel.medium:
        return Icons.remove;
      case PriorityLevel.high:
        return Icons.arrow_upward;
      case PriorityLevel.urgent:
        return Icons.priority_high;
    }
  }

  Color _getPriorityColorForLevel(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return const Color(0xFF10B981); // Green
      case PriorityLevel.medium:
        return const Color(0xFFF59E0B); // Orange
      case PriorityLevel.high:
        return const Color(0xFFEF4444); // Red
      case PriorityLevel.urgent:
        return const Color(0xFFDC2626); // Dark Red
    }
  }

  Future<void> _submitGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate amounts
    if (_targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid target amount greater than 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentAmount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current amount cannot be negative'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final targetAmount = _targetAmount;
      final currentAmount = _currentAmount;

      final goal = Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: _selectedDeadline,
        priority: _priorityLevelToGoalPriority(_selectedPriority),
        categoryId: _selectedCategoryId!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(goalNotifierProvider.notifier)
          .addGoal(goal);

      if (success && mounted) {
        // Invalidate dashboard to refresh data
        ref.invalidate(dashboardDataProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal created successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create goal'),
            backgroundColor: Colors.red,
          ),
        );
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