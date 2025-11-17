import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../storage/hive_storage.dart';
import '../router/app_router.dart';
import '../../features/transactions/data/datasources/transaction_hive_datasource.dart';
import '../../features/transactions/data/datasources/transaction_category_hive_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/data/repositories/transaction_category_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/repositories/transaction_category_repository.dart';
import '../../features/transactions/domain/usecases/add_transaction.dart';
import '../../features/transactions/domain/usecases/get_paginated_transactions.dart';
import '../../features/transactions/domain/usecases/get_transactions.dart';
import '../../features/transactions/domain/usecases/update_transaction.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';
import '../../features/transactions/domain/usecases/get_categories.dart';
import '../../features/transactions/domain/usecases/add_category.dart';
import '../../features/transactions/domain/usecases/archive_category.dart';
import '../../features/transactions/domain/usecases/update_category.dart';
import '../../features/transactions/domain/usecases/delete_category.dart';
import '../../features/transactions/domain/usecases/unarchive_category.dart';
import '../../features/transactions/domain/usecases/reorder_categories.dart';
import '../../features/budgets/data/datasources/budget_hive_datasource.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/budgets/domain/usecases/create_budget.dart';
import '../../features/budgets/domain/usecases/get_budgets.dart';
import '../../features/budgets/domain/usecases/update_budget.dart';
import '../../features/budgets/domain/usecases/delete_budget.dart';
import '../../features/budgets/domain/usecases/calculate_budget_status.dart';
import '../../features/goals/data/datasources/goal_hive_datasource.dart';
import '../../features/goals/data/repositories/goal_repository_impl.dart';
import '../../features/goals/data/models/goal_contribution_dto.dart';
import '../../features/goals/domain/repositories/goal_repository.dart';
import '../../features/goals/domain/usecases/create_goal.dart';
import '../../features/goals/domain/usecases/get_goals.dart';
import '../../features/goals/domain/usecases/update_goal.dart';
import '../../features/goals/domain/usecases/delete_goal.dart';
import '../../features/goals/domain/usecases/add_goal_contribution.dart' as add_goal_contribution_usecase;
import '../../features/goals/domain/usecases/validate_goal_allocation.dart';
import '../../features/goals/domain/usecases/allocate_to_goals.dart' as allocate_to_goals_usecase;
import '../../features/insights/data/datasources/insight_hive_datasource.dart';
import '../../features/insights/data/repositories/insight_repository_impl.dart';
import '../../features/insights/domain/repositories/insight_repository.dart';
import '../../features/insights/domain/usecases/get_insights.dart';
import '../../features/insights/domain/usecases/calculate_financial_health_score.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart' as onboarding_providers;
import '../../features/accounts/data/datasources/account_hive_datasource.dart';
import '../../features/accounts/data/repositories/account_repository_impl.dart';
import '../../features/accounts/domain/repositories/account_repository.dart';
import '../../features/accounts/domain/usecases/reconcile_account_balance.dart';
import '../../features/accounts/domain/usecases/create_account.dart';
import '../../features/accounts/domain/usecases/get_accounts.dart';
import '../../features/accounts/domain/usecases/update_account.dart';
import '../../features/accounts/domain/usecases/delete_account.dart';
import '../../features/accounts/domain/usecases/get_account_balance.dart';
import '../../features/bills/data/datasources/bill_hive_datasource.dart';
import '../../features/bills/data/repositories/bill_repository_impl.dart';
import '../../features/bills/domain/repositories/bill_repository.dart';
import '../../features/bills/domain/usecases/calculate_bills_summary.dart';
import '../../features/bills/domain/usecases/create_bill.dart';
import '../../features/bills/domain/usecases/delete_bill.dart';
import '../../features/bills/domain/usecases/get_bills.dart';
import '../../features/bills/domain/usecases/get_upcoming_bills.dart';
import '../../features/bills/domain/usecases/mark_bill_as_paid.dart';
import '../../features/bills/domain/usecases/update_bill.dart';
import '../../features/bills/domain/usecases/validate_bill_account.dart';
import '../../features/debt/data/datasources/debt_hive_datasource.dart';
import '../../features/debt/data/repositories/debt_repository_impl.dart';
import '../../features/debt/domain/repositories/debt_repository.dart';
import '../../features/debt/domain/usecases/create_debt.dart';
import '../../features/debt/domain/usecases/get_debts.dart';
import '../../features/debt/domain/usecases/update_debt.dart';
import '../../features/debt/domain/usecases/delete_debt.dart';
import '../../features/settings/presentation/providers/settings_providers.dart' as settings_providers;
import '../../features/recurring_incomes/domain/repositories/recurring_income_repository.dart';
import '../../features/recurring_incomes/data/repositories/recurring_income_repository_impl.dart';
import '../../features/recurring_incomes/domain/usecases/create_recurring_income.dart';
import '../../features/recurring_incomes/domain/usecases/get_recurring_incomes.dart';
import '../../features/recurring_incomes/domain/usecases/record_income_receipt.dart';
import '../../features/recurring_incomes/data/datasources/recurring_income_hive_datasource.dart';
import '../../features/recurring_incomes/presentation/providers/recurring_income_providers.dart' as recurring_income_providers;
import '../../features/notifications/presentation/providers/notification_providers.dart' as notification_providers;

