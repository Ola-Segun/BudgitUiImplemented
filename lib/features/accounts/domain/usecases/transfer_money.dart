import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/usecases/add_transaction.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

/// Use case for transferring money between accounts
/// This is a specialized use case that wraps the AddTransaction use case
/// with transfer-specific validation and logic
class TransferMoney {
  const TransferMoney(
    this._accountRepository,
    this._addTransaction,
  );

  final AccountRepository _accountRepository;
  final AddTransaction _addTransaction;

  /// Execute the transfer money use case
  Future<Result<Transaction>> call({
    required Account sourceAccount,
    required Account destinationAccount,
    required double amount,
    double? fee,
    String? description,
  }) async {
    try {
      // Validate transfer parameters
      final validationResult = _validateTransfer(
        sourceAccount,
        destinationAccount,
        amount,
        fee,
      );
      if (validationResult.isError) {
        return Result.error(validationResult.failureOrNull!);
      }

      // Create transfer transaction
      final transferTransaction = Transaction(
        id: 'transfer_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Transfer to ${destinationAccount.name}',
        amount: amount,
        type: TransactionType.transfer,
        date: DateTime.now(),
        categoryId: 'transfer', // Assuming transfer category exists
        accountId: sourceAccount.id,
        toAccountId: destinationAccount.id,
        transferFee: fee != null && fee > 0 ? fee : null,
        description: description,
      );

      // Use AddTransaction use case to handle the transfer
      // This will validate funds and update both accounts atomically
      return await _addTransaction(transferTransaction);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to transfer money: $e'));
    }
  }

  /// Validate transfer parameters
  Result<void> _validateTransfer(
    Account sourceAccount,
    Account destinationAccount,
    double amount,
    double? fee,
  ) {
    // Basic validation
    if (amount <= 0) {
      return Result.error(Failure.validation(
        'Transfer amount must be greater than zero',
        {'amount': 'Invalid amount'},
      ));
    }

    // Check if accounts are different
    if (sourceAccount.id == destinationAccount.id) {
      return Result.error(Failure.validation(
        'Cannot transfer to the same account',
        {'destinationAccount': 'Source and destination must be different'},
      ));
    }

    // Check if source account has sufficient funds
    final requiredAmount = amount + (fee ?? 0);
    if (sourceAccount.currentBalance < requiredAmount) {
      return Result.error(Failure.validation(
        'Insufficient balance in ${sourceAccount.name}. Available: \$${sourceAccount.currentBalance.toStringAsFixed(2)}, Required: \$${requiredAmount.toStringAsFixed(2)}',
        {'balance': 'Insufficient funds'},
      ));
    }

    // Validate fee if provided
    if (fee != null && fee < 0) {
      return Result.error(Failure.validation(
        'Transfer fee cannot be negative',
        {'fee': 'Invalid fee'},
      ));
    }

    return Result.success(null);
  }
}