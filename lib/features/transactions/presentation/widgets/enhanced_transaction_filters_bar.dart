import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

/// Horizontal scrollable filter bar for transaction list
class EnhancedTransactionFiltersBar extends ConsumerWidget {
  const EnhancedTransactionFiltersBar({
    super.key,
    required this.onFilterApplied,
    required this.onFilterCleared,
    this.currentFilter,
  });

  final TransactionFilter? currentFilter;
  final void Function(TransactionFilter) onFilterApplied;
  final VoidCallback onFilterCleared;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 56,
      margin: EdgeInsets.symmetric(
        horizontal: FormTokens.fieldPaddingH,
        vertical: DesignTokens.spacing2,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Transaction Type Filters
            _buildTypeFilter(TransactionType.income),
            SizedBox(width: DesignTokens.spacing2),
            _buildTypeFilter(TransactionType.expense),
            SizedBox(width: DesignTokens.spacing3),

            // Quick Date Filters
            _buildQuickDateFilter('Today', _getTodayRange()),
            SizedBox(width: DesignTokens.spacing2),
            _buildQuickDateFilter('This Week', _getThisWeekRange()),
            SizedBox(width: DesignTokens.spacing2),
            _buildQuickDateFilter('This Month', _getThisMonthRange()),
            SizedBox(width: DesignTokens.spacing3),

            // Category Filters (Top 5 most used)
            ..._buildTopCategoryFilters(ref),
            SizedBox(width: DesignTokens.spacing3),

            // Amount Range Filter
            _buildAmountRangeFilter(context),
            SizedBox(width: DesignTokens.spacing3),

            // Clear All Filter
            if (currentFilter != null && currentFilter!.isNotEmpty)
              _buildClearAllFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(TransactionType type) {
    final isSelected = currentFilter?.transactionType == type;

    return FilterChip(
      label: Text(
        type.displayName,
        style: TypographyTokens.labelMd.copyWith(
          color: isSelected ? Colors.white : ColorTokens.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            transactionType: type,
          );
          onFilterApplied(newFilter);
        } else {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            transactionType: null,
          );
          onFilterApplied(newFilter);
        }
      },
      backgroundColor: ColorTokens.surfaceSecondary,
      selectedColor: type == TransactionType.income
          ? ColorTokens.success500
          : ColorTokens.critical500,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : ColorTokens.borderSecondary,
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing3,
        vertical: DesignTokens.spacing2,
      ),
    ).animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: DesignTokens.durationSm,
        );
  }

  Widget _buildQuickDateFilter(String label, DateTimeRange range) {
    final isSelected = _isDateRangeSelected(range);

    return FilterChip(
      label: Text(
        label,
        style: TypographyTokens.labelMd.copyWith(
          color: isSelected ? Colors.white : ColorTokens.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            startDate: range.start,
            endDate: range.end,
          );
          onFilterApplied(newFilter);
        } else {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            startDate: null,
            endDate: null,
          );
          onFilterApplied(newFilter);
        }
      },
      backgroundColor: ColorTokens.surfaceSecondary,
      selectedColor: ColorTokens.teal500,
      checkmarkColor: Colors.white,
      avatar: Icon(
        Icons.calendar_today,
        size: DesignTokens.iconSm,
        color: isSelected ? Colors.white : ColorTokens.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : ColorTokens.borderSecondary,
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing3,
        vertical: DesignTokens.spacing2,
      ),
    );
  }

  List<Widget> _buildTopCategoryFilters(WidgetRef ref) {
    final categories = ref.watch(transactionCategoriesProvider);
    // Get top 5 categories (this could be enhanced with actual usage stats)
    final topCategories = categories.take(5).toList();

    return topCategories.map((category) {
      final isSelected = currentFilter?.categoryIds?.contains(category.id) ?? false;

      return Padding(
        padding: EdgeInsets.only(right: DesignTokens.spacing2),
        child: FilterChip(
          label: Text(
            category.name,
            style: TypographyTokens.labelMd.copyWith(
              color: isSelected ? Colors.white : ColorTokens.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            final currentIds = currentFilter?.categoryIds ?? [];
            List<String> newIds;
            if (selected) {
              newIds = [...currentIds, category.id];
            } else {
              newIds = currentIds.where((id) => id != category.id).toList();
            }

            final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
              categoryIds: newIds.isEmpty ? null : newIds,
            );
            onFilterApplied(newFilter);
          },
          backgroundColor: ColorTokens.surfaceSecondary,
          selectedColor: Color(category.color),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : ColorTokens.borderSecondary,
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing3,
            vertical: DesignTokens.spacing2,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAmountRangeFilter(BuildContext context) {
    final hasAmountFilter = currentFilter?.minAmount != null ||
                           currentFilter?.maxAmount != null;

    return FilterChip(
      label: Text(
        hasAmountFilter ? 'Amount Set' : 'Amount Range',
        style: TypographyTokens.labelMd.copyWith(
          color: hasAmountFilter ? Colors.white : ColorTokens.textPrimary,
          fontWeight: hasAmountFilter ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: hasAmountFilter,
      onSelected: (selected) {
        if (selected) {
          _showAmountRangeDialog(context);
        } else {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            minAmount: null,
            maxAmount: null,
          );
          onFilterApplied(newFilter);
        }
      },
      backgroundColor: ColorTokens.surfaceSecondary,
      selectedColor: ColorTokens.teal500,
      checkmarkColor: Colors.white,
      avatar: Icon(
        Icons.attach_money,
        size: DesignTokens.iconSm,
        color: hasAmountFilter ? Colors.white : ColorTokens.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        side: BorderSide(
          color: hasAmountFilter
              ? Colors.transparent
              : ColorTokens.borderSecondary,
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing3,
        vertical: DesignTokens.spacing2,
      ),
    );
  }

  Widget _buildClearAllFilter() {
    return FilterChip(
      label: Text(
        'Clear All',
        style: TypographyTokens.labelMd.copyWith(
          color: ColorTokens.critical500,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: false,
      onSelected: (_) => onFilterCleared(),
      backgroundColor: ColorTokens.critical500.withValues(alpha: 0.1),
      avatar: Icon(
        Icons.clear_all,
        size: DesignTokens.iconSm,
        color: ColorTokens.critical500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        side: BorderSide(
          color: ColorTokens.critical500.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing3,
        vertical: DesignTokens.spacing2,
      ),
    );
  }

  bool _isDateRangeSelected(DateTimeRange range) {
    return currentFilter?.startDate != null &&
           currentFilter?.endDate != null &&
           currentFilter!.startDate!.isAtSameMomentAs(range.start) &&
           currentFilter!.endDate!.isAtSameMomentAs(range.end);
  }

  DateTimeRange _getTodayRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTimeRange(
      start: today,
      end: today.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1)),
    );
  }

  DateTimeRange _getThisWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7)).subtract(const Duration(microseconds: 1));
    return DateTimeRange(start: weekStart, end: weekEnd);
  }

  DateTimeRange _getThisMonthRange() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(microseconds: 1));
    return DateTimeRange(start: monthStart, end: monthEnd);
  }

  void _showAmountRangeDialog(BuildContext context) {
    double? minAmount = currentFilter?.minAmount;
    double? maxAmount = currentFilter?.maxAmount;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(
            'Set Amount Range',
            style: TypographyTokens.heading5,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Minimum Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: minAmount?.toStringAsFixed(2)),
                onChanged: (value) {
                  minAmount = double.tryParse(value);
                },
              ),
              SizedBox(height: DesignTokens.spacing3),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Maximum Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: maxAmount?.toStringAsFixed(2)),
                onChanged: (value) {
                  maxAmount = double.tryParse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TypographyTokens.labelMd),
            ),
            TextButton(
              onPressed: () {
                final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
                  minAmount: minAmount,
                  maxAmount: maxAmount,
                );
                onFilterApplied(newFilter);
                Navigator.pop(dialogContext);
              },
              child: Text('Apply', style: TypographyTokens.labelMd),
            ),
          ],
        ),
      ),
    );
  }
}