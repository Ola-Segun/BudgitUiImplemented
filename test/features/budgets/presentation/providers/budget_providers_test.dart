import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_setup.dart';
import 'package:budget_tracker/core/error/failures.dart';
import 'package:budget_tracker/core/error/result.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/domain/usecases/calculate_budget_status.dart';
import 'package:budget_tracker/features/budgets/domain/usecases/create_budget.dart';
import 'package:budget_tracker/features/budgets/domain/usecases/delete_budget.dart';
import 'package:budget_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:budget_tracker/features/budgets/domain/usecases/update_budget.dart';
import 'package:budget_tracker/features/budgets/presentation/providers/budget_providers.dart';
import 'package:budget_tracker/features/budgets/presentation/states/budget_state.dart';

class MockGetBudgets extends Mock implements GetBudgets {}
class MockGetActiveBudgets extends Mock implements GetActiveBudgets {}
class MockCreateBudget extends Mock implements CreateBudget {}
class MockUpdateBudget extends Mock implements UpdateBudget {}
class MockDeleteBudget extends Mock implements DeleteBudget {}
class MockCalculateBudgetStatus extends Mock implements CalculateBudgetStatus {}

void main() {
  late ProviderContainer container;
  late MockGetBudgets mockGetBudgets;
  late MockGetActiveBudgets mockGetActiveBudgets;
  late MockCreateBudget mockCreateBudget;
  late MockUpdateBudget mockUpdateBudget;
  late MockDeleteBudget mockDeleteBudget;
  late MockCalculateBudgetStatus mockCalculateBudgetStatus;

  setUp(() {
    setupMockitoDummies();

    mockGetBudgets = MockGetBudgets();
    mockGetActiveBudgets = MockGetActiveBudgets();
    mockCreateBudget = MockCreateBudget();
    mockUpdateBudget = MockUpdateBudget();
    mockDeleteBudget = MockDeleteBudget();
    mockCalculateBudgetStatus = MockCalculateBudgetStatus();

    container = ProviderContainer(
      overrides: [
        getBudgetsProvider.overrideWithValue(mockGetBudgets),
        getActiveBudgetsProvider.overrideWithValue(mockGetActiveBudgets),
        createBudgetProvider.overrideWithValue(mockCreateBudget),
        updateBudgetProvider.overrideWithValue(mockUpdateBudget),
        deleteBudgetProvider.overrideWithValue(mockDeleteBudget),
        calculateBudgetStatusProvider.overrideWithValue(mockCalculateBudgetStatus),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('BudgetNotifierProvider', () {
    test('should initialize with loading state', () {
      final notifier = container.read(budgetNotifierProvider.notifier);
      expect(notifier.state, isA<AsyncLoading>());
    });

    test('should load budgets successfully', () async {
      final budgets = [
        Budget(
          id: '1',
          name: 'Test Budget',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [
            BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0),
          ],
          isActive: true,
        ),
      ];

      when(mockGetBudgets()).thenAnswer((_) async => Result.success(budgets));
      when(mockCalculateBudgetStatus(budgets.first)).thenAnswer((_) async => Result.success(
        BudgetStatus(
          budget: budgets.first,
          totalSpent: 200.0,
          totalBudget: 500.0,
          categoryStatuses: [],
          daysRemaining: 20,
        ),
      ));

      final notifier = container.read(budgetNotifierProvider.notifier);
      await notifier.loadBudgets();

      expect(notifier.state.value?.budgets, budgets);
      expect(notifier.state.value?.budgetStatuses.length, 1);
    });

    test('should handle budget loading error', () async {
      when(mockGetBudgets()).thenAnswer((_) async => Result.error(Failure.validation('Load failed', {})));

      final notifier = container.read(budgetNotifierProvider.notifier);
      await notifier.loadBudgets();

      expect(notifier.state, isA<AsyncError>());
    });

    test('should create budget successfully', () async {
      final budget = Budget(
        id: '1',
        name: 'New Budget',
        type: BudgetType.custom,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
        isActive: true,
      );

      when(mockCreateBudget(budget)).thenAnswer((_) async => Result.success(budget));

      final notifier = container.read(budgetNotifierProvider.notifier);
      // Set initial state
      notifier.state = AsyncValue.data(BudgetState(budgets: []));

      final result = await notifier.createBudget(budget);

      expect(result, true);
      expect(notifier.state.value?.budgets.length, 1);
      expect(notifier.state.value?.budgets.first, budget);
    });

    test('should handle create budget error', () async {
      final budget = Budget(
        id: '1',
        name: 'New Budget',
        type: BudgetType.custom,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
        isActive: true,
      );

      when(mockCreateBudget(budget)).thenAnswer((_) async => Result.error(Failure.validation('Create failed', {})));

      final notifier = container.read(budgetNotifierProvider.notifier);
      notifier.state = AsyncValue.data(BudgetState(budgets: []));

      final result = await notifier.createBudget(budget);

      expect(result, false);
      expect(notifier.state.value?.error, 'Create failed');
    });

    test('should update budget successfully', () async {
      final originalBudget = Budget(
        id: '1',
        name: 'Original Budget',
        type: BudgetType.custom,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
        isActive: true,
      );

      final updatedBudget = originalBudget.copyWith(name: 'Updated Budget');

      when(mockUpdateBudget(updatedBudget)).thenAnswer((_) async => Result.success(updatedBudget));

      final notifier = container.read(budgetNotifierProvider.notifier);
      notifier.state = AsyncValue.data(BudgetState(budgets: [originalBudget]));

      final result = await notifier.updateBudget(updatedBudget);

      expect(result, true);
      expect(notifier.state.value?.budgets.first.name, 'Updated Budget');
    });

    test('should delete budget successfully', () async {
      final budget = Budget(
        id: '1',
        name: 'Test Budget',
        type: BudgetType.custom,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
        isActive: true,
      );

      when(mockDeleteBudget('1')).thenAnswer((_) async => Result.success(null));

      final notifier = container.read(budgetNotifierProvider.notifier);
      notifier.state = AsyncValue.data(BudgetState(budgets: [budget]));

      final result = await notifier.deleteBudget('1');

      expect(result, true);
      expect(notifier.state.value?.budgets, isEmpty);
    });

    test('should search budgets correctly', () {
      final budgets = [
        Budget(
          id: '1',
          name: 'Food Budget',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
          isActive: true,
        ),
        Budget(
          id: '2',
          name: 'Transport Budget',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [BudgetCategory(id: 'cat2', name: 'Transport', amount: 300.0)],
          isActive: true,
        ),
      ];

      final notifier = container.read(budgetNotifierProvider.notifier);
      notifier.state = AsyncValue.data(BudgetState(budgets: budgets));

      notifier.searchBudgets('food');

      expect(notifier.state.value?.filteredBudgets.length, 1);
      expect(notifier.state.value?.filteredBudgets.first.name, 'Food Budget');
    });

    test('should apply filter correctly', () {
      final budgets = [
        Budget(
          id: '1',
          name: 'Active Budget',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
          isActive: true,
        ),
        Budget(
          id: '2',
          name: 'Inactive Budget',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [BudgetCategory(id: 'cat2', name: 'Transport', amount: 300.0)],
          isActive: false,
        ),
      ];

      final notifier = container.read(budgetNotifierProvider.notifier);
      notifier.state = AsyncValue.data(BudgetState(budgets: budgets));

      notifier.applyFilter(BudgetFilter(isActive: true));

      expect(notifier.state.value?.filteredBudgets.length, 1);
      expect(notifier.state.value?.filteredBudgets.first.isActive, true);
    });

    test('should select budget correctly', () {
      final budget = Budget(
        id: '1',
        name: 'Test Budget',
        type: BudgetType.custom,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
        isActive: true,
      );

      final notifier = container.read(budgetNotifierProvider.notifier);
      notifier.state = AsyncValue.data(BudgetState(budgets: [budget]));

      notifier.selectBudget(budget);

      expect(notifier.state.value?.selectedBudget, budget);
    });
  });

  group('Budget Providers', () {
    test('filteredBudgetsProvider should return filtered budgets', () {
      final budgets = [
        Budget(
          id: '1',
          name: 'Test Budget',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
          isActive: true,
        ),
      ];

      container.read(budgetNotifierProvider.notifier).state = AsyncValue.data(BudgetState(budgets: budgets));

      final filteredBudgets = container.read(filteredBudgetsProvider);

      expect(filteredBudgets.value, budgets);
    });

    test('activeBudgetsProvider should return only active budgets', () {
      final budgets = [
        Budget(
          id: '1',
          name: 'Active Budget',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
          isActive: true,
        ),
        Budget(
          id: '2',
          name: 'Inactive Budget',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [BudgetCategory(id: 'cat2', name: 'Transport', amount: 300.0)],
          isActive: false,
        ),
      ];

      container.read(budgetNotifierProvider.notifier).state = AsyncValue.data(BudgetState(budgets: budgets));

      final activeBudgets = container.read(activeBudgetsProvider);

      expect(activeBudgets.value?.length, 1);
      expect(activeBudgets.value?.first.isActive, true);
    });

    test('budgetStatsProvider should calculate statistics correctly', () {
      final budgets = [
        Budget(
          id: '1',
          name: 'Budget 1',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
          isActive: true,
        ),
        Budget(
          id: '2',
          name: 'Budget 2',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [BudgetCategory(id: 'cat2', name: 'Transport', amount: 300.0)],
          isActive: true,
        ),
      ];

      final budgetStatuses = [
        BudgetStatus(
          budget: budgets[0],
          totalSpent: 200.0,
          totalBudget: 500.0,
          categoryStatuses: [],
          daysRemaining: 20,
        ),
        BudgetStatus(
          budget: budgets[1],
          totalSpent: 150.0,
          totalBudget: 300.0,
          categoryStatuses: [],
          daysRemaining: 20,
        ),
      ];

      container.read(budgetNotifierProvider.notifier).state = AsyncValue.data(BudgetState(
        budgets: budgets,
        budgetStatuses: budgetStatuses,
      ));

      final stats = container.read(budgetStatsProvider);

      expect(stats.value?.totalBudgets, 2);
      expect(stats.value?.activeBudgets, 2);
      expect(stats.value?.totalBudgetAmount, 800.0);
      expect(stats.value?.totalActiveCosts, 350.0);
    });

    test('budgetProvider should return budget by ID', () {
      final budget = Budget(
        id: '1',
        name: 'Test Budget',
        type: BudgetType.custom,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        categories: [BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0)],
        isActive: true,
      );

      container.read(budgetNotifierProvider.notifier).state = AsyncValue.data(BudgetState(budgets: [budget]));

      final result = container.read(budgetProvider('1'));

      expect(result.value, budget);
    });

    test('budgetProvider should return null for non-existent budget', () {
      container.read(budgetNotifierProvider.notifier).state = AsyncValue.data(BudgetState(budgets: []));

      final result = container.read(budgetProvider('non-existent'));

      expect(result.value, null);
    });
  });

  group('BudgetStats', () {
    test('should calculate percentages correctly', () {
      const stats = BudgetStats(
        totalBudgets: 10,
        activeBudgets: 5,
        totalBudgetAmount: 1000.0,
        activeBudgetAmount: 500.0,
        totalActiveCosts: 300.0,
        healthyBudgets: 3,
        warningBudgets: 1,
        criticalBudgets: 1,
        overBudgetCount: 0,
      );

      expect(stats.healthyPercentage, 60.0);
      expect(stats.warningPercentage, 20.0);
      expect(stats.criticalPercentage, 20.0);
      expect(stats.overBudgetPercentage, 0.0);
      expect(stats.activeCostsPercentage, 60.0);
    });

    test('should handle zero active budgets', () {
      const stats = BudgetStats(
        totalBudgets: 10,
        activeBudgets: 0,
        totalBudgetAmount: 1000.0,
        activeBudgetAmount: 0.0,
        totalActiveCosts: 0.0,
        healthyBudgets: 0,
        warningBudgets: 0,
        criticalBudgets: 0,
        overBudgetCount: 0,
      );

      expect(stats.healthyPercentage, 0.0);
      expect(stats.warningPercentage, 0.0);
      expect(stats.criticalPercentage, 0.0);
      expect(stats.overBudgetPercentage, 0.0);
      expect(stats.activeCostsPercentage, 0.0);
    });
  });
}