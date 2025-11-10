import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';

part 'transaction_state.freezed.dart';

/// State for transaction management
@freezed
class TransactionState with _$TransactionState {
  const factory TransactionState({
    @Default([]) List<Transaction> transactions,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    String? error,
    String? searchQuery,
    TransactionFilter? filter,
    @Default(20) int pageSize,
    @Default(0) int currentOffset,
    @Default(false) bool hasMoreData,
    @Default(false) bool isInitialized,
  }) = _TransactionState;

  const TransactionState._();

  /// Get filtered transactions based on search query and filter
  List<Transaction> get filteredTransactions {
    var filtered = transactions;

    // Apply search filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered.where((transaction) {
        return transaction.description?.toLowerCase().contains(query) == true ||
               transaction.categoryId.toLowerCase().contains(query) ||
               transaction.amount.toString().contains(query);
      }).toList();
    }

    // Apply transaction filter
    if (filter != null) {
      filtered = filtered.where((transaction) {
        // Filter by transaction type
        if (filter!.transactionType != null &&
            transaction.type != filter!.transactionType) {
          return false;
        }

        // Filter by categories (multi-select)
        if (filter!.categoryIds != null && filter!.categoryIds!.isNotEmpty &&
            !filter!.categoryIds!.contains(transaction.categoryId)) {
          return false;
        }

        // Filter by account
        if (filter!.accountId != null &&
            transaction.accountId != filter!.accountId) {
          return false;
        }

        // Filter by date range
        if (filter!.startDate != null &&
            transaction.date.isBefore(filter!.startDate!)) {
          return false;
        }
        if (filter!.endDate != null &&
            transaction.date.isAfter(filter!.endDate!)) {
          return false;
        }

        // Filter by amount range
        if (filter!.minAmount != null &&
            transaction.amount < filter!.minAmount!) {
          return false;
        }
        if (filter!.maxAmount != null &&
            transaction.amount > filter!.maxAmount!) {
          return false;
        }

        return true;
      }).toList();
    }

    return filtered;
  }

  /// Get transactions grouped by date
  Map<DateTime, List<Transaction>> get transactionsByDate {
    final grouped = <DateTime, List<Transaction>>{};

    for (final transaction in filteredTransactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      grouped[date] ??= [];
      grouped[date]!.add(transaction);
    }

    // Sort dates in descending order (newest first)
    final sortedGrouped = Map.fromEntries(
      grouped.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)),
    );

    // Sort transactions within each date by time (newest first)
    for (final date in sortedGrouped.keys) {
      sortedGrouped[date]!.sort((a, b) => b.date.compareTo(a.date));
    }

    return sortedGrouped;
  }

}


/// Statistics for transactions
@freezed
class TransactionStats with _$TransactionStats {
  const factory TransactionStats({
    @Default(0.0) double totalIncome,
    @Default(0.0) double totalExpenses,
    @Default(0.0) double netAmount,
    @Default(0) int transactionCount,
    @Default(0.0) double averageTransactionAmount,
    @Default(0.0) double largestExpense,
  }) = _TransactionStats;

  const TransactionStats._();

  /// Get savings rate (income - expenses) / income
  double get savingsRate => totalIncome > 0
      ? ((totalIncome - totalExpenses) / totalIncome).clamp(0.0, 1.0)
      : 0.0;

  /// Get savings amount
  double get savingsAmount => (totalIncome - totalExpenses).clamp(0.0, double.infinity);

  /// Check if user is spending more than earning
  bool get isOverspending => totalExpenses > totalIncome;

  /// Get expense to income ratio
  double get expenseToIncomeRatio => totalIncome > 0
      ? (totalExpenses / totalIncome).clamp(0.0, double.infinity)
      : 0.0;
}