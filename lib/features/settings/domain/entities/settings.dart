import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:budget_tracker/features/accounts/domain/entities/account_type_theme.dart';

part 'settings.freezed.dart';

/// Settings entity representing user preferences and app configuration
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    /// Theme mode preference
    required ThemeMode themeMode,

    /// Currency code (e.g., 'USD', 'EUR', 'NGN') - null means use system default
    String? currencyCode,

    /// Date format preference
    required String dateFormat,

    /// Enable/disable notifications
    required bool notificationsEnabled,

    /// Enable/disable budget alerts
    required bool budgetAlertsEnabled,

    /// Enable/disable bill reminders
    required bool billRemindersEnabled,

    /// Enable/disable income reminders
    required bool incomeRemindersEnabled,

    /// Budget alert threshold percentage (0-100)
    required int budgetAlertThreshold,

    /// Days before bill due date to show reminder
    required int billReminderDays,

    /// Days before income expected to show reminder
    required int incomeReminderDays,

    /// Enable/disable biometric authentication
    required bool biometricEnabled,

    /// Enable/disable data backup
    required bool autoBackupEnabled,

    /// App language/locale
    required String languageCode,

    /// First time user flag
    required bool isFirstTime,

    /// App version (for display purposes)
    required String appVersion,

    /// Custom account type themes
    @Default({}) Map<String, AccountTypeTheme> accountTypeThemes,

    /// Privacy Mode Settings
    @Default(false) bool privacyModeEnabled,
    @Default(true) bool privacyModeGestureEnabled,

    /// Two-Factor Authentication Settings
    @Default(false) bool twoFactorEnabled,
    @Default('') String twoFactorMethod,
    @Default([]) List<String> backupCodes,

    /// Activity Logging
    @Default(true) bool activityLoggingEnabled,

    /// Advanced Notification Settings
    @Default(false) bool quietHoursEnabled,
    @Default('22:00') String quietHoursStart,
    @Default('08:00') String quietHoursEnd,
    @Default('immediate') String notificationFrequency,

    /// Advanced Export Settings
    @Default('csv') String defaultExportFormat,
    @Default(false) bool scheduledExportEnabled,
    @Default('monthly') String scheduledExportFrequency,
    }) = _AppSettings;

  factory AppSettings.defaultSettings() => AppSettings(
        themeMode: ThemeMode.system,
        currencyCode: null, // Will be set by currency service
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        billRemindersEnabled: true,
        incomeRemindersEnabled: true,
        budgetAlertThreshold: 80,
        billReminderDays: 3,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: false,
        languageCode: 'en',
        isFirstTime: true,
        appVersion: '1.0.0',
        privacyModeEnabled: false,
        privacyModeGestureEnabled: true,
        twoFactorEnabled: false,
        twoFactorMethod: '',
        backupCodes: [],
        activityLoggingEnabled: true,
        quietHoursEnabled: false,
        quietHoursStart: '22:00',
        quietHoursEnd: '08:00',
        notificationFrequency: 'immediate',
        defaultExportFormat: 'csv',
        scheduledExportEnabled: false,
        scheduledExportFrequency: 'monthly',
      );
}

// Using Flutter's ThemeMode

/// Export/Import data types
enum DataExportType {
  json,
  csv,
  pdf,
}

/// Settings section types for UI organization
enum SettingsSection {
  appearance,
  notifications,
  data,
  privacy,
  account,
  about,
}