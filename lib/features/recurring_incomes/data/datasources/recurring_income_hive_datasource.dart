import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/usecases/add_transaction.dart';
import '../models/recurring_income_dto.dart';
import '../../domain/entities/recurring_income.dart';

/// Hive-based data source for recurring income operations
class RecurringIncomeHiveDataSource {
  static const String _boxName = 'recurring_incomes';

  Box<RecurringIncomeDto>? _box;

  /// Initialize the data source
  Future<void> init() async {
    try {
      debugPrint('RecurringIncomeHiveDataSource: Starting initialization...');

      // Wait for Hive to be initialized
      await HiveStorage.init();
      debugPrint('RecurringIncomeHiveDataSource: Hive storage initialized');

      // Ensure adapters are registered before opening box
      if (!Hive.isAdapterRegistered(8)) {
        debugPrint('RecurringIncomeHiveDataSource: Registering RecurringIncomeDtoAdapter');
        Hive.registerAdapter(RecurringIncomeDtoAdapter());
      }
      if (!Hive.isAdapterRegistered(9)) {
        debugPrint('RecurringIncomeHiveDataSource: Registering RecurringIncomeInstanceDtoAdapter');
        Hive.registerAdapter(RecurringIncomeInstanceDtoAdapter());
      }
      if (!Hive.isAdapterRegistered(10)) {
        debugPrint('RecurringIncomeHiveDataSource: Registering RecurringIncomeRuleDtoAdapter');
        Hive.registerAdapter(RecurringIncomeRuleDtoAdapter());
      }

      // Handle box opening with proper type checking
      if (!Hive.isBoxOpen(_boxName)) {
        debugPrint('RecurringIncomeHiveDataSource: Opening new box $_boxName');
        _box = await Hive.openBox<RecurringIncomeDto>(_boxName);
      } else {
        debugPrint('RecurringIncomeHiveDataSource: Box $_boxName already open, getting reference');
        try {
          _box = Hive.box<RecurringIncomeDto>(_boxName);
        } catch (e) {
          // If the box is already open with wrong type, close and reopen
          debugPrint('RecurringIncomeHiveDataSource: Box type mismatch, reopening: $e');
          if (e.toString().contains('Box<dynamic>')) {
            await Hive.box(_boxName).close();
            _box = await Hive.openBox<RecurringIncomeDto>(_boxName);
          } else {
            rethrow;
          }
        }
      }

      debugPrint('RecurringIncomeHiveDataSource: Initialization completed successfully, _box is null: ${_box == null}');
    } catch (e) {
      debugPrint('RecurringIncomeHiveDataSource: Initialization failed: $e');
      rethrow;
    }
  }

  /// Get all recurring incomes
  Future<Result<List<RecurringIncome>>> getAll() async {
    try {
      // Initialize if not already done
      if (_box == null) {
        debugPrint('RecurringIncomeHiveDataSource: getAll called but _box is null - initializing data source');
        await init();
      }

      final dtos = _box!.values.toList();
      final incomes = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by start date (newest first)
      incomes.sort((a, b) => b.startDate.compareTo(a.startDate));

      return Result.success(incomes);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get recurring incomes: $e'));
    }
  }

