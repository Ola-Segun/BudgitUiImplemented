
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:budget_tracker/core/error/failures.dart';
import 'package:budget_tracker/core/error/result.dart';
import 'package:budget_tracker/features/accounts/domain/entities/account.dart';
import 'package:budget_tracker/features/accounts/domain/repositories/account_repository.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:budget_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budget_tracker/features/transactions/domain/usecases/add_transaction.dart';
import 'package:budget_tracker/features/transactions/domain/usecases/get_transactions.dart';
import 'package:budget_tracker/features/transactions/domain/usecases/get_paginated_transactions.dart';
import 'package:budget_tracker/features/transactions/domain/usecases/update_transaction.dart';
import 'package:budget_tracker/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:budget_tracker/features/transactions/domain/usecases/get_categories.dart';
import 'package:budget_tracker/features/transactions/domain/usecases/add_category.dart';
import 'package:budget_tracker/features/transactions/domain/usecases/update_category.dart';
import 'package:budget_tracker/features/transactions/domain/usecases/delete_category.dart';
import 'package:budget_tracker/features/transactions/domain/repositories/transaction_category_repository.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/transaction_notifier.dart';
import 'package:budget_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:budget_tracker/features/transactions/presentation/widgets/add_transaction_bottom_sheet.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/category_notifier.dart';
import 'package:budget_tracker/features/transactions/domain/services/category_icon_color_service.dart';

import '../../../../test_setup.dart';
import 'add_transaction_bottom_sheet_edge_cases_test.mocks.dart';

@GenerateMocks([
  TransactionRepository,
  AccountRepository,
  CategoryIconColorService,
  TransactionCategoryRepository,
])

