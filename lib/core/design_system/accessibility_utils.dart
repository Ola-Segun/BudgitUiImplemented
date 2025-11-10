import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Utility class for accessibility features
///
/// Provides consistent accessibility patterns across the app
class AccessibilityUtils {
  /// Create semantic label for buttons
  static String createButtonLabel(String action, String context) {
    return '$action button for $context';
  }

  /// Create semantic label for cards
  static String createCardLabel(String title, String content) {
    return '$title card: $content';
  }

  /// Create semantic label for progress indicators
  static String createProgressLabel(String label, double current, double total) {
    final percentage = total > 0 ? ((current / total) * 100).round() : 0;
    return '$label: $percentage% complete, $current of $total';
  }

  /// Create semantic label for status badges
  static String createStatusLabel(String status, String context) {
    return '$status status for $context';
  }

  /// Wrap widget with accessibility features
  static Widget wrapWithAccessibility({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool? excludeSemantics,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics ?? false,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible button
  static Widget accessibleButton({
    required Widget child,
    required String label,
    required VoidCallback onPressed,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: enabled ? () {
        SemanticsService.announce('Activated $label', TextDirection.ltr);
        onPressed();
      } : null,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        child: child,
      ),
    );
  }

  /// Create accessible card
  static Widget accessibleCard({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      onTap: onTap,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }

  /// Create accessible progress indicator
  static Widget accessibleProgressIndicator({
    required double value,
    required String label,
    String? hint,
    Color? color,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: '${(value * 100).round()}%',
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
      ),
    );
  }

  /// Announce screen changes for screen readers
  static void announceScreenChange(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announce actions for screen readers
  static void announceAction(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Check if high contrast mode is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  /// Get accessible text color based on background
  static Color getAccessibleTextColor(Color backgroundColor) {
    // Calculate luminance
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Ensure minimum touch target size (48x48)
  static Widget ensureMinimumTouchTarget({
    required Widget child,
    double minWidth = 48.0,
    double minHeight = 48.0,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: minHeight,
      ),
      child: child,
    );
  }

  /// Create accessible icon button
  static Widget accessibleIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
    double? size,
  }) {
    return Semantics(
      label: label,
      button: true,
      onTap: onPressed,
      child: IconButton(
        icon: Icon(icon),
        color: color,
        iconSize: size,
        onPressed: onPressed,
      ),
    );
  }
}