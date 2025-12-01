// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Tracciatore Budget';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get languageDescription => 'Scegli la tua lingua preferita';

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
  String get appearance => 'Aspetto';

  @override
  String get theme => 'Tema';

  @override
  String get themeDescription => 'Scegli il tema dell\'app';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get currency => 'Valuta';

  @override
  String get currencyDescription => 'Seleziona la tua valuta';

  @override
  String get dateFormat => 'Formato Data';

  @override
  String get dateFormatDescription =>
      'Scegli come vengono visualizzate le date';

  @override
  String get notifications => 'Notifiche';

  @override
  String get pushNotifications => 'Notifiche Push';

  @override
  String get pushNotificationsDescription => 'Ricevi notifiche dell\'app';

  @override
  String get budgetAlerts => 'Avvisi Budget';

  @override
  String get budgetAlertsDescription =>
      'Notifica quando ti avvicini ai limiti del budget';

  @override
  String get billReminders => 'Promemoria Bollette';

  @override
  String get billRemindersDescription => 'Ricorda le bollette in arrivo';

  @override
  String get incomeReminders => 'Promemoria Entrate';

  @override
  String get incomeRemindersDescription => 'Ricorda le entrate previste';

  @override
  String get budgetAlertThreshold => 'Soglia Avviso Budget';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '$value% del budget';
  }

  @override
  String get billReminderDays => 'Giorni Promemoria Bollette';

  @override
  String billReminderDaysDescription(Object days) {
    return '$days giorni prima della scadenza';
  }

  @override
  String get incomeReminderDays => 'Giorni Promemoria Entrate';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '$days giorni prima';
  }

  @override
  String get securityPrivacy => 'Sicurezza e Privacy';

  @override
  String get biometricAuth => 'Autenticazione Biometrica';

  @override
  String get biometricAuthDescription =>
      'Usa impronta digitale o sblocco facciale';

  @override
  String get autoBackup => 'Backup Automatico';

  @override
  String get autoBackupDescription =>
      'Esegui automaticamente il backup dei dati nel cloud';

  @override
  String get twoFactorAuth => 'Autenticazione a Due Fattori';

  @override
  String get setupTwoFactorAuth => 'Imposta Autenticazione a Due Fattori';

  @override
  String get privacyMode => 'Modalità Privacy';

  @override
  String get privacyModeDescription =>
      'Nascondi informazioni sensibili come saldi e numeri di conto';

  @override
  String get gestureActivation => 'Attivazione Gesto';

  @override
  String get gestureActivationDescription =>
      'Attiva modalità privacy con doppio tocco a tre dita';

  @override
  String get dataManagement => 'Gestione Dati';

  @override
  String get exportData => 'Esporta Dati';

  @override
  String get exportDataDescription => 'Esporta i tuoi dati come file JSON';

  @override
  String get importData => 'Importa Dati';

  @override
  String get importDataDescription => 'Importa dati da file JSON';

  @override
  String get clearAllData => 'Cancella Tutti i Dati';

  @override
  String get clearAllDataDescription =>
      'Elimina definitivamente tutti i dati dell\'app';

  @override
  String get quietHours => 'Ore di Silenzio';

  @override
  String get enableQuietHours => 'Abilita Ore di Silenzio';

  @override
  String get quietHoursDescription =>
      'Silenzia notifiche durante le ore specificate';

  @override
  String get startTime => 'Ora di Inizio';

  @override
  String get endTime => 'Ora di Fine';

  @override
  String get exportOptions => 'Opzioni Esportazione';

  @override
  String get defaultFormat => 'Formato Predefinito';

  @override
  String get defaultFormatDescription =>
      'Scegli formato esportazione predefinito';

  @override
  String get scheduledExport => 'Esportazione Programmata';

  @override
  String get scheduledExportDescription =>
      'Esporta automaticamente dati a intervalli impostati';

  @override
  String get frequency => 'Frequenza';

  @override
  String get frequencyDescription => 'Scegli frequenza esportazione';

  @override
  String get daily => 'Giornaliero';

  @override
  String get weekly => 'Settimanale';

  @override
  String get monthly => 'Mensile';

  @override
  String get quarterly => 'Trimestrale';

  @override
  String get advancedSettings => 'Impostazioni Avanzate';

  @override
  String get activityLogging => 'Registrazione Attività';

  @override
  String get activityLoggingDescription =>
      'Traccia e registra attività utente per analisi e risoluzione problemi';

  @override
  String get about => 'Informazioni';

  @override
  String get appVersion => 'Versione App';

  @override
  String get buildNumber => 'Numero Build';

  @override
  String get terms => 'Termini';

  @override
  String get privacyPolicy => 'Informativa Privacy';

  @override
  String get resetToDefaults => 'Ripristina valori predefiniti';

  @override
  String get resetSettingsConfirm =>
      'Ripristinare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get cancel => 'Annulla';

  @override
  String get reset => 'Ripristina';

  @override
  String get save => 'Salva';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get confirm => 'Conferma';

  @override
  String get error => 'Errore';

  @override
  String get success => 'Successo';

  @override
  String get loading => 'Caricamento...';

  @override
  String get retry => 'Riprova';

  @override
  String get close => 'Chiudi';

  @override
  String get back => 'Indietro';

  @override
  String get next => 'Avanti';

  @override
  String get previous => 'Precedente';

  @override
  String get continueText => 'Continua';

  @override
  String get skip => 'Salta';

  @override
  String get done => 'Fatto';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get add => 'Aggiungi';

  @override
  String get remove => 'Rimuovi';

  @override
  String get update => 'Aggiorna';

  @override
  String get create => 'Crea';

  @override
  String get select => 'Seleziona';

  @override
  String get choose => 'Scegli';

  @override
  String get search => 'Cerca';

  @override
  String get filter => 'Filtra';

  @override
  String get sort => 'Ordina';

  @override
  String get ascending => 'Crescente';

  @override
  String get descending => 'Decrescente';
}
