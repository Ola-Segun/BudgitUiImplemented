import 'package:hive/hive.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/hive_storage.dart';
import '../models/budget_dto.dart';
import '../../domain/entities/budget.dart';

/// Hive-based data source for budget operations
class BudgetHiveDataSource {
  static const String _boxName = 'budgets';

  Box<BudgetDto>? _box;
  bool _isInitialized = false;

  /// Ensure the data source is initialized
  Future<void> _ensureInitialized() async {
    if (_isInitialized && _box != null) return;

    // Wait for Hive to be initialized
    await HiveStorage.init();

    // Register adapters if not already registered
    // BudgetDtoAdapter is registered globally in main.dart
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BudgetCategoryDtoAdapter());
    }

    // Handle box opening with proper type checking
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<BudgetDto>(_boxName);
    } else {
      try {
        _box = Hive.box<BudgetDto>(_boxName);
      } catch (e) {
        // If the box is already open with wrong type, close and reopen
        if (e.toString().contains('Box<dynamic>')) {
          await Hive.box(_boxName).close();
          _box = await Hive.openBox<BudgetDto>(_boxName);
        } else {
          rethrow;
        }
      }
    }

    _isInitialized = true;
  }

  /// Initialize the data source
  Future<void> init() async {
    await _ensureInitialized();
  }

  /// Get all budgets
  Future<Result<List<Budget>>> getAll() async {
    try {
      await _ensureInitialized();

      final dtos = _box!.values.toList();
      final budgets = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by start date (newest first)
      budgets.sort((a, b) => b.startDate.compareTo(a.startDate));

      return Result.success(budgets);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get budgets: $e'));
    }
  }

  /// Get budget by ID
  Future<Result<Budget?>> getById(String id) async {
    try {
      await _ensureInitialized();

      final dto = _box!.get(id);
      if (dto == null) {
        return Result.success(null);
      }

      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.error(Failure.cache('Failed to get budget: $e'));
    }
  }

  /// Get active budgets (currently within their date range)
  Future<Result<List<Budget>>> getActive() async {
    try {
      await _ensureInitialized();

      final now = DateTime.now();
      final dtos = _box!.values.where((dto) {
        final startDate = DateTime.fromMillisecondsSinceEpoch(dto.startDate);
        final endDate = DateTime.fromMillisecondsSinceEpoch(dto.endDate);
        return dto.isActive && now.isAfter(startDate) && now.isBefore(endDate);
      }).toList();

      final budgets = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by end date (soonest first)
      budgets.sort((a, b) => a.endDate.compareTo(b.endDate));

      return Result.success(budgets);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get active budgets: $e'));
    }
  }

  /// Get budgets by date range
  Future<Result<List<Budget>>> getByDateRange(DateTime start, DateTime end) async {
    try {
      await _ensureInitialized();

      final dtos = _box!.values.where((dto) {
        final budgetStart = DateTime.fromMillisecondsSinceEpoch(dto.startDate);
        final budgetEnd = DateTime.fromMillisecondsSinceEpoch(dto.endDate);
        return budgetStart.isBefore(end) && budgetEnd.isAfter(start);
      }).toList();

      final budgets = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by start date (newest first)
      budgets.sort((a, b) => b.startDate.compareTo(a.startDate));

      return Result.success(budgets);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get budgets by date range: $e'));
    }
  }

  /// Add new budget
  Future<Result<Budget>> add(Budget budget) async {
    try {
      await _ensureInitialized();

      final dto = BudgetDto.fromDomain(budget);
      await _box!.put(budget.id, dto);

      return Result.success(budget);
    } catch (e) {
      return Result.error(Failure.cache('Failed to add budget: $e'));
    }
  }

  /// Update existing budget
  Future<Result<Budget>> update(Budget budget) async {
    try {
      await _ensureInitialized();

      final dto = BudgetDto.fromDomain(budget);
      await _box!.put(budget.id, dto);

      return Result.success(budget);
    } catch (e) {
      return Result.error(Failure.cache('Failed to update budget: $e'));
    }
  }

  /// Delete budget by ID
  Future<Result<void>> delete(String id) async {
    try {
      await _ensureInitialized();

      await _box!.delete(id);
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to delete budget: $e'));
    }
  }

  /// Duplicate budget with new date range
  Future<Result<Budget>> duplicate(String budgetId, DateTime newStartDate, DateTime newEndDate) async {
    try {
      await _ensureInitialized();

      final originalDto = _box!.get(budgetId);
      if (originalDto == null) {
        return Result.error(Failure.validation(
          'Budget not found',
          {'budgetId': 'Budget does not exist'},
        ));
      }

      // Create new budget with updated dates
      final newBudget = originalDto.toDomain().copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate new ID
        name: '${originalDto.name} (Copy)',
        startDate: newStartDate,
        endDate: newEndDate,
        isActive: false, // Start as inactive
      );

      final newDto = BudgetDto.fromDomain(newBudget);
      await _box!.put(newBudget.id, newDto);

      return Result.success(newBudget);
    } catch (e) {
      return Result.error(Failure.cache('Failed to duplicate budget: $e'));
    }
  }

  /// Clear all budgets
  Future<Result<void>> clear() async {
    try {
      await _ensureInitialized();

      await _box!.clear();
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to clear budgets: $e'));
    }
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}