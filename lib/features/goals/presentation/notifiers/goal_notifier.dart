import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_contribution.dart';
import '../../domain/usecases/add_goal_contribution.dart';
import '../../domain/usecases/create_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/get_goals.dart';
import '../../domain/usecases/update_goal.dart';
import '../states/goal_state.dart';

/// State notifier for goal management
class GoalNotifier extends StateNotifier<AsyncValue<GoalState>> {
  final GetGoals _getGoals;
  final GetActiveGoals _getActiveGoals;
  final GetCompletedGoals _getCompletedGoals;
  final GetGoalById _getGoalById;
  final CreateGoal _createGoal;
  final UpdateGoal _updateGoal;
  final DeleteGoal _deleteGoal;
  final AddGoalContribution _addGoalContribution;

  GoalNotifier({
    required GetGoals getGoals,
    required GetActiveGoals getActiveGoals,
    required GetCompletedGoals getCompletedGoals,
    required GetGoalById getGoalById,
    required CreateGoal createGoal,
    required UpdateGoal updateGoal,
    required DeleteGoal deleteGoal,
    required AddGoalContribution addGoalContribution,
  })  : _getGoals = getGoals,
        _getActiveGoals = getActiveGoals,
        _getCompletedGoals = getCompletedGoals,
        _getGoalById = getGoalById,
        _createGoal = createGoal,
        _updateGoal = updateGoal,
        _deleteGoal = deleteGoal,
        _addGoalContribution = addGoalContribution,
        super(const AsyncValue.loading()) {
    loadGoals();
  }

  /// Load all goals
  Future<void> loadGoals() async {
    state = const AsyncValue.loading();

    final result = await _getGoals();

    result.when(
      success: (goals) {
        state = AsyncValue.data(GoalState(goals: goals));
      },
      error: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
    );
  }

  /// Load active goals
  Future<void> loadActiveGoals() async {
    final result = await _getActiveGoals();

    result.when(
      success: (goals) {
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncValue.data(currentState.copyWith(goals: goals));
        }
      },
      error: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
    );
  }

  /// Get goal by ID
  Future<void> loadGoalById(String id) async {
    final result = await _getGoalById(id);

    result.when(
      success: (goal) {
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncValue.data(currentState.copyWith(selectedGoal: goal));
        }
      },
      error: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
    );
  }

  /// Add a new goal
  Future<bool> addGoal(Goal goal) async {
    debugPrint('GoalNotifier: Adding goal ${goal.title}');
    final currentState = state.value;
    if (currentState == null) return false;

    // Set loading state
    state = AsyncValue.data(currentState.copyWith(isLoading: true));
    debugPrint('GoalNotifier: Set loading state, goals count: ${currentState.goals.length}');

    final result = await _createGoal(goal);

    return result.when(
      success: (createdGoal) {
        // Update with server response
        final updatedGoals = [createdGoal, ...currentState.goals];
        state = AsyncValue.data(currentState.copyWith(
          goals: updatedGoals,
          isLoading: false,
        ));
        debugPrint('GoalNotifier: Goal added successfully, new goals count: ${updatedGoals.length}');
        return true;
      },
      error: (failure) {
        // Revert to original state with error
        state = AsyncValue.data(currentState.copyWith(
          isLoading: false,
          error: failure.message,
        ));
        debugPrint('GoalNotifier: Failed to add goal: ${failure.message}');
        return false;
      },
    );
  }

  /// Update an existing goal
  Future<bool> updateGoal(Goal goal) async {
    debugPrint('🔍 GoalNotifier: updateGoal called with goal: ${goal.title ?? "null"}');
    debugPrint('🔍 GoalNotifier: goal is null: ${goal == null}');
    debugPrint('🔍 GoalNotifier: goal.id: ${goal.id}');
    debugPrint('🔍 GoalNotifier: goal.title: ${goal.title}');

    final currentState = state.value;
    debugPrint('🔍 GoalNotifier: currentState is null: ${currentState == null}');
    if (currentState == null) {
      debugPrint('🔍 GoalNotifier: ERROR - currentState is null!');
      return false;
    }
    debugPrint('🔍 GoalNotifier: currentState.goals length: ${currentState.goals.length}');

    final result = await _updateGoal(goal);
    debugPrint('🔍 GoalNotifier: _updateGoal result: ${result.runtimeType}');

    return result.when(
      success: (updatedGoal) {
        debugPrint('🔍 GoalNotifier: updateGoal success - updatedGoal: ${updatedGoal.title ?? "null"}');
        debugPrint('🔍 GoalNotifier: updatedGoal is null: ${updatedGoal == null}');
        final updatedGoals = currentState.goals.map((g) {
          debugPrint('🔍 GoalNotifier: Checking goal ${g.id} against ${goal.id}');
          return g.id == goal.id ? updatedGoal : g;
        }).toList();
        debugPrint('🔍 GoalNotifier: updatedGoals length: ${updatedGoals.length}');
        state = AsyncValue.data(currentState.copyWith(goals: updatedGoals));
        debugPrint('🔍 GoalNotifier: State updated successfully');
        return true;
      },
      error: (failure) {
        debugPrint('🔍 GoalNotifier: updateGoal error: ${failure.message ?? "null"}');
        debugPrint('🔍 GoalNotifier: failure is null: ${failure == null}');
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }

  /// Delete a goal
  Future<bool> deleteGoal(String goalId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _deleteGoal(goalId);

    return result.when(
      success: (_) {
        final updatedGoals = currentState.goals
            .where((g) => g.id != goalId)
            .toList();
        state = AsyncValue.data(currentState.copyWith(goals: updatedGoals));
        return true;
      },
      error: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }

  /// Add contribution to a goal
  Future<bool> addContribution(String goalId, GoalContribution contribution) async {
    final currentState = state.value;
    if (currentState == null) return false;

    // Ensure the contribution has the correct goal ID
    final contributionWithId = contribution.copyWith(goalId: goalId);
    final result = await _addGoalContribution(contributionWithId);

    return result.when(
      success: (updatedGoal) {
        final updatedGoals = currentState.goals.map((g) {
          return g.id == goalId ? updatedGoal : g;
        }).toList();
        state = AsyncValue.data(currentState.copyWith(goals: updatedGoals));
        return true;
      },
      error: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }

  /// Search goals
  void searchGoals(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: query));
  }

  /// Apply filter
  void applyFilter(GoalFilter filter) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(filter: filter));
  }

  /// Clear filter
  void clearFilter() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(filter: null));
  }

  /// Clear search
  void clearSearch() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: null));
  }

  /// Select a goal
  void selectGoal(Goal? goal) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(selectedGoal: goal));
  }

  /// Toggle between showing active goals only and all goals
  void toggleShowAllGoals() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(
      showAllGoals: !currentState.showAllGoals,
    ));
  }

  /// Set show all goals mode
  void setShowAllGoals(bool showAll) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(showAllGoals: showAll));
  }

  /// Clear error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(error: null));
  }
}