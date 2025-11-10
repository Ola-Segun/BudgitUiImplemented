import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/transaction.dart';

part 'category_state.freezed.dart';

/// State for category management
@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState({
    @Default([]) List<TransactionCategory> categories,
    @Default(false) bool isOperationInProgress,
    String? operationError,
  }) = _CategoryState;

  const CategoryState._();

  /// Get sorted categories by order field
  List<TransactionCategory> get sortedCategories {
    final sorted = List<TransactionCategory>.from(categories);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// Get categories by type
  List<TransactionCategory> getCategoriesByType(TransactionType type) {
    return categories.where((category) => category.type == type).toList();
  }

  /// Get income categories
  List<TransactionCategory> get incomeCategories => getCategoriesByType(TransactionType.income);

  /// Get expense categories
  List<TransactionCategory> get expenseCategories => getCategoriesByType(TransactionType.expense);

  /// Get transfer categories (if any)
  List<TransactionCategory> get transferCategories => getCategoriesByType(TransactionType.transfer);

  /// Get active (non-archived) categories
  List<TransactionCategory> get activeCategories => categories.where((category) => !category.isArchived).toList();

  /// Get archived categories
  List<TransactionCategory> get archivedCategories => categories.where((category) => category.isArchived).toList();

  /// Get active income categories
  List<TransactionCategory> get activeIncomeCategories => activeCategories.where((category) => category.type == TransactionType.income).toList();

  /// Get active expense categories
  List<TransactionCategory> get activeExpenseCategories => activeCategories.where((category) => category.type == TransactionType.expense).toList();

  /// Get archived income categories
  List<TransactionCategory> get archivedIncomeCategories => archivedCategories.where((category) => category.type == TransactionType.income).toList();

  /// Get archived expense categories
  List<TransactionCategory> get archivedExpenseCategories => archivedCategories.where((category) => category.type == TransactionType.expense).toList();

  /// Find category by ID
  TransactionCategory? getCategoryById(String id) {
    return categories.where((category) => category.id == id).firstOrNull;
  }

  /// Check if category exists
  bool hasCategory(String id) {
    return categories.any((category) => category.id == id);
  }
}