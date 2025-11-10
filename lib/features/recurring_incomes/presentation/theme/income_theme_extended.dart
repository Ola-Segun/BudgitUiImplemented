import 'package:flutter/material.dart';

class IncomeThemeExtended {
  // Income-specific colors - Updated to match teal palette
  static const Color incomePrimary = Color(0xFF00D4AA); // Teal (matching budget primary)
  static const Color incomeSecondary = Color(0xFF7C3AED); // Purple (matching budget secondary)

  // Receipt status colors - Updated to match budget status colors
  static const Color statusReceived = Color(0xFF10B981); // Green (matching status normal)
  static const Color statusExpected = Color(0xFF3B82F6); // Blue (matching status warning)
  static const Color statusOverdue = Color(0xFFEF4444); // Red (matching status critical)
}