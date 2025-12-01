import '../../../../core/error/result.dart';
import '../entities/notification.dart';
import '../entities/notification_analytics.dart';
import '../entities/notification_settings.dart';

/// Repository interface for notification operations
/// Defines the contract for notification data access and management
abstract class NotificationRepository {
  // ===== NOTIFICATIONS =====

  /// Get all notifications with optional filtering and pagination
  Future<Result<List<AppNotification>>> getAllNotifications({
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  /// Get notification by ID
  Future<Result<AppNotification?>> getNotificationById(String id);

  /// Save notification
  Future<Result<void>> saveNotification(AppNotification notification);

  /// Delete notification
  Future<Result<void>> deleteNotification(String id);

  /// Get unread notifications count
  Future<Result<int>> getUnreadCount();

  /// Mark notification as read
  Future<Result<void>> markAsRead(String id);

  // ===== ANALYTICS =====

  /// Get all notification analytics
  Future<Result<List<NotificationAnalytics>>> getNotificationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Save notification analytics
  Future<Result<void>> saveNotificationAnalytics(NotificationAnalytics analytics);

  // ===== SETTINGS =====

  /// Get notification settings
  Future<Result<NotificationSettings>> getNotificationSettings();

  /// Save notification settings
  Future<Result<void>> saveNotificationSettings(NotificationSettings settings);

  /// Clear all notification data
  Future<Result<void>> clearAllData();

  /// Clean up old notifications (older than specified days)
  Future<Result<int>> cleanupOldNotifications(int daysToKeep);

  /// Get notification statistics
  Future<Result<Map<String, dynamic>>> getNotificationStats();
}