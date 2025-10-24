import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central typography system
/// Uses Inter font for modern, clean look
class AppTypography {
  AppTypography._();

  // Font family
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  // ═══════════════════════════════════════════════════════════
  // TEXT THEME - For Material Theme
  // ═══════════════════════════════════════════════════════════

  static TextTheme get textTheme => TextTheme(
        displayLarge: hero,
        displayMedium: display,
        displaySmall: h1,
        headlineLarge: h1,
        headlineMedium: h2,
        headlineSmall: h3,
        titleLarge: h2,
        titleMedium: h3,
        bodyLarge: body,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: bodyMedium,
        labelMedium: caption,
        labelSmall: overline,
      );

  // ═══════════════════════════════════════════════════════════
  // DISPLAY STYLES - Large headers, hero text
  // ═══════════════════════════════════════════════════════════

  /// Hero style - Use for splash screens, major moments
  /// Example: "Welcome to Budget App"
  static final TextStyle hero = GoogleFonts.inter(
    fontSize: 56,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -2.5,
    color: AppColors.textPrimary,
  );

  /// Display style - Use for large balance displays
  /// Example: "$1,234.56"
  static final TextStyle display = GoogleFonts.inter(
    fontSize: 40,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════
  // HEADING STYLES
  // ═══════════════════════════════════════════════════════════

  /// H1 - Use for screen titles
  /// Example: "Transactions", "Budget Overview"
  static final TextStyle h1 = GoogleFonts.inter(
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  /// H2 - Use for section headers
  /// Example: "Recent Transactions", "Active Goals"
  static final TextStyle h2 = GoogleFonts.inter(
    fontSize: 22,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  /// H3 - Use for card titles, subsections
  /// Example: "Food & Dining", "Monthly Budget"
  static final TextStyle h3 = GoogleFonts.inter(
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════
  // BODY STYLES
  // ═══════════════════════════════════════════════════════════

  /// Body - Use for main content, descriptions
  /// Example: Transaction descriptions, form labels
  static final TextStyle body = GoogleFonts.inter(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Body Medium - Use for emphasized body text
  /// Example: Button labels, important text
  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Body Small - Use for secondary information
  /// Example: Subtitles, helper text
  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  // ═══════════════════════════════════════════════════════════
  // SUPPORTING STYLES
  // ═══════════════════════════════════════════════════════════

  /// Caption - Use for timestamps, metadata
  /// Example: "2 hours ago", "Oct 16"
  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  /// Overline - Use for labels, tags
  /// Example: "EXPENSE", "INCOME"
  static final TextStyle overline = GoogleFonts.inter(
    fontSize: 11,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );

  // ═══════════════════════════════════════════════════════════
  // SPECIAL PURPOSE STYLES
  // ═══════════════════════════════════════════════════════════

  /// Currency - Use for transaction amounts
  /// Includes tabular figures for alignment
  static final TextStyle currency = GoogleFonts.inter(
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  /// Currency Large - Use for balance displays
  static final TextStyle currencyLarge = GoogleFonts.inter(
    fontSize: 48,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -2,
    color: AppColors.textPrimary,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  /// Button Text
  static final TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════
  // STATIC GETTERS FOR TEXT THEME STYLES
  // ═══════════════════════════════════════════════════════════

  static TextStyle get bodyLarge => body;
  static TextStyle get labelLarge => bodyMedium;
  static TextStyle get labelMedium => caption;
  static TextStyle get titleLarge => h2;
  static TextStyle get titleMedium => h3;
  static TextStyle get titleSmall => h3;
  static TextStyle get headlineLarge => h1;
  static TextStyle get headlineMedium => h2;
  static TextStyle get headlineSmall => h3;
  static TextStyle get buttonLarge => button;
  static TextStyle get buttonMedium => button;
}