import 'package:hive/hive.dart';

import '../../domain/entities/goal.dart';

part 'goal_dto.g.dart';

/// Data Transfer Object for Goal entity
/// Used for Hive storage - never expose domain entities directly to storage
@HiveType(typeId: 4)
class GoalDto extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late double targetAmount;

  @HiveField(4)
  late double currentAmount;

  @HiveField(5)
  late DateTime deadline;

  @HiveField(6)
  late String priority; // Store as string for Hive compatibility

  @HiveField(7)
  late String categoryId; // Store as string for Hive compatibility

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;

  @HiveField(10)
  List<String>? tags;

  @HiveField(11)
  List<String>? contributionIds;

  /// Default constructor
  GoalDto();

  /// Named constructor for creating from domain entity
  GoalDto.fromDomain(Goal goal) {
    id = goal.id;
    title = goal.title;
    description = goal.description;
    targetAmount = goal.targetAmount;
    currentAmount = goal.currentAmount;
    deadline = goal.deadline;
    priority = goal.priority.name; // Convert enum to string
    categoryId = goal.categoryId; // Store category ID directly
    createdAt = goal.createdAt;
    updatedAt = goal.updatedAt;
    tags = goal.tags;
    contributionIds = goal.contributions.map((c) => c.id).toList();
  }

  /// Convert to domain entity
  Goal toDomain() {
    return Goal(
      id: id,
      title: title,
      description: description,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      priority: GoalPriority.values.firstWhere(
        (e) => e.name == priority,
        orElse: () => GoalPriority.medium, // Default fallback
      ),
      categoryId: categoryId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags ?? [],
      contributions: [], // Will be populated by repository
    );
  }
}