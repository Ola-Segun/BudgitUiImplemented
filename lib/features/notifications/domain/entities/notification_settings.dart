import 'package:flutter/material.dart';
import 'notification.dart';

/// Settings for notification behavior
class NotificationSettings {
  const NotificationSettings({
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

  final bool notificationsEnabled;
  final bool budgetAlertsEnabled;
  final bool billRemindersEnabled;
  final bool incomeRemindersEnabled;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final String notificationFrequency;
  final Map<NotificationChannel, ChannelNotificationSettings> channelSettings;

  /// Check if current time is within quiet hours
  bool get isInQuietHours {
    if (!quietHoursEnabled) return false;

    final now = DateTime.now();
    final startTime = _parseTime(quietHoursStart);
    final endTime = _parseTime(quietHoursEnd);

    if (startTime == null || endTime == null) return false;

    final currentTime = TimeOfDay.fromDateTime(now);
    return _isTimeInRange(currentTime, startTime, endTime);
  }

  /// Check if notification should be sent based on frequency setting
  bool shouldSendNotification(NotificationType type) {
    if (!notificationsEnabled) return false;

    // Check channel-specific settings first
    final channel = _getChannelForType(type);
    final channelSettings = this.channelSettings[channel];
    if (channelSettings != null && !channelSettings.shouldSendNotification()) {
      return false;
    }

    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return budgetAlertsEnabled;
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return billRemindersEnabled;
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return true; // Always enabled for these types
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return incomeRemindersEnabled;
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return true; // System notifications are always enabled
      case NotificationType.custom:
        return true; // Custom notifications respect global setting
    }
  }

  /// Get notification delay based on frequency setting
  Duration? getNotificationDelay() {
    if (notificationFrequency == 'immediate') return null;

    switch (notificationFrequency) {
      case 'hourly':
        return const Duration(hours: 1);
      case 'daily':
        return const Duration(days: 1);
      case 'weekly':
        return const Duration(days: 7);
      default:
        return null;
    }
  }

  NotificationChannel _getChannelForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return NotificationChannel.budget;
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return NotificationChannel.bills;
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return NotificationChannel.goals;
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
        return NotificationChannel.accounts;
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return NotificationChannel.accounts; // Transaction alerts go to accounts
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return NotificationChannel.bills; // Income reminders are bill-related
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return NotificationChannel.system;
      case NotificationType.custom:
        return NotificationChannel.system; // Custom notifications go to system
    }
  }

  TimeOfDay? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Handle parsing error
    }
    return null;
  }

  bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      // Same day range
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight range
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  /// Create a copy of this NotificationSettings with modified fields
  NotificationSettings copyWith({
    bool? notificationsEnabled,
    bool? budgetAlertsEnabled,
    bool? billRemindersEnabled,
    bool? incomeRemindersEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? notificationFrequency,
    Map<NotificationChannel, ChannelNotificationSettings>? channelSettings,
  }) {
    return NotificationSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      billRemindersEnabled: billRemindersEnabled ?? this.billRemindersEnabled,
      incomeRemindersEnabled: incomeRemindersEnabled ?? this.incomeRemindersEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
      channelSettings: channelSettings ?? this.channelSettings,
    );
  }
}

/// Channel-specific notification settings
class ChannelNotificationSettings {
  const ChannelNotificationSettings({
    required this.enabled,
    required this.frequency,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  final bool enabled;
  final String frequency; // 'immediate', 'hourly', 'daily', 'weekly'
  final bool soundEnabled;
  final bool vibrationEnabled;

  /// Check if notification should be sent based on channel settings
  bool shouldSendNotification() {
    return enabled;
  }

  /// Get notification delay for this channel
  Duration? getNotificationDelay() {
    if (frequency == 'immediate') return null;

    switch (frequency) {
      case 'hourly':
        return const Duration(hours: 1);
      case 'daily':
        return const Duration(days: 1);
      case 'weekly':
        return const Duration(days: 7);
      default:
        return null;
    }
  }

  /// Create a copy of this ChannelNotificationSettings with modified fields
  ChannelNotificationSettings copyWith({
    bool? enabled,
    String? frequency,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return ChannelNotificationSettings(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}