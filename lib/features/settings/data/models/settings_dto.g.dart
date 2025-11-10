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
      themeMode: fields[0] as String,
      currencyCode: fields[1] as String,
      dateFormat: fields[2] as String,
      notificationsEnabled: fields[3] as bool,
      budgetAlertsEnabled: fields[4] as bool,
      billRemindersEnabled: fields[5] as bool,
      incomeRemindersEnabled: fields[6] as bool,
      budgetAlertThreshold: fields[7] as int,
      billReminderDays: fields[8] as int,
      incomeReminderDays: fields[9] as int,
      biometricEnabled: fields[10] as bool,
      autoBackupEnabled: fields[11] as bool,
      languageCode: fields[12] as String,
      isFirstTime: fields[13] as bool,
      appVersion: fields[14] as String,
      accountTypeThemes: (fields[15] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as Map).cast<String, dynamic>())),
    );
  }

  @override
  void write(BinaryWriter writer, SettingsDto obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.accountTypeThemes);
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
