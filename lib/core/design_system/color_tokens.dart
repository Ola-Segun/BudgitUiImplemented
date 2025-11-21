import 'package:flutter/material.dart';

/// Extended color system with semantic naming
class ColorTokens {

  // ============================================================================
  // PRIMARY PALETTE
  // ============================================================================

  /// Teal - Trust, growth, financial health
  static const Color teal50 = Color(0xFFE6FAF5);
  static const Color teal100 = Color(0xFFB3F0E0);
  static const Color teal200 = Color(0xFF80E7CC);
  static const Color teal300 = Color(0xFF4DDDB7);
  static const Color teal400 = Color(0xFF1AD4A3);
  static const Color teal500 = Color(0xFF00D4AA); // Primary
  static const Color teal600 = Color(0xFF00B894);
  static const Color teal700 = Color(0xFF009D7F);
  static const Color teal800 = Color(0xFF008169);
  static const Color teal900 = Color(0xFF006654);

  /// Purple - Premium, insights, analytics
  static const Color purple50 = Color(0xFFF5F3FF);
  static const Color purple100 = Color(0xFFEDE9FE);
  static const Color purple200 = Color(0xFFDDD6FE);
  static const Color purple300 = Color(0xFFC4B5FD);
  static const Color purple400 = Color(0xFFA78BFA);
  static const Color purple500 = Color(0xFF8B5CF6);
  static const Color purple600 = Color(0xFF7C3AED); // Primary
  static const Color purple700 = Color(0xFF6D28D9);
  static const Color purple800 = Color(0xFF5B21B6);
  static const Color purple900 = Color(0xFF4C1D95);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Success/Positive - Income, savings, on-track
  static const Color success50 = Color(0xFFECFDF5);
  static const Color success100 = Color(0xFFD1FAE5);
  static const Color success200 = Color(0xFFA7F3D0);
  static const Color success300 = Color(0xFF6EE7B7);
  static const Color success400 = Color(0xFF34D399);
  static const Color success500 = Color(0xFF10B981); // Primary
  static const Color success600 = Color(0xFF059669);
  static const Color success700 = Color(0xFF047857);
  static const Color success800 = Color(0xFF065F46);
  static const Color success900 = Color(0xFF064E3B);

  /// Warning - Caution, approaching limits
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning200 = Color(0xFFFDE68A);
  static const Color warning300 = Color(0xFFFCD34D);
  static const Color warning400 = Color(0xFFFBBF24);
  static const Color warning500 = Color(0xFFF59E0B); // Primary
  static const Color warning600 = Color(0xFFD97706);
  static const Color warning700 = Color(0xFFB45309);
  static const Color warning800 = Color(0xFF92400E);
  static const Color warning900 = Color(0xFF78350F);

  /// Critical/Error - Urgent, over-budget, expenses
  static const Color critical50 = Color(0xFFFEF2F2);
  static const Color critical100 = Color(0xFFFEE2E2);
  static const Color critical200 = Color(0xFFFECACA);
  static const Color critical300 = Color(0xFFFCA5A5);
  static const Color critical400 = Color(0xFFF87171);
  static const Color critical500 = Color(0xFFEF4444); // Primary
  static const Color critical600 = Color(0xFFDC2626);
  static const Color critical700 = Color(0xFFB91C1C);
  static const Color critical800 = Color(0xFF991B1B);
  static const Color critical900 = Color(0xFF7F1D1D);

  /// Info/Neutral - Information, status
  static const Color info50 = Color(0xFFEFF6FF);
  static const Color info100 = Color(0xFFDBEAFE);
  static const Color info200 = Color(0xFFBFDBFE);
  static const Color info300 = Color(0xFF93C5FD);
  static const Color info400 = Color(0xFF60A5FA);
  static const Color info500 = Color(0xFF3B82F6); // Primary
  static const Color info600 = Color(0xFF2563EB);
  static const Color info700 = Color(0xFF1D4ED8);
  static const Color info800 = Color(0xFF1E40AF);
  static const Color info900 = Color(0xFF1E3A8A);

  // ============================================================================
  // FEATURE-SPECIFIC COLORS
  // ============================================================================

  /// Budget colors
  static const Color budgetPrimary = teal500;
  static const Color budgetSecondary = purple600;
  static const Color budgetTertiary = Color(0xFFF59E0B); // Orange/Amber

