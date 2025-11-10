import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../features/transactions/domain/entities/transaction.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../form_tokens.dart';
import 'enhanced_bottom_sheet.dart';

/// A horizontal scrollable list of toggleable category buttons
class CategoryButtonSelector extends StatefulWidget {
  const CategoryButtonSelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.categoryIconColorService,
    this.label = 'Category',
    this.hint = 'Select a category',
    this.validator,
  });

  final List<TransactionCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final dynamic categoryIconColorService;
  final String label;
  final String hint;
  final String? Function(String?)? validator;

  @override
  State<CategoryButtonSelector> createState() => _CategoryButtonSelectorState();
}

class _CategoryButtonSelectorState extends State<CategoryButtonSelector> {
  final ScrollController _scrollController = ScrollController();
  String? _validationError;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CategoryButtonSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId) {
      _scrollToSelectedCategory();
    }
  }

  void _scrollToSelectedCategory() {
    if (widget.selectedCategoryId == null || !_scrollController.hasClients) return;

    final selectedIndex = widget.categories.indexWhere(
      (category) => category.id == widget.selectedCategoryId,
    );

    if (selectedIndex != -1) {
      final itemWidth = 120.0; // Approximate width of each button
      final targetOffset = selectedIndex * itemWidth;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;

      if (targetOffset <= maxScrollExtent) {
        _scrollController.animateTo(
          targetOffset.clamp(0, maxScrollExtent),
          duration: DesignTokens.durationNormal,
          curve: DesignTokens.curveEaseOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort categories by usage count (descending) and take top 6
    final sortedCategories = List<TransactionCategory>.from(widget.categories)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    final topCategories = sortedCategories.take(6).toList();
    final hasMoreCategories = widget.categories.length > 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.label,
          style: TypographyTokens.labelMd.copyWith(
            color: ColorTokens.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: DesignTokens.spacing2),

        // Category buttons in horizontal scrollable list
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: FormTokens.fieldBackground,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
            border: Border.all(
              color: _validationError != null
                  ? FormTokens.fieldBorderError
                  : FormTokens.fieldBorder,
              width: 1.5,
            ),
          ),
          child: widget.categories.isEmpty
              ? Center(
                  child: Text(
                    'No categories available',
                    style: TypographyTokens.bodyMd.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing3),
                  itemCount: topCategories.length + (hasMoreCategories ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < topCategories.length) {
                      final category = topCategories[index];
                      final isSelected = category.id == widget.selectedCategoryId;

                      return Padding(
                        padding: EdgeInsets.only(right: DesignTokens.spacing2),
                        child: _buildCategoryButton(category, isSelected),
                      );
                    } else {
                      // "More" button
                      return Padding(
                        padding: EdgeInsets.only(right: DesignTokens.spacing2),
                        child: _buildMoreButton(context),
                      );
                    }
                  },
                ),
        ),

        // Validation error
        if (_validationError != null)
          Padding(
            padding: EdgeInsets.only(
              top: DesignTokens.spacing1,
              left: FormTokens.fieldPaddingH,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: FormTokens.errorColor,
                  size: 14,
                ),
                SizedBox(width: DesignTokens.spacing1),
                Expanded(
                  child: Text(
                    _validationError!,
                    style: TypographyTokens.captionMd.copyWith(
                      color: FormTokens.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: DesignTokens.durationSm)
            .slideX(begin: -0.1, duration: DesignTokens.durationSm),
      ],
    );
  }

  Widget _buildCategoryButton(TransactionCategory category, bool isSelected) {
    final categoryColor = widget.categoryIconColorService != null
        ? widget.categoryIconColorService.getColorForCategory(category.id)
        : Color(category.color);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onCategorySelected(category.id);
          _validationError = widget.validator?.call(category.id);
          setState(() {});
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: AnimatedContainer(
          duration: DesignTokens.durationSm,
          curve: DesignTokens.curveEaseOut,
          width: 100,
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing2,
            vertical: DesignTokens.spacing2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? categoryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? categoryColor
                  : ColorTokens.borderSecondary,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
            boxShadow: isSelected
                ? DesignTokens.elevationGlow(
                    categoryColor,
                    alpha: 0.2,
                    spread: 0,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  widget.categoryIconColorService != null
                      ? widget.categoryIconColorService.getIconForCategory(category.id)
                      : Icons.category,
                  color: categoryColor,
                  size: DesignTokens.iconMd,
                ),
              ),
              SizedBox(height: DesignTokens.spacing1),

              // Category name
              Expanded(
                child: Text(
                  category.name,
                  style: TypographyTokens.captionMd.copyWith(
                    color: isSelected ? categoryColor : ColorTokens.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCategorySelectionDialog(context),
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: AnimatedContainer(
          duration: DesignTokens.durationSm,
          curve: DesignTokens.curveEaseOut,
          width: 100,
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing2,
            vertical: DesignTokens.spacing2,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.surfaceSecondary,
            border: Border.all(
              color: ColorTokens.borderSecondary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // More icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorTokens.teal500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  Icons.more_horiz,
                  color: ColorTokens.teal500,
                  size: DesignTokens.iconMd,
                ),
              ),
              SizedBox(height: DesignTokens.spacing1),

              // "More" text
              Expanded(
                child: Text(
                  'More',
                  style: TypographyTokens.captionMd.copyWith(
                    color: ColorTokens.teal500,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategorySelectionDialog(BuildContext context) {
    // Sort all categories by usage count
    final sortedCategories = List<TransactionCategory>.from(widget.categories)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

    EnhancedBottomSheet.showForm<String>(
      context: context,
      title: 'Select Category',
      subtitle: 'Choose a category for your transaction',
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sortedCategories.length,
          itemBuilder: (context, index) {
            final category = sortedCategories[index];
            final isSelected = category.id == widget.selectedCategoryId;
            final categoryColor = widget.categoryIconColorService != null
                ? widget.categoryIconColorService.getColorForCategory(category.id)
                : Color(category.color);

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  widget.categoryIconColorService != null
                      ? widget.categoryIconColorService.getIconForCategory(category.id)
                      : Icons.category,
                  color: categoryColor,
                  size: DesignTokens.iconMd,
                ),
              ),
              title: Text(
                category.name,
                style: TypographyTokens.bodyMd.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? categoryColor : ColorTokens.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: categoryColor,
                      size: DesignTokens.iconMd,
                    )
                  : null,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onCategorySelected(category.id);
                _validationError = widget.validator?.call(category.id);
                setState(() {});
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TypographyTokens.labelMd.copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// Import statement for TransactionCategory - this should be added at the top of files using this component
// import '../../../transactions/domain/entities/transaction.dart';