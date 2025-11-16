import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart' as core_providers;
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/services/category_icon_color_service.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_paginated_transactions.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';
import '../notifiers/transaction_notifier.dart';
import '../notifiers/category_notifier.dart';
import '../states/transaction_state.dart';
import '../states/category_state.dart';

/// State notifier provider for category state management
final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<CategoryState>>((ref) {
  final getCategories = ref.watch(core_providers.getCategoriesProvider);
  final addCategory = ref.watch(core_providers.addCategoryProvider);
  final updateCategory = ref.watch(core_providers.updateCategoryProvider);
  final deleteCategory = ref.watch(core_providers.deleteCategoryProvider);
  final archiveCategory = ref.watch(core_providers.archiveCategoryProvider);
  final unarchiveCategory = ref.watch(core_providers.unarchiveCategoryProvider);

  return CategoryNotifier(
    getCategories: getCategories,
    addCategory: addCategory,
    updateCategory: updateCategory,
    deleteCategory: deleteCategory,
    archiveCategory: archiveCategory,
    unarchiveCategory: unarchiveCategory,
  );
});

/// Provider for transaction categories (backward compatibility)
final transactionCategoriesProvider = Provider<List<TransactionCategory>>((ref) {
  final categoryState = ref.watch(categoryNotifierProvider);
  return categoryState.maybeWhen(
    data: (state) => state.categories,
    orElse: () => TransactionCategory.defaultCategories, // Fallback to defaults during loading/error
  );
});

/// Provider for CategoryIconColorService
final categoryIconColorServiceProvider = Provider<CategoryIconColorService>((ref) {
  final categoryNotifier = ref.watch(categoryNotifierProvider.notifier);
  return CategoryIconColorService(categoryNotifier);
});

/// Provider for GetTransactions use case
final getTransactionsProvider = Provider<GetTransactions>((ref) {
  return ref.read(core_providers.getTransactionsProvider);
});

/// Provider for AddTransaction use case
final addTransactionProvider = Provider<AddTransaction>((ref) {
  return ref.read(core_providers.addTransactionProvider);
});

/// Provider for UpdateTransaction use case
final updateTransactionProvider = Provider<UpdateTransaction>((ref) {
  return ref.read(core_providers.updateTransactionProvider);
});

/// Provider for DeleteTransaction use case
final deleteTransactionProvider = Provider<DeleteTransaction>((ref) {
  return ref.read(core_providers.deleteTransactionProvider);
});

/// Provider for GetPaginatedTransactions use case
final getPaginatedTransactionsProvider = Provider<GetPaginatedTransactions>((ref) {
  final repository = ref.watch(core_providers.transactionRepositoryProvider);
  return GetPaginatedTransactions(repository);
});

/// State notifier provider for transaction state management
final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<TransactionState>>((ref) {
  final getTransactions = ref.watch(getTransactionsProvider);
  final getPaginatedTransactions = ref.watch(getPaginatedTransactionsProvider);
  final addTransaction = ref.watch(addTransactionProvider);
  final updateTransaction = ref.watch(updateTransactionProvider);
  final deleteTransaction = ref.watch(deleteTransactionProvider);

  // Get goal notifier for cross-feature state updates
  final goalNotifier = ref.watch(goalNotifierProvider.notifier);

  return TransactionNotifier(
    getTransactions: getTransactions,
    getPaginatedTransactions: getPaginatedTransactions,
    addTransaction: addTransaction,
    updateTransaction: updateTransaction,
    deleteTransaction: deleteTransaction,
    goalNotifier: goalNotifier,
  );
});

/// Provider for filtered transactions
final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  debugPrint('filteredTransactionsProvider: Computing filtered transactions');
  final transactionState = ref.watch(transactionNotifierProvider);
  debugPrint('filteredTransactionsProvider: Watched transactionNotifierProvider');

  return transactionState.when(
    data: (state) {
      // Apply any filters here if needed
      return AsyncValue.data(state.filteredTransactions);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for transaction statistics
final transactionStatsProvider = Provider<TransactionStats>((ref) {
  // Watch the notifier state directly to compute stats synchronously
  final transactionState = ref.watch(transactionNotifierProvider);

  return transactionState.maybeWhen(
    data: (state) {
      final transactions = state.transactions;
      final totalIncome = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final transactionCount = transactions.length;

      final averageTransactionAmount = transactionCount > 0
          ? (totalIncome + totalExpenses) / transactionCount
          : 0.0;

      final largestExpense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (max, t) => t.amount > max ? t.amount : max);

      return TransactionStats(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        netAmount: totalIncome - totalExpenses,
        transactionCount: transactionCount,
        averageTransactionAmount: averageTransactionAmount,
        largestExpense: largestExpense,
      );
    },
    orElse: () => const TransactionStats(),
  );
});