/// Core providers for dependency injection
/// All app dependencies should be defined here

// Storage providers
final hiveStorageProvider = Provider<HiveStorage>((ref) {
  throw UnimplementedError('HiveStorage must be initialized in main.dart');
});

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

// Theme mode provider (now uses settings)
final themeModeProvider = settings_providers.themeModeProvider;

// Error logger provider
final errorLoggerProvider = Provider<ErrorLogger>((ref) {
  return ErrorLogger();
});

class ErrorLogger {
  void logError(Object error, StackTrace? stackTrace) {
    // TODO: Implement proper error logging (Sentry, Firebase Crashlytics, etc.)
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  void logInfo(String message) {
    debugPrint('Info: $message');
  }
}

// Transaction data sources
final transactionDataSourceProvider = Provider<TransactionHiveDataSource>((ref) {
  return TransactionHiveDataSource();
});

final transactionCategoryDataSourceProvider = Provider<TransactionCategoryHiveDataSource>((ref) {
  return TransactionCategoryHiveDataSource();
});

// Transaction repositories
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    ref.read(transactionDataSourceProvider),
    ref.read(accountRepositoryProvider),
    Hive.box<GoalContributionDto>('goal_contributions'),
  );
});

final transactionCategoryRepositoryProvider = Provider<TransactionCategoryRepository>((ref) {
  return TransactionCategoryRepositoryImpl(
    ref.read(transactionCategoryDataSourceProvider),
    // Remove circular dependency by not passing transactionRepository for now
    null, // Will be set later when needed
  );
});

// Category use cases
final getCategoriesProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.read(transactionCategoryRepositoryProvider));
});

final addCategoryProvider = Provider<AddCategory>((ref) {
  return AddCategory(ref.read(transactionCategoryRepositoryProvider));
});

final updateCategoryProvider = Provider<UpdateCategory>((ref) {
  return UpdateCategory(ref.read(transactionCategoryRepositoryProvider));
});

final deleteCategoryProvider = Provider<DeleteCategory>((ref) {
  return DeleteCategory(ref.read(transactionCategoryRepositoryProvider));
});

final archiveCategoryProvider = Provider<ArchiveCategory>((ref) {
  return ArchiveCategory(ref.read(transactionCategoryRepositoryProvider));
});

final unarchiveCategoryProvider = Provider<UnarchiveCategory>((ref) {
  return UnarchiveCategory(ref.read(transactionCategoryRepositoryProvider));
});

final reorderCategoriesProvider = Provider<ReorderCategories>((ref) {
  return ReorderCategories(ref.read(transactionCategoryRepositoryProvider));
});

