import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_settings.dart';

part 'notification_settings_dto.g.dart';

/// Data Transfer Object for NotificationSettings entity
/// Used for serialization/deserialization with Hive and JSON
@HiveType(typeId: 202)
@JsonSerializable()
class NotificationSettingsDto {
  const NotificationSettingsDto({
    required this.notificationsEnabled,
    required this.budgetAlertsEnabled,
    required this.billRemindersEnabled,
    required this.incomeRemindersEnabled,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.notificationFrequency,
    required this.channelSettings,
  });

  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsDtoToJson(this);

  @HiveField(0)
  final bool notificationsEnabled;
  @HiveField(1)
  final bool budgetAlertsEnabled;
  @HiveField(2)
  final bool billRemindersEnabled;
  @HiveField(3)
  final bool incomeRemindersEnabled;
  @HiveField(4)
  final bool quietHoursEnabled;
  @HiveField(5)
  final String quietHoursStart;
  @HiveField(6)
  final String quietHoursEnd;
  @HiveField(7)
  final String notificationFrequency;
  @HiveField(8)
  final Map<String, ChannelNotificationSettingsDto> channelSettings;

  /// Convert from domain entity
  factory NotificationSettingsDto.fromDomain(NotificationSettings settings) {
    return NotificationSettingsDto(
      notificationsEnabled: settings.notificationsEnabled,
      budgetAlertsEnabled: settings.budgetAlertsEnabled,
      billRemindersEnabled: settings.billRemindersEnabled,
      incomeRemindersEnabled: settings.incomeRemindersEnabled,
      quietHoursEnabled: settings.quietHoursEnabled,
      quietHoursStart: settings.quietHoursStart,
      quietHoursEnd: settings.quietHoursEnd,
      notificationFrequency: settings.notificationFrequency,
      channelSettings: settings.channelSettings.map(
        (key, value) => MapEntry(
          key.name,
          ChannelNotificationSettingsDto.fromDomain(value),
        ),
      ),
    );
  }

  /// Convert to domain entity
  NotificationSettings toDomain() {
    return NotificationSettings(
      notificationsEnabled: notificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled,
      billRemindersEnabled: billRemindersEnabled,
      incomeRemindersEnabled: incomeRemindersEnabled,
      quietHoursEnabled: quietHoursEnabled,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
      notificationFrequency: notificationFrequency,
      channelSettings: channelSettings.map(
        (key, value) => MapEntry(
          _parseNotificationChannel(key),
          value.toDomain(),
        ),
      ),
    );
  }

  static NotificationChannel _parseNotificationChannel(String channelString) {
    return NotificationChannel.values.firstWhere(
      (e) => e.name == channelString,
      orElse: () => NotificationChannel.system,
    );
  }
}

/// DTO for ChannelNotificationSettings
@HiveType(typeId: 203)
@JsonSerializable()
class ChannelNotificationSettingsDto {
  const ChannelNotificationSettingsDto({
    required this.enabled,
    required this.frequency,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  factory ChannelNotificationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$ChannelNotificationSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelNotificationSettingsDtoToJson(this);

  @HiveField(0)
  final bool enabled;
  @HiveField(1)
  final String frequency;
  @HiveField(2)
  final bool soundEnabled;
  @HiveField(3)
  final bool vibrationEnabled;

  /// Convert from domain entity
  factory ChannelNotificationSettingsDto.fromDomain(ChannelNotificationSettings settings) {
    return ChannelNotificationSettingsDto(
      enabled: settings.enabled,
      frequency: settings.frequency,
      soundEnabled: settings.soundEnabled,
      vibrationEnabled: settings.vibrationEnabled,
    );
  }

  /// Convert to domain entity
  ChannelNotificationSettings toDomain() {
    return ChannelNotificationSettings(
      enabled: enabled,
      frequency: frequency,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );
  }
}