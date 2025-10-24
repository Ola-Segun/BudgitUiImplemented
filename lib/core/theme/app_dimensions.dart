import 'package:flutter/material.dart';

/// Central dimensions system for the application
/// All spacing, sizing, and radius values
class AppDimensions {
  AppDimensions._();

  // ═══════════════════════════════════════════════════════════
  // BORDER RADIUS - Rounded corners
  // ═══════════════════════════════════════════════════════════

  static const double radiusXs = 6;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2xl = 24;
  static const double radiusFull = 9999;

  /// Semantic radius for common components
  static const double buttonRadius = radiusMd;
  static const double cardRadius = radiusLg;
  static const double inputRadius = radiusMd;
  static const double modalRadius = radius2xl;
  static const double categoryIconRadius = radiusMd;

  // ═══════════════════════════════════════════════════════════
  // SPACING SCALE - Based on 4px unit
  // ═══════════════════════════════════════════════════════════

  static const double spacing0 = 0;
  static const double spacing1 = 4;
  static const double spacing2 = 8;
  static const double spacing3 = 12;
  static const double spacing4 = 16;
  static const double spacing5 = 20;
  static const double spacing6 = 24;
  static const double spacing8 = 32;
  static const double spacing10 = 40;
  static const double spacing12 = 48;

  /// Semantic spacing for common use cases
  static const double screenPaddingH = 16;
  static const double screenPaddingV = 16;
  static const double cardPadding = 16;
  static const double cardPaddingLarge = 20;
  static const double sectionGap = 24;
  static const double componentGap = 16;

  // ═══════════════════════════════════════════════════════════
  // COMPONENT SIZES
  // ═══════════════════════════════════════════════════════════

  /// Icon sizes
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 28;
  static const double iconXl = 32;

  /// Button heights
  static const double buttonHeightMd = 48;
  static const double buttonHeightLg = 56;

  /// Category icon
  static const double categoryIconSize = 48;

  /// Touch target minimum (accessibility)
  static const double minTouchTarget = 48;

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  /// Create BorderRadius from radius value
  static BorderRadius borderRadius(double radius) {
    return BorderRadius.circular(radius);
  }

  /// Standard card border radius
  static BorderRadius get cardBorderRadius => borderRadius(cardRadius);

  /// Standard button border radius
  static BorderRadius get buttonBorderRadius => borderRadius(buttonRadius);
}