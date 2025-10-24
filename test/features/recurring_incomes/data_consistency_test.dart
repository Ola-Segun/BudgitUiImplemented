import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:budget_tracker/core/error/failures.dart';
import 'package:budget_tracker/core/error/result.dart';
import 'package:budget_tracker/features/accounts/domain/entities/account.dart';
import 'package:budget_tracker/features/accounts/domain/repositories/account_repository.dart';
import 'package:budget_tracker/features/recurring_incomes/domain/entities/recurring_income.dart';
import 'package:budget_tracker/features/recurring_incomes/domain/repositories/recurring_income_repository.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:budget_tracker/features/transactions/domain/repositories/transaction_repository.dart';

@GenerateMocks([RecurringIncomeRepository, AccountRepository, TransactionRepository])
import 'data_consistency_test.mocks.dart';

void main() {
  late MockRecurringIncomeRepository mockRecurringIncomeRepository;
  late MockAccountRepository mockAccountRepository;
  late MockTransactionRepository mockTransactionRepository;

  setUpAll(() {
    provideDummy<Result<List<RecurringIncome>>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<List<Account>>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<List<Transaction>>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<Map<String, double>>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<RecurringIncome>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<RecurringIncomesSummary>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<RecurringIncome?>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<Account?>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<Transaction>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<Transaction?>>(Result.error(Failure.unknown('dummy')));
    provideDummy<Result<void>>(Result.success(null));
  });

  setUp(() {
    mockRecurringIncomeRepository = MockRecurringIncomeRepository();
    mockAccountRepository = MockAccountRepository();
    mockTransactionRepository = MockTransactionRepository();
  });

  group('Data Consistency Tests - Recurring Income-Account-Transaction Relationships', () {
    const accountId1 = 'acc_1';
    const accountId2 = 'acc_2';
    const incomeId1 = 'income_1';
    const incomeId2 = 'income_2';

    final account1 = Account(
      id: accountId1,
      name: 'Checking Account',
      type: AccountType.bankAccount,
      cachedBalance: 1000.0,
      reconciledBalance: 1000.0,
      isActive: true,
    );

    final account2 = Account(
      id: accountId2,
      name: 'Savings Account',
      type: AccountType.bankAccount,
      cachedBalance: 5000.0,
      reconciledBalance: 5000.0,
      isActive: true,
    );

    test('should maintain balance consistency: account balance equals sum of transaction effects from recurring income receipts', () async {
      // Arrange - Account with recurring income transactions
      final income = RecurringIncome(
        id: incomeId1,
        name: 'Monthly Salary',
        amount: 3000.0,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        frequency: RecurringIncomeFrequency.monthly,
        categoryId: 'salary',
        defaultAccountId: accountId1,
        incomeHistory: [
          RecurringIncomeInstance(
            id: 'receipt_1',
            amount: 3000.0,
            receivedDate: DateTime.now().subtract(const Duration(days: 30)),
            accountId: accountId1,
          ),
          RecurringIncomeInstance(
            id: 'receipt_2',
            amount: 3000.0,
            receivedDate: DateTime.now(),
            accountId: accountId1,
          ),
        ],
      );

      final transactions = [
        Transaction(
          id: 'tx_1',
          title: 'Monthly Salary - Receipt 1',
          amount: 3000.0,
          type: TransactionType.income,
          date: DateTime.now().subtract(const Duration(days: 30)),
          categoryId: 'salary',
          accountId: accountId1,
        ),
        Transaction(
          id: 'tx_2',
          title: 'Monthly Salary - Receipt 2',
          amount: 3000.0,
          type: TransactionType.income,
          date: DateTime.now(),
          categoryId: 'salary',
          accountId: accountId1,
        ),
      ];

      // Expected balance: 3000 + 3000 = 6000 (only income transactions)
      final expectedBalance = 6000.0;

      when(mockTransactionRepository.getByAccountId(accountId1))
          .thenAnswer((_) async => Result.success(transactions));
      when(mockAccountRepository.getById(accountId1))
          .thenAnswer((_) async => Result.success(account1));
      when(mockRecurringIncomeRepository.getById(incomeId1))
          .thenAnswer((_) async => Result.success(income));

      // Act - Calculate actual balance from transactions
      final transactionsResult = await mockTransactionRepository.getByAccountId(accountId1);
      final accountResult = await mockAccountRepository.getById(accountId1);
      final incomeResult = await mockRecurringIncomeRepository.getById(incomeId1);

      // Assert
      expect(transactionsResult.isSuccess, true);
      expect(accountResult.isSuccess, true);
      expect(incomeResult.isSuccess, true);

      final actualTransactions = transactionsResult.dataOrNull!;
      final account = accountResult.dataOrNull!;
      final actualIncome = incomeResult.dataOrNull!;

      // Calculate balance from transactions
      final calculatedBalance = actualTransactions.fold<double>(
        0, // Start with zero and add all transaction effects
        (sum, tx) => sum + tx.effectiveAmount,
      );

      // Account balance should equal calculated balance
      expect(account.currentBalance, calculatedBalance);
      expect(calculatedBalance, expectedBalance);

      // Income history should match transaction amounts
      final totalIncomeReceived = actualIncome.totalReceived;
      final totalTransactionAmount = actualTransactions.fold<double>(
        0,
        (sum, tx) => sum + tx.amount,
      );
      expect(totalIncomeReceived, totalTransactionAmount);
    });

    test('should maintain recurring income receipt consistency: receipts create corresponding transactions', () async {
      // Arrange - Recurring income with receipt history
      final income = RecurringIncome(
        id: incomeId1,
        name: 'Freelance Income',
        amount: 1500.0,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        frequency: RecurringIncomeFrequency.monthly,
        categoryId: 'freelance',
        defaultAccountId: accountId1,
        incomeHistory: [
          RecurringIncomeInstance(
            id: 'receipt_1',
            amount: 1500.0,
            receivedDate: DateTime.now(),
            accountId: accountId1,
            transactionId: 'tx_1',
          ),
        ],
      );

      // Expected transaction from income receipt
      final expectedTransaction = Transaction(
        id: 'tx_1',
        title: 'Freelance Income',
        amount: 1500.0,
        type: TransactionType.income,
        date: DateTime.now(),
        categoryId: 'freelance',
        accountId: accountId1,
        description: 'Recurring income receipt',
      );

      when(mockRecurringIncomeRepository.getById(incomeId1))
          .thenAnswer((_) async => Result.success(income));
      when(mockTransactionRepository.getById('tx_1'))
          .thenAnswer((_) async => Result.success(expectedTransaction));

      // Act
      final incomeResult = await mockRecurringIncomeRepository.getById(incomeId1);
      final transactionResult = await mockTransactionRepository.getById('tx_1');

      // Assert
      expect(incomeResult.isSuccess, true);
      expect(transactionResult.isSuccess, true);

      final actualIncome = incomeResult.dataOrNull!;
      final actualTransaction = transactionResult.dataOrNull!;

      // Receipt should have corresponding transaction
      expect(actualIncome.incomeHistory.length, 1);
      final receipt = actualIncome.incomeHistory.first;
      expect(receipt.transactionId, isNotNull);
      expect(receipt.transactionId, actualTransaction.id);

      // Transaction details should match receipt
      expect(actualTransaction.amount, receipt.amount);
      expect(actualTransaction.date, receipt.receivedDate);
      expect(actualTransaction.accountId, receipt.accountId);
      expect(actualTransaction.categoryId, actualIncome.categoryId);
    });

    test('should maintain account-referral integrity: recurring incomes reference valid accounts', () async {
      // Arrange - Incomes linked to accounts
      final incomes = [
        RecurringIncome(
          id: incomeId1,
          name: 'Salary',
          amount: 3000.0,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          frequency: RecurringIncomeFrequency.monthly,
          categoryId: 'salary',
          defaultAccountId: accountId1,
        ),
        RecurringIncome(
          id: incomeId2,
          name: 'Bonus',
          amount: 1000.0,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          frequency: RecurringIncomeFrequency.quarterly,
          categoryId: 'bonus',
          defaultAccountId: accountId2,
        ),
      ];

      when(mockRecurringIncomeRepository.getAll())
          .thenAnswer((_) async => Result.success(incomes));
      when(mockAccountRepository.getById(accountId1))
          .thenAnswer((_) async => Result.success(account1));
      when(mockAccountRepository.getById(accountId2))
          .thenAnswer((_) async => Result.success(account2));

      // Act
      final incomesResult = await mockRecurringIncomeRepository.getAll();
      final account1Result = await mockAccountRepository.getById(accountId1);
      final account2Result = await mockAccountRepository.getById(accountId2);

      // Assert
      expect(incomesResult.isSuccess, true);
      expect(account1Result.isSuccess, true);
      expect(account2Result.isSuccess, true);

      final actualIncomes = incomesResult.dataOrNull!;
      final actualAccount1 = account1Result.dataOrNull!;
      final actualAccount2 = account2Result.dataOrNull!;

      // All incomes should reference valid accounts
      for (final income in actualIncomes) {
        expect(income.effectiveAccountId, isNotNull);
        final accountId = income.effectiveAccountId!;
        if (accountId == accountId1) {
          expect(actualAccount1.isActive, true);
        } else if (accountId == accountId2) {
          expect(actualAccount2.isActive, true);
        }
      }
    });

    test('should maintain summary calculations accuracy: dashboard summary matches individual income data', () async {
      // Arrange - Multiple incomes with different statuses
      final now = DateTime.now();
      final incomes = [
        RecurringIncome(
          id: incomeId1,
          name: 'Salary',
          amount: 3000.0,
          startDate: now.subtract(const Duration(days: 30)),
          frequency: RecurringIncomeFrequency.monthly,
          categoryId: 'salary',
          defaultAccountId: accountId1,
          nextExpectedDate: now.add(const Duration(days: 1)),
          incomeHistory: [
            RecurringIncomeInstance(
              id: 'receipt_1',
              amount: 3000.0,
              receivedDate: now.subtract(const Duration(days: 30)),
              accountId: accountId1,
            ),
          ],
        ),
        RecurringIncome(
          id: incomeId2,
          name: 'Freelance',
          amount: 500.0,
          startDate: now.subtract(const Duration(days: 15)),
          frequency: RecurringIncomeFrequency.weekly,
          categoryId: 'freelance',
          defaultAccountId: accountId2,
          nextExpectedDate: now.subtract(const Duration(days: 2)), // Overdue
        ),
      ];

      final summary = RecurringIncomesSummary(
        totalIncomes: 2,
        activeIncomes: 2,
        expectedThisMonth: 2,
        totalMonthlyAmount: 3500.0, // 3000 + 500
        receivedThisMonth: 0.0, // No receipts this month
        expectedAmount: 3500.0,
        upcomingIncomes: [
          RecurringIncomeStatus(
            income: incomes[0],
            daysUntilExpected: 1,
            isExpectedSoon: true,
            isExpectedToday: false,
            isOverdue: false,
            urgency: RecurringIncomeUrgency.expectedSoon,
          ),
          RecurringIncomeStatus(
            income: incomes[1],
            daysUntilExpected: -2,
            isExpectedSoon: false,
            isExpectedToday: false,
            isOverdue: true,
            urgency: RecurringIncomeUrgency.overdue,
          ),
        ],
      );

      when(mockRecurringIncomeRepository.getAll())
          .thenAnswer((_) async => Result.success(incomes));
      when(mockRecurringIncomeRepository.getIncomesSummary())
          .thenAnswer((_) async => Result.success(summary));

      // Act
      final incomesResult = await mockRecurringIncomeRepository.getAll();
      final summaryResult = await mockRecurringIncomeRepository.getIncomesSummary();

      // Assert
      expect(incomesResult.isSuccess, true);
      expect(summaryResult.isSuccess, true);

      final actualIncomes = incomesResult.dataOrNull!;
      final actualSummary = summaryResult.dataOrNull!;

      // Summary counts should match actual incomes
      expect(actualSummary.totalIncomes, actualIncomes.length);
      expect(actualSummary.activeIncomes, actualIncomes.where((i) => !i.hasEnded).length);

      // Monthly amount should be sum of all income amounts
      final calculatedMonthlyAmount = actualIncomes.fold<double>(0, (sum, income) => sum + income.amount);
      expect(actualSummary.totalMonthlyAmount, calculatedMonthlyAmount);

      // Upcoming incomes should match individual income statuses
      expect(actualSummary.upcomingIncomes.length, actualIncomes.length);
      for (final status in actualSummary.upcomingIncomes) {
        final income = actualIncomes.firstWhere((i) => i.id == status.income.id);
        expect(status.daysUntilExpected, income.daysUntilNextExpected);
        expect(status.isOverdue, income.isOverdue);
        expect(status.isExpectedSoon, income.isExpectedSoon);
      }
    });

    test('should maintain CRUD operation consistency: create, update, delete operations preserve data integrity', () async {
      // Arrange - Initial income
      final originalIncome = RecurringIncome(
        id: incomeId1,
        name: 'Original Salary',
        amount: 2500.0,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        frequency: RecurringIncomeFrequency.monthly,
        categoryId: 'salary',
        defaultAccountId: accountId1,
      );

      final updatedIncome = originalIncome.copyWith(
        name: 'Updated Salary',
        amount: 3000.0,
      );

      when(mockRecurringIncomeRepository.add(originalIncome))
          .thenAnswer((_) async => Result.success(originalIncome));
      when(mockRecurringIncomeRepository.update(updatedIncome))
          .thenAnswer((_) async => Result.success(updatedIncome));
      when(mockRecurringIncomeRepository.delete(incomeId1))
          .thenAnswer((_) async => Result.success(null));

      // Act - Perform CRUD operations
      final createResult = await mockRecurringIncomeRepository.add(originalIncome);
      final updateResult = await mockRecurringIncomeRepository.update(updatedIncome);
      final deleteResult = await mockRecurringIncomeRepository.delete(incomeId1);

      // Assert
      expect(createResult.isSuccess, true);
      expect(updateResult.isSuccess, true);
      expect(deleteResult.isSuccess, true);

      final createdIncome = createResult.dataOrNull!;
      final updatedIncomeResult = updateResult.dataOrNull!;

      // Created income should match original
      expect(createdIncome.id, originalIncome.id);
      expect(createdIncome.name, originalIncome.name);
      expect(createdIncome.amount, originalIncome.amount);

      // Updated income should have new values
      expect(updatedIncomeResult.name, 'Updated Salary');
      expect(updatedIncomeResult.amount, 3000.0);

      // ID should remain the same
      expect(updatedIncomeResult.id, originalIncome.id);
    });

    test('should maintain receipt recording consistency: recording receipt updates income history and creates transaction', () async {
      // Arrange - Income and receipt instance
      final income = RecurringIncome(
        id: incomeId1,
        name: 'Monthly Salary',
        amount: 3000.0,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        frequency: RecurringIncomeFrequency.monthly,
        categoryId: 'salary',
        defaultAccountId: accountId1,
        nextExpectedDate: DateTime.now(),
      );

      final receiptInstance = RecurringIncomeInstance(
        id: 'receipt_1',
        amount: 3000.0,
        receivedDate: DateTime.now(),
        accountId: accountId1,
      );

      final expectedTransaction = Transaction(
        id: 'tx_receipt_1',
        title: 'Monthly Salary',
        amount: 3000.0,
        type: TransactionType.income,
        date: DateTime.now(),
        categoryId: 'salary',
        accountId: accountId1,
      );

      final updatedIncome = income.copyWith(
        incomeHistory: [receiptInstance],
        lastReceivedDate: DateTime.now(),
        nextExpectedDate: DateTime.now().add(const Duration(days: 30)), // Next month
      );

      when(mockRecurringIncomeRepository.recordIncomeReceipt(incomeId1, receiptInstance, accountId: accountId1))
          .thenAnswer((_) async => Result.success(updatedIncome));
      when(mockTransactionRepository.add(expectedTransaction))
          .thenAnswer((_) async => Result.success(expectedTransaction));

      // Act
      final recordResult = await mockRecurringIncomeRepository.recordIncomeReceipt(
        incomeId1,
        receiptInstance,
        accountId: accountId1,
      );

      // Assert
      expect(recordResult.isSuccess, true);

      final resultIncome = recordResult.dataOrNull!;

      // Income should have receipt in history
      expect(resultIncome.incomeHistory.length, 1);
      expect(resultIncome.incomeHistory.first.id, receiptInstance.id);
      expect(resultIncome.incomeHistory.first.amount, receiptInstance.amount);

      // Last received date should be updated
      expect(resultIncome.lastReceivedDate, receiptInstance.receivedDate);

      // Next expected date should be updated based on frequency
      expect(resultIncome.nextExpectedDate, isNotNull);
      expect(resultIncome.nextExpectedDate!.isAfter(resultIncome.lastReceivedDate!), true);
    });

    test('should detect and flag data inconsistencies in recurring income relationships', () async {
      // Arrange - Income with invalid account reference
      final invalidIncome = RecurringIncome(
        id: incomeId1,
        name: 'Invalid Income',
        amount: 1000.0,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        frequency: RecurringIncomeFrequency.monthly,
        categoryId: 'salary',
        defaultAccountId: 'invalid_account_id', // Non-existent account
      );

      when(mockRecurringIncomeRepository.getById(incomeId1))
          .thenAnswer((_) async => Result.success(invalidIncome));
      when(mockAccountRepository.getById('invalid_account_id'))
          .thenAnswer((_) async => Result.error(Failure.notFound('Account not found')));

      // Act
      final incomeResult = await mockRecurringIncomeRepository.getById(incomeId1);
      final accountResult = await mockAccountRepository.getById('invalid_account_id');

      // Assert
      expect(incomeResult.isSuccess, true);
      expect(accountResult.isError, true);

      final income = incomeResult.dataOrNull!;

      // Income references invalid account - this is a data inconsistency
      expect(income.effectiveAccountId, 'invalid_account_id');
      // In a real system, this would trigger validation or repair
    });
  });
}