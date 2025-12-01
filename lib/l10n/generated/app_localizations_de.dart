// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Budget Tracker';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get languageDescription => 'Wählen Sie Ihre bevorzugte Sprache';

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
  String get appearance => 'Erscheinungsbild';

  @override
  String get theme => 'Thema';

  @override
  String get themeDescription => 'Wählen Sie das App-Thema';

  @override
  String get system => 'System';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get currency => 'Währung';

  @override
  String get currencyDescription => 'Wählen Sie Ihre Währung';

  @override
  String get dateFormat => 'Datumsformat';

  @override
  String get dateFormatDescription => 'Wählen Sie, wie Daten angezeigt werden';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get pushNotificationsDescription => 'App-Benachrichtigungen erhalten';

  @override
  String get budgetAlerts => 'Budget-Alerts';

  @override
  String get budgetAlertsDescription =>
      'Benachrichtigen, wenn Budgetgrenzen erreicht werden';

  @override
  String get billReminders => 'Rechnungserinnerungen';

  @override
  String get billRemindersDescription => 'An bevorstehende Rechnungen erinnern';

  @override
  String get incomeReminders => 'Einkommenserinnerungen';

  @override
  String get incomeRemindersDescription => 'An erwartete Einkommen erinnern';

  @override
  String get budgetAlertThreshold => 'Budget-Alert-Schwellenwert';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '$value% des Budgets';
  }

  @override
  String get billReminderDays => 'Rechnungserinnerungstage';

  @override
  String billReminderDaysDescription(Object days) {
    return '$days Tage vor Fälligkeit';
  }

  @override
  String get incomeReminderDays => 'Einkommenserinnerungstage';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '$days Tage vorher';
  }

  @override
  String get securityPrivacy => 'Sicherheit und Datenschutz';

  @override
  String get biometricAuth => 'Biometrische Authentifizierung';

  @override
  String get biometricAuthDescription =>
      'Fingerabdruck oder Gesichtsentsperrung verwenden';

  @override
  String get autoBackup => 'Automatische Sicherung';

  @override
  String get autoBackupDescription => 'Daten automatisch in der Cloud sichern';

  @override
  String get twoFactorAuth => 'Zwei-Faktor-Authentifizierung';

  @override
  String get setupTwoFactorAuth => 'Zwei-Faktor-Authentifizierung einrichten';

  @override
  String get privacyMode => 'Datenschutzmodus';

  @override
  String get privacyModeDescription =>
      'Sensible Informationen wie Guthaben und Kontonummern ausblenden';

  @override
  String get gestureActivation => 'Gestenaktivierung';

  @override
  String get gestureActivationDescription =>
      'Datenschutzmodus mit Dreifinger-Doppelberührung aktivieren';

  @override
  String get dataManagement => 'Datenverwaltung';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get exportDataDescription => 'Ihre Daten als JSON-Datei exportieren';

  @override
  String get importData => 'Daten importieren';

  @override
  String get importDataDescription => 'Daten aus JSON-Datei importieren';

  @override
  String get clearAllData => 'Alle Daten löschen';

  @override
  String get clearAllDataDescription => 'Alle App-Daten dauerhaft löschen';

  @override
  String get quietHours => 'Ruhezeiten';

  @override
  String get enableQuietHours => 'Ruhezeiten aktivieren';

  @override
  String get quietHoursDescription =>
      'Benachrichtigungen während bestimmter Stunden stummschalten';

  @override
  String get startTime => 'Startzeit';

  @override
  String get endTime => 'Endzeit';

  @override
  String get exportOptions => 'Exportoptionen';

  @override
  String get defaultFormat => 'Standardformat';

  @override
  String get defaultFormatDescription => 'Standard-Exportformat wählen';

  @override
  String get scheduledExport => 'Geplanter Export';

  @override
  String get scheduledExportDescription =>
      'Daten automatisch in festgelegten Intervallen exportieren';

  @override
  String get frequency => 'Häufigkeit';

  @override
  String get frequencyDescription => 'Exporthäufigkeit wählen';

  @override
  String get daily => 'Täglich';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get quarterly => 'Vierteljährlich';

  @override
  String get advancedSettings => 'Erweiterte Einstellungen';

  @override
  String get activityLogging => 'Aktivitätsprotokollierung';

  @override
  String get activityLoggingDescription =>
      'Benutzeraktivitäten für Analyse und Fehlerbehebung verfolgen und protokollieren';

  @override
  String get about => 'Über';

  @override
  String get appVersion => 'App-Version';

  @override
  String get buildNumber => 'Build-Nummer';

  @override
  String get terms => 'Bedingungen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get resetToDefaults => 'Auf Standardeinstellungen zurücksetzen';

  @override
  String get resetSettingsConfirm =>
      'Alle Einstellungen auf Standardwerte zurücksetzen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get save => 'Speichern';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolg';

  @override
  String get loading => 'Lädt...';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get previous => 'Zurück';

  @override
  String get continueText => 'Fortfahren';

  @override
  String get skip => 'Überspringen';

  @override
  String get done => 'Fertig';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get create => 'Erstellen';

  @override
  String get select => 'Auswählen';

  @override
  String get choose => 'Wählen';

  @override
  String get search => 'Suchen';

  @override
  String get filter => 'Filtern';

  @override
  String get sort => 'Sortieren';

  @override
  String get ascending => 'Aufsteigend';

  @override
  String get descending => 'Absteigend';
}
