import 'package:hive/hive.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../goals/data/models/goal_contribution_dto.dart';
import '../../../goals/data/models/goal_contribution_mapper.dart';
import '../../../goals/domain/entities/goal_contribution.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_hive_datasource.dart';
import '../datasources/transaction_category_hive_datasource.dart';

/// Implementation of TransactionRepository using Hive data source
class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(
    this._dataSource,
    this._accountRepository,
    this._contributionBox,
  );

  final TransactionHiveDataSource _dataSource;
  final AccountRepository _accountRepository;
  final Box<GoalContributionDto> _contributionBox;

  @override
  Future<Result<List<Transaction>>> getAll() => _dataSource.getAll();

  @override
  Future<Result<Transaction?>> getById(String id) => _dataSource.getById(id);

  @override
  Future<Result<List<Transaction>>> getByDateRange(DateTime start, DateTime end) =>
      _dataSource.getByDateRange(start, end);

  @override
  Future<Result<List<Transaction>>> getByCategory(String categoryId) =>
      _dataSource.getByCategory(categoryId);

  @override
  Future<Result<List<Transaction>>> getByType(TransactionType type) =>
      _dataSource.getByType(type);

  @override
  Future<Result<Transaction>> add(Transaction transaction) async {
    final result = await _dataSource.add(transaction);
    if (result.isSuccess) {
      // Update category usage count
      await _updateCategoryUsage(transaction.categoryId);
    }
    return result;
  }

  @override
  Future<Result<Transaction>> update(Transaction transaction) =>
      _dataSource.update(transaction);

  @override
  Future<Result<void>> delete(String id) => _dataSource.delete(id);

  @override
  Future<Result<double>> getTotalAmount(DateTime start, DateTime end, {TransactionType? type}) =>
      _dataSource.getTotalAmount(start, end, type: type);

  @override
  Future<Result<List<Transaction>>> search(String query) =>
      _dataSource.search(query);

  @override
  Future<Result<int>> getCount() => _dataSource.getCount();


  @override
  Future<Result<List<Transaction>>> getPaginated({
    int limit = 20,
    int offset = 0,
    TransactionFilter? filter,
  }) async {
    return getTransactionsPaginated(limit: limit, offset: offset, filter: filter);
  }

  @override
  Future<Result<List<Transaction>>> getTransactionsPaginated({
    int limit = 20,
    int offset = 0,
    TransactionFilter? filter,
  }) async {
    try {
      // Get all transactions first (in a real app, this would be optimized)
      final allResult = await _dataSource.getAll();
      if (allResult.isError) {
        return Result.error(allResult.failureOrNull!);
      }

      var transactions = allResult.dataOrNull!;

      // Apply filters if provided
      if (filter != null && filter.isNotEmpty) {
        transactions = transactions.where((transaction) {
          // Filter by transaction type
          if (filter.transactionType != null &&
              transaction.type != filter.transactionType) {
            return false;
          }

          // Filter by categories (multi-select)
          if (filter.categoryIds != null && filter.categoryIds!.isNotEmpty &&
              !filter.categoryIds!.contains(transaction.categoryId)) {
            return false;
          }

          // Filter by account
          if (filter.accountId != null &&
              transaction.accountId != filter.accountId) {
            return false;
          }

          // Filter by date range
          if (filter.startDate != null &&
              transaction.date.isBefore(filter.startDate!)) {
            return false;
          }
          if (filter.endDate != null &&
              transaction.date.isAfter(filter.endDate!)) {
            return false;
          }

          // Filter by amount range
          if (filter.minAmount != null &&
              transaction.amount < filter.minAmount!) {
            return false;
          }
          if (filter.maxAmount != null &&
              transaction.amount > filter.maxAmount!) {
            return false;
          }

          return true;
        }).toList();
      }

      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      // Apply pagination
      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, transactions.length);

      if (startIndex >= transactions.length) {
        return const Result.success([]);
      }

      final paginatedTransactions = transactions.sublist(startIndex, endIndex);
      return Result.success(paginatedTransactions);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get paginated transactions: $e'));
    }
  }

  @override
  Future<Result<List<Transaction>>> getTransactionsPaginatedByDateRange(
    DateTime start,
    DateTime end, {
    int limit = 20,
    int offset = 0,
    TransactionFilter? filter,
  }) async {
    try {
      // Get transactions by date range first
      final dateRangeResult = await _dataSource.getByDateRange(start, end);
      if (dateRangeResult.isError) {
        return Result.error(dateRangeResult.failureOrNull!);
      }

      var transactions = dateRangeResult.dataOrNull!;

      // Apply additional filters if provided
      if (filter != null && filter.isNotEmpty) {
        transactions = transactions.where((transaction) {
          // Filter by transaction type
          if (filter.transactionType != null &&
              transaction.type != filter.transactionType) {
            return false;
          }

          // Filter by categories (multi-select)
          if (filter.categoryIds != null && filter.categoryIds!.isNotEmpty &&
              !filter.categoryIds!.contains(transaction.categoryId)) {
            return false;
          }

          // Filter by account
          if (filter.accountId != null &&
              transaction.accountId != filter.accountId) {
            return false;
          }

          // Filter by amount range
          if (filter.minAmount != null &&
              transaction.amount < filter.minAmount!) {
            return false;
          }
          if (filter.maxAmount != null &&
              transaction.amount > filter.maxAmount!) {
            return false;
          }

          return true;
        }).toList();
      }

      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      // Apply pagination
      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, transactions.length);

      if (startIndex >= transactions.length) {
        return const Result.success([]);
      }

      final paginatedTransactions = transactions.sublist(startIndex, endIndex);
      return Result.success(paginatedTransactions);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get paginated transactions by date range: $e'));
    }
  }

  @override
  Future<Result<int>> getFilteredCount(TransactionFilter? filter) async {
    try {
      // Get all transactions first (in a real app, this would be optimized)
      final allResult = await _dataSource.getAll();
      if (allResult.isError) {
        return Result.error(allResult.failureOrNull!);
      }

      var transactions = allResult.dataOrNull!;

      // Apply filters if provided
      if (filter != null && filter.isNotEmpty) {
        transactions = transactions.where((transaction) {
          // Filter by transaction type
          if (filter.transactionType != null &&
              transaction.type != filter.transactionType) {
            return false;
          }

          // Filter by categories (multi-select)
          if (filter.categoryIds != null && filter.categoryIds!.isNotEmpty &&
              !filter.categoryIds!.contains(transaction.categoryId)) {
            return false;
          }

          // Filter by account
          if (filter.accountId != null &&
              transaction.accountId != filter.accountId) {
            return false;
          }

          // Filter by date range
          if (filter.startDate != null &&
              transaction.date.isBefore(filter.startDate!)) {
            return false;
          }
          if (filter.endDate != null &&
              transaction.date.isAfter(filter.endDate!)) {
            return false;
          }

          // Filter by amount range
          if (filter.minAmount != null &&
              transaction.amount < filter.minAmount!) {
            return false;
          }
          if (filter.maxAmount != null &&
              transaction.amount > filter.maxAmount!) {
            return false;
          }

          return true;
        }).toList();
      }

      return Result.success(transactions.length);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get filtered count: $e'));
    }
  }

  @override
  Future<Result<List<Transaction>>> getByAccountId(String accountId) async {
    try {
      final allResult = await _dataSource.getAll();
      if (allResult.isError) {
        return Result.error(allResult.failureOrNull!);
      }

      final transactions = allResult.dataOrNull!
          .where((transaction) =>
              transaction.accountId == accountId ||
              transaction.toAccountId == accountId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Recent first

      return Result.success(transactions);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get transactions by account ID: $e'));
    }
  }

  @override
  Future<Result<Map<String, double>>> getBalancesByAccount() async {
    try {
      final accountsResult = await _accountRepository.getAll();
      if (accountsResult.isError) {
        return Result.error(accountsResult.failureOrNull!);
      }

      final accounts = accountsResult.dataOrNull!;
      final balances = <String, double>{};

      // Initialize all accounts with 0
      for (final account in accounts) {
        balances[account.id] = 0.0;
      }

      // Get all transactions
      final transactionsResult = await _dataSource.getAll();
      if (transactionsResult.isError) {
        return Result.error(transactionsResult.failureOrNull!);
      }

      final transactions = transactionsResult.dataOrNull!;

      // Calculate balances from transactions
      for (final transaction in transactions) {
        if (transaction.accountId != null && balances.containsKey(transaction.accountId)) {
          final impact = _calculateTransactionImpact(transaction, transaction.accountId!);
          balances[transaction.accountId!] = balances[transaction.accountId!]! + impact;
        }

        // Handle transfer destination
        if (transaction.isTransfer && transaction.toAccountId != null && balances.containsKey(transaction.toAccountId)) {
          balances[transaction.toAccountId!] = balances[transaction.toAccountId!]! + transaction.amount;
        }
      }

      return Result.success(balances);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to calculate balances by account: $e'));
    }
  }

  @override
  Future<Result<double>> getCalculatedBalance(String accountId) async {
    try {
      final transactionsResult = await getByAccountId(accountId);
      if (transactionsResult.isError) {
        return Result.error(transactionsResult.failureOrNull!);
      }

      final transactions = transactionsResult.dataOrNull!;
      double balance = 0.0;

      for (final transaction in transactions) {
        balance += _calculateTransactionImpact(transaction, accountId);
      }

      return Result.success(balance);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to calculate balance for account: $e'));
    }
  }

  /// Calculate the impact of a transaction on an account's balance
  double _calculateTransactionImpact(Transaction transaction, [String? specificAccountId]) {
    final accountId = specificAccountId ?? transaction.accountId;

    if (transaction.type == TransactionType.income) {
      return transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      return -transaction.amount;
    } else if (transaction.type == TransactionType.transfer) {
      // For transfers, check if this account is source or destination
      if (transaction.accountId == accountId) {
        // This account is the source (money leaving)
        return -(transaction.amount + (transaction.transferFee ?? 0));
      } else if (transaction.toAccountId == accountId) {
        // This account is the destination (money arriving)
        return transaction.amount;
      }
    }

    return 0.0;
  }

  /// Update category usage count when a transaction is added
  Future<void> _updateCategoryUsage(String categoryId) async {
    try {
      // Get current category from category data source
      final categoryDataSource = TransactionCategoryHiveDataSource();
      await categoryDataSource.init();

      final categoryResult = await categoryDataSource.getById(categoryId);
      if (categoryResult.isError) return;

      final currentCategory = categoryResult.dataOrNull!;
      final updatedCategory = currentCategory.copyWith(
        usageCount: currentCategory.usageCount + 1,
      );

      // Update category in data source
      await categoryDataSource.update(updatedCategory);
    } catch (e) {
      // Silently fail - usage tracking is not critical
      return;
    }
  }

  /// Get goal allocations for a transaction
  Future<List<GoalContribution>?> _getGoalAllocations(List<String>? allocationIds) async {
    if (allocationIds == null || allocationIds.isEmpty) {
      return null;
    }

    try {
      final allocations = allocationIds
          .map((id) => _contributionBox.get(id))
          .whereType<GoalContributionDto>()
          .map(GoalContributionMapper.toDomain)
          .toList();

      return allocations;
    } catch (e) {
      // Silently fail goal allocations loading - don't fail the transaction loading
      return null;
    }
  }

}