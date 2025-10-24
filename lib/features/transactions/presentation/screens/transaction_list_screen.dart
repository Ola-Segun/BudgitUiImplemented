import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../providers/transaction_providers.dart';
import '../states/transaction_state.dart';
import '../widgets/add_transaction_bottom_sheet.dart';
import '../widgets/transaction_filters_bar.dart';
import '../widgets/transaction_stats_card.dart';
import '../widgets/transaction_tile.dart';
import 'category_management_screen.dart';
import 'transaction_detail_screen.dart';

/// Screen for displaying and managing transactions
class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize with pagination
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionNotifierProvider.notifier).initializeWithPagination();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionNotifierProvider);
    final categories = ref.watch(transactionCategoriesProvider);
    final statsState = ref.watch(transactionStatsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'categories':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryManagementScreen(),
                    ),
                  );
                  break;
                case 'advanced_filters':
                  _showFilterSheet(context, categories);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Manage Categories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'advanced_filters',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Advanced Filters'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: transactionState.when(
        data: (state) => _buildBody(state, statsState),
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(transactionNotifierProvider),
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final isLoading = ref.watch(transactionNotifierProvider).value?.isLoading ?? false;
          return Container(
            height: 56.0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : () => _showAddTransactionSheet(context),
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      const Icon(Icons.add_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      isLoading ? 'Adding...' : 'Add',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ).pressEffect();
        },
      ),
    );
  }

  Widget _buildBody(TransactionState state, AsyncValue<TransactionStats> statsState) {
    // Show skeleton loading if we have no transactions but are not in initial loading state
    if (state.transactions.isEmpty && !state.isLoading) {
      return _buildEmptyState();
    }

    // Show skeleton loading if we have no transactions but data is being loaded
    if (state.transactions.isEmpty && state.isLoading) {
      return _buildSkeletonLoading();
    }

    final groupedTransactions = state.transactionsByDate;

    if (groupedTransactions.isEmpty) {
      // Check if we have transactions but they are filtered out
      if (state.transactions.isNotEmpty && (state.searchQuery != null || state.filter != null)) {
        return _buildNoMatchesState();
      }
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(transactionNotifierProvider.notifier).loadTransactions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _calculateItemCount(groupedTransactions, state),
        itemBuilder: (context, index) {
          return _buildListItem(context, index, groupedTransactions, statsState, state);
        },
      ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.02, duration: 300.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showAddTransactionSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ).pressEffect(),
        ],
      ),
    );
  }

  Widget _buildNoMatchesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No matching transactions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(transactionNotifierProvider.notifier).clearFilter();
              ref.read(transactionNotifierProvider.notifier).clearSearch();
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear Filters'),
          ).pressEffect(),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(transactionNotifierProvider.notifier).loadTransactions();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Stats Card Skeleton
          const StatsCardSkeleton(),
          const SizedBox(height: 16),

          // Transaction List Skeleton
          const TransactionListSkeleton(itemCount: 6),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }

  int _calculateItemCount(Map<DateTime, List<Transaction>> groupedTransactions, TransactionState state) {
    int count = 2; // Filters bar and stats card

    // Add count for each date header + transactions + spacing
    for (final dayTransactions in groupedTransactions.values) {
      count += 1 + dayTransactions.length + 1; // header + transactions + spacing
    }

    // Add load more button or loading indicator
    if (state.hasMoreData || state.isLoadingMore) {
      count += 1;
    }

    return count;
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Map<DateTime, List<Transaction>> groupedTransactions,
    AsyncValue<TransactionStats> statsState,
    TransactionState state,
  ) {
    int currentIndex = 0;

    // Filters Bar (index 0)
    if (index == currentIndex++) {
      return const Column(
        children: [
          TransactionFiltersBar(),
          SizedBox(height: 18),
        ],
      ).animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, duration: 400.ms, curve: Curves.easeOutCubic);
    }

    // Stats Card (index 1)
    if (index == currentIndex++) {
      return Column(
        children: [
          statsState.when(
            data: (stats) => TransactionStatsCard(stats: stats)
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slideY(begin: 0.1, duration: 500.ms, delay: 200.ms, curve: Curves.easeOutCubic),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    // Transactions
    for (final entry in groupedTransactions.entries) {
      final date = entry.key;
      final dayTransactions = entry.value;

      // Date header
      if (index == currentIndex++) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            _formatDateHeader(date),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ).animate()
          .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * (currentIndex ~/ 2)))
          .slideX(begin: 0.1, duration: 300.ms, delay: Duration(milliseconds: 100 * (currentIndex ~/ 2)), curve: Curves.easeOutCubic);
      }

      // Transactions for this date
      for (final transaction in dayTransactions) {
        if (index == currentIndex++) {
          return TransactionTile(transaction: transaction)
              .animate()
              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * (currentIndex - 1)))
              .slideY(begin: 0.05, duration: 400.ms, delay: Duration(milliseconds: 50 * (currentIndex - 1)), curve: Curves.easeOutCubic);
        }
      }

      // Spacing after date group
      if (index == currentIndex++) {
        return const SizedBox(height: 16);
      }
    }

    // Load More Button or Loading Indicator
    if (state.hasMoreData && !state.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: FilledButton.icon(
            onPressed: () => ref.read(transactionNotifierProvider.notifier).loadMoreTransactions(),
            icon: const Icon(Icons.expand_more),
            label: const Text('Load More'),
          ).pressEffect(),
        ),
      );
    } else if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _showAddTransactionSheet(BuildContext context) async {
    await AppBottomSheet.show(
      context: context,
      child: AddTransactionBottomSheet(
        onSubmit: (transaction) async {
          final success = await ref
              .read(transactionNotifierProvider.notifier)
              .addTransaction(transaction);

          if (success && mounted) {
            Navigator.pop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction added successfully')),
                );
              }
            });
          }
        },
      ),
    );
  }

  Future<void> _showFilterSheet(BuildContext context, List<TransactionCategory> categories) async {
    final currentState = ref.read(transactionNotifierProvider).value;
    if (currentState == null) return;

    await showModalBottomSheet(
      context: context,
      builder: (context) => TransactionFilterBottomSheet(
        currentFilter: currentState.filter,
        categories: categories,
        onApplyFilter: (filter) {
          ref.read(transactionNotifierProvider.notifier).applyFilter(filter);
          Navigator.pop(context);
        },
        onClearFilter: () {
          ref.read(transactionNotifierProvider.notifier).clearFilter();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _onTransactionTap(Transaction transaction) {
    // Navigate to transaction detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(transactionId: transaction.id),
      ),
    );
  }

  Future<void> _confirmDeleteTransaction(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete "${transaction.description ?? 'this transaction'}"?',
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
      final success = await ref
          .read(transactionNotifierProvider.notifier)
          .deleteTransaction(transaction.id);

      if (success && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction deleted')),
            );
          }
        });
      }
    }
  }
}

