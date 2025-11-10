🎨 COMPREHENSIVE UNIVERSAL DESIGN SYSTEM & IMPLEMENTATION GUIDE
📐 PART 1: DESIGN FOUNDATION
1.1 Design Philosophy & Principles
yamlDesign System Name: "FinFlow Modern"
Version: 2.0
Last Updated: 2025

Core Philosophy:
  Vision: "Financial clarity through elegant simplicity"
  Mission: "Every pixel serves a purpose, every interaction delights"
  
  Guiding Principles:
    1. Visual Hierarchy:
       - Use size, weight, and color to guide attention
       - Most important information should be immediately visible
       - Progressive disclosure of complex data
       
    2. Consistency:
       - Reuse patterns across all screens
       - Predictable component behavior
       - Unified interaction patterns
       
    3. Immediate Feedback:
       - Visual responses to all interactions
       - Haptic feedback for important actions
       - Loading states that inform, not frustrate
       
    4. Scannable Clarity:
       - Information density optimized for quick comprehension
       - Clear typography hierarchy
       - Strategic use of whitespace
       
    5. Delightful Motion:
       - Purposeful animations that guide attention
       - Smooth transitions between states
       - Performance-optimized for 60fps
       
    6. Accessible by Default:
       - WCAG 2.1 AA compliance minimum
       - Touch targets minimum 48x48dp
       - Semantic color usage with text labels
       
    7. Data-First Design:
       - Prioritize actionable insights
       - Visualize trends effectively
       - Make complex data understandable

Color Psychology:
  Primary Colors:
    Teal (#00D4AA): Trust, growth, financial health, stability
    Purple (#7C3AED): Premium features, insights, analytics
    Blue (#3B82F6): Information, neutrality, reliability
    
  Semantic Colors:
    Success Green (#10B981): Positive actions, income, savings, on-track
    Warning Amber (#F59E0B): Caution, approaching limits, attention needed
    Critical Red (#EF4444): Urgent attention, expenses, over-budget
    Error Dark Red (#DC2626): Errors, failed actions, danger
    
  Supporting Colors:
    Orange (#F59E0B): Highlights, special items, badges
    Pink (#EC4899): Bills, subscriptions, recurring payments
    Cyan (#06B6D4): Income, deposits, positive cash flow
    Indigo (#6366F1): Goals, targets, aspirations

Typography Philosophy:
  Font Family: Inter (with SF Pro fallback)
  Principles:
    - Clarity over decoration
    - Consistent scale based on modular system
    - Appropriate weight for hierarchy
    - Optimized line height for readability
    - Strategic use of letter spacing

Spacing Philosophy:
  Base Unit: 4px (0.25rem)
  Principles:
    - All spacing is multiple of base unit
    - Consistent rhythm throughout app
    - Generous padding for touch targets
    - Strategic use of negative space
    - Grouped related content

Animation Philosophy:
  Principles:
    - Purpose: Guide attention, provide feedback, maintain context
    - Duration: Fast enough to feel instant, slow enough to perceive
    - Easing: Natural motion curves (ease-out for entrances, ease-in for exits)
    - Performance: 60fps maintained, GPU-accelerated transforms
    - Accessibility: Respect prefers-reduced-motion

📏 PART 2: DESIGN TOKENS
2.1 Complete Token System
dart// lib/core/design_system/design_tokens.dart

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
  static const double modalRadius = radiusXxl;     // 20px
  static const double avatarRadius = radiusFull;   // Fully rounded
  
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
2.2 Extended Color System
dart// lib/core/design_system/color_tokens.dart

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

🔤 PART 3: TYPOGRAPHY SYSTEM
dart// lib/core/design_system/typography_tokens.dart

import 'package:flutter/material.dart';
import 'color_tokens.dart';

/// CompleteRetryBContinuedart/// Complete typography system with semantic naming
class TypographyTokens {
  
  // ============================================================================
  // FONT FAMILIES
  // ============================================================================
  
  static const String fontFamilyPrimary = 'Inter';
  static const String fontFamilyFallback = 'SF Pro Display';
  static const String fontFamilyMono = 'JetBrains Mono';
  
  static const List<String> fontFamilyStack = [
    fontFamilyPrimary,
    fontFamilyFallback,
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];
  
  // ============================================================================
  // FONT WEIGHTS
  // ============================================================================
  
  static const FontWeight weightThin = FontWeight.w100;
  static const FontWeight weightExtraLight = FontWeight.w200;
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;
  static const FontWeight weightBlack = FontWeight.w900;
  
  // ============================================================================
  // FONT SIZES
  // ============================================================================
  
  static const double fontSize3xs = 10.0;
  static const double fontSize2xs = 11.0;
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 13.0;
  static const double fontSizeBase = 14.0;   // Base size
  static const double fontSizeMd = 15.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSize2xl = 20.0;
  static const double fontSize3xl = 24.0;
  static const double fontSize4xl = 28.0;
  static const double fontSize5xl = 32.0;
  static const double fontSize6xl = 36.0;
  static const double fontSize7xl = 48.0;
  static const double fontSize8xl = 64.0;
  
  // ============================================================================
  // LINE HEIGHTS
  // ============================================================================
  
  static const double lineHeightTight = 1.2;
  static const double lineHeightSnug = 1.3;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.5;
  static const double lineHeightLoose = 1.6;
  
  // ============================================================================
  // LETTER SPACING
  // ============================================================================
  
  static const double letterSpacingTighter = -0.8;
  static const double letterSpacingTight = -0.4;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.4;
  static const double letterSpacingWider = 0.8;
  
  // ============================================================================
  // DISPLAY STYLES (Hero text, large headings)
  // ============================================================================
  
  static TextStyle get display1 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize8xl,
    fontWeight: weightBlack,
    height: lineHeightTight,
    letterSpacing: letterSpacingTighter,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get display2 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize7xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get display3 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize6xl,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
  );
  
  // ============================================================================
  // HEADING STYLES
  // ============================================================================
  
  static TextStyle get heading1 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize5xl,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get heading2 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize4xl,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get heading3 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize3xl,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get heading4 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xl,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get heading5 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXl,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get heading6 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  // ============================================================================
  // BODY TEXT STYLES
  // ============================================================================
  
  static TextStyle get bodyXl => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXl,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get bodyLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get bodyMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get bodySm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get bodyXs => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  // ============================================================================
  // LABEL STYLES
  // ============================================================================
  
  static TextStyle get labelLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get labelMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get labelSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get labelXs => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: ColorTokens.textPrimary,
  );
  
  // ============================================================================
  // CAPTION STYLES
  // ============================================================================
  
  static TextStyle get captionLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );
  
  static TextStyle get captionMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );
  
  static TextStyle get captionSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xs,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );
  
  // ============================================================================
  // OVERLINE STYLES (Small caps, uppercase labels)
  // ============================================================================
  
  static TextStyle get overlineLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
    color: ColorTokens.textSecondary,
  );
  
  static TextStyle get overlineMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
    color: ColorTokens.textSecondary,
  );
  
  static TextStyle get overlineSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize3xs,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
    color: ColorTokens.textSecondary,
  );
  
  // ============================================================================
  // BUTTON TEXT STYLES
  // ============================================================================
  
  static TextStyle get buttonLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get buttonMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get buttonSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  // ============================================================================
  // NUMERIC STYLES (For financial data)
  // ============================================================================
  
  static TextStyle get numericXl => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize5xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  static TextStyle get numericLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize3xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  static TextStyle get numericMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xl,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  static TextStyle get numericSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  // ============================================================================
  // LINK STYLES
  // ============================================================================
  
  static TextStyle get linkLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightMedium,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textLink,
    decoration: TextDecoration.underline,
  );
  
  static TextStyle get linkMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightMedium,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textLink,
    decoration: TextDecoration.underline,
  );
  
  static TextStyle get linkSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textLink,
    decoration: TextDecoration.underline,
  );
  
  // ============================================================================
  // CODE/MONOSPACE STYLES
  // ============================================================================
  
  static TextStyle get codeLg => TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: fontSizeLg,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get codeMd => TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: fontSizeBase,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  static TextStyle get codeSm => TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: fontSizeSm,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  // ============================================================================
  // SEMANTIC STYLES (App-specific)
  // ============================================================================
  
  /// Circular progress percentage (e.g., "32%")
  static TextStyle get circularProgressPercentage => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize5xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  /// Circular progress amount (e.g., "$83 / $200")
  static TextStyle get circularProgressAmount => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  /// Date pill day (e.g., "24")
  static TextStyle get datePillDay => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  /// Date pill label (e.g., "Mon")
  static TextStyle get datePillLabel => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );
  
  /// Status message
  static TextStyle get statusMessage => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );
  
  /// Metric percentage (e.g., "56%")
  static TextStyle get metricPercentage => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize4xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  /// Metric label (e.g., "Usage Rate")
  static TextStyle get metricLabel => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );
  
  /// Stats value (e.g., "$1,250")
  static TextStyle get statsValue => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  /// Stats label (e.g., "Spent")
  static TextStyle get statsLabel => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );
  
  /// Chart label
  static TextStyle get chartLabel => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textTertiary,
  );
  
  /// Chart tooltip
  static TextStyle get chartTooltip => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textInverse,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Apply weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Apply size to text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  /// Make text style bold
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: weightBold);
  }
  
  /// Make text style italic
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }
  
  /// Make text style underlined
  static TextStyle underline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }
  
  /// Apply line through decoration
  static TextStyle strikethrough(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.lineThrough);
  }
  
  /// Apply opacity to text
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha: opacity));
  }
  
  /// Get text style by name
  static TextStyle? getStyleByName(String name) {
    switch (name.toLowerCase()) {
      case 'display1': return display1;
      case 'display2': return display2;
      case 'display3': return display3;
      case 'heading1': case 'h1': return heading1;
      case 'heading2': case 'h2': return heading2;
      case 'heading3': case 'h3': return heading3;
      case 'heading4': case 'h4': return heading4;
      case 'heading5': case 'h5': return heading5;
      case 'heading6': case 'h6': return heading6;
      case 'bodyxl': return bodyXl;
      case 'bodylg': return bodyLg;
      case 'bodymd': return bodyMd;
      case 'bodysm': return bodySm;
      case 'bodyxs': return bodyXs;
      default: return null;
    }
  }
}

