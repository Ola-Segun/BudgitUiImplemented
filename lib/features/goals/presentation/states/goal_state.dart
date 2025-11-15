import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_contribution.dart';
import '../../domain/entities/goal_progress.dart';

part 'goal_state.freezed.dart';

/// State for goal management
@freezed
class GoalState with _$GoalState {
  const factory GoalState({
    @Default([]) List<Goal> goals,
    @Default([]) List<GoalProgress> goalProgress,
    @Default([]) List<GoalContribution> contributions,
    @Default(false) bool isLoading,
    String? error,
    String? searchQuery,
    GoalFilter? filter,
    Goal? selectedGoal,
    @Default(false) bool showAllGoals,
  }) = _GoalState;

  const GoalState._();

  /// Get filtered goals based on search query and filter
  List<Goal> get filteredGoals {
    // First, filter by view mode (active only vs all goals)
    var filtered = showAllGoals ? goals : activeGoals;

    // Apply search filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered.where((goal) {
        return goal.title.toLowerCase().contains(query) ||
               goal.description.toLowerCase().contains(query) ||
               goal.categoryId.toLowerCase().contains(query);
      }).toList();
    }

    // Apply goal filter
    if (filter != null) {
      filtered = filtered.where((goal) {
        // Filter by priority
        if (filter!.priority != null && goal.priority != filter!.priority) {
          return false;
        }

        // Filter by category
        if (filter!.category != null && goal.categoryId != filter!.category) {
          return false;
        }

        // Filter by completion status
        if (filter!.showCompleted != null) {
          final isCompleted = goal.isCompleted;
          if (filter!.showCompleted! && !isCompleted) return false;
          if (!filter!.showCompleted! && isCompleted) return false;
        }

        // Filter by deadline range
        if (filter!.deadlineStart != null &&
            goal.deadline.isBefore(filter!.deadlineStart!)) {
          return false;
        }
        if (filter!.deadlineEnd != null &&
            goal.deadline.isAfter(filter!.deadlineEnd!)) {
          return false;
        }

        return true;
      }).toList();
    }

    return filtered;
  }

  /// Get active goals (not completed)
  List<Goal> get activeGoals => goals.where((goal) => !goal.isCompleted).toList();

  /// Get completed goals
  List<Goal> get completedGoals => goals.where((goal) => goal.isCompleted).toList();

  /// Get goals grouped by priority
  Map<GoalPriority, List<Goal>> get goalsByPriority {
    final grouped = <GoalPriority, List<Goal>>{};

    for (final goal in filteredGoals) {
      grouped[goal.priority] ??= [];
      grouped[goal.priority]!.add(goal);
    }

    return grouped;
  }

  /// Get goals grouped by category
  Map<String, List<Goal>> get goalsByCategory {
    final grouped = <String, List<Goal>>{};

    for (final goal in filteredGoals) {
      grouped[goal.categoryId] ??= [];
      grouped[goal.categoryId]!.add(goal);
    }

    return grouped;
  }

  /// Get total target amount across all goals
  double get totalTargetAmount => goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);

  /// Get total current amount across all goals
  double get totalCurrentAmount => goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);

  /// Get overall progress percentage
  double get overallProgressPercentage {
    if (totalTargetAmount <= 0) return 0.0;
    return (totalCurrentAmount / totalTargetAmount).clamp(0.0, 1.0);
  }

  /// Get aggregated goal representing all goals combined
  Goal? get aggregatedGoal {
    if (goals.isEmpty) return null;

    // Find earliest creation date and latest deadline
    final earliestCreated = goals.map((g) => g.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
    final latestDeadline = goals.map((g) => g.deadline).reduce((a, b) => a.isAfter(b) ? a : b);

    // Sum all targets and current amounts
    final totalTarget = totalTargetAmount;
    final totalCurrent = totalCurrentAmount;

    // Determine priority based on highest priority goal
    final highestPriority = goals.map((g) => g.priority).reduce((a, b) => a.value > b.value ? a : b);

    // Use a generic category or the most common one
    final categoryCounts = <String, int>{};
    for (final goal in goals) {
      categoryCounts[goal.categoryId] = (categoryCounts[goal.categoryId] ?? 0) + 1;
    }
    final mostCommonCategory = categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Goal(
      id: 'aggregated_goals',
      title: 'All Goals Combined',
      description: 'Aggregated view of all your financial goals',
      targetAmount: totalTarget,
      currentAmount: totalCurrent,
      deadline: latestDeadline,
      priority: highestPriority,
      categoryId: mostCommonCategory,
      createdAt: earliestCreated,
      updatedAt: DateTime.now(),
      tags: [],
    );
  }

  /// Get goals sorted by priority and progress
  List<Goal> get prioritizedGoals {
    final sorted = List<Goal>.from(filteredGoals);
    sorted.sort((a, b) {
      // First sort by priority (high first)
      final priorityCompare = b.priority.value.compareTo(a.priority.value);
      if (priorityCompare != 0) return priorityCompare;

      // Then by progress percentage (lower first - needs more attention)
      return a.progressPercentage.compareTo(b.progressPercentage);
    });
    return sorted;
  }
}

/// Filter for goals
@freezed
class GoalFilter with _$GoalFilter {
  const factory GoalFilter({
    GoalPriority? priority,
    String? category,
    bool? showCompleted,
    DateTime? deadlineStart,
    DateTime? deadlineEnd,
  }) = _GoalFilter;

  const GoalFilter._();

  /// Check if filter is empty (no filters applied)
  bool get isEmpty =>
      priority == null &&
      category == null &&
      showCompleted == null &&
      deadlineStart == null &&
      deadlineEnd == null;

  /// Check if filter has any active filters
  bool get isNotEmpty => !isEmpty;
}

/// Statistics for goals
@freezed
class GoalStats with _$GoalStats {
  const factory GoalStats({
    @Default(0) int totalGoals,
    @Default(0) int activeGoals,
    @Default(0) int completedGoals,
    @Default(0.0) double totalTargetAmount,
    @Default(0.0) double totalCurrentAmount,
    @Default(0.0) double overallProgress,
    @Default(0) int highPriorityGoals,
    @Default(0) int overdueGoals,
  }) = _GoalStats;

  const GoalStats._();

  /// Get completion rate
  double get completionRate => totalGoals > 0
      ? (completedGoals / totalGoals).clamp(0.0, 1.0)
      : 0.0;

  /// Get average progress per goal
  double get averageProgress => totalGoals > 0
      ? overallProgress / totalGoals
      : 0.0;

  /// Check if user has overdue goals
  bool get hasOverdueGoals => overdueGoals > 0;
}