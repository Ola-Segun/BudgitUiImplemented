import 'dart:async';
import 'dart:developer' as developer;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/budget.dart';

/// Exception for retryable operations
class RetryableException implements Exception {
  const RetryableException(this.failure);

  final Failure failure;

  @override
  String toString() => 'RetryableException: ${failure.message}';
}

/// Use case for calculating budget status with spending data
class CalculateBudgetStatus {
  const CalculateBudgetStatus(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  /// Configuration for retry mechanism
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(milliseconds: 500);
  static const double _retryBackoffMultiplier = 2.0;

  /// Execute the use case with a budget object
  Future<Result<BudgetStatus>> call(Budget budget) async {
    try {
      // Calculate spending for each category
      final categoryStatuses = <CategoryStatus>[];

      for (final category in budget.categories) {
        final spentResult = await _getCategorySpending(
          category.id,
          budget.startDate,
          budget.endDate,
          budget.createdAt,
        );

        if (spentResult.isError) {
          return Result.error(spentResult.failureOrNull!);
        }

        final spent = spentResult.dataOrNull ?? 0.0;
        final percentage = category.amount > 0 ? (spent / category.amount) * 100 : 0.0;

        final status = _getBudgetHealth(percentage);

        categoryStatuses.add(CategoryStatus(
          categoryId: category.id,
          spent: spent,
          budget: category.amount,
          percentage: percentage,
          status: status,
        ));
      }

      // Calculate overall totals
      final totalSpent = categoryStatuses.fold<double>(0.0, (sum, status) => sum + status.spent);
      final totalBudget = budget.totalBudget;
      final daysRemaining = budget.remainingDays;

      // Apply rollover logic if enabled
      final adjustedTotalSpent = budget.allowRollover
          ? _calculateRolloverAdjustedSpending(totalSpent, totalBudget, budget)
          : totalSpent;

      final budgetStatus = BudgetStatus(
        budget: budget,
        totalSpent: adjustedTotalSpent,
        totalBudget: totalBudget,
        categoryStatuses: categoryStatuses,
        daysRemaining: daysRemaining,
      );

      return Result.success(budgetStatus);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to calculate budget status: $e'));
    }
  }

  /// Get spending amount for a category within date range, starting from budget creation
  Future<Result<double>> _getCategorySpending(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
    DateTime? budgetCreatedAt,
  ) async {
    developer.log('CalculateBudgetStatus: STARTING category spending calculation for category: $categoryId');
    developer.log('CalculateBudgetStatus: Date range: $startDate to $endDate, budget created: $budgetCreatedAt');

    // Implement retry mechanism with exponential backoff
    return await _retryWithBackoff(
      operation: () async {
        developer.log('CalculateBudgetStatus: Calling _transactionRepository.getByCategory($categoryId)');
        final transactionsResult = await _transactionRepository.getByCategory(categoryId);
        developer.log('CalculateBudgetStatus: Repository call completed, result type: ${transactionsResult.runtimeType}');

        if (transactionsResult.isError) {
          final failure = transactionsResult.failureOrNull!;
          developer.log('CalculateBudgetStatus: ERROR - Repository returned error for category $categoryId: $failure');
          developer.log('CalculateBudgetStatus: ERROR - Failure type: ${failure.runtimeType}');

          // Check if this is a retryable error (network/connection issues)
          if (_isRetryableError(failure)) {
            developer.log('CalculateBudgetStatus: RETRYABLE ERROR detected for category $categoryId: ${failure.message}');
            throw RetryableException(failure);
          }

          // Non-retryable error, return immediately
          return Result.error(failure);
        }

        final allTransactions = transactionsResult.dataOrNull ?? [];
        developer.log('CalculateBudgetStatus: SUCCESS - Retrieved ${allTransactions.length} total transactions for category $categoryId');

        // Filter by date range and sum expenses, but only include transactions on or after budget creation
        final effectiveStartDate = budgetCreatedAt ?? startDate;
        developer.log('CalculateBudgetStatus: Using effective start date: $effectiveStartDate');

        final filteredTransactions = allTransactions
            .where((transaction) {
              final inDateRange = transaction.date.compareTo(effectiveStartDate) >= 0 &&
                                 transaction.date.isBefore(endDate.add(const Duration(days: 1)));
              final isExpense = transaction.type == TransactionType.expense;
              return inDateRange && isExpense;
            })
            .toList();

        developer.log('CalculateBudgetStatus: Filtered to ${filteredTransactions.length} expense transactions in date range for category $categoryId');

        final spending = filteredTransactions.fold<double>(0.0, (sum, transaction) => sum + transaction.amount);
        developer.log('CalculateBudgetStatus: CALCULATION COMPLETE - Total spending for category $categoryId: \$${spending.toStringAsFixed(2)}');

        return Result.success(spending);
      },
      categoryId: categoryId,
    );
  }

  /// Retry operation with exponential backoff
  Future<Result<double>> _retryWithBackoff({
    required Future<Result<double>> Function() operation,
    required String categoryId,
  }) async {
    Duration delay = _initialRetryDelay;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        developer.log('CalculateBudgetStatus: Attempt $attempt/$_maxRetries for category $categoryId');
        final result = await operation();

        if (result.isSuccess) {
          developer.log('CalculateBudgetStatus: SUCCESS on attempt $attempt for category $categoryId');
          return result;
        }

        // If we get here, it's a non-retryable error
        developer.log('CalculateBudgetStatus: NON-RETRYABLE ERROR on attempt $attempt for category $categoryId');
        return result;

      } catch (e) {
        if (e is RetryableException) {
          if (attempt == _maxRetries) {
            developer.log('CalculateBudgetStatus: MAX RETRIES EXCEEDED for category $categoryId, returning error');
            return Result.error(e.failure);
          }

          developer.log('CalculateBudgetStatus: RETRYABLE EXCEPTION on attempt $attempt for category $categoryId, waiting ${delay.inMilliseconds}ms before retry');
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * _retryBackoffMultiplier).round());
        } else {
          // Non-retryable exception
          developer.log('CalculateBudgetStatus: NON-RETRYABLE EXCEPTION on attempt $attempt for category $categoryId: $e');
          return Result.error(Failure.unknown('Failed to get category spending: $e'));
        }
      }
    }

    // This should never be reached, but just in case
    return Result.error(Failure.unknown('Unexpected retry failure for category $categoryId'));
  }

  /// Check if an error is retryable (network/connection issues)
  bool _isRetryableError(Failure failure) {
    if (failure is NetworkFailure) {
      return true;
    }

    final message = failure.message.toLowerCase();
    return message.contains('connection') ||
            message.contains('network') ||
            message.contains('timeout') ||
            message.contains('socket') ||
            message.contains('http') ||
            message.contains('unreachable') ||
            message.contains('dns') ||
            message.contains('server error') ||
            message.contains('service unavailable') ||
            message.contains('temporary failure') ||
            message.contains('rate limit');
  }

  /// Determine budget health based on spending percentage
  BudgetHealth _getBudgetHealth(double percentage) {
    if (percentage > 100) return BudgetHealth.overBudget;
    if (percentage > 90) return BudgetHealth.critical;
    if (percentage > 75) return BudgetHealth.warning;
    return BudgetHealth.healthy;
  }

  /// Calculate rollover-adjusted spending for budgets with rollover enabled
  double _calculateRolloverAdjustedSpending(double totalSpent, double totalBudget, Budget budget) {
    // If rollover is enabled and budget period has ended, calculate rollover amount
    final now = DateTime.now();
    if (now.isAfter(budget.endDate)) {
      // Calculate how much was under-spent in the previous period
      final underSpent = totalBudget - totalSpent;
      if (underSpent > 0) {
        // Add rollover amount to current spending calculation
        // This effectively reduces the "spent" amount for health calculations
        // since rollover funds are available
        return (totalSpent - underSpent).clamp(0.0, double.infinity);
      }
    }
    return totalSpent;
  }
}