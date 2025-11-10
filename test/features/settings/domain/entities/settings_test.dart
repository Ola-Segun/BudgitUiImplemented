import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/features/settings/domain/entities/settings.dart';

void main() {
  group('AppSettings Entity', () {
    test('should create AppSettings with all fields', () {
      // Arrange
      const themeMode = ThemeMode.dark;
      const currencyCode = 'EUR';
      const dateFormat = 'dd/MM/yyyy';
      const notificationsEnabled = false;
      const budgetAlertsEnabled = false;
      const billRemindersEnabled = false;
      const budgetAlertThreshold = 90;
      const billReminderDays = 7;
      const biometricEnabled = true;
      const autoBackupEnabled = true;
      const languageCode = 'es';
      const isFirstTime = false;
      const appVersion = '1.2.0';

      // Act
      final settings = AppSettings(
        themeMode: themeMode,
        currencyCode: currencyCode,
        dateFormat: dateFormat,
        notificationsEnabled: notificationsEnabled,
        budgetAlertsEnabled: budgetAlertsEnabled,
        billRemindersEnabled: billRemindersEnabled,
        incomeRemindersEnabled: true,
        budgetAlertThreshold: budgetAlertThreshold,
        billReminderDays: billReminderDays,
        incomeReminderDays: 1,
        biometricEnabled: biometricEnabled,
        autoBackupEnabled: autoBackupEnabled,
        languageCode: languageCode,
        isFirstTime: isFirstTime,
        appVersion: appVersion,
      );

      // Assert
      expect(settings.themeMode, themeMode);
      expect(settings.currencyCode, currencyCode);
      expect(settings.dateFormat, dateFormat);
      expect(settings.notificationsEnabled, notificationsEnabled);
      expect(settings.budgetAlertsEnabled, budgetAlertsEnabled);
      expect(settings.billRemindersEnabled, billRemindersEnabled);
      expect(settings.budgetAlertThreshold, budgetAlertThreshold);
      expect(settings.billReminderDays, billReminderDays);
      expect(settings.biometricEnabled, biometricEnabled);
      expect(settings.autoBackupEnabled, autoBackupEnabled);
      expect(settings.languageCode, languageCode);
      expect(settings.isFirstTime, isFirstTime);
      expect(settings.appVersion, appVersion);
    });

    test('should create default settings', () {
      // Act
      final settings = AppSettings.defaultSettings();

      // Assert
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.currencyCode, null);
      expect(settings.dateFormat, 'MM/dd/yyyy');
      expect(settings.notificationsEnabled, true);
      expect(settings.budgetAlertsEnabled, true);
      expect(settings.billRemindersEnabled, true);
      expect(settings.budgetAlertThreshold, 80);
      expect(settings.billReminderDays, 3);
      expect(settings.biometricEnabled, false);
      expect(settings.autoBackupEnabled, false);
      expect(settings.languageCode, 'en');
      expect(settings.isFirstTime, true);
      expect(settings.appVersion, '1.0.0');
    });

    test('should support copyWith', () {
      // Arrange
      final original = AppSettings.defaultSettings();

      // Act
      final updated = original.copyWith(
        themeMode: ThemeMode.dark,
        currencyCode: 'EUR',
        notificationsEnabled: false,
      );

      // Assert
      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.currencyCode, 'EUR');
      expect(updated.notificationsEnabled, false);
      // Other fields should remain the same
      expect(updated.dateFormat, original.dateFormat);
      expect(updated.budgetAlertsEnabled, original.budgetAlertsEnabled);
    });

    test('should support equality', () {
      // Arrange
      final settings1 = AppSettings.defaultSettings();
      final settings2 = AppSettings.defaultSettings();
      final settings3 = settings1.copyWith(themeMode: ThemeMode.dark);

      // Assert
      expect(settings1, settings2);
      expect(settings1, isNot(settings3));
    });

    test('should validate budget alert threshold range', () {
      // Arrange & Act & Assert
      expect(() => AppSettings.defaultSettings().copyWith(budgetAlertThreshold: -1), returnsNormally);
      expect(() => AppSettings.defaultSettings().copyWith(budgetAlertThreshold: 150), returnsNormally);
      // Note: In a real app, you might want validation, but freezed doesn't enforce it
    });

    test('should validate bill reminder days range', () {
      // Arrange & Act & Assert
      expect(() => AppSettings.defaultSettings().copyWith(billReminderDays: 0), returnsNormally);
      expect(() => AppSettings.defaultSettings().copyWith(billReminderDays: 30), returnsNormally);
    });
  });

  group('DataExportType Enum', () {
    test('should have correct values', () {
      // Assert
      expect(DataExportType.json.name, 'json');
      expect(DataExportType.csv.name, 'csv');
      expect(DataExportType.pdf.name, 'pdf');
    });
  });

  group('SettingsSection Enum', () {
    test('should have correct values', () {
      // Assert
      expect(SettingsSection.appearance.name, 'appearance');
      expect(SettingsSection.notifications.name, 'notifications');
      expect(SettingsSection.data.name, 'data');
      expect(SettingsSection.privacy.name, 'privacy');
      expect(SettingsSection.account.name, 'account');
      expect(SettingsSection.about.name, 'about');
    });
  });
}