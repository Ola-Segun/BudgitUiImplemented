import 'package:hive/hive.dart';

import '../../domain/entities/goal_contribution.dart';

part 'goal_contribution_dto.g.dart';

/// Data Transfer Object for GoalContribution entity
/// Used for Hive storage - never expose domain entities directly to storage
@HiveType(typeId: 5)
class GoalContributionDto extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String goalId;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  String? transactionId;

  @HiveField(5)
  String? note;

  /// Default constructor
  GoalContributionDto();

  /// Named constructor for creating from domain entity
  GoalContributionDto.fromDomain(GoalContribution contribution) {
    id = contribution.id;
    goalId = contribution.goalId;
    amount = contribution.amount;
    date = contribution.date;
    transactionId = contribution.transactionId;
    note = contribution.note;
  }

  /// Convert to domain entity
  GoalContribution toDomain() {
    return GoalContribution(
      id: id,
      goalId: goalId,
      amount: amount,
      date: date,
      transactionId: transactionId,
      note: note,
    );
  }
}