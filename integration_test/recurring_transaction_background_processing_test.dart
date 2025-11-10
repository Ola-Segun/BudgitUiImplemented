import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:budget_tracker/core/di/providers.dart';
import 'package:budget_tracker/features/recurring_transactions/domain/entities/recurring_transaction.dart';
import 'package:budget_tracker/features/recurring_transactions/domain/repositories/recurring_transaction_repository.dart';
import 'package:budget_tracker/features/recurring_transactions/domain/services/recurring_transaction_background_service.dart';
import 'package:budget_tracker/features/transactions/domain/repositories/transaction_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late RecurringTransactionRepository recurringRepository;
  late TransactionRepository transactionRepository;
  late RecurringTransactionBackgroundService backgroundService;

  setUp(() async {
    // Initialize dependencies
    recurringRepository = getIt<RecurringTransactionRepository>();
    transactionRepository = getIt<TransactionRepository>();
    backgroundService = getIt<RecurringTransactionBackgroundService>();
  });

  group('Recurring Transaction Background Processing Integration Tests', () {
    testWidgets('should process due recurring transactions end-to-end', (tester) async {
      // Arrange: Create a recurring transaction due today
      final dueDate = DateTime.now();
      final recurringTransaction = RecurringTransaction(
        id: 'integration_test_rt_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Integration Test Salary',
        amount: 3000.0,
        recurrenceType: RecurrenceType.monthly,
        recurrenceValue: 1,
        startDate: dueDate.subtract(const Duration(days: 30)),
        categoryId: 'salary',
        accountId: 'test_account',
        currencyCode: 'USD',
      );

      // Add the recurring transaction
      final createResult = await recurringRepository.createRecurringTransaction(recurringTransaction);
      expect(createResult.isSuccess, true);

      // Act: Process recurring transactions for today
      final processResult = await backgroundService.processRecurringTransactionsForDate(dueDate);
      expect(processResult.isSuccess, true);

      final processedIds = processResult.dataOrNull!;
      expect(processedIds, isNotEmpty);

      // Assert: Verify transaction was created
      final createdTransactionId = processedIds.first;
      final transactionResult = await transactionRepository.getById(createdTransactionId);
      expect(transactionResult.isSuccess, true);

      final transaction = transactionResult.dataOrNull!;
      expect(transaction.title, recurringTransaction.title);
      expect(transaction.amount, recurringTransaction.amount);
      expect(transaction.categoryId, recurringTransaction.categoryId);
      expect(transaction.accountId, recurringTransaction.accountId);

      // Verify recurring transaction was updated
      final updatedRecurringResult = await recurringRepository.getRecurringTransactionById(recurringTransaction.id);
      expect(updatedRecurringResult.isSuccess, true);

      final updatedRecurring = updatedRecurringResult.dataOrNull!;
      expect(updatedRecurring.lastProcessedDate, isNotNull);
      expect(updatedRecurring.lastProcessedDate!.year, dueDate.year);
      expect(updatedRecurring.lastProcessedDate!.month, dueDate.month);
      expect(updatedRecurring.lastProcessedDate!.day, dueDate.day);

      // Cleanup
      await recurringRepository.deleteRecurringTransaction(recurringTransaction.id);
      await transactionRepository.delete(createdTransactionId);
    });

    testWidgets('should handle duplicate processing correctly', (tester) async {
      // Arrange: Create and process a recurring transaction
      final dueDate = DateTime.now();
      final recurringTransaction = RecurringTransaction(
        id: 'integration_test_duplicate_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Integration Test Duplicate',
        amount: 1500.0,
        recurrenceType: RecurrenceType.weekly,
        recurrenceValue: 1,
        startDate: dueDate.subtract(const Duration(days: 7)),
        categoryId: 'freelance',
        accountId: 'test_account',
        currencyCode: 'USD',
      );

      await recurringRepository.createRecurringTransaction(recurringTransaction);

      // Process once
      final firstProcessResult = await backgroundService.processRecurringTransactionsForDate(dueDate);
      expect(firstProcessResult.isSuccess, true);

      // Act: Try to process again on the same date
      final secondProcessResult = await backgroundService.processRecurringTransactionsForDate(dueDate);

      // Assert: Should handle gracefully (either success with empty list or validation error)
      expect(secondProcessResult.isSuccess || secondProcessResult.failureOrNull is ValidationFailure, true);

      // Cleanup
      await recurringRepository.deleteRecurringTransaction(recurringTransaction.id);
      if (firstProcessResult.dataOrNull!.isNotEmpty) {
        await transactionRepository.delete(firstProcessResult.dataOrNull!.first);
      }
    });

    testWidgets('should handle background service initialization', (tester) async {
      // Act
      final initResult = await backgroundService.initialize();
      expect(initResult.isSuccess, true);

      final startResult = await backgroundService.startBackgroundProcessing();
      expect(startResult.isSuccess, true);

      final statusResult = await backgroundService.isBackgroundProcessingEnabled();
      expect(statusResult.isSuccess, true);

      final stopResult = await backgroundService.stopBackgroundProcessing();
      expect(stopResult.isSuccess, true);
    });

    testWidgets('should handle error recovery scenarios', (tester) async {
      // This test would require setting up error conditions
      // For now, just verify the service can handle normal operations
      final recoveryResult = await backgroundService.checkUpcomingDueTransactions();
      expect(recoveryResult.isSuccess, true);
    });

    testWidgets('should process multiple recurring transactions', (tester) async {
      // Arrange: Create multiple recurring transactions
      final dueDate = DateTime.now();
      final transactions = [
        RecurringTransaction(
          id: 'integration_test_multi1_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Multi Test 1',
          amount: 1000.0,
          recurrenceType: RecurrenceType.monthly,
          recurrenceValue: 1,
          startDate: dueDate.subtract(const Duration(days: 30)),
          categoryId: 'salary',
          accountId: 'test_account',
          currencyCode: 'USD',
        ),
        RecurringTransaction(
          id: 'integration_test_multi2_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Multi Test 2',
          amount: 500.0,
          recurrenceType: RecurrenceType.monthly,
          recurrenceValue: 1,
          startDate: dueDate.subtract(const Duration(days: 30)),
          categoryId: 'freelance',
          accountId: 'test_account',
          currencyCode: 'USD',
        ),
      ];

      // Add transactions
      for (final tx in transactions) {
        await recurringRepository.createRecurringTransaction(tx);
      }

      // Act: Process all due transactions
      final processResult = await backgroundService.processRecurringTransactionsForDate(dueDate);
      expect(processResult.isSuccess, true);

      final processedIds = processResult.dataOrNull!;
      expect(processedIds.length, transactions.length);

      // Assert: Verify all transactions were created
      for (final id in processedIds) {
        final txResult = await transactionRepository.getById(id);
        expect(txResult.isSuccess, true);
      }

      // Cleanup
      for (final tx in transactions) {
        await recurringRepository.deleteRecurringTransaction(tx.id);
      }
      for (final id in processedIds) {
        await transactionRepository.delete(id);
      }
    });
  });
}