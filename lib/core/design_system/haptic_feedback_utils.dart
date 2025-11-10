import 'package:flutter/services.dart';

/// Utility class for haptic feedback across the app
///
/// Provides consistent haptic feedback patterns for different interactions
class HapticFeedbackUtils {
  /// Light impact for subtle interactions (taps, selections)
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact for important actions (buttons, confirmations)
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact for major actions (deletions, important changes)
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback for picker interactions
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibration for errors or warnings
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Success feedback - light impact with slight delay
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error feedback - heavy impact
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Warning feedback - medium impact
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }
}