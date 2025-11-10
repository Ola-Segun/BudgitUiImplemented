import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_setup.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../domain/entities/split_transaction.dart';
import '../../domain/entities/transaction.dart';
import '../../presentation/notifiers/category_notifier.dart';
import '../../presentation/notifiers/transaction_notifier.dart';
import '../../presentation/providers/transaction_providers.dart';
import '../../presentation/widgets/split_transaction_bottom_sheet.dart';

class MockTransactionNotifier extends Mock implements TransactionNotifier {}

class MockCategoryNotifier extends Mock implements CategoryNotifier {}

void main() {
  late MockTransactionNotifier mockTransactionNotifier;
  late MockCategoryNotifier mockCategoryNotifier;

  setUp(() async {
    await TestSetup.init();
    mockTransactionNotifier = MockTransactionNotifier();
    mockCategoryNotifier = MockCategoryNotifier();
  });

  tearDown(() {
    TestSetup.dispose();
  });

  group('SplitTransactionBottomSheet', () {
    testWidgets('should display split transaction bottom sheet correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Split Transaction'), findsOneWidget);
      expect(find.text('Split a single transaction across multiple categories'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Split Configuration'), findsOneWidget);
    });

    testWidgets('should initialize with one split by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Split 1'), findsOneWidget);
      expect(find.text('1 split'), findsOneWidget);
    });

    testWidgets('should add split when add button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Split'));
      await tester.pumpAndSettle();

      expect(find.text('Split 1'), findsOneWidget);
      expect(find.text('Split 2'), findsOneWidget);
      expect(find.text('2 splits'), findsOneWidget);
    });

    testWidgets('should remove split when remove button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Add a second split first
      await tester.tap(find.text('Add Split'));
      await tester.pumpAndSettle();

      expect(find.text('2 splits'), findsOneWidget);

      // Remove the second split
      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
      await tester.pumpAndSettle();

      expect(find.text('Split 1'), findsOneWidget);
      expect(find.text('Split 2'), findsNothing);
      expect(find.text('1 split'), findsOneWidget);
    });

    testWidgets('should update remaining amount when total amount changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter total amount
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.pumpAndSettle();

      expect(find.text('Remaining: \$100.00'), findsOneWidget);

      // Enter split amount
      final splitAmountField = find.byType(TextField).at(1); // Second text field (amount in split)
      await tester.enterText(splitAmountField, '50.00');
      await tester.pumpAndSettle();

      expect(find.text('Remaining: \$50.00'), findsOneWidget);
    });

    testWidgets('should validate total amount is required',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter total amount'), findsOneWidget);
    });

    testWidgets('should validate account selection is required',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([])), // No accounts
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      expect(find.text('Please select an account'), findsOneWidget);
    });

    testWidgets('should validate split amounts sum to total',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter total amount
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.pumpAndSettle();

      // Enter split amount that doesn't match total
      final splitAmountField = find.byType(TextField).at(1);
      await tester.enterText(splitAmountField, '50.00');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      expect(find.text('Split amounts must total \$100.00'), findsOneWidget);
    });

    testWidgets('should submit valid split transaction',
        (WidgetTester tester) async {
      SplitTransaction? submittedTransaction;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {
                      submittedTransaction = splitTransaction;
                    },
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter total amount
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.pumpAndSettle();

      // Enter split amount
      final splitAmountField = find.byType(TextField).at(1);
      await tester.enterText(splitAmountField, '100.00');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      expect(submittedTransaction, isNotNull);
      expect(submittedTransaction!.totalAmount, 100.0);
      expect(submittedTransaction!.splits.length, 1);
    });

    testWidgets('should handle percentage and amount synchronization',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter total amount
      await tester.enterText(find.byType(TextField).first, '200.00');
      await tester.pumpAndSettle();

      // Enter percentage
      final percentageField = find.byType(TextField).at(2); // Third text field (percentage)
      await tester.enterText(percentageField, '50.0');
      await tester.pumpAndSettle();

      // Check that amount field is updated
      final amountField = find.byType(TextField).at(1);
      expect(find.text('100.00'), findsOneWidget); // Amount should be 100.00 (50% of 200)
    });

    testWidgets('should show error for single split validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Remove the only split (should not be allowed)
      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
      await tester.pumpAndSettle();

      expect(find.text('Split 1'), findsOneWidget); // Should still have one split
    });

    testWidgets('should handle maximum splits limit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Add splits up to a reasonable maximum (let's say 10 for testing)
      for (int i = 1; i < 10; i++) {
        await tester.tap(find.text('Add Split'));
        await tester.pumpAndSettle();
      }

      expect(find.text('10 splits'), findsOneWidget);
    });

    testWidgets('should handle zero amount validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter total amount
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.pumpAndSettle();

      // Enter zero amount for split
      final splitAmountField = find.byType(TextField).at(1);
      await tester.enterText(splitAmountField, '0.00');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      expect(find.text('Split amounts must total \$100.00'), findsOneWidget);
    });

    testWidgets('should handle invalid percentage allocations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter total amount
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.pumpAndSettle();

      // Add second split
      await tester.tap(find.text('Add Split'));
      await tester.pumpAndSettle();

      // Enter invalid percentages (more than 100% total)
      final firstPercentageField = find.byType(TextField).at(2);
      final secondPercentageField = find.byType(TextField).at(5);

      await tester.enterText(firstPercentageField, '70.0');
      await tester.pumpAndSettle();

      await tester.enterText(secondPercentageField, '40.0');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      expect(find.text('Split amounts must total \$100.00'), findsOneWidget);
    });

    testWidgets('should handle category selection requirement',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {},
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter total amount
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.pumpAndSettle();

      // Enter split amount without selecting category
      final splitAmountField = find.byType(TextField).at(1);
      await tester.enterText(splitAmountField, '100.00');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      expect(find.text('Please select a category for all splits'), findsOneWidget);
    });

    testWidgets('should show loading state during submission',
        (WidgetTester tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {
                      await completer.future; // Wait for completer
                    },
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter valid data
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.pumpAndSettle();

      final splitAmountField = find.byType(TextField).at(1);
      await tester.enterText(splitAmountField, '100.00');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      // Check loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Create Split Transaction'), findsNothing);

      // Complete the submission
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('should handle submission errors gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {
                      throw Exception('Submission failed');
                    },
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter valid data
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.pumpAndSettle();

      final splitAmountField = find.byType(TextField).at(1);
      await tester.enterText(splitAmountField, '100.00');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      expect(find.text('Error: Exception: Submission failed'), findsOneWidget);
    });

    testWidgets('should prevent multiple simultaneous submissions',
        (WidgetTester tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionNotifierProvider.overrideWith((ref) => mockTransactionNotifier),
            categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            filteredAccountsProvider.overrideWith((ref) => Stream.value([
              Account(id: '1', name: 'Test Account', type: AccountType.checking, balance: 1000.0),
            ])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SplitTransactionBottomSheet.show(
                    context: context,
                    onSubmit: (splitTransaction) async {
                      await completer.future;
                    },
                  ),
                  child: const Text('Show Split Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Split Sheet'));
      await tester.pumpAndSettle();

      // Enter valid data
      await tester.enterText(find.byType(TextField).first, '100.00');
      await tester.pumpAndSettle();

      final splitAmountField = find.byType(TextField).at(1);
      await tester.enterText(splitAmountField, '100.00');
      await tester.pumpAndSettle();

      // Tap submit multiple times quickly
      await tester.tap(find.text('Create Split Transaction'));
      await tester.tap(find.text('Create Split Transaction'));
      await tester.tap(find.text('Create Split Transaction'));
      await tester.pumpAndSettle();

      // Should only show one loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}