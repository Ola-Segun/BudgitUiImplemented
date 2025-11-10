import '../entities/goal_template.dart';

/// Use case for validating goal templates
class ValidateGoalTemplate {
  /// Validate a template for goal creation
  bool call(
    GoalTemplate template, {
    double? customAmount,
    DateTime? customDeadline,
  }) {
    return template.validateForCreation(
      customAmount: customAmount,
      customDeadline: customDeadline,
    );
  }

  /// Validate multiple templates
  Map<String, bool> validateMultiple(
    List<GoalTemplate> templates, {
    double? customAmount,
    DateTime? customDeadline,
  }) {
    return Map.fromEntries(
      templates.map(
        (template) => MapEntry(
          template.id,
          call(
            template,
            customAmount: customAmount,
            customDeadline: customDeadline,
          ),
        ),
      ),
    );
  }

  /// Get validation errors for a template
  List<String> getValidationErrors(
    GoalTemplate template, {
    double? customAmount,
    DateTime? customDeadline,
  }) {
    final errors = <String>[];
    final amount = customAmount ?? template.suggestedAmount;
    final deadline = customDeadline ?? template.suggestedDeadline;

    if (amount <= 0) {
      errors.add('Amount must be greater than 0');
    }

    if (deadline.isBefore(DateTime.now())) {
      errors.add('Deadline must be in the future');
    }

    if (template.suggestedMonths <= 0) {
      errors.add('Suggested months must be greater than 0');
    }

    return errors;
  }
}