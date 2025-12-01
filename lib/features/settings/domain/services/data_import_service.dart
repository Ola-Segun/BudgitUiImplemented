import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fpdart/fpdart.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction.dart' as tx show TransactionCategory;
import '../../../accounts/domain/entities/account.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../../../goals/domain/entities/goal.dart';
import '../entities/import_result.dart';
import '../entities/import_error.dart';

/// Service for importing data from various formats (CSV, JSON)
class DataImportService {
  const DataImportService();

  /// Import data from a file
  Future<Either<ImportError, ImportResult>> importFromFile(
    File file, {
    required ImportOptions options,
  }) async {
    try {
      final extension = file.path.split('.').last.toLowerCase();

      switch (extension) {
        case 'csv':
          return await _importFromCsv(file, options);
        case 'json':
          return await _importFromJson(file, options);
        default:
          return Left(ImportError(
            type: ImportErrorType.unsupportedFormat,
            message: 'Unsupported file format: $extension',
            lineNumber: 0,
          ));
      }
    } catch (e) {
      return Left(ImportError(
        type: ImportErrorType.fileReadError,
        message: 'Failed to read file: ${e.toString()}',
        lineNumber: 0,
      ));
    }
  }

  /// Import from CSV file
  Future<Either<ImportError, ImportResult>> _importFromCsv(
    File file,
    ImportOptions options,
  ) async {
    try {
      final content = await file.readAsString();
      final csvData = const CsvToListConverter().convert(content);

      if (csvData.isEmpty) {
        return Left(ImportError(
          type: ImportErrorType.emptyFile,
          message: 'CSV file is empty',
          lineNumber: 0,
        ));
      }

      final headers = csvData[0].map((e) => e.toString()).toList();
      final dataRows = csvData.sublist(1);

      return _parseCsvData(headers, dataRows, options);
    } catch (e) {
      return Left(ImportError(
        type: ImportErrorType.parsingError,
        message: 'Failed to parse CSV: ${e.toString()}',
        lineNumber: 0,
      ));
    }
  }

  /// Import from JSON file
  Future<Either<ImportError, ImportResult>> _importFromJson(
    File file,
    ImportOptions options,
  ) async {
    try {
      final content = await file.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;

      return _parseJsonData(jsonData, options);
    } catch (e) {
      return Left(ImportError(
        type: ImportErrorType.parsingError,
        message: 'Failed to parse JSON: ${e.toString()}',
        lineNumber: 0,
      ));
    }
  }

  /// Parse CSV data based on headers
  Either<ImportError, ImportResult> _parseCsvData(
    List<String> headers,
    List<List<dynamic>> rows,
    ImportOptions options,
  ) {
    // Detect data type from headers
    final dataType = _detectDataTypeFromHeaders(headers);

    switch (dataType) {
      case ImportDataType.transactions:
        return _parseTransactionCsv(headers, rows, options);
      case ImportDataType.categories:
        return _parseCategoryCsv(headers, rows, options);
      case ImportDataType.accounts:
        return _parseAccountCsv(headers, rows, options);
      case ImportDataType.budgets:
        return _parseBudgetCsv(headers, rows, options);
      case ImportDataType.goals:
        return _parseGoalCsv(headers, rows, options);
      default:
        return Left(ImportError(
          type: ImportErrorType.unknownDataType,
          message: 'Could not determine data type from CSV headers',
          lineNumber: 0,
        ));
    }
  }