  /// Get recurring income by ID
  Future<Result<RecurringIncome?>> getById(String id) async {
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
      return Result.error(Failure.cache('Failed to get recurring income: $e'));
    }
  }

  /// Get incomes expected within specified days
  Future<Result<List<RecurringIncome>>> getExpectedWithin(int days) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final now = DateTime.now();
      final futureDate = now.add(Duration(days: days));

      final dtos = _box!.values.where((dto) {
        if (dto.nextExpectedDate == null) return false;
        return dto.nextExpectedDate!.isAfter(now.subtract(const Duration(days: 1))) &&
               dto.nextExpectedDate!.isBefore(futureDate.add(const Duration(days: 1)));
      }).toList();

      final incomes = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by expected date (soonest first)
      incomes.sort((a, b) => a.nextExpectedDate!.compareTo(b.nextExpectedDate!));

      return Result.success(incomes);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get incomes expected within $days days: $e'));
    }
  }

  /// Get overdue incomes (expected but not received)
  Future<Result<List<RecurringIncome>>> getOverdue() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final now = DateTime.now();
      final dtos = _box!.values.where((dto) {
        return dto.nextExpectedDate != null &&
               dto.nextExpectedDate!.isBefore(now) &&
               !dto.incomeHistory!.any((instance) =>
                 instance.receivedDate.year == now.year &&
                 instance.receivedDate.month == now.month &&
                 instance.receivedDate.day == now.day);
      }).toList();

      final incomes = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by expected date (oldest first)
      incomes.sort((a, b) => a.nextExpectedDate!.compareTo(b.nextExpectedDate!));

      return Result.success(incomes);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get overdue incomes: $e'));
    }
  }

  /// Get incomes received this month
  Future<Result<List<RecurringIncome>>> getReceivedThisMonth() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);

      final dtos = _box!.values.where((dto) {
        return dto.incomeHistory!.any((instance) {
          final receivedMonth = DateTime(instance.receivedDate.year, instance.receivedDate.month);
          return receivedMonth == currentMonth;
        });
      }).toList();

      final incomes = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by most recent receipt
      incomes.sort((a, b) {
        final aLatest = a.incomeHistory
            .where((i) => DateTime(i.receivedDate.year, i.receivedDate.month) == currentMonth)
            .map((i) => i.receivedDate)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        final bLatest = b.incomeHistory
            .where((i) => DateTime(i.receivedDate.year, i.receivedDate.month) == currentMonth)
            .map((i) => i.receivedDate)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        return bLatest.compareTo(aLatest);
      });

      return Result.success(incomes);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get incomes received this month: $e'));
    }
  }

  /// Get incomes expected this month
  Future<Result<List<RecurringIncome>>> getExpectedThisMonth() async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      final nextMonth = DateTime(now.year, now.month + 1);

      final dtos = _box!.values.where((dto) {
        if (dto.nextExpectedDate == null) return false;
        final expectedMonth = DateTime(dto.nextExpectedDate!.year, dto.nextExpectedDate!.month);
        return expectedMonth == currentMonth;
      }).toList();

      final incomes = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by expected date (soonest first)
      incomes.sort((a, b) => a.nextExpectedDate!.compareTo(b.nextExpectedDate!));

      return Result.success(incomes);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get incomes expected this month: $e'));
    }
  }

  /// Add new recurring income
  Future<Result<RecurringIncome>> add(RecurringIncome income) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = RecurringIncomeDto.fromDomain(income);
      await _box!.put(income.id, dto);

      return Result.success(income);
    } catch (e) {
      return Result.error(Failure.cache('Failed to add recurring income: $e'));
    }
  }

  /// Update existing recurring income
  Future<Result<RecurringIncome>> update(RecurringIncome income) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = RecurringIncomeDto.fromDomain(income);
      await _box!.put(income.id, dto);

      return Result.success(income);
    } catch (e) {
      return Result.error(Failure.cache('Failed to update recurring income: $e'));
    }
  }

  /// Delete recurring income by ID
  Future<Result<void>> delete(String id) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      await _box!.delete(id);
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to delete recurring income: $e'));
    }
  }

  /// Record income receipt
  Future<Result<RecurringIncome>> recordIncomeReceipt(
    String incomeId,
    RecurringIncomeInstance instance,
    AddTransaction addTransaction,
    {String? accountId}
  ) async {
    debugPrint('RecurringIncomeHiveDataSource: Recording income receipt - incomeId: $incomeId, amount: ${instance.amount}, accountId: $accountId');

    if (_box == null) {
      debugPrint('RecurringIncomeHiveDataSource: Data source not initialized');
      return Result.error(Failure.cache('Data source not initialized'));
    }

    final dto = _box!.get(incomeId);
    if (dto == null) {
      debugPrint('RecurringIncomeHiveDataSource: Recurring income not found - incomeId: $incomeId');
      return Result.error(Failure.cache('Recurring income not found'));
    }

    debugPrint('RecurringIncomeHiveDataSource: Found income - name: ${dto.name}, current history length: ${dto.incomeHistory?.length ?? 0}');

    // Determine which account to use for income deposit
    final accountIdToUse = accountId ?? instance.accountId ?? dto.accountId;
    if (accountIdToUse == null) {
      debugPrint('RecurringIncomeHiveDataSource: No account specified for income deposit');
      return Result.error(Failure.cache(
        'No account specified for income deposit. Please specify an account for this income.'
      ));
    }

    debugPrint('RecurringIncomeHiveDataSource: Using account ID: $accountIdToUse for income deposit');

    // Create corresponding income transaction using the proper usecase
    // This ensures balance integrity and follows Account-Transaction-Relationship principles
    final transaction = Transaction(
      id: 'income_${incomeId}_${instance.id}',
      title: '${dto.name} Income', // Required title field
      amount: instance.amount,
      categoryId: dto.categoryId, // Use income's actual category
      date: instance.receivedDate,
      type: TransactionType.income,
      accountId: accountIdToUse, // Use determined account
      description: 'Income from ${dto.name}', // Optional description
    );

    debugPrint('RecurringIncomeHiveDataSource: Created transaction - id: ${transaction.id}, amount: ${transaction.amount}, accountId: ${transaction.accountId}');

    debugPrint('RecurringIncomeHiveDataSource: Created transaction - id: ${transaction.id}, amount: ${transaction.amount}');

    // Step 1: Create transaction first (critical for balance integrity)
    final transactionResult = await addTransaction(transaction);
    if (transactionResult.isError) {
      debugPrint('RecurringIncomeHiveDataSource: Failed to create transaction - error: ${transactionResult.failureOrNull?.message}');
      return Result.error(Failure.cache(
        'Failed to create transaction for income receipt: ${transactionResult.failureOrNull?.message}'
      ));
    }

    final createdTransaction = transactionResult.dataOrNull!;
    debugPrint('RecurringIncomeHiveDataSource: Transaction created successfully - id: ${createdTransaction.id}');
    Transaction? transactionToRollback;

    try {
      // Step 2: Update income status (only after successful transaction creation)
      debugPrint('RecurringIncomeHiveDataSource: Updating income status');
      dto.lastReceivedDate = instance.receivedDate;

      // Add instance to history with transaction reference
      dto.incomeHistory ??= [];
      final instanceDto = RecurringIncomeInstanceDto.fromDomain(instance);
      instanceDto.transactionId = createdTransaction.id; // Set transaction ID directly
      instanceDto.accountId = accountIdToUse; // Ensure account is set on instance
      dto.incomeHistory!.add(instanceDto);

      debugPrint('RecurringIncomeHiveDataSource: Added instance to history - new history length: ${dto.incomeHistory!.length}');

      // Update next expected date for recurring incomes
      if (dto.frequency != RecurringIncomeFrequency.custom.name) {
        final frequency = RecurringIncomeFrequency.values.firstWhere(
          (e) => e.name == dto.frequency,
          orElse: () => RecurringIncomeFrequency.monthly,
        );
        dto.nextExpectedDate = _calculateNextExpectedDate(dto.lastReceivedDate!, frequency);
        debugPrint('RecurringIncomeHiveDataSource: Updated next expected date to: ${dto.nextExpectedDate}');
      }

      await _box!.put(incomeId, dto);
      transactionToRollback = createdTransaction;

      debugPrint('RecurringIncomeHiveDataSource: Income updated successfully');
      return Result.success(dto.toDomain());
    } catch (e) {
      debugPrint('RecurringIncomeHiveDataSource: Failed to update income status - error: $e');
      // Note: Transaction rollback is now handled at the use case level
      return Result.error(Failure.cache('Failed to update income status after transaction creation: $e'));
    }
  }

  /// Update next expected date for recurring income
  Future<Result<RecurringIncome>> updateNextExpectedDate(String incomeId) async {
    try {
      if (_box == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = _box!.get(incomeId);
      if (dto == null) {
        return Result.error(Failure.cache('Recurring income not found'));
      }

      final frequency = RecurringIncomeFrequency.values.firstWhere(
        (e) => e.name == dto.frequency,
        orElse: () => RecurringIncomeFrequency.monthly,
      );

      dto.nextExpectedDate = _calculateNextExpectedDate(
        dto.lastReceivedDate ?? dto.startDate,
        frequency
      );

      await _box!.put(incomeId, dto);

      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.error(Failure.cache('Failed to update next expected date: $e'));
    }
  }

  /// Calculate next expected date based on frequency
  DateTime _calculateNextExpectedDate(DateTime currentDate, RecurringIncomeFrequency frequency) {
    switch (frequency) {
      case RecurringIncomeFrequency.daily:
        return currentDate.add(const Duration(days: 1));
      case RecurringIncomeFrequency.weekly:
        return currentDate.add(const Duration(days: 7));
      case RecurringIncomeFrequency.biWeekly:
        return currentDate.add(const Duration(days: 14));
      case RecurringIncomeFrequency.monthly:
        return DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
      case RecurringIncomeFrequency.quarterly:
        return DateTime(currentDate.year, currentDate.month + 3, currentDate.day);
      case RecurringIncomeFrequency.annually:
        return DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
      case RecurringIncomeFrequency.custom:
        return currentDate; // Custom logic needed
    }
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}