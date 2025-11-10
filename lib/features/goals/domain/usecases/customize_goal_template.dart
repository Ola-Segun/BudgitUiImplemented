import '../entities/goal_template.dart';
import '../entities/goal.dart';

/// Use case for customizing goal templates
class CustomizeGoalTemplate {
  /// Customize a template with new parameters
  GoalTemplate call(
    GoalTemplate template, {
    String? newName,
    String? newDescription,
    double? newAmount,
    int? newMonths,
    GoalPriority? newPriority,
    String? newIcon,
    int? newColor,
  }) {
    return template.customize(
      newName: newName,
      newDescription: newDescription,
      newAmount: newAmount,
      newMonths: newMonths,
      newPriority: newPriority,
      newIcon: newIcon,
      newColor: newColor,
    );
  }

  /// Create a template from user preferences
  GoalTemplate createFromPreferences({
    required String id,
    required String name,
    required String description,
    required double amount,
    required int months,
    required String categoryId,
    GoalPriority priority = GoalPriority.medium,
    String? icon,
    int? color,
    List<String> tips = const [],
  }) {
    return GoalTemplate(
      id: id,
      name: name,
      description: description,
      suggestedAmount: amount,
      suggestedMonths: months,
      categoryId: categoryId,
      defaultPriority: priority,
      icon: icon,
      color: color,
      tips: tips,
    );
  }

  /// Apply common customizations based on user profile
  GoalTemplate applyUserPreferences(
    GoalTemplate template, {
    required double monthlyIncome,
    required int riskTolerance, // 1-5 scale
  }) {
    // Adjust amount based on income (max 20% of monthly income)
    final maxAmount = monthlyIncome * 0.2;
    final adjustedAmount = template.suggestedAmount > maxAmount
        ? maxAmount
        : template.suggestedAmount;

    // Adjust timeline based on risk tolerance
    final adjustedMonths = riskTolerance >= 4
        ? template.suggestedMonths + 3 // Conservative - longer timeline
        : riskTolerance <= 2
            ? (template.suggestedMonths * 0.8).round() // Aggressive - shorter timeline
            : template.suggestedMonths;

    return template.customize(
      newAmount: adjustedAmount,
      newMonths: adjustedMonths,
    );
  }
}