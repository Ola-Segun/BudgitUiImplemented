import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/settings.dart';
import 'package:budget_tracker/features/accounts/domain/entities/account_type_theme.dart';

part 'settings_dto.g.dart';

/// Data transfer object for settings storage
@HiveType(typeId: 100) // Use a unique typeId
class SettingsDto {
  @HiveField(0)
  final String themeMode;

  @HiveField(1)
  final String currencyCode;

  @HiveField(2)
  final String dateFormat;

  @HiveField(3)
  final bool notificationsEnabled;

  @HiveField(4)
  final bool budgetAlertsEnabled;

  @HiveField(5)
  final bool billRemindersEnabled;

  @HiveField(6)
  final bool incomeRemindersEnabled;

  @HiveField(7)
  final int budgetAlertThreshold;

  @HiveField(8)
  final int billReminderDays;

  @HiveField(9)
  final int incomeReminderDays;

  @HiveField(10)
  final bool biometricEnabled;

  @HiveField(11)
  final bool autoBackupEnabled;

  @HiveField(12)
  final String languageCode;

  @HiveField(13)
  final bool isFirstTime;

  @HiveField(14)
  final String appVersion;

  @HiveField(15)
  final Map<String, Map<String, dynamic>> accountTypeThemes;

  @HiveField(16)
  final bool privacyModeEnabled;

  @HiveField(17)
  final bool privacyModeGestureEnabled;

  @HiveField(18)
  final bool twoFactorEnabled;

  @HiveField(19)
  final String twoFactorMethod;

  @HiveField(20)
  final List<String> backupCodes;

  @HiveField(21)
  final bool activityLoggingEnabled;

  @HiveField(22)
  final bool quietHoursEnabled;

  @HiveField(23)
  final String quietHoursStart;

  @HiveField(24)
  final String quietHoursEnd;

  @HiveField(25)
  final String notificationFrequency;

  @HiveField(26)
  final String defaultExportFormat;

  @HiveField(27)
  final bool scheduledExportEnabled;

  @HiveField(28)
  final String scheduledExportFrequency;

  const SettingsDto({
    required this.themeMode,
    required this.currencyCode,
    required this.dateFormat,
    required this.notificationsEnabled,
    required this.budgetAlertsEnabled,
    required this.billRemindersEnabled,
    required this.incomeRemindersEnabled,
    required this.budgetAlertThreshold,
    required this.billReminderDays,
    required this.incomeReminderDays,
    required this.biometricEnabled,
    required this.autoBackupEnabled,
    required this.languageCode,
    required this.isFirstTime,
    required this.appVersion,
    required this.accountTypeThemes,
    required this.privacyModeEnabled,
    required this.privacyModeGestureEnabled,
    required this.twoFactorEnabled,
    required this.twoFactorMethod,
    required this.backupCodes,
    required this.activityLoggingEnabled,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.notificationFrequency,
    required this.defaultExportFormat,
    required this.scheduledExportEnabled,
    required this.scheduledExportFrequency,
  });

  /// Create DTO from domain entity
  factory SettingsDto.fromDomain(AppSettings settings) {
    return SettingsDto(
      themeMode: settings.themeMode.name,
      currencyCode: settings.currencyCode ?? '',
      dateFormat: settings.dateFormat,
      notificationsEnabled: settings.notificationsEnabled,
      budgetAlertsEnabled: settings.budgetAlertsEnabled,
      billRemindersEnabled: settings.billRemindersEnabled,
      incomeRemindersEnabled: settings.incomeRemindersEnabled,
      budgetAlertThreshold: settings.budgetAlertThreshold,
      billReminderDays: settings.billReminderDays,
      incomeReminderDays: settings.incomeReminderDays,
      biometricEnabled: settings.biometricEnabled,
      autoBackupEnabled: settings.autoBackupEnabled,
      languageCode: settings.languageCode,
      isFirstTime: settings.isFirstTime,
      appVersion: settings.appVersion,
      accountTypeThemes: settings.accountTypeThemes.map(
        (key, theme) => MapEntry(key, {
          'accountType': theme.accountType,
          'displayName': theme.displayName,
          'iconName': theme.iconName,
          'colorValue': theme.colorValue,
        }),
      ),
      privacyModeEnabled: settings.privacyModeEnabled,
      privacyModeGestureEnabled: settings.privacyModeGestureEnabled,
      twoFactorEnabled: settings.twoFactorEnabled,
      twoFactorMethod: settings.twoFactorMethod,
      backupCodes: settings.backupCodes,
      activityLoggingEnabled: settings.activityLoggingEnabled,
      quietHoursEnabled: settings.quietHoursEnabled,
      quietHoursStart: settings.quietHoursStart,
      quietHoursEnd: settings.quietHoursEnd,
      notificationFrequency: settings.notificationFrequency,
      defaultExportFormat: settings.defaultExportFormat,
      scheduledExportEnabled: settings.scheduledExportEnabled,
      scheduledExportFrequency: settings.scheduledExportFrequency,
    );
  }

  /// Convert to domain entity
  AppSettings toDomain() {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == themeMode,
        orElse: () => ThemeMode.system,
      ),
      currencyCode: currencyCode.isEmpty ? null : currencyCode,
      dateFormat: dateFormat,
      notificationsEnabled: notificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled,
      billRemindersEnabled: billRemindersEnabled,
      incomeRemindersEnabled: incomeRemindersEnabled,
      budgetAlertThreshold: budgetAlertThreshold,
      billReminderDays: billReminderDays,
      incomeReminderDays: incomeReminderDays,
      biometricEnabled: biometricEnabled,
      autoBackupEnabled: autoBackupEnabled,
      languageCode: languageCode,
      isFirstTime: isFirstTime,
      appVersion: appVersion,
      accountTypeThemes: accountTypeThemes.map(
        (key, themeMap) => MapEntry(
          key,
          AccountTypeTheme(
            accountType: themeMap['accountType'] as String? ?? '',
            displayName: themeMap['displayName'] as String? ?? '',
            iconName: themeMap['iconName'] as String? ?? '',
            colorValue: themeMap['colorValue'] as int? ?? 0,
          ),
        ),
      ),
      privacyModeEnabled: privacyModeEnabled,
      privacyModeGestureEnabled: privacyModeGestureEnabled,
      twoFactorEnabled: twoFactorEnabled,
      twoFactorMethod: twoFactorMethod,
      backupCodes: backupCodes,
      activityLoggingEnabled: activityLoggingEnabled,
      quietHoursEnabled: quietHoursEnabled,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
      notificationFrequency: notificationFrequency,
      defaultExportFormat: defaultExportFormat,
      scheduledExportEnabled: scheduledExportEnabled,
      scheduledExportFrequency: scheduledExportFrequency,
    );
  }

  /// Create default settings DTO
  factory SettingsDto.defaultSettings() {
    return SettingsDto(
      themeMode: 'system',
      currencyCode: '',
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
      accountTypeThemes: {},
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
}