🎯 PART 4: COMPONENT PATTERNS
4.1 Info Card Pattern (Enhanced)
dart// lib/core/design_system/patterns/info_card_pattern.dart

import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Standard info card pattern with consistent styling
/// 
/// Features:
/// - Icon header with colored background
/// - Title with optional trailing widget
/// - Flexible content area
/// - Consistent padding and styling
/// - Optional tap handler
/// 
/// Usage:
/// ```dart
/// InfoCardPattern(
///   title: 'Budget Overview',
///   icon: Icons.pie_chart,
///   iconColor: ColorTokens.budgetPrimary,
///   trailing: TextButton(child: Text('View All')),
///   children: [
///     Text('Your content here'),
///   ],
///   onTap: () => navigate(),
/// )
/// ```
class InfoCardPattern extends StatelessWidget {
  const InfoCardPattern({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.trailing,
    required this.children,
    this.onTap,
    this.padding,
    this.elevation,
  });

  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final List<Widget> children;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final List<BoxShadow>? elevation;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? ColorTokens.teal500;
    final effectivePadding = padding ?? EdgeInsets.all(DesignTokens.cardPaddingLg);
    final effectiveElevation = elevation ?? DesignTokens.elevationLow;
    
    final cardContent = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        boxShadow: effectiveElevation,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: ColorTokens.withOpacity(color, 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  icon,
                  size: DesignTokens.iconMd,
                  color: color,
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Text(
                  title,
                  style: TypographyTokens.heading6,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: DesignTokens.spacing2),
                trailing!,
              ],
            ],
          ),
          SizedBox(height: DesignTokens.spacing4),
          
          // Content
          ...children,
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
4.2 Status Badge Pattern (Enhanced)
dart// lib/core/design_system/patterns/status_badge_pattern.dart

import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Status badge sizes
enum StatusBadgeSize {
  small,
  medium,
  large,
}

/// Status badge variants
enum StatusBadgeVariant {
  filled,      // Solid background
  outlined,    // Border only
  subtle,      // Light background
}

/// Standard status badge pattern
/// 
/// Features:
/// - Multiple sizes and variants
/// - Optional icon
/// - Semantic colors
/// - Consistent styling
/// 
/// Usage:
/// ```dart
/// StatusBadgePattern(
///   label: 'Active',
///   color: ColorTokens.statusNormal,
///   icon: Icons.check_circle,
///   size: StatusBadgeSize.medium,
///   variant: StatusBadgeVariant.subtle,
/// )
/// ```
class StatusBadgePattern extends StatelessWidget {
  const StatusBadgePattern({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.size = StatusBadgeSize.medium,
    this.variant = StatusBadgeVariant.subtle,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final StatusBadgeSize size;
  final StatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final textStyle = _getTextStyle();
    final decoration = _getDecoration();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.paddingH,
        vertical: dimensions.paddingV,
      ),
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dimensions.iconSize, color: _getContentColor()),
            SizedBox(width: dimensions.iconSpacing),
          ],
          Text(
            label,
            style: textStyle.copyWith(color: _getContentColor()),
          ),
        ],
      ),
    );
  }

  _BadgeDimensions _getDimensions() {
    switch (size) {
      case StatusBadgeSize.small:
        return _BadgeDimensions(
          paddingH: DesignTokens.spacing2,
          paddingV: DesignTokens.spacing05,
          iconSize: DesignTokens.iconXs,
          iconSpacing: DesignTokens.spacing1,
        );
      case StatusBadgeSize.medium:
        return _BadgeDimensions(
          paddingH: DesignTokens.spacing3,
          paddingV: DesignTokens.spacing1,
          iconSize: DesignTokens.iconSm,
          iconSpacing: DesignTokens.spacing1,
        );
      case StatusBadgeSize.large:
        return _BadgeDimensions(
          paddingH: DesignTokens.spacing4,
          paddingV: DesignTokens.spacing2,
          iconSize: DesignTokens.iconMd,
          iconSpacing: DesignTokens.spacing2,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case StatusBadgeSize.small:
        return TypographyTokens.labelXs;
      case StatusBadgeSize.medium:
        return TypographyTokens.labelSm;
      case StatusBadgeSize.large:
        return TypographyTokens.labelMd;
    }
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case StatusBadgeVariant.filled:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
        );
      case StatusBadgeVariant.outlined:
        return BoxDecoration(
          colorRetryBContinuedart          color: Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          border: Border.all(color: color, width: 1.5),
        );
      case StatusBadgeVariant.subtle:
        return BoxDecoration(
          color: ColorTokens.withOpacity(color, 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          border: Border.all(
            color: ColorTokens.withOpacity(color, 0.3),
            width: 1,
          ),
        );
    }
  }

  Color _getContentColor() {
    switch (variant) {
      case StatusBadgeVariant.filled:
        return ColorTokens.getContrastingTextColor(color);
      case StatusBadgeVariant.outlined:
      case StatusBadgeVariant.subtle:
        return color;
    }
  }
}

class _BadgeDimensions {
  final double paddingH;
  final double paddingV;
  final double iconSize;
  final double iconSpacing;

  _BadgeDimensions({
    required this.paddingH,
    required this.paddingV,
    required this.iconSize,
    required this.iconSpacing,
  });
}
4.3 Progress Indicator Pattern (Enhanced)
dart// lib/core/design_system/patterns/progress_indicator_pattern.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Progress indicator pattern with automatic color-coding
/// 
/// Features:
/// - Automatic health color based on percentage
/// - Gradient progress bar
/// - Optional percentage and amounts display
/// - Animated transitions
/// - Glow effect for emphasis
/// 
/// Usage:
/// ```dart
/// ProgressIndicatorPattern(
///   label: 'Budget Usage',
///   current: 750,
///   total: 1000,
///   color: ColorTokens.budgetPrimary, // Optional override
///   showPercentage: true,
///   showAmounts: true,
/// )
/// ```
class ProgressIndicatorPattern extends StatelessWidget {
  const ProgressIndicatorPattern({
    super.key,
    required this.label,
    required this.current,
    required this.total,
    this.color,
    this.showPercentage = true,
    this.showAmounts = true,
    this.height = 8.0,
    this.animate = true,
  });

