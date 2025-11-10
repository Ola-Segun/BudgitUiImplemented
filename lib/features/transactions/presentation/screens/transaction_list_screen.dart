import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../shared/presentation/widgets/cards/app_card.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../providers/transaction_providers.dart';
import '../states/transaction_state.dart';
import '../widgets/enhanced_add_transaction_bottom_sheet.dart';
import '../widgets/transaction_filters_bar.dart';
import '../widgets/transaction_stats_card.dart';
import '../widgets/transaction_tile.dart';
import 'category_management_screen.dart';

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
    final stats = ref.watch(transactionStatsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing2,
              vertical: AppDimensions.spacing1,
            ),
            decoration: BoxDecoration(
              // color: AppColors.background2,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                HapticFeedback.selectionClick();
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
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: AppDimensions.iconMd,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'categories',
                  child: Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: AppDimensions.iconSm,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppDimensions.spacing2),
                      Text(
                        'Manage Categories',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'advanced_filters',
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: AppDimensions.iconSm,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppDimensions.spacing2),
                      Text(
                        'Advanced Filters',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: transactionState.when(
        data: (state) => _buildBody(state, stats),
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
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : () => _showAddTransactionSheet(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: AppDimensions.iconMd,
                        height: AppDimensions.iconMd,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: AppDimensions.iconMd,
                      ),
                    SizedBox(width: AppDimensions.spacing2),
                    Text(
                      isLoading ? 'Adding...' : 'Add',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 200.ms, curve: Curves.elasticOut);
        },
      ),
    );
  }

  Widget _buildBody(TransactionState state, TransactionStats stats) {
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
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        itemCount: _calculateItemCount(groupedTransactions, state),
        itemBuilder: (context, index) {
          return _buildListItem(context, index, groupedTransactions, stats, state);
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
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: AppDimensions.iconXl,
              color: AppColors.primary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'No transactions yet',
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 200.ms),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Add your first transaction to get started',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),
          SizedBox(height: AppDimensions.spacing5),
          AppCard(
            elevation: AppCardElevation.medium,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.cardPadding,
              vertical: AppDimensions.spacing3,
            ),
            onTap: () {
              HapticFeedback.mediumImpact();
              _showAddTransactionSheet(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacing2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: AppDimensions.iconMd,
                  ),
                ),
                SizedBox(width: AppDimensions.spacing3),
                Text(
                  'Add Transaction',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 400.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildNoMatchesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing4),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: Icon(
              Icons.search_off,
              size: AppDimensions.iconXl,
              color: AppColors.warning,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'No matching transactions',
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 200.ms),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Try adjusting your search or filters',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),
          SizedBox(height: AppDimensions.spacing5),
          AppCard(
            elevation: AppCardElevation.low,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.cardPadding,
              vertical: AppDimensions.spacing3,
            ),
            onTap: () {
              ref.read(transactionNotifierProvider.notifier).clearFilter();
              ref.read(transactionNotifierProvider.notifier).clearSearch();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacing2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    Icons.clear,
                    color: AppColors.warning,
                    size: AppDimensions.iconMd,
                  ),
                ),
                SizedBox(width: AppDimensions.spacing3),
                Text(
                  'Clear Filters',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 400.ms, curve: Curves.elasticOut),
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
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        children: [
          // Stats Card Skeleton
          const StatsCardSkeleton(),
          SizedBox(height: AppDimensions.sectionGap),

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
    TransactionStats stats,
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
          TransactionStatsCard(
            key: ValueKey('stats_${stats.totalIncome}_${stats.totalExpenses}_${stats.transactionCount}'),
            stats: stats,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.1, duration: 500.ms, delay: 200.ms, curve: Curves.easeOutCubic),
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
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing3,
              vertical: AppDimensions.spacing2,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: AppDimensions.iconSm,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppDimensions.spacing2),
                Text(
                  _formatDateHeader(date),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * (currentIndex ~/ 2)))
          .slideX(begin: 0.1, duration: 300.ms, delay: Duration(milliseconds: 100 * (currentIndex ~/ 2)), curve: Curves.easeOutCubic);
      }

      // Transactions for this date
      for (final transaction in dayTransactions) {
        if (index == currentIndex++) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spacing2), // Changed from spacing2
            child: TransactionTile(transaction: transaction)
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * (currentIndex - 1)))
                .slideY(begin: 0.05, duration: 400.ms, delay: Duration(milliseconds: 50 * (currentIndex - 1)), curve: Curves.easeOutCubic),
          );
        }
      }

      // Spacing after date group
      if (index == currentIndex++) {
        return SizedBox(height: AppDimensions.spacing4);
      }
    }

    // Load More Button or Loading Indicator
    if (state.hasMoreData && !state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing4),
        child: Center(
          child: AppCard(
            elevation: AppCardElevation.low,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.cardPadding,
              vertical: AppDimensions.spacing3,
            ),
            onTap: () => ref.read(transactionNotifierProvider.notifier).loadMoreTransactions(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacing2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    Icons.expand_more,
                    color: AppColors.primary,
                    size: AppDimensions.iconMd,
                  ),
                ),
                SizedBox(width: AppDimensions.spacing3),
                Text(
                  'Load More',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, duration: 300.ms, curve: Curves.elasticOut),
        ),
      );
    } else if (state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing4),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _showAddTransactionSheet(BuildContext context) async {
    await EnhancedAddTransactionBottomSheet.show(
      context: context,
      onSubmit: (transaction) async {
        final success = await ref
            .read(transactionNotifierProvider.notifier)
            .addTransaction(transaction);

        if (success && mounted) {
          // Don't pop here - let the bottom sheet handle its own dismissal
          // to avoid double-popping the navigation stack
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction added successfully')),
              );
            }
          });
        }
      },
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
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.8, // Limit to 80% of screen height
      ),
      child: SingleChildScrollView( // Make scrollable
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacing2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    size: AppDimensions.iconMd,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: AppDimensions.spacing3),
                Text(
                  'Filter Transactions',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spacing5),

            // Transaction Type
            Text(
              'Transaction Type',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
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

            SizedBox(height: AppDimensions.spacing5),

            // Account Filter
            Text(
              'Account',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            AppCard(
              elevation: AppCardElevation.none,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing3,
                vertical: AppDimensions.spacing2,
              ),
              child: DropdownButtonFormField<String?>(
                initialValue: _selectedAccountId,
                decoration: InputDecoration(
                  labelText: 'Select Account',
                  labelStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'All Accounts',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'checking',
                    child: Text(
                      'Checking Account',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'savings',
                    child: Text(
                      'Savings Account',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'credit',
                    child: Text(
                      'Credit Card',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
              ),
            ),

            SizedBox(height: AppDimensions.spacing5),

            // Category Filter (Multi-select)
            Text(
              'Categories',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            AppCard(
              elevation: AppCardElevation.none,
              padding: EdgeInsets.all(AppDimensions.spacing3),
              onTap: () => _showCategoryMultiSelect(context),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedCategoryIds.isEmpty
                          ? 'All Categories'
                          : '${_selectedCategoryIds.length} selected',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                    size: AppDimensions.iconMd,
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDimensions.spacing5),

            // Date Range
            Text(
              'Date Range',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    elevation: AppCardElevation.none,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing3,
                      vertical: AppDimensions.spacing3,
                    ),
                    onTap: () async {
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: AppDimensions.iconMd,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppDimensions.spacing2),
                        Text(
                          _startDate != null
                              ? DateFormat('MMM dd').format(_startDate!)
                              : 'Start Date',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacing4),
                Expanded(
                  child: AppCard(
                    elevation: AppCardElevation.none,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing3,
                      vertical: AppDimensions.spacing3,
                    ),
                    onTap: () async {
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: AppDimensions.iconMd,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppDimensions.spacing2),
                        Text(
                          _endDate != null
                              ? DateFormat('MMM dd').format(_endDate!)
                              : 'End Date',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppDimensions.spacing5),

            // Amount Range
            Text(
              'Amount Range',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.spacing2),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    elevation: AppCardElevation.none,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing3,
                      vertical: AppDimensions.spacing2,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Min Amount',
                        prefixText: '\$',
                        labelStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.number,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _minAmount = value.isEmpty ? null : double.tryParse(value);
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacing4),
                Expanded(
                  child: AppCard(
                    elevation: AppCardElevation.none,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing3,
                      vertical: AppDimensions.spacing2,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Max Amount',
                        prefixText: '\$',
                        labelStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.number,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _maxAmount = value.isEmpty ? null : double.tryParse(value);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppDimensions.spacing6),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    elevation: AppCardElevation.low,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.cardPadding,
                      vertical: AppDimensions.spacing3,
                    ),
                    onTap: widget.onClearFilter,
                    child: Center(
                      child: Text(
                        'Clear',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacing4),
                Expanded(
                  child: AppCard(
                    elevation: AppCardElevation.medium,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.cardPadding,
                      vertical: AppDimensions.spacing3,
                    ),
                    backgroundColor: AppColors.primary,
                    onTap: () {
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
                    child: Center(
                      child: Text(
                        'Apply',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
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