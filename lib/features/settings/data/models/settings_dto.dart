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
    );
  }

  /// Create default settings DTO
  factory SettingsDto.defaultSettings() {
    final defaultSettings = AppSettings.defaultSettings();
    return SettingsDto.fromDomain(defaultSettings);
  }
}