  final String label;
  final double current;
  final double total;
  final Color? color;
  final bool showPercentage;
  final bool showAmounts;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final progressColor = color ?? _getAutoColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label and percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TypographyTokens.labelMd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showPercentage) ...[
              SizedBox(width: DesignTokens.spacing2),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TypographyTokens.labelSm.copyWith(
                  color: progressColor,
                  fontWeight: TypographyTokens.weightBold,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: DesignTokens.spacing2),
        
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              // Background
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: ColorTokens.neutral200,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
              // Progress
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: percentage),
                duration: animate ? DesignTokens.durationNormal : Duration.zero,
                curve: DesignTokens.curveEaseOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor,
                            ColorTokens.lighten(progressColor, 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: DesignTokens.elevationGlow(
                          progressColor,
                          alpha: 0.3,
                          spread: 0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        if (showAmounts) ...[
          SizedBox(height: DesignTokens.spacing2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatCurrency(current),
                style: TypographyTokens.labelSm.copyWith(
                  color: progressColor,
                  fontWeight: TypographyTokens.weightBold,
                ),
              ),
              Text(
                'of ${_formatCurrency(total)}',
                style: TypographyTokens.captionMd,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getAutoColor(double percentage) {
    if (percentage < 0.5) return ColorTokens.success500;
    if (percentage < 0.75) return ColorTokens.warning500;
    if (percentage < 1.0) return ColorTokens.critical500;
    return ColorTokens.critical600;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    ).format(amount);
  }
}
4.4 Action Button Pattern (Enhanced)
dart// lib/core/design_system/patterns/action_button_pattern.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Button sizes
enum ButtonSize {
  small,
  medium,
  large,
}

/// Button variants
enum ButtonVariant {
  primary,      // Gradient with shadow
  secondary,    // Outlined
  tertiary,     // Text only
  danger,       // Red/destructive
}

/// Action button with consistent styling
/// 
/// Features:
/// - Multiple sizes and variants
/// - Gradient backgrounds
/// - Optional icon
/// - Loading state
/// - Haptic feedback
/// - Disabled state
/// 
/// Usage:
/// ```dart
/// ActionButtonPattern(
///   label: 'Create Budget',
///   icon: Icons.add,
///   variant: ButtonVariant.primary,
///   size: ButtonSize.large,
///   gradient: ColorTokens.gradientPrimary,
///   onPressed: () {},
/// )
/// ```
class ActionButtonPattern extends StatelessWidget {
  const ActionButtonPattern({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.gradient,
    this.color,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Gradient? gradient;
  final Color? color;
  final bool isFullWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final isEnabled = onPressed != null && !isLoading;

    Widget button = _buildButton(context, dimensions, isEnabled);

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildButton(BuildContext context, _ButtonDimensions dimensions, bool isEnabled) {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildPrimaryButton(dimensions, isEnabled);
      case ButtonVariant.secondary:
        return _buildSecondaryButton(dimensions, isEnabled);
      case ButtonVariant.tertiary:
        return _buildTertiaryButton(dimensions, isEnabled);
      case ButtonVariant.danger:
        return _buildDangerButton(dimensions, isEnabled);
    }
  }

  Widget _buildPrimaryButton(_ButtonDimensions dimensions, bool isEnabled) {
    final effectiveGradient = gradient ?? ColorTokens.gradientPrimary;
    final effectiveColor = color ?? ColorTokens.teal500;

    return Container(
      height: dimensions.height,
      decoration: BoxDecoration(
        gradient: isEnabled ? effectiveGradient : null,
        color: isEnabled ? null : ColorTokens.neutral300,
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        boxShadow: isEnabled 
            ? DesignTokens.elevationColored(effectiveColor, alpha: 0.3)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dimensions.paddingH),
            child: _buildButtonContent(dimensions, ColorTokens.textInverse),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(_ButtonDimensions dimensions, bool isEnabled) {
    final effectiveColor = color ?? ColorTokens.teal500;

    return Container(
      height: dimensions.height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        border: Border.all(
          color: isEnabled ? effectiveColor : ColorTokens.neutral300,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dimensions.paddingH),
            child: _buildButtonContent(
              dimensions,
              isEnabled ? effectiveColor : ColorTokens.neutral400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTertiaryButton(_ButtonDimensions dimensions, bool isEnabled) {
    final effectiveColor = color ?? ColorTokens.teal500;

    return SizedBox(
      height: dimensions.height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dimensions.paddingH),
            child: _buildButtonContent(
              dimensions,
              isEnabled ? effectiveColor : ColorTokens.neutral400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDangerButton(_ButtonDimensions dimensions, bool isEnabled) {
    return Container(
      height: dimensions.height,
      decoration: BoxDecoration(
        gradient: isEnabled ? ColorTokens.gradientCritical : null,
        color: isEnabled ? null : ColorTokens.neutral300,
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        boxShadow: isEnabled 
            ? DesignTokens.elevationColored(ColorTokens.critical500, alpha: 0.3)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dimensions.paddingH),
            child: _buildButtonContent(dimensions, ColorTokens.textInverse),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(_ButtonDimensions dimensions, Color textColor) {
    return Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: dimensions.iconSize,
            height: dimensions.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
        ] else if (icon != null) ...[
          Icon(icon, color: textColor, size: dimensions.iconSize),
          SizedBox(width: dimensions.iconSpacing),
        ],
        Text(
          label,
          style: _getTextStyle().copyWith(color: textColor),
        ),
      ],
    );
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    onPressed?.call();
  }

  _ButtonDimensions _getDimensions() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonDimensions(
          height: DesignTokens.buttonHeightSm,
          paddingH: DesignTokens.buttonPaddingHSm,
          iconSize: DesignTokens.iconSm,
          iconSpacing: DesignTokens.spacing1,
        );
      case ButtonSize.medium:
        return _ButtonDimensions(
          height: DesignTokens.buttonHeightMd,
          paddingH: DesignTokens.buttonPaddingHMd,
          iconSize: DesignTokens.iconMd,
          iconSpacing: DesignTokens.spacing2,
        );
      case ButtonSize.large:
        return _ButtonDimensions(
          height: DesignTokens.buttonHeightLg,
          paddingH: DesignTokens.buttonPaddingHLg,
          iconSize: DesignTokens.iconLg,
          iconSpacing: DesignTokens.spacing2,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return TypographyTokens.buttonSm;
      case ButtonSize.medium:
        return TypographyTokens.buttonMd;
      case ButtonSize.large:
        return TypographyTokens.buttonLg;
    }
  }
}

class _ButtonDimensions {
  final double height;
  final double paddingH;
  final double iconSize;
  final double iconSpacing;

  _ButtonDimensions({
    required this.height,
    required this.paddingH,
    required this.iconSize,
    required this.iconSpacing,
  });
}
4.5 Empty State Pattern
dart// lib/core/design_system/patterns/empty_state_pattern.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import 'action_button_pattern.dart';

/// Empty state pattern for consistent "no data" screens
/// 
/// Features:
/// - Icon with colored background
/// - Title and description
/// - Optional action button
/// - Animated entrance
/// 
/// Usage:
/// ```dart
/// EmptyStatePattern(
///   icon: Icons.inbox_outlined,
///   iconColor: ColorTokens.teal500,
///   title: 'No transactions yet',
///   description: 'Start tracking your finances by adding your first transaction',
///   actionLabel: 'Add Transaction',
///   onAction: () => navigate(),
/// )
/// ```
class EmptyStatePattern extends StatelessWidget {
  const EmptyStatePattern({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? ColorTokens.teal500;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.spacing8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing6),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(effectiveIconColor, 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: DesignTokens.icon3xl,
                color: effectiveIconColor,
              ),
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: DesignTokens.durationNormal,
                curve: DesignTokens.curveElastic,
              ),
            
            SizedBox(height: DesignTokens.spacing5),
            
            // Title
            Text(
              title,
              style: TypographyTokens.heading4,
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms),
            
            if (description != null) ...[
              SizedBox(height: DesignTokens.spacing2),
              Text(
                description!,
                style: TypographyTokens.bodyMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms),
            ],
            
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: DesignTokens.spacing6),
              ActionButtonPattern(
                label: actionLabel!,
                icon: actionIcon ?? Icons.add,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                gradient: ColorTokens.gradientCustom(
                  effectiveIconColor,
                  ColorTokens.darken(effectiveIconColor, 0.1),
                ),
                onPressed: onAction,
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                .slideY(
                  begin: 0.1,
                  duration: DesignTokens.durationNormal,
                  delay: 300.ms,
                  curve: DesignTokens.curveElastic,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

📱 PART 5: SCREEN TEMPLATES
5.1 Base Screen Template (Enhanced)
dart// lib/core/design_system/templates/base_screen_template.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../../../widgets/loading_view.dart';
import '../../../widgets/error_view.dart';
import '../patterns/empty_state_pattern.dart';

/// Base template for all screens
/// 
/// Features:
/// - Consistent structure
/// - Automatic state handling (loading/error/empty)
/// - Pull-to-refresh support
/// - Floating action button support
/// - Safe area handling
/// 
/// Usage:
/// ```dart
/// BaseScreenTemplate<List<Transaction>>(
///   title: 'Transactions',
///   asyncValue: ref.watch(transactionsProvider),
///   onRefresh: () async => ref.refresh(transactionsProvider),
///   builder: (transactions) => TransactionList(transactions),
///   emptyStateBuilder: () => EmptyStatePattern(...),
///   floatingActionButton: FAB(...),
/// )
/// ```
class BaseScreenTemplate<T> extends StatelessWidget {
  const BaseScreenTemplate({
    super.key,
    required this.title,
    this.subtitle,
    this.headerActions = const [],
    required this.asyncValue,
    this.onRefresh,
    required this.builder,
    this.emptyStateBuilder,
    this.floatingActionButton,
    this.showAppBar = true,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> headerActions;
  final AsyncValue<T> asyncValue;
  final Future<void> Function()? onRefresh;
  final Widget Function(T data) builder;
  final Widget Function()? emptyStateBuilder;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: showAppBar ? _buildAppBar(context) : null,
      body: SafeArea(
        child: asyncValue.when(
          loading: () => const LoadingView(),
          error: (error, stack) => ErrorView(
            message: error.toString(),
            onRetry: onRefresh,
          ),
          data: (data) {
            if (_isEmpty(data) && emptyStateBuilder != null) {
              return emptyStateBuilder!();
            }
            
            Widget content = builder(data);
            
            if (onRefresh != null) {
              content = RefreshIndicator(
                onRefresh: onRefresh!,
                color: ColorTokens.teal500,
                backgroundColor: ColorTokens.surfacePrimary,
                child: content,
              );
            }
            
            return content;
          },
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorTokens.surfacePrimary,
      elevation: 0,
      centerTitle: centerTitle,
      title: Column(
        crossAxisAlignment: centerTitle 
            ? CrossAxisAlignment.center 
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TypographyTokens.heading4,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TypographyTokens.captionMd,
            ),
          ],
        ],
      ),
      actions: headerActions,
    );
  }

  bool _isEmpty(T data) {
    if (data is List) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    if (data is Set) return data.isEmpty;
    return data == null;
  }
}
5.2 List Screen Template (Enhanced)
dart// lib/core/design_system/templates/list_screen_template.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../../../widgets/loading_view.dart';
import '../../../widgets/error_view.dart';
import '../patterns/empty_state_pattern.dart';

/// Template for list-based screens with grouping
/// 
/// Features:
/// - Grouped items with headers
/// - Search functionality
/// - Filter options
/// - Load more pagination
/// - Empty states
/// - Pull-to-refresh
/// 
/// Usage:
/// ```dart
/// ListScreenTemplate<Transaction>(
///   title: 'Transactions',
///   asyncValue: ref.watch(transactionsProvider),
///   groupBy: (t) => DateFormat('yyyy-MM-dd').format(t.date),
///   itemBuilder: (t) => TransactionTile(t),
///   headerBuilder: (date) => DateHeader(date),
///   onSearch: (query) => ref.read(searchProvider.notifier).state = query,
///   emptyStateBuilder: () => EmptyStatePattern(...),
/// )
/// ```
class ListScreenTemplate<T> extends StatefulWidget {
  const ListScreenTemplate({
    super.key,
    required this.title,
    required this.asyncValue,
    required this.groupBy,
    required this.itemBuilder,
    required this.headerBuilder,
    this.onSearch,
    this.onFilter,
    this.onLoadMore,
    this.hasMoreData = false,
    this.topWidget,
    this.emptyStateBuilder,
    this.showSearch = false,
  });

  final String title;
  final AsyncValue<List<T>> asyncValue;
  final dynamic Function(T item) groupBy;
  final Widget Function(T item) itemBuilder;
  final Widget Function(dynamic groupKey) headerBuilder;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onLoadMore;
  final bool hasMoreData;
  final Widget? topWidget;
  final Widget Function()? emptyStateBuilder;
  final bool showSearch;

  @override
  State<ListScreenTemplate<T>> createState() => _ListScreenTemplateState<T>();
}

class _ListScreenTemplateState<T> extends State<ListScreenTemplate<T>> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: widget.asyncValue.when(
                loading: () => const LoadingView(),
                error: (error, stack) => ErrorView(message: error.toString()),
                data: (items) => _buildList(context, items),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        boxShadow: DesignTokens.elevationLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_isSearchActive && widget.showSearch) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = false;
                      _searchController.clear();
                    });
                    widget.onSearch?.call('');
                  },
                ),
              ],
              Expanded(
                child: _isSearchActive && widget.showSearch
                    ? _buildSearchField()
                    : Text(
                        widget.title,
                        style: TypographyTokens.heading3,
                      ),
              ),
              if (widget.showSearch && !_isSearchActive) ...[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = true;
                    });
                  },
                ),
              ],
              if (widget.onFilter != null) ...[
                SizedBox(width: DesignTokens.spacing2),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: widget.onFilter,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TypographyTokens.bodyMd.copyWith(
            color: ColorTokens.textTertiary,
          ),
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing4,
            vertical: DesignTokens.spacing3,
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<T> items) {
    if (items.isEmpty) {
      return widget.emptyStateBuilder?.call() ?? 
          const Center(child: Text('No items found'));
    }

    final groupedItems = _groupItems(items);

    return ListView.builder(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      itemCount: _calculateItemCount(groupedItems),
      itemBuilder: (context, index) => _buildListItem(context, index, groupedItems),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Map<dynamic, List<T>> groupedItems,
  ) {
    int currentIndex = 0;

    // Top widget
    if (widget.topWidget != null && index == currentIndex++) {
      return Padding(
        padding: EdgeInsets.only(bottom: DesignTokens.sectionGapLg),
        child: widget.topWidget!,
      );
    }

    // Grouped items
    for (final entry in groupedItems.entries) {
      // Header
      if (index == currentIndex++) {
        return Padding(
          padding: EdgeInsets.only(bottom: DesignTokens.spacing3),
          child: widget.headerBuilder(entry.key),
        );
      }

      // Items
      for (final item in entry.value) {
        if (index == currentIndex++) {
          return Padding(
            padding: EdgeInsets.only(bottom: DesignTokens.listItemGap),
            child: widget.itemBuilder(item),
          );
        }
      }

      // Spacing between groups
      if (index == currentIndex++) {
        return SizedBox(height: DesignTokens.sectionGapMd);RetryBContinuedart      }
    }

    // Load more
    if (widget.hasMoreData && widget.onLoadMore != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing4),
        child: Center(
          child: TextButton.icon(
            onPressed: widget.onLoadMore,
            icon: const Icon(Icons.expand_more),
            label: const Text('Load More'),
            style: TextButton.styleFrom(
              foregroundColor: ColorTokens.teal500,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Map<dynamic, List<T>> _groupItems(List<T> items) {
    final Map<dynamic, List<T>> grouped = {};
    for (final item in items) {
      final key = widget.groupBy(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  int _calculateItemCount(Map<dynamic, List<T>> groupedItems) {
    int count = widget.topWidget != null ? 1 : 0;
    for (final entry in groupedItems.entries) {
      count += 1 + entry.value.length + 1; // header + items + spacing
    }
    if (widget.hasMoreData && widget.onLoadMore != null) count++;
    return count;
  }
}

🎬 PART 6: ANIMATION SYSTEM
6.1 Animation Presets
dart// lib/core/design_system/animation_presets.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'design_tokens.dart';

/// Reusable animation presets for consistent motion
class AnimationPresets {
  
  // ============================================================================
  // ENTRANCE ANIMATIONS
  // ============================================================================
  
  /// Fade in from transparent
  static List<Effect> fadeIn({
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: curve ?? DesignTokens.curveEaseOut,
      ),
    ];
  }
  
  /// Fade in and slide up
  static List<Effect> fadeInSlideUp({
    Duration? duration,
    Duration? delay,
    double distance = 0.1,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
      ),
      SlideEffect(
        begin: Offset(0, distance),
        end: Offset.zero,
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: DesignTokens.curveEaseOut,
      ),
    ];
  }
  
  /// Fade in and slide from left
  static List<Effect> fadeInSlideLeft({
    Duration? duration,
    Duration? delay,
    double distance = 0.1,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
      ),
      SlideEffect(
        begin: Offset(-distance, 0),
        end: Offset.zero,
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: DesignTokens.curveEaseOut,
      ),
    ];
  }
  
  /// Fade in and slide from right
  static List<Effect> fadeInSlideRight({
    Duration? duration,
    Duration? delay,
    double distance = 0.1,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
      ),
      SlideEffect(
        begin: Offset(distance, 0),
        end: Offset.zero,
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: DesignTokens.curveEaseOut,
      ),
    ];
  }
  
  /// Fade in and scale (bounce effect)
  static List<Effect> fadeInScale({
    Duration? duration,
    Duration? delay,
    Offset? begin,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
      ),
      ScaleEffect(
        begin: begin ?? const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: DesignTokens.curveElastic,
      ),
    ];
  }
  
  // ============================================================================
  // STAGGERED LIST ANIMATIONS
  // ============================================================================
  
  /// Staggered fade in for list items
  static List<Effect> staggeredFadeIn({
    required int index,
    int baseDelayMs = 100,
    Duration? duration,
  }) {
    return fadeIn(
      duration: duration,
      delay: Duration(milliseconds: baseDelayMs * index),
    );
  }
  
  /// Staggered fade in and slide for list items
  static List<Effect> staggeredFadeInSlide({
    required int index,
    int baseDelayMs = 100,
    Duration? duration,
    bool fromRight = true,
  }) {
    return fromRight 
        ? fadeInSlideRight(
            duration: duration,
            delay: Duration(milliseconds: baseDelayMs * index),
          )
        : fadeInSlideLeft(
            duration: duration,
            delay: Duration(milliseconds: baseDelayMs * index),
          );
  }
  
  // ============================================================================
  // HOVER/INTERACTION ANIMATIONS
  // ============================================================================
  
  /// Scale up on hover
  static List<Effect> hoverScale({
    double scale = 1.05,
    Duration? duration,
  }) {
    return [
      ScaleEffect(
        begin: const Offset(1.0, 1.0),
        end: Offset(scale, scale),
        duration: duration ?? DesignTokens.durationSm,
        curve: DesignTokens.curveEaseOut,
      ),
    ];
  }
  
  /// Shimmer effect for loading states
  static List<Effect> shimmer({
    Duration? duration,
    Color? color,
  }) {
    return [
      ShimmerEffect(
        duration: duration ?? const Duration(seconds: 2),
        color: color ?? Colors.white.withValues(alpha: 0.3),
      ),
    ];
  }
  
  // ============================================================================
  // PAGE TRANSITION ANIMATIONS
  // ============================================================================
  
  /// Slide transition for page navigation
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.right,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.up:
        begin = const Offset(0, 1);
        break;
      case SlideDirection.down:
        begin = const Offset(0, -1);
        break;
      case SlideDirection.left:
        begin = const Offset(1, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(-1, 0);
        break;
    }
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: DesignTokens.curveEaseOut,
      )),
      child: child,
    );
  }
  
  /// Fade transition for page navigation
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
  
  /// Scale transition for modals
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: DesignTokens.curveElastic,
      ),
      child: child,
    );
  }
  
  // ============================================================================
  // SPECIAL EFFECTS
  // ============================================================================
  
  /// Pulse effect for notifications/badges
  static List<Effect> pulse({
    Duration? duration,
    int repeat = 1,
  }) {
    return [
      ScaleEffect(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.1, 1.1),
        duration: duration ?? const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    ];
  }
  
  /// Shake effect for errors
  static List<Effect> shake({
    Duration? duration,
    double intensity = 10.0,
  }) {
    return [
      ShakeEffect(
        duration: duration ?? const Duration(milliseconds: 500),
        hz: 4,
        offset: Offset(intensity, 0),
      ),
    ];
  }
  
  /// Glow effect for emphasis
  static BoxDecoration glowDecoration({
    required Color color,
    double blur = 12.0,
    double spread = 2.0,
  }) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ],
    );
  }
}

