import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../entities/bill.dart';

/// Use case for validating and handling currency differences in bill payments
/// Ensures proper currency handling for multi-currency scenarios
class ValidateBillCurrency {
  const ValidateBillCurrency(this._accountRepository);

  final AccountRepository _accountRepository;

  /// Validate currency compatibility for bill payment
  Future<Result<CurrencyValidationResult>> validatePaymentCurrency({
    required Bill bill,
    required String accountId,
    required double paymentAmount,
  }) async {
    // Get account details
    final accountResult = await _accountRepository.getById(accountId);
    if (accountResult.isError) {
      return Result.error(accountResult.failureOrNull!);
    }

    final account = accountResult.dataOrNull!;

    // Get bill currency (default to USD if not specified)
    final billCurrency = bill.currencyCode ?? 'USD';
    final accountCurrency = account.currency ?? 'USD';

    // Check if currencies match
    final currenciesMatch = billCurrency == accountCurrency;

    // For same currency, no conversion needed
    if (currenciesMatch) {
      return Result.success(CurrencyValidationResult(
        isValid: true,
        requiresConversion: false,
        billCurrency: billCurrency,
        accountCurrency: accountCurrency,
        originalAmount: paymentAmount,
        convertedAmount: paymentAmount,
        exchangeRate: 1.0,
        conversionFee: 0.0,
        warnings: [],
      ));
    }

    // For different currencies, check if conversion is supported
    final conversionResult = await _calculateCurrencyConversion(
      billCurrency,
      accountCurrency,
      paymentAmount,
    );

    if (conversionResult.isError) {
      return Result.error(conversionResult.failureOrNull!);
    }

    final conversion = conversionResult.dataOrNull!;

    // Check if converted amount is valid for the account
    final convertedAmount = conversion.convertedAmount;
    final availableBalance = account.availableBalance;

    final warnings = <String>[];
    if (convertedAmount > availableBalance) {
      warnings.add('Converted amount exceeds account balance');
    }

    // Add warnings for high conversion fees
    if (conversion.conversionFee > paymentAmount * 0.05) { // More than 5%
      warnings.add('High currency conversion fee');
    }

    return Result.success(CurrencyValidationResult(
      isValid: convertedAmount <= availableBalance,
      requiresConversion: true,
      billCurrency: billCurrency,
      accountCurrency: accountCurrency,
      originalAmount: paymentAmount,
      convertedAmount: convertedAmount,
      exchangeRate: conversion.exchangeRate,
      conversionFee: conversion.conversionFee,
      warnings: warnings,
    ));
  }

  /// Get currency exchange rate between two currencies
  Future<Result<double>> getExchangeRate(String fromCurrency, String toCurrency) async {
    // In a real implementation, this would call a currency API
    // For now, return mock rates for common currencies

    if (fromCurrency == toCurrency) return Result.success(1.0);

    // Mock exchange rates (as of 2024)
    final rates = {
      'USD': {'EUR': 0.85, 'GBP': 0.73, 'CAD': 1.25, 'AUD': 1.35, 'JPY': 110.0},
      'EUR': {'USD': 1.18, 'GBP': 0.86, 'CAD': 1.47, 'AUD': 1.59, 'JPY': 129.0},
      'GBP': {'USD': 1.37, 'EUR': 1.16, 'CAD': 1.71, 'AUD': 1.85, 'JPY': 150.0},
      'CAD': {'USD': 0.80, 'EUR': 0.68, 'GBP': 0.58, 'AUD': 1.08, 'JPY': 88.0},
      'AUD': {'USD': 0.74, 'EUR': 0.63, 'GBP': 0.54, 'CAD': 0.93, 'JPY': 81.0},
      'JPY': {'USD': 0.0091, 'EUR': 0.0078, 'GBP': 0.0067, 'CAD': 0.0114, 'AUD': 0.0123},
    };

    final fromRates = rates[fromCurrency];
    if (fromRates == null) {
      return Result.error(Failure.validation(
        'Unsupported currency',
        {'currency': fromCurrency, 'supported': rates.keys.join(', ')},
      ));
    }

    final rate = fromRates[toCurrency];
    if (rate == null) {
      return Result.error(Failure.validation(
        'Exchange rate not available',
        {'from': fromCurrency, 'to': toCurrency},
      ));
    }

    return Result.success(rate);
  }

