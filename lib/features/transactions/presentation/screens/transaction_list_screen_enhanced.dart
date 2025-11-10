// lib/features/transactions/presentation/screens/transaction_list_screen_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import '../states/transaction_state.dart';
import '../widgets/enhanced_transaction_header.dart';
import '../widgets/enhanced_transaction_tile.dart';
import '../widgets/enhanced_transaction_filters.dart';
import '../widgets/enhanced_transaction_filters_bar.dart';
import '../widgets/enhanced_empty_states.dart';
import '../widgets/enhanced_shimmer_loading.dart';
import '../widgets/enhanced_add_transaction_bottom_sheet.dart';

/// Enhanced Transaction List Screen with modern UI
class TransactionListScreenEnhanced extends ConsumerStatefulWidget {
  const TransactionListScreenEnhanced({super.key});

  @override
  ConsumerState<TransactionListScreenEnhanced> createState() => _TransactionListScreenEnhancedState();
}

class _TransactionListScreenEnhancedState extends ConsumerState<TransactionListScreenEnhanced> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionNotifierProvider.notifier).initializeWithPagination();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionNotifierProvider);
    final stats = ref.watch(transactionStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            EnhancedTransactionHeader(
              onFilterPressed: () => _showFilterSheet(context),
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                ref.read(transactionNotifierProvider.notifier).searchTransactions(query);
              },
              hasActiveFilters: transactionState.value?.filter != null,
            ),

            // Horizontal Filter Bar
            EnhancedTransactionFiltersBar(
              currentFilter: transactionState.value?.filter,
              onFilterApplied: (filter) {
                ref.read(transactionNotifierProvider.notifier).applyFilter(filter);
              },
              onFilterCleared: () {
                ref.read(transactionNotifierProvider.notifier).clearFilter();
              },
            ),

            // Main Content
            Expanded(
              child: transactionState.when(
                data: (state) => _buildBody(state, stats),
                loading: () => const LoadingView(),
                error: (error, stack) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.refresh(transactionNotifierProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildBody(TransactionState state, TransactionStats stats) {
    if (state.transactions.isEmpty && !state.isLoading) {
      return EnhancedEmptyTransactionsState(
        onAddTransaction: () => _showAddTransactionSheet(context),
      );
    }

    if (state.transactions.isEmpty && state.isLoading) {
      return const EnhancedShimmerLoading();
    }

    final groupedTransactions = state.transactionsByDate;

    if (groupedTransactions.isEmpty) {
      if (state.transactions.isNotEmpty && (state.searchQuery != null || state.filter != null)) {
        return EnhancedNoMatchesState(
          onClearFilters: () {
            ref.read(transactionNotifierProvider.notifier).clearFilter();
            ref.read(transactionNotifierProvider.notifier).clearSearch();
          },
        );
      }
      return EnhancedEmptyTransactionsState(
        onAddTransaction: () => _showAddTransactionSheet(context),
      );
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
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Map<DateTime, List<Transaction>> groupedTransactions,
    TransactionStats stats,
    TransactionState state,
  ) {
    int currentIndex = 0;

    // Stats Card (index 0)
    // if (index == currentIndex++) {
    //   return Padding(
    //     padding: const EdgeInsets.only(bottom: 16),
    //     child: EnhancedTransactionStatsCard(stats: stats)
    //         .animate()
    //         .fadeIn(duration: 500.ms)
    //         .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic),
    //   );
    // }

    // Transactions grouped by date
    for (final entry in groupedTransactions.entries) {
      final date = entry.key;
      final dayTransactions = entry.value;

      // Date header
      if (index == currentIndex++) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
          child: _DateHeader(date: date)
              .animate()
              .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * (currentIndex ~/ 2)))
              .slideX(begin: -0.1, duration: 300.ms, delay: Duration(milliseconds: 50 * (currentIndex ~/ 2))),
        );
      }

      // Transactions for this date
      for (final transaction in dayTransactions) {
        if (index == currentIndex++) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: EnhancedTransactionTile(transaction: transaction)
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 30 * (currentIndex - 1)))
                .slideX(begin: 0.05, duration: 400.ms, delay: Duration(milliseconds: 30 * (currentIndex - 1))),
          );
        }
      }

      // Spacing after date group
      if (index == currentIndex++) {
        return SizedBox(height: AppDimensions.spacing4);
      }
    }

    // Load More Button
    if (state.hasMoreData && !state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing4),
        child: Center(
          child: TextButton.icon(
            onPressed: () => ref.read(transactionNotifierProvider.notifier).loadMoreTransactions(),
            icon: const Icon(Icons.expand_more),
            label: const Text('Load More'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      );
    } else if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFAB() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddTransactionSheet(context),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Add Transaction',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 600.ms)
      .slideY(begin: 0.1, duration: 300.ms, delay: 600.ms, curve: Curves.elasticOut);
  }

  int _calculateItemCount(Map<DateTime, List<Transaction>> groupedTransactions, TransactionState state) {
    int count = 1; // Stats card

    for (final dayTransactions in groupedTransactions.values) {
      count += 1 + dayTransactions.length + 1; // header + transactions + spacing
    }

    if (state.hasMoreData || state.isLoadingMore) {
      count += 1;
    }

    return count;
  }

  Future<void> _showAddTransactionSheet(BuildContext context) async {
    await EnhancedAddTransactionBottomSheet.show(
      context: context,
      onSubmit: (transaction) async {
        final success = await ref
            .read(transactionNotifierProvider.notifier)
            .addTransaction(transaction);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction added successfully')),
          );
        }
      },
    );
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final currentState = ref.read(transactionNotifierProvider).value;
    if (currentState == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedTransactionFilters(
        currentFilter: currentState.filter,
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

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMMM dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing3,
        vertical: AppDimensions.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppDimensions.spacing2),
          Text(
            _formatDate(),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}