import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_analytics.freezed.dart';

/// Analytics for notification tracking
@freezed
class NotificationAnalytics with _$NotificationAnalytics {
  const factory NotificationAnalytics({
    required String id,
    required String notificationId,
    required DateTime sentAt,
    DateTime? readAt,
    DateTime? clickedAt,
    String? actionTaken,
    Map<String, dynamic>? metadata,
  }) = _NotificationAnalytics;

  const NotificationAnalytics._();

  /// Check if notification was read
  bool get wasRead => readAt != null;

  /// Check if notification was clicked
  bool get wasClicked => clickedAt != null;

  /// Get time to read (if read)
  Duration? get timeToRead {
    if (readAt == null) return null;
    return readAt!.difference(sentAt);
  }

  /// Get time to click (if clicked)
  Duration? get timeToClick {
    if (clickedAt == null) return null;
    return clickedAt!.difference(sentAt);
  }
}

/// Actions that can be taken on notifications
enum NotificationAction {
  markAsRead,
  dismiss,
  navigateToScreen,
  performAction,
  custom,
}