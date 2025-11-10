import '../../../../core/error/result.dart';
import '../entities/transaction.dart';

/// Repository interface for transaction category operations
abstract class TransactionCategoryRepository {
  /// Get all categories
  Future<Result<List<TransactionCategory>>> getAll();

  /// Get category by ID
  Future<Result<TransactionCategory?>> getById(String id);

  /// Get categories by type
  Future<Result<List<TransactionCategory>>> getByType(TransactionType type);

  /// Get active (non-archived) categories
  Future<Result<List<TransactionCategory>>> getActive();

  /// Get archived categories
  Future<Result<List<TransactionCategory>>> getArchived();

  /// Add new category
  Future<Result<TransactionCategory>> add(TransactionCategory category);

  /// Update existing category
  Future<Result<TransactionCategory>> update(TransactionCategory category);

  /// Delete category by ID
  Future<Result<void>> delete(String id);

  /// Check if category is in use by any transactions
  Future<Result<bool>> isCategoryInUse(String categoryId);
}