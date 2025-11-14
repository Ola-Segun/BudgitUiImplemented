import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart' as core_providers;
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/states/category_state.dart';
import '../../../transactions/presentation/states/transaction_state.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/calculate_budget_status.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/update_budget.dart';
import '../notifiers/budget_notifier.dart';
import '../states/budget_state.dart';

/// Provider for GetBudgets use case
final getBudgetsProvider = Provider<GetBudgets>((ref) {
  return ref.read(core_providers.getBudgetsProvider);
});

/// Provider for GetActiveBudgets use case
final getActiveBudgetsProvider = Provider<GetActiveBudgets>((ref) {
  return ref.read(core_providers.getActiveBudgetsProvider);
});

/// Provider for CreateBudget use case
final createBudgetProvider = Provider<CreateBudget>((ref) {
  return ref.read(core_providers.createBudgetProvider);
});

/// Provider for UpdateBudget use case
final updateBudgetProvider = Provider<UpdateBudget>((ref) {
  return ref.read(core_providers.updateBudgetProvider);
});

/// Provider for DeleteBudget use case
final deleteBudgetProvider = Provider<DeleteBudget>((ref) {
  return ref.read(core_providers.deleteBudgetProvider);
});

/// Provider for CalculateBudgetStatus use case
final calculateBudgetStatusProvider = Provider<CalculateBudgetStatus>((ref) {
  return ref.read(core_providers.calculateBudgetStatusProvider);
});

/// State notifier provider for budget state management
final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, AsyncValue<BudgetState>>((ref) {
  final getBudgets = ref.watch(getBudgetsProvider);
  final getActiveBudgets = ref.watch(getActiveBudgetsProvider);
  final createBudget = ref.watch(createBudgetProvider);
  final updateBudget = ref.watch(updateBudgetProvider);
  final deleteBudget = ref.watch(deleteBudgetProvider);
  final calculateBudgetStatus = ref.watch(calculateBudgetStatusProvider);

  final notifier = BudgetNotifier(
    getBudgets: getBudgets,
    getActiveBudgets: getActiveBudgets,
    createBudget: createBudget,
    updateBudget: updateBudget,
    deleteBudget: deleteBudget,
    calculateBudgetStatus: calculateBudgetStatus,
  );

  // Listen to transaction changes and refresh budget statuses
  ref.listen<AsyncValue<TransactionState>>(
    transactionNotifierProvider,
    (previous, next) {
      // Refresh budget statuses when transactions change (more responsive)
      // This ensures real-time updates to total active budget costs
      notifier.loadActiveBudgets();
    },
    fireImmediately: false,
  );

  // Listen to category changes and refresh budget statuses only when necessary
  ref.listen<AsyncValue<CategoryState>>(
    categoryNotifierProvider,
    (previous, next) {
      // Only refresh if categories were actually modified (not just operation state changes)
      final prevCategories = previous?.value?.categories ?? [];
      final nextCategories = next.value?.categories ?? [];

      // Check if categories actually changed (not just operation state)
      if (prevCategories.length != nextCategories.length ||
          !prevCategories.every((cat) => nextCategories.any((c) => c.id == cat.id && c.name == cat.name))) {
        notifier.loadActiveBudgets();
      }
    },
    fireImmediately: false,
  );

  return notifier;
});

