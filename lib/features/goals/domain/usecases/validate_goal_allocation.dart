import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/goal_contribution.dart';
import '../repositories/goal_repository.dart';

/// Use case for validating goal allocations before processing
class ValidateGoalAllocation {
  const ValidateGoalAllocation(this._repository);

  final GoalRepository _repository;

  /// Validate allocations for a transaction
  Future<Result<List<GoalContribution>>> call({
    required double transactionAmount,
    required TransactionType transactionType,
    required List<GoalContribution> allocations,
  }) async {
    try {
      // Only allow allocations for income transactions
      if (transactionType != TransactionType.income) {
        return Result.error(Failure.validation(
          'Goal allocations are only allowed for income transactions',
          {'transactionType': 'Must be income transaction'},
        ));
      }

      // Check for empty allocations (this is allowed)
      if (allocations.isEmpty) {
        return Result.success([]);
      }

      // Validate each allocation
      final validationErrors = <String, String>{};
      final validAllocations = <GoalContribution>[];

      for (final allocation in allocations) {
        final allocationValidation = await _validateSingleAllocation(allocation);
        if (allocationValidation.isError) {
          final failure = allocationValidation.failureOrNull!;
          validationErrors['allocation_${allocations.indexOf(allocation)}'] = failure.message;
        } else {
          validAllocations.add(allocation);
        }
      }

      if (validationErrors.isNotEmpty) {
        return Result.error(Failure.validation(
          'Invalid goal allocations',
          validationErrors,
        ));
      }

      // Check total allocation doesn't exceed transaction amount
      final totalAllocated = validAllocations.fold<double>(
        0,
        (sum, allocation) => sum + allocation.amount,
      );

      if (totalAllocated > transactionAmount) {
        return Result.error(Failure.validation(
          'Total allocated amount (${totalAllocated.toStringAsFixed(2)}) exceeds transaction amount (${transactionAmount.toStringAsFixed(2)})',
          {'totalAllocated': 'Cannot exceed transaction amount'},
        ));
      }

      // Check for duplicate goal allocations
      final goalIds = validAllocations.map((a) => a.goalId).toSet();
      if (goalIds.length != validAllocations.length) {
        return Result.error(Failure.validation(
          'Duplicate goal allocations found',
          {'allocations': 'Each goal can only be allocated once'},
        ));
      }

      return Result.success(validAllocations);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to validate goal allocations: $e'));
    }
  }

  /// Validate a single allocation
  Future<Result<GoalContribution>> _validateSingleAllocation(GoalContribution allocation) async {
    // Basic amount validation
    if (allocation.amount <= 0) {
      return Result.error(Failure.validation(
        'Allocation amount must be greater than zero',
        {'amount': 'Must be positive'},
      ));
    }

    // Check goal exists and is eligible
    final goalResult = await _repository.getById(allocation.goalId);
    if (goalResult.isError) {
      return Result.error(Failure.validation(
        'Goal not found: ${allocation.goalId}',
        {'goalId': 'Goal does not exist'},
      ));
    }

    final goal = goalResult.dataOrNull;
    if (goal == null) {
      return Result.error(Failure.validation(
        'Goal not found: ${allocation.goalId}',
        {'goalId': 'Goal does not exist'},
      ));
    }

    // Check if goal is completed
    if (goal.isCompleted) {
      return Result.error(Failure.validation(
        'Cannot allocate to completed goal: ${goal.title}',
        {'goalId': 'Goal is already completed'},
      ));
    }

    // Check if goal is overdue
    if (goal.isOverdue) {
      return Result.error(Failure.validation(
        'Cannot allocate to overdue goal: ${goal.title}',
        {'goalId': 'Goal deadline has passed'},
      ));
    }

    // Check if allocation exceeds remaining goal amount
    final remaining = goal.targetAmount - goal.currentAmount;
    if (allocation.amount > remaining) {
      return Result.error(Failure.validation(
        'Allocation amount (${allocation.amount.toStringAsFixed(2)}) exceeds remaining goal amount (${remaining.toStringAsFixed(2)}) for ${goal.title}',
        {'amount': 'Exceeds goal remaining amount'},
      ));
    }

    // Validate contribution date
    if (allocation.date.isAfter(DateTime.now())) {
      return Result.error(Failure.validation(
        'Allocation date cannot be in the future',
        {'date': 'Date cannot be in the future'},
      ));
    }

    return Result.success(allocation);
  }
}

// Note: AllocateToGoals class has been moved to allocate_to_goals.dart
// to avoid circular dependencies