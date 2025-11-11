// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsDtoAdapter extends TypeAdapter<SettingsDto> {
  @override
  final int typeId = 100;

  @override
  SettingsDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsDto(
      themeMode: fields[0] as String? ?? 'system',
      currencyCode: fields[1] as String? ?? '',
      dateFormat: fields[2] as String? ?? 'MM/dd/yyyy',
      notificationsEnabled: fields[3] as bool? ?? true,
      budgetAlertsEnabled: fields[4] as bool? ?? true,
      billRemindersEnabled: fields[5] as bool? ?? true,
      incomeRemindersEnabled: fields[6] as bool? ?? true,
      budgetAlertThreshold: fields[7] as int? ?? 80,
      billReminderDays: fields[8] as int? ?? 3,
      incomeReminderDays: fields[9] as int? ?? 1,
      biometricEnabled: fields[10] as bool? ?? false,
      autoBackupEnabled: fields[11] as bool? ?? false,
      languageCode: fields[12] as String? ?? 'en',
      isFirstTime: fields[13] as bool? ?? true,
      appVersion: fields[14] as String? ?? '1.0.0',
      accountTypeThemes: (fields[15] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as Map).cast<String, dynamic>())) ?? {},
      privacyModeEnabled: fields[16] as bool? ?? false,
      privacyModeGestureEnabled: fields[17] as bool? ?? true,
      twoFactorEnabled: fields[18] as bool? ?? false,
      twoFactorMethod: fields[19] as String? ?? '',
      backupCodes: (fields[20] as List?)?.cast<String>() ?? [],
      activityLoggingEnabled: fields[21] as bool? ?? true,
      quietHoursEnabled: fields[22] as bool? ?? false,
      quietHoursStart: fields[23] as String? ?? '22:00',
      quietHoursEnd: fields[24] as String? ?? '08:00',
      notificationFrequency: fields[25] as String? ?? 'immediate',
      defaultExportFormat: fields[26] as String? ?? 'csv',
      scheduledExportEnabled: fields[27] as bool? ?? false,
      scheduledExportFrequency: fields[28] as String? ?? 'monthly',
    );
  }

  @override
  void write(BinaryWriter writer, SettingsDto obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.currencyCode)
      ..writeByte(2)
      ..write(obj.dateFormat)
      ..writeByte(3)
      ..write(obj.notificationsEnabled)
      ..writeByte(4)
      ..write(obj.budgetAlertsEnabled)
      ..writeByte(5)
      ..write(obj.billRemindersEnabled)
      ..writeByte(6)
      ..write(obj.incomeRemindersEnabled)
      ..writeByte(7)
      ..write(obj.budgetAlertThreshold)
      ..writeByte(8)
      ..write(obj.billReminderDays)
      ..writeByte(9)
      ..write(obj.incomeReminderDays)
      ..writeByte(10)
      ..write(obj.biometricEnabled)
      ..writeByte(11)
      ..write(obj.autoBackupEnabled)
      ..writeByte(12)
      ..write(obj.languageCode)
      ..writeByte(13)
      ..write(obj.isFirstTime)
      ..writeByte(14)
      ..write(obj.appVersion)
      ..writeByte(15)
      ..write(obj.accountTypeThemes)
      ..writeByte(16)
      ..write(obj.privacyModeEnabled)
      ..writeByte(17)
      ..write(obj.privacyModeGestureEnabled)
      ..writeByte(18)
      ..write(obj.twoFactorEnabled)
      ..writeByte(19)
      ..write(obj.twoFactorMethod)
      ..writeByte(20)
      ..write(obj.backupCodes)
      ..writeByte(21)
      ..write(obj.activityLoggingEnabled)
      ..writeByte(22)
      ..write(obj.quietHoursEnabled)
      ..writeByte(23)
      ..write(obj.quietHoursStart)
      ..writeByte(24)
      ..write(obj.quietHoursEnd)
      ..writeByte(25)
      ..write(obj.notificationFrequency)
      ..writeByte(26)
      ..write(obj.defaultExportFormat)
      ..writeByte(27)
      ..write(obj.scheduledExportEnabled)
      ..writeByte(28)
      ..write(obj.scheduledExportFrequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
