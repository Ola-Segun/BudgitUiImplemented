import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_category_repository.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_contribution.dart';
import '../../domain/entities/goal_progress.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_hive_datasource.dart';

/// Implementation of GoalRepository using Hive data source
class GoalRepositoryImpl implements GoalRepository {
  const GoalRepositoryImpl(this._dataSource, this._transactionCategoryRepository);

  final GoalHiveDataSource _dataSource;
  final TransactionCategoryRepository _transactionCategoryRepository;

  @override
  Future<Result<List<Goal>>> getAll() => _dataSource.getAll();

  @override
  Future<Result<Goal?>> getById(String id) => _dataSource.getById(id);

  @override
  Future<Result<List<Goal>>> getActive() => _dataSource.getActive();

  @override
  Future<Result<List<Goal>>> getByPriority(GoalPriority priority) =>
      _dataSource.getByPriority(priority);

  @override
  Future<Result<List<Goal>>> getByCategoryId(String categoryId) =>
      _dataSource.getByCategoryId(categoryId);

  @override
  Future<Result<Goal>> add(Goal goal) => _dataSource.add(goal);

  @override
  Future<Result<Goal>> update(Goal goal) => _dataSource.update(goal);

  @override
  Future<Result<void>> delete(String id) => _dataSource.delete(id);

  @override
  Future<Result<List<GoalContribution>>> getContributions(String goalId) =>
      _dataSource.getContributions(goalId);

  @override
  Future<Result<Goal>> addContribution(String goalId, GoalContribution contribution) =>
      _dataSource.addContribution(goalId, contribution);

  @override
  Future<Result<void>> deleteContribution(String contributionId) =>
      _dataSource.deleteContribution(contributionId);

  @override
  Future<Result<GoalProgress>> getGoalProgress(String goalId) =>
      _dataSource.getGoalProgress(goalId);

  @override
  Future<Result<List<GoalProgress>>> getAllGoalProgress() =>
      _dataSource.getAllGoalProgress();

  @override
  Future<Result<List<Goal>>> search(String query) => _dataSource.search(query);

  @override
  Future<Result<int>> getCount() => _dataSource.getCount();

  @override
  Future<Result<List<Goal>>> getAllWithCategories() async {
    final goalsResult = await getAll();
    if (goalsResult.isError) {
      return goalsResult;
    }

    final goals = goalsResult.dataOrNull ?? [];
    final goalsWithCategories = <Goal>[];

    for (final goal in goals) {
      final categoryName = await _getCategoryName(goal.categoryId);
      // For now, we can't modify the Goal entity to include categoryName
      // So we return the goals as-is. Category name resolution should be done in presentation layer
      // using the _getCategoryName method or similar approach
      goalsWithCategories.add(goal);
    }

    return Result.success(goalsWithCategories);
  }

  /// Get category name by ID using repository lookup
  Future<String> _getCategoryName(String categoryId) async {
    final result = await _transactionCategoryRepository.getById(categoryId);

    return result.when(
      success: (category) => category?.name ?? categoryId,
      error: (failure) {
        // Log error and return category ID as fallback
        debugPrint('Failed to get category name for $categoryId: $failure');
        return categoryId;
      },
    );
  }

  @override
  Future<Result<List<Goal>>> getEligibleForAllocation(
    double amount,
    TransactionType transactionType,
  ) async {
    try {
      // Get all active goals
      final activeGoals = await _dataSource.getActive();

      return activeGoals.when(
        success: (goals) {
          // Filter based on transaction type and other criteria
          final eligible = goals.where((goal) {
            // Only show for income transactions
            if (transactionType != TransactionType.income) {
              return false;
            }

            // Don't show completed goals
            if (goal.isCompleted) {
              return false;
            }

            // Don't show if goal needs less than $1
            if (goal.remainingAmount < 1) {
              return false;
            }

            return true;
          }).toList();

          // Sort by priority and progress
          eligible.sort((a, b) {
            // High priority first
            final priorityCompare = _comparePriority(a.priority, b.priority);
            if (priorityCompare != 0) return priorityCompare;

            // Then by closest to completion
            return b.percentageComplete.compareTo(a.percentageComplete);
          });

          return Result.success(eligible);
        },
        error: (failure) => Result.error(failure),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Failed to get eligible goals: $e'),
      );
    }
  }

  int _comparePriority(GoalPriority? a, GoalPriority? b) {
    const priorities = {
      GoalPriority.high: 3,
      GoalPriority.medium: 2,
      GoalPriority.low: 1,
      null: 0,
    };

    return priorities[b]!.compareTo(priorities[a]!);
  }
}