  /// Validate currency code format
  Result<void> validateCurrencyCode(String currencyCode) {
    // ISO 4217 currency codes are 3 letters
    if (currencyCode.length != 3) {
      return Result.error(Failure.validation(
        'Invalid currency code length',
        {'code': currencyCode, 'required': '3 characters'},
      ));
    }

    // Check if all characters are letters
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      return Result.error(Failure.validation(
        'Invalid currency code format',
        {'code': currencyCode, 'required': '3 uppercase letters'},
      ));
    }

    // Common currency codes (not exhaustive) - should be moved to currency service
    const supportedCurrencies = {
      'USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'CHF', 'CNY', 'SEK', 'NZD',
      'MXN', 'SGD', 'HKD', 'NOK', 'KRW', 'TRY', 'RUB', 'INR', 'BRL', 'ZAR'
    };

    if (!supportedCurrencies.contains(currencyCode)) {
      // Allow uncommon currencies but could warn in UI
      // In a full implementation, this could return a warning result
    }

    return Result.success(null);
  }

  /// Get supported currencies for the application
  /// TODO: This should be moved to currency service for centralized management
  List<String> getSupportedCurrencies() {
    return [
      'USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'CHF', 'CNY', 'SEK', 'NZD',
      'MXN', 'SGD', 'HKD', 'NOK', 'KRW', 'TRY', 'RUB', 'INR', 'BRL', 'ZAR'
    ];
  }

  /// Calculate currency conversion with fees
  Future<Result<CurrencyConversion>> _calculateCurrencyConversion(
    String fromCurrency,
    String toCurrency,
    double amount,
  ) async {
    // Get exchange rate
    final rateResult = await getExchangeRate(fromCurrency, toCurrency);
    if (rateResult.isError) {
      return Result.error(rateResult.failureOrNull!);
    }

    final exchangeRate = rateResult.dataOrNull!;

    // Calculate converted amount
    final convertedAmount = amount * exchangeRate;

    // Calculate conversion fee (typically 1-3% for personal transfers)
    const conversionFeePercent = 0.025; // 2.5%
    final conversionFee = convertedAmount * conversionFeePercent;

    // Total amount needed in target currency
    final totalAmount = convertedAmount + conversionFee;

    return Result.success(CurrencyConversion(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      originalAmount: amount,
      convertedAmount: totalAmount,
      exchangeRate: exchangeRate,
      conversionFee: conversionFee,
    ));
  }
}

/// Result of currency validation
class CurrencyValidationResult {
  const CurrencyValidationResult({
    required this.isValid,
    required this.requiresConversion,
    required this.billCurrency,
    required this.accountCurrency,
    required this.originalAmount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.conversionFee,
    required this.warnings,
  });

  final bool isValid;
  final bool requiresConversion;
  final String billCurrency;
  final String accountCurrency;
  final double originalAmount;
  final double convertedAmount;
  final double exchangeRate;
  final double conversionFee;
  final List<String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
  bool get isSameCurrency => billCurrency == accountCurrency;

  String get conversionDescription {
    if (!requiresConversion) return 'No conversion needed';

    return '${originalAmount.toStringAsFixed(2)} $billCurrency = '
           '${convertedAmount.toStringAsFixed(2)} $accountCurrency '
           '(Rate: ${exchangeRate.toStringAsFixed(4)}, Fee: ${conversionFee.toStringAsFixed(2)} $accountCurrency)';
  }
}

/// Currency conversion details
class CurrencyConversion {
  const CurrencyConversion({
    required this.fromCurrency,
    required this.toCurrency,
    required this.originalAmount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.conversionFee,
  });

  final String fromCurrency;
  final String toCurrency;
  final double originalAmount;
  final double convertedAmount;
  final double exchangeRate;
  final double conversionFee;

  double get totalCost => convertedAmount + conversionFee;
}