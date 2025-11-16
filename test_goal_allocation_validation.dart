import 'package:flutter_test/flutter_test.dart';

import 'lib/core/error/failures.dart';
import 'lib/core/error/result.dart';
import 'lib/features/goals/domain/entities/goal.dart';
import 'lib/features/goals/domain/entities/goal_contribution.dart';
import 'lib/features/goals/domain/entities/goal_progress.dart';
import 'lib/features/goals/domain/repositories/goal_repository.dart';
import 'lib/features/goals/domain/usecases/validate_goal_allocation.dart';
import 'lib/features/transactions/domain/entities/transaction.dart';

// Mock repository for testing
class MockGoalRepository implements GoalRepository {
  final List<Goal> mockGoals;

  MockGoalRepository(this.mockGoals);

  @override
  Future<Result<List<Goal>>> getAll() async => Result.success(mockGoals);

  @override
  Future<Result<Goal?>> getById(String id) async {
    final goal = mockGoals.where((g) => g.id == id).firstOrNull;
    return Result.success(goal);
  }

  @override
  Future<Result<Goal>> add(Goal goal) async => Result.success(goal);

  @override
  Future<Result<Goal>> update(Goal goal) async => Result.success(goal);

  @override
  Future<Result<void>> delete(String id) async => Result.success(null);

  @override
  Future<Result<List<GoalContribution>>> getContributions(String goalId) async =>
      Result.success([]);

  @override
  Future<Result<Goal>> addContribution(String goalId, GoalContribution contribution) async {
    final goal = mockGoals.where((g) => g.id == goalId).firstOrNull;
    if (goal == null) return Result.error(Failure.notFound('Goal not found'));

    final updatedGoal = goal.copyWith(currentAmount: goal.currentAmount + contribution.amount);
    return Result.success(updatedGoal);
  }

  @override
  Future<Result<void>> deleteContribution(String contributionId) async =>
      Result.success(null);

  @override
  Future<Result<GoalProgress>> getGoalProgress(String goalId) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<GoalProgress>>> getAllGoalProgress() async =>
      throw UnimplementedError();

  @override
  Future<Result<List<Goal>>> search(String query) async =>
      throw UnimplementedError();

  @override
  Future<Result<int>> getCount() async =>
      throw UnimplementedError();

  @override
  Future<Result<List<Goal>>> getAllWithCategories() async =>
      throw UnimplementedError();

  @override
  Future<Result<List<Goal>>> getActive() async =>
      Result.success(mockGoals.where((g) => !g.isCompleted).toList());

  @override
  Future<Result<List<Goal>>> getByPriority(GoalPriority priority) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<Goal>>> getByCategoryId(String categoryId) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<Goal>>> getEligibleForAllocation(double amount, TransactionType transactionType) async =>
      throw UnimplementedError();
}

void main() {
  late ValidateGoalAllocation validateGoalAllocation;
  late MockGoalRepository mockRepository;

  setUp(() {
    final mockGoals = [
      Goal(
        id: 'goal1',
        title: 'Emergency Fund',
        description: 'Emergency savings',
        targetAmount: 1000.0,
        currentAmount: 200.0,
        deadline: DateTime.now().add(const Duration(days: 365)),
        priority: GoalPriority.high,
        categoryId: 'savings',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: [],
      ),
      Goal(
        id: 'goal2',
        title: 'Vacation',
        description: 'Trip to Europe',
        targetAmount: 2000.0,
        currentAmount: 1500.0,
        deadline: DateTime.now().add(const Duration(days: 180)),
        priority: GoalPriority.medium,
        categoryId: 'travel',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: [],
      ),
      Goal(
        id: 'goal3',
        title: 'Overdue Goal',
        description: 'Old goal',
        targetAmount: 500.0,
        currentAmount: 100.0,
        deadline: DateTime.now().subtract(const Duration(days: 30)),
        priority: GoalPriority.low,
        categoryId: 'other',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: [],
      ),
    ];

    mockRepository = MockGoalRepository(mockGoals);
    validateGoalAllocation = ValidateGoalAllocation(mockRepository);
  });

  group('ValidateGoalAllocation', () {
    test('should validate successful allocations', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'goal1',
          amount: 100.0,
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isSuccess, true);
      expect(result.dataOrNull, isNotNull);
      expect(result.dataOrNull!.length, 1);
    });

    test('should reject allocations for expense transactions', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'goal1',
          amount: 100.0,
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.expense,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('only allowed for income'));
    });

    test('should reject over-allocation beyond transaction amount', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'goal1',
          amount: 300.0,
          date: DateTime.now(),
        ),
        GoalContribution(
          id: 'alloc2',
          goalId: 'goal2',
          amount: 300.0,
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('exceeds transaction amount'));
    });

    test('should reject allocation to non-existent goal', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'nonexistent',
          amount: 100.0,
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('Invalid goal allocations'));
    });

    test('should reject allocation to completed goal', () async {
      final completedGoal = Goal(
        id: 'completed',
        title: 'Completed Goal',
        description: 'Already done',
        targetAmount: 1000.0,
        currentAmount: 1000.0,
        deadline: DateTime.now().add(const Duration(days: 365)),
        priority: GoalPriority.medium,
        categoryId: 'savings',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: [],
      );

      mockRepository.mockGoals.add(completedGoal);

      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'completed',
          amount: 100.0,
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('Invalid goal allocations'));
    });

    test('should reject allocation to overdue goal', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'goal3', // This is the overdue goal
          amount: 100.0,
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('Invalid goal allocations'));
    });

    test('should reject allocation exceeding goal remaining amount', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'goal1', // Has 800 remaining (1000-200)
          amount: 900.0, // Exceeds remaining
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 1000.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('Invalid goal allocations'));
    });

    test('should reject zero amount allocations', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'goal1',
          amount: 0.0,
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('Invalid goal allocations'));
    });

    test('should reject negative amount allocations', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'goal1',
          amount: -50.0,
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('Invalid goal allocations'));
    });

    test('should reject duplicate goal allocations', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'goal1',
          amount: 50.0,
          date: DateTime.now(),
        ),
        GoalContribution(
          id: 'alloc2',
          goalId: 'goal1', // Duplicate
          amount: 50.0,
          date: DateTime.now(),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('Duplicate goal allocations found'));
    });

    test('should reject future dated allocations', () async {
      final allocations = [
        GoalContribution(
          id: 'alloc1',
          goalId: 'goal1',
          amount: 100.0,
          date: DateTime.now().add(const Duration(days: 1)),
        ),
      ];

      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: allocations,
      );

      expect(result.isError, true);
      expect(result.failureOrNull!.message, contains('Invalid goal allocations'));
    });

    test('should allow empty allocations list', () async {
      final result = await validateGoalAllocation.call(
        transactionAmount: 500.0,
        transactionType: TransactionType.income,
        allocations: [],
      );

      expect(result.isSuccess, true);
      expect(result.dataOrNull, isEmpty);
    });
  });
}