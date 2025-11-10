// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppSettings {
  /// Theme mode preference
  ThemeMode get themeMode => throw _privateConstructorUsedError;

  /// Currency code (e.g., 'USD', 'EUR', 'NGN') - null means use system default
  String? get currencyCode => throw _privateConstructorUsedError;

  /// Date format preference
  String get dateFormat => throw _privateConstructorUsedError;

  /// Enable/disable notifications
  bool get notificationsEnabled => throw _privateConstructorUsedError;

  /// Enable/disable budget alerts
  bool get budgetAlertsEnabled => throw _privateConstructorUsedError;

  /// Enable/disable bill reminders
  bool get billRemindersEnabled => throw _privateConstructorUsedError;

  /// Enable/disable income reminders
  bool get incomeRemindersEnabled => throw _privateConstructorUsedError;

  /// Budget alert threshold percentage (0-100)
  int get budgetAlertThreshold => throw _privateConstructorUsedError;

  /// Days before bill due date to show reminder
  int get billReminderDays => throw _privateConstructorUsedError;

  /// Days before income expected to show reminder
  int get incomeReminderDays => throw _privateConstructorUsedError;

  /// Enable/disable biometric authentication
  bool get biometricEnabled => throw _privateConstructorUsedError;

  /// Enable/disable data backup
  bool get autoBackupEnabled => throw _privateConstructorUsedError;

  /// App language/locale
  String get languageCode => throw _privateConstructorUsedError;

  /// First time user flag
  bool get isFirstTime => throw _privateConstructorUsedError;

  /// App version (for display purposes)
  String get appVersion => throw _privateConstructorUsedError;

  /// Custom account type themes
  Map<String, AccountTypeTheme> get accountTypeThemes =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) then) =
      _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call(
      {ThemeMode themeMode,
      String? currencyCode,
      String dateFormat,
      bool notificationsEnabled,
      bool budgetAlertsEnabled,
      bool billRemindersEnabled,
      bool incomeRemindersEnabled,
      int budgetAlertThreshold,
      int billReminderDays,
      int incomeReminderDays,
      bool biometricEnabled,
      bool autoBackupEnabled,
      String languageCode,
      bool isFirstTime,
      String appVersion,
      Map<String, AccountTypeTheme> accountTypeThemes});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? currencyCode = freezed,
    Object? dateFormat = null,
    Object? notificationsEnabled = null,
    Object? budgetAlertsEnabled = null,
    Object? billRemindersEnabled = null,
    Object? incomeRemindersEnabled = null,
    Object? budgetAlertThreshold = null,
    Object? billReminderDays = null,
    Object? incomeReminderDays = null,
    Object? biometricEnabled = null,
    Object? autoBackupEnabled = null,
    Object? languageCode = null,
    Object? isFirstTime = null,
    Object? appVersion = null,
    Object? accountTypeThemes = null,
  }) {
    return _then(_value.copyWith(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      dateFormat: null == dateFormat
          ? _value.dateFormat
          : dateFormat // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      budgetAlertsEnabled: null == budgetAlertsEnabled
          ? _value.budgetAlertsEnabled
          : budgetAlertsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      billRemindersEnabled: null == billRemindersEnabled
          ? _value.billRemindersEnabled
          : billRemindersEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      incomeRemindersEnabled: null == incomeRemindersEnabled
          ? _value.incomeRemindersEnabled
          : incomeRemindersEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      budgetAlertThreshold: null == budgetAlertThreshold
          ? _value.budgetAlertThreshold
          : budgetAlertThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      billReminderDays: null == billReminderDays
          ? _value.billReminderDays
          : billReminderDays // ignore: cast_nullable_to_non_nullable
              as int,
      incomeReminderDays: null == incomeReminderDays
          ? _value.incomeReminderDays
          : incomeReminderDays // ignore: cast_nullable_to_non_nullable
              as int,
      biometricEnabled: null == biometricEnabled
          ? _value.biometricEnabled
          : biometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoBackupEnabled: null == autoBackupEnabled
          ? _value.autoBackupEnabled
          : autoBackupEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      isFirstTime: null == isFirstTime
          ? _value.isFirstTime
          : isFirstTime // ignore: cast_nullable_to_non_nullable
              as bool,
      appVersion: null == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String,
      accountTypeThemes: null == accountTypeThemes
          ? _value.accountTypeThemes
          : accountTypeThemes // ignore: cast_nullable_to_non_nullable
              as Map<String, AccountTypeTheme>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
          _$AppSettingsImpl value, $Res Function(_$AppSettingsImpl) then) =
      __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ThemeMode themeMode,
      String? currencyCode,
      String dateFormat,
      bool notificationsEnabled,
      bool budgetAlertsEnabled,
      bool billRemindersEnabled,
      bool incomeRemindersEnabled,
      int budgetAlertThreshold,
      int billReminderDays,
      int incomeReminderDays,
      bool biometricEnabled,
      bool autoBackupEnabled,
      String languageCode,
      bool isFirstTime,
      String appVersion,
      Map<String, AccountTypeTheme> accountTypeThemes});
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
      _$AppSettingsImpl _value, $Res Function(_$AppSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? currencyCode = freezed,
    Object? dateFormat = null,
    Object? notificationsEnabled = null,
    Object? budgetAlertsEnabled = null,
    Object? billRemindersEnabled = null,
    Object? incomeRemindersEnabled = null,
    Object? budgetAlertThreshold = null,
    Object? billReminderDays = null,
    Object? incomeReminderDays = null,
    Object? biometricEnabled = null,
    Object? autoBackupEnabled = null,
    Object? languageCode = null,
    Object? isFirstTime = null,
    Object? appVersion = null,
    Object? accountTypeThemes = null,
  }) {
    return _then(_$AppSettingsImpl(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      dateFormat: null == dateFormat
          ? _value.dateFormat
          : dateFormat // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      budgetAlertsEnabled: null == budgetAlertsEnabled
          ? _value.budgetAlertsEnabled
          : budgetAlertsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      billRemindersEnabled: null == billRemindersEnabled
          ? _value.billRemindersEnabled
          : billRemindersEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      incomeRemindersEnabled: null == incomeRemindersEnabled
          ? _value.incomeRemindersEnabled
          : incomeRemindersEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      budgetAlertThreshold: null == budgetAlertThreshold
          ? _value.budgetAlertThreshold
          : budgetAlertThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      billReminderDays: null == billReminderDays
          ? _value.billReminderDays
          : billReminderDays // ignore: cast_nullable_to_non_nullable
              as int,
      incomeReminderDays: null == incomeReminderDays
          ? _value.incomeReminderDays
          : incomeReminderDays // ignore: cast_nullable_to_non_nullable
              as int,
      biometricEnabled: null == biometricEnabled
          ? _value.biometricEnabled
          : biometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoBackupEnabled: null == autoBackupEnabled
          ? _value.autoBackupEnabled
          : autoBackupEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      isFirstTime: null == isFirstTime
          ? _value.isFirstTime
          : isFirstTime // ignore: cast_nullable_to_non_nullable
              as bool,
      appVersion: null == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String,
      accountTypeThemes: null == accountTypeThemes
          ? _value._accountTypeThemes
          : accountTypeThemes // ignore: cast_nullable_to_non_nullable
              as Map<String, AccountTypeTheme>,
    ));
  }
}

