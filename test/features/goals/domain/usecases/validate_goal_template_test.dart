import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/features/goals/domain/entities/goal_template.dart';
import 'package:budget_tracker/features/goals/domain/usecases/validate_goal_template.dart';

void main() {
  late ValidateGoalTemplate useCase;

  setUp(() {
    useCase = ValidateGoalTemplate();
  });

  group('ValidateGoalTemplate', () {
    final template = GoalTemplates.all.first;

    test('should return true for valid template', () {
      final result = useCase.call(template);

      expect(result, isTrue);
    });

    test('should return false for template with negative amount', () {
      final invalidTemplate = template.customize(newAmount: -100);

      final result = useCase.call(invalidTemplate);

      expect(result, isFalse);
    });

    test('should return false for template with past deadline', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final invalidTemplate = template.customize(
        newAmount: 1000,
        newMonths: 1,
      );

      final result = useCase.call(invalidTemplate, customDeadline: pastDate);

      expect(result, isFalse);
    });

    test('should return false for template with zero months', () {
      final invalidTemplate = template.customize(newMonths: 0);

      final result = useCase.call(invalidTemplate);

      expect(result, isFalse);
    });

    test('should validate multiple templates correctly', () {
      final templates = GoalTemplates.all.take(3).toList();
      final results = useCase.validateMultiple(templates);

      expect(results.length, 3);
      expect(results.values.every((result) => result == true), isTrue);
    });

    test('should return validation errors for invalid template', () {
      final invalidTemplate = template.customize(
        newAmount: -500,
        newMonths: 0,
      );

      final errors = useCase.getValidationErrors(invalidTemplate);

      expect(errors.length, 2);
      expect(errors, contains('Amount must be greater than 0'));
      expect(errors, contains('Suggested months must be greater than 0'));
    });

    test('should return empty errors list for valid template', () {
      final errors = useCase.getValidationErrors(template);

      expect(errors, isEmpty);
    });
  });
}