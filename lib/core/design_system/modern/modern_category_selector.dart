import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';
import 'modern_text_field.dart';

/// Category Item Model
class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final int color;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// ModernCategorySelector Widget
/// Horizontal scrollable category icons with labels
/// Rounded square icons (56x56px), Icon size: 24x24px, Corner radius: 16px
/// Vibrant, distinct colors per category, Label below icon (13pt, medium weight)
/// Horizontal scroll, 12px spacing between items
class ModernCategorySelector extends StatefulWidget {
  final List<CategoryItem> categories;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final bool showSearch;
  final bool allowCustom;

  const ModernCategorySelector({
    super.key,
    required this.categories,
    this.selectedId,
    required this.onChanged,
    this.showSearch = false,
    this.allowCustom = false,
  });

  @override
  State<ModernCategorySelector> createState() => _ModernCategorySelectorState();
}

class _ModernCategorySelectorState extends State<ModernCategorySelector> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  late List<CategoryItem> _filteredCategories;

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
  }

  @override
  void didUpdateWidget(ModernCategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _filterCategories();
    }
  }

  void _filterCategories() {
    if (_searchQuery.isEmpty) {
      _filteredCategories = widget.categories;
    } else {
      _filteredCategories = widget.categories
          .where((cat) => cat.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showSearch) ...[
          ModernTextField(
            placeholder: 'Search categories...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterCategories();
              });
            },
          ),
          const SizedBox(height: spacing_md),
        ],
        Semantics(
          label: 'Category selector',
          child: SizedBox(
            height: 100,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: spacing_md),
              itemCount: _filteredCategories.length + (widget.allowCustom ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: spacing_md),
              itemBuilder: (context, index) {
                if (index == _filteredCategories.length && widget.allowCustom) {
                  return _buildCustomCategoryButton();
                }

                final category = _filteredCategories[index];
                final isSelected = category.id == widget.selectedId;

                return Semantics(
                  label: '${category.name} category',
                  selected: isSelected,
                  button: true,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onChanged(category.id);
                    },
                    child: AnimatedContainer(
                      duration: ModernAnimations.normal,
                      child: Column(
                        children: [
                          Container(
                            width: ModernSizes.categoryIconSize,
                            height: ModernSizes.categoryIconSize,
                            decoration: BoxDecoration(
                              color: Color(category.color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(radius_lg),
                              border: isSelected ? Border.all(
                                color: Color(category.color),
                                width: 2.5,
                              ) : null,
                            ),
                            child: Center(
                              child: Icon(
                                category.icon,
                                size: 24,
                                color: Color(category.color),
                              ),
                            ),
                          ),
                          const SizedBox(height: spacing_xs),
                          Text(
                            category.name,
                            style: ModernTypography.labelMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? ModernColors.textPrimary : ModernColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCategoryButton() {
    return Semantics(
      label: 'Add custom category',
      button: true,
      child: GestureDetector(
        onTap: () => _showCustomCategoryDialog(context),
        child: Column(
          children: [
            Container(
              width: ModernSizes.categoryIconSize,
              height: ModernSizes.categoryIconSize,
              decoration: BoxDecoration(
                color: ModernColors.primaryGray,
                borderRadius: BorderRadius.circular(radius_lg),
                border: Border.all(
                  color: ModernColors.borderColor,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: ModernColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: spacing_xs),
            Text(
              'Custom',
              style: ModernTypography.labelMedium.copyWith(
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomCategoryDialog(BuildContext context) {
    // Implementation for custom category creation
    // This would typically show a dialog to create a new category
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Category'),
        content: const Text('Custom category creation would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}