// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Suivi du Budget';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get languageDescription => 'Choisissez votre langue préférée';

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
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get themeDescription => 'Choisissez le thème de l\'application';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get currency => 'Devise';

  @override
  String get currencyDescription => 'Sélectionnez votre devise';

  @override
  String get dateFormat => 'Format de Date';

  @override
  String get dateFormatDescription =>
      'Choisissez comment les dates sont affichées';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications Push';

  @override
  String get pushNotificationsDescription =>
      'Recevoir les notifications de l\'application';

  @override
  String get budgetAlerts => 'Alertes de Budget';

  @override
  String get budgetAlertsDescription =>
      'Notifier lors de l\'approche des limites budgétaires';

  @override
  String get billReminders => 'Rappels de Factures';

  @override
  String get billRemindersDescription => 'Rappeler les factures à venir';

  @override
  String get incomeReminders => 'Rappels de Revenus';

  @override
  String get incomeRemindersDescription => 'Rappeler les revenus attendus';

  @override
  String get budgetAlertThreshold => 'Seuil d\'Alerte Budgétaire';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '$value% du budget';
  }

  @override
  String get billReminderDays => 'Jours de Rappel de Factures';

  @override
  String billReminderDaysDescription(Object days) {
    return '$days jours avant l\'échéance';
  }

  @override
  String get incomeReminderDays => 'Jours de Rappel de Revenus';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '$days jours avant';
  }

  @override
  String get securityPrivacy => 'Sécurité et Confidentialité';

  @override
  String get biometricAuth => 'Authentification Biométrique';

  @override
  String get biometricAuthDescription =>
      'Utiliser l\'empreinte digitale ou le déverrouillage facial';

  @override
  String get autoBackup => 'Sauvegarde Automatique';

  @override
  String get autoBackupDescription =>
      'Sauvegarder automatiquement les données dans le cloud';

  @override
  String get twoFactorAuth => 'Authentification à Deux Facteurs';

  @override
  String get setupTwoFactorAuth =>
      'Configurer l\'Authentification à Deux Facteurs';

  @override
  String get privacyMode => 'Mode de Confidentialité';

  @override
  String get privacyModeDescription =>
      'Masquer les informations sensibles comme les soldes et numéros de compte';

  @override
  String get gestureActivation => 'Activation par Geste';

  @override
  String get gestureActivationDescription =>
      'Activer le mode de confidentialité avec un double tap à trois doigts';

  @override
  String get dataManagement => 'Gestion des Données';

  @override
  String get exportData => 'Exporter les Données';

  @override
  String get exportDataDescription =>
      'Exporter vos données sous forme de fichier JSON';

  @override
  String get importData => 'Importer les Données';

  @override
  String get importDataDescription =>
      'Importer des données depuis un fichier JSON';

  @override
  String get clearAllData => 'Effacer Toutes les Données';

  @override
  String get clearAllDataDescription =>
      'Supprimer définitivement toutes les données de l\'application';

  @override
  String get quietHours => 'Heures de Silence';

  @override
  String get enableQuietHours => 'Activer les Heures de Silence';

  @override
  String get quietHoursDescription =>
      'Silencer les notifications pendant les heures spécifiées';

  @override
  String get startTime => 'Heure de Début';

  @override
  String get endTime => 'Heure de Fin';

  @override
  String get exportOptions => 'Options d\'Exportation';

  @override
  String get defaultFormat => 'Format par Défaut';

  @override
  String get defaultFormatDescription =>
      'Choisir le format d\'exportation par défaut';

  @override
  String get scheduledExport => 'Exportation Planifiée';

  @override
  String get scheduledExportDescription =>
      'Exporter automatiquement les données à intervalles définis';

  @override
  String get frequency => 'Fréquence';

  @override
  String get frequencyDescription => 'Choisir la fréquence d\'exportation';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get quarterly => 'Trimestriel';

  @override
  String get advancedSettings => 'Paramètres Avancés';

  @override
  String get activityLogging => 'Journalisation d\'Activité';

  @override
  String get activityLoggingDescription =>
      'Suivre et enregistrer les activités utilisateur pour l\'analyse et le dépannage';

  @override
  String get about => 'À Propos';

  @override
  String get appVersion => 'Version de l\'Application';

  @override
  String get buildNumber => 'Numéro de Build';

  @override
  String get terms => 'Conditions';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get resetToDefaults => 'Réinitialiser aux valeurs par défaut';

  @override
  String get resetSettingsConfirm =>
      'Réinitialiser tous les paramètres aux valeurs par défaut ? Cette action ne peut pas être annulée.';

  @override
  String get cancel => 'Annuler';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get save => 'Sauvegarder';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get confirm => 'Confirmer';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get loading => 'Chargement...';

  @override
  String get retry => 'Réessayer';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get continueText => 'Continuer';

  @override
  String get skip => 'Ignorer';

  @override
  String get done => 'Terminé';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get add => 'Ajouter';

  @override
  String get remove => 'Retirer';

  @override
  String get update => 'Mettre à Jour';

  @override
  String get create => 'Créer';

  @override
  String get select => 'Sélectionner';

  @override
  String get choose => 'Choisir';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get ascending => 'Croissant';

  @override
  String get descending => 'Décroissant';
}