enum SlideDirection {
  up,
  down,
  left,
  right,
}
6.2 Animation Helper Widget
dart// lib/core/design_system/widgets/animated_container_pattern.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../animation_presets.dart';

/// Wrapper widget that applies consistent animations
/// 
/// Usage:
/// ```dart
/// AnimatedContainerPattern(
///   index: 0,
///   animationType: AnimationType.fadeInSlideUp,
///   child: YourWidget(),
/// )
/// ```
class AnimatedContainerPattern extends StatelessWidget {
  const AnimatedContainerPattern({
    super.key,
    required this.child,
    this.index = 0,
    this.animationType = AnimationType.fadeInSlideUp,
    this.baseDelayMs = 100,
    this.duration,
  });

  final Widget child;
  final int index;
  final AnimationType animationType;
  final int baseDelayMs;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    List<Effect> effects;
    
    switch (animationType) {
      case AnimationType.fadeIn:
        effects = AnimationPresets.fadeIn(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.fadeInSlideUp:
        effects = AnimationPresets.fadeInSlideUp(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.fadeInSlideLeft:
        effects = AnimationPresets.fadeInSlideLeft(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.fadeInSlideRight:
        effects = AnimationPresets.fadeInSlideRight(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.fadeInScale:
        effects = AnimationPresets.fadeInScale(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.staggeredFadeInSlide:
        effects = AnimationPresets.staggeredFadeInSlide(
          index: index,
          baseDelayMs: baseDelayMs,
          duration: duration,
        );
        break;
      case AnimationType.none:
        return child;
    }
    
    return Animate(
      effects: effects,
      child: child,
    );
  }
}

enum AnimationType {
  none,
  fadeIn,
  fadeInSlideUp,
  fadeInSlideLeft,
  fadeInSlideRight,
  fadeInScale,
  staggeredFadeInSlide,
}

📖 PART 7: USAGE GUIDE & EXAMPLES
7.1 Quick Start Guide
dart/// QUICK START GUIDE
/// 
/// Follow these steps to create a new screen using the design system:
/// 
/// 1. CHOOSE YOUR TEMPLATE
///    - BaseScreenTemplate: Simple content, no complex lists
///    - ListScreenTemplate: Grouped lists with search/filter
/// 
/// 2. SELECT COLOR SCHEME
///    Choose primary color based on feature:
///    - Budgets: ColorTokens.teal500
///    - Goals: ColorTokens.purple600
///    - Bills: Color(0xFFEC4899) (Pink)
///    - Income: Color(0xFF14B8A6) (Teal)
///    - General: ColorTokens.teal500
/// 
/// 3. BUILD WITH PATTERNS
///    Use these building blocks:
///    - InfoCardPattern: For card layouts
///    - StatusBadgePattern: For status indicators
///    - ProgressIndicatorPattern: For progress bars
///    - ActionButtonPattern: For buttons
///    - EmptyStatePattern: For empty states
/// 
/// 4. APPLY ANIMATIONS
///    Use AnimationPresets or AnimatedContainerPattern
/// 
/// 5. STYLE WITH TOKENS
///    Always use DesignTokens, ColorTokens, TypographyTokens

// ============================================================================
// EXAMPLE 1: Simple Card Screen
// ============================================================================

class SimpleCardScreen extends ConsumerWidget {
  const SimpleCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(yourDataProvider);

    return BaseScreenTemplate<YourData>(
      title: 'Screen Title',
      asyncValue: dataAsync,
      onRefresh: () async => ref.refresh(yourDataProvider),
      builder: (data) => SingleChildScrollView(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        child: Column(
          children: [
            // Card 1
            InfoCardPattern(
              title: 'Section Title',
              icon: Icons.pie_chart,
              iconColor: ColorTokens.teal500,
              children: [
                Text('Your content here'),
                SizedBox(height: DesignTokens.spacing3),
                ProgressIndicatorPattern(
                  label: 'Progress',
                  current: data.current,
                  total: data.total,
                ),
              ],
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal),
            
            SizedBox(height: DesignTokens.sectionGapLg),
            
            // Card 2
            InfoCardPattern(
              title: 'Another Section',
              icon: Icons.analytics,
              iconColor: ColorTokens.purple600,
              children: [
                // More content
              ],
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
          ],
        ),
      ),
      emptyStateBuilder: () => EmptyStatePattern(
        icon: Icons.inbox_outlined,
        iconColor: ColorTokens.teal500,
        title: 'No data yet',
        description: 'Get started by adding your first item',
        actionLabel: 'Add Item',
        onAction: () {
          // Navigate or show dialog
        },
      ),
      floatingActionButton: ActionButtonPattern(
        label: 'Add',
        icon: Icons.add,
        gradient: ColorTokens.gradientPrimary,
        onPressed: () {
          // Action
        },
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: List Screen with Grouping
// ============================================================================

class GroupedListScreen extends ConsumerWidget {
  const GroupedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(yourItemsProvider);

    return ListScreenTemplate<YourItem>(
      title: 'Items',
      asyncValue: itemsAsync,
      showSearch: true,
      onSearch: (query) {
        ref.read(searchQueryProvider.notifier).state = query;
      },
      onFilter: () {
        // Show filter dialog
      },
      groupBy: (item) => item.category,
      headerBuilder: (category) => Padding(
        padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing2),
        child: Text(
          category.toString(),
          style: TypographyTokens.heading6,
        ),
      ),
      itemBuilder: (item) => Container(
        padding: EdgeInsets.all(DesignTokens.cardPaddingMd),
        decoration: BoxDecoration(
          color: ColorTokens.surfacePrimary,
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          boxShadow: DesignTokens.elevationLow,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing2),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.teal500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                Icons.check_circle,
                color: ColorTokens.teal500,
                size: DesignTokens.iconMd,
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TypographyTokens.bodyLg),
                  Text(item.subtitle, style: TypographyTokens.captionMd),
                ],
              ),
            ),
            
            // Badge
            StatusBadgePattern(
              label: item.status,
              color: ColorTokens.statusNormal,
              size: StatusBadgeSize.small,
            ),
          ],
        ),
      ),
      emptyStateBuilder: () => EmptyStatePattern(
        icon: Icons.inbox_outlined,
        title: 'No items found',
        description: 'Try adjusting your search or filters',
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Dashboard with Multiple Sections
// ============================================================================

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return BaseScreenTemplate<Stats>(
      title: 'Dashboard',
      subtitle: 'Your financial overview',
      asyncValue: statsAsync,
      onRefresh: () async => ref.refresh(statsProvider),
      builder: (stats) => SingleChildScrollView(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            _buildHeroCard(stats).animate()
              .fadeIn(duration: DesignTokens.durationSlow)
              .scale(begin: const Offset(0.9, 0.9), duration: DesignTokens.durationSlow),
            
            SizedBox(height: DesignTokens.sectionGapLg),
            
            // Metrics Grid
            _buildMetricsGrid(stats),
            
            SizedBox(height: DesignTokens.sectionGapLg),
            
            // Recent Activity
            _buildRecentActivity(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(Stats stats) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.cardPaddingXl),
      decoration: BoxDecoration(
        gradient: ColorTokens.gradientPrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: DesignTokens.elevationColored(
          ColorTokens.teal500,
          alpha: 0.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TypographyTokens.bodyMd.copyWith(
              color: ColorTokens.withOpacity(ColorTokens.textInverse, 0.8),
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),
          Text(
            '\$${stats.totalBalance.toStringAsFixed(2)}',
            style: TypographyTokens.display3.copyWith(
              color: ColorTokens.textInverse,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Stats stats) {
    final metrics = [
      ('Income', stats.income, Icons.trending_up, ColorTokens.success500),
      ('Expenses', stats.expenses, Icons.trending_down, ColorTokens.critical500),
      ('Savings', stats.savings, Icons.savings, ColorTokens.purple600),
      ('Goals', stats.goals, Icons.flag, ColorTokens.warning500),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _buildMetricCard(
          label: metric.$1,
          value: metric.$2,
          icon: metric.$3,
          color: metric.$4,
        ).animate()
          .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 100 * index))
          .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 100 * index));
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.cardPaddingMd),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        boxShadow: DesignTokens.elevationLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing2),
            decoration: BoxDecoration(
              color: ColorTokens.withOpacity(color, 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(icon, color: color, size: DesignTokens.iconMd),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${value.toStringAsFixed(0)}',
                style: TypographyTokens.numericMd.copyWith(color: color),
              ),
              Text(label, style: TypographyTokens.captionMd),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(Stats stats) {
    return InfoCardPattern(
      title: 'Recent Activity',
      icon: Icons.history,
      iconColor: ColorTokens.teal500,
      trailing: TextButton(
        onPressed: () {
          // Navigate to full activity
        },
        child: const Text('View All'),
      ),
      children: [
        // Activity items
        ...stats.recentActivity.map((activity) => Padding(
          padding: EdgeInsets.only(bottom: DesignTokens.spacing3),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: ColorTokens.teal500,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.title, style: TypographyTokens.bodyMd),
                    Text(activity.subtitle, style: TypographyTokens.captionMd),
                  ],
                ),
              ),
              Text(
                activity.amount,
                style: TypographyTokens.labelMd.copyWith(
                  color: ColorTokens.teal500,
                ),
              ),
            ],
          ),
        )),
      ],
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms);
  }
}
7.2 Common Patterns Cheat Sheet
dart/// COMMON PATTERNS CHEAT SHEET
/// 
/// Quick reference for frequently used patterns

