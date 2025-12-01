import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';

class GoalsThemeExtended {
  // Primary goal colors (already defined, ensuring consistency)
  static const Color goalPrimary = Color(0xFF6366F1); // Indigo
  static const Color goalSecondary = Color(0xFF8B5CF6); // Purple
  static const Color goalSuccess = Color(0xFF10B981); // Green
  static const Color goalWarning = Color(0xFFF59E0B); // Amber

  // Template-specific colors
  static const Color templateEmergency = Color(0xFFEF4444); // Red
  static const Color templateVacation = Color(0xFF06B6D4); // Cyan
  static const Color templateHome = Color(0xFFF59E0B); // Orange
  static const Color templateDebt = Color(0xFF8B5CF6); // Purple
  static const Color templateCar = Color(0xFF3B82F6); // Blue
  static const Color templateEducation = Color(0xFF10B981); // Green
  static const Color templateRetirement = Color(0xFF6366F1); // Indigo
  static const Color templateInvestment = Color(0xFF14B8A6); // Teal
  static const Color templateWedding = Color(0xFFEC4899); // Pink

  // Priority colors - Updated to match budget status colors
  static const Color priorityHigh = Color(0xFFEF4444); // Red (matching status critical)
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber (matching status warning)
  static const Color priorityLow = Color(0xFF6B7280); // Gray (matching text secondary)

  // Tertiary color for additional styling
  static const Color goalTertiary = Color(0xFFF59E0B); // Amber

  // Card styling
  static const double cardElevation = 0;
  static const double cardBorderRadius = 16;
  static const double cardPadding = 20;

  // Selection states
  static const double selectedBorderWidth = 2.5;
  static const double unselectedBorderWidth = 1;

  // Animation durations
  static const Duration cardAnimationDuration = Duration(milliseconds: 400);
  static const Duration staggerDelay = Duration(milliseconds: 100);

  // Shadows
  static BoxShadow getCardShadow(BuildContext context) {
    return BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    );
  }

  static BoxShadow getSelectedCardShadow(BuildContext context, Color color) {
    return BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    );
  }

  // Get template color by icon name
  static Color getTemplateColor(String? iconName) {
    switch (iconName) {
      case 'security':
        return templateEmergency;
      case 'beach_access':
        return templateVacation;
      case 'home':
        return templateHome;
      case 'credit_card_off':
        return templateDebt;
      case 'directions_car':
        return templateCar;
      case 'school':
        return templateEducation;
      case 'account_balance':
        return templateRetirement;
      case 'trending_up':
        return templateInvestment;
      case 'favorite':
        return templateWedding;
      default:
        return goalPrimary;
    }
  }
}