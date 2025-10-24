import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case for updating an existing transaction with balance recalculation
/// Follows the Transaction Update (Recalculation) pattern from Account-Transaction-Relationship.md
class UpdateTransaction {
  const UpdateTransaction(
    this._transactionRepository,
    this._accountRepository,
  );

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;

  /// Execute the use case with balance recalculation
  Future<Result<Transaction>> call(Transaction transaction) async {
    try {
      // 1. Validate transaction exists and get original
      final existingResult = await _transactionRepository.getById(transaction.id);
      if (existingResult.isError) {
        return existingResult.map((_) => transaction); // Return error
      }

      final originalTransaction = existingResult.dataOrNull;
      if (originalTransaction == null) {
        return Result.error(Failure.validation(
          'Transaction not found',
          {'id': 'Transaction with this ID does not exist'},
        ));
      }

      // 2. Validate updated transaction data
      final validationResult = _validateTransaction(transaction);
      if (validationResult.isError) {
        return validationResult;
      }

      // 3. Check account balance for expenses and transfers (insufficient funds validation)
      if (transaction.isExpense || transaction.isTransfer) {
        final balanceCheck = await _checkSufficientFunds(transaction, originalTransaction);
        if (balanceCheck.isError) {
          return Result.error(balanceCheck.failureOrNull!);
        }
      }

      // 4. Update transaction in repository
      final updateResult = await _transactionRepository.update(transaction);
      if (updateResult.isError) {
        return updateResult;
      }

      // 5. Recalculate account balances (rollback original + apply new)
      final balanceUpdateResult = await _recalculateAccountBalances(originalTransaction, transaction);
      if (balanceUpdateResult.isError) {
        // If balance update fails, we should ideally rollback the transaction update
        // For now, log the error but return success since transaction was updated
        // In production, implement proper transaction rollback
        return Result.error(balanceUpdateResult.failureOrNull!);
      }

      return updateResult;
    } catch (e) {
      return Result.error(Failure.unknown('Failed to update transaction: $e'));
    }
  }

  /// Validate transaction data
  Result<Transaction> _validateTransaction(Transaction transaction) {
    if (transaction.title.trim().isEmpty) {
      return Result.error(Failure.validation(
        'Transaction title cannot be empty',
        {'title': 'Title is required'},
      ));
    }

    if (transaction.amount <= 0) {
      return Result.error(Failure.validation(
        'Transaction amount must be greater than zero',
        {'amount': 'Amount must be positive'},
      ));
    }

    if (transaction.accountId == null || transaction.accountId!.trim().isEmpty) {
      return Result.error(Failure.validation(
        'Transaction account is required',
        {'accountId': 'Account is required'},
      ));
    }

    if (transaction.categoryId.trim().isEmpty) {
      return Result.error(Failure.validation(
        'Transaction category is required',
        {'categoryId': 'Category is required'},
      ));
    }

    if (transaction.date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return Result.error(Failure.validation(
        'Transaction date cannot be in the future',
        {'date': 'Date cannot be in the future'},
      ));
    }

    // Transfer-specific validation
    if (transaction.type == TransactionType.transfer) {
      if (transaction.accountId == null) {
        return Result.error(Failure.validation(
          'Transfer must have a source account',
          {'accountId': 'Source account is required for transfers'},
        ));
      }

      if (transaction.toAccountId == null) {
        return Result.error(Failure.validation(
          'Transfer must have a destination account',
          {'toAccountId': 'Destination account is required for transfers'},
        ));
      }

      if (transaction.accountId == transaction.toAccountId) {
        return Result.error(Failure.validation(
          'Cannot transfer to the same account',
          {'toAccountId': 'Source and destination accounts must be different'},
        ));
      }
    }

    return Result.success(transaction);
  }

