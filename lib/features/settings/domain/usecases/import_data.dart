import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction.dart' as tx show TransactionCategory;
import '../../../budgets/domain/entities/budget.dart';
import '../../../goals/domain/entities/goal.dart';
import '../entities/import_result.dart';
import '../entities/import_error.dart';
import '../services/data_import_service.dart';

/// Use case for importing data from files
class ImportData {
  const ImportData(
    this._importService,
    this._transactionRepository,
    this._categoryRepository,
    this._accountRepository,
    this._budgetRepository,
    this._goalRepository,
  );

  final DataImportService _importService;
  final dynamic _transactionRepository; // Will be injected
  final dynamic _categoryRepository;
  final dynamic _accountRepository;
  final dynamic _budgetRepository;
  final dynamic _goalRepository;

  /// Import data from a file with the given options
  Future<Result<ImportResult>> call(
    File file, {
    required ImportOptions options,
  }) async {
    try {
      // Parse the file
      final parseResult = await _importService.importFromFile(file, options: options);

      return parseResult.fold(
        (error) => Result.error(Failure.unknown(error.message)),
        (importResult) async {
          // If parsing failed, return the error
          if (!importResult.isSuccessful && !options.skipErrors) {
            final firstError = importResult.errorErrors.first;
            return Result.error(Failure.unknown(firstError.message));
          }

          // Import the data to repositories
          final importResultWithData = await _importToRepositories(importResult, options);

          return Result.success(importResultWithData);
        },
      );
    } catch (e) {
      return Result.error(Failure.unknown('Import failed: ${e.toString()}'));
    }
  }

  /// Import parsed data to all repositories
  Future<ImportResult> _importToRepositories(
    ImportResult importResult,
    ImportOptions options,
  ) async {
    final importedTransactions = <Transaction>[];
    final importedCategories = <TransactionCategory>[];
    final importedAccounts = <Account>[];
    final importedBudgets = <Budget>[];
    final importedGoals = <Goal>[];
    final allErrors = <ImportError>[...importResult.errors];

    // Import in order: accounts -> categories -> transactions -> budgets -> goals
    // This ensures dependencies are met

    try {
      // Import accounts first
      if (importResult.accounts.isNotEmpty) {
        final accountResult = await _importAccounts(importResult.accounts, options);
        importedAccounts.addAll(accountResult.imported);
        allErrors.addAll(accountResult.errors);
      }

      // Import categories
      if (importResult.categories.isNotEmpty) {
        final categoryResult = await _importCategories(importResult.categories, options);
        importedCategories.addAll(categoryResult.imported);
        allErrors.addAll(categoryResult.errors);
      }

      // Import transactions
      if (importResult.transactions.isNotEmpty) {
        final transactionResult = await _importTransactions(importResult.transactions, options);
        importedTransactions.addAll(transactionResult.imported);
        allErrors.addAll(transactionResult.errors);
      }

      // Import budgets
      if (importResult.budgets.isNotEmpty) {
        final budgetResult = await _importBudgets(importResult.budgets, options);
        importedBudgets.addAll(budgetResult.imported);
        allErrors.addAll(budgetResult.errors);
      }

      // Import goals
      if (importResult.goals.isNotEmpty) {
        final goalResult = await _importGoals(importResult.goals, options);
        importedGoals.addAll(goalResult.imported);
        allErrors.addAll(goalResult.errors);
      }

      return ImportResult(
        transactions: importedTransactions,
        categories: importedCategories,
        accounts: importedAccounts,
        budgets: importedBudgets,
        goals: importedGoals,
        errors: allErrors,
        summary: ImportSummary(
          transactionsImported: importedTransactions.length,
          categoriesImported: importedCategories.length,
          accountsImported: importedAccounts.length,
          budgetsImported: importedBudgets.length,
          goalsImported: importedGoals.length,
          transactionsSkipped: importResult.transactions.length - importedTransactions.length,
          categoriesSkipped: importResult.categories.length - importedCategories.length,
          accountsSkipped: importResult.accounts.length - importedAccounts.length,
          budgetsSkipped: importResult.budgets.length - importedBudgets.length,
          goalsSkipped: importResult.goals.length - importedGoals.length,
          errors: allErrors.where((e) => e.type.isError).length,
          warnings: allErrors.where((e) => e.type.isWarning).length,
        ),
      );
    } catch (e) {
      // If rollback is enabled and we have errors, we should rollback
      if (options.rollbackOnError && allErrors.isNotEmpty) {
        await _rollbackImport(ImportResult(
          transactions: importedTransactions,
          categories: importedCategories,
          accounts: importedAccounts,
          budgets: importedBudgets,
          goals: importedGoals,
          errors: allErrors,
          summary: ImportSummary(),
        ));
      }
      rethrow;
    }
  }

