import 'package:flutter/foundation.dart';

/// Simple logger utility for the app
class Logger {
  static const String _tag = 'BudgetTracker';

  /// Log an info message
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] $message');
    }
  }

  /// Log an error message
  static void logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$_tag ERROR] $message');
      if (error != null) {
        debugPrint('[$_tag ERROR] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[$_tag ERROR] StackTrace: $stackTrace');
      }
    }
  }

  /// Log a warning message
  static void logWarning(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag WARNING] $message');
    }
  }
}