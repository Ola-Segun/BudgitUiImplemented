import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../currency/domain/services/currency_service.dart';
import '../entities/settings.dart';

/// Use case for getting the user's preferred currency
class GetUserCurrency {
  const GetUserCurrency(this._currencyService);

  final CurrencyService _currencyService;

  /// Execute the use case
  Future<Result<String>> call(AppSettings? settings) async {
    try {
      // First check if user has set a currency in settings
      if (settings?.currencyCode != null) {
        return Result.success(settings!.currencyCode!);
      }

      // Otherwise, get the base currency from currency service
      final baseCurrencyResult = await _currencyService.getBaseCurrency();
      if (baseCurrencyResult.isSuccess && baseCurrencyResult.dataOrNull != null) {
        return Result.success(baseCurrencyResult.dataOrNull!.code);
      }

      // Fallback to default currency
      return Result.success(_currencyService.getDefaultCurrency().code);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get user currency: $e'));
    }
  }
}