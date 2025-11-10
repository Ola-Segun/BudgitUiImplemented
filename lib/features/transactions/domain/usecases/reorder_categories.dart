import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_category_repository.dart';

/// Use case for reordering categories
class ReorderCategories {
  final TransactionCategoryRepository _repository;

  const ReorderCategories(this._repository);

  /// Reorders categories by updating their order field
  /// [categoryIds] should be in the desired order
  Future<Result<void>> call(List<String> categoryIds) async {
    try {
      // Get all categories
      final result = await _repository.getAll();
      if (result.isError) {
        return Result.error(result.failureOrNull!);
      }

      final categories = result.dataOrNull ?? [];
      // Create updated categories with new order
      final updatedCategories = <TransactionCategory>[];

      for (int i = 0; i < categoryIds.length; i++) {
        final categoryId = categoryIds[i];
        final category = categories.firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () => throw Exception('Category not found: $categoryId'),
        );

        // Update order
        final updatedCategory = category.copyWith(order: i);
        updatedCategories.add(updatedCategory);
      }

      // Update all categories in repository
      for (final category in updatedCategories) {
        final updateResult = await _repository.update(category);
        if (updateResult.isError) {
          return Result.error(updateResult.failureOrNull!);
        }
      }

      return const Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to reorder categories: $e'));
    }
  }
}