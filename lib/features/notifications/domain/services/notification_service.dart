import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/error/result.dart';
import '../entities/notification.dart';
import '../usecases/check_all_notifications.dart';

/// Service for managing notifications
class NotificationService {
  NotificationService(this._checkAllNotifications);

  final CheckAllNotifications _checkAllNotifications;

  final StreamController<List<AppNotification>> _notificationsController =
      StreamController<List<AppNotification>>.broadcast();

  /// Stream of current notifications
  Stream<List<AppNotification>> get notifications => _notificationsController.stream;

  Timer? _periodicCheckTimer;

  /// Flutter Local Notifications plugin instance
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize flutter local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings);

    // Check for notifications immediately
    await checkForNotifications();

    // Set up periodic checking (every hour)
    _periodicCheckTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => checkForNotifications(),
    );
  }

  /// Check for new notifications
  Future<Result<List<AppNotification>>> checkForNotifications() async {
    final result = await _checkAllNotifications();

    if (result.isSuccess) {
      final notifications = result.dataOrNull!;
      _notificationsController.add(notifications);

      // Show in-app notifications for high priority items
      _showInAppNotifications(notifications);
    }

    return result;
  }

  /// Get current notifications
  Future<Result<List<AppNotification>>> getCurrentNotifications() async {
    return await _checkAllNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    // TODO: Implement marking as read in persistent storage
    // For now, just update the stream
    final currentNotifications = await getCurrentNotifications();
    if (currentNotifications.isSuccess) {
      final updatedNotifications = currentNotifications.dataOrNull!.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      _notificationsController.add(updatedNotifications);
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    _notificationsController.add([]);
  }

  /// Show in-app notifications for high priority items
  void _showInAppNotifications(List<AppNotification> notifications) {
    final highPriorityNotifications = notifications.where(
      (notification) => notification.priority == NotificationPriority.high ||
                       notification.priority == NotificationPriority.critical,
    );

    for (final notification in highPriorityNotifications) {
      if (notification.isRead != true) {
        // Schedule local notification for bill reminders
        if (notification.type == NotificationType.billReminder) {
          scheduleLocalNotification(notification);
        }
        // Show in-app notification using a snackbar or overlay
        _showInAppNotification(notification);
      }
    }
  }

  /// Show a single in-app notification
  void _showInAppNotification(AppNotification notification) {
    // This would typically use a notification overlay or snackbar
    // For now, we'll just print to console as a placeholder
    print('🔔 ${notification.priority.name.toUpperCase()}: ${notification.title}');
    print('   ${notification.message}');
  }

  /// Schedule local notification
  Future<void> scheduleLocalNotification(AppNotification notification) async {
    // Only schedule if the notification has a scheduled time
    if (notification.scheduledFor == null) return;

    final scheduledTime = notification.scheduledFor!;
    final now = DateTime.now();

    // Don't schedule notifications for past times
    if (scheduledTime.isBefore(now)) return;

    final androidDetails = AndroidNotificationDetails(
      'bill_reminders',
      'Bill Reminders',
      channelDescription: 'Reminders for upcoming and overdue bills',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use notification ID hash for uniqueness
    final notificationId = notification.id.hashCode.abs();

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      notification.title,
      notification.message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel scheduled notification
  Future<void> cancelScheduledNotification(String notificationId) async {
    final notificationIdInt = notificationId.hashCode.abs();
    await _flutterLocalNotificationsPlugin.cancel(notificationIdInt);
  }

  /// Dispose of the service
  void dispose() {
    _periodicCheckTimer?.cancel();
    _notificationsController.close();
  }

  /// Request notification permissions (call this from UI when needed)
  Future<bool> requestPermissions() async {
    final androidGranted = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final iosGranted = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return (androidGranted ?? false) || (iosGranted ?? false);
  }
}