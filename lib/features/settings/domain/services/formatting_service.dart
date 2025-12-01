import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../presentation/providers/settings_providers.dart';

/// Service for formatting amounts and dates based on user settings
class FormattingService {
  const FormattingService(this._ref);

  final Ref _ref;

  /// Get the user's currency code from settings
  String get currencyCode {
    final settings = _ref.read(currentSettingsProvider);
    return settings?.currencyCode ?? 'USD';
  }

  /// Get the user's date format from settings
  String get dateFormat {
    final settings = _ref.read(currentSettingsProvider);
    return settings?.dateFormat ?? 'MM/dd/yyyy';
  }

  /// Format amount with user's currency settings
  String formatCurrency(double amount, {String? currencyCode, int? decimalDigits}) {
    final code = currencyCode ?? this.currencyCode;
    final digits = decimalDigits ?? 2;

    // For now, use simple formatting. In a real app, you'd use the currency service
    // to get proper currency symbols and formatting
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(code),
      decimalDigits: digits,
    );

    return formatter.format(amount);
  }

  /// Format date with user's date format settings
  String formatDate(DateTime date, {String? format}) {
    final dateFormat = format ?? this.dateFormat;
    final formatter = DateFormat(dateFormat);
    return formatter.format(date);
  }

  /// Format date and time
  String formatDateTime(DateTime dateTime, {String? dateFormat, String? timeFormat}) {
    final dateStr = formatDate(dateTime, format: dateFormat);
    final timeStr = DateFormat(timeFormat ?? 'HH:mm').format(dateTime);
    return '$dateStr $timeStr';
  }

  /// Get currency symbol for a currency code
  String _getCurrencySymbol(String currencyCode) {
    // Simple mapping - in a real app, this would come from the currency service
    const symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'NGN': '₦',
      'CAD': 'C\$',
      'AUD': 'A\$',
    };

    return symbols[currencyCode] ?? currencyCode;
  }
}