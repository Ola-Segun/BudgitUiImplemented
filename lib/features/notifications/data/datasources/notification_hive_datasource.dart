import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../models/notification_analytics_dto.dart';
import '../models/notification_dto.dart';
import '../models/notification_settings_dto.dart';

/// Hive-based data source for notifications
class NotificationHiveDataSource {
  static const String _notificationsBoxName = 'notifications';
  static const String _analyticsBoxName = 'notification_analytics';
  static const String _settingsBoxName = 'notification_settings';
  static const String _settingsKey = 'notification_settings';

  late Box<NotificationDto> _notificationsBox;
  late Box<NotificationAnalyticsDto> _analyticsBox;
  late Box<NotificationSettingsDto> _settingsBox;

  /// Initialize the data source
  Future<void> init() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(200)) {
      Hive.registerAdapter(NotificationDtoAdapter());
    }
    if (!Hive.isAdapterRegistered(201)) {
      Hive.registerAdapter(NotificationAnalyticsDtoAdapter());
    }
    if (!Hive.isAdapterRegistered(202)) {
      Hive.registerAdapter(NotificationSettingsDtoAdapter());
    }
    if (!Hive.isAdapterRegistered(203)) {
      Hive.registerAdapter(ChannelNotificationSettingsDtoAdapter());
    }

    _notificationsBox = await Hive.openBox<NotificationDto>(_notificationsBoxName);
    _analyticsBox = await Hive.openBox<NotificationAnalyticsDto>(_analyticsBoxName);
    _settingsBox = await Hive.openBox<NotificationSettingsDto>(_settingsBoxName);
  }

  // ===== NOTIFICATIONS =====

  /// Get all notifications with optional filtering
  Future<Result<List<NotificationDto>>> getAllNotifications({
    String? type,
    String? priority,
    bool? isRead,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      var notifications = _notificationsBox.values.toList();

      // Apply filters
      if (type != null) {
        notifications = notifications.where((n) => n.type == type).toList();
      }
      if (priority != null) {
        notifications = notifications.where((n) => n.priority == priority).toList();
      }
      if (isRead != null) {
        notifications = notifications.where((n) => n.isRead == isRead).toList();
      }
      if (startDate != null) {
        notifications = notifications.where((n) => n.createdAt.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        notifications = notifications.where((n) => n.createdAt.isBefore(endDate)).toList();
      }

      // Sort by created date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply pagination
      if (offset != null && offset > 0) {
        notifications = notifications.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        notifications = notifications.take(limit).toList();
      }

      return Result.success(notifications);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get notifications: $e'));
    }
  }

  /// Get notification by ID
  Future<Result<NotificationDto?>> getNotificationById(String id) async {
    try {
      final notification = _notificationsBox.get(id);
      return Result.success(notification);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get notification: $e'));
    }
  }

  /// Save notification
  Future<Result<void>> saveNotification(NotificationDto notification) async {
    try {
      await _notificationsBox.put(notification.id, notification);
      return const Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to save notification: $e'));
    }
  }

  /// Delete notification
  Future<Result<void>> deleteNotification(String id) async {
    try {
      await _notificationsBox.delete(id);
      return const Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to delete notification: $e'));
    }
  }

  /// Get unread notifications count
  Future<Result<int>> getUnreadCount() async {
    try {
      final unreadCount = _notificationsBox.values
          .where((notification) => notification.isRead != true)
          .length;
      return Result.success(unreadCount);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get unread count: $e'));
    }
  }

  /// Mark notification as read
  Future<Result<void>> markAsRead(String id) async {
    try {
      final notification = _notificationsBox.get(id);
      if (notification != null) {
        final updatedNotification = NotificationDto(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          priority: notification.priority,
          createdAt: notification.createdAt,
          scheduledFor: notification.scheduledFor,
          isRead: true,
          actionUrl: notification.actionUrl,
          metadata: notification.metadata,
        );
        await _notificationsBox.put(id, updatedNotification);
      }
      return const Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to mark notification as read: $e'));
    }
  }

  // ===== ANALYTICS =====

  /// Get all notification analytics
  Future<Result<List<NotificationAnalyticsDto>>> getAllAnalytics() async {
    try {
      final analytics = _analyticsBox.values.toList();
      return Result.success(analytics);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get analytics: $e'));
    }
  }

  /// Get analytics by date range
  Future<Result<List<NotificationAnalyticsDto>>> getAnalyticsByDateRange(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final analytics = _analyticsBox.values.where((analytic) {
        if (startDate != null && analytic.sentAt.isBefore(startDate)) return false;
        if (endDate != null && analytic.sentAt.isAfter(endDate)) return false;
        return true;
      }).toList();
      return Result.success(analytics);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get analytics by date range: $e'));
    }
  }

  /// Save notification analytics
  Future<Result<void>> saveAnalytics(NotificationAnalyticsDto analytics) async {
    try {
      await _analyticsBox.put(analytics.id, analytics);
      return const Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to save analytics: $e'));
    }
  }

  // ===== SETTINGS =====

  /// Get notification settings
  Future<Result<NotificationSettingsDto>> getSettings() async {
    try {
      final settings = _settingsBox.get(_settingsKey);
      if (settings != null) {
        return Result.success(settings);
      } else {
        // Return default settings if none exist
        final defaultSettings = _createDefaultSettings();
        await _settingsBox.put(_settingsKey, defaultSettings);
        return Result.success(defaultSettings);
      }
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get notification settings: $e'));
    }
  }

  /// Save notification settings
  Future<Result<void>> saveSettings(NotificationSettingsDto settings) async {
    try {
      await _settingsBox.put(_settingsKey, settings);
      return const Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to save notification settings: $e'));
    }
  }

  /// Clear all notification data
  Future<Result<void>> clearAllData() async {
    try {
      await _notificationsBox.clear();
      await _analyticsBox.clear();
      await _settingsBox.clear();
      return const Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to clear notification data: $e'));
    }
  }

  /// Cleanup old notifications
  Future<Result<int>> cleanupOldNotifications(DateTime cutoffDate) async {
    try {
      final notificationsToDelete = _notificationsBox.values
          .where((notification) => notification.createdAt.isBefore(cutoffDate))
          .map((notification) => notification.id)
          .toList();

      for (final id in notificationsToDelete) {
        await _notificationsBox.delete(id);
      }

      return Result.success(notificationsToDelete.length);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to cleanup old notifications: $e'));
    }
  }

  /// Get notification statistics
  Future<Result<Map<String, dynamic>>> getNotificationStats() async {
    try {
      final notifications = _notificationsBox.values.toList();
      final analytics = _analyticsBox.values.toList();

      final totalNotifications = notifications.length;
      final unreadCount = notifications.where((n) => n.isRead != true).length;
      final readCount = totalNotifications - unreadCount;

      final typeStats = <String, int>{};
      for (final notification in notifications) {
        typeStats[notification.type] = (typeStats[notification.type] ?? 0) + 1;
      }

      final priorityStats = <String, int>{};
      for (final notification in notifications) {
        priorityStats[notification.priority] = (priorityStats[notification.priority] ?? 0) + 1;
      }

      final totalAnalytics = analytics.length;
      final readAnalytics = analytics.where((a) => a.readAt != null).length;
      final clickedAnalytics = analytics.where((a) => a.clickedAt != null).length;

      return Result.success({
        'totalNotifications': totalNotifications,
        'unreadCount': unreadCount,
        'readCount': readCount,
        'typeStats': typeStats,
        'priorityStats': priorityStats,
        'totalAnalytics': totalAnalytics,
        'readAnalytics': readAnalytics,
        'clickedAnalytics': clickedAnalytics,
      });
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get notification stats: $e'));
    }
  }

  /// Create default notification settings
  NotificationSettingsDto _createDefaultSettings() {
    return NotificationSettingsDto(
      notificationsEnabled: true,
      budgetAlertsEnabled: true,
      billRemindersEnabled: true,
      incomeRemindersEnabled: true,
      quietHoursEnabled: false,
      quietHoursStart: '22:00',
      quietHoursEnd: '08:00',
      notificationFrequency: 'immediate',
      channelSettings: {
        'budget': ChannelNotificationSettingsDto(
          enabled: true,
          frequency: 'immediate',
          soundEnabled: true,
          vibrationEnabled: true,
        ),
        'bills': ChannelNotificationSettingsDto(
          enabled: true,
          frequency: 'immediate',
          soundEnabled: true,
          vibrationEnabled: true,
        ),
        'goals': ChannelNotificationSettingsDto(
          enabled: true,
          frequency: 'immediate',
          soundEnabled: true,
          vibrationEnabled: true,
        ),
        'accounts': ChannelNotificationSettingsDto(
          enabled: true,
          frequency: 'immediate',
          soundEnabled: true,
          vibrationEnabled: true,
        ),
        'system': ChannelNotificationSettingsDto(
          enabled: true,
          frequency: 'immediate',
          soundEnabled: true,
          vibrationEnabled: true,
        ),
      },
    );
  }
}