// Transaction use cases
final addTransactionProvider = Provider<AddTransaction>((ref) {
  return AddTransaction(
    ref.read(transactionRepositoryProvider),
    ref.read(accountRepositoryProvider),
    ref.read(addGoalContributionProvider),
  );
});

final getTransactionsProvider = Provider<GetTransactions>((ref) {
  return GetTransactions(ref.read(transactionRepositoryProvider));
});

final updateTransactionProvider = Provider<UpdateTransaction>((ref) {
  return UpdateTransaction(
    ref.read(transactionRepositoryProvider),
    ref.read(accountRepositoryProvider),
  );
});

final deleteTransactionProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(
    ref.read(transactionRepositoryProvider),
    ref.read(accountRepositoryProvider),
    ref.read(billRepositoryProvider),
    ref.read(recurringIncomeRepositoryProvider),
  );
});

// Recurring Income repositories
final recurringIncomeRepositoryProvider = Provider<RecurringIncomeRepository>((ref) {
  return RecurringIncomeRepositoryImpl(
    ref.read(accountRepositoryProvider),
    ref.read(addTransactionProvider),
  );
});

// Recurring Income repositories
// final recurringIncomeRepositoryProvider = Provider<RecurringIncomeRepository>((ref) {
//   return RecurringIncomeRepositoryImpl(
//     ref.read(accountRepositoryProvider),
//     ref.read(addTransactionProvider),
//     ref.read(deleteTransactionProvider),
//   );
// });

final getPaginatedTransactionsProvider = Provider<GetPaginatedTransactions>((ref) {
  return GetPaginatedTransactions(ref.read(transactionRepositoryProvider));
});

// Account data sources
final accountDataSourceProvider = Provider<AccountHiveDataSource>((ref) {
  return AccountHiveDataSource();
});

// Account repositories
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.read(accountDataSourceProvider));
});

// Account use cases
final createAccountProvider = Provider<CreateAccount>((ref) {
  return CreateAccount(ref.read(accountRepositoryProvider));
});

final getAccountsProvider = Provider<GetAccounts>((ref) {
  return GetAccounts(ref.read(accountRepositoryProvider));
});

final updateAccountProvider = Provider<UpdateAccount>((ref) {
  return UpdateAccount(ref.read(accountRepositoryProvider));
});

final deleteAccountProvider = Provider<DeleteAccount>((ref) {
  return DeleteAccount(ref.read(accountRepositoryProvider));
});

final getAccountBalanceProvider = Provider<GetAccountBalance>((ref) {
  return GetAccountBalance(ref.read(accountRepositoryProvider));
});

final reconcileAccountBalanceProvider = Provider<ReconcileAccountBalance>((ref) {
  return ReconcileAccountBalance(
    ref.read(accountRepositoryProvider),
    ref.read(transactionRepositoryProvider),
  );
});

// Reconciliation service for scheduled reconciliation
final reconciliationServiceProvider = Provider<ReconciliationService>((ref) {
  return ReconciliationService(
    ref.read(reconcileAccountBalanceProvider),
    ref.read(getAccountsProvider),
    ref.read(errorLoggerProvider),
  );
});

class ReconciliationService {
  const ReconciliationService(
    this._reconcileAccountBalance,
    this._getAccounts,
    this._logger,
  );

  final ReconcileAccountBalance _reconcileAccountBalance;
  final GetAccounts _getAccounts;
  final ErrorLogger _logger;

  /// Reconcile all accounts
  Future<void> reconcileAllAccounts() async {
    final result = await _getAccounts();
    result.when(
      success: (accounts) async {
        for (final account in accounts) {
          await _reconcileAccountBalance(account.id);
        }
        _logger.logInfo('Reconciled ${accounts.length} accounts');
      },
      error: (failure) {
        _logger.logError(failure, null);
      },
    );
  }

  /// Reconcile specific account
  Future<void> reconcileAccount(String accountId) async {
    await _reconcileAccountBalance(accountId);
  }
}