  /// Parse JSON data
  Either<ImportError, ImportResult> _parseJsonData(
    Map<String, dynamic> jsonData,
    ImportOptions options,
  ) {
    final result = ImportResult.empty();

    try {
      // Handle different JSON structures
      if (jsonData.containsKey('transactions')) {
        final transactions = jsonData['transactions'] as List<dynamic>;
        final parsedTransactions = _parseTransactionsFromJson(transactions, options);
        result.transactions.addAll(parsedTransactions);
      }

      if (jsonData.containsKey('categories')) {
        final categories = jsonData['categories'] as List<dynamic>;
        final parsedCategories = _parseCategoriesFromJson(categories, options);
        result.categories.addAll(parsedCategories);
      }

      if (jsonData.containsKey('accounts')) {
        final accounts = jsonData['accounts'] as List<dynamic>;
        final parsedAccounts = _parseAccountsFromJson(accounts, options);
        result.accounts.addAll(parsedAccounts);
      }

      if (jsonData.containsKey('budgets')) {
        final budgets = jsonData['budgets'] as List<dynamic>;
        final parsedBudgets = _parseBudgetsFromJson(budgets, options);
        result.budgets.addAll(parsedBudgets);
      }

      if (jsonData.containsKey('goals')) {
        final goals = jsonData['goals'] as List<dynamic>;
        final parsedGoals = _parseGoalsFromJson(goals, options);
        result.goals.addAll(parsedGoals);
      }

      return Right(result);
    } catch (e) {
      return Left(ImportError(
        type: ImportErrorType.parsingError,
        message: 'Failed to parse JSON structure: ${e.toString()}',
        lineNumber: 0,
      ));
    }
  }

  /// Detect data type from CSV headers
  ImportDataType _detectDataTypeFromHeaders(List<String> headers) {
    final headerString = headers.join(' ').toLowerCase();

    if (headerString.contains('amount') && headerString.contains('date')) {
      return ImportDataType.transactions;
    } else if (headerString.contains('category') && headerString.contains('icon')) {
      return ImportDataType.categories;
    } else if (headerString.contains('account') && headerString.contains('balance')) {
      return ImportDataType.accounts;
    } else if (headerString.contains('budget') && headerString.contains('limit')) {
      return ImportDataType.budgets;
    } else if (headerString.contains('goal') && headerString.contains('target')) {
      return ImportDataType.goals;
    }

    return ImportDataType.unknown;
  }

  // CSV parsing methods for each data type
  Either<ImportError, ImportResult> _parseTransactionCsv(
    List<String> headers,
    List<List<dynamic>> rows,
    ImportOptions options,
  ) {
    final result = ImportResult.empty();
    final errors = <ImportError>[];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final lineNumber = i + 2; // +2 because of 0-index and header row

      try {
        final transaction = _parseTransactionFromCsvRow(headers, row, options);
        if (transaction != null) {
          result.transactions.add(transaction);
        }
      } catch (e) {
        errors.add(ImportError(
          type: ImportErrorType.validationError,
          message: 'Failed to parse transaction: ${e.toString()}',
          lineNumber: lineNumber,
        ));
      }
    }

    if (errors.isNotEmpty && !options.skipErrors) {
      return Left(errors.first);
    }

