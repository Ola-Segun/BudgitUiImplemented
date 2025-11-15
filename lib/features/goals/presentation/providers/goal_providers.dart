import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/states/category_state.dart';
import '../../../../core/di/providers.dart' as core_providers;
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/usecases/create_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/get_goals.dart';
import '../../domain/usecases/update_goal.dart';
import '../notifiers/goal_notifier.dart';
import '../states/goal_state.dart';

/// Provider for goal categories (dynamic from transaction categories)
final goalCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final categoryRepository = ref.watch(core_providers.transactionCategoryRepositoryProvider);
  final result = await categoryRepository.getAll();

  return result.when(
    success: (categories) => categories.map((category) => category.id).toList(),
    error: (failure) => [], // Return empty list on error
  );
});

/// Provider for goal categories with full category objects (for dynamic display)
final goalCategoriesWithDetailsProvider = FutureProvider<List<TransactionCategory>>((ref) async {
  final categoryRepository = ref.watch(core_providers.transactionCategoryRepositoryProvider);
  final result = await categoryRepository.getAll();

  return result.when(
    success: (categories) => categories,
    error: (failure) => [], // Return empty list on error
  );
});

/// Provider for category name by ID (for dynamic display in widgets) - memoized
final categoryNameProvider = FutureProvider.family<String, String>((ref, categoryId) async {
  // First try to get from the notifier cache for immediate response
  final categoryNotifier = ref.watch(categoryNotifierProvider.notifier);
  final cachedCategory = categoryNotifier.getCategoryById(categoryId);
  if (cachedCategory != null) {
    return cachedCategory.name;
  }

  // Fallback to repository if not in cache
  final categoryRepository = ref.watch(core_providers.transactionCategoryRepositoryProvider);
  final result = await categoryRepository.getById(categoryId);

  return result.when(
    success: (category) => category?.name ?? categoryId,
    error: (failure) => categoryId, // Return categoryId as fallback
  );
});

/// Provider for GetGoals use case
final getGoalsProvider = Provider<GetGoals>((ref) {
  return ref.read(core_providers.getGoalsProvider);
});

/// Provider for GetActiveGoals use case
final getActiveGoalsProvider = Provider<GetActiveGoals>((ref) {
  return ref.read(core_providers.getActiveGoalsProvider);
});

/// Provider for GetCompletedGoals use case
final getCompletedGoalsProvider = Provider<GetCompletedGoals>((ref) {
  return ref.read(core_providers.getCompletedGoalsProvider);
});

/// Provider for GetGoalById use case
final getGoalByIdProvider = Provider<GetGoalById>((ref) {
  return ref.read(core_providers.getGoalByIdProvider);
});

/// Provider for CreateGoal use case
final createGoalProvider = Provider<CreateGoal>((ref) {
  return ref.read(core_providers.createGoalProvider);
});

/// Provider for UpdateGoal use case
final updateGoalProvider = Provider<UpdateGoal>((ref) {
  return ref.read(core_providers.updateGoalProvider);
});

/// Provider for DeleteGoal use case
final deleteGoalProvider = Provider<DeleteGoal>((ref) {
  return ref.read(core_providers.deleteGoalProvider);
});

/// Provider for AddGoalContribution use case
final addGoalContributionProvider = Provider<AddGoalContribution>((ref) {
  return ref.read(core_providers.addGoalContributionProvider);
});

