import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/goal.dart';
import '../entities/goal_contribution.dart';
import '../repositories/goal_repository.dart';

/// Use case for adding a contribution to a goal
class AddGoalContribution {
  const AddGoalContribution(this._repository);

  final GoalRepository _repository;

  /// Execute the use case
  Future<Result<Goal>> call(GoalContribution contribution) async {
    try {
      // Validate contribution
      final validationResult = _validateContribution(contribution);
      if (validationResult.isError) {
        return Result.error(validationResult.failureOrNull!);
      }

      // Add contribution to goal
      final result = await _repository.addContribution(contribution.goalId, contribution);
      return result;
    } catch (e) {
      return Result.error(Failure.unknown('Failed to add goal contribution: $e'));
    }
  }

  /// Validate contribution data
  Result<void> _validateContribution(GoalContribution contribution) {
    if (contribution.amount <= 0) {
      return Result.error(Failure.validation(
        'Contribution amount must be greater than zero',
        {'amount': 'Must be positive'},
      ));
    }

    if (contribution.goalId.trim().isEmpty) {
      return Result.error(Failure.validation(
        'Goal ID is required',
        {'goalId': 'Goal ID cannot be empty'},
      ));
    }

    if (contribution.date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return Result.error(Failure.validation(
        'Contribution date cannot be in the future',
        {'date': 'Date cannot be in the future'},
      ));
    }

    return Result.success(null);
  }
}