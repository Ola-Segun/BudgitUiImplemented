import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../goals/presentation/notifiers/goal_notifier.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/split_transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_paginated_transactions.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';
import '../states/transaction_state.dart';

/// State notifier for transaction management
class TransactionNotifier extends StateNotifier<AsyncValue<TransactionState>> {
  final GetTransactions _getTransactions;
  final GetPaginatedTransactions _getPaginatedTransactions;
  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GoalNotifier? _goalNotifier;

  TransactionNotifier({
    required GetTransactions getTransactions,
    required GetPaginatedTransactions getPaginatedTransactions,
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    GoalNotifier? goalNotifier,
  })  : _getTransactions = getTransactions,
        _getPaginatedTransactions = getPaginatedTransactions,
        _addTransaction = addTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _goalNotifier = goalNotifier,
        super(const AsyncValue.loading()) {
    loadTransactions();
  }

  /// Load all transactions (legacy method for backward compatibility)
  Future<void> loadTransactions() async {
    final currentState = state.value;
    if (currentState?.isLoading == true) return; // Prevent concurrent loads

    state = const AsyncValue.loading();

    final result = await _getTransactions();

    result.when(
      success: (transactions) {
        state = AsyncValue.data(TransactionState(
          transactions: transactions,
          isInitialized: true,
          hasMoreData: false, // All data loaded at once
        ));
      },
      error: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
    );
  }

  /// Initialize with paginated transactions
  Future<void> initializeWithPagination() async {
    state = const AsyncValue.loading();

    final result = await _getPaginatedTransactions(
      limit: 20,
      offset: 0,
      filter: null,
    );

    result.when(
      success: (transactions) async {
        // Check if there's more data
        final countResult = await _getPaginatedTransactions.getFilteredCount(null);
        final totalCount = countResult.getOrDefault(0);

        state = AsyncValue.data(TransactionState(
          transactions: transactions,
          isInitialized: true,
          hasMoreData: transactions.length < totalCount,
          currentOffset: transactions.length,
        ));
      },
      error: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
    );
  }

  /// Load more transactions (pagination)
  Future<void> loadMoreTransactions() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMoreData) {
      return;
    }

    // Set loading more state
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    final result = await _getPaginatedTransactions(
      limit: currentState.pageSize,
      offset: currentState.currentOffset,
      filter: currentState.filter,
    );

    result.when(
      success: (newTransactions) async {
        if (newTransactions.isEmpty) {
          // No more data
          state = AsyncValue.data(currentState.copyWith(
            isLoadingMore: false,
            hasMoreData: false,
          ));
          return;
        }

        // Check if there's still more data
        final countResult = await _getPaginatedTransactions.getFilteredCount(currentState.filter);
        final totalCount = countResult.getOrDefault(0);
        final allTransactions = [...currentState.transactions, ...newTransactions];

        state = AsyncValue.data(currentState.copyWith(
          transactions: allTransactions,
          isLoadingMore: false,
          hasMoreData: allTransactions.length < totalCount,
          currentOffset: allTransactions.length,
        ));
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(
          isLoadingMore: false,
          error: failure.message,
        ));
      },
    );
  }

  /// Add a new transaction
  Future<bool> addTransaction(Transaction transaction) async {
    debugPrint('TransactionNotifier: Adding transaction - type: ${transaction.type}, amount: ${transaction.amount}, title: ${transaction.title}');
    final currentState = state.value;
    if (currentState == null) {
      return false;
    }

    // Set loading state
    state = AsyncValue.data(currentState.copyWith(isLoading: true));
    debugPrint('TransactionNotifier: Set loading state to true');

    final result = await _addTransaction(transaction);
    debugPrint('TransactionNotifier: Add transaction result received');

    return result.when(
      success: (addedTransaction) {
        debugPrint('TransactionNotifier: Transaction added successfully, reloading transactions');
        // Reload transactions to ensure consistency with pagination and filters
        // Use initializeWithPagination to maintain pagination state
        initializeWithPagination();

        // Refresh goals if transaction has goal allocations
        if (addedTransaction.goalAllocations != null && addedTransaction.goalAllocations!.isNotEmpty && _goalNotifier != null) {
          debugPrint('TransactionNotifier: Transaction has goal allocations, refreshing goals');
          _goalNotifier!.loadGoals();
        }

        debugPrint('TransactionNotifier: Transactions reloaded after successful addition');
        return true;
      },
      error: (failure) {
        debugPrint('TransactionNotifier: Failed to add transaction: ${failure.message}');
        // Revert to original state with error
        state = AsyncValue.data(currentState.copyWith(
          isLoading: false,
          error: failure.message,
        ));
        return false;
      },
    );
  }

  /// Update an existing transaction
  Future<bool> updateTransaction(Transaction transaction) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateTransaction(transaction);

    return result.when(
      success: (updatedTransaction) {
        debugPrint('TransactionNotifier: Transaction updated successfully, reloading transactions');
        // Reload transactions to ensure consistency with pagination and filters
        loadTransactions();
        return true;
      },
      error: (failure) {
        debugPrint('TransactionNotifier: Failed to update transaction: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }

  /// Add a split transaction by converting it to multiple individual transactions
  Future<bool> addSplitTransaction(SplitTransaction splitTransaction) async {
    debugPrint('TransactionNotifier: Adding split transaction with ${splitTransaction.splits.length} splits');

    final currentState = state.value;
    if (currentState == null) {
      return false;
    }

    // Set loading state
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      // Convert split transaction to individual transactions
      final transactions = splitTransaction.splits.map((split) {
        return Transaction(
          id: '${splitTransaction.id}_${split.categoryId}_${DateTime.now().millisecondsSinceEpoch}',
          title: splitTransaction.title,
          amount: split.amount,
          type: splitTransaction.type,
          date: splitTransaction.date,
          categoryId: split.categoryId,
          accountId: splitTransaction.accountId,
          description: split.description ?? splitTransaction.description,
          tags: splitTransaction.tags,
          currencyCode: splitTransaction.currencyCode,
        );
      }).toList();

      // Add all transactions
      bool allSuccessful = true;
      for (final transaction in transactions) {
        final result = await _addTransaction(transaction);
        result.when(
          success: (_) {
            // Transaction added successfully
          },
          error: (failure) {
            allSuccessful = false;
            debugPrint('TransactionNotifier: Failed to add split transaction part: ${failure.message}');
          },
        );
        if (!allSuccessful) break;
      }

      if (allSuccessful) {
        debugPrint('TransactionNotifier: All split transactions added successfully, reloading');
        // Reload transactions to ensure consistency
        initializeWithPagination();
        return true;
      } else {
        // Revert to original state with error
        state = AsyncValue.data(currentState.copyWith(
          isLoading: false,
          error: 'Failed to add some split transactions',
        ));
        return false;
      }
    } catch (e) {
      debugPrint('TransactionNotifier: Error adding split transaction: $e');
      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Delete a transaction
  Future<bool> deleteTransaction(String transactionId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _deleteTransaction(transactionId);

    return result.when(
      success: (_) {
        debugPrint('TransactionNotifier: Transaction deleted successfully, reloading transactions');
        // Reload transactions to ensure consistency with pagination and filters
        loadTransactions();
        return true;
      },
      error: (failure) {
        debugPrint('TransactionNotifier: Failed to delete transaction: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }

  /// Search transactions
  void searchTransactions(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: query));
  }

  /// Apply filter
  void applyFilter(TransactionFilter filter) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(filter: filter));
  }

  /// Clear filter
  void clearFilter() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(filter: null));
  }

  /// Clear search
  void clearSearch() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: null));
  }
}