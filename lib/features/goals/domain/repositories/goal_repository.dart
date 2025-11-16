import '../../../../core/error/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/goal.dart';
import '../entities/goal_contribution.dart';
import '../entities/goal_progress.dart';

/// Repository interface for goal operations
/// Defines the contract for goal data access
abstract class GoalRepository {
  /// Get all goals
  Future<Result<List<Goal>>> getAll();

  /// Get goal by ID
  Future<Result<Goal?>> getById(String id);

  /// Get active goals (not completed)
  Future<Result<List<Goal>>> getActive();

  /// Get goals by priority
  Future<Result<List<Goal>>> getByPriority(GoalPriority priority);

  /// Get goals by category ID
  Future<Result<List<Goal>>> getByCategoryId(String categoryId);

  /// Add new goal
  Future<Result<Goal>> add(Goal goal);

  /// Update existing goal
  Future<Result<Goal>> update(Goal goal);

  /// Delete goal by ID
  Future<Result<void>> delete(String id);

  /// Get contributions for a specific goal
  Future<Result<List<GoalContribution>>> getContributions(String goalId);

  /// Add contribution to a goal
  Future<Result<Goal>> addContribution(String goalId, GoalContribution contribution);

  /// Delete contribution by ID
  Future<Result<void>> deleteContribution(String contributionId);

  /// Get goal progress for a specific goal
  Future<Result<GoalProgress>> getGoalProgress(String goalId);

  /// Get progress for all goals
  Future<Result<List<GoalProgress>>> getAllGoalProgress();

  /// Search goals by title or description
  Future<Result<List<Goal>>> search(String query);

  /// Get goal count
  Future<Result<int>> getCount();

  /// Get all goals with category names resolved
  Future<Result<List<Goal>>> getAllWithCategories();

  /// Get eligible goals for allocation based on transaction amount and type
  Future<Result<List<Goal>>> getEligibleForAllocation(
    double amount,
    TransactionType transactionType,
  );
}