  /// Import accounts to repository
  Future<ImportBatchResult<Account>> _importAccounts(
    List<Account> accounts,
    ImportOptions options,
  ) async {
    final imported = <Account>[];
    final skipped = <Account>[];
    final errors = <ImportError>[];

    for (final account in accounts) {
      try {
        // Check for conflicts
        final conflictResult = await _checkAccountConflict(account, options);
        if (conflictResult.isSome()) {
          final conflict = conflictResult.getOrElse(() => throw 'Unexpected error');
          if (options.updateExisting) {
            // Update existing account
            final updateResult = await _accountRepository.updateAccount(account);
            updateResult.fold(
              (failure) => errors.add(ImportError.conflict(
                message: 'Failed to update account: ${failure.message}',
                lineNumber: 0,
                field: 'id',
                existingValue: 'existing',
                newValue: account.id,
              )),
              (_) => imported.add(account),
            );
          } else {
            skipped.add(account);
            errors.add(conflict);
          }
        } else {
          // Create new account
          final createResult = await _accountRepository.createAccount(account);
          createResult.fold(
            (failure) => errors.add(ImportError.validation(
              message: 'Failed to create account: ${failure.message}',
              lineNumber: 0,
              field: 'id',
              value: account.id,
            )),
            (_) => imported.add(account),
          );
        }
      } catch (e) {
        errors.add(ImportError.validation(
          message: 'Unexpected error importing account: ${e.toString()}',
          lineNumber: 0,
          field: 'id',
          value: account.id,
        ));
      }
    }

    return ImportBatchResult(
      imported: imported,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Import categories to repository
  Future<ImportBatchResult<TransactionCategory>> _importCategories(
    List<TransactionCategory> categories,
    ImportOptions options,
  ) async {
    final imported = <TransactionCategory>[];
    final skipped = <TransactionCategory>[];
    final errors = <ImportError>[];

    for (final category in categories) {
      try {
        // Check for conflicts
        final conflictResult = await _checkCategoryConflict(category, options);
        if (conflictResult.isSome()) {
          final conflict = conflictResult.getOrElse(() => throw 'Unexpected error');
          if (options.updateExisting) {
            // Update existing category
            final updateResult = await _categoryRepository.updateCategory(category);
            updateResult.fold(
              (failure) => errors.add(ImportError.conflict(
                message: 'Failed to update category: ${failure.message}',
                lineNumber: 0,
                field: 'id',
                existingValue: 'existing',
                newValue: category.id,
              )),
              (_) => imported.add(category),
            );
          } else {
            skipped.add(category);
            errors.add(conflict);
          }
        } else {
          // Create new category
          final createResult = await _categoryRepository.addCategory(category);
          createResult.fold(
            (failure) => errors.add(ImportError.validation(
              message: 'Failed to create category: ${failure.message}',
              lineNumber: 0,
              field: 'id',
              value: category.id,
            )),
            (_) => imported.add(category),
          );
        }
      } catch (e) {
        errors.add(ImportError.validation(
          message: 'Unexpected error importing category: ${e.toString()}',
          lineNumber: 0,
          field: 'id',
          value: category.id,
        ));
      }
    }

    return ImportBatchResult(
      imported: imported,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Import transactions to repository
  Future<ImportBatchResult<Transaction>> _importTransactions(
    List<Transaction> transactions,
    ImportOptions options,
  ) async {
    final imported = <Transaction>[];
    final skipped = <Transaction>[];
    final errors = <ImportError>[];

    for (final transaction in transactions) {
      try {
        // Check for conflicts (duplicate transactions)
        final conflictResult = await _checkTransactionConflict(transaction, options);
        if (conflictResult.isSome()) {
          final conflict = conflictResult.getOrElse(() => throw 'Unexpected error');
          if (options.updateExisting) {
            // Update existing transaction
            final updateResult = await _transactionRepository.updateTransaction(transaction);
            updateResult.fold(
              (failure) => errors.add(ImportError.conflict(
                message: 'Failed to update transaction: ${failure.message}',
                lineNumber: 0,
                field: 'id',
                existingValue: 'existing',
                newValue: transaction.id,
              )),
              (_) => imported.add(transaction),
            );
          } else {
            skipped.add(transaction);
            errors.add(conflict);
          }
        } else {
          // Create new transaction
          final createResult = await _transactionRepository.addTransaction(transaction);
          createResult.fold(
            (failure) => errors.add(ImportError.validation(
              message: 'Failed to create transaction: ${failure.message}',
              lineNumber: 0,
              field: 'id',
              value: transaction.id,
            )),
            (_) => imported.add(transaction),
          );
        }
      } catch (e) {
        errors.add(ImportError.validation(
          message: 'Unexpected error importing transaction: ${e.toString()}',
          lineNumber: 0,
          field: 'id',
          value: transaction.id,
        ));
      }
    }

    return ImportBatchResult(
      imported: imported,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Import budgets to repository
  Future<ImportBatchResult<Budget>> _importBudgets(
    List<Budget> budgets,
    ImportOptions options,
  ) async {
    final imported = <Budget>[];
    final skipped = <Budget>[];
    final errors = <ImportError>[];

    for (final budget in budgets) {
      try {
        // Check for conflicts
        final conflictResult = await _checkBudgetConflict(budget, options);
        if (conflictResult.isSome()) {
          final conflict = conflictResult.getOrElse(() => throw 'Unexpected error');
          if (options.updateExisting) {
            // Update existing budget
            final updateResult = await _budgetRepository.updateBudget(budget);
            updateResult.fold(
              (failure) => errors.add(ImportError.conflict(
                message: 'Failed to update budget: ${failure.message}',
                lineNumber: 0,
                field: 'id',
                existingValue: 'existing',
                newValue: budget.id,
              )),
              (_) => imported.add(budget),
            );
          } else {
            skipped.add(budget);
            errors.add(conflict);
          }
        } else {
          // Create new budget
          final createResult = await _budgetRepository.createBudget(budget);
          createResult.fold(
            (failure) => errors.add(ImportError.validation(
              message: 'Failed to create budget: ${failure.message}',
              lineNumber: 0,
              field: 'id',
              value: budget.id,
            )),
            (_) => imported.add(budget),
          );
        }
      } catch (e) {
        errors.add(ImportError.validation(
          message: 'Unexpected error importing budget: ${e.toString()}',
          lineNumber: 0,
          field: 'id',
          value: budget.id,
        ));
      }
    }

    return ImportBatchResult(
      imported: imported,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Import goals to repository
  Future<ImportBatchResult<Goal>> _importGoals(
    List<Goal> goals,
    ImportOptions options,
  ) async {
    final imported = <Goal>[];
    final skipped = <Goal>[];
    final errors = <ImportError>[];

    for (final goal in goals) {
      try {
        // Check for conflicts
        final conflictResult = await _checkGoalConflict(goal, options);
        if (conflictResult.isSome()) {
          final conflict = conflictResult.getOrElse(() => throw 'Unexpected error');
          if (options.updateExisting) {
            // Update existing goal
            final updateResult = await _goalRepository.updateGoal(goal);
            updateResult.fold(
              (failure) => errors.add(ImportError.conflict(
                message: 'Failed to update goal: ${failure.message}',
                lineNumber: 0,
                field: 'id',
                existingValue: 'existing',
                newValue: goal.id,
              )),
              (_) => imported.add(goal),
            );
          } else {
            skipped.add(goal);
            errors.add(conflict);
          }
        } else {
          // Create new goal
          final createResult = await _goalRepository.createGoal(goal);
          createResult.fold(
            (failure) => errors.add(ImportError.validation(
              message: 'Failed to create goal: ${failure.message}',
              lineNumber: 0,
              field: 'id',
              value: goal.id,
            )),
            (_) => imported.add(goal),
          );
        }
      } catch (e) {
        errors.add(ImportError.validation(
          message: 'Unexpected error importing goal: ${e.toString()}',
          lineNumber: 0,
          field: 'id',
          value: goal.id,
        ));
      }
    }

    return ImportBatchResult(
      imported: imported,
      skipped: skipped,
      errors: errors,
    );
  }

  // Conflict checking methods (simplified - would need full implementation)
  Future<Option<ImportError>> _checkAccountConflict(Account account, ImportOptions options) async {
    // Implementation would check if account with same ID or name exists
    return const None();
  }

  Future<Option<ImportError>> _checkCategoryConflict(TransactionCategory category, ImportOptions options) async {
    // Implementation would check if category with same ID or name exists
    return const None();
  }

  Future<Option<ImportError>> _checkTransactionConflict(Transaction transaction, ImportOptions options) async {
    // Implementation would check for duplicate transactions
    return const None();
  }

  Future<Option<ImportError>> _checkBudgetConflict(Budget budget, ImportOptions options) async {
    // Implementation would check if budget with same ID or name exists
    return const None();
  }

  Future<Option<ImportError>> _checkGoalConflict(Goal goal, ImportOptions options) async {
    // Implementation would check if goal with same ID or name exists
    return const None();
  }

  /// Rollback imported data
  Future<void> _rollbackImport(ImportResult importResult) async {
    // Implementation would delete all imported items in reverse order
    // This is a simplified version
    try {
      // Rollback in reverse order
      for (final goal in importResult.goals) {
        await _goalRepository.deleteGoal(goal.id);
      }
      for (final budget in importResult.budgets) {
        await _budgetRepository.deleteBudget(budget.id);
      }
      for (final transaction in importResult.transactions) {
        await _transactionRepository.deleteTransaction(transaction.id);
      }
      for (final category in importResult.categories) {
        await _categoryRepository.deleteCategory(category.id);
      }
      for (final account in importResult.accounts) {
        await _accountRepository.deleteAccount(account.id);
      }
    } catch (e) {
      // Log rollback errors but don't throw
      debugPrint('Rollback failed: $e');
    }
  }
}


/// Result of importing a batch of items
class ImportBatchResult<T> {
  const ImportBatchResult({
    required this.imported,
    required this.skipped,
    required this.errors,
  });

  final List<T> imported;
  final List<T> skipped;
  final List<ImportError> errors;
}