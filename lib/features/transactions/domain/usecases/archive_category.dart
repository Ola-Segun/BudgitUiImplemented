import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_category_repository.dart';

/// Use case for archiving a transaction category
class ArchiveCategory {
  const ArchiveCategory(this._repository);

  final TransactionCategoryRepository _repository;

  /// Execute the use case
  Future<Result<TransactionCategory>> call(String categoryId) async {
    try {
      // Get the category to archive
      final categoryResult = await _repository.getById(categoryId);
      if (categoryResult.isError) {
        return Result.error(categoryResult.failureOrNull!);
      }

      final category = categoryResult.dataOrNull;
      if (category == null) {
        return Result.error(Failure.notFound('Category not found'));
      }

      // Create archived version
      final archivedCategory = category.copyWith(isArchived: true);

      // Update category
      return await _repository.update(archivedCategory);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to archive category: $e'));
    }
  }
}