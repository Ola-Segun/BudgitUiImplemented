import 'package:hive/hive.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/hive_storage.dart';
import '../models/transaction_dto.dart';
import '../../domain/entities/transaction.dart';

/// Hive-based data source for transaction category operations
class TransactionCategoryHiveDataSource {
  static const String _boxName = 'categories';

  Box<TransactionCategoryDto>? _box;

  /// Initialize the data source
  Future<void> init() async {
    // Wait for Hive to be initialized
    await HiveStorage.init();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionDtoAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionCategoryDtoAdapter());
    }

    // Handle box opening with proper type checking
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<TransactionCategoryDto>(_boxName);

      // Initialize with default categories if empty
      if (_box!.isEmpty) {
        await _initializeDefaultCategories();
      }
    } else {
      try {
        _box = Hive.box<TransactionCategoryDto>(_boxName);
      } catch (e) {
        // If the box is already open with wrong type, close and reopen
        if (e.toString().contains('Box<dynamic>')) {
          await Hive.box(_boxName).close();
          _box = await Hive.openBox<TransactionCategoryDto>(_boxName);

          // Initialize with default categories if empty
          if (_box!.isEmpty) {
            await _initializeDefaultCategories();
          }
        } else {
          rethrow;
        }
      }
    }
  }

  /// Initialize default categories
  Future<void> _initializeDefaultCategories() async {
    final defaultCategories = TransactionCategory.defaultCategories;
    for (final category in defaultCategories) {
      final dto = TransactionCategoryDto.fromDomain(category);
      await _box!.put(category.id, dto);
    }
  }

  /// Get all categories
  Future<Result<List<TransactionCategory>>> getAll() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _box!.values.toList();
      final categories = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by name
      categories.sort((a, b) => a.name.compareTo(b.name));

      return Result.success(categories);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get categories: $e'));
    }
  }

  /// Get category by ID
  Future<Result<TransactionCategory?>> getById(String id) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = _box!.get(id);
      if (dto == null) {
        return Result.success(null);
      }

      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.error(Failure.cache('Failed to get category: $e'));
    }
  }

  /// Get categories by type
  Future<Result<List<TransactionCategory>>> getByType(TransactionType type) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _box!.values.where((dto) => dto.type == type.name).toList();
      final categories = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by name
      categories.sort((a, b) => a.name.compareTo(b.name));

      return Result.success(categories);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get categories by type: $e'));
    }
  }

  /// Get active (non-archived) categories
  Future<Result<List<TransactionCategory>>> getActive() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _box!.values.where((dto) => !dto.isArchived).toList();
      final categories = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by name
      categories.sort((a, b) => a.name.compareTo(b.name));

      return Result.success(categories);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get active categories: $e'));
    }
  }

  /// Get archived categories
  Future<Result<List<TransactionCategory>>> getArchived() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _box!.values.where((dto) => dto.isArchived).toList();
      final categories = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by name
      categories.sort((a, b) => a.name.compareTo(b.name));

      return Result.success(categories);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get archived categories: $e'));
    }
  }

  /// Add new category
  Future<Result<TransactionCategory>> add(TransactionCategory category) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = TransactionCategoryDto.fromDomain(category);
      await _box!.put(category.id, dto);

      return Result.success(category);
    } catch (e) {
      return Result.error(Failure.cache('Failed to add category: $e'));
    }
  }

  /// Update existing category
  Future<Result<TransactionCategory>> update(TransactionCategory category) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = TransactionCategoryDto.fromDomain(category);
      await _box!.put(category.id, dto);

      return Result.success(category);
    } catch (e) {
      return Result.error(Failure.cache('Failed to update category: $e'));
    }
  }

  /// Delete category by ID
  Future<Result<void>> delete(String id) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      await _box!.delete(id);
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to delete category: $e'));
    }
  }

  /// Check if category is in use
  Future<Result<bool>> isCategoryInUse(String categoryId) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      // This would need to check transactions box
      // For now, return false (simplified implementation)
      return Result.success(false);
    } catch (e) {
      return Result.error(Failure.cache('Failed to check category usage: $e'));
    }
  }

  /// Clear all categories
  Future<Result<void>> clear() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      await _box!.clear();
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to clear categories: $e'));
    }
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}