import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_tracker/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:budget_tracker/features/accounts/domain/entities/account.dart';
import 'package:budget_tracker/features/accounts/presentation/providers/account_providers.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';

void main() {
  group('AccountDetailScreen', () {
    testWidgets('displays loading state initially', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays account not found when account is null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Account not found'), findsOneWidget);
    });

    testWidgets('displays account details correctly', (WidgetTester tester) async {
      // Arrange
      final mockAccount = Account(
        id: 'test-account-id',
        name: 'Test Checking Account',
        type: AccountType.checking,
        currentBalance: 2500.50,
        currency: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTransactions = <Transaction>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockAccount),
            ),
            accountTransactionsProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockTransactions),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Checking Account'), findsOneWidget);
      expect(find.text('Checking'), findsOneWidget);
      expect(find.text('\$2,500.50'), findsOneWidget);
    });

    testWidgets('displays account balance visualization', (WidgetTester tester) async {
      // Arrange
      final mockAccount = Account(
        id: 'test-account-id',
        name: 'Test Account',
        type: AccountType.savings,
        currentBalance: 5000.00,
        currency: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTransactions = <Transaction>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockAccount),
            ),
            accountTransactionsProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockTransactions),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Balance visualization section'), findsOneWidget);
    });

    testWidgets('displays quick actions', (WidgetTester tester) async {
      // Arrange
      final mockAccount = Account(
        id: 'test-account-id',
        name: 'Test Account',
        type: AccountType.checking,
        currentBalance: 1000.00,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTransactions = <Transaction>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockAccount),
            ),
            accountTransactionsProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockTransactions),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Quick actions section'), findsOneWidget);
      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Transfer Money'), findsOneWidget);
      expect(find.text('View Statement'), findsOneWidget);
    });

    testWidgets('displays account information section', (WidgetTester tester) async {
      // Arrange
      final mockAccount = Account(
        id: 'test-account-id',
        name: 'Test Account',
        type: AccountType.checking,
        currentBalance: 1000.00,
        currency: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTransactions = <Transaction>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockAccount),
            ),
            accountTransactionsProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockTransactions),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Account information section'), findsOneWidget);
    });

    testWidgets('displays transaction history section', (WidgetTester tester) async {
      // Arrange
      final mockAccount = Account(
        id: 'test-account-id',
        name: 'Test Account',
        type: AccountType.checking,
        currentBalance: 1000.00,
        currency: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTransactions = <Transaction>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockAccount),
            ),
            accountTransactionsProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockTransactions),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Transaction history section'), findsOneWidget);
    });

    testWidgets('shows popup menu with edit and delete options', (WidgetTester tester) async {
      // Arrange
      final mockAccount = Account(
        id: 'test-account-id',
        name: 'Test Account',
        type: AccountType.checking,
        currentBalance: 1000.00,
        currency: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTransactions = <Transaction>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockAccount),
            ),
            accountTransactionsProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockTransactions),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the popup menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit Account'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('refresh indicator works on pull to refresh', (WidgetTester tester) async {
      // Arrange
      final mockAccount = Account(
        id: 'test-account-id',
        name: 'Test Account',
        type: AccountType.checking,
        currentBalance: 1000.00,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTransactions = <Transaction>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockAccount),
            ),
            accountTransactionsProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockTransactions),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Perform pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();

      // Assert - Should still render properly
      expect(find.text('Test Account'), findsOneWidget);
    });

    testWidgets('accessibility features are properly implemented', (WidgetTester tester) async {
      // Arrange
      final mockAccount = Account(
        id: 'test-account-id',
        name: 'Test Account',
        type: AccountType.checking,
        currentBalance: 1000.00,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTransactions = <Transaction>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockAccount),
            ),
            accountTransactionsProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockTransactions),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.bySemanticsLabel('Account details for Test Account'), findsOneWidget);
      expect(find.bySemanticsLabel('Scroll to view account information, balance, and transactions'), findsOneWidget);
    });

    testWidgets('animations work properly', (WidgetTester tester) async {
      // Arrange
      final mockAccount = Account(
        id: 'test-account-id',
        name: 'Test Account',
        type: AccountType.checking,
        currentBalance: 1000.00,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTransactions = <Transaction>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockAccount),
            ),
            accountTransactionsProvider('test-account-id').overrideWith(
              (ref) => Stream.value(mockTransactions),
            ),
          ],
          child: const MaterialApp(
            home: AccountDetailScreen(accountId: 'test-account-id'),
          ),
        ),
      );

      // Initial state
      await tester.pump();

      // After animation completes
      await tester.pumpAndSettle();

      // Assert - Screen should be fully rendered
      expect(find.text('Test Account'), findsOneWidget);
    });
  });
}