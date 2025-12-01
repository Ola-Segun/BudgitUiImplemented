import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_analytics.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_hive_datasource.dart';
import '../models/notification_analytics_dto.dart';
import '../models/notification_dto.dart';
import '../models/notification_settings_dto.dart';

/// Implementation of NotificationRepository using Hive data source
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationHiveDataSource _dataSource;

  NotificationRepositoryImpl(this._dataSource);

  // ===== NOTIFICATIONS =====

  @override
  Future<Result<List<AppNotification>>> getAllNotifications({
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await _dataSource.getAllNotifications(
        type: type?.name,
        priority: priority?.name,
        isRead: isRead,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
      return result.map((dtos) => dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get notifications: $e'));
    }
  }

  @override
  Future<Result<AppNotification?>> getNotificationById(String id) async {
    try {
      final result = await _dataSource.getNotificationById(id);
      return result.map((dto) => dto?.toDomain());
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get notification: $e'));
    }
  }

  @override
  Future<Result<void>> saveNotification(AppNotification notification) async {
    try {
      final dto = NotificationDto.fromDomain(notification);
      return await _dataSource.saveNotification(dto);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to save notification: $e'));
    }
  }

  @override
  Future<Result<void>> deleteNotification(String id) async {
    return await _dataSource.deleteNotification(id);
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    return await _dataSource.getUnreadCount();
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    return await _dataSource.markAsRead(id);
  }

  // ===== ANALYTICS =====

  @override
  Future<Result<List<NotificationAnalytics>>> getNotificationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _dataSource.getAnalyticsByDateRange(startDate, endDate);
      return result.map((dtos) => dtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get analytics: $e'));
    }
  }

  @override
  Future<Result<void>> saveNotificationAnalytics(NotificationAnalytics analytics) async {
    try {
      final dto = NotificationAnalyticsDto.fromDomain(analytics);
      return await _dataSource.saveAnalytics(dto);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to save analytics: $e'));
    }
  }

  // ===== SETTINGS =====

  @override
  Future<Result<NotificationSettings>> getNotificationSettings() async {
    try {
      final result = await _dataSource.getSettings();
      return result.map((dto) => dto.toDomain());
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get notification settings: $e'));
    }
  }

  @override
  Future<Result<void>> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final dto = NotificationSettingsDto.fromDomain(settings);
      return await _dataSource.saveSettings(dto);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to save notification settings: $e'));
    }
  }

  // ===== UTILITY =====

  @override
  Future<Result<void>> clearAllData() async {
    return await _dataSource.clearAllData();
  }

  @override
  Future<Result<int>> cleanupOldNotifications(int daysToKeep) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final result = await _dataSource.cleanupOldNotifications(cutoffDate);
      return result;
    } catch (e) {
      return Result.error(Failure.unknown('Failed to cleanup old notifications: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getNotificationStats() async {
    try {
      final result = await _dataSource.getNotificationStats();
      return result;
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get notification stats: $e'));
    }
  }
}