import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../goals/data/models/goal_contribution_dto.dart';
import '../../../goals/domain/entities/goal_contribution.dart';
import '../models/transaction_dto.dart';
import '../models/transaction_mapper.dart';
import '../../domain/entities/transaction.dart';

/// Hive-based data source for transaction operations
class TransactionHiveDataSource {
  static const String _boxName = 'transactions';

  Box<TransactionDto>? _box;

  /// Initialize the data source
  Future<void> init() async {
    try {
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
        try {
          _box = await Hive.openBox<TransactionDto>(_boxName);
        } catch (e) {
          debugPrint('Error opening transaction box: $e');
          // Try to clear incompatible data by opening as dynamic and clearing
          try {
            final tempBox = await Hive.openBox(_boxName);
            await tempBox.clear();
            await tempBox.close();
          } catch (e2) {
            debugPrint('Error clearing box: $e2');
            // If clearing fails, try deleting the box
            try {
              await Hive.deleteBoxFromDisk(_boxName);
            } catch (e3) {
              debugPrint('Error deleting box: $e3');
            }
          }
          _box = await Hive.openBox<TransactionDto>(_boxName);
        }
      } else {
        try {
          _box = Hive.box<TransactionDto>(_boxName);
        } catch (e) {
          // If the box is already open with wrong type, close and reopen
          if (e.toString().contains('Box<dynamic>')) {
            await Hive.box(_boxName).close();
            try {
              _box = await Hive.openBox<TransactionDto>(_boxName);
            } catch (e2) {
              debugPrint('Error reopening transaction box: $e2');
              // Try to clear incompatible data by opening as dynamic and clearing
              try {
                final tempBox = await Hive.openBox(_boxName);
                await tempBox.clear();
                await tempBox.close();
              } catch (e3) {
                debugPrint('Error clearing box: $e3');
                // If clearing fails, try deleting the box
                try {
                  await Hive.deleteBoxFromDisk(_boxName);
                } catch (e4) {
                  debugPrint('Error deleting box: $e4');
                }
              }
              _box = await Hive.openBox<TransactionDto>(_boxName);
            }
          } else {
            rethrow;
          }
        }
      }

      // Try to read all values to check for serialization issues
      if (_box != null) {
        final values = _box!.values.toList();
        for (final dto in values) {
          try {
            dto.toDomain(); // This will trigger deserialization
          } catch (e) {
            debugPrint('Error deserializing transaction DTO: $e');
            debugPrint('DTO data: ${dto.toString()}');
            // Clear the box if deserialization fails due to incompatible data
            debugPrint('Clearing transaction box due to incompatible data');
            await _box!.clear();
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing TransactionHiveDataSource: $e');
      rethrow;
    }
  }

  /// Get all transactions
  Future<Result<List<Transaction>>> getAll() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _box!.values.toList();
      final transactions = <Transaction>[];

      for (final dto in dtos) {
        final allocations = await _getGoalAllocations(dto.goalAllocationIds);
        final transaction = TransactionMapper.toDomainWithAllocations(dto, allocations);
        transactions.add(transaction);
      }

      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return Result.success(transactions);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get transactions: $e'));
    }
  }

  /// Get transaction by ID
  Future<Result<Transaction?>> getById(String id) async {
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
      return Result.error(Failure.cache('Failed to get transaction: $e'));
    }
  }

  /// Get transactions by date range
  Future<Result<List<Transaction>>> getByDateRange(DateTime start, DateTime end) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _box!.values.where((dto) {
        return dto.date.isAfter(start.subtract(const Duration(days: 1))) &&
               dto.date.isBefore(end.add(const Duration(days: 1)));
      }).toList();

      final transactions = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return Result.success(transactions);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get transactions by date range: $e'));
    }
  }

  /// Get transactions by category
  Future<Result<List<Transaction>>> getByCategory(String categoryId) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _box!.values.where((dto) => dto.categoryId == categoryId).toList();
      final transactions = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return Result.success(transactions);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get transactions by category: $e'));
    }
  }

  /// Get transactions by type
  Future<Result<List<Transaction>>> getByType(TransactionType type) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _box!.values.where((dto) => dto.type == type.name).toList();
      final transactions = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return Result.success(transactions);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get transactions by type: $e'));
    }
  }

  /// Add new transaction
  Future<Result<Transaction>> add(Transaction transaction) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = TransactionDto.fromDomain(transaction);
      await _box!.put(transaction.id, dto);

      return Result.success(transaction);
    } catch (e) {
      return Result.error(Failure.cache('Failed to add transaction: $e'));
    }
  }

  /// Update existing transaction
  Future<Result<Transaction>> update(Transaction transaction) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = TransactionDto.fromDomain(transaction);
      await _box!.put(transaction.id, dto);

      return Result.success(transaction);
    } catch (e) {
      return Result.error(Failure.cache('Failed to update transaction: $e'));
    }
  }

  /// Delete transaction by ID
  Future<Result<void>> delete(String id) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      await _box!.delete(id);
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to delete transaction: $e'));
    }
  }

  /// Get total amount for date range
  Future<Result<double>> getTotalAmount(DateTime start, DateTime end, {TransactionType? type}) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _box!.values.where((dto) {
        final inDateRange = dto.date.isAfter(start.subtract(const Duration(days: 1))) &&
                           dto.date.isBefore(end.add(const Duration(days: 1)));
        final matchesType = type == null || dto.type == type.name;
        return inDateRange && matchesType;
      }).toList();

      final total = dtos.fold<double>(0.0, (sum, dto) {
        final transaction = dto.toDomain();
        return sum + (transaction.isIncome ? transaction.amount : -transaction.amount);
      });

      return Result.success(total);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get total amount: $e'));
    }
  }

  /// Search transactions by title or description
  Future<Result<List<Transaction>>> search(String query) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final lowerQuery = query.toLowerCase();
      final dtos = _box!.values.where((dto) {
        return dto.title.toLowerCase().contains(lowerQuery) ||
               (dto.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();

      final transactions = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return Result.success(transactions);
    } catch (e) {
      return Result.error(Failure.cache('Failed to search transactions: $e'));
    }
  }

  /// Get transaction count
  Future<Result<int>> getCount() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      return Result.success(_box!.length);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get transaction count: $e'));
    }
  }


  /// Clear all transactions
  Future<Result<void>> clear() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      await _box!.clear();
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to clear transactions: $e'));
    }
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  /// Get goal allocations for a transaction
  Future<List<GoalContribution>?> _getGoalAllocations(List<String>? allocationIds) async {
    if (allocationIds == null || allocationIds.isEmpty) {
      return null;
    }

    try {
      // Import the contribution box dynamically to avoid circular dependencies
      final contributionBox = await Hive.openBox('goal_contributions');
      final allocations = <GoalContribution>[];

      for (final id in allocationIds) {
        final data = contributionBox.get(id);
        if (data != null && data is GoalContributionDto) {
          allocations.add(data.toDomain());
        }
      }

      await contributionBox.close();
      return allocations.isEmpty ? null : allocations;
    } catch (e) {
      debugPrint('Failed to load goal allocations: $e');
      return null;
    }
  }
}