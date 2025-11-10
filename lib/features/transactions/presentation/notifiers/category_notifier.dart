import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/archive_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/unarchive_category.dart';
import '../../domain/usecases/update_category.dart';
import '../states/category_state.dart';

/// State notifier for category management
class CategoryNotifier extends StateNotifier<AsyncValue<CategoryState>> {
  final GetCategories _getCategories;
  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;
  final ArchiveCategory _archiveCategory;
  final UnarchiveCategory _unarchiveCategory;

  CategoryNotifier({
    required GetCategories getCategories,
    required AddCategory addCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
    required ArchiveCategory archiveCategory,
    required UnarchiveCategory unarchiveCategory,
  })  : _getCategories = getCategories,
        _addCategory = addCategory,
        _updateCategory = updateCategory,
        _deleteCategory = deleteCategory,
        _archiveCategory = archiveCategory,
        _unarchiveCategory = unarchiveCategory,
        super(const AsyncValue.loading()) {
    loadCategories();
  }

  /// Load all categories from repository
  Future<void> loadCategories() async {
    state = const AsyncValue.loading();

    final result = await _getCategories();

    result.when(
      success: (categories) {
        state = AsyncValue.data(CategoryState(categories: categories));
      },
      error: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
    );
  }

  /// Add a new category
  Future<bool> addCategory(TransactionCategory category) async {
    final currentState = state.value;
    if (currentState == null) return false;

    // Optimistically add category to local state
    final optimisticCategories = [...currentState.categories, category];
    state = AsyncValue.data(currentState.copyWith(
      categories: optimisticCategories,
      isOperationInProgress: true,
      operationError: null,
    ));

    final result = await _addCategory(category);

    return result.when(
      success: (addedCategory) {
        // Update with server response and clear operation state
        final updatedCategories = currentState.categories.map((c) => c.id == category.id ? addedCategory : c).toList();
        if (!updatedCategories.contains(addedCategory)) {
          updatedCategories.add(addedCategory);
        }
        state = AsyncValue.data(CategoryState(
          categories: updatedCategories,
          isOperationInProgress: false,
          operationError: null,
        ));
        return true;
      },
      error: (failure) {
        // Revert to original state with error
        state = AsyncValue.data(currentState.copyWith(
          isOperationInProgress: false,
          operationError: failure.message,
        ));
        return false;
      },
    );
  }

  /// Update an existing category
  Future<bool> updateCategory(TransactionCategory category) async {
    final currentState = state.value;
    if (currentState == null) return false;

    // Optimistically update category in local state
    final optimisticCategories = currentState.categories.map((c) => c.id == category.id ? category : c).toList();
    state = AsyncValue.data(currentState.copyWith(
      categories: optimisticCategories,
      isOperationInProgress: true,
      operationError: null,
    ));

    final result = await _updateCategory(category);

    return result.when(
      success: (updatedCategory) {
        // Update with server response and clear operation state
        final finalCategories = currentState.categories.map((c) => c.id == category.id ? updatedCategory : c).toList();
        state = AsyncValue.data(CategoryState(
          categories: finalCategories,
          isOperationInProgress: false,
          operationError: null,
        ));
        return true;
      },
      error: (failure) {
        // Revert to original state with error
        state = AsyncValue.data(currentState.copyWith(
          isOperationInProgress: false,
          operationError: failure.message,
        ));
        return false;
      },
    );
  }

  /// Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    // Optimistically remove category from local state
    final optimisticCategories = currentState.categories.where((c) => c.id != categoryId).toList();
    state = AsyncValue.data(currentState.copyWith(
      categories: optimisticCategories,
      isOperationInProgress: true,
      operationError: null,
    ));

    final result = await _deleteCategory(categoryId);

    return result.when(
      success: (_) {
        // Keep the optimistic update and clear operation state
        state = AsyncValue.data(CategoryState(
          categories: optimisticCategories,
          isOperationInProgress: false,
          operationError: null,
        ));
        return true;
      },
      error: (failure) {
        // Revert to original state with error
        state = AsyncValue.data(currentState.copyWith(
          isOperationInProgress: false,
          operationError: failure.message,
        ));
        return false;
      },
    );
  }

  /// Get categories by type
  List<TransactionCategory> getCategoriesByType(TransactionType type) {
    final currentState = state.value;
    return currentState?.getCategoriesByType(type) ?? [];
  }

  /// Get income categories
  List<TransactionCategory> get incomeCategories => getCategoriesByType(TransactionType.income);

  /// Get expense categories
  List<TransactionCategory> get expenseCategories => getCategoriesByType(TransactionType.expense);

  /// Find category by ID
  TransactionCategory? getCategoryById(String id) {
    final currentState = state.value;
    return currentState?.getCategoryById(id);
  }

  /// Check if category exists
  bool hasCategory(String id) {
    final currentState = state.value;
    return currentState?.hasCategory(id) ?? false;
  }

  /// Archive a category
  Future<bool> archiveCategory(String categoryId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    // Optimistically update category in local state
    final optimisticCategories = currentState.categories.map((c) => c.id == categoryId ? c.copyWith(isArchived: true) : c).toList();
    state = AsyncValue.data(currentState.copyWith(
      categories: optimisticCategories,
      isOperationInProgress: true,
      operationError: null,
    ));

    final result = await _archiveCategory(categoryId);

    return result.when(
      success: (archivedCategory) {
        // Update with server response and clear operation state
        final finalCategories = currentState.categories.map((c) => c.id == categoryId ? archivedCategory : c).toList();
        state = AsyncValue.data(CategoryState(
          categories: finalCategories,
          isOperationInProgress: false,
          operationError: null,
        ));
        return true;
      },
      error: (failure) {
        // Revert to original state with error
        state = AsyncValue.data(currentState.copyWith(
          isOperationInProgress: false,
          operationError: failure.message,
        ));
        return false;
      },
    );
  }

  /// Unarchive a category
  Future<bool> unarchiveCategory(String categoryId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    // Optimistically update category in local state
    final optimisticCategories = currentState.categories.map((c) => c.id == categoryId ? c.copyWith(isArchived: false) : c).toList();
    state = AsyncValue.data(currentState.copyWith(
      categories: optimisticCategories,
      isOperationInProgress: true,
      operationError: null,
    ));

    final result = await _unarchiveCategory(categoryId);

    return result.when(
      success: (unarchivedCategory) {
        // Update with server response and clear operation state
        final finalCategories = currentState.categories.map((c) => c.id == categoryId ? unarchivedCategory : c).toList();
        state = AsyncValue.data(CategoryState(
          categories: finalCategories,
          isOperationInProgress: false,
          operationError: null,
        ));
        return true;
      },
      error: (failure) {
        // Revert to original state with error
        state = AsyncValue.data(currentState.copyWith(
          isOperationInProgress: false,
          operationError: failure.message,
        ));
        return false;
      },
    );
  }

  /// Clear operation error
  void clearOperationError() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(operationError: null));
    }
  }
}