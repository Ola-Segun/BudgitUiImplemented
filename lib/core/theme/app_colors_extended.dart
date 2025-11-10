import 'package:flutter/material.dart';

/// Extended color system for budget components
/// Based on the redesign guide with teal color palette
class AppColorsExtended {
  AppColorsExtended._(); // Private constructor prevents instantiation

  // ═══════════════════════════════════════════════════════════
  // BUDGET-SPECIFIC COLORS - Teal palette matching home design
  // ═══════════════════════════════════════════════════════════

  /// Main budget primary color - Teal/mint
  static const Color budgetPrimary = Color(0xFF00D4AA);

  /// Budget secondary color - Purple
  static const Color budgetSecondary = Color(0xFF7C3AED);

  /// Budget tertiary color - Amber
  static const Color budgetTertiary = Color(0xFFF59E0B);

  // ═══════════════════════════════════════════════════════════
  // ACCOUNT UI COLORS - Vibrant gradients and semantic colors
  // ═══════════════════════════════════════════════════════════

  /// Primary gradient colors for Account UI
  static const Color accountPrimary = Color(0xFF00D4AA);
  static const Color accountPrimaryLight = Color(0xFF00B894);
  static const Color accountSecondary = Color(0xFF7C3AED);
  static const Color accountSecondaryLight = Color(0xFF6D28D9);

  /// Semantic colors for Account UI
  static const Color positive = Color(0xFF00D4AA);  // Positive balance, income
  static const Color negative = Color(0xFFEF4444);  // Negative balance, expenses
  static const Color neutral = Color(0xFF3B82F6);   // Neutral status, information
  static const Color warning = Color(0xFFF59E0B);   // Warning status

  /// Gradient definitions for Account UI
  static const LinearGradient accountPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accountPrimary, accountPrimaryLight],
  );

  static const LinearGradient accountSecondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accountSecondary, accountSecondaryLight],
  );

  static const LinearGradient positiveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
  );

  static const LinearGradient negativeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // ═══════════════════════════════════════════════════════════
  // STATUS COLORS - For budget health indicators
  // ═══════════════════════════════════════════════════════════

  /// Healthy budget status - Green
  static const Color statusNormal = Color(0xFF10B981);

  /// Warning budget status - Amber
  static const Color statusWarning = Color(0xFFF59E0B);

  /// Critical budget status - Red
  static const Color statusCritical = Color(0xFFEF4444);

  /// Over budget status - Dark red
  static const Color statusOverBudget = Color(0xFFDC2626);

  // ═══════════════════════════════════════════════════════════
  // CHART COLORS - For data visualization
  // ═══════════════════════════════════════════════════════════

  /// Chart gradient colors
  static const List<Color> chartGradient = [
    Color(0xFF00D4AA),
    Color(0xFF00B894),
  ];

  /// Chart tooltip background
  static const Color chartTooltipBg = Color(0xFF1F2937);

  /// Chart axis line color
  static const Color chartAxisLine = Color(0xFFE5E7EB);

  // ═══════════════════════════════════════════════════════════
  // BACKGROUND COLORS - Matching home design
  // ═══════════════════════════════════════════════════════════

  /// Primary card background
  static const Color cardBgPrimary = Color(0xFFFFFFFF);

  /// Secondary card background
  static const Color cardBgSecondary = Color(0xFFF9FAFB);

  /// Selected pill background
  static const Color pillBgSelected = Color(0xFF1F2937);

  /// Unselected pill background
  static const Color pillBgUnselected = Color(0xFFF3F4F6);

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  /// Get budget health color based on status
  static Color getBudgetHealthColor(BudgetHealth health) {
    switch (health) {
      case BudgetHealth.healthy:
        return statusNormal;
      case BudgetHealth.warning:
        return statusWarning;
      case BudgetHealth.critical:
        return statusCritical;
      case BudgetHealth.overBudget:
        return statusOverBudget;
    }
  }

  /// Get progress color based on percentage (0.0 to 1.0)
  static Color getProgressColor(double percentage) {
    if (percentage < 0.5) return statusNormal;
    if (percentage < 0.75) return statusWarning;
    if (percentage < 1.0) return statusCritical;
    return statusOverBudget;
  }

  /// Get semantic color based on value type
  static Color getSemanticColor(SemanticType type) {
    switch (type) {
      case SemanticType.positive:
        return positive;
      case SemanticType.negative:
        return negative;
      case SemanticType.neutral:
        return neutral;
      case SemanticType.warning:
        return warning;
    }
  }

  /// Get gradient based on semantic type
  static LinearGradient getSemanticGradient(SemanticType type) {
    switch (type) {
      case SemanticType.positive:
        return positiveGradient;
      case SemanticType.negative:
        return negativeGradient;
      case SemanticType.neutral:
        return accountPrimaryGradient;
      case SemanticType.warning:
        return accountSecondaryGradient;
    }
  }
}

/// Budget health enumeration for color mapping
enum BudgetHealth {
  healthy,
  warning,
  critical,
  overBudget,
}

/// Semantic type enumeration for Account UI
enum SemanticType {
  positive,
  negative,
  neutral,
  warning,
}