  /// Check if account has sufficient funds for expense transactions
  /// Takes into account the original transaction's impact when calculating available balance
  Future<Result<void>> _checkSufficientFunds(Transaction newTransaction, Transaction originalTransaction) async {
    final accountResult = await _accountRepository.getById(newTransaction.accountId!);

    return accountResult.when(
      success: (account) {
        if (account == null) {
          return Result.error(Failure.validation(
            'Account not found',
            {'account': 'Account does not exist'},
          ));
        }

        // Calculate current available balance considering the original transaction's impact
        // We need to "undo" the original transaction's impact first, then check if new transaction is valid
        final originalImpact = originalTransaction.effectiveAmount;
        final availableBalance = account.currentBalance - originalImpact;

        // For transfers, check amount + fee
        final requiredAmount = newTransaction.isTransfer
            ? newTransaction.amount + (newTransaction.transferFee ?? 0)
            : newTransaction.amount;

        if (availableBalance < requiredAmount) {
          return Result.error(Failure.validation(
            'Insufficient balance in ${account.name}. Available: \$${availableBalance.toStringAsFixed(2)}, Required: \$${requiredAmount.toStringAsFixed(2)}',
            {'balance': 'Insufficient funds'},
          ));
        }

        return Result.success(null);
      },
      error: (failure) => Result.error(failure),
    );
  }

  /// Recalculate account balances after transaction update
  /// Step 1: Rollback original transaction's impact
  /// Step 2: Apply new transaction's impact
  Future<Result<void>> _recalculateAccountBalances(Transaction originalTransaction, Transaction newTransaction) async {
    // Handle transfers (update both source and destination accounts)
    if (originalTransaction.isTransfer || newTransaction.isTransfer) {
      return await _recalculateTransferBalances(originalTransaction, newTransaction);
    }

    // Handle regular transactions (income/expense)
    final accountResult = await _accountRepository.getById(newTransaction.accountId!);

    return accountResult.when(
      success: (account) async {
        if (account == null) {
          return Result.error(Failure.validation(
            'Account not found for balance update',
            {'account': 'Account does not exist'},
          ));
        }

        // Calculate net balance change: rollback original + apply new
        final originalDelta = originalTransaction.effectiveAmount;
        final newDelta = newTransaction.effectiveAmount;
        final netDelta = newDelta - originalDelta;

        // Update cached balance and timestamp
        final updatedAccount = account.copyWith(
          cachedBalance: account.currentBalance + netDelta,
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

  /// Recalculate balances for transfer transactions (both source and destination)
  Future<Result<void>> _recalculateTransferBalances(Transaction originalTransaction, Transaction newTransaction) async {
    // Determine all accounts involved (original and new)
    final accountsToUpdate = <String>{};

    if (originalTransaction.accountId != null) accountsToUpdate.add(originalTransaction.accountId!);
    if (originalTransaction.toAccountId != null) accountsToUpdate.add(originalTransaction.toAccountId!);
    if (newTransaction.accountId != null) accountsToUpdate.add(newTransaction.accountId!);
    if (newTransaction.toAccountId != null) accountsToUpdate.add(newTransaction.toAccountId!);

    // Update each account
    for (final accountId in accountsToUpdate) {
      final accountResult = await _accountRepository.getById(accountId);
      if (accountResult.isError) {
        return Result.error(accountResult.failureOrNull!);
      }

      final account = accountResult.dataOrNull!;

      // Calculate net impact on this account
      final originalImpact = _calculateAccountImpact(originalTransaction, accountId);
      final newImpact = _calculateAccountImpact(newTransaction, accountId);
      final netDelta = newImpact - originalImpact;

      if (netDelta != 0) {
        final updatedAccount = account.copyWith(
          cachedBalance: account.currentBalance + netDelta,
          lastBalanceUpdate: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updateResult = await _accountRepository.update(updatedAccount);
        if (updateResult.isError) {
          return Result.error(updateResult.failureOrNull!);
        }
      }
    }

    return Result.success(null);
  }

  /// Calculate the impact of a transaction on a specific account
  double _calculateAccountImpact(Transaction transaction, String accountId) {
    if (transaction.accountId == accountId) {
      // This account is the source of the transaction
      return transaction.effectiveAmount;
    } else if (transaction.toAccountId == accountId && transaction.isTransfer) {
      // This account is the destination of a transfer
      return transaction.amount; // Destination receives the amount (no fee)
    }
    return 0.0; // No impact on this account
  }
}