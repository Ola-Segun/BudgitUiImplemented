import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../bills/domain/entities/bill.dart';
import '../../../bills/domain/repositories/bill_repository.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../../../budgets/domain/repositories/budget_repository.dart';
import '../../../budgets/domain/usecases/calculate_budget_status.dart';
import '../../../recurring_incomes/domain/entities/recurring_income.dart';
import '../../../recurring_incomes/domain/repositories/recurring_income_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_category_repository.dart';
import '../../../insights/domain/entities/insight.dart';
import '../../../insights/domain/repositories/insight_repository.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Helper class for aggregating category data across multiple budgets
class AggregatedCategoryData {
  final String categoryId;
  double spent;
  double budget;
  BudgetHealth status;

  AggregatedCategoryData({
    required this.categoryId,
    required this.spent,
    required this.budget,
    required this.status,
  });
}

/// Implementation of dashboard repository that aggregates data from multiple sources
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(
    this._transactionRepository,
    this._budgetRepository,
    this._billRepository,
    this._accountRepository,
    this._insightRepository,
    this._transactionCategoryRepository,
    this._calculateBudgetStatus,
    this._recurringIncomeRepository,
  );

  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;
  final BillRepository _billRepository;
  final AccountRepository _accountRepository;
  final InsightRepository _insightRepository;
  final TransactionCategoryRepository _transactionCategoryRepository;
  final CalculateBudgetStatus _calculateBudgetStatus;
  final RecurringIncomeRepository? _recurringIncomeRepository;

  @override
  Future<Result<DashboardData>> getDashboardData() async {
    try {
      // Get all data concurrently
      final results = await Future.wait([
        getFinancialSnapshot(),
        getBudgetOverview(),
        getUpcomingBills(),
        getUpcomingIncomes(),
        getRecentTransactions(),
        getDashboardInsights(),
      ]);

      // Provide default values for failed operations to make dashboard more resilient
      final financialSnapshotResult = results[0].isSuccess
          ? results[0] as Result<FinancialSnapshot>
          : Result.success(FinancialSnapshot(
              incomeThisMonth: 0.0,
              expensesThisMonth: 0.0,
              balanceThisMonth: 0.0,
              netWorth: 0.0,
            ));

      final budgetOverviewResult = results[1].isSuccess
          ? results[1] as Result<List<BudgetCategoryOverview>>
          : Result.success(<BudgetCategoryOverview>[]);

      final upcomingBillsResult = results[2].isSuccess
          ? results[2] as Result<List<Bill>>
          : Result.success(<Bill>[]);

      final upcomingIncomesResult = results[3].isSuccess
          ? results[3] as Result<List<RecurringIncomeStatus>>
          : Result.success(<RecurringIncomeStatus>[]);

      final recentTransactionsResult = results[4].isSuccess
          ? results[4] as Result<List<Transaction>>
          : Result.success(<Transaction>[]);

      final insightsResult = results[5].isSuccess
          ? results[5] as Result<List<Insight>>
          : Result.success(<Insight>[]);

      final financialSnapshot = financialSnapshotResult;
      final budgetOverview = budgetOverviewResult;
      final upcomingBills = upcomingBillsResult;
      final upcomingIncomes = upcomingIncomesResult;
      final recentTransactions = recentTransactionsResult;
      final insights = insightsResult;

      final dashboardData = DashboardData(
        financialSnapshot: financialSnapshot.dataOrNull!,
        budgetOverview: budgetOverview.dataOrNull!,
        upcomingBills: upcomingBills.dataOrNull!,
        upcomingIncomes: upcomingIncomes.dataOrNull!,
        recentTransactions: recentTransactions.dataOrNull!,
        insights: insights.dataOrNull!,
        generatedAt: DateTime.now(),
      );

      return Result.success(dashboardData);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get dashboard data: $e'));
    }
  }

  @override
  Future<Result<FinancialSnapshot>> getFinancialSnapshot() async {
    try {
      // Get current month date range
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Get all transactions for current month
      final transactionsResult = await _transactionRepository.getByDateRange(
        startOfMonth,
        endOfMonth,
      );

      if (transactionsResult.isError) {
        return Result.error(transactionsResult.failureOrNull!);
      }

      final transactions = transactionsResult.dataOrNull ?? [];

      // Calculate total income and expenses
      final expensesThisMonth = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final incomeThisMonth = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final balanceThisMonth = incomeThisMonth - expensesThisMonth;

      // Get net worth from accounts
      final netWorthResult = await _accountRepository.getNetWorth();
      final netWorth = netWorthResult.getOrDefault(0.0);

      final snapshot = FinancialSnapshot(
        incomeThisMonth: incomeThisMonth,
        expensesThisMonth: expensesThisMonth,
        balanceThisMonth: balanceThisMonth,
        netWorth: netWorth,
      );

      return Result.success(snapshot);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get financial snapshot: $e'));
    }
  }

  @override
  Future<Result<List<BudgetCategoryOverview>>> getBudgetOverview({int limit = 5}) async {
    try {
      // Get all budgets
      final budgetsResult = await _budgetRepository.getAll();
      if (budgetsResult.isError) {
        return Result.error(budgetsResult.failureOrNull!);
      }

      final budgets = budgetsResult.dataOrNull ?? [];
      if (budgets.isEmpty) {
        return Result.success([]);
      }

      // Filter for active budgets only
      final activeBudgets = budgets.where((budget) => budget.isCurrentlyActive).toList();
      if (activeBudgets.isEmpty) {
        return Result.success([]);
      }

      // Aggregate category data across all active budgets
      final categoryAggregation = <String, AggregatedCategoryData>{};

      for (final budget in activeBudgets) {
        // Calculate budget status for each active budget
        final statusResult = await _calculateBudgetStatus(budget);
        if (statusResult.isError) {
          continue; // Skip this budget if calculation fails
        }

        final budgetStatus = statusResult.dataOrNull!;
        for (final categoryStatus in budgetStatus.categoryStatuses) {
          final categoryId = categoryStatus.categoryId;

          if (categoryAggregation.containsKey(categoryId)) {
            // Aggregate with existing data
            categoryAggregation[categoryId]!.spent += categoryStatus.spent;
            categoryAggregation[categoryId]!.budget += categoryStatus.budget;
          } else {
            // Add new category
            categoryAggregation[categoryId] = AggregatedCategoryData(
              categoryId: categoryId,
              spent: categoryStatus.spent,
              budget: categoryStatus.budget,
              status: categoryStatus.status,
            );
          }
        }
      }

      // Convert aggregated data to BudgetCategoryOverview
      final categoryOverviews = <BudgetCategoryOverview>[];
      for (final entry in categoryAggregation.entries) {
        final data = entry.value;
        final categoryName = await _getCategoryName(data.categoryId);

        // Calculate aggregated percentage and status
        final percentage = data.budget > 0 ? (data.spent / data.budget) * 100 : 0.0;
        final status = _determineAggregatedStatus(data.spent, data.budget);

        categoryOverviews.add(BudgetCategoryOverview(
          categoryId: data.categoryId,
          categoryName: categoryName,
          spent: data.spent,
          budget: data.budget,
          percentage: percentage,
          status: status,
        ));
      }

      // Sort by spending amount (highest first) and limit results
      categoryOverviews.sort((a, b) => b.spent.compareTo(a.spent));
      final limitedOverviews = categoryOverviews.take(limit).toList();

      return Result.success(limitedOverviews);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get budget overview: $e'));
    }
  }

  @override
  Future<Result<List<Bill>>> getUpcomingBills({int limit = 3}) async {
    try {
      final billsResult = await _billRepository.getAll();
      if (billsResult.isError) {
        return Result.error(billsResult.failureOrNull!);
      }

      final bills = billsResult.dataOrNull ?? [];

      // Filter and sort upcoming bills
      final upcomingBills = bills
          .where((bill) => !bill.isPaid && bill.daysUntilDue >= 0)
          .sorted((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue))
          .take(limit)
          .toList();

      return Result.success(upcomingBills);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get upcoming bills: $e'));
    }
  }

  @override
  Future<Result<List<RecurringIncomeStatus>>> getUpcomingIncomes({int limit = 3}) async {
    try {
      // Get all recurring incomes first
      final incomesResult = await _recurringIncomeRepository?.getAllIncomeStatuses();
      if (incomesResult == null || incomesResult.isError) {
        // Fallback to empty list if repository not available
        return Result.success(<RecurringIncomeStatus>[]);
      }

      final allStatuses = incomesResult.dataOrNull ?? [];

      // Filter for upcoming incomes (expected soon, today, or overdue)
      final upcomingStatuses = allStatuses.where((status) =>
        status.isExpectedSoon ||
        status.isExpectedToday ||
        status.isOverdue
      ).toList();

      // Sort by urgency and date
      upcomingStatuses.sort((a, b) {
        // Overdue first
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;

        // Expected today second
        if (a.isExpectedToday && !b.isExpectedToday) return -1;
        if (!a.isExpectedToday && b.isExpectedToday) return 1;

        // Expected soon third
        if (a.isExpectedSoon && !b.isExpectedSoon) return -1;
        if (!a.isExpectedSoon && b.isExpectedSoon) return 1;

        // Then by days until expected
        return a.daysUntilExpected.compareTo(b.daysUntilExpected);
      });

      // Take the limit
      final limitedStatuses = upcomingStatuses.take(limit).toList();

      return Result.success(limitedStatuses);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get upcoming incomes: $e'));
    }
  }

  @override
  Future<Result<List<Transaction>>> getRecentTransactions({int limit = 7}) async {
    try {
      final transactionsResult = await _transactionRepository.getAll();
      if (transactionsResult.isError) {
        return Result.error(transactionsResult.failureOrNull!);
      }

      final transactions = transactionsResult.dataOrNull ?? [];

      // Sort by date descending and take recent ones
      final recentTransactions = transactions
          .sorted((a, b) => b.date.compareTo(a.date))
          .take(limit)
          .toList();

      return Result.success(recentTransactions);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get recent transactions: $e'));
    }
  }

  @override
  Future<Result<List<Insight>>> getDashboardInsights({int limit = 3}) async {
    try {
      final insightsResult = await _insightRepository.getAll();
      if (insightsResult.isError) {
        return Result.error(insightsResult.failureOrNull!);
      }

      final insights = insightsResult.dataOrNull ?? [];

      // Take most recent insights
      final recentInsights = insights
          .sorted((a, b) => b.generatedAt.compareTo(a.generatedAt))
          .take(limit)
          .toList();

      return Result.success(recentInsights);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get dashboard insights: $e'));
    }
  }

  @override
  Future<Result<void>> refreshDashboardData() async {
    // In a real implementation, this might clear caches or force refresh
    // For now, just return success
    return Result.success(null);
  }



  /// Determine aggregated budget health status based on total spent vs total budget
  BudgetHealthStatus _determineAggregatedStatus(double totalSpent, double totalBudget) {
    if (totalBudget <= 0) return BudgetHealthStatus.healthy;

    final percentage = totalSpent / totalBudget;
    if (percentage > 1.0) return BudgetHealthStatus.overBudget;
    if (percentage > 0.9) return BudgetHealthStatus.critical;
    if (percentage > 0.75) return BudgetHealthStatus.warning;
    return BudgetHealthStatus.healthy;
  }

  /// Get category name by ID using repository lookup
  Future<String> _getCategoryName(String categoryId) async {
    final result = await _transactionCategoryRepository.getById(categoryId);

    return result.when(
      success: (category) => category?.name ?? categoryId,
      error: (failure) {
        // Log error and return category ID as fallback
        debugPrint('Failed to get category name for $categoryId: $failure');
        return categoryId;
      },
    );
  }
}