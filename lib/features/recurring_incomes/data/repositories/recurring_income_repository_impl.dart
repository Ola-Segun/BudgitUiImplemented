import 'dart:developer' as developer;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../transactions/domain/usecases/add_transaction.dart';
import '../../../transactions/domain/usecases/delete_transaction.dart';
import '../../domain/entities/recurring_income.dart';
import '../../domain/repositories/recurring_income_repository.dart';
import '../datasources/recurring_income_hive_datasource.dart';

/// Implementation of RecurringIncomeRepository using Hive data source
class RecurringIncomeRepositoryImpl implements RecurringIncomeRepository {
  RecurringIncomeRepositoryImpl(
    this._accountRepository,
    this._addTransaction,
  ) : _dataSource = RecurringIncomeHiveDataSource();

  final AccountRepository _accountRepository;
  final AddTransaction _addTransaction;
  final RecurringIncomeHiveDataSource _dataSource;

  @override
  Future<Result<List<RecurringIncome>>> getAll() => _dataSource.getAll();

  @override
  Future<Result<RecurringIncome?>> getById(String id) => _dataSource.getById(id);

  @override
  Future<Result<List<RecurringIncome>>> getExpectedWithin(int days) => _dataSource.getExpectedWithin(days);

  @override
  Future<Result<List<RecurringIncome>>> getOverdue() => _dataSource.getOverdue();

  @override
  Future<Result<List<RecurringIncome>>> getReceivedThisMonth() => _dataSource.getReceivedThisMonth();

  @override
  Future<Result<List<RecurringIncome>>> getExpectedThisMonth() => _dataSource.getExpectedThisMonth();

  @override
  Future<Result<RecurringIncome>> add(RecurringIncome income) => _dataSource.add(income);

  @override
  Future<Result<RecurringIncome>> update(RecurringIncome income) => _dataSource.update(income);

  @override
  Future<Result<void>> delete(String id) => _dataSource.delete(id);

  @override
  Future<Result<RecurringIncome>> recordIncomeReceipt(
    String incomeId,
    RecurringIncomeInstance instance,
    {String? accountId}
  ) async {
    developer.log('RecurringIncomeRepositoryImpl: Recording income receipt - incomeId: $incomeId, amount: ${instance.amount}, accountId: $accountId');

    // Get income details first
    final incomeResult = await _dataSource.getById(incomeId);
    if (incomeResult.isError) {
      developer.log('RecurringIncomeRepositoryImpl: Failed to get income details - error: ${incomeResult.failureOrNull!.message}');
      return Result.error(incomeResult.failureOrNull!);
    }

    final income = incomeResult.dataOrNull;
    if (income == null) {
      developer.log('RecurringIncomeRepositoryImpl: Income not found - incomeId: $incomeId');
      return Result.error(Failure.validation('Recurring income not found', {'incomeId': 'Income does not exist'}));
    }

    developer.log('RecurringIncomeRepositoryImpl: Found income - name: ${income.name}, current history length: ${income.incomeHistory.length}');

    // Determine which account to use for income deposit
    final accountIdToUse = accountId ?? instance.accountId ?? income.effectiveAccountId;
    if (accountIdToUse == null) {
      developer.log('RecurringIncomeRepositoryImpl: No account specified for income deposit');
      return Result.error(Failure.validation(
        'No account specified for income deposit. Please configure a default account for this income or specify one when recording receipt.',
        {'accountId': 'Account is required for income deposit'}
      ));
    }

    developer.log('RecurringIncomeRepositoryImpl: Using account ID: $accountIdToUse for income deposit');

    // Validate that the account exists and is accessible
    final accountResult = await _accountRepository.getById(accountIdToUse);
    if (accountResult.isError || accountResult.dataOrNull == null) {
      developer.log('RecurringIncomeRepositoryImpl: Account validation failed - accountId: $accountIdToUse, error: ${accountResult.failureOrNull?.message}');
      return Result.error(Failure.validation(
        'Selected account is not available or does not exist',
        {'accountId': 'Invalid account for income deposit'}
      ));
    }

    developer.log('RecurringIncomeRepositoryImpl: Account validated successfully - proceeding with receipt recording');

    // Proceed with recording income receipt using the proper usecase pattern
    final result = await _dataSource.recordIncomeReceipt(incomeId, instance, _addTransaction, accountId: accountIdToUse);

    result.when(
      success: (updatedIncome) {
        developer.log('RecurringIncomeRepositoryImpl: Income receipt recorded successfully - updated income: ${updatedIncome.name}, new history length: ${updatedIncome.incomeHistory.length}');
      },
      error: (failure) {
        developer.log('RecurringIncomeRepositoryImpl: Failed to record income receipt - error: ${failure.message}');
      },
    );

    return result;
  }

