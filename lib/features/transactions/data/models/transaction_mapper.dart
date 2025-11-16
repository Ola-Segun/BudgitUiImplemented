import '../../../goals/data/models/goal_contribution_mapper.dart';
import '../../../goals/domain/entities/goal_contribution.dart';
import 'transaction_dto.dart';
import '../../domain/entities/transaction.dart';

/// Mapper for converting between Transaction domain entity and DTO
class TransactionMapper {
  /// Convert DTO to domain entity
  static Transaction toDomain(TransactionDto dto) {
    return dto.toDomain();
  }

  /// Convert DTO to domain entity with goal allocations
  static Transaction toDomainWithAllocations(TransactionDto dto, List<GoalContribution>? allocations) {
    return dto.toDomainWithAllocations(allocations);
  }

  /// Convert domain entity to DTO
  static TransactionDto toDTO(Transaction transaction) {
    return TransactionDto.fromDomain(transaction);
  }
}