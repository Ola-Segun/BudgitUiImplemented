import 'package:flutter/material.dart';

class ObligationsTheme {
  // Primary Colors - TrackFinz Brand
  static const Color trackfinzPrimary = Color(0xFF00D4AA); // Teal/Mint
  static const Color trackfinzSecondary = Color(0xFF00B894); // Darker Teal
  static const Color trackfinzAccent = Color(0xFF1DE9B6); // Light Mint

  // Status Colors - Matching TrackFinz
  static const Color statusNormal = Color(0xFF10B981); // Green
  static const Color statusWarning = Color(0xFFF59E0B); // Amber
  static const Color statusCritical = Color(0xFFEF4444); // Red
  static const Color statusOverdue = Color(0xFFDC2626); // Dark Red

  // Background & Surface
  static const Color background = Color(0xFFF9FAFB); // Light gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBg = Color(0xFFF3F4F6); // Light card background

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Almost black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);

  // Gradient Colors
  static List<Color> get primaryGradient => [
    trackfinzPrimary,
    trackfinzPrimary.withValues(alpha: 0.8),
  ];

  static List<Color> get successGradient => [
    statusNormal,
    statusNormal.withValues(alpha: 0.8),
  ];

  static List<Color> get warningGradient => [
    statusWarning,
    statusWarning.withValues(alpha: 0.8),
  ];

  static List<Color> get criticalGradient => [
    statusCritical,
    statusCritical.withValues(alpha: 0.8),
  ];
}