  @override
  Future<Result<RecurringIncomeStatus>> getIncomeStatus(String incomeId) async {
    final incomeResult = await _dataSource.getById(incomeId);
    if (incomeResult.isError) {
      return Result.error(incomeResult.failureOrNull!);
    }

    final income = incomeResult.dataOrNull;
    if (income == null) {
      return Result.error(Failure.validation('Recurring income not found', {'incomeId': 'Income does not exist'}));
    }

    // Calculate status
    final daysUntilExpected = income.daysUntilExpected;
    final isExpectedSoon = income.isExpectedSoon;
    final isExpectedToday = income.isExpectedToday;
    final isOverdue = income.isOverdue;

    RecurringIncomeUrgency urgency;
    if (isOverdue) {
      urgency = RecurringIncomeUrgency.overdue;
    } else if (isExpectedToday) {
      urgency = RecurringIncomeUrgency.expectedToday;
    } else if (isExpectedSoon) {
      urgency = RecurringIncomeUrgency.expectedSoon;
    } else {
      urgency = RecurringIncomeUrgency.normal;
    }

    final status = RecurringIncomeStatus(
      income: income,
      daysUntilExpected: daysUntilExpected,
      isExpectedSoon: isExpectedSoon,
      isExpectedToday: isExpectedToday,
      isOverdue: isOverdue,
      urgency: urgency,
    );

    return Result.success(status);
  }

  @override
  Future<Result<List<RecurringIncomeStatus>>> getAllIncomeStatuses() async {
    final incomesResult = await _dataSource.getAll();
    if (incomesResult.isError) {
      return Result.error(incomesResult.failureOrNull!);
    }

    final incomes = incomesResult.dataOrNull ?? [];
    final statuses = <RecurringIncomeStatus>[];

    for (final income in incomes) {
      final statusResult = await getIncomeStatus(income.id);
      if (statusResult.isSuccess) {
        statuses.add(statusResult.dataOrNull!);
      }
    }

    // Sort by urgency
    statuses.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      if (a.isExpectedSoon && !b.isExpectedSoon) return -1;
      if (!a.isExpectedSoon && b.isExpectedSoon) return 1;
      return a.daysUntilExpected.compareTo(b.daysUntilExpected);
    });

    return Result.success(statuses);
  }

  @override
  Future<Result<RecurringIncomesSummary>> getIncomesSummary() async {
    final allIncomesResult = await _dataSource.getAll();
    if (allIncomesResult.isError) {
      return Result.error(allIncomesResult.failureOrNull!);
    }

    final allIncomes = allIncomesResult.dataOrNull ?? [];
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Calculate metrics
    final totalIncomes = allIncomes.length;
    final activeIncomes = allIncomes.where((income) => !income.hasEnded).length;

    final expectedThisMonthResult = await _dataSource.getExpectedThisMonth();
    final expectedThisMonth = expectedThisMonthResult.dataOrNull?.length ?? 0;

    final totalMonthlyAmount = allIncomes.fold<double>(0.0, (sum, income) => sum + income.amount);
    final receivedThisMonth = allIncomes.fold<double>(0.0, (sum, income) {
      return sum + income.incomeHistory.where((instance) {
        final receivedMonth = DateTime(instance.receivedDate.year, instance.receivedDate.month);
        return receivedMonth == currentMonth;
      }).fold(0.0, (sum, instance) => sum + instance.amount);
    });
    final expectedAmount = allIncomes.fold<double>(0.0, (sum, income) {
      if (income.nextExpectedDate != null) {
        final expectedMonth = DateTime(income.nextExpectedDate!.year, income.nextExpectedDate!.month);
        if (expectedMonth == currentMonth) {
          return sum + income.amount;
        }
      }
      return sum;
    });

    // Get upcoming incomes
    final upcomingIncomesResult = await _dataSource.getExpectedWithin(30);
    if (upcomingIncomesResult.isError) {
      return Result.error(upcomingIncomesResult.failureOrNull!);
    }

    final upcomingIncomesRaw = upcomingIncomesResult.dataOrNull ?? [];
    final upcomingIncomeStatuses = <RecurringIncomeStatus>[];

    for (final income in upcomingIncomesRaw.take(5)) {
      final statusResult = await getIncomeStatus(income.id);
      if (statusResult.isSuccess) {
        upcomingIncomeStatuses.add(statusResult.dataOrNull!);
      }
    }

    final summary = RecurringIncomesSummary(
      totalIncomes: totalIncomes,
      activeIncomes: activeIncomes,
      expectedThisMonth: expectedThisMonth,
      totalMonthlyAmount: totalMonthlyAmount,
      receivedThisMonth: receivedThisMonth,
      expectedAmount: expectedAmount,
      upcomingIncomes: upcomingIncomeStatuses,
    );

    return Result.success(summary);
  }

  @override
  Future<Result<RecurringIncome>> updateNextExpectedDate(String incomeId) => _dataSource.updateNextExpectedDate(incomeId);

  @override
  Future<Result<bool>> nameExists(String name, {String? excludeId}) async {
    try {
      final incomesResult = await _dataSource.getAll();
      if (incomesResult.isError) {
        return Result.error(incomesResult.failureOrNull!);
      }

      final incomes = incomesResult.dataOrNull ?? [];
      final trimmedName = name.trim().toLowerCase();

      final exists = incomes.any((income) {
        if (excludeId != null && income.id == excludeId) {
          return false;
        }
        return income.name.trim().toLowerCase() == trimmedName;
      });

      return Result.success(exists);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to check if recurring income name exists: $e'));
    }
  }
}