void main() {
  late MockTransactionRepository mockTransactionRepository;
  late MockAccountRepository mockAccountRepository;
  late MockCategoryIconColorService mockCategoryIconColorService;
  late MockTransactionCategoryRepository mockCategoryRepository;
  late AddTransaction useCase;

  setUpAll(() {
    setupMockitoDummies();
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockAccountRepository = MockAccountRepository();
    mockCategoryIconColorService = MockCategoryIconColorService();
    mockCategoryRepository = MockTransactionCategoryRepository();
    useCase = AddTransaction(mockTransactionRepository, mockAccountRepository);

    // Setup default mocks
    when(mockCategoryIconColorService.getIconForCategory(any)).thenReturn(Icons.category);
    when(mockCategoryIconColorService.getColorForCategory(any)).thenReturn(Colors.blue);
  });

  group('AddTransactionBottomSheet Edge Cases', () {
    const testAccount = Account(
      id: 'test-account',
      name: 'Test Account',
      type: AccountType.bankAccount,
      cachedBalance: 1000.0,
    );

    final testCategories = [
      TransactionCategory(
        id: 'food',
        name: 'Food',
        type: TransactionType.expense,
        color: 0xFF000000,
        icon: 'restaurant',
      ),
      TransactionCategory(
        id: 'salary',
        name: 'Salary',
        type: TransactionType.income,
        color: 0xFF00FF00,
        icon: 'work',
      ),
    ];

    Widget createTestWidget({
      required Future<void> Function(Transaction) onSubmit,
      bool simulateOffline = false,
      bool simulateAuthFailure = false,
    }) {
      return ProviderScope(
        overrides: [
          transactionNotifierProvider.overrideWith((ref) {
            return TransactionNotifier(
              getTransactions: GetTransactions(mockTransactionRepository),
              getPaginatedTransactions: GetPaginatedTransactions(mockTransactionRepository),
              addTransaction: useCase,
              updateTransaction: UpdateTransaction(mockTransactionRepository, mockAccountRepository),
              deleteTransaction: DeleteTransaction(mockTransactionRepository, mockAccountRepository),
            );
          }),
          categoryNotifierProvider.overrideWith((ref) {
            return CategoryNotifier(
              getCategories: GetCategories(mockCategoryRepository),
              addCategory: AddCategory(mockCategoryRepository),
              updateCategory: UpdateCategory(mockCategoryRepository),
              deleteCategory: DeleteCategory(mockCategoryRepository),
            );
          }),
          categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddTransactionBottomSheet(onSubmit: onSubmit),
                ),
                child: const Text('Open Bottom Sheet'),
              ),
            ),
          ),
        ),
      );
    }

    group('Network Connectivity Issues', () {
      testWidgets('should handle offline state gracefully', (tester) async {
        // Setup offline simulation - repository throws network error
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.error(Failure.network('No internet connection')));

        Transaction? submittedTransaction;
        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async => submittedTransaction = transaction,
          simulateOffline: true,
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify bottom sheet is visible
        expect(find.byType(AddTransactionBottomSheet), findsOneWidget);
        expect(find.text('Add Transaction'), findsOneWidget);

        // Fill form with valid data
        await tester.enterText(find.byType(TextFormField).first, '25.50');
        await tester.pump();

        // Select category
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        // Select account
        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        // Submit transaction
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for error handling
        await tester.pumpAndSettle();

        // Verify error message is shown
        expect(find.text('Failed to add transaction'), findsOneWidget);

        // Verify bottom sheet is still visible (not dismissed)
        expect(find.byType(AddTransactionBottomSheet), findsOneWidget);

        // Verify home screen is still visible behind
        expect(find.text('Open Bottom Sheet'), findsOneWidget);
      });

      testWidgets('should handle network timeout gracefully', (tester) async {
        // Setup timeout simulation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(seconds: 30)); // Simulate timeout
              return Result.error(Failure.network('Request timeout'));
            });

        Transaction? submittedTransaction;
        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async => submittedTransaction = transaction,
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Fill and submit form quickly
        await tester.enterText(find.byType(TextFormField).first, '10.00');
        await tester.pump();

        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify loading state appears
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Simulate timeout by advancing time
        await tester.pump(const Duration(seconds: 35));

        // Verify error handling (this might need adjustment based on actual timeout handling)
        expect(find.byType(AddTransactionBottomSheet), findsOneWidget);
      });
    });

    group('Authentication State Issues', () {
      testWidgets('should handle authentication failure during submission', (tester) async {
        // Setup auth failure simulation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.error(Failure.unknown('Session expired')));

        Transaction? submittedTransaction;
        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async => submittedTransaction = transaction,
          simulateAuthFailure: true,
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, '50.00');
        await tester.pump();

        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for error
        await tester.pumpAndSettle();

        // Verify error message
        expect(find.text('Failed to add transaction'), findsOneWidget);

        // Verify bottom sheet remains open
        expect(find.byType(AddTransactionBottomSheet), findsOneWidget);
      });
    });

    group('Device Orientation Tests', () {
      testWidgets('should handle portrait orientation correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSubmit: (_) async {},
        ));

        // Set portrait orientation
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify bottom sheet adapts to portrait
        expect(find.byType(AddTransactionBottomSheet), findsOneWidget);

        // Check that content is scrollable and fits
        final scrollableFinder = find.byType(SingleChildScrollView);
        expect(scrollableFinder, findsOneWidget);

        // Verify form elements are accessible
        expect(find.text('Add Transaction'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4)); // amount, description, note, and date field
      });

      testWidgets('should handle landscape orientation correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSubmit: (_) async {},
        ));

        // Set landscape orientation
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify bottom sheet adapts to landscape
        expect(find.byType(AddTransactionBottomSheet), findsOneWidget);

        // Verify content is still accessible in landscape
        expect(find.text('Add Transaction'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4));
      });
    });

    group('Form Validation Tests', () {
      testWidgets('should prevent submission with empty amount', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSubmit: (_) async {},
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Leave amount empty, fill other fields
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        // Try to submit
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify validation error
        expect(find.text('Please enter an amount'), findsOneWidget);

        // Verify bottom sheet stays open
        expect(find.byType(AddTransactionBottomSheet), findsOneWidget);
      });

      testWidgets('should prevent submission with zero amount', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSubmit: (_) async {},
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Enter zero amount
        await tester.enterText(find.byType(TextFormField).first, '0');
        await tester.pump();

        // Fill other required fields
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        // Try to submit
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify validation error
        expect(find.text('Please enter a valid amount'), findsOneWidget);
      });

      testWidgets('should prevent submission with negative amount', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSubmit: (_) async {},
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Enter negative amount
        await tester.enterText(find.byType(TextFormField).first, '-50');
        await tester.pump();

        // Fill other required fields
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        // Try to submit
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify validation error
        expect(find.text('Please enter a valid amount'), findsOneWidget);
      });

      testWidgets('should prevent submission without category selection', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSubmit: (_) async {},
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Fill amount
        await tester.enterText(find.byType(TextFormField).first, '25.00');
        await tester.pump();

        // Select account but not category
        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        // Try to submit
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify validation error
        expect(find.text('Please select a category'), findsOneWidget);
      });

      testWidgets('should prevent submission without account selection', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSubmit: (_) async {},
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Fill amount
        await tester.enterText(find.byType(TextFormField).first, '25.00');
        await tester.pump();

        // Select category but not account
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        // Try to submit
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify validation error
        expect(find.text('Please select an account'), findsOneWidget);
      });

      testWidgets('should accept valid decimal amounts', (tester) async {
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.success(Transaction(
                  id: 'test-id',
                  title: 'Test Transaction',
                  amount: 25.99,
                  type: TransactionType.expense,
                  date: DateTime.now(),
                  categoryId: 'food',
                  accountId: 'test-account',
                )));
        when(mockAccountRepository.getById(any))
            .thenAnswer((_) async => Result.success(testAccount));
        when(mockAccountRepository.update(any))
            .thenAnswer((_) async => Result.success(testAccount));

        Transaction? submittedTransaction;
        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async => submittedTransaction = transaction,
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Enter decimal amount
        await tester.enterText(find.byType(TextFormField).first, '25.99');
        await tester.pump();

        // Fill other fields
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for success
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Transaction added successfully'), findsOneWidget);

        // Verify transaction was submitted
        expect(submittedTransaction?.amount, 25.99);
      });
    });

    group('Concurrent Operations Tests', () {
      testWidgets('should handle rapid successive submissions', (tester) async {
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.success(Transaction(
                  id: 'test-id-${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Test Transaction',
                  amount: 10.0,
                  type: TransactionType.expense,
                  date: DateTime.now(),
                  categoryId: 'food',
                  accountId: 'test-account',
                )));
        when(mockAccountRepository.getById(any))
            .thenAnswer((_) async => Result.success(testAccount));
        when(mockAccountRepository.update(any))
            .thenAnswer((_) async => Result.success(testAccount));

        int submissionCount = 0;
        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async => submissionCount++,
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, '10.00');
        await tester.pump();

        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        // Rapid clicks on submit button
        await tester.tap(find.text('Add Transaction'));
        await tester.tap(find.text('Add Transaction'));
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify only one submission is processed (loading state prevents duplicates)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for completion
        await tester.pumpAndSettle();

        // Verify success message appears
        expect(find.text('Transaction added successfully'), findsOneWidget);

        // Verify only one submission was processed
        expect(submissionCount, 1);
      });

      testWidgets('should handle submission during background operations', (tester) async {
        // Setup slow repository response to simulate background operation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(seconds: 2));
              return Result.success(Transaction(
                id: 'test-id',
                title: 'Test Transaction',
                amount: 20.0,
                type: TransactionType.expense,
                date: DateTime.now(),
                categoryId: 'food',
                accountId: 'test-account',
              ));
            });
        when(mockAccountRepository.getById(any))
            .thenAnswer((_) async => Result.success(testAccount));
        when(mockAccountRepository.update(any))
            .thenAnswer((_) async => Result.success(testAccount));

        Transaction? submittedTransaction;
        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async => submittedTransaction = transaction,
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, '20.00');
        await tester.pump();

        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Try to submit again while first is processing
        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify still only one loading indicator (duplicate submission prevented)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for completion
        await tester.pumpAndSettle();

        // Verify success
        expect(find.text('Transaction added successfully'), findsOneWidget);
        expect(submittedTransaction?.amount, 20.0);
      });
    });

    group('UI Stability Tests', () {
      testWidgets('should maintain home screen visibility during all operations', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSubmit: (_) async {},
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify both home screen and bottom sheet are visible
        expect(find.text('Open Bottom Sheet'), findsOneWidget); // Home screen content
        expect(find.byType(AddTransactionBottomSheet), findsOneWidget); // Bottom sheet

        // Fill form and submit
        await tester.enterText(find.byType(TextFormField).first, '15.00');
        await tester.pump();

        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Verify home screen remains visible during loading
        expect(find.text('Open Bottom Sheet'), findsOneWidget);
        expect(find.byType(AddTransactionBottomSheet), findsOneWidget);
      });

      testWidgets('should not crash on rapid bottom sheet interactions', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSubmit: (_) async {},
        ));

        // Rapidly open and close bottom sheet multiple times
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('Open Bottom Sheet'));
          await tester.pumpAndSettle();

          expect(find.byType(AddTransactionBottomSheet), findsOneWidget);

          // Close bottom sheet
          await tester.tap(find.byIcon(Icons.close));
          await tester.pumpAndSettle();

          // Verify bottom sheet is closed
          expect(find.byType(AddTransactionBottomSheet), findsNothing);
          expect(find.text('Open Bottom Sheet'), findsOneWidget);
        }

        // Verify no crashes occurred and app is still functional
        expect(find.text('Open Bottom Sheet'), findsOneWidget);
      });
    });
  });
}