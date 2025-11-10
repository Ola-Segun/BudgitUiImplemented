import 'package:flutter/material.dart';

/// Complete design token system for FinFlow Modern
///
/// Usage:
/// ```dart
/// Container(
///   padding: EdgeInsets.all(DesignTokens.spacing4),
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
///     boxShadow: DesignTokens.elevationLow,
///   ),
/// )
/// ```
class DesignTokens {

  // ============================================================================
  // SPACING SYSTEM
  // ============================================================================

  /// Base unit: 4px (all spacing derives from this)
  static const double baseUnit = 4.0;

  /// Micro spacing (rarely used)
  static const double spacing05 = baseUnit * 0.5;  // 2px

  /// Standard spacing scale
  static const double spacing1 = baseUnit * 1;     // 4px  - Tiny gaps, icon padding
  static const double spacing2 = baseUnit * 2;     // 8px  - Small gaps, chip padding
  static const double spacing3 = baseUnit * 3;     // 12px - Medium gaps, button padding
  static const double spacing4 = baseUnit * 4;     // 16px - Standard gaps, card padding
  static const double spacing5 = baseUnit * 5;     // 20px - Large gaps, section padding
  static const double spacing6 = baseUnit * 6;     // 24px - Extra large gaps
  static const double spacing7 = baseUnit * 7;     // 28px - Section headers
  static const double spacing8 = baseUnit * 8;     // 32px - Major sections
  static const double spacing10 = baseUnit * 10;   // 40px - Screen sections
  static const double spacing12 = baseUnit * 12;   // 48px - Large separations
  static const double spacing16 = baseUnit * 16;   // 64px - Major page divisions
  static const double spacing20 = baseUnit * 20;   // 80px - Hero sections

  /// Semantic spacing (use these for consistency)

  // Section gaps (between major content blocks)
  static const double sectionGapXs = spacing2;     // 8px
  static const double sectionGapSm = spacing3;     // 12px
  static const double sectionGapMd = spacing4;     // 16px
  static const double sectionGapLg = spacing6;     // 24px
  static const double sectionGapXl = spacing8;     // 32px

  // Card padding
  static const double cardPaddingXs = spacing2;    // 8px
  static const double cardPaddingSm = spacing3;    // 12px
  static const double cardPaddingMd = spacing4;    // 16px
  static const double cardPaddingLg = spacing5;    // 20px
  static const double cardPaddingXl = spacing6;    // 24px

  // Screen padding
  static const double screenPaddingH = spacing4;   // 16px - Horizontal
  static const double screenPaddingV = spacing4;   // 16px - Vertical
  static const double screenPaddingTop = spacing5; // 20px - Top (below app bar)

  // List item spacing
  static const double listItemGap = spacing3;      // 12px
  static const double listItemPadding = spacing4;  // 16px

  // ============================================================================
  // BORDER RADIUS SYSTEM
  // ============================================================================

  /// Border radius scale (consistent rounded corners)
  static const double radiusXs = 2.0;   // Subtle rounding
  static const double radiusSm = 4.0;   // Small elements
  static const double radiusMd = 8.0;   // Input fields, small cards
  static const double radiusLg = 12.0;  // Standard cards, buttons
  static const double radiusXl = 16.0;  // Large cards, modals
  static const double radiusXxl = 20.0; // Hero cards
  static const double radius3xl = 24.0; // Extra large cards
  static const double radiusFull = 999.0; // Fully rounded (pills)

  /// Semantic radius (use these for consistency)
  static const double cardRadius = radiusLg;       // 12px
  static const double buttonRadius = radiusLg;     // 12px
  static const double inputRadius = radiusMd;      // 8px
  static const double chipRadius = radiusFull;     // Fully rounded

  // ============================================================================
  // ELEVATION (SHADOW) SYSTEM
  // ============================================================================

  /// No shadow
  static List<BoxShadow> get elevationNone => [];

