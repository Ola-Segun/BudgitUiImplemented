import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../repositories/bill_repository.dart';

/// Use case for validating bill name uniqueness
class ValidateBillName {
  const ValidateBillName(this._repository);

  final BillRepository _repository;

  /// Execute the use case
  Future<Result<String>> call(String name, {String? excludeId}) async {
    try {
      // Check for duplicate name
      final nameExistsResult = await _repository.nameExists(name, excludeId: excludeId);
      if (nameExistsResult.isError) {
        return Result.error(nameExistsResult.failureOrNull!);
      }

      final nameExists = nameExistsResult.dataOrNull ?? false;
      if (nameExists) {
        return Result.error(Failure.validation(
          'Bill names must be unique. This name is already in use by another bill. Please choose a different name.',
          {'name': 'Bill name must be unique'},
        ));
      }

      return Result.success(name);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to validate bill name: $e'));
    }
  }
}