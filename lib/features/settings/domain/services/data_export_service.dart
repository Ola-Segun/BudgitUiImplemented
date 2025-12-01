import 'dart:convert';
import 'package:csv/csv.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/settings.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/domain/repositories/category_repository.dart';
import '../../../budgets/domain/repositories/budget_repository.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../bills/domain/repositories/bill_repository.dart';

/// Service for exporting app data in various formats
class DataExportService {
  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final BudgetRepository _budgetRepository;
  final GoalRepository _goalRepository;
  final BillRepository _billRepository;

  DataExportService({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
    required BudgetRepository budgetRepository,
    required GoalRepository goalRepository,
    required BillRepository billRepository,
  })  : _accountRepository = accountRepository,
        _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        _budgetRepository = budgetRepository,
        _goalRepository = goalRepository,
        _billRepository = billRepository;

  /// Export all app data
  Future<Result<String>> exportAllData({
    required DataExportType format,
  }) async {
    try {
      // Gather all data concurrently
      final results = await Future.wait([
        _accountRepository.getAccounts(),
        _transactionRepository.getTransactions(),
        _categoryRepository.getCategories(),
        _budgetRepository.getBudgets(),
        _goalRepository.getGoals(),
        _billRepository.getBills(),
      ]);

      // Check for errors
      for (final result in results) {
        if (result.isError) {
          return Result.error(result.failureOrNull!);
        }
      }

      final accounts = results[0].dataOrNull!;
      final transactions = results[1].dataOrNull!;
      final categories = results[2].dataOrNull!;
      final budgets = results[3].dataOrNull!;
      final goals = results[4].dataOrNull!;
      final bills = results[5].dataOrNull!;

      // Create export data structure
      final exportData = {
        'metadata': {
          'exportedAt': DateTime.now().toIso8601String(),
          'version': '1.0.0',
          'format': format.name,
        },
        'accounts': accounts.map((account) => account.toJson()).toList(),
        'transactions': transactions.map((transaction) => transaction.toJson()).toList(),
        'categories': categories.map((category) => category.toJson()).toList(),
        'budgets': budgets.map((budget) => budget.toJson()).toList(),
        'goals': goals.map((goal) => goal.toJson()).toList(),
        'bills': bills.map((bill) => bill.toJson()).toList(),
      };

      // Format the data
      switch (format) {
        case DataExportType.json:
          return Result.success(jsonEncode(exportData));

        case DataExportType.csv:
          return Result.success(_convertToCsv(exportData));

        case DataExportType.pdf:
          // PDF export would require additional libraries
          return Result.error(Failure.unknown('PDF export not yet implemented'));
      }
    } catch (e) {
      return Result.error(Failure.unknown('Failed to export data: $e'));
    }
  }

  /// Convert export data to CSV format
  String _convertToCsv(Map<String, dynamic> data) {
    final csvData = <List<String>>[];

    // Add metadata
    csvData.add(['Section', 'Type', 'Data']);
    csvData.add(['metadata', 'exportedAt', data['metadata']['exportedAt']]);
    csvData.add(['metadata', 'version', data['metadata']['version']]);

    // Add accounts
    for (final account in data['accounts']) {
      csvData.add(['accounts', 'account', jsonEncode(account)]);
    }

    // Add transactions
    for (final transaction in data['transactions']) {
      csvData.add(['transactions', 'transaction', jsonEncode(transaction)]);
    }

    // Add categories
    for (final category in data['categories']) {
      csvData.add(['categories', 'category', jsonEncode(category)]);
    }

    // Add budgets
    for (final budget in data['budgets']) {
      csvData.add(['budgets', 'budget', jsonEncode(budget)]);
    }

    // Add goals
    for (final goal in data['goals']) {
      csvData.add(['goals', 'goal', jsonEncode(goal)]);
    }

    // Add bills
    for (final bill in data['bills']) {
      csvData.add(['bills', 'bill', jsonEncode(bill)]);
    }

    return const ListToCsvConverter().convert(csvData);
  }
}