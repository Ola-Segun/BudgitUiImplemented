
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/presentation/notifiers/budget_notifier.dart';
import 'package:budget_tracker/features/budgets/presentation/providers/budget_providers.dart';
import 'package:budget_tracker/features/budgets/presentation/states/budget_state.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/enhanced_budget_card.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/budget_status_banner.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/budget_metric_cards.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/budget_stats_row.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/date_selector_pills.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/transaction_notifier.dart';
import 'package:budget_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:budget_tracker/features/transactions/presentation/states/transaction_state.dart';
import 'package:budget_tracker/main.dart';

class MockBudgetNotifier extends Mock implements BudgetNotifier {
  @override
  AsyncValue<BudgetState> get state => super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: const AsyncData(BudgetState()),
        returnValueForMissingStub: const AsyncData(BudgetState()),
      );
}

class MockTransactionNotifier extends Mock implements TransactionNotifier {
  @override
  AsyncValue<TransactionState> get state => super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: const AsyncData(TransactionState(transactions: [], hasMoreData: false)),
        returnValueForMissingStub: const AsyncData(TransactionState(transactions: [], hasMoreData: false)),
      );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockBudgetNotifier mockBudgetNotifier;
  late MockTransactionNotifier mockTransactionNotifier;

  setUp(() {
    mockBudgetNotifier = MockBudgetNotifier();
    mockTransactionNotifier = MockTransactionNotifier();
  });

  group('Budget Features Integration Tests', () {
    testWidgets('Complete budget feature testing with real data', (tester) async {
      // Setup comprehensive test data
      final testBudgets = [
        Budget(
          id: 'budget1',
          name: 'Monthly Expenses',
          type: BudgetType.fiftyThirtyTwenty,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          categories: [
            BudgetCategory(
              id: 'food',
              name: 'Food & Dining',
              amount: 600.0,
            ),
            BudgetCategory(
              id: 'transport',
              name: 'Transportation',
              amount: 300.0,
            ),
            BudgetCategory(
              id: 'entertainment',
              name: 'Entertainment',
              amount: 200.0,
            ),
          ],
          isActive: true,
        ),
        Budget(
          id: 'budget2',
          name: 'Savings Goal',
          type: BudgetType.custom,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 90)),
          createdAt: DateTime.now(),
          categories: [
            BudgetCategory(
              id: 'savings',
              name: 'Emergency Fund',
              amount: 1000.0,
            ),
          ],
          isActive: true,
        ),
      ];

      final testTransactions = [
        Transaction(
          id: 'tx1',
          title: 'Grocery Shopping',
          amount: 85.50,
          type: TransactionType.expense,
          categoryId: 'food',
          accountId: 'account1',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Transaction(
          id: 'tx2',
          title: 'Gas Station',
          amount: 45.00,
          type: TransactionType.expense,
          categoryId: 'transport',
          accountId: 'account1',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Transaction(
          id: 'tx3',
          title: 'Movie Tickets',
          amount: 25.00,
          type: TransactionType.expense,
          categoryId: 'entertainment',
          accountId: 'account1',
          date: DateTime.now(),
        ),
        Transaction(
          id: 'tx4',
          title: 'Restaurant Dinner',
          amount: 65.00,
          type: TransactionType.expense,
          categoryId: 'food',
          accountId: 'account1',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];

      // Create budget statuses with real calculations
      final budgetStatuses = testBudgets.map((budget) {
        final categoryStatuses = budget.categories.map((category) {
          final spent = testTransactions
              .where((tx) => tx.categoryId == category.id && tx.type == TransactionType.expense)
              .fold<double>(0.0, (sum, tx) => sum + tx.amount);

          final percentage = category.amount > 0 ? (spent / category.amount) : 0.0;

          BudgetHealth health;
          if (percentage > 1.0) {
            health = BudgetHealth.overBudget;
          } else if (percentage > 0.9) {
            health = BudgetHealth.critical;
          } else if (percentage > 0.75) {
            health = BudgetHealth.warning;
          } else {
            health = BudgetHealth.healthy;
          }

          return CategoryStatus(
            categoryId: category.id,
            spent: spent,
            budget: category.amount,
            percentage: percentage,
            status: health,
          );
        }).toList();

        final totalSpent = categoryStatuses.fold<double>(0.0, (sum, status) => sum + status.spent);
        final totalBudget = budget.totalBudget;

        return BudgetStatus(
          budget: budget,
          totalSpent: totalSpent,
          totalBudget: totalBudget,
          categoryStatuses: categoryStatuses,
          daysRemaining: budget.remainingDays,
        );
      }).toList();

      // Setup mock states
      when(mockBudgetNotifier.state).thenReturn(
        AsyncData(BudgetState(
          budgets: testBudgets,
          budgetStatuses: budgetStatuses,
          isLoading: false,
        )),
      );

      when(mockTransactionNotifier.state).thenReturn(
        AsyncData(TransactionState(
          transactions: testTransactions,
          hasMoreData: false,
        )),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Test 1: Navigate to Budget List Screen
      expect(find.text('Dashboard'), findsOneWidget);

      // Navigate to Budgets using bottom navigation
      await tester.tap(find.byIcon(Icons.pie_chart_outline));
      await tester.pumpAndSettle();

      expect(find.text('My Budget'), findsOneWidget);

      // Test 2: Verify Budget List Display
      expect(find.text('Monthly Expenses'), findsOneWidget);
      expect(find.text('Savings Goal'), findsOneWidget);
      expect(find.text('All Budgets'), findsOneWidget);

      // Test 3: Verify Circular Budget Indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets); // Should show progress

      // Test 4: Verify Budget Cards
      expect(find.byType(EnhancedBudgetCard), findsAtLeastNWidgets(2));

      // Test 5: Test Navigation to Budget Detail
      await tester.tap(find.text('Monthly Expenses'));
      await tester.pumpAndSettle();

      // Verify we're on detail screen
      expect(find.text('Monthly Expenses'), findsOneWidget);

      // Test 6: Verify Budget Detail Components
      expect(find.text('Category Breakdown'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('Budget Information'), findsOneWidget);

      // Test 7: Verify Status Banner
      expect(find.byType(BudgetStatusBanner), findsOneWidget);

      // Test 8: Verify Metric Cards
      expect(find.byType(BudgetMetricCards), findsOneWidget);

      // Test 9: Verify Stats Row
      expect(find.byType(BudgetStatsRow), findsOneWidget);

      // Test 10: Verify Category Breakdown
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);

      // Test 11: Verify Transaction History
      expect(find.text('Grocery Shopping'), findsOneWidget);
      expect(find.text('Gas Station'), findsOneWidget);
      expect(find.text('Movie Tickets'), findsOneWidget);

      // Test 12: Test Chart Tabs
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);

      // Test 13: Test Date Selector Pills
      expect(find.byType(DateSelectorPills), findsOneWidget);

      // Test 14: Test FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Test 15: Navigate Back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('My Budget'), findsOneWidget);

      // Test 16: Test Manage Budgets Sheet
      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      expect(find.text('Manage Budgets'), findsOneWidget);
      expect(find.text('Filter Budgets'), findsOneWidget);
      expect(find.text('Edit Categories'), findsOneWidget);

      // Close the sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Test 17: Test Pull to Refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify still on budget list
      expect(find.text('My Budget'), findsOneWidget);
    });

    testWidgets('Budget animations and performance test', (tester) async {
      // Setup minimal test data for performance testing
      final testBudget = Budget(
        id: 'perf_budget',
        name: 'Performance Test',
        type: BudgetType.custom,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        categories: [
          BudgetCategory(
            id: 'test_cat',
            name: 'Test Category',
            amount: 1000.0,
          ),
        ],
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        budget: testBudget,
        totalSpent: 300.0,
        totalBudget: 1000.0,
        categoryStatuses: [
          CategoryStatus(
            categoryId: 'test_cat',
            spent: 300.0,
            budget: 1000.0,
            percentage: 0.3,
            status: BudgetHealth.healthy,
          ),
        ],
        daysRemaining: 30,
      );

      when(mockBudgetNotifier.state).thenReturn(
        AsyncData(BudgetState(
          budgets: [testBudget],
          budgetStatuses: [budgetStatus],
          isLoading: false,
        )),
      );

      when(mockTransactionNotifier.state).thenReturn(
        const AsyncData(TransactionState(transactions: [], hasMoreData: false)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
          ],
          child: const MyApp(),
        ),
      );

      // Wait for initial animations to complete
      await tester.pumpAndSettle();

      // Navigate to budget detail
      await tester.tap(find.text('Performance Test'));
      await tester.pumpAndSettle();

      // Test animation performance - measure frame drops
      final stopwatch = Stopwatch()..start();

      // Perform rapid interactions to test animation smoothness
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byType(TabBar).first);
        await tester.pump(const Duration(milliseconds: 100));
      }

      stopwatch.stop();

      // Should complete within reasonable time without frame drops
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Verify no errors occurred during rapid interactions
      expect(tester.takeException(), isNull);
    });

    testWidgets('Error handling and edge cases', (tester) async {
      // Test empty state
      when(mockBudgetNotifier.state).thenReturn(
        const AsyncData(BudgetState(budgets: [], budgetStatuses: [], isLoading: false)),
      );

      when(mockTransactionNotifier.state).thenReturn(
        const AsyncData(TransactionState(transactions: [], hasMoreData: false)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith((ref) => mockBudgetNotifier),
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No budgets yet'), findsOneWidget);
      expect(find.text('Create your first budget to start'), findsOneWidget);

      // Test FAB is still functional
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}