/// @nodoc

class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl(
      {required this.themeMode,
      this.currencyCode,
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
      final Map<String, AccountTypeTheme> accountTypeThemes = const {}})
      : _accountTypeThemes = accountTypeThemes;

  /// Theme mode preference
  @override
  final ThemeMode themeMode;

  /// Currency code (e.g., 'USD', 'EUR', 'NGN') - null means use system default
  @override
  final String? currencyCode;

  /// Date format preference
  @override
  final String dateFormat;

  /// Enable/disable notifications
  @override
  final bool notificationsEnabled;

  /// Enable/disable budget alerts
  @override
  final bool budgetAlertsEnabled;

  /// Enable/disable bill reminders
  @override
  final bool billRemindersEnabled;

  /// Enable/disable income reminders
  @override
  final bool incomeRemindersEnabled;

  /// Budget alert threshold percentage (0-100)
  @override
  final int budgetAlertThreshold;

  /// Days before bill due date to show reminder
  @override
  final int billReminderDays;

  /// Days before income expected to show reminder
  @override
  final int incomeReminderDays;

  /// Enable/disable biometric authentication
  @override
  final bool biometricEnabled;

  /// Enable/disable data backup
  @override
  final bool autoBackupEnabled;

  /// App language/locale
  @override
  final String languageCode;

  /// First time user flag
  @override
  final bool isFirstTime;

  /// App version (for display purposes)
  @override
  final String appVersion;

  /// Custom account type themes
  final Map<String, AccountTypeTheme> _accountTypeThemes;

  /// Custom account type themes
  @override
  @JsonKey()
  Map<String, AccountTypeTheme> get accountTypeThemes {
    if (_accountTypeThemes is EqualUnmodifiableMapView)
      return _accountTypeThemes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_accountTypeThemes);
  }

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, currencyCode: $currencyCode, dateFormat: $dateFormat, notificationsEnabled: $notificationsEnabled, budgetAlertsEnabled: $budgetAlertsEnabled, billRemindersEnabled: $billRemindersEnabled, incomeRemindersEnabled: $incomeRemindersEnabled, budgetAlertThreshold: $budgetAlertThreshold, billReminderDays: $billReminderDays, incomeReminderDays: $incomeReminderDays, biometricEnabled: $biometricEnabled, autoBackupEnabled: $autoBackupEnabled, languageCode: $languageCode, isFirstTime: $isFirstTime, appVersion: $appVersion, accountTypeThemes: $accountTypeThemes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.dateFormat, dateFormat) ||
                other.dateFormat == dateFormat) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.budgetAlertsEnabled, budgetAlertsEnabled) ||
                other.budgetAlertsEnabled == budgetAlertsEnabled) &&
            (identical(other.billRemindersEnabled, billRemindersEnabled) ||
                other.billRemindersEnabled == billRemindersEnabled) &&
            (identical(other.incomeRemindersEnabled, incomeRemindersEnabled) ||
                other.incomeRemindersEnabled == incomeRemindersEnabled) &&
            (identical(other.budgetAlertThreshold, budgetAlertThreshold) ||
                other.budgetAlertThreshold == budgetAlertThreshold) &&
            (identical(other.billReminderDays, billReminderDays) ||
                other.billReminderDays == billReminderDays) &&
            (identical(other.incomeReminderDays, incomeReminderDays) ||
                other.incomeReminderDays == incomeReminderDays) &&
            (identical(other.biometricEnabled, biometricEnabled) ||
                other.biometricEnabled == biometricEnabled) &&
            (identical(other.autoBackupEnabled, autoBackupEnabled) ||
                other.autoBackupEnabled == autoBackupEnabled) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.isFirstTime, isFirstTime) ||
                other.isFirstTime == isFirstTime) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            const DeepCollectionEquality()
                .equals(other._accountTypeThemes, _accountTypeThemes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      themeMode,
      currencyCode,
      dateFormat,
      notificationsEnabled,
      budgetAlertsEnabled,
      billRemindersEnabled,
      incomeRemindersEnabled,
      budgetAlertThreshold,
      billReminderDays,
      incomeReminderDays,
      biometricEnabled,
      autoBackupEnabled,
      languageCode,
      isFirstTime,
      appVersion,
      const DeepCollectionEquality().hash(_accountTypeThemes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings(
          {required final ThemeMode themeMode,
          final String? currencyCode,
          required final String dateFormat,
          required final bool notificationsEnabled,
          required final bool budgetAlertsEnabled,
          required final bool billRemindersEnabled,
          required final bool incomeRemindersEnabled,
          required final int budgetAlertThreshold,
          required final int billReminderDays,
          required final int incomeReminderDays,
          required final bool biometricEnabled,
          required final bool autoBackupEnabled,
          required final String languageCode,
          required final bool isFirstTime,
          required final String appVersion,
          final Map<String, AccountTypeTheme> accountTypeThemes}) =
      _$AppSettingsImpl;

  @override

  /// Theme mode preference
  ThemeMode get themeMode;
  @override

  /// Currency code (e.g., 'USD', 'EUR', 'NGN') - null means use system default
  String? get currencyCode;
  @override

  /// Date format preference
  String get dateFormat;
  @override

  /// Enable/disable notifications
  bool get notificationsEnabled;
  @override

  /// Enable/disable budget alerts
  bool get budgetAlertsEnabled;
  @override

  /// Enable/disable bill reminders
  bool get billRemindersEnabled;
  @override

  /// Enable/disable income reminders
  bool get incomeRemindersEnabled;
  @override

  /// Budget alert threshold percentage (0-100)
  int get budgetAlertThreshold;
  @override

  /// Days before bill due date to show reminder
  int get billReminderDays;
  @override

  /// Days before income expected to show reminder
  int get incomeReminderDays;
  @override

  /// Enable/disable biometric authentication
  bool get biometricEnabled;
  @override

  /// Enable/disable data backup
  bool get autoBackupEnabled;
  @override

  /// App language/locale
  String get languageCode;
  @override

  /// First time user flag
  bool get isFirstTime;
  @override

  /// App version (for display purposes)
  String get appVersion;
  @override

  /// Custom account type themes
  Map<String, AccountTypeTheme> get accountTypeThemes;
  @override
  @JsonKey(ignore: true)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
