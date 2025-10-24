import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/settings_hive_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';
import '../notifiers/settings_notifier.dart';
import '../states/settings_state.dart';

// Data source provider
final settingsDataSourceProvider = Provider<SettingsHiveDataSource>((ref) {
  final dataSource = SettingsHiveDataSource();
  // Initialize the data source
  dataSource.init();
  return dataSource;
});

// Repository provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
});

// Use case providers
final getSettingsUseCaseProvider = Provider<GetSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettings(repository);
});

final updateSettingsUseCaseProvider = Provider<UpdateSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateSettings(repository);
});

// Notifier provider
final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>((ref) {
  final getSettings = ref.watch(getSettingsUseCaseProvider);
  final updateSettings = ref.watch(updateSettingsUseCaseProvider);

  return SettingsNotifier(
    getSettings: getSettings,
    updateSettings: updateSettings,
  );
});

// Current settings provider (convenience provider)
final currentSettingsProvider = Provider<AppSettings?>((ref) {
  final settingsState = ref.watch(settingsNotifierProvider);
  return settingsState.maybeWhen(
    data: (state) => state.settings,
    orElse: () => null,
  );
});

// Theme mode provider (for app-wide theme switching)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    // Listen to settings changes and update theme mode
    _ref.listen(currentSettingsProvider, (previous, next) {
      if (next != null) {
        state = next.themeMode;
      }
    });

    // Initialize with current settings
    final currentSettings = _ref.read(currentSettingsProvider);
    if (currentSettings != null) {
      state = currentSettings.themeMode;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    // Update settings
    await _ref.read(settingsNotifierProvider.notifier).updateThemeMode(themeMode);
  }
}