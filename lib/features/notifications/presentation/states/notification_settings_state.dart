import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_settings.dart';

part 'notification_settings_state.freezed.dart';

@freezed
class NotificationSettingsState with _$NotificationSettingsState {
  const factory NotificationSettingsState({
    required NotificationSettings settings,
    required bool isLoading,
    String? errorMessage,
  }) = _NotificationSettingsState;

  const NotificationSettingsState._();

  factory NotificationSettingsState.initial() => NotificationSettingsState(
        settings: NotificationSettings(
          notificationsEnabled: true,
          budgetAlertsEnabled: true,
          billRemindersEnabled: true,
          incomeRemindersEnabled: true,
          quietHoursEnabled: false,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
          notificationFrequency: 'immediate',
          channelSettings: {
            NotificationChannel.budget: ChannelNotificationSettings(
              enabled: true,
              frequency: 'immediate',
              soundEnabled: true,
              vibrationEnabled: true,
            ),
            NotificationChannel.bills: ChannelNotificationSettings(
              enabled: true,
              frequency: 'immediate',
              soundEnabled: true,
              vibrationEnabled: true,
            ),
            NotificationChannel.goals: ChannelNotificationSettings(
              enabled: true,
              frequency: 'immediate',
              soundEnabled: true,
              vibrationEnabled: true,
            ),
            NotificationChannel.accounts: ChannelNotificationSettings(
              enabled: true,
              frequency: 'immediate',
              soundEnabled: true,
              vibrationEnabled: true,
            ),
            NotificationChannel.system: ChannelNotificationSettings(
              enabled: true,
              frequency: 'immediate',
              soundEnabled: false,
              vibrationEnabled: false,
            ),
          },
        ),
        isLoading: false,
      );
}