import 'package:intl/intl.dart';

/// Extension methods for number formatting and utilities
extension NumberExtensions on num {
  /// Format as currency: 1234.56 -> "$1,234.56"
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    ).format(this);
  }

  /// Format with commas: 1234567 -> "1,234,567"
  String toFormatted() {
    return NumberFormat('#,###').format(this);
  }

  /// Compact format: 1500000 -> "1.5M"
  String toCompact() {
    return NumberFormat.compact().format(this);
  }

  /// Percentage: 0.85 -> "85%"
  String toPercentage({int decimals = 0}) {
    return NumberFormat.percentPattern()
        .format(this)
        .replaceAll('.00', '');
  }
}