  /// Subtle elevation (hovering just above surface)
  static List<BoxShadow> get elevationXs => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Low elevation (cards on background)
  static List<BoxShadow> get elevationLow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Medium elevation (floating cards, dropdowns)
  static List<BoxShadow> get elevationMedium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// High elevation (modals, dialogs)
  static List<BoxShadow> get elevationHigh => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Extra high elevation (important modals)
  static List<BoxShadow> get elevationXl => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Colored elevation (for emphasis, buttons, important cards)
  static List<BoxShadow> elevationColored(
    Color color, {
    double alpha = 0.3,
    double blur = 12,
    double offsetY = 4,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: blur,
        offset: Offset(0, offsetY),
      ),
    ];
  }

  /// Glow effect (for active states, highlights)
  static List<BoxShadow> elevationGlow(
    Color color, {
    double alpha = 0.4,
    double spread = 2,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: 12,
        spreadRadius: spread,
        offset: const Offset(0, 0),
      ),
    ];
  }

  // ============================================================================
  // ICON SIZE SYSTEM
  // ============================================================================

  static const double iconXs = 12.0;   // Very small icons
  static const double iconSm = 16.0;   // Small icons, inline icons
  static const double iconMd = 20.0;   // Standard icons
  static const double iconLg = 24.0;   // Large icons, important actions
  static const double iconXl = 32.0;   // Extra large icons, featured items
  static const double iconXxl = 48.0;  // Hero icons, empty states
  static const double icon3xl = 64.0;  // Massive icons, splash screens

  // ============================================================================
  // BUTTON SIZE SYSTEM
  // ============================================================================

  static const double buttonHeightSm = 32.0;   // Small buttons
  static const double buttonHeightMd = 44.0;   // Standard buttons
  static const double buttonHeightLg = 56.0;   // Large buttons (primary actions)
  static const double buttonHeightXl = 64.0;   // Extra large buttons

  static const double buttonPaddingHSm = spacing3;  // 12px
  static const double buttonPaddingHMd = spacing4;  // 16px
  static const double buttonPaddingHLg = spacing6;  // 24px

  // ============================================================================
  // OPACITY SYSTEM
  // ============================================================================

  static const double opacityDisabled = 0.38;     // Disabled state
  static const double opacityHint = 0.6;          // Hint text, placeholders
  static const double opacitySecondary = 0.7;     // Secondary text
  static const double opacityHover = 0.08;        // Hover overlay
  static const double opacityPressed = 0.12;      // Pressed overlay
  static const double opacityFocus = 0.12;        // Focus overlay
  static const double opacityDrag = 0.16;         // Dragging overlay

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  static const Duration durationInstant = Duration.zero;
  static const Duration durationXs = Duration(milliseconds: 100);      // Micro interactions
  static const Duration durationSm = Duration(milliseconds: 150);      // Quick transitions
  static const Duration durationMd = Duration(milliseconds: 200);      // Fast animations
  static const Duration durationNormal = Duration(milliseconds: 300);  // Standard animations
  static const Duration durationLg = Duration(milliseconds: 400);      // Deliberate animations
  static const Duration durationSlow = Duration(milliseconds: 500);    // Slow animations
  static const Duration durationXl = Duration(milliseconds: 800);      // Very slow animations
  static const Duration durationSlower = Duration(milliseconds: 1000); // Extra slow

  // ============================================================================
  // ANIMATION CURVES
  // ============================================================================

  /// Standard easing curves
  static const Curve curveLinear = Curves.linear;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;

  /// Custom cubic bezier curves
  static const Curve curveEaseOutCubic = Curves.easeOutCubic;   // Exits, elements leaving
  static const Curve curveEaseInCubic = Curves.easeInCubic;     // Entrances from rest
  static const Curve curveStandard = Curves.easeInOut;          // Standard motion

  /// Emphatic curves
  static const Curve curveElastic = Curves.elasticOut;          // Bouncy, playful
  static const Curve curveElasticIn = Curves.elasticIn;         // Anticipation
  static const Curve curveBounceOut = Curves.bounceOut;         // Physical bounce

  /// Custom curves for specific use cases
  static const Curve curveDecelerate = Curves.decelerate;       // Slowing down
  static const Curve curveAccelerate = Curves.fastOutSlowIn;    // Speeding up

  // ============================================================================
  // Z-INDEX SYSTEM (for Stack positioning)
  // ============================================================================

  static const int zIndexBackground = 0;       // Background layers
  static const int zIndexContent = 10;         // Main content
  static const int zIndexFloating = 20;        // Floating elements (FAB)
  static const int zIndexSticky = 30;          // Sticky headers
  static const int zIndexOverlay = 40;         // Overlays, backdrops
  static const int zIndexModal = 50;           // Modals, dialogs
  static const int zIndexPopover = 60;         // Popovers, tooltips
  static const int zIndexToast = 70;           // Toasts, snackbars
  static const int zIndexTooltip = 80;         // Tooltips (highest)

  // ============================================================================
  // BREAKPOINTS (for responsive design)
  // ============================================================================

  static const double breakpointMobile = 0;      // 0-599px
  static const double breakpointTablet = 600;    // 600-1023px
  static const double breakpointDesktop = 1024;  // 1024-1439px
  static const double breakpointWide = 1440;     // 1440px+

  // ============================================================================
  // SAFE AREA PADDING
  // ============================================================================

  static const double safeAreaPaddingMin = spacing4;  // Minimum safe area
  static const double safeAreaPaddingMax = spacing8;  // Maximum safe area

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get responsive value based on screen width
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= breakpointWide && wide != null) return wide;
    if (width >= breakpointDesktop && desktop != null) return desktop;
    if (width >= breakpointTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get spacing based on size name
  static double spacingByName(String size) {
    switch (size.toLowerCase()) {
      case 'xs': return spacing1;
      case 'sm': return spacing2;
      case 'md': return spacing4;
      case 'lg': return spacing6;
      case 'xl': return spacing8;
      default: return spacing4;
    }
  }

  /// Get radius based on size name
  static double radiusByName(String size) {
    switch (size.toLowerCase()) {
      case 'xs': return radiusXs;
      case 'sm': return radiusSm;
      case 'md': return radiusMd;
      case 'lg': return radiusLg;
      case 'xl': return radiusXl;
      case 'full': return radiusFull;
      default: return radiusLg;
    }
  }

  /// Calculate spacing based on multiplier
  static double spacingMultiple(double multiplier) {
    return baseUnit * multiplier;
  }

  /// Get elevation based on level
  static List<BoxShadow> elevationByLevel(int level) {
    switch (level) {
      case 0: return elevationNone;
      case 1: return elevationXs;
      case 2: return elevationLow;
      case 3: return elevationMedium;
      case 4: return elevationHigh;
      case 5: return elevationXl;
      default: return elevationLow;
    }
  }
}