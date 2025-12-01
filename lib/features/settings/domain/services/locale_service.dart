import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../presentation/providers/settings_providers.dart';

/// Service for managing app locale and language settings
class LocaleService {
  final SettingsRepository _settingsRepository;

  LocaleService(this._settingsRepository);

  /// Get the current locale based on user settings
  Future<Locale> getCurrentLocale() async {
    final result = await _settingsRepository.getSettings();
    final settings = result.getOrDefault(AppSettings.defaultSettings());
    final languageCode = settings.languageCode;

    // Map language codes to Locale objects
    switch (languageCode) {
      case 'en':
        return const Locale('en');
      case 'es':
        return const Locale('es');
      case 'fr':
        return const Locale('fr');
      case 'de':
        return const Locale('de');
      case 'it':
        return const Locale('it');
      case 'pt':
        return const Locale('pt');
      case 'ru':
        return const Locale('ru');
      case 'ja':
        return const Locale('ja');
      case 'ko':
        return const Locale('ko');
      case 'zh':
        return const Locale('zh');
      default:
        return const Locale('en'); // Default to English
    }
  }

  /// Set the app locale
  Future<void> setLocale(String languageCode) async {
    await _settingsRepository.updateSetting('languageCode', languageCode);
  }

  /// Get the display name for a language code
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'zh':
        return '中文';
      default:
        return 'English';
    }
  }

  /// Get list of supported language codes
  List<String> getSupportedLanguageCodes() {
    return ['en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'ja', 'ko', 'zh'];
  }

  /// Get list of supported locales
  List<Locale> getSupportedLocales() {
    return getSupportedLanguageCodes()
        .map((code) => Locale(code))
        .toList();
  }
}

/// Provider for LocaleService
final localeServiceProvider = Provider<LocaleService>((ref) {
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  return LocaleService(settingsRepository);
});

/// Provider for current locale
final currentLocaleProvider = FutureProvider<Locale>((ref) {
  final localeService = ref.watch(localeServiceProvider);
  return localeService.getCurrentLocale();
});