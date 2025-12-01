// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Rastreador de Presupuesto';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription => 'Elige tu idioma preferido';

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
  String get appearance => 'Apariencia';

  @override
  String get theme => 'Tema';

  @override
  String get themeDescription => 'Elige el tema de la aplicación';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get currency => 'Moneda';

  @override
  String get currencyDescription => 'Selecciona tu moneda';

  @override
  String get dateFormat => 'Formato de Fecha';

  @override
  String get dateFormatDescription => 'Elige cómo se muestran las fechas';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones Push';

  @override
  String get pushNotificationsDescription =>
      'Recibir notificaciones de la aplicación';

  @override
  String get budgetAlerts => 'Alertas de Presupuesto';

  @override
  String get budgetAlertsDescription =>
      'Notificar cuando se acerque a los límites del presupuesto';

  @override
  String get billReminders => 'Recordatorios de Facturas';

  @override
  String get billRemindersDescription => 'Recordar sobre facturas próximas';

  @override
  String get incomeReminders => 'Recordatorios de Ingresos';

  @override
  String get incomeRemindersDescription => 'Recordar sobre ingresos esperados';

  @override
  String get budgetAlertThreshold => 'Umbral de Alerta de Presupuesto';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '$value% del presupuesto';
  }

  @override
  String get billReminderDays => 'Días de Recordatorio de Facturas';

  @override
  String billReminderDaysDescription(Object days) {
    return '$days días antes del vencimiento';
  }

  @override
  String get incomeReminderDays => 'Días de Recordatorio de Ingresos';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '$days días antes';
  }

  @override
  String get securityPrivacy => 'Seguridad y Privacidad';

  @override
  String get biometricAuth => 'Autenticación Biométrica';

  @override
  String get biometricAuthDescription =>
      'Usar huella digital o desbloqueo facial';

  @override
  String get autoBackup => 'Copia de Seguridad Automática';

  @override
  String get autoBackupDescription =>
      'Respaldar datos automáticamente en la nube';

  @override
  String get twoFactorAuth => 'Autenticación de Dos Factores';

  @override
  String get setupTwoFactorAuth => 'Configurar Autenticación de Dos Factores';

  @override
  String get privacyMode => 'Modo de Privacidad';

  @override
  String get privacyModeDescription =>
      'Ocultar información sensible como saldos y números de cuenta';

  @override
  String get gestureActivation => 'Activación por Gesto';

  @override
  String get gestureActivationDescription =>
      'Activar modo de privacidad con doble toque de tres dedos';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get exportDataDescription => 'Exportar tus datos como archivo JSON';

  @override
  String get importData => 'Importar Datos';

  @override
  String get importDataDescription => 'Importar datos desde archivo JSON';

  @override
  String get clearAllData => 'Borrar Todos los Datos';

  @override
  String get clearAllDataDescription =>
      'Eliminar permanentemente todos los datos de la aplicación';

  @override
  String get quietHours => 'Horas de Silencio';

  @override
  String get enableQuietHours => 'Habilitar Horas de Silencio';

  @override
  String get quietHoursDescription =>
      'Silenciar notificaciones durante horas especificadas';

  @override
  String get startTime => 'Hora de Inicio';

  @override
  String get endTime => 'Hora de Fin';

  @override
  String get exportOptions => 'Opciones de Exportación';

  @override
  String get defaultFormat => 'Formato Predeterminado';

  @override
  String get defaultFormatDescription =>
      'Elegir formato de exportación predeterminado';

  @override
  String get scheduledExport => 'Exportación Programada';

  @override
  String get scheduledExportDescription =>
      'Exportar datos automáticamente a intervalos establecidos';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get frequencyDescription => 'Elegir frecuencia de exportación';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get quarterly => 'Trimestral';

  @override
  String get advancedSettings => 'Configuración Avanzada';

  @override
  String get activityLogging => 'Registro de Actividad';

  @override
  String get activityLoggingDescription =>
      'Rastrear y registrar actividades del usuario para análisis y resolución de problemas';

  @override
  String get about => 'Acerca de';

  @override
  String get appVersion => 'Versión de la Aplicación';

  @override
  String get buildNumber => 'Número de Compilación';

  @override
  String get terms => 'Términos';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get resetToDefaults => 'Restablecer valores predeterminados';

  @override
  String get resetSettingsConfirm =>
      '¿Restablecer todas las configuraciones a valores predeterminados? Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reset => 'Restablecer';

  @override
  String get save => 'Guardar';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get confirm => 'Confirmar';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get loading => 'Cargando...';

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get continueText => 'Continuar';

  @override
  String get skip => 'Omitir';

  @override
  String get done => 'Hecho';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get add => 'Agregar';

  @override
  String get remove => 'Remover';

  @override
  String get update => 'Actualizar';

  @override
  String get create => 'Crear';

  @override
  String get select => 'Seleccionar';

  @override
  String get choose => 'Elegir';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get ascending => 'Ascendente';

  @override
  String get descending => 'Descendente';
}