// ============================================================================
// SPACING
// ============================================================================

// Between sections
SizedBox(height: DesignTokens.sectionGapLg)

// Between related items
SizedBox(height: DesignTokens.spacing3)

// Screen padding
padding: EdgeInsets.all(DesignTokens.screenPaddingH)

// Card padding
padding: EdgeInsets.all(DesignTokens.cardPaddingLg)

// ============================================================================
// COLORS
// ============================================================================

// Primary brand color
ColorTokens.teal500

// Success (positive actions)
ColorTokens.success500

// Warning (caution)
ColorTokens.warning500

// Error/Critical
ColorTokens.critical500

// Text colors
ColorTokens.textPrimary
ColorTokens.textSecondary
ColorTokens.textTertiary

// With opacity
ColorTokens.withOpacity(ColorTokens.teal500, 0.1)

// ============================================================================
// TYPOGRAPHY
// ============================================================================

// Headings
TypographyTokens.heading1  // Largest
TypographyTokens.heading2
TypographyTokens.heading3
TypographyTokens.heading4  // Standard section header

// Body text
TypographyTokens.bodyLg    // Large body
TypographyTokens.bodyMd    // Standard body
TypographyTokens.bodySm    // Small body

// Labels
TypographyTokens.labelMd   // Form labels, badges
TypographyTokens.captionMd // Secondary info