    result.errors.addAll(errors);
    return Right(result);
  }

  Either<ImportError, ImportResult> _parseCategoryCsv(
    List<String> headers,
    List<List<dynamic>> rows,
    ImportOptions options,
  ) {
    final result = ImportResult.empty();
    final errors = <ImportError>[];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final lineNumber = i + 2;

      try {
        final category = _parseCategoryFromCsvRow(headers, row, options);
        if (category != null) {
          result.categories.add(category);
        }
      } catch (e) {
        errors.add(ImportError(
          type: ImportErrorType.validationError,
          message: 'Failed to parse category: ${e.toString()}',
          lineNumber: lineNumber,
        ));
      }
    }

    if (errors.isNotEmpty && !options.skipErrors) {
      return Left(errors.first);
    }

    result.errors.addAll(errors);
    return Right(result);
  }

  Either<ImportError, ImportResult> _parseAccountCsv(
    List<String> headers,
    List<List<dynamic>> rows,
    ImportOptions options,
  ) {
    final result = ImportResult.empty();
    final errors = <ImportError>[];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final lineNumber = i + 2;

      try {
        final account = _parseAccountFromCsvRow(headers, row, options);
        if (account != null) {
          result.accounts.add(account);
        }
      } catch (e) {
        errors.add(ImportError(
          type: ImportErrorType.validationError,
          message: 'Failed to parse account: ${e.toString()}',
          lineNumber: lineNumber,
        ));
      }
    }

    if (errors.isNotEmpty && !options.skipErrors) {
      return Left(errors.first);
    }

    result.errors.addAll(errors);
    return Right(result);
  }

  Either<ImportError, ImportResult> _parseBudgetCsv(
    List<String> headers,
    List<List<dynamic>> rows,
    ImportOptions options,
  ) {
    final result = ImportResult.empty();
    final errors = <ImportError>[];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final lineNumber = i + 2;

      try {
        final budget = _parseBudgetFromCsvRow(headers, row, options);
        if (budget != null) {
          result.budgets.add(budget);
        }
      } catch (e) {
        errors.add(ImportError(
          type: ImportErrorType.validationError,
          message: 'Failed to parse budget: ${e.toString()}',
          lineNumber: lineNumber,
        ));
      }
    }

    if (errors.isNotEmpty && !options.skipErrors) {
      return Left(errors.first);
    }

    result.errors.addAll(errors);
    return Right(result);
  }

  Either<ImportError, ImportResult> _parseGoalCsv(
    List<String> headers,
    List<List<dynamic>> rows,
    ImportOptions options,
  ) {
    final result = ImportResult.empty();
    final errors = <ImportError>[];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final lineNumber = i + 2;

      try {
        final goal = _parseGoalFromCsvRow(headers, row, options);
        if (goal != null) {
          result.goals.add(goal);
        }
      } catch (e) {
        errors.add(ImportError(
          type: ImportErrorType.validationError,
          message: 'Failed to parse goal: ${e.toString()}',
          lineNumber: lineNumber,
        ));
      }
    }

    if (errors.isNotEmpty && !options.skipErrors) {
      return Left(errors.first);
    }

    result.errors.addAll(errors);
    return Right(result);
  }

  // Individual row parsing methods (simplified - would need full implementation)
  Transaction? _parseTransactionFromCsvRow(
    List<String> headers,
    List<dynamic> row,
    ImportOptions options,
  ) {
    // Implementation would parse CSV row into Transaction entity
    // This is a placeholder - full implementation needed
    return null;
  }

  tx.TransactionCategory? _parseCategoryFromCsvRow(
    List<String> headers,
    List<dynamic> row,
    ImportOptions options,
  ) {
    // Implementation would parse CSV row into TransactionCategory entity
    return null;
  }

  Account? _parseAccountFromCsvRow(
    List<String> headers,
    List<dynamic> row,
    ImportOptions options,
  ) {
    // Implementation would parse CSV row into Account entity
    return null;
  }

  Budget? _parseBudgetFromCsvRow(
    List<String> headers,
    List<dynamic> row,
    ImportOptions options,
  ) {
    // Implementation would parse CSV row into Budget entity
    return null;
  }

  Goal? _parseGoalFromCsvRow(
    List<String> headers,
    List<dynamic> row,
    ImportOptions options,
  ) {
    // Implementation would parse CSV row into Goal entity
    return null;
  }

  // JSON parsing methods
  List<Transaction> _parseTransactionsFromJson(
    List<dynamic> transactionsJson,
    ImportOptions options,
  ) {
    // Implementation would parse JSON into Transaction entities
    return [];
  }

  List<tx.TransactionCategory> _parseCategoriesFromJson(
    List<dynamic> categoriesJson,
    ImportOptions options,
  ) {
    // Implementation would parse JSON into TransactionCategory entities
    return [];
  }

  List<Account> _parseAccountsFromJson(
    List<dynamic> accountsJson,
    ImportOptions options,
  ) {
    // Implementation would parse JSON into Account entities
    return [];
  }

  List<Budget> _parseBudgetsFromJson(
    List<dynamic> budgetsJson,
    ImportOptions options,
  ) {
    // Implementation would parse JSON into Budget entities
    return [];
  }

  List<Goal> _parseGoalsFromJson(
    List<dynamic> goalsJson,
    ImportOptions options,
  ) {
    // Implementation would parse JSON into Goal entities
    return [];
  }
}

/// Options for import operations
class ImportOptions {
  const ImportOptions({
    this.skipErrors = false,
    this.updateExisting = false,
    this.validateData = true,
    this.rollbackOnError = true,
  });

  final bool skipErrors;
  final bool updateExisting;
  final bool validateData;
  final bool rollbackOnError;
}

/// Types of data that can be imported
enum ImportDataType {
  transactions,
  categories,
  accounts,
  budgets,
  goals,
  unknown,
}