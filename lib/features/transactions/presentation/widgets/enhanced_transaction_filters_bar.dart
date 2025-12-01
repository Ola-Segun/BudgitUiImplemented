import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
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
    final color = type == TransactionType.income
        ? AppColorsExtended.statusNormal
        : AppColorsExtended.statusCritical;

    return _EnhancedFilterChip(
      label: type.displayName,
      isSelected: isSelected,
      color: color,
      onTap: () {
        if (isSelected) {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            transactionType: null,
          );
          onFilterApplied(newFilter);
        } else {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            transactionType: type,
          );
          onFilterApplied(newFilter);
        }
      },
    );
  }

  Widget _buildQuickDateFilter(String label, DateTimeRange range) {
    final isSelected = _isDateRangeSelected(range);

    return _EnhancedFilterChip(
      label: label,
      isSelected: isSelected,
      color: AppColorsExtended.budgetPrimary,
      icon: Icons.calendar_today,
      onTap: () {
        if (isSelected) {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            startDate: null,
            endDate: null,
          );
          onFilterApplied(newFilter);
        } else {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            startDate: range.start,
            endDate: range.end,
          );
          onFilterApplied(newFilter);
        }
      },
    );
  }

  List<Widget> _buildTopCategoryFilters(WidgetRef ref) {
    final categories = ref.watch(transactionCategoriesProvider);
    // Get top 5 categories (this could be enhanced with actual usage stats)
    final topCategories = categories.take(5).toList();

    return topCategories.map((category) {
      final isSelected = currentFilter?.categoryIds?.contains(category.id) ?? false;

      return Padding(
        padding: EdgeInsets.only(right: AppDimensions.spacing2),
        child: _EnhancedFilterChip(
          label: category.name,
          isSelected: isSelected,
          color: Color(category.color),
          onTap: () {
            final currentIds = currentFilter?.categoryIds ?? [];
            List<String> newIds;
            if (isSelected) {
              newIds = currentIds.where((id) => id != category.id).toList();
            } else {
              newIds = [...currentIds, category.id];
            }

            final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
              categoryIds: newIds.isEmpty ? null : newIds,
            );
            onFilterApplied(newFilter);
          },
        ),
      );
    }).toList();
  }

  Widget _buildAmountRangeFilter(BuildContext context) {
    final hasAmountFilter = currentFilter?.minAmount != null ||
                            currentFilter?.maxAmount != null;

    return _EnhancedFilterChip(
      label: hasAmountFilter ? 'Amount Set' : 'Amount Range',
      isSelected: hasAmountFilter,
      color: AppColorsExtended.budgetPrimary,
      icon: Icons.attach_money,
      onTap: () {
        if (hasAmountFilter) {
          final newFilter = (currentFilter ?? TransactionFilter()).copyWith(
            minAmount: null,
            maxAmount: null,
          );
          onFilterApplied(newFilter);
        } else {
          _showAmountRangeDialog(context);
        }
      },
    );
  }

  Widget _buildClearAllFilter() {
    return _EnhancedFilterChip(
      label: 'Clear All',
      isSelected: false,
      color: AppColorsExtended.statusCritical,
      icon: Icons.clear_all,
      onTap: onFilterCleared,
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

class _EnhancedFilterChip extends StatelessWidget {
  const _EnhancedFilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing3,
            vertical: AppDimensions.spacing2,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.08),
                    ],
                  )
                : null,
            color: isSelected ? null : AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
                SizedBox(width: AppDimensions.spacing1),
              ],
              Text(
                label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: isSelected ? color : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: const Duration(milliseconds: 200),
        );
  }
}