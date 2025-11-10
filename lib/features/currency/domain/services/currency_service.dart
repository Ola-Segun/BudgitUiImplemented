import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/currency.dart';
import '../repositories/currency_repository.dart';

/// Currency service that manages supported currencies, exchange rates, and user preferences
class CurrencyService {
  const CurrencyService(this._repository);

  final CurrencyRepository _repository;

  /// Get all available currencies
  Future<Result<List<Currency>>> getAllCurrencies() {
    return _repository.getAllCurrencies();
  }

  /// Get currency by code
  Future<Result<Currency?>> getCurrencyByCode(String code) {
    return _repository.getCurrencyByCode(code);
  }

  /// Get user's base currency
  Future<Result<Currency?>> getBaseCurrency() {
    return _repository.getBaseCurrency();
  }

  /// Set user's base currency
  Future<Result<void>> setBaseCurrency(String currencyCode) {
    return _repository.setBaseCurrency(currencyCode);
  }

  /// Get exchange rate between two currencies
  Future<Result<double?>> getExchangeRate(String fromCurrency, String toCurrency) {
    return _repository.getExchangeRate(fromCurrency, toCurrency);
  }

  /// Convert amount from one currency to another
  Future<Result<double>> convertAmount(double amount, String fromCurrency, String toCurrency) {
    return _repository.convertAmount(amount, fromCurrency, toCurrency);
  }

  /// Update exchange rates from external API
  Future<Result<void>> updateExchangeRates() {
    return _repository.updateExchangeRates();
  }

  /// Get supported currencies for the app
  Future<Result<List<Currency>>> getSupportedCurrencies() {
    return _repository.getSupportedCurrencies();
  }

  /// Get default currency (USD as fallback)
  Currency getDefaultCurrency() => Currency.usd;

  /// Validate if a currency code is supported
  Future<Result<bool>> isCurrencySupported(String currencyCode) async {
    final result = await getSupportedCurrencies();
    if (result.isError) return Result.error(result.failureOrNull!);

    final supportedCurrencies = result.dataOrNull!;
    return Result.success(
      supportedCurrencies.any((currency) => currency.code == currencyCode),
    );
  }

  /// Get currency symbol for a currency code
  Future<Result<String>> getCurrencySymbol(String currencyCode) async {
    final result = await getCurrencyByCode(currencyCode);
    if (result.isError) return Result.error(result.failureOrNull!);

    final currency = result.dataOrNull;
    if (currency == null) {
      return Result.error(Failure.notFound('Currency not found: $currencyCode'));
    }

    return Result.success(currency.symbol);
  }

  /// Format amount with currency symbol
  Future<Result<String>> formatAmount(double amount, String currencyCode) async {
    final result = await getCurrencyByCode(currencyCode);
    if (result.isError) return Result.error(result.failureOrNull!);

    final currency = result.dataOrNull;
    if (currency == null) {
      return Result.error(Failure.notFound('Currency not found: $currencyCode'));
    }

    return Result.success(currency.formatAmount(amount));
  }
}