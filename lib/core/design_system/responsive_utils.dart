import 'package:flutter/material.dart';

/// Utility class for responsive design patterns
///
/// Provides consistent responsive behavior across the app
class ResponsiveUtils {
  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) {
      // Desktop
      return const EdgeInsets.all(32.0);
    } else if (screenWidth >= 768) {
      // Tablet
      return const EdgeInsets.all(24.0);
    } else {
      // Mobile
      return const EdgeInsets.all(16.0);
    }
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) {
      return 1.2; // Larger text on desktop
    } else if (screenWidth >= 768) {
      return 1.1; // Slightly larger on tablet
    } else {
      return 1.0; // Standard on mobile
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    final multiplier = getFontSizeMultiplier(context);
    return baseSize * multiplier;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1200;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return 4; // Desktop
    } else if (width >= 768) {
      return 3; // Tablet
    } else {
      return 2; // Mobile
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) {
      return baseSpacing * 1.5; // More spacing on desktop
    } else if (screenWidth >= 768) {
      return baseSpacing * 1.2; // Slightly more on tablet
    } else {
      return baseSpacing; // Standard on mobile
    }
  }

  /// Get responsive card elevation
  static double getCardElevation(BuildContext context) {
    if (isMobile(context)) {
      return 2.0; // Lower elevation on mobile for better touch interaction
    } else {
      return 4.0; // Higher elevation on larger screens
    }
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context, double baseRadius) {
    if (isDesktop(context)) {
      return baseRadius * 1.2; // Slightly larger radius on desktop
    }
    return baseRadius;
  }

  /// Get responsive max width for content containers
  static double? getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return 1200; // Max width on desktop
    } else if (width >= 768) {
      return width * 0.9; // 90% of screen width on tablet
    } else {
      return null; // Full width on mobile
    }
  }

  /// Get responsive aspect ratio for cards
  static double getCardAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 1.2; // Taller cards on mobile
    } else {
      return 1.5; // Wider cards on larger screens
    }
  }
}