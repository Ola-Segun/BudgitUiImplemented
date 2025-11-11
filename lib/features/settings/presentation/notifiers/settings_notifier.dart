import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';
import '../states/settings_state.dart';

/// State notifier for settings management
class SettingsNotifier extends StateNotifier<AsyncValue<SettingsState>> {
  final GetSettings _getSettings;
  final UpdateSettings _updateSettings;

  SettingsNotifier({
    required GetSettings getSettings,
    required UpdateSettings updateSettings,
  })  : _getSettings = getSettings,
        _updateSettings = updateSettings,
        super(const AsyncValue.loading()) {
    loadSettings();
  }

  /// Load settings from repository
  Future<void> loadSettings() async {
    debugPrint('SettingsNotifier: Loading settings');
    state = const AsyncValue.loading();

    final result = await _getSettings();

    result.when(
      success: (settings) {
        state = AsyncValue.data(SettingsState(
          settings: settings,
          isLoading: false,
          error: null,
        ));
      },
      error: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
    );
  }

  /// Update theme mode
  Future<bool> updateThemeMode(ThemeMode themeMode) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting('themeMode', themeMode);

    return result.when(
      success: (_) {
        // Update local state immediately for better UX
        state = AsyncValue.data(currentState.copyWith(
          settings: currentState.settings.copyWith(themeMode: themeMode),
        ));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Update currency code
  Future<bool> updateCurrencyCode(String currencyCode) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting('currencyCode', currencyCode);

    return result.when(
      success: (_) {
        state = AsyncValue.data(currentState.copyWith(
          settings: currentState.settings.copyWith(currencyCode: currencyCode),
        ));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Update notifications enabled
  Future<bool> updateNotificationsEnabled(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting('notificationsEnabled', enabled);

    return result.when(
      success: (_) {
        state = AsyncValue.data(currentState.copyWith(
          settings: currentState.settings.copyWith(notificationsEnabled: enabled),
        ));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Update budget alerts enabled
  Future<bool> updateBudgetAlertsEnabled(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting('budgetAlertsEnabled', enabled);

    return result.when(
      success: (_) {
        state = AsyncValue.data(currentState.copyWith(
          settings: currentState.settings.copyWith(budgetAlertsEnabled: enabled),
        ));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Update bill reminders enabled
  Future<bool> updateBillRemindersEnabled(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting('billRemindersEnabled', enabled);

    return result.when(
      success: (_) {
        state = AsyncValue.data(currentState.copyWith(
          settings: currentState.settings.copyWith(billRemindersEnabled: enabled),
        ));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Update budget alert threshold
  Future<bool> updateBudgetAlertThreshold(int threshold) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting('budgetAlertThreshold', threshold);

    return result.when(
      success: (_) {
        state = AsyncValue.data(currentState.copyWith(
          settings: currentState.settings.copyWith(budgetAlertThreshold: threshold),
        ));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Update bill reminder days
  Future<bool> updateBillReminderDays(int days) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting('billReminderDays', days);

    return result.when(
      success: (_) {
        state = AsyncValue.data(currentState.copyWith(
          settings: currentState.settings.copyWith(billReminderDays: days),
        ));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Update income reminders enabled
  Future<bool> updateIncomeRemindersEnabled(bool enabled) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting('incomeRemindersEnabled', enabled);

    return result.when(
      success: (_) {
        state = AsyncValue.data(currentState.copyWith(
          settings: currentState.settings.copyWith(incomeRemindersEnabled: enabled),
        ));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Update income reminder days
  Future<bool> updateIncomeReminderDays(int days) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting('incomeReminderDays', days);

    return result.when(
      success: (_) {
        state = AsyncValue.data(currentState.copyWith(
          settings: currentState.settings.copyWith(incomeReminderDays: days),
        ));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Export data
  Future<String?> exportData(DataExportType type) async {
    // TODO: Implement data export through repository
    // For now, return a placeholder
    return 'Data export not yet implemented';
  }

  /// Update a specific setting by key
  Future<bool> updateSetting(String key, dynamic value) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateSettings.updateSetting(key, value);

    return result.when(
      success: (_) {
        // Update local state immediately for better UX
        AppSettings updatedSettings;
        switch (key) {
          case 'themeMode':
            updatedSettings = currentState.settings.copyWith(themeMode: value as ThemeMode);
            break;
          case 'currencyCode':
            updatedSettings = currentState.settings.copyWith(currencyCode: value as String);
            break;
          case 'dateFormat':
            updatedSettings = currentState.settings.copyWith(dateFormat: value as String);
            break;
          case 'biometricEnabled':
            updatedSettings = currentState.settings.copyWith(biometricEnabled: value as bool);
            break;
          case 'autoBackupEnabled':
            updatedSettings = currentState.settings.copyWith(autoBackupEnabled: value as bool);
            break;
          case 'privacyModeEnabled':
            updatedSettings = currentState.settings.copyWith(privacyModeEnabled: value as bool);
            break;
          case 'privacyModeGestureEnabled':
            updatedSettings = currentState.settings.copyWith(privacyModeGestureEnabled: value as bool);
            break;
          case 'twoFactorEnabled':
            updatedSettings = currentState.settings.copyWith(twoFactorEnabled: value as bool);
            break;
          case 'twoFactorMethod':
            updatedSettings = currentState.settings.copyWith(twoFactorMethod: value as String);
            break;
          case 'backupCodes':
            updatedSettings = currentState.settings.copyWith(backupCodes: value as List<String>);
            break;
          case 'activityLoggingEnabled':
            updatedSettings = currentState.settings.copyWith(activityLoggingEnabled: value as bool);
            break;
          case 'quietHoursEnabled':
            updatedSettings = currentState.settings.copyWith(quietHoursEnabled: value as bool);
            break;
          case 'quietHoursStart':
            updatedSettings = currentState.settings.copyWith(quietHoursStart: value as String);
            break;
          case 'quietHoursEnd':
            updatedSettings = currentState.settings.copyWith(quietHoursEnd: value as String);
            break;
          case 'notificationFrequency':
            updatedSettings = currentState.settings.copyWith(notificationFrequency: value as String);
            break;
          case 'defaultExportFormat':
            updatedSettings = currentState.settings.copyWith(defaultExportFormat: value as String);
            break;
          case 'scheduledExportEnabled':
            updatedSettings = currentState.settings.copyWith(scheduledExportEnabled: value as bool);
            break;
          case 'scheduledExportFrequency':
            updatedSettings = currentState.settings.copyWith(scheduledExportFrequency: value as String);
            break;
          default:
            return false;
        }
        state = AsyncValue.data(currentState.copyWith(settings: updatedSettings));
        return true;
      },
      error: (failure) {
        state = AsyncValue.data(currentState.copyWith(error: failure.message));
        return false;
      },
    );
  }

  /// Clear error state
  void clearError() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(error: null));
    }
  }
}