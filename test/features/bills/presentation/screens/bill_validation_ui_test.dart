import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_setup.dart';
import 'package:budget_tracker/features/bills/domain/entities/bill.dart';
import 'package:budget_tracker/features/bills/presentation/providers/bill_providers.dart';
import 'package:budget_tracker/features/bills/presentation/screens/bill_creation_screen.dart';
import 'package:budget_tracker/features/bills/presentation/widgets/edit_bill_bottom_sheet.dart';
import 'package:budget_tracker/features/bills/presentation/notifiers/bill_notifier.dart';
import 'package:budget_tracker/features/bills/presentation/states/bill_state.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/category_notifier.dart';
import 'package:budget_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:budget_tracker/features/transactions/presentation/states/category_state.dart';
import 'package:budget_tracker/core/widgets/error_view.dart';
import 'package:budget_tracker/core/widgets/loading_view.dart';

class MockBillNotifier extends Mock implements BillNotifier {}

class MockCategoryNotifier extends Mock implements CategoryNotifier {}

void main() {
  late MockBillNotifier mockBillNotifier;
  late MockCategoryNotifier mockCategoryNotifier;

  setUp(() {
    mockBillNotifier = MockBillNotifier();
    mockCategoryNotifier = MockCategoryNotifier();
    setupMockitoDummies();
  });

  group('Bill Validation UI Tests', () {
    group('BillCreationScreen', () {
      testWidgets('shows red border and error message for duplicate bill name',
          (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', icon: 'bolt', color: 0xFF10B981, type: TransactionType.expense),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(categories: expenseCategories)),
        );

        // Mock bill state with existing bill
        when(mockBillNotifier.state).thenReturn(
          BillState.loaded(
            bills: [
              Bill(
                id: '1',
                name: 'Electricity Bill',
                amount: 150.0,
                dueDate: DateTime.now().add(const Duration(days: 30)),
                frequency: BillFrequency.monthly,
                categoryId: 'utilities',
              )
            ],
            summary: BillsSummary(
              totalBills: 1,
              paidThisMonth: 0,
              dueThisMonth: 1,
              overdue: 0,
              totalMonthlyAmount: 150.0,
              paidAmount: 0.0,
              remainingAmount: 150.0,
              upcomingBills: [],
            ),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith((ref) => mockBillNotifier),
              categoryNotifierProvider.overrideWith((ref) => mockCategoryNotifier),
            ],
            child: const MaterialApp(
              home: BillCreationScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enter duplicate name
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Electricity Bill');
        await tester.pump();

        // Wait for validation debounce
        await tester.pump(const Duration(milliseconds: 600));

        // Verify red border appears - check the InputDecorator instead
        final inputDecorator = find.ancestor(
          of: nameField,
          matching: find.byType(InputDecorator),
        ).first;
        final decorator = tester.widget<InputDecorator>(inputDecorator);
        expect(decorator.decoration.errorBorder, isNotNull);
        expect(
          decorator.decoration.errorBorder,
          isA<OutlineInputBorder>().having(
            (border) => border.borderSide.color,
            'border color',
            Theme.of(tester.element(nameField)).colorScheme.error,
          ),
        );

        // Verify error message appears
        expect(find.text('A bill with this name already exists'), findsOneWidget);

        // Verify error icon appears
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('shows loading indicator during name validation', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        when(mockBillNotifier.state).thenReturn(
          AsyncData(BillState.loaded([], null)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: const MaterialApp(
              home: BillCreationScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enter name to trigger validation
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'New Bill Name');
        await tester.pump();

        // Should show loading indicator immediately
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for validation to complete
        await tester.pump(const Duration(milliseconds: 600));

        // Loading indicator should disappear
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('shows error container for bill creation failure', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        // Mock error state
        when(mockBillNotifier.state).thenReturn(
          AsyncError(Exception('Failed to create bill'), StackTrace.current),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: const MaterialApp(
              home: BillCreationScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify error container appears
        expect(find.byType(Container), findsWidgets); // Multiple containers, check styling

        // Find the error container by its properties
        final errorContainers = find.byWidgetPredicate((widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final decoration = widget.decoration as BoxDecoration;
            return decoration.color == Theme.of(tester.element(find.byType(MaterialApp))).colorScheme.errorContainer;
          }
          return false;
        });

        expect(errorContainers, findsOneWidget);

        // Verify error icon and message
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Failed to create bill'), findsOneWidget);
      });

      testWidgets('shows red border for invalid amount input', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: const MaterialApp(
              home: BillCreationScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enter invalid amount
        final amountField = find.byType(TextFormField).at(1); // Amount field
        await tester.enterText(amountField, '-100.00');
        await tester.pump();

        // Try to submit
        await tester.tap(find.text('Add Bill'));
        await tester.pump();

        // Verify red border appears
        final textField = tester.widget<TextFormField>(amountField);
        expect(textField.decoration?.errorBorder, isNotNull);
        expect(find.text('Please enter a valid amount'), findsOneWidget);
      });

      testWidgets('clears validation errors when input becomes valid', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        when(mockBillNotifier.state).thenReturn(
          AsyncData(BillState.loaded([
            Bill(
              id: '1',
              name: 'Existing Bill',
              amount: 150.0,
              dueDate: DateTime.now().add(const Duration(days: 30)),
              frequency: BillFrequency.monthly,
              categoryId: 'utilities',
            )
          ], null)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: const MaterialApp(
              home: BillCreationScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enter duplicate name
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Existing Bill');
        await tester.pump(const Duration(milliseconds: 600));

        // Verify error appears
        expect(find.text('A bill with this name already exists'), findsOneWidget);

        // Change to unique name
        await tester.enterText(nameField, 'Unique Bill Name');
        await tester.pump(const Duration(milliseconds: 600));

        // Verify error disappears
        expect(find.text('A bill with this name already exists'), findsNothing);
      });

      testWidgets('shows warning container for account validation errors', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: const MaterialApp(
              home: BillCreationScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Fill form with valid data
        await tester.enterText(find.byType(TextFormField).first, 'Test Bill');
        await tester.enterText(find.byType(TextFormField).at(1), '100.00');

        // Mock account validation failure during submission
        when(mockBillNotifier.createBill(any)).thenAnswer((_) async => false);

        // Submit
        await tester.tap(find.text('Add Bill'));
        await tester.pump();

        // Should show snackbar with account validation error
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    group('EditBillBottomSheet', () {
      late Bill testBill;

      setUp(() {
        testBill = Bill(
          id: '1',
          name: 'Test Bill',
          amount: 100.0,
          dueDate: DateTime.now().add(const Duration(days: 30)),
          frequency: BillFrequency.monthly,
          categoryId: 'utilities',
        );
      });

      testWidgets('shows red border and error message for duplicate bill name during edit',
          (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        // Mock bill state with existing bill (different from the one being edited)
        when(mockBillNotifier.state).thenReturn(
          AsyncData(BillState.loaded([
            testBill,
            Bill(
              id: '2',
              name: 'Another Bill',
              amount: 150.0,
              dueDate: DateTime.now().add(const Duration(days: 30)),
              frequency: BillFrequency.monthly,
              categoryId: 'utilities',
            )
          ], null)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => EditBillBottomSheet(
                          bill: testBill,
                          onSubmit: (_) async {},
                        ),
                      );
                    },
                    child: const Text('Show Edit Sheet'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open the bottom sheet
        await tester.tap(find.text('Show Edit Sheet'));
        await tester.pumpAndSettle();

        // Enter duplicate name
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Another Bill');
        await tester.pump();

        // Wait for validation debounce
        await tester.pump(const Duration(milliseconds: 600));

        // Verify red border appears
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.decoration?.errorBorder, isNotNull);

        // Verify error message appears
        expect(find.text('A bill with this name already exists'), findsOneWidget);

        // Verify error icon appears
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('shows loading indicator during name validation in edit mode', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        when(mockBillNotifier.state).thenReturn(
          AsyncData(BillState.loaded([testBill], null)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => EditBillBottomSheet(
                          bill: testBill,
                          onSubmit: (_) async {},
                        ),
                      );
                    },
                    child: const Text('Show Edit Sheet'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open the bottom sheet
        await tester.tap(find.text('Show Edit Sheet'));
        await tester.pumpAndSettle();

        // Enter new name to trigger validation
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Updated Bill Name');
        await tester.pump();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for validation to complete
        await tester.pump(const Duration(milliseconds: 600));

        // Loading indicator should disappear
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('shows red border for invalid amount in edit mode', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => EditBillBottomSheet(
                          bill: testBill,
                          onSubmit: (_) async {},
                        ),
                      );
                    },
                    child: const Text('Show Edit Sheet'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open the bottom sheet
        await tester.tap(find.text('Show Edit Sheet'));
        await tester.pumpAndSettle();

        // Enter invalid amount
        final amountField = find.byType(TextFormField).at(1);
        await tester.enterText(amountField, '0');
        await tester.pump();

        // Try to submit
        await tester.tap(find.text('Update Bill'));
        await tester.pump();

        // Verify red border appears
        final textField = tester.widget<TextFormField>(amountField);
        expect(textField.decoration?.errorBorder, isNotNull);
        expect(find.text('Please enter a valid amount'), findsOneWidget);
      });

      testWidgets('clears validation errors in edit mode when input becomes valid', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        // Mock bill state with existing bill
        when(mockBillNotifier.state).thenReturn(
          AsyncData(BillState.loaded([
            testBill,
            Bill(
              id: '2',
              name: 'Existing Bill',
              amount: 150.0,
              dueDate: DateTime.now().add(const Duration(days: 30)),
              frequency: BillFrequency.monthly,
              categoryId: 'utilities',
            )
          ], null)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => EditBillBottomSheet(
                          bill: testBill,
                          onSubmit: (_) async {},
                        ),
                      );
                    },
                    child: const Text('Show Edit Sheet'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open the bottom sheet
        await tester.tap(find.text('Show Edit Sheet'));
        await tester.pumpAndSettle();

        // Enter duplicate name
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Existing Bill');
        await tester.pump(const Duration(milliseconds: 600));

        // Verify error appears
        expect(find.text('A bill with this name already exists'), findsOneWidget);

        // Change to unique name
        await tester.enterText(nameField, 'Unique Updated Bill');
        await tester.pump(const Duration(milliseconds: 600));

        // Verify error disappears
        expect(find.text('A bill with this name already exists'), findsNothing);
      });

      testWidgets('shows loading state during bill update submission', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => EditBillBottomSheet(
                          bill: testBill,
                          onSubmit: (_) async {
                            // Simulate async operation
                            await Future.delayed(const Duration(seconds: 1));
                          },
                        ),
                      );
                    },
                    child: const Text('Show Edit Sheet'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open the bottom sheet
        await tester.tap(find.text('Show Edit Sheet'));
        await tester.pumpAndSettle();

        // Submit the form
        await tester.tap(find.text('Update Bill'));
        await tester.pump();

        // Should show loading indicator on button
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Update Bill'), findsNothing); // Button text hidden during loading
      });
    });

    group('Validation Feedback Timing and Animations', () {
      testWidgets('debounces validation to prevent excessive API calls', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        when(mockBillNotifier.state).thenReturn(
          AsyncData(BillState.loaded([], null)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: const MaterialApp(
              home: BillCreationScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final nameField = find.byType(TextFormField).first;

        // Rapid typing simulation
        await tester.enterText(nameField, 'B');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(nameField, 'Bi');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(nameField, 'Bil');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(nameField, 'Bill');
        await tester.pump(const Duration(milliseconds: 100));

        // Should not show validation error immediately (debounced)
        expect(find.text('A bill with this name already exists'), findsNothing);

        // Wait for debounce period
        await tester.pump(const Duration(milliseconds: 500));

        // Validation should have completed
        verify(mockBillNotifier.state).called(greaterThanOrEqualTo(1));
      });

      testWidgets('shows smooth transitions between validation states', (tester) async {
        final expenseCategories = [
          TransactionCategory(id: 'utilities', name: 'Utilities', color: 0xFF10B981),
        ];

        when(mockCategoryNotifier.state).thenReturn(
          AsyncData(CategoryState(expenseCategories: expenseCategories)),
        );

        when(mockBillNotifier.state).thenReturn(
          AsyncData(BillState.loaded([
            Bill(
              id: '1',
              name: 'Existing Bill',
              amount: 150.0,
              dueDate: DateTime.now().add(const Duration(days: 30)),
              frequency: BillFrequency.monthly,
              categoryId: 'utilities',
            )
          ], null)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              billNotifierProvider.overrideWith(() => mockBillNotifier),
              categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
            ],
            child: const MaterialApp(
              home: BillCreationScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final nameField = find.byType(TextFormField).first;

        // Enter duplicate name
        await tester.enterText(nameField, 'Existing Bill');
        await tester.pump();

        // Should show loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for validation
        await tester.pump(const Duration(milliseconds: 600));

        // Should transition to error state
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('A bill with this name already exists'), findsOneWidget);

        // Clear error by entering valid name
        await tester.enterText(nameField, 'New Unique Bill');
        await tester.pump();

        // Should show loading again
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for validation
        await tester.pump(const Duration(milliseconds: 600));

        // Should clear error
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('A bill with this name already exists'), findsNothing);
      });
    });
  });
}