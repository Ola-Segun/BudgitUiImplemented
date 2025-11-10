import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/features/goals/domain/entities/goal_template.dart';
import 'package:budget_tracker/features/goals/domain/entities/goal.dart';
import 'package:budget_tracker/features/goals/domain/usecases/customize_goal_template.dart';

void main() {
  late CustomizeGoalTemplate useCase;

  setUp(() {
    useCase = CustomizeGoalTemplate();
  });

  group('CustomizeGoalTemplate', () {
    final template = GoalTemplates.all.first;

    test('should customize template with new name', () {
      const newName = 'Custom Emergency Fund';

      final result = useCase.call(template, newName: newName);

      expect(result.name, newName);
      expect(result.id, template.id); // ID should remain the same
      expect(result.description, template.description);
    });

    test('should customize template with new amount and months', () {
      const newAmount = 5000.0;
      const newMonths = 10;

      final result = useCase.call(template, newAmount: newAmount, newMonths: newMonths);

      expect(result.suggestedAmount, newAmount);
      expect(result.suggestedMonths, newMonths);
      expect(result.monthlyContribution, newAmount / newMonths);
    });

    test('should customize template with new priority', () {
      final newPriority = GoalPriority.high;

      final result = useCase.call(template, newPriority: newPriority);

      expect(result.defaultPriority, newPriority);
    });

    test('should create template from preferences', () {
      const id = 'custom_template';
      const name = 'Custom Goal';
      const description = 'A custom goal';
      const amount = 10000.0;
      const months = 12;
      const categoryId = 'savings';

      final result = useCase.createFromPreferences(
        id: id,
        name: name,
        description: description,
        amount: amount,
        months: months,
        categoryId: categoryId,
      );

      expect(result.id, id);
      expect(result.name, name);
      expect(result.description, description);
      expect(result.suggestedAmount, amount);
      expect(result.suggestedMonths, months);
      expect(result.categoryId, categoryId);
    });

    test('should apply user preferences based on income', () {
      const monthlyIncome = 5000.0;
      const riskTolerance = 3; // Medium risk

      final result = useCase.applyUserPreferences(
        template,
        monthlyIncome: monthlyIncome,
        riskTolerance: riskTolerance,
      );

      // Should adjust amount to 20% of income max
      expect(result.suggestedAmount, lessThanOrEqualTo(monthlyIncome * 0.2));
      // Should keep original months for medium risk
      expect(result.suggestedMonths, template.suggestedMonths);
    });

    test('should apply conservative preferences for high risk tolerance', () {
      const monthlyIncome = 5000.0;
      const riskTolerance = 5; // High risk tolerance = conservative

      final result = useCase.applyUserPreferences(
        template,
        monthlyIncome: monthlyIncome,
        riskTolerance: riskTolerance,
      );

      // Should extend timeline for conservative approach
      expect(result.suggestedMonths, greaterThan(template.suggestedMonths));
    });

    test('should apply aggressive preferences for low risk tolerance', () {
      const monthlyIncome = 5000.0;
      const riskTolerance = 1; // Low risk tolerance = aggressive

      final result = useCase.applyUserPreferences(
        template,
        monthlyIncome: monthlyIncome,
        riskTolerance: riskTolerance,
      );

      // Should shorten timeline for aggressive approach
      expect(result.suggestedMonths, lessThan(template.suggestedMonths));
    });
  });
}