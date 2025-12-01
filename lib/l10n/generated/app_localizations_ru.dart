// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Отслеживание Бюджета';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get languageDescription => 'Выберите предпочитаемый язык';

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
  String get appearance => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get themeDescription => 'Выберите тему приложения';

  @override
  String get system => 'Система';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Темная';

  @override
  String get currency => 'Валюта';

  @override
  String get currencyDescription => 'Выберите вашу валюту';

  @override
  String get dateFormat => 'Формат даты';

  @override
  String get dateFormatDescription => 'Выберите, как отображаются даты';

  @override
  String get notifications => 'Уведомления';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get pushNotificationsDescription => 'Получать уведомления приложения';

  @override
  String get budgetAlerts => 'Предупреждения о бюджете';

  @override
  String get budgetAlertsDescription =>
      'Уведомлять при приближении к лимитам бюджета';

  @override
  String get billReminders => 'Напоминания о счетах';

  @override
  String get billRemindersDescription => 'Напоминать о предстоящих счетах';

  @override
  String get incomeReminders => 'Напоминания о доходах';

  @override
  String get incomeRemindersDescription => 'Напоминать об ожидаемых доходах';

  @override
  String get budgetAlertThreshold => 'Порог предупреждения о бюджете';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '$value% бюджета';
  }

  @override
  String get billReminderDays => 'Дни напоминания о счетах';

  @override
  String billReminderDaysDescription(Object days) {
    return '$days дней до срока оплаты';
  }

  @override
  String get incomeReminderDays => 'Дни напоминания о доходах';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '$days дней до';
  }

  @override
  String get securityPrivacy => 'Безопасность и конфиденциальность';

  @override
  String get biometricAuth => 'Биометрическая аутентификация';

  @override
  String get biometricAuthDescription =>
      'Использовать отпечаток пальца или разблокировку лица';

  @override
  String get autoBackup => 'Автоматическое резервное копирование';

  @override
  String get autoBackupDescription =>
      'Автоматически резервное копирование данных в облако';

  @override
  String get twoFactorAuth => 'Двухфакторная аутентификация';

  @override
  String get setupTwoFactorAuth => 'Настроить двухфакторную аутентификацию';

  @override
  String get privacyMode => 'Режим конфиденциальности';

  @override
  String get privacyModeDescription =>
      'Скрывать конфиденциальную информацию, такую как балансы и номера счетов';

  @override
  String get gestureActivation => 'Активация жестом';

  @override
  String get gestureActivationDescription =>
      'Активировать режим конфиденциальности двойным касанием тремя пальцами';

  @override
  String get dataManagement => 'Управление данными';

  @override
  String get exportData => 'Экспорт данных';

  @override
  String get exportDataDescription =>
      'Экспортировать ваши данные как файл JSON';

  @override
  String get importData => 'Импорт данных';

  @override
  String get importDataDescription => 'Импортировать данные из файла JSON';

  @override
  String get clearAllData => 'Очистить все данные';

  @override
  String get clearAllDataDescription =>
      'Навсегда удалить все данные приложения';

  @override
  String get quietHours => 'Тихие часы';

  @override
  String get enableQuietHours => 'Включить тихие часы';

  @override
  String get quietHoursDescription => 'Отключать уведомления в указанные часы';

  @override
  String get startTime => 'Время начала';

  @override
  String get endTime => 'Время окончания';

  @override
  String get exportOptions => 'Параметры экспорта';

  @override
  String get defaultFormat => 'Формат по умолчанию';

  @override
  String get defaultFormatDescription => 'Выбрать формат экспорта по умолчанию';

  @override
  String get scheduledExport => 'Запланированный экспорт';

  @override
  String get scheduledExportDescription =>
      'Автоматически экспортировать данные через заданные интервалы';

  @override
  String get frequency => 'Частота';

  @override
  String get frequencyDescription => 'Выбрать частоту экспорта';

  @override
  String get daily => 'Ежедневно';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get quarterly => 'Ежеквартально';

  @override
  String get advancedSettings => 'Расширенные настройки';

  @override
  String get activityLogging => 'Журналирование активности';

  @override
  String get activityLoggingDescription =>
      'Отслеживать и записывать действия пользователя для анализа и устранения неисправностей';

  @override
  String get about => 'О приложении';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get buildNumber => 'Номер сборки';

  @override
  String get terms => 'Условия';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get resetToDefaults => 'Сбросить к настройкам по умолчанию';

  @override
  String get resetSettingsConfirm =>
      'Сбросить все настройки к значениям по умолчанию? Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get reset => 'Сброс';

  @override
  String get save => 'Сохранить';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get error => 'Ошибка';

  @override
  String get success => 'Успех';

  @override
  String get loading => 'Загрузка...';

  @override
  String get retry => 'Повторить';

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get previous => 'Предыдущий';

  @override
  String get continueText => 'Продолжить';

  @override
  String get skip => 'Пропустить';

  @override
  String get done => 'Готово';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get add => 'Добавить';

  @override
  String get remove => 'Удалить';

  @override
  String get update => 'Обновить';

  @override
  String get create => 'Создать';

  @override
  String get select => 'Выбрать';

  @override
  String get choose => 'Выбрать';

  @override
  String get search => 'Поиск';

  @override
  String get filter => 'Фильтр';

  @override
  String get sort => 'Сортировка';

  @override
  String get ascending => 'По возрастанию';

  @override
  String get descending => 'По убыванию';
}
