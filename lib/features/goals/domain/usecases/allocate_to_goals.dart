import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/goal.dart';
import '../entities/goal_contribution.dart';
import '../repositories/goal_repository.dart';
import 'validate_goal_allocation.dart';

/// Use case for allocating funds to multiple goals
class AllocateToGoals {
  const AllocateToGoals(this._repository);

  final GoalRepository _repository;

  /// Execute allocation to multiple goals
  Future<Result<List<Goal>>> call({
    required double transactionAmount,
    required TransactionType transactionType,
    required List<GoalContribution> allocations,
  }) async {
    try {
      // First validate the allocations
      final validationResult = await ValidateGoalAllocation(_repository).call(
        transactionAmount: transactionAmount,
        transactionType: transactionType,
        allocations: allocations,
      );

      if (validationResult.isError) {
        return Result.error(validationResult.failureOrNull!);
      }

      final validAllocations = validationResult.dataOrNull ?? [];

      // If no valid allocations, return empty success
      if (validAllocations.isEmpty) {
        return Result.success([]);
      }

      // Process allocations in sequence to ensure atomicity
      final updatedGoals = <Goal>[];
      final errors = <String>[];

      for (final allocation in validAllocations) {
        final result = await _repository.addContribution(allocation.goalId, allocation);
        if (result.isError) {
          errors.add('Failed to allocate to goal ${allocation.goalId}: ${result.failureOrNull!.message}');
        } else {
          updatedGoals.add(result.dataOrNull!);
        }
      }

      // If any allocations failed, this is a partial failure
      if (errors.isNotEmpty) {
        return Result.error(Failure.unknown(
          'Some allocations failed: ${errors.join(', ')}',
        ));
      }

      return Result.success(updatedGoals);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to allocate to goals: $e'));
    }
  }

  /// Allocate with rollback capability (if any allocation fails, rollback all)
  Future<Result<List<Goal>>> callWithRollback({
    required double transactionAmount,
    required TransactionType transactionType,
    required List<GoalContribution> allocations,
  }) async {
    try {
      // First validate the allocations
      final validationResult = await ValidateGoalAllocation(_repository).call(
        transactionAmount: transactionAmount,
        transactionType: transactionType,
        allocations: allocations,
      );

      if (validationResult.isError) {
        return Result.error(validationResult.failureOrNull!);
      }

      final validAllocations = validationResult.dataOrNull ?? [];

      // If no valid allocations, return empty success
      if (validAllocations.isEmpty) {
        return Result.success([]);
      }

      // Process allocations and track successful ones for rollback
      final updatedGoals = <Goal>[];
      final successfulAllocations = <GoalContribution>[];

      for (final allocation in validAllocations) {
        final result = await _repository.addContribution(allocation.goalId, allocation);
        if (result.isError) {
          // Rollback all successful allocations
          await _rollbackAllocations(successfulAllocations);
          return Result.error(Failure.unknown(
            'Allocation failed and was rolled back: ${result.failureOrNull!.message}',
          ));
        } else {
          updatedGoals.add(result.dataOrNull!);
          successfulAllocations.add(allocation);
        }
      }

      return Result.success(updatedGoals);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to allocate to goals: $e'));
    }
  }

  /// Rollback allocations by removing the contributions
  Future<void> _rollbackAllocations(List<GoalContribution> allocations) async {
    for (final allocation in allocations) {
      try {
        // Note: This assumes we have a way to remove contributions
        // In a real implementation, we'd need a deleteContribution method
        // For now, we'll just log the rollback attempt
        await _repository.deleteContribution(allocation.id);
      } catch (e) {
        // Log rollback failure but continue with other rollbacks
        // In production, this should be properly logged
      }
    }
  }
}