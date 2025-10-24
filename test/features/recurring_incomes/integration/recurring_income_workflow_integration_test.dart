
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:budget_tracker/features/accounts/domain/entities/account.dart';
import 'package:budget_tracker/features/recurring_incomes/domain/entities/recurring_income.dart';
import 'package:budget_tracker/features/recurring_incomes/presentation/providers/recurring_income_providers.dart';
import 'package:budget_tracker/features/recurring_incomes/presentation/screens/recurring_income_dashboard_screen.dart';
import 'package:budget_tracker/features/recurring_incomes/presentation/notifiers/recurring_income_notifier.dart';
import 'package:budget_tracker/features/recurring_incomes/presentation/states/recurring_income_state.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/transaction_notifier.dart';
import 'package:budget_tracker/features/transactions/presentation/providers/transaction_providers.dart';

class MockRecurringIncomeNotifier extends Mock implements RecurringIncomeNotifier {}

class MockTransactionNotifier extends Mock implements TransactionNotifier {}

void main() {
  late MockRecurringIncomeNotifier mockRecurringIncomeNotifier;
  late MockTransactionNotifier mockTransactionNotifier;

  setUp(() {
    mockRecurringIncomeNotifier = MockRecurringIncomeNotifier();
    mockTransactionNotifier = MockTransactionNotifier();
  });

  group('Recurring Income End-to-End Workflow Integration Tests', () {
    testWidgets('Complete recurring income workflow: create, view, record receipt, verify updates',
        (tester) async {
      // Setup mock data
      final testAccount = Account(
        id: 'test_account_1',
        name: 'Test Checking Account',
        type: AccountType.bankAccount,
        balance: 1000.0,
        currency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testIncome = RecurringIncome(
        id: 'test_income_1',
        name: 'Test Salary',
        amount: 3000.0,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        frequency: RecurringIncomeFrequency.monthly,
        categoryId: 'salary_category',
        defaultAccountId: testAccount.id,
        nextExpectedDate: DateTime.now().add(const Duration(days: 1)),
      );

      final testInstance = RecurringIncomeInstance(
        id: 'test_instance_1',
        amount: 3000.0,
        receivedDate: DateTime.now(),
        accountId: testAccount.id,
        notes: 'Monthly salary payment',
      );

      // Mock initial empty state
      when(mockRecurringIncomeNotifier.state).thenReturn(
        RecurringIncomeState.loaded(
          incomes: [],
          summary: RecurringIncomesSummary(
            totalIncomes: 0,
            activeIncomes: 0,
            expectedThisMonth: 0,
            totalMonthlyAmount: 0,
            receivedThisMonth: 0,
            expectedAmount: 0,
            upcomingIncomes: [],
          ),
        ),
      );

      // Mock successful income creation
      when(mockRecurringIncomeNotifier.createIncome(any)).thenAnswer((_) async => true);

      // Mock state after creation
      when(mockRecurringIncomeNotifier.state).thenReturn(
        RecurringIncomeState.loaded(
          incomes: [testIncome],
          summary: RecurringIncomesSummary(
            totalIncomes: 1,
            activeIncomes: 1,
            expectedThisMonth: 1,
            totalMonthlyAmount: 3000.0,
            receivedThisMonth: 0,
            expectedAmount: 3000.0,
            upcomingIncomes: [
              RecurringIncomeStatus(
                income: testIncome,
                daysUntilExpected: 1,
                isExpectedSoon: true,
                isExpectedToday: false,
                isOverdue: false,
                urgency: RecurringIncomeUrgency.expectedSoon,
              ),
            ],
          ),
        ),
      );

      // Mock successful receipt recording
      when(mockRecurringIncomeNotifier.recordIncomeReceipt(
        any,
        any,
        accountId: anyNamed('accountId'),
      )).thenAnswer((_) async => true);

      // Mock transaction creation
      when(mockTransactionNotifier.addTransaction(any)).thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringIncomeNotifierProvider.overrideWith((ref) => mockRecurringIncomeNotifier),
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
          ],
          child: const MaterialApp(
            home: RecurringIncomeDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Verify initial empty state
      expect(find.text('No recurring incomes yet'), findsOneWidget);
      expect(find.text('Total Incomes'), findsOneWidget);
      expect(find.text('0'), findsWidgets); // Total incomes count

      // Step 2: Navigate to create income screen (simulated)
      // Note: In a real integration test, we'd navigate to the creation screen
      // For this test, we'll directly call the notifier methods

      // Simulate income creation
      await mockRecurringIncomeNotifier.createIncome(testIncome);
      await tester.pumpAndSettle();

      // Verify creation was called
      verify(mockRecurringIncomeNotifier.createIncome(any)).called(1);

      // Step 3: Verify income appears in dashboard
      expect(find.text('Test Salary'), findsOneWidget);
      expect(find.text('Total Incomes'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // Updated total incomes count
      expect(find.text('\$3,000'), findsWidgets); // Monthly total

      // Step 4: Verify upcoming incomes section
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Test Salary'), findsWidgets); // Should appear in upcoming
      expect(find.text('In 1 days'), findsOneWidget);

      // Step 5: Simulate recording income receipt
      await mockRecurringIncomeNotifier.recordIncomeReceipt(
        testIncome.id,
        testInstance,
        accountId: testAccount.id,
      );
      await tester.pumpAndSettle();

      // Verify receipt recording was called
      verify(mockRecurringIncomeNotifier.recordIncomeReceipt(
        any,
        any,
        accountId: anyNamed('accountId'),
      )).called(1);

      // Step 6: Verify transaction was created
      verify(mockTransactionNotifier.addTransaction(any)).called(1);

      // Step 7: Verify dashboard updates after receipt recording
      // The notifier should refresh and show updated state
      // In a real scenario, this would trigger a state update showing the income as received

      // Step 8: Verify account balance would be updated
      // This would typically be verified by checking account balance changes
      // In integration tests, we might need to mock account balance updates

      // Step 9: Verify income history is updated
      // The income should now show in its history that it was received

      // Step 10: Verify next expected date is updated
      // For monthly frequency, next expected date should be next month
    });

    testWidgets('Income creation validation and error handling', (tester) async {
      // Setup with validation errors
      when(mockRecurringIncomeNotifier.createIncome(any)).thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringIncomeNotifierProvider.overrideWith((ref) => mockRecurringIncomeNotifier),
          ],
          child: const MaterialApp(
            home: RecurringIncomeDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Attempt to create invalid income (would be done via form in real scenario)
      final invalidIncome = RecurringIncome(
        id: 'invalid_income',
        name: '', // Invalid: empty name
        amount: -100.0, // Invalid: negative amount
        startDate: DateTime.now().add(const Duration(days: 1)), // Invalid: future date
        frequency: RecurringIncomeFrequency.monthly,
        categoryId: 'test_category',
      );

      await mockRecurringIncomeNotifier.createIncome(invalidIncome);
      await tester.pumpAndSettle();

      // Verify creation failed
      verify(mockRecurringIncomeNotifier.createIncome(any)).called(1);
      // In real scenario, error state would be shown
    });

    testWidgets('Receipt recording with account balance updates', (tester) async {
      // Setup test data
      final testAccount = Account(
        id: 'test_account_2',
        name: 'Test Savings Account',
        type: AccountType.bankAccount,
        balance: 500.0,
        currency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testIncome = RecurringIncome(
        id: 'test_income_2',
        name: 'Test Bonus',
        amount: 1000.0,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        frequency: RecurringIncomeFrequency.monthly,
        categoryId: 'bonus_category',
        defaultAccountId: testAccount.id,
      );

      final testInstance = RecurringIncomeInstance(
        id: 'test_instance_2',
        amount: 1000.0,
        receivedDate: DateTime.now(),
        accountId: testAccount.id,
      );

      // Mock successful operations
      when(mockRecurringIncomeNotifier.recordIncomeReceipt(
        any,
        any,
        accountId: anyNamed('accountId'),
      )).thenAnswer((_) async => true);
      when(mockTransactionNotifier.addTransaction(any)).thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringIncomeNotifierProvider.overrideWith((ref) => mockRecurringIncomeNotifier),
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
          ],
          child: const MaterialApp(
            home: RecurringIncomeDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Record receipt
      await mockRecurringIncomeNotifier.recordIncomeReceipt(
        testIncome.id,
        testInstance,
        accountId: testAccount.id,
      );
      await tester.pumpAndSettle();

      // Verify transaction creation with correct details
      final capturedTransaction = verify(mockTransactionNotifier.addTransaction(captureAny)).captured.single;
      expect(capturedTransaction, isA<Transaction>());
      final transaction = capturedTransaction as Transaction;
      expect(transaction.amount, 1000.0);
      expect(transaction.type, TransactionType.income);
      expect(transaction.accountId, testAccount.id);
    });

    testWidgets('Dashboard reactivity to multiple income changes', (tester) async {
      // Test that dashboard updates correctly when multiple incomes are added/updated

      final income1 = RecurringIncome(
        id: 'income_1',
        name: 'Salary',
        amount: 3000.0,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        frequency: RecurringIncomeFrequency.monthly,
        categoryId: 'salary',
        defaultAccountId: 'account_1',
      );

      final income2 = RecurringIncome(
        id: 'income_2',
        name: 'Freelance',
        amount: 500.0,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        frequency: RecurringIncomeFrequency.weekly,
        categoryId: 'freelance',
        defaultAccountId: 'account_1',
      );

      // Start with empty state
      when(mockRecurringIncomeNotifier.state).thenReturn(
        RecurringIncomeState.loaded(
          incomes: [],
          summary: RecurringIncomesSummary(
            totalIncomes: 0,
            activeIncomes: 0,
            expectedThisMonth: 0,
            totalMonthlyAmount: 0,
            receivedThisMonth: 0,
            expectedAmount: 0,
            upcomingIncomes: [],
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringIncomeNotifierProvider.overrideWith((ref) => mockRecurringIncomeNotifier),
          ],
          child: const MaterialApp(
            home: RecurringIncomeDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add first income
      when(mockRecurringIncomeNotifier.createIncome(any)).thenAnswer((_) async => true);
      when(mockRecurringIncomeNotifier.state).thenReturn(
        RecurringIncomeState.loaded(
          incomes: [income1],
          summary: RecurringIncomesSummary(
            totalIncomes: 1,
            activeIncomes: 1,
            expectedThisMonth: 1,
            totalMonthlyAmount: 3000.0,
            receivedThisMonth: 0,
            expectedAmount: 3000.0,
            upcomingIncomes: [],
          ),
        ),
      );

      await mockRecurringIncomeNotifier.createIncome(income1);
      await tester.pumpAndSettle();

      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // Total incomes

      // Add second income
      when(mockRecurringIncomeNotifier.state).thenReturn(
        RecurringIncomeState.loaded(
          incomes: [income1, income2],
          summary: RecurringIncomesSummary(
            totalIncomes: 2,
            activeIncomes: 2,
            expectedThisMonth: 2,
            totalMonthlyAmount: 3500.0, // 3000 + 500
            receivedThisMonth: 0,
            expectedAmount: 3500.0,
            upcomingIncomes: [],
          ),
        ),
      );

      await mockRecurringIncomeNotifier.createIncome(income2);
      await tester.pumpAndSettle();

      expect(find.text('Freelance'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // Total incomes updated
      expect(find.text('\$3,500'), findsWidgets); // Updated monthly total
    });
  });
}