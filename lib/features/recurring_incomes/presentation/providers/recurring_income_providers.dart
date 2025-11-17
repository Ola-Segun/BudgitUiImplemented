import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart' as core_providers;
import '../../../../core/di/providers.dart';
import '../../data/repositories/recurring_income_repository_impl.dart';
import '../../domain/repositories/recurring_income_repository.dart';
import '../../domain/usecases/create_recurring_income.dart';
import '../../domain/usecases/get_recurring_incomes.dart';
import '../../domain/usecases/record_income_receipt.dart';
import '../notifiers/recurring_income_notifier.dart';
import '../states/recurring_income_state.dart';

// Repository provider - now defined in core/di/providers.dart
// This local definition has been removed to avoid circular dependency

// Use case providers
final createRecurringIncomeProvider = Provider<CreateRecurringIncome>((ref) {
  return CreateRecurringIncome(
    ref.read(recurringIncomeRepositoryProvider),
    ref.read(core_providers.accountRepositoryProvider),
  );
});

final getRecurringIncomesProvider = Provider<GetRecurringIncomes>((ref) {
  return GetRecurringIncomes(ref.read(recurringIncomeRepositoryProvider));
});

final recordIncomeReceiptProvider = Provider<RecordIncomeReceipt>((ref) {
  return RecordIncomeReceipt(ref.read(recurringIncomeRepositoryProvider));
});

// Notifier provider - lazy initialization to avoid premature data source access
final recurringIncomeNotifierProvider = StateNotifierProvider<RecurringIncomeNotifier, RecurringIncomeState>((ref) {
  // Ensure app initialization is complete before creating the notifier
  ref.watch(appInitializationProvider);

  return RecurringIncomeNotifier(
    getRecurringIncomes: ref.read(getRecurringIncomesProvider),
    createRecurringIncome: ref.read(createRecurringIncomeProvider),
    recordIncomeReceipt: ref.read(recordIncomeReceiptProvider),
    repository: ref.read(recurringIncomeRepositoryProvider),
  );
});