import 'package:flutter/material.dart';

/// Central color system for the application
/// Based on hybrid design: TrackFinz (teal) + Pink App (clean) + Modern Budget Tracker
class AppColors {
  AppColors._(); // Private constructor prevents instantiation

  // ═══════════════════════════════════════════════════════════
  // PRIMARY COLORS - Teal from TrackFinz
  // ═══════════════════════════════════════════════════════════

  /// Main brand color - Use for primary actions, active states
  static const Color primary = Color(0xFF14B8A6);

  /// Lighter teal - Use for hover states, backgrounds
  static const Color primaryLight = Color(0xFF5EEAD4);

  /// Darker teal - Use for pressed states
  static const Color primaryDark = Color(0xFF0F766E);

  /// Accent teal - Use for highlights
  static const Color primaryAccent = Color(0xFF2DD4BF);

  // ═══════════════════════════════════════════════════════════
  // SECONDARY COLORS - Pink for warmth
  // ═══════════════════════════════════════════════════════════

  static const Color secondary = Color(0xFFEC4899);
  static const Color secondaryLight = Color(0xFFF9A8D4);
  static const Color secondaryDark = Color(0xFFDB2777);

  // ═══════════════════════════════════════════════════════════
  // TERTIARY COLORS - Purple for accents
  // ═══════════════════════════════════════════════════════════

  static const Color tertiary = Color(0xFF8B5CF6);
  static const Color tertiaryLight = Color(0xFFC4B5FD);
  static const Color tertiaryDark = Color(0xFF6D28D9);

  // ═══════════════════════════════════════════════════════════
  // SEMANTIC COLORS - Status indicators
  // ═══════════════════════════════════════════════════════════

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color danger = error;

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ═══════════════════════════════════════════════════════════
  // NEUTRAL COLORS - Backgrounds, surfaces
  // ═══════════════════════════════════════════════════════════

  static const Color background = Color(0xFFF2F4F6);
  static const Color background2 = Color(0xFFE9ECF0);
  static const Color backgroundAlt = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Additional colors
  static const Color surfaceDark = backgroundAlt;

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // ═══════════════════════════════════════════════════════════
  // CATEGORY COLORS - For transactions/budgets
  // ═══════════════════════════════════════════════════════════

  static const Map<String, Color> categoryColors = {
    'food': Color(0xFFF97316),
    'transport': Color(0xFF3B82F6),
    'shopping': Color(0xFFEC4899),
    'entertainment': Color(0xFF8B5CF6),
    'health': Color(0xFF10B981),
    'utilities': Color(0xFF06B6D4),
    'housing': Color(0xFF6366F1),
    'education': Color(0xFFFBBF24),
    'business': Color(0xFF14B8A6),
  };

  // ═══════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
  );

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  /// Get category color by name, returns primary if not found
  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? primary;
  }

  /// Get category color with opacity for backgrounds
  static Color getCategoryBackground(String category, {double opacity = 0.1}) {
    return getCategoryColor(category).withOpacity(opacity);
  }
}