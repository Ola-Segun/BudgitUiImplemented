
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

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
import 'package:budget_tracker/features/transactions/presentation/widgets/enhanced_add_transaction_bottom_sheet.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/category_notifier.dart';
import 'package:budget_tracker/features/transactions/domain/services/category_icon_color_service.dart';

import '../../../../test_setup.dart';
import 'add_transaction_bottom_sheet_dismissal_test.mocks.dart';

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

  group('EnhancedEnhancedAddTransactionBottomSheet Dismissal Behavior', () {
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
      TransactionType? initialType,
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
                  builder: (context) => EnhancedAddTransactionBottomSheet(
                    onSubmit: onSubmit,
                    initialType: initialType,
                  ),
                ),
                child: const Text('Open Bottom Sheet'),
              ),
            ),
          ),
        ),
      );
    }

    group('Successful Transaction Submission Dismissal', () {
      testWidgets('should dismiss bottom sheet after successful expense transaction submission', (tester) async {
        // Setup successful transaction creation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.success(Transaction(
                  id: 'test-id',
                  title: 'Test Expense',
                  amount: 25.50,
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

        // Verify bottom sheet is visible
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsOneWidget);
        expect(find.text('Add Transaction'), findsOneWidget);

        // Fill form with valid expense data
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

        // Wait for submission to complete and bottom sheet to dismiss
        await tester.pumpAndSettle();

        // Verify bottom sheet is dismissed
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsNothing);

        // Verify home screen is still visible
        expect(find.text('Open Bottom Sheet'), findsOneWidget);

        // Verify transaction was submitted
        expect(submittedTransaction?.amount, 25.50);
        expect(submittedTransaction?.type, TransactionType.expense);
      });

      testWidgets('should dismiss bottom sheet after successful income transaction submission', (tester) async {
        // Setup successful transaction creation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.success(Transaction(
                  id: 'test-id',
                  title: 'Test Income',
                  amount: 500.00,
                  type: TransactionType.income,
                  date: DateTime.now(),
                  categoryId: 'salary',
                  accountId: 'test-account',
                )));
        when(mockAccountRepository.getById(any))
            .thenAnswer((_) async => Result.success(testAccount));
        when(mockAccountRepository.update(any))
            .thenAnswer((_) async => Result.success(testAccount));

        Transaction? submittedTransaction;
        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async => submittedTransaction = transaction,
          initialType: TransactionType.income,
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify bottom sheet is visible and pre-selected to income
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsOneWidget);
        expect(find.text('Add Transaction'), findsOneWidget);

        // Fill form with valid income data
        await tester.enterText(find.byType(TextFormField).first, '500.00');
        await tester.pump();

        // Select category (should show income categories)
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Salary').last);
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

        // Wait for submission to complete and bottom sheet to dismiss
        await tester.pumpAndSettle();

        // Verify bottom sheet is dismissed
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsNothing);

        // Verify home screen is still visible
        expect(find.text('Open Bottom Sheet'), findsOneWidget);

        // Verify transaction was submitted
        expect(submittedTransaction?.amount, 500.00);
        expect(submittedTransaction?.type, TransactionType.income);
      });
    });

    group('Entry Point Consistency', () {
      testWidgets('should dismiss consistently when opened via FAB (no initial type)', (tester) async {
        // Setup successful transaction creation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.success(Transaction(
                  id: 'test-id',
                  title: 'Test Transaction',
                  amount: 100.00,
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
          // No initialType - simulates FAB behavior
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify bottom sheet opens with default expense type
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsOneWidget);

        // Fill and submit form
        await tester.enterText(find.byType(TextFormField).first, '100.00');
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

        // Wait for dismissal
        await tester.pumpAndSettle();

        // Verify dismissal occurred
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsNothing);
        expect(submittedTransaction?.amount, 100.00);
      });

      testWidgets('should dismiss consistently when opened via Income button', (tester) async {
        // Setup successful transaction creation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.success(Transaction(
                  id: 'test-id',
                  title: 'Income Transaction',
                  amount: 200.00,
                  type: TransactionType.income,
                  date: DateTime.now(),
                  categoryId: 'salary',
                  accountId: 'test-account',
                )));
        when(mockAccountRepository.getById(any))
            .thenAnswer((_) async => Result.success(testAccount));
        when(mockAccountRepository.update(any))
            .thenAnswer((_) async => Result.success(testAccount));

        Transaction? submittedTransaction;
        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async => submittedTransaction = transaction,
          initialType: TransactionType.income, // Simulates Income button
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify bottom sheet opens with income type pre-selected
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsOneWidget);

        // Fill and submit form
        await tester.enterText(find.byType(TextFormField).first, '200.00');
        await tester.pump();

        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Salary').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButtonFormField<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Account').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Wait for dismissal
        await tester.pumpAndSettle();

        // Verify dismissal occurred
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsNothing);
        expect(submittedTransaction?.amount, 200.00);
        expect(submittedTransaction?.type, TransactionType.income);
      });

      testWidgets('should dismiss consistently when opened via Expense button', (tester) async {
        // Setup successful transaction creation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.success(Transaction(
                  id: 'test-id',
                  title: 'Expense Transaction',
                  amount: 75.00,
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
          initialType: TransactionType.expense, // Simulates Expense button
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify bottom sheet opens with expense type pre-selected
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsOneWidget);

        // Fill and submit form
        await tester.enterText(find.byType(TextFormField).first, '75.00');
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

        // Wait for dismissal
        await tester.pumpAndSettle();

        // Verify dismissal occurred
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsNothing);
        expect(submittedTransaction?.amount, 75.00);
        expect(submittedTransaction?.type, TransactionType.expense);
      });
    });

    group('Data Persistence and UI Updates', () {
      testWidgets('should persist transaction data and update UI after successful submission', (tester) async {
        // Setup successful transaction creation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.success(Transaction(
                  id: 'test-id',
                  title: 'Persisted Transaction',
                  amount: 150.00,
                  type: TransactionType.expense,
                  date: DateTime.now(),
                  categoryId: 'food',
                  accountId: 'test-account',
                )));
        when(mockAccountRepository.getById(any))
            .thenAnswer((_) async => Result.success(testAccount));
        when(mockAccountRepository.update(any))
            .thenAnswer((_) async => Result.success(testAccount));

        List<Transaction> persistedTransactions = [];
        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async {
            persistedTransactions.add(transaction);
            // Simulate successful persistence
          },
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Fill and submit form
        await tester.enterText(find.byType(TextFormField).first, '150.00');
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

        // Wait for dismissal
        await tester.pumpAndSettle();

        // Verify bottom sheet is dismissed
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsNothing);

        // Verify data persistence
        expect(persistedTransactions.length, 1);
        expect(persistedTransactions.first.amount, 150.00);
        expect(persistedTransactions.first.title, 'Persisted Transaction');
      });

      testWidgets('should show success message after transaction submission', (tester) async {
        // Setup successful transaction creation
        when(mockTransactionRepository.add(any))
            .thenAnswer((_) async => Result.success(Transaction(
                  id: 'test-id',
                  title: 'Success Transaction',
                  amount: 50.00,
                  type: TransactionType.expense,
                  date: DateTime.now(),
                  categoryId: 'food',
                  accountId: 'test-account',
                )));
        when(mockAccountRepository.getById(any))
            .thenAnswer((_) async => Result.success(testAccount));
        when(mockAccountRepository.update(any))
            .thenAnswer((_) async => Result.success(testAccount));

        await tester.pumpWidget(createTestWidget(
          onSubmit: (transaction) async {
            // Simulate showing success message (this would be done by the parent widget)
            final context = tester.element(find.text('Open Bottom Sheet'));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction added successfully')),
            );
          },
        ));

        // Open bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Fill and submit form
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

        await tester.tap(find.text('Add Transaction'));
        await tester.pump();

        // Wait for dismissal and success message
        await tester.pumpAndSettle();

        // Verify bottom sheet is dismissed
        expect(find.byType(EnhancedAddTransactionBottomSheet), findsNothing);

        // Verify success message appears
        expect(find.text('Transaction added successfully'), findsOneWidget);
      });
    });
  });
}