import 'package:freezed_annotation/freezed_annotation.dart';

import 'transaction.dart';

part 'split_transaction.freezed.dart';

/// Represents a single split within a transaction
@freezed
class TransactionSplit with _$TransactionSplit {
  const factory TransactionSplit({
    required String categoryId,
    required double amount,
    required double percentage,
    String? description,
  }) = _TransactionSplit;

  const TransactionSplit._();

  /// Create a split from amount and total
  factory TransactionSplit.fromAmount({
    required String categoryId,
    required double amount,
    required double totalAmount,
    String? description,
  }) {
    final percentage = totalAmount > 0 ? (amount / totalAmount) * 100.0 : 0.0;
    return TransactionSplit(
      categoryId: categoryId,
      amount: amount,
      percentage: percentage,
      description: description,
    );
  }

  /// Create a split from percentage and total
  factory TransactionSplit.fromPercentage({
    required String categoryId,
    required double percentage,
    required double totalAmount,
    String? description,
  }) {
    final amount = (percentage / 100.0) * totalAmount;
    return TransactionSplit(
      categoryId: categoryId,
      amount: amount,
      percentage: percentage,
      description: description,
    );
  }
}

/// Represents a transaction that can be split across multiple categories
@freezed
class SplitTransaction with _$SplitTransaction {
  const factory SplitTransaction({
    required String id,
    required String title,
    required double totalAmount,
    required TransactionType type,
    required DateTime date,
    required String accountId,
    required List<TransactionSplit> splits,
    String? description,
    String? receiptUrl,
    @Default([]) List<String> tags,
    String? currencyCode,
  }) = _SplitTransaction;

  const SplitTransaction._();

  /// Check if transaction is income
  bool get isIncome => type == TransactionType.income;

  /// Check if transaction is expense
  bool get isExpense => type == TransactionType.expense;

  /// Check if this is actually a split transaction (has multiple splits)
  bool get isSplit => splits.length > 1;

  /// Get the effective amount for balance calculations
  double get effectiveAmount {
    switch (type) {
      case TransactionType.income:
        return totalAmount;
      case TransactionType.expense:
        return -totalAmount;
      case TransactionType.transfer:
        return -totalAmount; // Transfers not supported in splits for now
    }
  }

  /// Validate that splits sum to total amount
  bool get isValid => _validateSplits();

  bool _validateSplits() {
    if (splits.isEmpty) return false;
    final sum = splits.fold<double>(0.0, (sum, split) => sum + split.amount);
    return (sum - totalAmount).abs() < 0.01; // Allow for small floating point errors
  }

  /// Get formatted amount with sign
  String get signedAmount => isIncome
      ? '+${currencyCode ?? 'USD'} ${totalAmount.toStringAsFixed(2)}'
      : '-${currencyCode ?? 'USD'} ${totalAmount.toStringAsFixed(2)}';

  /// Get absolute amount
  double get absoluteAmount => totalAmount.abs();
}