// Budget data sources
final budgetDataSourceProvider = Provider<BudgetHiveDataSource>((ref) {
  return BudgetHiveDataSource();
});

// Budget repositories
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(
    ref.read(budgetDataSourceProvider),
    ref.read(calculateBudgetStatusProvider),
    ref.read(transactionCategoryRepositoryProvider),
  );
});

// Budget use cases
final createBudgetProvider = Provider<CreateBudget>((ref) {
  return CreateBudget(ref.read(budgetRepositoryProvider));
});

final getBudgetsProvider = Provider<GetBudgets>((ref) {
  return GetBudgets(ref.read(budgetRepositoryProvider));
});

final getActiveBudgetsProvider = Provider<GetActiveBudgets>((ref) {
  return GetActiveBudgets(ref.read(budgetRepositoryProvider));
});

final updateBudgetProvider = Provider<UpdateBudget>((ref) {
  return UpdateBudget(ref.read(budgetRepositoryProvider));
});

final deleteBudgetProvider = Provider<DeleteBudget>((ref) {
  return DeleteBudget(ref.read(budgetRepositoryProvider));
});

final calculateBudgetStatusProvider = Provider<CalculateBudgetStatus>((ref) {
  return CalculateBudgetStatus(ref.read(transactionRepositoryProvider));
});

// Bill data sources
final billDataSourceProvider = Provider<BillHiveDataSource>((ref) {
  // Return the singleton instance that was initialized during app startup
  if (_billDataSource == null) {
    debugPrint('BillDataSourceProvider: ERROR - Singleton instance should have been created during initialization');
    _billDataSource = BillHiveDataSource();
  } else {
    debugPrint('BillDataSourceProvider: Returning initialized singleton instance');
  }
  return _billDataSource!;
});

BillHiveDataSource? _billDataSource;

// Bill repositories
final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepositoryImpl(
    ref.read(transactionRepositoryProvider),
    ref.read(addTransactionProvider),
  );
});


// Bill use cases
final createBillProvider = Provider<CreateBill>((ref) {
  return CreateBill(
    ref.read(billRepositoryProvider),
    ref.read(accountRepositoryProvider),
  );
});

final getBillsProvider = Provider<GetBills>((ref) {
  return GetBills(ref.read(billRepositoryProvider));
});

final updateBillProvider = Provider<UpdateBill>((ref) {
  return UpdateBill(
    ref.read(billRepositoryProvider),
    ref.read(accountRepositoryProvider),
  );
});

final calculateBillsSummaryProvider = Provider<CalculateBillsSummary>((ref) {
  return CalculateBillsSummary(ref.read(billRepositoryProvider));
});

final deleteBillProvider = Provider<DeleteBill>((ref) {
  return DeleteBill(ref.read(billRepositoryProvider));
});

final markBillAsPaidProvider = Provider<MarkBillAsPaid>((ref) {
  return MarkBillAsPaid(
    ref.read(billRepositoryProvider),
    ref.read(accountRepositoryProvider),
  );
});

final getUpcomingBillsProvider = Provider<GetUpcomingBills>((ref) {
  return GetUpcomingBills(ref.read(billRepositoryProvider));
});

final validateBillAccountProvider = Provider<ValidateBillAccount>((ref) {
  return ValidateBillAccount(ref.read(accountRepositoryProvider));
});

// Debt data sources
final debtDataSourceProvider = Provider<DebtHiveDataSource>((ref) {
  return DebtHiveDataSourceImpl();
});

// Debt repositories
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepositoryImpl(ref.read(debtDataSourceProvider));
});

// Debt use cases
final createDebtProvider = Provider<CreateDebt>((ref) {
  return CreateDebt(ref.read(debtRepositoryProvider));
});

final getDebtsProvider = Provider<GetDebts>((ref) {
  return GetDebts(ref.read(debtRepositoryProvider));
});

final updateDebtProvider = Provider<UpdateDebt>((ref) {
  return UpdateDebt(ref.read(debtRepositoryProvider));
});