/// State notifier provider for goal state management
final goalNotifierProvider =
    StateNotifierProvider<GoalNotifier, AsyncValue<GoalState>>((ref) {
  final getGoals = ref.watch(getGoalsProvider);
  final getActiveGoals = ref.watch(getActiveGoalsProvider);
  final getCompletedGoals = ref.watch(getCompletedGoalsProvider);
  final getGoalById = ref.watch(getGoalByIdProvider);
  final createGoal = ref.watch(createGoalProvider);
  final updateGoal = ref.watch(updateGoalProvider);
  final deleteGoal = ref.watch(deleteGoalProvider);
  final addGoalContribution = ref.watch(addGoalContributionProvider);

  final notifier = GoalNotifier(
    getGoals: getGoals,
    getActiveGoals: getActiveGoals,
    getCompletedGoals: getCompletedGoals,
    getGoalById: getGoalById,
    createGoal: createGoal,
    updateGoal: updateGoal,
    deleteGoal: deleteGoal,
    addGoalContribution: addGoalContribution,
  );

  // Listen to category changes and refresh goals only when necessary
  ref.listen<AsyncValue<CategoryState>>(
    categoryNotifierProvider,
    (previous, next) {
      // Only refresh if categories were actually modified (not just operation state changes)
      final prevCategories = previous?.value?.categories ?? [];
      final nextCategories = next.value?.categories ?? [];

      // Check if categories actually changed (not just operation state)
      if (prevCategories.length != nextCategories.length ||
          !prevCategories.every((cat) => nextCategories.any((c) => c.id == cat.id && c.name == cat.name))) {
        notifier.loadGoals();
      }
    },
    fireImmediately: false,
  );

  return notifier;
});

/// Provider for filtered goals
final filteredGoalsProvider = Provider<AsyncValue<List<Goal>>>((ref) {
  final goalState = ref.watch(goalNotifierProvider);

  return goalState.when(
    data: (state) {
      return AsyncValue.data(state.filteredGoals);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for active goals
final activeGoalsProvider = Provider<AsyncValue<List<Goal>>>((ref) {
  final goalState = ref.watch(goalNotifierProvider);

  return goalState.when(
    data: (state) {
      return AsyncValue.data(state.activeGoals);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for completed goals
final completedGoalsProvider = Provider<AsyncValue<List<Goal>>>((ref) {
  final goalState = ref.watch(goalNotifierProvider);

  return goalState.when(
    data: (state) {
      return AsyncValue.data(state.completedGoals);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for goal statistics
final goalStatsProvider = Provider<AsyncValue<GoalStats>>((ref) {
  final goalState = ref.watch(goalNotifierProvider);

  return goalState.when(
    data: (state) {
      final goals = state.goals;

      final totalGoals = goals.length;
      final activeGoals = state.activeGoals.length;
      final completedGoals = state.completedGoals.length;
      final totalTargetAmount = state.totalTargetAmount;
      final totalCurrentAmount = state.totalCurrentAmount;
      final overallProgress = state.overallProgressPercentage;
      final highPriorityGoals = goals.where((g) => g.priority == GoalPriority.high).length;
      final overdueGoals = goals.where((g) => g.isOverdue).length;

      final stats = GoalStats(
        totalGoals: totalGoals,
        activeGoals: activeGoals,
        completedGoals: completedGoals,
        totalTargetAmount: totalTargetAmount,
        totalCurrentAmount: totalCurrentAmount,
        overallProgress: overallProgress,
        highPriorityGoals: highPriorityGoals,
        overdueGoals: overdueGoals,
      );

      return AsyncValue.data(stats);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for selected goal
final selectedGoalProvider = Provider<AsyncValue<Goal?>>((ref) {
  final goalState = ref.watch(goalNotifierProvider);

  return goalState.when(
    data: (state) => AsyncValue.data(state.selectedGoal),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for individual goal by ID
final goalProvider = FutureProvider.family<Goal?, String>((ref, goalId) async {
  final getGoalById = ref.watch(getGoalByIdProvider);
  final result = await getGoalById(goalId);

  return result.when(
    success: (goal) => goal,
    error: (failure) => throw Exception(failure.message),
  );
});

/// Provider for goal contributions by goal ID
final goalContributionsProvider = FutureProvider.family<List<dynamic>, String>((ref, goalId) async {
  final goalRepository = ref.watch(goalRepositoryProvider);
  final result = await goalRepository.getContributions(goalId);

  return result.when(
    success: (contributions) => contributions,
    error: (failure) => throw Exception(failure.message),
  );
});

/// Provider for goal repository (needed for contributions)
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return ref.read(core_providers.goalRepositoryProvider);
});

/// Provider for aggregated goal
final aggregatedGoalProvider = Provider<AsyncValue<Goal?>>((ref) {
  final goalState = ref.watch(goalNotifierProvider);

  return goalState.when(
    data: (state) => AsyncValue.data(state.aggregatedGoal),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});