// Financial numbers
TypographyTokens.numericXl // Large amounts
TypographyTokens.numericMd // Standard amounts

// ============================================================================
// ELEVATION/SHADOWS
// ============================================================================

// Standard card shadow
boxShadow: DesignTokens.elevationLow

// Floating elements
boxShadow: DesignTokens.elevationMedium

// Modals
boxShadow: DesignTokens.elevationHigh

// Colored shadow (emphasis)
boxShadow: DesignTokens.elevationColored(ColorTokens.teal500)

// ============================================================================
// BORDER RADIUS
// ============================================================================

// Cards
borderRadius: BorderRadius.circular(DesignTokens.cardRadius)  // 12px

// Buttons
borderRadius: BorderRadius.circular(DesignTokens.buttonRadius)  // 12px

// Pills/badges
borderRadius: BorderRadius.circular(DesignTokens.chipRadius)  // Fully rounded

// ============================================================================
// ANIMATIONS
// ============================================================================

// Fade in
.animate()
  .fadeIn(duration: DesignTokens.durationNormal)

// Fade in + slide up
.animate()
  .fadeIn(duration: DesignTokens.durationNormal)
  .slideY(begin: 0.1, duration: DesignTokens.durationNormal)

// Staggered (for lists)
.animate()
  .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: index * 100))
  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: index * 100))

// Scale (bounce effect)
.animate()
  .fadeIn(duration: DesignTokens.durationNormal)
  .scale(begin: const Offset(0.8, 0.8), curve: DesignTokens.curveElastic)

// ============================================================================
// COMMON WIDGETS
// ============================================================================

// Status badge
StatusBadgePattern(
  label: 'Active',
  color: ColorTokens.statusNormal,
  icon: Icons.check_circle,
)

// Progress bar
ProgressIndicatorPattern(
  label: 'Progress',
  current: 75,
  total: 100,
)

// Action button
ActionButtonPattern(
  label: 'Save',
  icon: Icons.save,
  variant: ButtonVariant.primary,
  onPressed: () {},
)

// Info card
InfoCardPattern(
  title: 'Title',
  icon: Icons.info,
  iconColor: ColorTokens.teal500,
  children: [
    // Your content
  ],
)

// Empty state
EmptyStatePattern(
  icon: Icons.inbox_outlined,
  title: 'No data',
  description: 'Description here',
)

✅ PART 8: IMPLEMENTATION CHECKLIST
markdown# Design System Implementation Checklist

## Setup Phase
- [ ] Copy DesignTokens to `lib/core/design_system/design_tokens.dart`
- [ ] Copy ColorTokens to `lib/core/design_system/color_tokens.dart`
- [ ] Copy TypographyTokens to `lib/core/design_system/typography_tokens.dart`
- [ ] Copy AnimationPresets to `lib/core/design_system/animation_presets.dart`
- [ ] Install required dependencies (flutter_animate, intl)

