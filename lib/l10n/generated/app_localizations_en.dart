// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Budget Tracker';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose your preferred language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Português';

  @override
  String get russian => 'Русский';

  @override
  String get japanese => '日本語';

  @override
  String get korean => '한국어';

  @override
  String get chinese => '中文';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeDescription => 'Choose your app theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get currency => 'Currency';

  @override
  String get currencyDescription => 'Select your currency';

  @override
  String get dateFormat => 'Date Format';

  @override
  String get dateFormatDescription => 'Choose how dates are displayed';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsDescription => 'Receive app notifications';

  @override
  String get budgetAlerts => 'Budget Alerts';

  @override
  String get budgetAlertsDescription => 'Notify when approaching budget limits';

  @override
  String get billReminders => 'Bill Reminders';

  @override
  String get billRemindersDescription => 'Remind about upcoming bills';

  @override
  String get incomeReminders => 'Income Reminders';

  @override
  String get incomeRemindersDescription => 'Remind about expected income';

  @override
  String get budgetAlertThreshold => 'Budget Alert Threshold';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '$value% of budget';
  }

  @override
  String get billReminderDays => 'Bill Reminder Days';

  @override
  String billReminderDaysDescription(Object days) {
    return '$days days before due';
  }

  @override
  String get incomeReminderDays => 'Income Reminder Days';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '$days days before';
  }

  @override
  String get securityPrivacy => 'Security & Privacy';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get biometricAuthDescription => 'Use fingerprint or face unlock';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get autoBackupDescription => 'Automatically backup data to cloud';

  @override
  String get twoFactorAuth => 'Two-Factor Authentication';

  @override
  String get setupTwoFactorAuth => 'Setup Two-Factor Auth';

  @override
  String get privacyMode => 'Privacy Mode';

  @override
  String get privacyModeDescription =>
      'Hide sensitive information like balances and account numbers';

  @override
  String get gestureActivation => 'Gesture Activation';

  @override
  String get gestureActivationDescription =>
      'Activate privacy mode with three-finger double tap';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataDescription => 'Export your data as JSON file';

  @override
  String get importData => 'Import Data';

  @override
  String get importDataDescription => 'Import data from JSON file';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataDescription => 'Permanently delete all app data';

  @override
  String get quietHours => 'Quiet Hours';

  @override
  String get enableQuietHours => 'Enable Quiet Hours';

  @override
  String get quietHoursDescription =>
      'Silence notifications during specified hours';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get exportOptions => 'Export Options';

  @override
  String get defaultFormat => 'Default Format';

  @override
  String get defaultFormatDescription => 'Choose default export format';

  @override
  String get scheduledExport => 'Scheduled Export';

  @override
  String get scheduledExportDescription =>
      'Automatically export data at set intervals';

  @override
  String get frequency => 'Frequency';

  @override
  String get frequencyDescription => 'Choose export frequency';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get quarterly => 'Quarterly';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get activityLogging => 'Activity Logging';

  @override
  String get activityLoggingDescription =>
      'Track and log user activities for analytics and troubleshooting';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get terms => 'Terms';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get resetToDefaults => 'Reset to defaults';

  @override
  String get resetSettingsConfirm =>
      'Reset all settings to default values? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get save => 'Save';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirm => 'Confirm';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get continueText => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get done => 'Done';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get update => 'Update';

  @override
  String get create => 'Create';

  @override
  String get select => 'Select';

  @override
  String get choose => 'Choose';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';
}
