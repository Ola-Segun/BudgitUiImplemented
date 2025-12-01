import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/notification.dart';
import '../entities/notification_analytics.dart';
import '../repositories/notification_repository.dart';

/// Use case for tracking notification analytics
class TrackNotificationAnalytics {
  const TrackNotificationAnalytics(
    this._notificationRepository,
  );

  final NotificationRepository _notificationRepository;

  /// Track notification analytics (read, clicked, etc.)
  Future<Result<void>> call({
    required String notificationId,
    DateTime? readAt,
    DateTime? clickedAt,
    String? actionTaken,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final analytics = NotificationAnalytics(
        id: 'analytics_${notificationId}_${DateTime.now().millisecondsSinceEpoch}',
        notificationId: notificationId,
        sentAt: DateTime.now(), // This should be the original sent time, but for simplicity
        readAt: readAt,
        clickedAt: clickedAt,
        actionTaken: actionTaken,
        metadata: metadata,
      );

      return await _notificationRepository.saveNotificationAnalytics(analytics);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to track notification analytics: $e'));
    }
  }

  /// Mark notification as read
  Future<Result<void>> markAsRead(String notificationId) async {
    return await call(
      notificationId: notificationId,
      readAt: DateTime.now(),
      actionTaken: 'read',
    );
  }

  /// Track notification click
  Future<Result<void>> trackClick(String notificationId, {String? action}) async {
    return await call(
      notificationId: notificationId,
      clickedAt: DateTime.now(),
      actionTaken: action ?? 'clicked',
    );
  }
}