## Pattern Setup
- [ ] Copy InfoCardPattern to `lib/core/design_system/patterns/`
- [ ] Copy StatusBadgePattern to `lib/core/design_system/patterns/`
- [ ] Copy ProgressIndicatorPattern to `lib/core/design_system/patterns/`
- [ ] Copy ActionButtonPattern to `RetryBContinuemarkdownlib/core/design_system/patterns/`
- [ ] Copy EmptyStatePattern to `lib/core/design_system/patterns/`

## Template Setup
- [ ] Copy BaseScreenTemplate to `lib/core/design_system/templates/`
- [ ] Copy ListScreenTemplate to `lib/core/design_system/templates/`
- [ ] Update imports in existing code to use new design system

## Screen Migration
- [ ] Identify screens to migrate (prioritize high-traffic screens)
- [ ] Choose appropriate template for each screen
- [ ] Apply design tokens for spacing and colors
- [ ] Replace custom components with design system patterns
- [ ] Add consistent animations
- [ ] Test on multiple screen sizes

## Quality Assurance
- [ ] Verify all spacing uses DesignTokens
- [ ] Verify all colors use ColorTokens
- [ ] Verify all typography uses TypographyTokens
- [ ] Verify animations are consistent (60fps)
- [ ] Test accessibility (contrast ratios, touch targets)
- [ ] Test on iOS and Android
- [ ] Test with system dark mode (if supported)
- [ ] Performance profiling (no jank)

## Documentation
- [ ] Document any custom patterns created
- [ ] Update team guidelines
- [ ] Create visual style guide (optional)
- [ ] Train team on design system usage

🎓 PART 9: BEST PRACTICES & GUIDELINES
9.1 Do's and Don'ts
dart/// DO'S AND DON'TS

// ============================================================================
// SPACING
// ============================================================================

// ✅ DO: Use design tokens
Container(
  padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
  margin: EdgeInsets.only(bottom: DesignTokens.sectionGapLg),
)

// ❌ DON'T: Use arbitrary values
Container(
  padding: EdgeInsets.all(20),
  margin: EdgeInsets.only(bottom: 24),
)

// ============================================================================
// COLORS
// ============================================================================

// ✅ DO: Use semantic color names
Container(
  color: ColorTokens.surfacePrimary,
  child: Text(
    'Hello',
    style: TypographyTokens.bodyMd.copyWith(
      color: ColorTokens.textPrimary,
    ),
  ),
)

// ❌ DON'T: Use hardcoded hex colors
Container(
  color: Color(0xFFFFFFFF),
  child: Text(
    'Hello',
    style: TextStyle(color: Color(0xFF111827)),
  ),
)

// ============================================================================
// TYPOGRAPHY
// ============================================================================

// ✅ DO: Use typography tokens
Text('Title', style: TypographyTokens.heading3)
Text('Body', style: TypographyTokens.bodyMd)
Text('Caption', style: TypographyTokens.captionMd)

// ❌ DON'T: Define custom text styles
Text('Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
Text('Body', style: TextStyle(fontSize: 14))

// ============================================================================
// COMPONENTS
// ============================================================================

// ✅ DO: Use design system patterns
InfoCardPattern(
  title: 'Budget',
  icon: Icons.pie_chart,
  iconColor: ColorTokens.teal500,
  children: [Text('Content')],
)

// ❌ DON'T: Create one-off custom components
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(...)],
  ),
  child: Column(
    children: [
      Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.pie_chart, color: Colors.teal),
          ),
          Text('Budget'),
        ],
      ),
      Text('Content'),
    ],
  ),
)

// ============================================================================
// ANIMATIONS
// ============================================================================

// ✅ DO: Use animation presets
widget.animate()
  .fadeIn(duration: DesignTokens.durationNormal)
  .slideY(begin: 0.1, duration: DesignTokens.durationNormal)

// ❌ DON'T: Define custom animations
AnimatedOpacity(
  opacity: 1.0,
  duration: Duration(milliseconds: 300),
  child: Transform.translate(
    offset: Offset(0, -10),
    child: widget,
  ),
)

// ============================================================================
// RESPONSIVE DESIGN
// ============================================================================

// ✅ DO: Use responsive helper
final spacing = DesignTokens.responsive<double>(
  context,
  mobile: DesignTokens.spacing4,
  tablet: DesignTokens.spacing6,
  desktop: DesignTokens.spacing8,
)

// ❌ DON'T: Use fixed values without context
final spacing = 16.0

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

// ✅ DO: Use templates for consistent state handling
BaseScreenTemplate<Data>(
  asyncValue: ref.watch(dataProvider),
  builder: (data) => YourContent(data),
  emptyStateBuilder: () => EmptyStatePattern(...),
)

// ❌ DON'T: Handle states manually everywhere
asyncValue.when(
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
  data: (data) => data.isEmpty 
      ? Text('No data')
      : YourContent(data),
)
9.2 Performance Guidelines
dart/// PERFORMANCE BEST PRACTICES

// ============================================================================
// WIDGET REBUILDS
// ============================================================================

// ✅ DO: Use const constructors
const InfoCardPattern(
  title: 'Title',
  icon: Icons.info,
  iconColor: ColorTokens.teal500,
  children: [
    Text('Static content'),
  ],
)

// ✅ DO: Extract widgets to reduce rebuild scope
class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});
  final MetricData data;
  
  @override
  Widget build(BuildContext context) {
    return InfoCardPattern(...);
  }
}

// ❌ DON'T: Build complex widgets inline
Column(
  children: [
    Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(...),
          Text(...),
          // Many nested widgets
        ],
      ),
    ),
  ],
)

// ============================================================================
// ANIMATIONS
// ============================================================================

// ✅ DO: Use GPU-accelerated transforms
Transform.translate(
  offset: Offset(0, 10),
  child: widget,
)

Transform.scale(
  scale: 1.1,
  child: widget,
)

// ❌ DON'T: Animate expensive properties
Container(
  height: animatedHeight,  // Causes layout recalculation
  child: widget,
)

// ============================================================================
// LISTS
// ============================================================================

// ✅ DO: Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ItemWidget(item: item, key: ValueKey(item.id));
  },
)

// ❌ DON'T: Build all items upfront
Column(
  children: items.map((item) => ItemWidget(item: item)).toList(),
)

// ============================================================================
// IMAGES
// ============================================================================

// ✅ DO: Specify dimensions for images
Image.network(
  url,
  width: 100,
  height: 100,
  cacheWidth: 100,
  cacheHeight: 100,
)

// ❌ DON'T: Load full-size images
Image.network(url)

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

// ✅ DO: Use selective rebuilds with Riverpod
final nameProvider = Provider((ref) => ref.watch(userProvider).name);

Consumer(
  builder: (context, ref, child) {
    final name = ref.watch(nameProvider); // Only rebuilds when name changes
    return Text(name);
  },
)

// ❌ DON'T: Watch entire objects when only part is needed
Consumer(
  builder: (context, ref, child) {
    final user = ref.watch(userProvider); // Rebuilds for any user change
    return Text(user.name);
  },
)
9.3 Accessibility Guidelines
dart/// ACCESSIBILITY BEST PRACTICES

// ============================================================================
// SEMANTIC WIDGETS
// ============================================================================

// ✅ DO: Use Semantics widget for custom UI
Semantics(
  label: 'Budget progress',
  value: '75 percent',
  hint: 'Double tap to view details',
  button: true,
  onTap: () => showDetails(),
  child: CircularBudgetIndicator(...),
)

// ✅ DO: Provide meaningful labels
IconButton(
  icon: Icon(Icons.add),
  tooltip: 'Add new transaction',
  onPressed: () {},
)

// ❌ DON'T: Ignore accessibility
GestureDetector(
  onTap: () {},
  child: Icon(Icons.add),
)

// ============================================================================
// TOUCH TARGETS
// ============================================================================

// ✅ DO: Ensure minimum 48x48 touch targets
Container(
  width: 48,
  height: 48,
  child: IconButton(
    icon: Icon(Icons.delete),
    onPressed: () {},
  ),
)

// ❌ DON'T: Use tiny touch targets
GestureDetector(
  onTap: () {},
  child: Icon(Icons.delete, size: 16),
)

// ============================================================================
// COLOR CONTRAST
// ============================================================================

// ✅ DO: Use contrasting colors (WCAG AA: 4.5:1)
Text(
  'Important text',
  style: TypographyTokens.bodyMd.copyWith(
    color: ColorTokens.textPrimary, // High contrast
  ),
)