final deleteDebtProvider = Provider<DeleteDebt>((ref) {
  return DeleteDebt(ref.read(debtRepositoryProvider));
});

// Goal data sources
final goalDataSourceProvider = Provider<GoalHiveDataSource>((ref) {
  return GoalHiveDataSource();
});

// Goal repositories
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(
    ref.read(goalDataSourceProvider),
    ref.read(transactionCategoryRepositoryProvider),
  );
});

// Goal use cases
final createGoalProvider = Provider<CreateGoal>((ref) {
  return CreateGoal(ref.read(goalRepositoryProvider));
});

final getGoalsProvider = Provider<GetGoals>((ref) {
  return GetGoals(ref.read(goalRepositoryProvider));
});

final getActiveGoalsProvider = Provider<GetActiveGoals>((ref) {
  return GetActiveGoals(ref.read(goalRepositoryProvider));
});

final getCompletedGoalsProvider = Provider<GetCompletedGoals>((ref) {
  return GetCompletedGoals(ref.read(goalRepositoryProvider));
});

final getGoalByIdProvider = Provider<GetGoalById>((ref) {
  return GetGoalById(ref.read(goalRepositoryProvider));
});

final updateGoalProvider = Provider<UpdateGoal>((ref) {
  return UpdateGoal(ref.read(goalRepositoryProvider));
});

final deleteGoalProvider = Provider<DeleteGoal>((ref) {
  return DeleteGoal(ref.read(goalRepositoryProvider));
});

final addGoalContributionProvider = Provider<add_goal_contribution_usecase.AddGoalContribution>((ref) {
  return add_goal_contribution_usecase.AddGoalContribution(ref.read(goalRepositoryProvider));
});

final validateGoalAllocationProvider = Provider<ValidateGoalAllocation>((ref) {
  return ValidateGoalAllocation(ref.read(goalRepositoryProvider));
});

final allocateToGoalsProvider = Provider<allocate_to_goals_usecase.AllocateToGoals>((ref) {
  return allocate_to_goals_usecase.AllocateToGoals(ref.read(goalRepositoryProvider));
});

// Insight data sources
final insightDataSourceProvider = Provider<InsightHiveDataSource>((ref) {
  return InsightHiveDataSource(ref.read(transactionRepositoryProvider), ref.read(budgetRepositoryProvider));
});

// Insight repositories
final insightRepositoryProvider = Provider<InsightRepository>((ref) {
  return InsightRepositoryImpl(ref.read(insightDataSourceProvider));
});

// Insight use cases
final getInsightsProvider = Provider<GetInsights>((ref) {
  return GetInsights(ref.read(insightRepositoryProvider));
});

final getRecentInsightsProvider = Provider<GetRecentInsights>((ref) {
  return GetRecentInsights(ref.read(insightRepositoryProvider));
});

final markInsightAsReadProvider = Provider<MarkInsightAsRead>((ref) {
  return MarkInsightAsRead(ref.read(insightRepositoryProvider));
});

final generateInsightsSummaryProvider = Provider<GenerateInsightsSummary>((ref) {
  return GenerateInsightsSummary(ref.read(insightRepositoryProvider));
});

final calculateFinancialHealthScoreProvider = Provider<CalculateFinancialHealthScore>((ref) {
  return CalculateFinancialHealthScore(ref.read(insightRepositoryProvider));
});

final createFinancialReportProvider = Provider<CreateFinancialReport>((ref) {
  return CreateFinancialReport(ref.read(insightRepositoryProvider));
});

final getFinancialReportsProvider = Provider<GetFinancialReports>((ref) {
  return GetFinancialReports(ref.read(insightRepositoryProvider));
});

