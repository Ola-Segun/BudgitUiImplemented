import '../../../../core/error/result.dart';
import '../entities/recurring_income.dart';
import '../repositories/recurring_income_repository.dart';

/// Use case for recording income receipt
class RecordIncomeReceipt {
  const RecordIncomeReceipt(this._repository);

  final RecurringIncomeRepository _repository;

  /// Execute the use case
  Future<Result<RecurringIncome>> call(
    String incomeId,
    RecurringIncomeInstance instance, {
    String? accountId,
  }) => _repository.recordIncomeReceipt(incomeId, instance, accountId: accountId);
}