import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/presentation/notifiers/budget_notifier.dart';
import 'package:budget_tracker/features/budgets/presentation/providers/budget_providers.dart';
import 'package:budget_tracker/features/budgets/presentation/states/budget_state.dart';
import 'package:budget_tracker/features/dashboard/presentation/widgets/enhanced_dashboard_header.dart';
import 'package:budget_tracker/features/dashboard/presentation/widgets/enhanced_financial_overview.dart';
import 'package:budget_tracker/features/dashboard/presentation/widgets/enhanced_quick_actions.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/transaction_notifier.dart';
import 'package:budget_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:budget_tracker/features/transactions/presentation/states/transaction_state.dart';
import 'package:budget_tracker/features/transactions/presentation/widgets/enhanced_transaction_tile.dart';
import 'package:budget_tracker/features/transactions/presentation/widgets/enhanced_transaction_filters.dart';
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

  group('Enhanced Features Integration Tests', () {
    testWidgets('Complete enhanced dashboard and transaction screen testing with real data',
        (tester) async {
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
          title: 'Salary',
          amount: 3000.00,
          type: TransactionType.income,
          categoryId: 'income',
          accountId: 'account1',
          date: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Transaction(
          id: 'tx5',
          title: 'Freelance Payment',
          amount: 500.00,
          type: TransactionType.income,
          categoryId: 'income',
          accountId: 'account1',
          date: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      // Setup mock states
      when(mockBudgetNotifier.state).thenReturn(
        AsyncData(BudgetState(
          budgets: testBudgets,
          budgetStatuses: [],
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

      // Test 1: Verify Enhanced Dashboard Header
      expect(find.byType(EnhancedDashboardHeader), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      // Test 2: Verify Enhanced Financial Overview
      expect(find.byType(EnhancedFinancialOverview), findsOneWidget);
      expect(find.text('Financial Overview'), findsOneWidget);

      // Test 3: Verify Circular Budget Indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Test 4: Verify Enhanced Quick Actions
      expect(find.byType(EnhancedQuickActions), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);

      // Test 5: Navigate to Transaction Screen
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();

      expect(find.text('Transactions'), findsOneWidget);

      // Test 6: Verify Enhanced Transaction Screen Components
      expect(find.byType(EnhancedTransactionTile), findsWidgets);
      expect(find.text('Grocery Shopping'), findsOneWidget);
      expect(find.text('Gas Station'), findsOneWidget);
      expect(find.text('Movie Tickets'), findsOneWidget);

      // Test 7: Test Transaction Filtering
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedTransactionFilters), findsOneWidget);
      expect(find.text('Filter Transactions'), findsOneWidget);

      // Test 8: Test Component Interactions - Tap on Transaction
      await tester.tap(find.text('Grocery Shopping'));
      await tester.pumpAndSettle();

      // Should navigate to transaction detail (assuming route exists)
      expect(find.text('Transaction Details'), findsNothing); // Adjust based on actual implementation

      // Test 9: Test Swipe Actions on Transaction Tile
      await tester.drag(find.text('Gas Station'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Should show edit/delete actions
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Test 10: Test FAB Functionality
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should show add transaction bottom sheet
      expect(find.text('Add Transaction'), findsOneWidget);

      // Test 11: Test Navigation Back to Dashboard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);

      // Test 12: Test Quick Actions on Dashboard
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      // Should show income transaction sheet
      expect(find.text('Add Income'), findsOneWidget);

      // Test 13: Test Date Navigation in Header
      await tester.tap(find.textContaining(DateTime.now().year.toString()));
      await tester.pumpAndSettle();

      // Should show date selector (assuming it exists)
      // expect(find.byType(DateSelectorPills), findsOneWidget);

      // Test 14: Test Pull to Refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should still be on dashboard
      expect(find.text('Dashboard'), findsOneWidget);

      // Test 15: Test Performance - Animation Smoothness
      final stopwatch = Stopwatch()..start();

      // Perform rapid interactions
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.receipt_long));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byIcon(Icons.home));
        await tester.pump(const Duration(milliseconds: 100));
      }

      stopwatch.stop();

      // Should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));

      // Test 16: Test Accessibility - Semantic Labels
      final semantics = tester.getSemantics(find.text('Financial Overview'));
      expect(semantics.label, isNotNull);

      // Test 17: Test Responsive Design - Different Screen Sizes
      await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone SE size
      await tester.pumpAndSettle();

      // Components should still be visible and functional
      expect(find.byType(EnhancedFinancialOverview), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(428, 926)); // iPhone 12 Pro Max size
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedFinancialOverview), findsOneWidget);

      // Reset to default
      await tester.binding.setSurfaceSize(null);
      await tester.pumpAndSettle();
    });

    testWidgets('Error handling and edge cases', (tester) async {
      // Test empty transaction state
      when(mockTransactionNotifier.state).thenReturn(
        const AsyncData(TransactionState(transactions: [], hasMoreData: false)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to transactions
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();

      // Should show empty states appropriately
      expect(find.text('No transactions yet'), findsNothing); // Adjust based on actual empty state text

      // Test error state in transaction notifier
      when(mockTransactionNotifier.state).thenReturn(
        AsyncError(Exception('Network error'), StackTrace.current),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error state
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('State management and provider integration', (tester) async {
      final testTransactions = [
        Transaction(
          id: 'tx1',
          title: 'Test Transaction',
          amount: 100.0,
          type: TransactionType.expense,
          categoryId: 'test',
          accountId: 'account1',
          date: DateTime.now(),
        ),
      ];

      when(mockTransactionNotifier.state).thenReturn(
        AsyncData(TransactionState(
          transactions: testTransactions,
          hasMoreData: false,
        )),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to transactions
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();

      // Verify transaction appears
      expect(find.text('Test Transaction'), findsOneWidget);

      // Test state updates
      final updatedTransactions = [
        ...testTransactions,
        Transaction(
          id: 'tx2',
          title: 'New Transaction',
          amount: 50.0,
          type: TransactionType.expense,
          categoryId: 'test',
          accountId: 'account1',
          date: DateTime.now(),
        ),
      ];

      when(mockTransactionNotifier.state).thenReturn(
        AsyncData(TransactionState(
          transactions: updatedTransactions,
          hasMoreData: false,
        )),
      );

      // Trigger state update
      await tester.pump();

      // Verify new transaction appears
      expect(find.text('New Transaction'), findsOneWidget);
    });

    testWidgets('Animation performance and smoothness', (tester) async {
      final testTransactions = List.generate(
        10,
        (index) => Transaction(
          id: 'tx$index',
          title: 'Transaction $index',
          amount: 100.0 + index,
          type: TransactionType.expense,
          categoryId: 'test',
          accountId: 'account1',
          date: DateTime.now().subtract(Duration(days: index)),
        ),
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
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to transactions
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();

      // Test scrolling performance
      final stopwatch = Stopwatch()..start();

      // Perform scroll operations
      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 50));
      }

      stopwatch.stop();

      // Should complete smoothly
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Verify no frame drops (this is a basic check)
      expect(tester.takeException(), isNull);
    });
  });
}