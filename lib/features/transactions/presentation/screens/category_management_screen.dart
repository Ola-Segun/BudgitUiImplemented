import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/di/providers.dart' as core_providers;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/cards/app_card.dart';
import '../../../../shared/presentation/widgets/buttons/app_icon_button.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/update_category.dart';
import '../providers/transaction_providers.dart';
import '../../../insights/presentation/providers/insight_providers.dart';

/// Screen for managing transaction categories
class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final categoryStateAsync = ref.watch(categoryNotifierProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          categoryStateAsync.maybeWhen(
            data: (state) => state.isOperationInProgress
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddCategoryDialog(context),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: categoryStateAsync.when(
        data: (categoryState) {
          if (categoryState.categories.isEmpty) {
            return const Center(
              child: Text('No categories found. Add your first category!'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppDimensions.screenPaddingH),
            itemCount: categoryState.categories.length,
            itemBuilder: (context, index) {
              final category = categoryState.categories[index];
              return _buildCategoryTile(category, categoryState.isOperationInProgress, categoryIconColorService);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load categories: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(categoryNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(TransactionCategory category, bool isOperationInProgress, dynamic categoryIconColorService) {
    return Slidable(
      key: ValueKey(category.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          // Edit action (blue)
          SlidableAction(
            onPressed: isOperationInProgress ? null : (_) {
              HapticFeedback.lightImpact();
              _showEditCategoryDialog(context, category);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          // Delete action (red)
          SlidableAction(
            onPressed: isOperationInProgress ? null : (_) {
              HapticFeedback.mediumImpact();
              _confirmDeleteCategory(context, category);
            },
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimensions.spacing2),
        child: AppCard(
          elevation: AppCardElevation.low,
          padding: EdgeInsets.all(AppDimensions.cardPadding),
          child: Row(
            children: [
              Container(
                width: AppDimensions.categoryIconSize,
                height: AppDimensions.categoryIconSize,
                decoration: BoxDecoration(
                  color: Color(category.color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.categoryIconRadius),
                ),
                child: Icon(
                  categoryIconColorService.getIconForCategory(category.id),
                  color: categoryIconColorService.getColorForCategory(category.id),
                  size: AppDimensions.iconMd,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing1),
                    Text(
                      category.type.displayName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIconButton(
                    icon: Icons.edit,
                    onPressed: isOperationInProgress ? null : () => _showEditCategoryDialog(context, category),
                    variant: AppIconButtonVariant.ghost,
                    size: AppIconButtonSize.small,
                  ),
                  SizedBox(width: AppDimensions.spacing1),
                  AppIconButton(
                    icon: Icons.delete,
                    onPressed: isOperationInProgress ? null : () => _confirmDeleteCategory(context, category),
                    variant: AppIconButtonVariant.ghost,
                    size: AppIconButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  Future<void> _showEditCategoryDialog(BuildContext context, TransactionCategory category) async {
    await showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );
  }

  Future<void> _confirmDeleteCategory(BuildContext context, TransactionCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Get the repository and create the use case
      final repository = ref.read(core_providers.transactionCategoryRepositoryProvider);
      final deleteCategory = DeleteCategory(repository);

      // Call the use case
      final result = await deleteCategory(category.id);

      if (mounted) {
        result.when(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category deleted successfully')),
            );
            // Refresh the categories list and dependent providers
            ref.invalidate(transactionCategoriesProvider);
            ref.invalidate(categoryNotifierProvider);
            // Invalidate transaction-related providers that might depend on category display
            ref.invalidate(transactionNotifierProvider);
            ref.invalidate(filteredTransactionsProvider);
            ref.invalidate(transactionStatsProvider);
          },
          error: (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete category: ${failure.message}')),
            );
          },
        );
      }
    }
  }

}

/// Dialog for adding a new category
class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String _selectedIcon = 'category';
  int _selectedColor = 0xFF64748B; // Default gray

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag},
    {'name': 'movie', 'icon': Icons.movie},
    {'name': 'bolt', 'icon': Icons.bolt},
    {'name': 'local_hospital', 'icon': Icons.local_hospital},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'computer', 'icon': Icons.computer},
    {'name': 'trending_up', 'icon': Icons.trending_up},
    {'name': 'category', 'icon': Icons.category},
  ];

  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'Blue', 'color': 0xFF2563EB},
    {'name': 'Green', 'color': 0xFF10B981},
    {'name': 'Red', 'color': 0xFFEF4444},
    {'name': 'Yellow', 'color': 0xFFF59E0B},
    {'name': 'Purple', 'color': 0xFF8B5CF6},
    {'name': 'Pink', 'color': 0xFFEC4899},
    {'name': 'Orange', 'color': 0xFFF97316},
    {'name': 'Cyan', 'color': 0xFF06B6D4},
    {'name': 'Gray', 'color': 0xFF64748B},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Food & Dining',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type selection
              DropdownButtonFormField<TransactionType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                items: TransactionType.values.map((type) {
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

              // Icon selection
              Text('Icon', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableIcons.map((iconData) {
                  final isSelected = _selectedIcon == iconData['name'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconData['name'] as String;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        iconData['icon'] as IconData,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Color selection
              Text('Color', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableColors.map((colorData) {
                  final isSelected = _selectedColor == colorData['color'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorData['color'] as int;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(colorData['color'] as int),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  );
                }).toList(),
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
        FilledButton(
          onPressed: _addCategory,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _addCategory() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Create the category
    final category = TransactionCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      type: _selectedType,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    // Get the repository and create the use case
    final repository = ref.read(core_providers.transactionCategoryRepositoryProvider) as dynamic;
    final addCategory = AddCategory(repository);

    // Call the use case
    addCategory(category).then((result) {
      if (mounted) {
        result.when(
          success: (_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category added successfully')),
            );
            // Refresh the categories list and dependent providers
            ref.invalidate(transactionCategoriesProvider);
            ref.invalidate(categoryNotifierProvider);
            // Invalidate transaction-related providers that might depend on category display
            ref.invalidate(transactionNotifierProvider);
            ref.invalidate(filteredTransactionsProvider);
            ref.invalidate(transactionStatsProvider);
            // Invalidate dashboard and insights that might use category data
            ref.invalidate(insightNotifierProvider);
          },
          error: (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add category: ${failure.message}')),
            );
          },
        );
      }
    });
  }
}

/// Dialog for editing an existing category
class EditCategoryDialog extends ConsumerStatefulWidget {
  const EditCategoryDialog({
    super.key,
    required this.category,
  });

  final TransactionCategory category;

  @override
  ConsumerState<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends ConsumerState<EditCategoryDialog> {
  late final TextEditingController _nameController;
  late TransactionType _selectedType;
  late String _selectedIcon;
  late int _selectedColor;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag},
    {'name': 'movie', 'icon': Icons.movie},
    {'name': 'bolt', 'icon': Icons.bolt},
    {'name': 'local_hospital', 'icon': Icons.local_hospital},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'computer', 'icon': Icons.computer},
    {'name': 'trending_up', 'icon': Icons.trending_up},
    {'name': 'category', 'icon': Icons.category},
  ];

  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'Blue', 'color': 0xFF2563EB},
    {'name': 'Green', 'color': 0xFF10B981},
    {'name': 'Red', 'color': 0xFFEF4444},
    {'name': 'Yellow', 'color': 0xFFF59E0B},
    {'name': 'Purple', 'color': 0xFF8B5CF6},
    {'name': 'Pink', 'color': 0xFFEC4899},
    {'name': 'Orange', 'color': 0xFFF97316},
    {'name': 'Cyan', 'color': 0xFF06B6D4},
    {'name': 'Gray', 'color': 0xFF64748B},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedType = widget.category.type;
    _selectedIcon = widget.category.icon;
    _selectedColor = widget.category.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Food & Dining',
              ),
            ),
            const SizedBox(height: 16),

            // Type selection
            DropdownButtonFormField<TransactionType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
              ),
              items: TransactionType.values.map((type) {
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

            // Icon selection
            Text('Icon', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((iconData) {
                final isSelected = _selectedIcon == iconData['name'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData['name'] as String;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      iconData['icon'] as IconData,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Color selection
            Text('Color', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((colorData) {
                final isSelected = _selectedColor == colorData['color'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorData['color'] as int;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(colorData['color'] as int),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _updateCategory,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _updateCategory() {
    // Create the updated category
    final updatedCategory = TransactionCategory(
      id: widget.category.id,
      name: _nameController.text.trim(),
      type: _selectedType,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    // Get the repository and create the use case
    final repository = ref.read(core_providers.transactionCategoryRepositoryProvider) as dynamic;
    final updateCategory = UpdateCategory(repository);

    // Call the use case
    updateCategory(updatedCategory).then((result) {
      if (mounted) {
        result.when(
          success: (_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category updated successfully')),
            );
            // Refresh the categories list and dependent providers
            ref.invalidate(transactionCategoriesProvider);
            ref.invalidate(categoryNotifierProvider);
            // Invalidate transaction-related providers that might depend on category display
            ref.invalidate(transactionNotifierProvider);
            ref.invalidate(filteredTransactionsProvider);
            ref.invalidate(transactionStatsProvider);
          },
          error: (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update category: ${failure.message}')),
            );
          },
        );
      }
    });
  }
}