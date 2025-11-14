import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';

class GoalsThemeExtended {
  // Goal-specific colors - Updated to match teal palette
  static const Color goalPrimary = Color(0xFF00D4AA); // Teal (matching budget primary)
  static const Color goalSecondary = Color(0xFF7C3AED); // Purple (matching budget secondary)
  static const Color goalTertiary = Color(0xFFF59E0B); // Amber
  static const Color goalSuccess = Color(0xFF10B981); // Green (matching status normal)
  static const Color goalWarning = Color(0xFFF59E0B); // Amber (matching status warning)

  // Priority colors - Updated to match budget status colors
  static const Color priorityHigh = Color(0xFFEF4444); // Red (matching status critical)
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber (matching status warning)
  static const Color priorityLow = Color(0xFF6B7280); // Gray (matching text secondary)

  // Progress colors - reuse from budget
  static const Color progressNormal = AppColorsExtended.statusNormal;
  static const Color progressWarning = AppColorsExtended.statusWarning;
  static const Color progressCritical = AppColorsExtended.statusCritical;
}