import 'package:flutter/material.dart';

/// Modern Design System Constants
/// Based on the comprehensive form design system specification

/// Spacing System
const double spacing_xs = 4.0;  // Tiny gaps
const double spacing_sm = 8.0;  // Small elements
const double spacing_md = 16.0; // Component spacing
const double spacing_lg = 24.0; // Section spacing
const double spacing_xl = 32.0; // Major sections

/// Border Radius System
const double radius_sm = 8.0;
const double radius_md = 12.0;
const double radius_lg = 16.0;
const double radius_xl = 24.0;
const double radius_pill = 999.0;

/// Color Palette
class ModernColors {
  // Primary colors
  static const Color primaryBlack = Color(0xFF1A1A1A);
  static const Color primaryGray = Color(0xFFF5F5F5);
  static const Color accentGreen = Color(0xFF00D09C);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color borderColor = Color(0xFFE5E5EA);

  // Category colors (vibrant, distinct)
  static const Color categoryGreen = Color(0xFF00D09C);
  static const Color categoryBlack = Color(0xFF1A1A1A);
  static const Color categoryOrange = Color(0xFFFF6B2C);
  static const Color categoryBlue = Color(0xFF007AFF);
  static const Color categoryPink = Color(0xFFFF2D92);
  static const Color categoryPurple = Color(0xFF5E5CE6);

  // Semantic colors
  static const Color success = Color(0xFF00D09C);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Transaction colors
  static const Color income = Color(0xFF00D09C);
  static const Color expense = Color(0xFFFF3B30);

  // Light mode
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightBorder = Color(0xFFE5E5EA);

  // Dark mode
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkBorder = Color(0xFF38383A);
}

/// Typography System
class ModernTypography {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.0,
    color: ModernColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.0,
    color: ModernColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: ModernColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: ModernColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    color: ModernColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: ModernColors.textSecondary,
  );
}

/// Animation Durations
class ModernAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration sheet = Duration(milliseconds: 300);
}

/// Animation Curves
class ModernCurves {
  static const Curve easeOutCubic = Cubic(0.33, 1, 0.68, 1);
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve easeOut = Curves.easeOut;
}

/// Box Shadows
class ModernShadows {
  static const BoxShadow subtle = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x29000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}

/// Component Sizes
class ModernSizes {
  static const double touchTarget = 44.0;
  static const double buttonHeight = 48.0;
  static const double textFieldHeight = 48.0;
  static const double categoryIconSize = 56.0;
  static const double keyboardButtonSize = 64.0;
}