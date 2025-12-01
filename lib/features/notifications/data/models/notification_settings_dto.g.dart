// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsDtoAdapter
    extends TypeAdapter<NotificationSettingsDto> {
  @override
  final int typeId = 202;

  @override
  NotificationSettingsDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettingsDto(
      notificationsEnabled: fields[0] as bool,
      budgetAlertsEnabled: fields[1] as bool,
      billRemindersEnabled: fields[2] as bool,
      incomeRemindersEnabled: fields[3] as bool,
      quietHoursEnabled: fields[4] as bool,
      quietHoursStart: fields[5] as String,
      quietHoursEnd: fields[6] as String,
      notificationFrequency: fields[7] as String,
      channelSettings:
          (fields[8] as Map).cast<String, ChannelNotificationSettingsDto>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettingsDto obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.notificationsEnabled)
      ..writeByte(1)
      ..write(obj.budgetAlertsEnabled)
      ..writeByte(2)
      ..write(obj.billRemindersEnabled)
      ..writeByte(3)
      ..write(obj.incomeRemindersEnabled)
      ..writeByte(4)
      ..write(obj.quietHoursEnabled)
      ..writeByte(5)
      ..write(obj.quietHoursStart)
      ..writeByte(6)
      ..write(obj.quietHoursEnd)
      ..writeByte(7)
      ..write(obj.notificationFrequency)
      ..writeByte(8)
      ..write(obj.channelSettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChannelNotificationSettingsDtoAdapter
    extends TypeAdapter<ChannelNotificationSettingsDto> {
  @override
  final int typeId = 203;

  @override
  ChannelNotificationSettingsDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChannelNotificationSettingsDto(
      enabled: fields[0] as bool,
      frequency: fields[1] as String,
      soundEnabled: fields[2] as bool,
      vibrationEnabled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChannelNotificationSettingsDto obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.enabled)
      ..writeByte(1)
      ..write(obj.frequency)
      ..writeByte(2)
      ..write(obj.soundEnabled)
      ..writeByte(3)
      ..write(obj.vibrationEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelNotificationSettingsDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSettingsDto _$NotificationSettingsDtoFromJson(
        Map<String, dynamic> json) =>
    NotificationSettingsDto(
      notificationsEnabled: json['notificationsEnabled'] as bool,
      budgetAlertsEnabled: json['budgetAlertsEnabled'] as bool,
      billRemindersEnabled: json['billRemindersEnabled'] as bool,
      incomeRemindersEnabled: json['incomeRemindersEnabled'] as bool,
      quietHoursEnabled: json['quietHoursEnabled'] as bool,
      quietHoursStart: json['quietHoursStart'] as String,
      quietHoursEnd: json['quietHoursEnd'] as String,
      notificationFrequency: json['notificationFrequency'] as String,
      channelSettings: (json['channelSettings'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k,
            ChannelNotificationSettingsDto.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$NotificationSettingsDtoToJson(
        NotificationSettingsDto instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'budgetAlertsEnabled': instance.budgetAlertsEnabled,
      'billRemindersEnabled': instance.billRemindersEnabled,
      'incomeRemindersEnabled': instance.incomeRemindersEnabled,
      'quietHoursEnabled': instance.quietHoursEnabled,
      'quietHoursStart': instance.quietHoursStart,
      'quietHoursEnd': instance.quietHoursEnd,
      'notificationFrequency': instance.notificationFrequency,
      'channelSettings': instance.channelSettings,
    };

ChannelNotificationSettingsDto _$ChannelNotificationSettingsDtoFromJson(
        Map<String, dynamic> json) =>
    ChannelNotificationSettingsDto(
      enabled: json['enabled'] as bool,
      frequency: json['frequency'] as String,
      soundEnabled: json['soundEnabled'] as bool,
      vibrationEnabled: json['vibrationEnabled'] as bool,
    );

Map<String, dynamic> _$ChannelNotificationSettingsDtoToJson(
        ChannelNotificationSettingsDto instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'frequency': instance.frequency,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
    };
