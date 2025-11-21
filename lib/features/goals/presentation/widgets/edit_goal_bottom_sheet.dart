import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/widgets/custom_numeric_keyboard.dart';
import '../../../transactions/domain/services/category_icon_color_service.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/goal.dart';

/// Bottom sheet for editing an existing goal
class EditGoalBottomSheet extends ConsumerStatefulWidget {
  const EditGoalBottomSheet({
    super.key,
    required this.goal,
    required this.onSubmit,
  });

  final Goal goal;
  final Future<void> Function(Goal updatedGoal) onSubmit;

  @override
  ConsumerState<EditGoalBottomSheet> createState() => _EditGoalBottomSheetState();
}

class _EditGoalBottomSheetState extends ConsumerState<EditGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // Amount variables with editing flags to prevent controller interference
  late double _targetAmount;
  late double _currentAmount;
  int? _editingTargetAmountIndex;
  int? _editingCurrentAmountIndex;

  late PriorityLevel _selectedPriority;
  late String _selectedCategoryId;
  late DateTime _selectedDeadline;

  bool _isSubmitting = false;

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _descriptionController = TextEditingController(text: widget.goal.description);

    // Initialize amount variables
    _targetAmount = widget.goal.targetAmount;
    _currentAmount = widget.goal.currentAmount;

    _selectedPriority = _goalPriorityToPriorityLevel(widget.goal.priority);
    _selectedCategoryId = widget.goal.categoryId;
    _selectedDeadline = widget.goal.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: spacing_md),
            child: Row(
              children: [
                Text(
                  'Edit Goal',
                  style: ModernTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                        return ModernCategorySelector(
                          categories: categories.map((category) {
                            final iconAndColor = categoryService.getIconAndColorForCategory(category.id);
                            return CategoryItem(
                              id: category.id,
                              name: category.name,
                              icon: iconAndColor.icon,
                              color: iconAndColor.color.toARGB32(),
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
                          color: ModernColors.error.withValues(alpha: 0.1),
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

                // Current Amount
                ModernTextField(
                  controller: TextEditingController(text: _currentAmount.toStringAsFixed(2)),
                  label: 'Current Amount (optional)',
                  placeholder: '0.00',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      _currentAmount = double.tryParse(value ?? '0') ?? 0.0;
                    });
                  },
                ),
                const SizedBox(height: spacing_md),

                // Goal Title
                ModernTextField(
                  controller: _titleController,
                  // label: 'Goal Title',
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

                // Description
                ModernTextField(
                  controller: _descriptionController,
                  // label: 'Description',
                  prefixIcon: Icons.description,
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

                // Priority
                ModernPrioritySelector(
                  label: 'Priority',
                  selectedPriority: _selectedPriority,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: spacing_xl),

                // Action Button
                ModernActionButton(
                  text: 'Update Goal',
                  onPressed: _isSubmitting ? null : _submitGoal,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: spacing_lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final targetAmount = _targetAmount;
      final currentAmount = _currentAmount;

      final updatedGoal = widget.goal.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: _selectedDeadline,
        priority: _priorityLevelToGoalPriority(_selectedPriority),
        categoryId: _selectedCategoryId,
        updatedAt: DateTime.now(),
      );

      await widget.onSubmit(updatedGoal);
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