// App initialization provider
final appInitializationProvider = FutureProvider<void>((ref) async {
  try {
    // Initialize storage
    await HiveStorage.init();
    ref.read(errorLoggerProvider).logInfo('Hive storage initialized');

    // Initialize data sources in dependency order
    // Start with core data sources that others depend on

    ref.read(errorLoggerProvider).logInfo('Initializing account data source');
    final accountDataSource = ref.read(accountDataSourceProvider);
    await accountDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Account data source initialized');

    ref.read(errorLoggerProvider).logInfo('Initializing transaction data source');
    final transactionDataSource = ref.read(transactionDataSourceProvider);
    await transactionDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Transaction data source initialized');

    ref.read(errorLoggerProvider).logInfo('Initializing category data source');
    final categoryDataSource = ref.read(transactionCategoryDataSourceProvider);
    await categoryDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Category data source initialized');

    ref.read(errorLoggerProvider).logInfo('Initializing budget data source');
    final budgetDataSource = ref.read(budgetDataSourceProvider);
    await budgetDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Budget data source initialized');

    ref.read(errorLoggerProvider).logInfo('Initializing bill data source');
    final billDataSource = ref.read(billDataSourceProvider); // This creates the singleton
    await billDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Bill data source initialized');

    ref.read(errorLoggerProvider).logInfo('Initializing goal data source');
    final goalDataSource = ref.read(goalDataSourceProvider);
    await goalDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Goal data source initialized');

    ref.read(errorLoggerProvider).logInfo('Initializing insight data source');
    final insightDataSource = ref.read(insightDataSourceProvider);
    await insightDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Insight data source initialized');

    ref.read(errorLoggerProvider).logInfo('Initializing settings data source');
    final settingsDataSource = ref.read(settings_providers.settingsDataSourceProvider);
    await settingsDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Settings data source initialized');

    ref.read(errorLoggerProvider).logInfo('Initializing debt data source');
    final debtDataSource = ref.read(debtDataSourceProvider);
    await debtDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Debt data source initialized');


    // Initialize recurring income data source (depends on transaction data source)
    ref.read(errorLoggerProvider).logInfo('Initializing recurring income data source');
    final recurringIncomeDataSource = ref.read(recurringIncomeDataSourceProvider);
    await recurringIncomeDataSource.init();
    ref.read(errorLoggerProvider).logInfo('Recurring income data source initialized');

    // Initialize onboarding data source (depends on user profile)
    ref.read(errorLoggerProvider).logInfo('Initializing user profile data source');
    final userProfileDataSource = ref.read(onboarding_providers.userProfileDataSourceProvider);
    await userProfileDataSource.init();
    ref.read(errorLoggerProvider).logInfo('User profile data source initialized');

    // Initialize notification service
    ref.read(errorLoggerProvider).logInfo('Initializing notification service');
    final notificationService = ref.read(notification_providers.notificationServiceProvider);
    await notificationService.initialize();
    ref.read(errorLoggerProvider).logInfo('Notification service initialized');

    // Initialize other services here as needed

    ref.read(errorLoggerProvider).logInfo('App initialized successfully');
    // Note: Onboarding state is initialized lazily when accessed
  } catch (e, stackTrace) {
    ref.read(errorLoggerProvider).logError(e, stackTrace);
    rethrow;
  }
});
// Recurring Income data sources
final recurringIncomeDataSourceProvider = Provider<RecurringIncomeHiveDataSource>((ref) {
  return RecurringIncomeHiveDataSource();
});

// Recurring Income use cases
final createRecurringIncomeProvider = Provider<CreateRecurringIncome>((ref) {
  return CreateRecurringIncome(
    ref.read(recurringIncomeRepositoryProvider),
    ref.read(accountRepositoryProvider),
  );
});

final getRecurringIncomesProvider = Provider<GetRecurringIncomes>((ref) {
  return GetRecurringIncomes(ref.read(recurringIncomeRepositoryProvider));
});

final recordIncomeReceiptProvider = Provider<RecordIncomeReceipt>((ref) {
  return RecordIncomeReceipt(ref.read(recurringIncomeRepositoryProvider));
});

// Recurring Income notifier provider
final recurringIncomeNotifierProvider = recurring_income_providers.recurringIncomeNotifierProvider;
