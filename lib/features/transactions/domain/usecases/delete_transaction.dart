import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../bills/domain/entities/bill.dart';
import '../../../bills/domain/repositories/bill_repository.dart';
import '../../../recurring_incomes/domain/entities/recurring_income.dart';
import '../../../recurring_incomes/domain/repositories/recurring_income_repository.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case for deleting a transaction with balance rollback
/// Follows the Transaction Deletion (Rollback) pattern from Account-Transaction-Relationship.md
/// Also handles bidirectional relationship updates for income/bill transactions
class DeleteTransaction {
  const DeleteTransaction(
    this._transactionRepository,
    this._accountRepository,
    this._billRepository,
    this._recurringIncomeRepository,
  );

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final BillRepository _billRepository;
  final RecurringIncomeRepository _recurringIncomeRepository;

  /// Execute the use case with balance rollback
  Future<Result<void>> call(String transactionId) async {
    try {
      // 1. Retrieve transaction details BEFORE deletion
      final existingResult = await _transactionRepository.getById(transactionId);
      if (existingResult.isError) {
        return existingResult.map((_) {}); // Return error
      }

      final transaction = existingResult.dataOrNull;
      if (transaction == null) {
        return Result.error(Failure.validation(
          'Transaction not found',
          {'id': 'Transaction with this ID does not exist'},
        ));
      }

      // 2. Handle bidirectional relationship updates BEFORE transaction deletion
      final relationshipResult = await _handleRelationshipUpdates(transaction);
      if (relationshipResult.isError) {
        return relationshipResult;
      }

      // 3. Delete transaction from repository
      final deleteResult = await _transactionRepository.delete(transactionId);
      if (deleteResult.isError) {
        return deleteResult;
      }

      // 4. Immediately rollback account balance (reverse the transaction's impact)
      final rollbackResult = await _rollbackAccountBalance(transaction);
      if (rollbackResult.isError) {
        // If balance rollback fails, we should ideally rollback the transaction deletion
        // For now, log the error but return success since transaction was deleted
        // In production, implement proper transaction rollback
        return Result.error(rollbackResult.failureOrNull!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to delete transaction: $e'));
    }
  }

  /// Handle bidirectional relationship updates for income/bill transactions
  /// When a transaction is deleted, update the corresponding income/bill records
  Future<Result<void>> _handleRelationshipUpdates(Transaction transaction) async {
    try {
      // Check if this is an income transaction (created by recurring income)
      if (transaction.isIncome && transaction.title?.contains('Income') == true) {
        final incomeResult = await _updateIncomeOnTransactionDeletion(transaction);
        if (incomeResult.isError) {
          return incomeResult;
        }
      }
      // Check if this is a bill payment transaction (created by bill payment)
      else if (!transaction.isIncome && transaction.title?.contains('Payment') == true) {
        final billResult = await _updateBillOnTransactionDeletion(transaction);
        if (billResult.isError) {
          return billResult;
        }
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to handle relationship updates: $e'));
    }
  }

  /// Update recurring income when its transaction is deleted
  Future<Result<void>> _updateIncomeOnTransactionDeletion(Transaction transaction) async {
    try {
      // Find the income that created this transaction
      final incomesResult = await _recurringIncomeRepository.getAll();
      if (incomesResult.isError) {
        return Result.error(incomesResult.failureOrNull!);
      }

      final incomes = incomesResult.dataOrNull ?? [];
      RecurringIncome? matchingIncome;

      // Find income by matching transaction details
      for (final income in incomes) {
        final hasMatchingInstance = income.incomeHistory.any((instance) =>
          instance.transactionId == transaction.id ||
          (instance.amount == transaction.amount &&
           instance.receivedDate.year == transaction.date.year &&
           instance.receivedDate.month == transaction.date.month &&
           instance.receivedDate.day == transaction.date.day)
        );

        if (hasMatchingInstance) {
          matchingIncome = income;
          break;
        }
      }

      if (matchingIncome == null) {
        // Transaction might not be linked to income, skip
        return Result.success(null);
      }

      // Remove the transaction reference from income history
      final updatedHistory = matchingIncome.incomeHistory
          .where((instance) => instance.transactionId != transaction.id)
          .toList();

      // Update last received date if needed
      DateTime? newLastReceivedDate;
      if (updatedHistory.isNotEmpty) {
        newLastReceivedDate = updatedHistory
            .map((i) => i.receivedDate)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }

      final updatedIncome = matchingIncome.copyWith(
        incomeHistory: updatedHistory,
        lastReceivedDate: newLastReceivedDate,
      );

      final updateResult = await _recurringIncomeRepository.update(updatedIncome);
      return updateResult.when(
        success: (_) => Result.success(null),
        error: (failure) => Result.error(failure),
      );
    } catch (e) {
      return Result.error(Failure.unknown('Failed to update income on transaction deletion: $e'));
    }
  }

  /// Update bill when its payment transaction is deleted
  Future<Result<void>> _updateBillOnTransactionDeletion(Transaction transaction) async {
    try {
      // Find the bill that created this transaction
      final billsResult = await _billRepository.getAll();
      if (billsResult.isError) {
        return Result.error(billsResult.failureOrNull!);
      }

      final bills = billsResult.dataOrNull ?? [];
      Bill? matchingBill;

      // Find bill by matching transaction details
      for (final bill in bills) {
        final hasMatchingPayment = bill.paymentHistory.any((payment) =>
          payment.transactionId == transaction.id ||
          (payment.amount == transaction.amount &&
           payment.paymentDate.year == transaction.date.year &&
           payment.paymentDate.month == transaction.date.month &&
           payment.paymentDate.day == transaction.date.day)
        );

        if (hasMatchingPayment) {
          matchingBill = bill;
          break;
        }
      }

      if (matchingBill == null) {
        // Transaction might not be linked to bill, skip
        return Result.success(null);
      }

      // Remove the transaction reference from payment history
      final updatedHistory = matchingBill.paymentHistory
          .where((payment) => payment.transactionId != transaction.id)
          .toList();

      // Update bill status based on remaining payments
      final totalPaid = updatedHistory.fold<double>(0, (sum, payment) => sum + payment.amount);
      final isPaid = totalPaid >= matchingBill.amount;

      DateTime? newLastPaidDate;
      if (updatedHistory.isNotEmpty) {
        newLastPaidDate = updatedHistory
            .map((p) => p.paymentDate)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }

      final updatedBill = matchingBill.copyWith(
        paymentHistory: updatedHistory,
        isPaid: isPaid,
        lastPaidDate: newLastPaidDate,
      );

      final updateResult = await _billRepository.update(updatedBill);
      return updateResult.when(
        success: (_) => Result.success(null),
        error: (failure) => Result.error(failure),
      );
    } catch (e) {
      return Result.error(Failure.unknown('Failed to update bill on transaction deletion: $e'));
    }
  }

  /// Rollback account balance by reversing transaction impact
  /// For income: decrease account balance
  /// For expense: increase account balance
  /// For transfers: reverse both source and destination account updates (not implemented)
  Future<Result<void>> _rollbackAccountBalance(Transaction transaction) async {
    if (transaction.accountId == null) {
      // Skip balance rollback for transactions without account (shouldn't happen for regular transactions)
      return Result.success(null);
    }

    final accountResult = await _accountRepository.getById(transaction.accountId!);

    return accountResult.when(
      success: (account) async {
        if (account == null) {
          return Result.error(Failure.validation(
            'Account not found for balance rollback',
            {'account': 'Account does not exist'},
          ));
        }

        // Calculate balance delta for rollback (reverse of addition)
        // For income: transaction added money, so rollback decreases balance
        // For expense: transaction subtracted money, so rollback increases balance
        final delta = transaction.isIncome ? -transaction.amount : transaction.amount;

        // Update cached balance and timestamp
        final updatedAccount = account.copyWith(
          cachedBalance: account.currentBalance + delta,
          lastBalanceUpdate: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updateResult = await _accountRepository.update(updatedAccount);
        return updateResult.when(
          success: (_) => Result.success(null),
          error: (failure) => Result.error(failure),
        );
      },
      error: (failure) => Result.error(failure),
    );
  }
}