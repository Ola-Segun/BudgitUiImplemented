import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_category_repository.dart';

/// Use case for unarchiving a transaction category
class UnarchiveCategory {
  const UnarchiveCategory(this._repository);

  final TransactionCategoryRepository _repository;

  /// Execute the use case
  Future<Result<TransactionCategory>> call(String categoryId) async {
    try {
      // Get the category to unarchive
      final categoryResult = await _repository.getById(categoryId);
      if (categoryResult.isError) {
        return Result.error(categoryResult.failureOrNull!);
      }

      final category = categoryResult.dataOrNull;
      if (category == null) {
        return Result.error(Failure.notFound('Category not found'));
      }

      // Create unarchived version
      final unarchivedCategory = category.copyWith(isArchived: false);

      // Update category
      return await _repository.update(unarchivedCategory);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to unarchive category: $e'));
    }
  }
}