/// Bottom sheet for transaction filters
class TransactionFilterBottomSheet extends ConsumerWidget {
  const TransactionFilterBottomSheet({
    super.key,
    this.currentFilter,
    required this.categories,
    required this.onApplyFilter,
    required this.onClearFilter,
  });

  final TransactionFilter? currentFilter;
  final List<TransactionCategory> categories;
  final void Function(TransactionFilter) onApplyFilter;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    return _TransactionFilterBottomSheetContent(
      currentFilter: currentFilter,
      categories: categories,
      categoryIconColorService: categoryIconColorService,
      onApplyFilter: onApplyFilter,
      onClearFilter: onClearFilter,
    );
  }
}

class _TransactionFilterBottomSheetContent extends StatefulWidget {
  const _TransactionFilterBottomSheetContent({
    required this.currentFilter,
    required this.categories,
    required this.categoryIconColorService,
    required this.onApplyFilter,
    required this.onClearFilter,
  });

  final TransactionFilter? currentFilter;
  final List<TransactionCategory> categories;
  final dynamic categoryIconColorService;
  final void Function(TransactionFilter) onApplyFilter;
  final VoidCallback onClearFilter;

  @override
  State<_TransactionFilterBottomSheetContent> createState() => _TransactionFilterBottomSheetContentState();
}

class _TransactionFilterBottomSheetContentState extends State<_TransactionFilterBottomSheetContent> {
  late TransactionType? _selectedType;
  late List<String> _selectedCategoryIds;
  late String? _selectedAccountId;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late double? _minAmount;
  late double? _maxAmount;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentFilter?.transactionType;
    _selectedCategoryIds = widget.currentFilter?.categoryIds ?? [];
    _selectedAccountId = widget.currentFilter?.accountId;
    _startDate = widget.currentFilter?.startDate;
    _endDate = widget.currentFilter?.endDate;
    _minAmount = widget.currentFilter?.minAmount;
    _maxAmount = widget.currentFilter?.maxAmount;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TransactionFilterBottomSheet: Building sheet');
    final screenHeight = MediaQuery.of(context).size.height;
    debugPrint('TransactionFilterBottomSheet: Screen height: $screenHeight');

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.8, // Limit to 80% of screen height
      ),
      child: SingleChildScrollView( // Make scrollable
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter Transactions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Transaction Type
            Text(
              'Transaction Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
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

            const SizedBox(height: 24),

            // Account Filter
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _selectedAccountId,
              decoration: const InputDecoration(
                labelText: 'Select Account',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Accounts'),
                ),
                const DropdownMenuItem(
                  value: 'checking',
                  child: Text('Checking Account'),
                ),
                const DropdownMenuItem(
                  value: 'savings',
                  child: Text('Savings Account'),
                ),
                const DropdownMenuItem(
                  value: 'credit',
                  child: Text('Credit Card'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAccountId = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Category Filter (Multi-select)
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showCategoryMultiSelect(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedCategoryIds.isEmpty
                            ? 'All Categories'
                            : '${_selectedCategoryIds.length} selected',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Date Range
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _startDate != null
                          ? DateFormat('MMM dd').format(_startDate!)
                          : 'Start Date',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _endDate != null
                          ? DateFormat('MMM dd').format(_endDate!)
                          : 'End Date',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Amount Range
            Text(
              'Amount Range',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Min Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _minAmount = value.isEmpty ? null : double.tryParse(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _maxAmount = value.isEmpty ? null : double.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClearFilter,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final filter = TransactionFilter(
                        transactionType: _selectedType,
                        categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
                        accountId: _selectedAccountId,
                        startDate: _startDate,
                        endDate: _endDate,
                        minAmount: _minAmount,
                        maxAmount: _maxAmount,
                      );
                      widget.onApplyFilter(filter);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryMultiSelect(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Categories'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.categories.map((category) {
                final isSelected = _selectedCategoryIds.contains(category.id);
                return CheckboxListTile(
                  title: Row(
                    children: [
                      Icon(
                        widget.categoryIconColorService.getIconForCategory(category.id),
                        size: 20,
                        color: widget.categoryIconColorService.getColorForCategory(category.id),
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

}