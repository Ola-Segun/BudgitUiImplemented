import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_contribution.freezed.dart';

/// Goal contribution entity - represents a contribution towards a goal
/// Pure domain entity with no dependencies
@freezed
class GoalContribution with _$GoalContribution {
  const factory GoalContribution({
    required String id,
    required String goalId,
    required double amount,
    required DateTime date,
    String? transactionId, // Link to source transaction
    String? note,
  }) = _GoalContribution;

  const GoalContribution._();

  /// Get formatted amount
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  /// Check if contribution is positive
  bool get isPositive => amount > 0;

  /// Get contribution type based on amount
  String get type => isPositive ? 'Contribution' : 'Withdrawal';
}