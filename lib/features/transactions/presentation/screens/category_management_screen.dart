import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/di/providers.dart' as core_providers;
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/components/enhanced_dropdown_field.dart';
import '../../../../core/design_system/components/optional_fields_toggle.dart';
import '../../../../core/design_system/modern/modern.dart';
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

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Active (${categoryState.activeCategories.length})'),
                    Tab(text: 'Archived (${categoryState.archivedCategories.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Active categories
                      _buildCategoryList(categoryState.activeCategories, categoryState.isOperationInProgress, categoryIconColorService),
                      // Archived categories
                      _buildCategoryList(categoryState.archivedCategories, categoryState.isOperationInProgress, categoryIconColorService, isArchived: true),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildCategoryList(List<TransactionCategory> categories, bool isOperationInProgress, dynamic categoryIconColorService, {bool isArchived = false}) {
    if (categories.isEmpty) {
      return Center(
        child: Text(isArchived ? 'No archived categories' : 'No active categories. Add your first category!'),
      );
    }

    return ReorderableListView.builder(
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      itemCount: categories.length,
      onReorder: isArchived ? (oldIndex, newIndex) {} : (oldIndex, newIndex) async {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        final reorderedCategories = List<TransactionCategory>.from(categories);
        final category = reorderedCategories.removeAt(oldIndex);
        reorderedCategories.insert(newIndex, category);

        // Update order in database
        final categoryIds = reorderedCategories.map((c) => c.id).toList();
        final reorderUseCase = ref.read(core_providers.reorderCategoriesProvider);
        final result = await reorderUseCase(categoryIds);

        result.when(
          success: (_) {
            // Refresh the categories list
            ref.invalidate(categoryNotifierProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Categories reordered successfully')),
            );
          },
          error: (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to reorder categories: ${failure.message}')),
            );
            // Revert the local change by refreshing
            ref.invalidate(categoryNotifierProvider);
          },
        );
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryTile(category, isOperationInProgress, categoryIconColorService, index, isArchived);
      },
    );
  }

  Widget _buildCategoryTile(TransactionCategory category, bool isOperationInProgress, dynamic categoryIconColorService, [int? index, bool isArchived = false]) {
    return Slidable(
      key: ValueKey(category.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          // Archive/Unarchive action (orange/amber)
          SlidableAction(
            onPressed: isOperationInProgress ? null : (_) {
              HapticFeedback.lightImpact();
              if (isArchived) {
                _unarchiveCategory(category);
              } else {
                _archiveCategory(category);
              }
            },
            backgroundColor: isArchived ? Colors.green : Colors.orange,
            foregroundColor: Colors.white,
            icon: isArchived ? Icons.unarchive : Icons.archive,
            label: isArchived ? 'Unarchive' : 'Archive',
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
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
        key: ValueKey(category.id), // Required for ReorderableListView
        margin: EdgeInsets.only(bottom: AppDimensions.spacing2),
        child: AppCard(
          elevation: AppCardElevation.low,
          padding: EdgeInsets.all(AppDimensions.cardPadding),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index ?? 0,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.drag_handle,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
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
    await showModernBottomSheet(
      context: context,
      builder: (context) => const EnhancedAddCategoryForm(),
    );
  }

  Future<void> _showEditCategoryDialog(BuildContext context, TransactionCategory category) async {
    await showModernBottomSheet(
      context: context,
      builder: (context) => EnhancedEditCategoryForm(category: category),
    );
  }

  Future<void> _archiveCategory(TransactionCategory category) async {
    final notifier = ref.read(categoryNotifierProvider.notifier);
    final success = await notifier.archiveCategory(category.id);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "${category.name}" archived successfully')),
      );
    }
  }

  Future<void> _unarchiveCategory(TransactionCategory category) async {
    final notifier = ref.read(categoryNotifierProvider.notifier);
    final success = await notifier.unarchiveCategory(category.id);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "${category.name}" unarchived successfully')),
      );
    }
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

/// Enhanced form for adding a new category
class EnhancedAddCategoryForm extends ConsumerStatefulWidget {
  const EnhancedAddCategoryForm({super.key});

  @override
  ConsumerState<EnhancedAddCategoryForm> createState() => _EnhancedAddCategoryFormState();
}

class _EnhancedAddCategoryFormState extends ConsumerState<EnhancedAddCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String _selectedIcon = 'category';
  int _selectedColor = 0xFF64748B; // Default gray
  bool _isSubmitting = false;
  bool _showOptionalFields = false;

  // Convert available icons to CategoryItem format
  List<CategoryItem> get _availableCategoryItems => _availableIcons.map((iconData) {
    return CategoryItem(
      id: iconData['name'] as String,
      name: iconData['name'] as String,
      icon: iconData['icon'] as IconData,
      color: _selectedColor,
    );
  }).toList();

  final List<Map<String, dynamic>> _availableIcons = [
    // Food & Dining
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'fastfood', 'icon': Icons.fastfood},
    {'name': 'local_cafe', 'icon': Icons.local_cafe},
    {'name': 'local_pizza', 'icon': Icons.local_pizza},
    {'name': 'local_bar', 'icon': Icons.local_bar},
    {'name': 'cake', 'icon': Icons.cake},
    {'name': 'icecream', 'icon': Icons.icecream},

    // Transportation
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'directions_bus', 'icon': Icons.directions_bus},
    {'name': 'directions_bike', 'icon': Icons.directions_bike},
    {'name': 'flight', 'icon': Icons.flight},
    {'name': 'train', 'icon': Icons.train},
    {'name': 'local_taxi', 'icon': Icons.local_taxi},
    {'name': 'pedal_bike', 'icon': Icons.pedal_bike},

    // Shopping
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'store', 'icon': Icons.store},
    {'name': 'local_mall', 'icon': Icons.local_mall},
    {'name': 'shopping_basket', 'icon': Icons.shopping_basket},

    // Entertainment
    {'name': 'movie', 'icon': Icons.movie},
    {'name': 'music_note', 'icon': Icons.music_note},
    {'name': 'sports_soccer', 'icon': Icons.sports_soccer},
    {'name': 'theater_comedy', 'icon': Icons.theater_comedy},
    {'name': 'casino', 'icon': Icons.casino},
    {'name': 'videogame_asset', 'icon': Icons.videogame_asset},
    {'name': 'headphones', 'icon': Icons.headphones},

    // Health & Medical
    {'name': 'local_hospital', 'icon': Icons.local_hospital},
    {'name': 'fitness_center', 'icon': Icons.fitness_center},
    {'name': 'spa', 'icon': Icons.spa},
    {'name': 'medical_services', 'icon': Icons.medical_services},
    {'name': 'healing', 'icon': Icons.healing},
    {'name': 'vaccines', 'icon': Icons.vaccines},

    // Education
    {'name': 'school', 'icon': Icons.school},
    {'name': 'library_books', 'icon': Icons.library_books},
    {'name': 'science', 'icon': Icons.science},
    {'name': 'calculate', 'icon': Icons.calculate},

    // Home & Living
    {'name': 'home', 'icon': Icons.home},
    {'name': 'apartment', 'icon': Icons.apartment},
    {'name': 'cottage', 'icon': Icons.cottage},
    {'name': 'villa', 'icon': Icons.villa},
    {'name': 'real_estate_agent', 'icon': Icons.real_estate_agent},

    // Finance
    {'name': 'account_balance', 'icon': Icons.account_balance},
    {'name': 'credit_card', 'icon': Icons.credit_card},
    {'name': 'savings', 'icon': Icons.savings},
    {'name': 'trending_up', 'icon': Icons.trending_up},
    {'name': 'trending_down', 'icon': Icons.trending_down},
    {'name': 'attach_money', 'icon': Icons.attach_money},
    {'name': 'account_balance_wallet', 'icon': Icons.account_balance_wallet},

    // Travel & Leisure
    {'name': 'beach_access', 'icon': Icons.beach_access},
    {'name': 'landscape', 'icon': Icons.landscape},
    {'name': 'location_city', 'icon': Icons.location_city},
    {'name': 'hotel', 'icon': Icons.hotel},
    {'name': 'camera_alt', 'icon': Icons.camera_alt},
    {'name': 'photo_camera', 'icon': Icons.photo_camera},

    // Utilities
    {'name': 'bolt', 'icon': Icons.bolt},
    {'name': 'water_drop', 'icon': Icons.water_drop},
    {'name': 'gas_meter', 'icon': Icons.gas_meter},
    {'name': 'wifi', 'icon': Icons.wifi},
    {'name': 'phone', 'icon': Icons.phone},
    {'name': 'tv', 'icon': Icons.tv},
    {'name': 'cleaning_services', 'icon': Icons.cleaning_services},

    // Personal
    {'name': 'person', 'icon': Icons.person},
    {'name': 'family_restroom', 'icon': Icons.family_restroom},
    {'name': 'child_care', 'icon': Icons.child_care},
    {'name': 'elderly', 'icon': Icons.elderly},
    {'name': 'self_improvement', 'icon': Icons.self_improvement},

    // Work & Business
    {'name': 'work', 'icon': Icons.work},
    {'name': 'business_center', 'icon': Icons.business_center},
    {'name': 'engineering', 'icon': Icons.engineering},
    {'name': 'construction', 'icon': Icons.construction},
    {'name': 'handyman', 'icon': Icons.handyman},

    // Technology
    {'name': 'computer', 'icon': Icons.computer},
    {'name': 'phone_android', 'icon': Icons.phone_android},
    {'name': 'laptop', 'icon': Icons.laptop},
    {'name': 'smartphone', 'icon': Icons.smartphone},
    {'name': 'devices', 'icon': Icons.devices},

    // Other
    {'name': 'category', 'icon': Icons.category},
    {'name': 'star', 'icon': Icons.star},
    {'name': 'favorite', 'icon': Icons.favorite},
    {'name': 'pets', 'icon': Icons.pets},
    {'name': 'celebration', 'icon': Icons.celebration},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard},
    {'name': 'redeem', 'icon': Icons.redeem},
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
    return ModernBottomSheet(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Add Category',
              style: ModernTypography.titleLarge,
              textAlign: TextAlign.center,
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
            ).animate()
              .fadeIn(duration: ModernAnimations.normal)
              .slideY(begin: 0.1, duration: ModernAnimations.normal),

            const SizedBox(height: spacing_lg),

            // Section: Basic Information
            _buildSectionHeader(
              'Basic Information',
              'Essential details about your category',
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
              .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 100.ms),

            const SizedBox(height: spacing_md),

            // Name field with async validation
            ModernTextField(
              controller: _nameController,
              placeholder: 'e.g., Food & Dining',
              prefixIcon: Icons.category,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name';
                }
                if (value.trim().length < 2) {
                  return 'Category name must be at least 2 characters';
                }
                return null;
              },
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
              .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 100.ms),

            const SizedBox(height: spacing_md),

            // Type selection
            EnhancedDropdownField<TransactionType>(
              label: 'Transaction Type',
              hint: 'Select category type',
              items: TransactionType.values.map((type) {
                return DropdownItem<TransactionType>(
                  value: type,
                  label: type.displayName,
                  icon: type == TransactionType.expense
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  iconColor: type == TransactionType.expense
                      ? ColorTokens.critical500
                      : ColorTokens.success500,
                );
              }).toList(),
              value: _selectedType,
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 200.ms)
              .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 200.ms),

            const SizedBox(height: spacing_lg),

            // Section: Appearance
            if (_showOptionalFields) ...[
              _buildSectionHeader(
                'Appearance',
                'Customize how your category looks',
              ).animate()
                .fadeIn(duration: ModernAnimations.normal, delay: 400.ms)
                .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 400.ms),

              const SizedBox(height: spacing_md),

              // Icon selection
              _buildIconSelection().animate()
                .fadeIn(duration: ModernAnimations.normal, delay: 500.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: ModernAnimations.normal, delay: 500.ms),

              const SizedBox(height: spacing_md),

              // Color selection
              _buildColorSelection().animate()
                .fadeIn(duration: ModernAnimations.normal, delay: 600.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: ModernAnimations.normal, delay: 600.ms),

              const SizedBox(height: spacing_lg),
            ],

            // Submit button
            _buildSubmitButton().animate()
              .fadeIn(duration: ModernAnimations.normal, delay: _showOptionalFields ? 700.ms : 300.ms)
              .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: _showOptionalFields ? 700.ms : 300.ms)
              .scale(begin: const Offset(0.95, 0.95), duration: ModernAnimations.fast, delay: _showOptionalFields ? 700.ms : 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TypographyTokens.heading6.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          subtitle,
          style: TypographyTokens.captionMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelection() {
    return ModernCategorySelector(
      categories: _availableCategoryItems,
      selectedId: _selectedIcon,
      onChanged: (id) {
        if (id != null) {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedIcon = id;
          });
        }
      },
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: ModernTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: spacing_sm),
        Wrap(
          spacing: spacing_sm,
          runSpacing: spacing_sm,
          children: _availableColors.map((colorData) {
            final isSelected = _selectedColor == colorData['color'];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedColor = colorData['color'] as int;
                  });
                },
                borderRadius: BorderRadius.circular(radius_pill),
                child: AnimatedContainer(
                  duration: ModernAnimations.fast,
                  curve: ModernCurves.easeOut,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(colorData['color'] as int),
                    border: Border.all(
                      color: isSelected
                          ? ModernColors.accentGreen
                          : Colors.transparent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(radius_pill),
                    boxShadow: isSelected
                        ? [ModernShadows.medium]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ).animate(target: isSelected ? 1 : 0)
                  .scaleXY(
                    begin: 1.0,
                    end: 1.1,
                    duration: ModernAnimations.fast,
                  ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ModernActionButton(
      text: 'Add Category',
      onPressed: _isSubmitting ? null : _addCategory,
      isLoading: _isSubmitting,
    );
  }

  Future<String?> _validateCategoryName(String name) async {
    if (name.trim().isEmpty) return null;

    try {
      final categoryState = ref.read(categoryNotifierProvider);
      final existingCategories = categoryState.maybeWhen(
        data: (state) => state.categories,
        orElse: () => <TransactionCategory>[],
      );

      final isDuplicate = existingCategories.any(
        (category) => category.name.trim().toLowerCase() == name.toLowerCase(),
      );

      return isDuplicate ? 'A category with this name already exists' : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
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
      final result = await addCategory(category);

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// Enhanced form for editing an existing category
class EnhancedEditCategoryForm extends ConsumerStatefulWidget {
  const EnhancedEditCategoryForm({
    super.key,
    required this.category,
  });

  final TransactionCategory category;

  @override
  ConsumerState<EnhancedEditCategoryForm> createState() => _EnhancedEditCategoryFormState();
}

class _EnhancedEditCategoryFormState extends ConsumerState<EnhancedEditCategoryForm> {
  late final TextEditingController _nameController;
  late TransactionType _selectedType;
  late String _selectedIcon;
  late int _selectedColor;
  bool _isSubmitting = false;
  bool _showOptionalFields = false;

  // Convert available icons to CategoryItem format
  List<CategoryItem> get _availableCategoryItems => _availableIcons.map((iconData) {
    return CategoryItem(
      id: iconData['name'] as String,
      name: iconData['name'] as String,
      icon: iconData['icon'] as IconData,
      color: _selectedColor,
    );
  }).toList();

  final List<Map<String, dynamic>> _availableIcons = [
    // Food & Dining
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'fastfood', 'icon': Icons.fastfood},
    {'name': 'local_cafe', 'icon': Icons.local_cafe},
    {'name': 'local_pizza', 'icon': Icons.local_pizza},
    {'name': 'local_bar', 'icon': Icons.local_bar},
    {'name': 'cake', 'icon': Icons.cake},
    {'name': 'icecream', 'icon': Icons.icecream},

    // Transportation
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'directions_bus', 'icon': Icons.directions_bus},
    {'name': 'directions_bike', 'icon': Icons.directions_bike},
    {'name': 'flight', 'icon': Icons.flight},
    {'name': 'train', 'icon': Icons.train},
    {'name': 'local_taxi', 'icon': Icons.local_taxi},
    {'name': 'pedal_bike', 'icon': Icons.pedal_bike},

    // Shopping
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'store', 'icon': Icons.store},
    {'name': 'local_mall', 'icon': Icons.local_mall},
    {'name': 'shopping_basket', 'icon': Icons.shopping_basket},

    // Entertainment
    {'name': 'movie', 'icon': Icons.movie},
    {'name': 'music_note', 'icon': Icons.music_note},
    {'name': 'sports_soccer', 'icon': Icons.sports_soccer},
    {'name': 'theater_comedy', 'icon': Icons.theater_comedy},
    {'name': 'casino', 'icon': Icons.casino},
    {'name': 'videogame_asset', 'icon': Icons.videogame_asset},
    {'name': 'headphones', 'icon': Icons.headphones},

    // Health & Medical
    {'name': 'local_hospital', 'icon': Icons.local_hospital},
    {'name': 'fitness_center', 'icon': Icons.fitness_center},
    {'name': 'spa', 'icon': Icons.spa},
    {'name': 'medical_services', 'icon': Icons.medical_services},
    {'name': 'healing', 'icon': Icons.healing},
    {'name': 'vaccines', 'icon': Icons.vaccines},

    // Education
    {'name': 'school', 'icon': Icons.school},
    {'name': 'library_books', 'icon': Icons.library_books},
    {'name': 'science', 'icon': Icons.science},
    {'name': 'calculate', 'icon': Icons.calculate},

    // Home & Living
    {'name': 'home', 'icon': Icons.home},
    {'name': 'apartment', 'icon': Icons.apartment},
    {'name': 'cottage', 'icon': Icons.cottage},
    {'name': 'villa', 'icon': Icons.villa},
    {'name': 'real_estate_agent', 'icon': Icons.real_estate_agent},

    // Finance
    {'name': 'account_balance', 'icon': Icons.account_balance},
    {'name': 'credit_card', 'icon': Icons.credit_card},
    {'name': 'savings', 'icon': Icons.savings},
    {'name': 'trending_up', 'icon': Icons.trending_up},
    {'name': 'trending_down', 'icon': Icons.trending_down},
    {'name': 'attach_money', 'icon': Icons.attach_money},
    {'name': 'account_balance_wallet', 'icon': Icons.account_balance_wallet},

    // Travel & Leisure
    {'name': 'beach_access', 'icon': Icons.beach_access},
    {'name': 'landscape', 'icon': Icons.landscape},
    {'name': 'location_city', 'icon': Icons.location_city},
    {'name': 'hotel', 'icon': Icons.hotel},
    {'name': 'camera_alt', 'icon': Icons.camera_alt},
    {'name': 'photo_camera', 'icon': Icons.photo_camera},

    // Utilities
    {'name': 'bolt', 'icon': Icons.bolt},
    {'name': 'water_drop', 'icon': Icons.water_drop},
    {'name': 'gas_meter', 'icon': Icons.gas_meter},
    {'name': 'wifi', 'icon': Icons.wifi},
    {'name': 'phone', 'icon': Icons.phone},
    {'name': 'tv', 'icon': Icons.tv},
    {'name': 'cleaning_services', 'icon': Icons.cleaning_services},

    // Personal
    {'name': 'person', 'icon': Icons.person},
    {'name': 'family_restroom', 'icon': Icons.family_restroom},
    {'name': 'child_care', 'icon': Icons.child_care},
    {'name': 'elderly', 'icon': Icons.elderly},
    {'name': 'self_improvement', 'icon': Icons.self_improvement},

    // Work & Business
    {'name': 'work', 'icon': Icons.work},
    {'name': 'business_center', 'icon': Icons.business_center},
    {'name': 'engineering', 'icon': Icons.engineering},
    {'name': 'construction', 'icon': Icons.construction},
    {'name': 'handyman', 'icon': Icons.handyman},

    // Technology
    {'name': 'computer', 'icon': Icons.computer},
    {'name': 'phone_android', 'icon': Icons.phone_android},
    {'name': 'laptop', 'icon': Icons.laptop},
    {'name': 'smartphone', 'icon': Icons.smartphone},
    {'name': 'devices', 'icon': Icons.devices},

    // Other
    {'name': 'category', 'icon': Icons.category},
    {'name': 'star', 'icon': Icons.star},
    {'name': 'favorite', 'icon': Icons.favorite},
    {'name': 'pets', 'icon': Icons.pets},
    {'name': 'celebration', 'icon': Icons.celebration},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard},
    {'name': 'redeem', 'icon': Icons.redeem},
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
    return ModernBottomSheet(
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Edit Category',
              style: ModernTypography.titleLarge,
              textAlign: TextAlign.center,
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
            ).animate()
              .fadeIn(duration: ModernAnimations.normal)
              .slideY(begin: 0.1, duration: ModernAnimations.normal),

            const SizedBox(height: spacing_lg),

            // Section: Basic Information
            _buildSectionHeader(
              'Basic Information',
              'Update essential category details',
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
              .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 100.ms),

            const SizedBox(height: spacing_md),

            // Name field with async validation
            ModernTextField(
              controller: _nameController,
              placeholder: 'e.g., Food & Dining',
              prefixIcon: Icons.category,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name';
                }
                if (value.trim().length < 2) {
                  return 'Category name must be at least 2 characters';
                }
                return null;
              },
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
              .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 100.ms),

            const SizedBox(height: spacing_md),

            // Type selection
            EnhancedDropdownField<TransactionType>(
              label: 'Transaction Type',
              hint: 'Select category type',
              items: TransactionType.values.map((type) {
                return DropdownItem<TransactionType>(
                  value: type,
                  label: type.displayName,
                  icon: type == TransactionType.expense
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  iconColor: type == TransactionType.expense
                      ? ColorTokens.critical500
                      : ColorTokens.success500,
                );
              }).toList(),
              value: _selectedType,
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 200.ms)
              .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 200.ms),

            const SizedBox(height: spacing_lg),

            // Section: Appearance
            if (_showOptionalFields) ...[
              _buildSectionHeader(
                'Appearance',
                'Customize how your category looks',
              ).animate()
                .fadeIn(duration: ModernAnimations.normal, delay: 400.ms)
                .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 400.ms),

              const SizedBox(height: spacing_md),

              // Icon selection
              _buildIconSelection().animate()
                .fadeIn(duration: ModernAnimations.normal, delay: 500.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: ModernAnimations.normal, delay: 500.ms),

              const SizedBox(height: spacing_md),

              // Color selection
              _buildColorSelection().animate()
                .fadeIn(duration: ModernAnimations.normal, delay: 600.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: ModernAnimations.normal, delay: 600.ms),

              const SizedBox(height: spacing_lg),
            ],

            // Submit button
            _buildSubmitButton().animate()
              .fadeIn(duration: ModernAnimations.normal, delay: _showOptionalFields ? 700.ms : 300.ms)
              .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: _showOptionalFields ? 700.ms : 300.ms)
              .scale(begin: const Offset(0.95, 0.95), duration: ModernAnimations.fast, delay: _showOptionalFields ? 700.ms : 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TypographyTokens.heading6.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          subtitle,
          style: TypographyTokens.captionMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelection() {
    return ModernCategorySelector(
      categories: _availableCategoryItems,
      selectedId: _selectedIcon,
      onChanged: (id) {
        if (id != null) {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedIcon = id;
          });
        }
      },
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: ModernTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: spacing_sm),
        Wrap(
          spacing: spacing_sm,
          runSpacing: spacing_sm,
          children: _availableColors.map((colorData) {
            final isSelected = _selectedColor == colorData['color'];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedColor = colorData['color'] as int;
                  });
                },
                borderRadius: BorderRadius.circular(radius_pill),
                child: AnimatedContainer(
                  duration: ModernAnimations.fast,
                  curve: ModernCurves.easeOut,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(colorData['color'] as int),
                    border: Border.all(
                      color: isSelected
                          ? ModernColors.accentGreen
                          : Colors.transparent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(radius_pill),
                    boxShadow: isSelected
                        ? [ModernShadows.medium]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ).animate(target: isSelected ? 1 : 0)
                  .scaleXY(
                    begin: 1.0,
                    end: 1.1,
                    duration: ModernAnimations.fast,
                  ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ModernActionButton(
      text: 'Update Category',
      onPressed: _isSubmitting ? null : _updateCategory,
      isLoading: _isSubmitting,
    );
  }

  Future<String?> _validateCategoryName(String name) async {
    if (name.trim().isEmpty) return null;

    try {
      final categoryState = ref.read(categoryNotifierProvider);
      final existingCategories = categoryState.maybeWhen(
        data: (state) => state.categories,
        orElse: () => <TransactionCategory>[],
      );

      final isDuplicate = existingCategories.any(
        (category) =>
            category.id != widget.category.id &&
            category.name.trim().toLowerCase() == name.toLowerCase(),
      );

      return isDuplicate ? 'A category with this name already exists' : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateCategory() async {
    // Create the updated category
    final updatedCategory = TransactionCategory(
      id: widget.category.id,
      name: _nameController.text.trim(),
      type: _selectedType,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    setState(() => _isSubmitting = true);

    try {
      // Get the repository and create the use case
      final repository = ref.read(core_providers.transactionCategoryRepositoryProvider) as dynamic;
      final updateCategory = UpdateCategory(repository);

      // Call the use case
      final result = await updateCategory(updatedCategory);

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}