  /// Goal colors
  static const Color goalPrimary = purple600;  // Indigo
  static const Color goalSecondary = purple500;
  static const Color goalSuccess = success500;

  /// Bill colors
  static const Color billPrimary = Color(0xFFEC4899); // Pink
  static const Color billSecondary = purple600;

  /// Income colors
  static const Color incomePrimary = Color(0xFF14B8A6); // Teal
  static const Color incomeSecondary = Color(0xFF06B6D4); // Cyan

  /// Transaction colors
  static const Color transactionIncome = success500;
  static const Color transactionExpense = critical500;
  static const Color transactionTransfer = info500;

  // ============================================================================
  // NEUTRAL COLORS (Grayscale)
  // ============================================================================

  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ============================================================================
  // SURFACE COLORS
  // ============================================================================

  static const Color surfaceBackground = Color(0xFFF9FAFB);
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF3F4F6);
  static const Color surfaceTertiary = Color(0xFFE5E7EB);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceOverlay = Color(0x80000000); // 50% black

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textLink = info600;

  // ============================================================================
  // BORDER COLORS
  // ============================================================================

  static const Color borderPrimary = Color(0xFFE5E7EB);
  static const Color borderSecondary = Color(0xFFF3F4F6);
  static const Color borderFocus = info500;
  static const Color borderError = critical500;
  static const Color borderSuccess = success500;

  // ============================================================================
  // FUNCTIONAL COLORS
  // ============================================================================

  static const Color overlay = Color(0x80000000);
  static const Color backdrop = Color(0xB3000000);
  static const Color scrim = Color(0x99000000);
  static const Color divider = Color(0x1F000000);

  // ============================================================================
  // STATUS COLORS (reusing semantic colors with aliases)
  // ============================================================================

  static const Color statusNormal = success500;
  static const Color statusWarning = warning500;
  static const Color statusCritical = critical500;
  static const Color statusOverBudget = critical600;
  static const Color statusPaid = success500;
  static const Color statusPending = warning500;
  static const Color statusFailed = critical500;
  static const Color statusReceived = success500;
  static const Color statusExpected = info500;
  static const Color statusOverdue = critical600;

  // ============================================================================
  // FORM DESIGN SYSTEM COLORS (from FormDesign screenshots)
  // ============================================================================

  /// Form primary dark color
  static const Color formPrimaryDark = Color(0xFF0F172A);

  /// Form primary teal color
  static const Color formPrimaryTeal = Color(0xFF14B8A6);

  /// Form background light
  static const Color formBackgroundLight = Color(0xFFF2F4F6);

  /// Form surface white
  static const Color formSurfaceWhite = Color(0xFFFFFFFF);

  /// Form border light
  static const Color formBorderLight = Color(0xFFE2E8F0);

  /// Form text secondary
  static const Color formTextSecondary = Color(0xFF94A3B8);

  /// Form error color
  static const Color formErrorColor = Color(0xFFEF4444);

  // ============================================================================
  // CHART COLORS (for data visualization)
  // ============================================================================

  static const List<Color> chartColors = [
    teal500,
    purple600,
    warning500,
    critical500,
    info500,
    success500,
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF59E0B), // Orange
    Color(0xFF8B5CF6), // Purple variant
  ];

  static const Color chartTooltipBg = Color(0xFF1F2937);
  static const Color chartAxisLine = Color(0xFFE5E7EB);
  static const Color chartGridLine = Color(0xFFF3F4F6);

  // ============================================================================
  // GRADIENT PRESETS
  // ============================================================================

  static LinearGradient get gradientPrimary => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal500, teal600],
  );

  static LinearGradient get gradientSecondary => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple600, purple700],
  );

  static LinearGradient get gradientSuccess => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success500, success600],
  );

  static LinearGradient get gradientWarning => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning500, warning600],
  );

  static LinearGradient get gradientCritical => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [critical500, critical600],
  );

  static LinearGradient gradientCustom(Color start, Color end) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [start, end],
  );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get lighter shade of color
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Get darker shade of color
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Check if color is light
  static bool isLight(Color color) {
    return color.computeLuminance() > 0.5;
  }

  /// Get contrasting text color
  static Color getContrastingTextColor(Color backgroundColor) {
    return isLight(backgroundColor) ? textPrimary : textInverse;
  }
}