/// Provider for filtered budgets
final filteredBudgetsProvider = Provider<AsyncValue<List<Budget>>>((ref) {
  final budgetState = ref.watch(budgetNotifierProvider);

  return budgetState.when(
    data: (state) {
      return AsyncValue.data(state.filteredBudgets);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for active budgets
final activeBudgetsProvider = Provider<AsyncValue<List<Budget>>>((ref) {
  final budgetState = ref.watch(budgetNotifierProvider);

  return budgetState.when(
    data: (state) {
      return AsyncValue.data(state.activeBudgets);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for budget statuses
final budgetStatusesProvider = Provider<AsyncValue<List<BudgetStatus>>>((ref) {
  final budgetState = ref.watch(budgetNotifierProvider);

  return budgetState.when(
    data: (state) {
      return AsyncValue.data(state.budgetStatuses);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for selected budget
final selectedBudgetProvider = Provider<AsyncValue<Budget?>>((ref) {
  final budgetState = ref.watch(budgetNotifierProvider);

  return budgetState.when(
    data: (state) => AsyncValue.data(state.selectedBudget),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for budget statistics
final budgetStatsProvider = Provider<AsyncValue<BudgetStats>>((ref) {
  final budgetState = ref.watch(budgetNotifierProvider);

  return budgetState.when(
    data: (state) {
      final budgets = state.budgets;
      final activeBudgets = state.activeBudgets;
      final totalBudgetAmount = budgets.fold<double>(0.0, (sum, budget) => sum + budget.totalBudget);
      final activeBudgetAmount = activeBudgets.fold<double>(0.0, (sum, budget) => sum + budget.totalBudget);

      // Calculate total active budget costs (actual spent amounts)
      final totalActiveCosts = state.budgetStatuses
          .where((status) => activeBudgets.any((budget) => budget.id == status.budget.id))
          .fold<double>(0.0, (sum, status) => sum + status.totalSpent);

      final healthyBudgets = state.budgetStatuses.where((status) => status.overallHealth == BudgetHealth.healthy).length;
      final warningBudgets = state.budgetStatuses.where((status) => status.overallHealth == BudgetHealth.warning).length;
      final criticalBudgets = state.budgetStatuses.where((status) => status.overallHealth == BudgetHealth.critical).length;
      final overBudgetCount = state.budgetStatuses.where((status) => status.overallHealth == BudgetHealth.overBudget).length;

      final stats = BudgetStats(
        totalBudgets: budgets.length,
        activeBudgets: activeBudgets.length,
        totalBudgetAmount: totalBudgetAmount,
        activeBudgetAmount: activeBudgetAmount,
        totalActiveCosts: totalActiveCosts,
        healthyBudgets: healthyBudgets,
        warningBudgets: warningBudgets,
        criticalBudgets: criticalBudgets,
        overBudgetCount: overBudgetCount,
      );

      return AsyncValue.data(stats);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for individual budget by ID
final budgetProvider = Provider.family<AsyncValue<Budget?>, String>((ref, budgetId) {
  final budgetState = ref.watch(budgetNotifierProvider);

  return budgetState.when(
    data: (state) => AsyncValue.data(
      state.budgets.where((budget) => budget.id == budgetId).firstOrNull,
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});


/// Provider for budget status by ID with real-time updates
final budgetStatusProvider = FutureProvider.family<BudgetStatus?, String>((ref, budgetId) async {
  debugPrint('BudgetStatusProvider: Starting calculation for budgetId: $budgetId');

  // Listen to budget state changes to refresh
  final budgetState = ref.watch(budgetNotifierProvider);
  debugPrint('BudgetStatusProvider: Budget state type: ${budgetState.runtimeType}');

  // Listen to transaction changes to refresh status immediately
  final transactionState = ref.watch(transactionNotifierProvider);
  debugPrint('BudgetStatusProvider: Transaction state type: ${transactionState.runtimeType}');

  // Listen to category changes to refresh status (important for category name/icon/color updates)
  final categoryState = ref.watch(categoryNotifierProvider);
  debugPrint('BudgetStatusProvider: Category state type: ${categoryState.runtimeType}');

  final calculateBudgetStatus = ref.watch(calculateBudgetStatusProvider);
  debugPrint('BudgetStatusProvider: CalculateBudgetStatus instance obtained');

  // Get budget from the notifier state instead of direct repository call
  final budget = budgetState.maybeWhen(
    data: (state) {
      final foundBudget = state.budgets.where((b) => b.id == budgetId).firstOrNull;
      debugPrint('BudgetStatusProvider: Found budget in state: ${foundBudget?.id ?? 'null'}');
      return foundBudget;
    },
    loading: () {
      debugPrint('BudgetStatusProvider: Budget state is loading');
      return null;
    },
    error: (error, stack) {
      debugPrint('BudgetStatusProvider: Budget state error: $error');
      debugPrint('BudgetStatusProvider: Budget state stack: $stack');
      return null;
    },
    orElse: () {
      debugPrint('BudgetStatusProvider: Budget state is in unexpected state');
      return null;
    },
  );

  if (budget == null) {
    debugPrint('BudgetStatusProvider: Budget not found for ID: $budgetId - returning null');
    return null;
  }

  // Validate budget data integrity before processing
  try {
    if (budget.categories.isEmpty) {
      debugPrint('BudgetStatusProvider: WARNING - Budget has no categories for budget $budgetId');
    } else {
      // Check for corrupted category data
      for (final category in budget.categories) {
        if (category.id.isEmpty) {
          debugPrint('BudgetStatusProvider: ERROR - Budget category with null/empty ID found in budget $budgetId');
          return null;
        }
        if (category.amount.isNaN || category.amount.isInfinite) {
          debugPrint('BudgetStatusProvider: ERROR - Budget category ${category.id} has invalid amount: ${category.amount} in budget $budgetId');
          return null;
        }
      }
    }
  } catch (e, stackTrace) {
    debugPrint('BudgetStatusProvider: CRITICAL - Error validating budget data for $budgetId: $e');
    debugPrint('BudgetStatusProvider: Validation stack trace: $stackTrace');
    return null;
  }

  debugPrint('BudgetStatusProvider: Calculating status for budget: ${budget.id} with ${budget.categories.length} categories');

  // Implement retry mechanism for budget status calculation
  const int maxRetries = 2;
  Duration retryDelay = const Duration(seconds: 1);

  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      debugPrint('BudgetStatusProvider: Attempt $attempt/$maxRetries for budget $budgetId');
      final result = await calculateBudgetStatus(budget);
      debugPrint('BudgetStatusProvider: calculateBudgetStatus returned result type: ${result.runtimeType}');

      final status = result.when(
        success: (status) {
          debugPrint('BudgetStatusProvider: SUCCESS - Status calculated for budget ${budget.id}: spent=\$${status.totalSpent.toStringAsFixed(2)}, budget=\$${status.totalBudget.toStringAsFixed(2)}, categories=${status.categoryStatuses.length}');

          // Validate returned status data
          if (status.totalSpent.isNaN || status.totalSpent.isInfinite) {
            debugPrint('BudgetStatusProvider: ERROR - Invalid totalSpent in status for budget $budgetId: ${status.totalSpent}');
            return null;
          }
          if (status.totalBudget.isNaN || status.totalBudget.isInfinite) {
            debugPrint('BudgetStatusProvider: ERROR - Invalid totalBudget in status for budget $budgetId: ${status.totalBudget}');
            return null;
          }

          return status;
        },
        error: (failure) {
          debugPrint('BudgetStatusProvider: ERROR - Failed to calculate budget status for ${budget.id}: ${failure.message}');
          debugPrint('BudgetStatusProvider: ERROR - Failure type: ${failure.runtimeType}');

          // Enhanced error handling - check for different types of failures
          if (_isConnectionError(failure)) {
            debugPrint('BudgetStatusProvider: CONNECTION ERROR detected - returning null to show offline state');
            return null; // UI will handle this as offline state
          } else if (_isRetryableError(failure) && attempt < maxRetries) {
            debugPrint('BudgetStatusProvider: RETRYABLE ERROR detected - will retry');
            // Don't return, let the loop continue
            return null; // This will be ignored since we continue
          } else {
            debugPrint('BudgetStatusProvider: NON-RETRYABLE ERROR or MAX RETRIES - returning null');
            // For non-retryable errors or max retries reached, return null
            return null;
          }
        },
      );

      // If we got a status, return it
      if (status != null) {
        return status;
      }
      // If status is null and it's retryable, continue to next attempt
      if (result.isError && _isRetryableError(result.failureOrNull!) && attempt < maxRetries) {
        await Future.delayed(retryDelay);
        retryDelay *= 2; // Exponential backoff
        continue;
      }
      // If not retryable or max attempts, return null
      return null;
    } catch (e, stack) {
      debugPrint('BudgetStatusProvider: EXCEPTION - Unexpected error calculating budget status for ${budget.id}: $e');
      debugPrint('BudgetStatusProvider: EXCEPTION - Stack trace: $stack');

      // Enhanced exception handling
      if (_isConnectionException(e) && attempt < maxRetries) {
        debugPrint('BudgetStatusProvider: CONNECTION EXCEPTION detected - retrying in ${retryDelay.inSeconds}s');
        await Future.delayed(retryDelay);
        retryDelay *= 2; // Exponential backoff
        continue; // Retry
      } else if (_isConnectionException(e)) {
        debugPrint('BudgetStatusProvider: CONNECTION EXCEPTION detected - max retries reached, returning null');
        return null; // UI will show offline indicator
      } else {
        debugPrint('BudgetStatusProvider: NON-CONNECTION EXCEPTION - rethrowing');
        rethrow; // Let Riverpod handle unexpected exceptions
      }
    }
  }

  // This should never be reached, but just in case
  debugPrint('BudgetStatusProvider: Unexpected end of retry loop for budget $budgetId');
  return null;
}
);

/// Helper function to check if failure is connection-related
bool _isConnectionError(Object failure) {
  final message = failure.toString().toLowerCase();
  return message.contains('connection') ||
         message.contains('network') ||
         message.contains('timeout') ||
         message.contains('unreachable') ||
         message.contains('dns') ||
         message.contains('socket') ||
         message.contains('http');
}

/// Helper function to check if failure is retryable
bool _isRetryableError(Object failure) {
  // Most failures are retryable except for data validation errors
  final message = failure.toString().toLowerCase();
  return !message.contains('invalid') &&
          !message.contains('not found') &&
          !message.contains('unauthorized') &&
          !message.contains('forbidden') &&
          !message.contains('permission denied') &&
          !message.contains('authentication failed');
}

/// Helper function to check if exception is connection-related
bool _isConnectionException(Object e) {
  final errorString = e.toString().toLowerCase();
  return errorString.contains('connection') ||
         errorString.contains('network') ||
         errorString.contains('timeout') ||
         errorString.contains('socket') ||
         errorString.contains('unreachable') ||
         errorString.contains('dns') ||
         errorString.contains('http');
}

/// Provider for budget transactions
final budgetTransactionsProvider = FutureProvider.family<List<dynamic>, String>((ref, budgetId) async {
  // This would need to be implemented - for now return empty list
  // In a real implementation, this would filter transactions by budget categories and date range
  return [];
});

/// Budget statistics
class BudgetStats {
  const BudgetStats({
    required this.totalBudgets,
    required this.activeBudgets,
    required this.totalBudgetAmount,
    required this.activeBudgetAmount,
    required this.totalActiveCosts,
    required this.healthyBudgets,
    required this.warningBudgets,
    required this.criticalBudgets,
    required this.overBudgetCount,
  });

  final int totalBudgets;
  final int activeBudgets;
  final double totalBudgetAmount;
  final double activeBudgetAmount;
  final double totalActiveCosts;
  final int healthyBudgets;
  final int warningBudgets;
  final int criticalBudgets;
  final int overBudgetCount;

  /// Get percentage of healthy budgets
  double get healthyPercentage => activeBudgets > 0 ? (healthyBudgets / activeBudgets) * 100 : 0.0;

  /// Get percentage of budgets in warning
  double get warningPercentage => activeBudgets > 0 ? (warningBudgets / activeBudgets) * 100 : 0.0;

  /// Get percentage of budgets in critical state
  double get criticalPercentage => activeBudgets > 0 ? (criticalBudgets / activeBudgets) * 100 : 0.0;

  /// Get percentage of over-budget budgets
  double get overBudgetPercentage => activeBudgets > 0 ? (overBudgetCount / activeBudgets) * 100 : 0.0;

  /// Get total active budget costs as percentage of active budget amount
  double get activeCostsPercentage => activeBudgetAmount > 0 ? (totalActiveCosts / activeBudgetAmount) * 100 : 0.0;
}