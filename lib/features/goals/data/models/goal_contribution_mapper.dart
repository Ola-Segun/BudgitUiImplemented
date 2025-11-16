import 'goal_contribution_dto.dart';
import '../../domain/entities/goal_contribution.dart';

/// Mapper for converting between GoalContribution domain entity and DTO
class GoalContributionMapper {
  /// Convert DTO to domain entity
  static GoalContribution toDomain(GoalContributionDto dto) {
    return dto.toDomain();
  }

  /// Convert domain entity to DTO
  static GoalContributionDto toDTO(GoalContribution contribution) {
    return GoalContributionDto.fromDomain(contribution);
  }
}