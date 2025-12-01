import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction.dart' as tx show TransactionCategory;
import '../../../accounts/domain/entities/account.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../../../goals/domain/entities/goal.dart';
import 'import_error.dart';

part 'import_result.freezed.dart';

/// Result of an import operation
@freezed
class ImportResult with _$ImportResult {
  const factory ImportResult({
    required List<Transaction> transactions,
    required List<tx.TransactionCategory> categories,
    required List<Account> accounts,
    required List<Budget> budgets,
    required List<Goal> goals,
    required List<ImportError> errors,
    required ImportSummary summary,
  }) = _ImportResult;

  const ImportResult._();

  /// Create an empty result
  factory ImportResult.empty() => ImportResult(
        transactions: [],
        categories: [],
        accounts: [],
        budgets: [],
        goals: [],
        errors: [],
        summary: const ImportSummary(),
      );

  /// Get total number of items imported
  int get totalItems =>
      transactions.length +
      categories.length +
      accounts.length +
      budgets.length +
      goals.length;

  /// Check if import was successful (no errors or only warnings)
  bool get isSuccessful => !hasErrors;

  /// Check if there are any errors
  bool get hasErrors => errors.any((error) => error.type.isError);

  /// Check if there are any warnings
  bool get hasWarnings => errors.any((error) => error.type.isWarning);

  /// Get only error-type errors
  List<ImportError> get errorErrors => errors.where((error) => error.type.isError).toList();

  /// Get only warning-type errors
  List<ImportError> get warningErrors => errors.where((error) => error.type.isWarning).toList();
}

/// Summary of import operation
@freezed
class ImportSummary with _$ImportSummary {
  const factory ImportSummary({
    @Default(0) int transactionsImported,
    @Default(0) int categoriesImported,
    @Default(0) int accountsImported,
    @Default(0) int budgetsImported,
    @Default(0) int goalsImported,
    @Default(0) int transactionsSkipped,
    @Default(0) int categoriesSkipped,
    @Default(0) int accountsSkipped,
    @Default(0) int budgetsSkipped,
    @Default(0) int goalsSkipped,
    @Default(0) int errors,
    @Default(0) int warnings,
  }) = _ImportSummary;

  const ImportSummary._();

  /// Get total items processed
  int get totalProcessed =>
      transactionsImported + categoriesImported + accountsImported + budgetsImported + goalsImported +
      transactionsSkipped + categoriesSkipped + accountsSkipped + budgetsSkipped + goalsSkipped;

  /// Get total items successfully imported
  int get totalImported =>
      transactionsImported + categoriesImported + accountsImported + budgetsImported + goalsImported;

  /// Get total items skipped
  int get totalSkipped =>
      transactionsSkipped + categoriesSkipped + accountsSkipped + budgetsSkipped + goalsSkipped;
}