// lib/features/transactions/presentation/widgets/enhanced_transaction_filters.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

class EnhancedTransactionFilters extends ConsumerStatefulWidget {
  const EnhancedTransactionFilters({
    super.key,
    required this.onApplyFilter,
    required this.onClearFilter,
    this.currentFilter,
  });

  final TransactionFilter? currentFilter;
  final void Function(TransactionFilter) onApplyFilter;
  final VoidCallback onClearFilter;

  @override
  ConsumerState<EnhancedTransactionFilters> createState() => _EnhancedTransactionFiltersState();
}

class _EnhancedTransactionFiltersState extends ConsumerState<EnhancedTransactionFilters> {
  late TransactionType? _selectedType;
  late List<String> _selectedCategoryIds;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late double? _minAmount;
  late double? _maxAmount;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentFilter?.transactionType;
    _selectedCategoryIds = widget.currentFilter?.categoryIds ?? [];
    _startDate = widget.currentFilter?.startDate;
    _endDate = widget.currentFilter?.endDate;
    _minAmount = widget.currentFilter?.minAmount;
    _maxAmount = widget.currentFilter?.maxAmount;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(transactionCategoriesProvider);

    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    size: 20,
                    color: AppColorsExtended.budgetPrimary,
                  ),
                ),
                SizedBox(width: AppDimensions.spacing2),
                Text(
                  'Filter Transactions',
                  style: AppTypographyExtended.circularProgressPercentage.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spacing4),

            // Transaction Type
            Text(
              'Transaction Type',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            SegmentedButton<TransactionType?>(
              segments: const [
                ButtonSegment(
                  value: null,
                  label: Text('All'),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (selected) {
                setState(() {
                  _selectedType = selected.first;
                });
              },
            ),

            SizedBox(height: AppDimensions.spacing4),

            // Date Range
            Text(
              'Date Range',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: 'Start Date',
                    selectedDate: _startDate,
                    onDateSelected: (date) => setState(() => _startDate = date),
                  ),
                ),
                SizedBox(width: AppDimensions.spacing3),
                Expanded(
                  child: _buildDatePicker(
                    label: 'End Date',
                    selectedDate: _endDate,
                    onDateSelected: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppDimensions.spacing4),

            // Categories
            Text(
              'Categories',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            _buildCategorySelector(categories),

            SizedBox(height: AppDimensions.spacing4),

            // Amount Range
            Text(
              'Amount Range',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            Row(
              children: [
                Expanded(
                  child: _buildAmountField(
                    label: 'Min Amount',
                    value: _minAmount,
                    onChanged: (value) => setState(() => _minAmount = value),
                  ),
                ),
                SizedBox(width: AppDimensions.spacing3),
                Expanded(
                  child: _buildAmountField(
                    label: 'Max Amount',
                    value: _maxAmount,
                    onChanged: (value) => setState(() => _maxAmount = value),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppDimensions.spacing5),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClearFilter,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.textSecondary),
                    ),
                    child: Text(
                      'Clear',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacing3),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsExtended.budgetPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Apply',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColorsExtended.pillBgUnselected,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: AppDimensions.spacing2),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('MMM dd, yyyy').format(selectedDate)
                    : label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: selectedDate != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(List<TransactionCategory> categories) {
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

    return InkWell(
      onTap: () => _showCategoryMultiSelect(categories),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColorsExtended.pillBgUnselected,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(
              Icons.category,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: AppDimensions.spacing2),
            Expanded(
              child: Text(
                _selectedCategoryIds.isEmpty
                    ? 'All Categories'
                    : '${_selectedCategoryIds.length} selected',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField({
    required String label,
    required double? value,
    required ValueChanged<double?> onChanged,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixText: '\$',
        labelStyle: AppTypographyExtended.metricLabel.copyWith(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsExtended.budgetPrimary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      keyboardType: TextInputType.number,
      style: AppTypographyExtended.metricLabel.copyWith(
        fontSize: 12,
      ),
      onChanged: (text) {
        final parsed = double.tryParse(text);
        onChanged(parsed);
      },
    );
  }

  void _showCategoryMultiSelect(List<TransactionCategory> categories) {
    final categoryIconColorService = ref.read(categoryIconColorServiceProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Categories'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: categories.map((category) {
                final isSelected = _selectedCategoryIds.contains(category.id);
                return CheckboxListTile(
                  title: Row(
                    children: [
                      Icon(
                        categoryIconColorService.getIconForCategory(category.id),
                        size: 20,
                        color: categoryIconColorService.getColorForCategory(category.id),
                      ),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedCategoryIds.add(category.id);
                      } else {
                        _selectedCategoryIds.remove(category.id);
                      }
                    });
                    // Update parent state
                    this.setState(() {});
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilter() {
    final filter = TransactionFilter(
      transactionType: _selectedType,
      categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
      startDate: _startDate,
      endDate: _endDate,
      minAmount: _minAmount,
      maxAmount: _maxAmount,
    );
    widget.onApplyFilter(filter);
    Navigator.pop(context);
  }
}