// ❌ DON'T: Use low-contrast colors
Text(
  'Important text',
  style: TextStyle(color: Colors.grey[400]), // Poor contrast
)

// ============================================================================
// FOCUS MANAGEMENT
// ============================================================================

// ✅ DO: Manage focus order
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      FocusTraversalOrder(order: NumericFocusOrder(1.0), child: TextField()),
      FocusTraversalOrder(order: NumericFocusOrder(2.0), child: TextField()),
      FocusTraversalOrder(order: NumericFocusOrder(3.0), child: ElevatedButton()),
    ],
  ),
)

// ============================================================================
// SCREEN READER SUPPORT
// ============================================================================

// ✅ DO: Announce important changes
void _showSuccessMessage() {
  SemanticsService.announce(
    'Transaction saved successfully',
    TextDirection.ltr,
  );
}

// ✅ DO: Hide decorative elements from screen readers
Semantics(
  excludeSemantics: true,
  child: Icon(Icons.chevron_right), // Decorative arrow
)

📚 PART 10: REFERENCE & RESOURCES
10.1 Component Index
markdown# Component Quick Reference

## Layout Components
- BaseScreenTemplate: Basic screen structure with state handling
- ListScreenTemplate: List screen with grouping and search
- InfoCardPattern: Standard card layout with icon header
- EmptyStatePattern: Consistent empty state display

## Interactive Components
- ActionButtonPattern: Buttons with variants and states
- StatusBadgePattern: Status indicators with variants
- ProgressIndicatorPattern: Progress bars with auto-coloring

## Data Visualization
- CircularBudgetIndicator: Circular progress (reuse from budget)
- BudgetBarChart: Bar charts with tooltips (reuse from budget)
- MiniTrendIndicator: Small trend sparklines (reuse from budget)

## Navigation Components
- DateSelectorPills: Horizontal date selector (reuse from budget)
- AnimatedContainerPattern: Wrapper for consistent animations

## Utility Components
- AnimationPresets: Reusable animation patterns
- DesignTokens: Spacing, sizing, timing tokens
- ColorTokens: Complete color system
- TypographyTokens: Typography scale
10.2 Token Reference
markdown# Design Token Reference

## Spacing Scale (Base: 4px)
- spacing1: 4px   - Tiny gaps, icon padding
- spacing2: 8px   - Small gaps, chip padding
- spacing3: 12px  - Medium gaps, button padding
- spacing4: 16px  - Standard gaps, card padding
- spacing5: 20px  - Large gaps, section padding
- spacing6: 24px  - Extra large gaps
- spacing8: 32px  - Major sections
- spacing10: 40px - Screen sections

## Section Gaps
- sectionGapXs: 8px
- sectionGapSm: 12px
- sectionGapMd: 16px
- sectionGapLg: 24px
- sectionGapXl: 32px

## Border Radius
- radiusXs: 2px   - Subtle rounding
- radiusSm: 4px   - Small elements
- radiusMd: 8px   - Input fields, small cards
- radiusLg: 12px  - Standard cards, buttons
- radiusXl: 16px  - Large cards, modals
- radiusFull: 999px - Fully rounded (pills)

## Icon Sizes
- iconXs: 12px
- iconSm: 16px
- iconMd: 20px
- iconLg: 24px
- iconXl: 32px
- iconXxl: 48px

## Animation Durations
- durationXs: 100ms   - Micro interactions
- durationSm: 150ms   - Quick transitions
- durationMd: 200ms   - Fast animations
- durationNormal: 300ms - Standard animations
- durationLg: 400ms   - Deliberate animations
- durationSlow: 500ms - Slow animations

## Elevation Levels
- elevationNone: No shadow
- elevationXs: Subtle elevation
- elevationLow: Cards on background
- elevationMedium: Floating cards
- elevationHigh: Modals, dialogs
- elevationXl: Important modals
10.3 Color Reference
markdown# Color System Reference

## Primary Colors
- Teal (teal500): #00D4AA - Trust, financial health
- Purple (purple600): #7C3AED - Premium, insights
- Blue (info500): #3B82F6 - Information, neutral

## Semantic Colors
- Success (success500): #10B981 - Positive, income
- Warning (warning500): #F59E0B - Caution, limits
- Critical (critical500): #EF4444 - Urgent, expenses
- Error (critical600): #DC2626 - Errors, danger

## Feature Colors
- Budget: teal500
- Goals: purple600
- Bills: #EC4899 (Pink)
- Income: #14B8A6 (Teal)

## Text Colors
- textPrimary: #111827 - Main text
- textSecondary: #6B7280 - Supporting text
- textTertiary: #9CA3AF - Hints, disabled
- textInverse: #FFFFFF - On dark backgrounds

## Surface Colors
- surfaceBackground: #F9FAFB - App background
- surfacePrimary: #FFFFFF - Cards, elevated
- surfaceSecondary: #F3F4F6 - Subtle contrast
10.4 Typography Reference
markdown# Typography System Reference

## Display Styles (Hero text)
- display1: 64px, Black
- display2: 48px, Bold
- display3: 36px, Bold

## Headings
- heading1: 32px, Bold
- heading2: 28px, Bold
- heading3: 24px, SemiBold
- heading4: 20px, SemiBold
- heading5: 18px, SemiBold
- heading6: 16px, SemiBold

## Body Text
- bodyXl: 18px, Regular
- bodyLg: 16px, Regular
- bodyMd: 14px, Regular (Base)
- bodySm: 13px, Regular
- bodyXs: 12px, Regular

## Labels
- labelLg: 16px, Medium
- labelMd: 14px, Medium
- labelSm: 13px, Medium
- labelXs: 12px, Medium

## Captions
- captionLg: 13px, Regular
- captionMd: 12px, Regular
- captionSm: 11px, Regular

## Buttons
- buttonLg: 16px, SemiBold
- buttonMd: 14px, SemiBold
- buttonSm: 13px, Medium

## Numeric (Financial data)
- numericXl: 32px, Bold, Tabular
- numericLg: 24px, Bold, Tabular
- numericMd: 20px, SemiBold, Tabular
- numericSm: 16px, Medium, Tabular

🎯 PART 11: FINAL SUMMARY
Key Takeaways
yamlUniversal Design System - FinFlow Modern:

  Foundation:
    - Token-based system for consistency
    - Semantic naming for clarity
    - Modular components for reusability
    - Predictable behavior across app

  Implementation:
    - Always use tokens, never hardcode values
    - Choose appropriate patterns for each use case
    - Apply consistent animations
    - Test accessibility and performance

  Maintenance:
    - Document custom patterns
    - Update tokens, not individual usages
    - Refactor one-offs into patterns
    - Keep design system synchronized

  Benefits:
    - Faster development (reusable components)
    - Consistent UX (same patterns everywhere)
    - Easier maintenance (single source of truth)
    - Better quality (built-in best practices)
    - Scalability (add features without redesign)
Migration Path
markdown# Recommended Migration Path

## Phase 1: Foundation (Week 1)
1. Set up design tokens
2. Set up color system
3. Set up typography system
4. Update theme configuration

## Phase 2: Patterns (Week 2)
1. Implement core patterns
2. Create component library
3. Document usage examples
4. Train team

## Phase 3: Templates (Week 3)
1. Create screen templates
2. Update existing screens
3. Test and refine
4. Document changes

## Phase 4: Refinement (Week 4)
1. Performance optimization
2. Accessibility audit
3. Visual consistency pass
4. Documentation finalization
Support Resources
dart/// For questions or issues:
/// 
/// 1. Check this guide first
/// 2. Review existing implementations
/// 3. Consult component documentation
/// 4. Review Flutter/Material docs
/// 
/// Common Issues:
/// 
/// Q: Colors not applying correctly?
/// A: Ensure you're using ColorTokens, not hardcoded colors
/// 
/// Q: Spacing looks inconsistent?
/// A: Use DesignTokens spacing scale, not arbitrary values
/// 
/// Q: Animations stuttering?
/// A: Check for expensive operations in build methods
/// 
/// Q: Text styles not matching design?
/// A: Use TypographyTokens, don't create custom TextStyles
/// 
/// Q: Components not reusable enough?
/// A: Consider extracting into a design system pattern

This comprehensive design system guide provides everything needed to:
✅ Maintain visual consistency across all screens
✅ Speed up development with reusable components
✅ Ensure accessibility and performance
✅ Scale the application efficiently
✅ Onboard new developers quickly
✅ Make systematic changes easily
The system is complete, production-ready, and fully documented with examples for any use case.RetryClaude can make mistakes. Please double-check responses.