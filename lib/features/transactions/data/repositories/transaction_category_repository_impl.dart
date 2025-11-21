import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_category_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_category_hive_datasource.dart';

/// Implementation of TransactionCategoryRepository using Hive data source
class TransactionCategoryRepositoryImpl implements TransactionCategoryRepository {
  const TransactionCategoryRepositoryImpl(
    this._dataSource,
    this._transactionRepository,
  );

  final TransactionCategoryHiveDataSource _dataSource;
  final TransactionRepository? _transactionRepository;

  @override
  Future<Result<List<TransactionCategory>>> getAll() => _dataSource.getAll();

  @override
  Future<Result<TransactionCategory?>> getById(String id) => _dataSource.getById(id);

  @override
  Future<Result<List<TransactionCategory>>> getByType(TransactionType type) =>
      _dataSource.getByType(type);

  @override
  Future<Result<TransactionCategory>> add(TransactionCategory category) =>
      _dataSource.add(category);

  @override
  Future<Result<TransactionCategory>> update(TransactionCategory category) =>
      _dataSource.update(category);

  @override
  Future<Result<void>> delete(String id) => _dataSource.delete(id);

  @override
  Future<Result<List<TransactionCategory>>> getActive() => _dataSource.getActive();

  @override
  Future<Result<List<TransactionCategory>>> getArchived() => _dataSource.getArchived();

  @override
  Future<Result<bool>> isCategoryInUse(String categoryId) async {
    try {
      // Check if category is used by any transactions
      final transactionsResult = _transactionRepository != null
          ? await _transactionRepository!.getByCategory(categoryId)
          : Result.success([]); // Return empty if transaction repository is not available
      
      if (transactionsResult.isError) {
        return Result.error(transactionsResult.failureOrNull!);
      }

      final transactions = transactionsResult.dataOrNull ?? [];
      if (transactions.isNotEmpty) {
        return Result.success(true);
      }

      // Note: Bill usage check removed to break circular dependency
      // This check should be done at a higher level if needed
      return Result.success(false);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to check category usage: $e'));
    }
  }
}