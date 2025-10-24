import 'package:flutter/material.dart';

/// Extension methods for BuildContext to provide easy access to theme and navigation
extension BuildContextExtensions on BuildContext {
  /// Access theme data easily
  ThemeData get theme => Theme.of(this);

  /// Access color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Access text theme
  TextTheme get textTheme => theme.textTheme;

  /// Screen size helpers
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Responsive breakpoints
  bool get isMobile => screenWidth < 640;
  bool get isTablet => screenWidth >= 640 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  /// Navigation helpers
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Show snackbar helper
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}