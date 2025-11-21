import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/services/category_icon_color_service.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_template.dart';
import '../providers/goal_providers.dart';

/// Bottom sheet for creating a new goal
class CreateGoalBottomSheet extends ConsumerStatefulWidget {
  const CreateGoalBottomSheet({
    super.key,
    this.selectedTemplate,
  });

  final GoalTemplate? selectedTemplate;

  static Future<void> show(
    BuildContext context, {
    GoalTemplate? selectedTemplate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateGoalBottomSheet(selectedTemplate: selectedTemplate),
    );
  }

  @override
  ConsumerState<CreateGoalBottomSheet> createState() => _CreateGoalBottomSheetState();
}

class _CreateGoalBottomSheetState extends ConsumerState<CreateGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _targetAmount = 0.0;
  double _currentAmount = 0.0;

  GoalPriority _selectedPriority = GoalPriority.medium;

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

  // Convert PriorityLevel back to GoalPriority
  GoalPriority _priorityLevelToGoalPriority(PriorityLevel? priority) {
    switch (priority) {
      case PriorityLevel.low:
        return GoalPriority.low;
      case PriorityLevel.medium:
        return GoalPriority.medium;
      case PriorityLevel.high:
        return GoalPriority.high;
      case PriorityLevel.urgent:
        return GoalPriority.high; // Map urgent to high
      case null:
        return GoalPriority.medium;
    }
  }
  String? _selectedCategoryId;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 365));

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields if template is provided
    debugPrint('CreateGoalBottomSheet: initState called with template: ${widget.selectedTemplate?.name ?? 'null'}');
    if (widget.selectedTemplate != null) {
      debugPrint('CreateGoalBottomSheet: Pre-populating fields with template data');
      _titleController.text = widget.selectedTemplate!.name;
      _descriptionController.text = widget.selectedTemplate!.description;
      _targetAmount = widget.selectedTemplate!.suggestedAmount;
      _selectedPriority = widget.selectedTemplate!.defaultPriority;
      _selectedCategoryId = widget.selectedTemplate!.categoryId;
      _selectedDeadline = widget.selectedTemplate!.suggestedDeadline;
    } else {
      debugPrint('CreateGoalBottomSheet: No template provided, using default values');
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
                  'Create Goal',
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
                    setState(() {
                      _targetAmount = value;
                    });
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

                // Current Amount (optional)
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
                  selectedPriority: _goalPriorityToPriorityLevel(_selectedPriority),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = _priorityLevelToGoalPriority(value);
                      });
                    }
                  },
                ),

                const SizedBox(height: spacing_xl),

                // Action Button
                ModernActionButton(
                  text: 'Create Goal',
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
        priority: _selectedPriority,
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
