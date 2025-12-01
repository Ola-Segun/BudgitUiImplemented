import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

/// Widget that displays currency amounts using user settings
class SettingsCurrencyText extends ConsumerWidget {
  final double amount;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? currencyCode;
  final int? decimalDigits;

  const SettingsCurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.currencyCode,
    this.decimalDigits,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattingService = ref.watch(formattingServiceProvider);
    final formattedAmount = formattingService.formatCurrency(
      amount,
      currencyCode: currencyCode,
      decimalDigits: decimalDigits,
    );

    // Use a fixed width container to prevent layout shifts when currency changes
    return SizedBox(
      width: 100, // Fixed width to accommodate most currency formats
      child: Text(
        formattedAmount,
        style: style,
        textAlign: textAlign ?? TextAlign.end,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }
}

/// Widget that displays dates using user settings
class SettingsDateText extends ConsumerWidget {
  final DateTime date;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? format;

  const SettingsDateText({
    super.key,
    required this.date,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.format,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattingService = ref.watch(formattingServiceProvider);
    final formattedDate = formattingService.formatDate(date, format: format);

    // Use a fixed width container to prevent layout shifts when date format changes
    return SizedBox(
      width: 80, // Fixed width to accommodate most date formats
      child: Text(
        formattedDate,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }
}

/// Widget that displays date and time using user settings
class SettingsDateTimeText extends ConsumerWidget {
  final DateTime dateTime;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? dateFormat;
  final String? timeFormat;

  const SettingsDateTimeText({
    super.key,
    required this.dateTime,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.dateFormat,
    this.timeFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattingService = ref.watch(formattingServiceProvider);
    final formattedDateTime = formattingService.formatDateTime(
      dateTime,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
    );

    // Use a fixed width container to prevent layout shifts
    return SizedBox(
      width: 120, // Fixed width to accommodate date and time formats
      child: Text(
        formattedDateTime,
        style: style,
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }
}

/// Extension methods for easy formatting in widgets
extension FormattingExtensions on WidgetRef {
  /// Format currency using settings
  String formatCurrency(double amount, {String? currencyCode, int? decimalDigits}) {
    final formattingService = read(formattingServiceProvider);
    return formattingService.formatCurrency(
      amount,
      currencyCode: currencyCode,
      decimalDigits: decimalDigits,
    );
  }

  /// Format date using settings
  String formatDate(DateTime date, {String? format}) {
    final formattingService = read(formattingServiceProvider);
    return formattingService.formatDate(date, format: format);
  }

  /// Format date and time using settings
  String formatDateTime(DateTime dateTime, {String? dateFormat, String? timeFormat}) {
    final formattingService = read(formattingServiceProvider);
    return formattingService.formatDateTime(
      dateTime,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
    );
  }
}