import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../providers/transaction_providers.dart';

/// Responsive horizontal scrollable filters bar for transactions
class TransactionFiltersBar extends ConsumerStatefulWidget {
  const TransactionFiltersBar({super.key});

  @override
  ConsumerState<TransactionFiltersBar> createState() => _TransactionFiltersBarState();
}

class _TransactionFiltersBarState extends ConsumerState<TransactionFiltersBar> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(transactionCategoriesProvider);
    final accounts = ref.watch(filteredAccountsProvider);
    final currentFilter = ref.watch(transactionNotifierProvider).value?.filter;
    final screenWidth = MediaQuery.of(context).size.width;

    // Use wrap layout for very small screens
    if (screenWidth < 360) {
      return _buildWrapLayout(categories, accounts, currentFilter);
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 50),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Search
              _buildSearchField(),
              const SizedBox(width: 8),

              // All Accounts
              _buildAccountsDropdown(accounts),
              const SizedBox(width: 8),

              // Date Range
              _buildDateRangePicker(),
              const SizedBox(width: 8),

              // Categories
              _buildCategoriesFilter(categories),
              const SizedBox(width: 8),

              // Amount Range
              _buildAmountRangeFilter(),
              const SizedBox(width: 8),

              // Clear Filters
              if (currentFilter != null && currentFilter.isNotEmpty)
                _buildClearFiltersButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Wrap layout for very small screens
  Widget _buildWrapLayout(
    List<TransactionCategory> categories,
    AsyncValue<List<Account>> accounts,
    TransactionFilter? currentFilter,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Search
          SizedBox(
            width: _isSearchExpanded ? double.infinity : 48,
            child: _buildSearchField(),
          ),

          // All Accounts
          if (!_isSearchExpanded) _buildAccountsDropdown(accounts),

          // Date Range
          if (!_isSearchExpanded) _buildDateRangePicker(),

          // Categories
          if (!_isSearchExpanded) _buildCategoriesFilter(categories),

          // Amount Range
          if (!_isSearchExpanded) _buildAmountRangeFilter(),

          // Clear Filters
          if (!_isSearchExpanded && currentFilter != null && currentFilter.isNotEmpty)
            _buildClearFiltersButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isSearchExpanded) {
      // Calculate responsive width
      final expandedWidth = screenWidth < 360
          ? screenWidth - 32 // Full width minus padding on small screens
          : screenWidth < 400
              ? 160.0
              : screenWidth < 600
                  ? 200.0
                  : 250.0;

      return SizedBox(
        width: expandedWidth,
        height: AppDimensions.buttonHeightMd,
        child: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: AppDimensions.iconSm,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.close,
                size: AppDimensions.iconSm,
                color: AppColors.textSecondary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = false;
                  _searchController.clear();
                });
                ref.read(transactionNotifierProvider.notifier).clearSearch();
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing3,
              vertical: AppDimensions.spacing2,
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          style: AppTypography.body.copyWith(
            color: AppColors.textPrimary,
          ),
          onChanged: (query) {
            ref.read(transactionNotifierProvider.notifier).searchTransactions(query);
          },
        ),
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.search,
          size: AppDimensions.iconMd,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _isSearchExpanded = true;
          });
        },
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
          padding: EdgeInsets.all(AppDimensions.spacing2),
        ),
      );
    }
  }

  Widget _buildAccountsDropdown(AsyncValue<List<Account>> accounts) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownWidth = screenWidth < 360 
        ? 100.0 
        : screenWidth < 400 
            ? 110.0 
            : 130.0;
    
    return accounts.when(
      data: (accountsList) => SizedBox(
        width: dropdownWidth,
        height: 48,
        child: DropdownButtonFormField<String?>(
          isDense: true,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Account',
            labelStyle: const TextStyle(fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 12),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
            ),
            ...accountsList.map((account) => DropdownMenuItem(
              value: account.id,
              child: Text(
                account.name, 
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          onChanged: (value) {
            final currentFilter = ref.read(transactionNotifierProvider).value?.filter;
            final newFilter = currentFilter?.copyWith(accountId: value) ??
                TransactionFilter(accountId: value);
            ref.read(transactionNotifierProvider.notifier).applyFilter(newFilter);
          },
        ),
      ),
      loading: () => SizedBox(
        width: dropdownWidth, 
        height: 48,
        child: const Center(child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )),
      ),
      error: (error, stack) => SizedBox(
        width: dropdownWidth, 
        height: 48,
        child: const Icon(Icons.error, size: 20),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return OutlinedButton.icon(
      onPressed: () => _showDateRangePicker(),
      icon: Icon(
        Icons.date_range,
        size: AppDimensions.iconSm,
        color: AppColors.primary,
      ),
      label: Text(
        'Date',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing3,
          vertical: AppDimensions.spacing2,
        ),
        side: BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }

  Widget _buildCategoriesFilter(List<TransactionCategory> categories) {
    return OutlinedButton.icon(
      onPressed: () => _showCategoriesMultiSelect(categories),
      icon: Icon(
        Icons.category,
        size: AppDimensions.iconSm,
        color: AppColors.primary,
      ),
      label: Text(
        'Category',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing3,
          vertical: AppDimensions.spacing2,
        ),
        side: BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }

  Widget _buildAmountRangeFilter() {
    return OutlinedButton.icon(
      onPressed: () => _showAmountRangePicker(),
      icon: Icon(
        Icons.attach_money,
        size: AppDimensions.iconSm,
        color: AppColors.primary,
      ),
      label: Text(
        'Amount',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing3,
          vertical: AppDimensions.spacing2,
        ),
        side: BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    return TextButton.icon(
      onPressed: () {
        ref.read(transactionNotifierProvider.notifier).clearFilter();
        setState(() {
          _isSearchExpanded = false;
          _searchController.clear();
        });
      },
      icon: Icon(
        Icons.clear,
        size: AppDimensions.iconSm,
        color: AppColors.primary,
      ),
      label: Text(
        'Clear',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing3,
          vertical: AppDimensions.spacing2,
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (picked != null && mounted) {
      final currentFilter = ref.read(transactionNotifierProvider).value?.filter;
      final newFilter = currentFilter?.copyWith(
        startDate: picked.start,
        endDate: picked.end,
      ) ?? TransactionFilter(startDate: picked.start, endDate: picked.end);
      ref.read(transactionNotifierProvider.notifier).applyFilter(newFilter);
    }
  }

  void _showCategoriesMultiSelect(List<TransactionCategory> categories) {
    final categoryIconColorService = ref.read(categoryIconColorServiceProvider);
    final currentFilter = ref.read(transactionNotifierProvider).value?.filter;
    final selectedIds = List<String>.from(currentFilter?.categoryIds ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Categories'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedIds.contains(category.id);
                return CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        categoryIconColorService.getIconForCategory(category.id),
                        size: 20,
                        color: categoryIconColorService.getColorForCategory(category.id),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        selectedIds.add(category.id);
                      } else {
                        selectedIds.remove(category.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final currentFilter = ref.read(transactionNotifierProvider).value?.filter;
                final newFilter = currentFilter?.copyWith(
                  categoryIds: selectedIds.isEmpty ? null : selectedIds,
                ) ?? TransactionFilter(categoryIds: selectedIds.isEmpty ? null : selectedIds);
                ref.read(transactionNotifierProvider.notifier).applyFilter(newFilter);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAmountRangePicker() {
    final currentFilter = ref.read(transactionNotifierProvider).value?.filter;
    double minAmount = currentFilter?.minAmount ?? 0;
    double maxAmount = currentFilter?.maxAmount ?? 1000;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Amount Range'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Min: \$${minAmount.toStringAsFixed(0)}'),
                Slider(
                  value: minAmount,
                  min: 0,
                  max: 10000,
                  onChanged: (value) => setState(() => minAmount = value),
                ),
                const SizedBox(height: 16),
                Text('Max: \$${maxAmount.toStringAsFixed(0)}'),
                Slider(
                  value: maxAmount,
                  min: 0,
                  max: 10000,
                  onChanged: (value) => setState(() => maxAmount = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final currentFilter = ref.read(transactionNotifierProvider).value?.filter;
                final newFilter = currentFilter?.copyWith(
                  minAmount: minAmount,
                  maxAmount: maxAmount,
                ) ?? TransactionFilter(minAmount: minAmount, maxAmount: maxAmount);
                ref.read(transactionNotifierProvider.notifier).applyFilter(newFilter);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

}