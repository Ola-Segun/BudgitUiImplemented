import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' if (dart.library.html) '../../../../../firebase_messaging_stub.dart' as fcm;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' if (dart.library.html) '../../../../../flutter_local_notifications_stub.dart' as notifications;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';

import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Service for handling Firebase Cloud Messaging (FCM) push notifications
class FCMService {
  FCMService(this._localNotificationsPlugin, [this._notificationRepository]) {
    _messageController = StreamController<dynamic>.broadcast();
    _tokenController = StreamController<String>.broadcast();
    _notificationController = StreamController<AppNotification>.broadcast();

    if (!kIsWeb) {
      _firebaseMessaging = fcm.FirebaseMessaging.instance;
    }
  }

  final dynamic _localNotificationsPlugin;
  final NotificationRepository? _notificationRepository;
  dynamic _firebaseMessaging;
  late final StreamController<dynamic> _messageController;
  late final StreamController<String> _tokenController;
  late final StreamController<AppNotification> _notificationController;

  /// Stream of incoming FCM messages
  Stream<dynamic> get onMessage => _messageController.stream;

  /// Stream of FCM token updates
  Stream<String> get onTokenRefresh => _tokenController.stream;

  /// Stream of created notifications from FCM messages
  Stream<AppNotification> get onNotificationCreated => _notificationController.stream;

  /// Initialize FCM service
  Future<Result<void>> initialize() async {
    if (kIsWeb) {
      // FCM not available on web
      return Result.error(Failure.unknown('FCM not supported on web platform'));
    }

    try {
      // Request permission for iOS
      if (Platform.isIOS) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        if (settings.authorizationStatus != fcm.AuthorizationStatus.authorized) {
          return Result.error(Failure.unknown('FCM permission not granted'));
        }
      }

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _tokenController.add(token);
      }

      // Set up message handlers
      fcm.FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      fcm.FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      fcm.FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessageStatic);

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _tokenController.add(token);
      });

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to initialize FCM: $e'));
    }
  }

  /// Get current FCM token
  Future<Result<String?>> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return Result.success(token);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get FCM token: $e'));
    }
  }

  /// Subscribe to a topic
  Future<Result<void>> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to subscribe to topic $topic: $e'));
    }
  }

  /// Unsubscribe from a topic
  Future<Result<void>> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to unsubscribe from topic $topic: $e'));
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(dynamic message) async {
    _messageController.add(message);

    // Create notification entity from FCM message
    final notification = await _createNotificationFromFCM(message);
    if (notification != null) {
      _notificationController.add(notification);

      // Save to repository if available
      try {
        await _notificationRepository?.saveNotification(notification);
        debugPrint('Saved FCM notification to repository: ${notification.id}');
      } catch (e) {
        debugPrint('Failed to save FCM notification to repository: $e');
      }
    }

    if (!kIsWeb) {
      _showLocalNotificationFromFCM(message);
    }
  }

  /// Handle background messages
  void _handleBackgroundMessage(dynamic message) {
    _messageController.add(message);
    // Background messages are handled by the static handler
  }

  /// Handle background messages (static method required by FCM)
  static Future<void> _handleBackgroundMessageStatic(dynamic message) async {
    if (!kIsWeb) {
      // Initialize Firebase if not already done
      await Firebase.initializeApp();

      // Handle the message (could show local notification, update data, etc.)
      debugPrint('Handling background message: ${message.messageId}');
    }
  }

  /// Convert FCM message to local notification
  Future<void> _showLocalNotificationFromFCM(dynamic message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    // Determine notification channel based on data
    final channelId = data['channel'] ?? 'general';
    final channelName = _getChannelName(channelId);
    final channelDescription = _getChannelDescription(channelId);

    final androidDetails = notifications.AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: notifications.Importance.high,
      priority: notifications.Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = notifications.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = notifications.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use message ID as notification ID
    final notificationId = message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

    await _localNotificationsPlugin.show(
      notificationId,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(data),
    );
  }

  /// Get channel name based on channel ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'budget':
        return 'Budget Alerts';
      case 'bills':
        return 'Bill Reminders';
      case 'goals':
        return 'Goal Updates';
      case 'accounts':
        return 'Account Alerts';
      case 'system':
        return 'System Updates';
      default:
        return 'General Notifications';
    }
  }

  /// Get channel description based on channel ID
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'budget':
        return 'Notifications about budget limits and spending alerts';
      case 'bills':
        return 'Reminders for upcoming and overdue bills';
      case 'goals':
        return 'Updates on savings goals progress';
      case 'accounts':
        return 'Alerts about account balances and transactions';
      case 'system':
        return 'App updates and system notifications';
      default:
        return 'General app notifications';
    }
  }

  /// Send rich FCM notification with enhanced payload
  Future<Result<String>> sendRichNotification({
    required String title,
    required String body,
    required NotificationType type,
    required Map<String, dynamic> data,
    List<String>? actionButtons,
    NotificationPriority priority = NotificationPriority.medium,
    bool requiresInteraction = false,
    Duration? timeToLive,
  }) async {
    try {
      final messageId = 'fcm_${DateTime.now().millisecondsSinceEpoch}';

      // Create rich notification payload
      final richData = <String, dynamic>{
        'messageId': messageId,
        'title': title,
        'body': body,
        'type': type.name,
        'timestamp': DateTime.now().toIso8601String(),
        'priority': priority.name,
        'channel': _getChannelForType(type),
        'requiresInteraction': requiresInteraction,
        'ttl': timeToLive?.inSeconds ?? 86400, // Default 24 hours
        ...data,
      };

      // Add action buttons if provided
      if (actionButtons != null && actionButtons.isNotEmpty) {
        richData['actions'] = actionButtons.map((action) => {
          'action': action,
          'title': _getActionTitle(action),
        }).toList();
      }

      // Add deep linking URL if available
      if (data.containsKey('actionUrl')) {
        richData['click_action'] = data['actionUrl'];
      }

      // Add rich content metadata
      if (data.containsKey('imageUrl')) {
        richData['image'] = data['imageUrl'];
      }

      if (data.containsKey('largeIcon')) {
        richData['large_icon'] = data['largeIcon'];
      }

      // Add notification styling
      richData['style'] = _getNotificationStyle(type);

      // For now, simulate sending FCM message
      // In production, this would use Firebase Admin SDK or cloud functions
      debugPrint('Sending rich FCM notification: $richData');

      // Store analytics data
      await _trackNotificationAnalytics(type, 'sent', messageId: messageId);

      return Result.success(messageId);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to send rich FCM notification: $e'));
    }
  }

  /// Send targeted notification to specific users/topics
  Future<Result<String>> sendTargetedNotification({
    required String title,
    required String body,
    required NotificationType type,
    required String target, // User ID, topic, or device token
    required Map<String, dynamic> data,
    NotificationPriority priority = NotificationPriority.medium,
  }) async {
    try {
      final messageId = 'targeted_${DateTime.now().millisecondsSinceEpoch}';

      final richData = <String, dynamic>{
        'messageId': messageId,
        'title': title,
        'body': body,
        'type': type.name,
        'target': target,
        'timestamp': DateTime.now().toIso8601String(),
        'priority': priority.name,
        ...data,
      };

      // Send to specific target (user, topic, or device)
      debugPrint('Sending targeted FCM notification to $target: $richData');

      await _trackNotificationAnalytics(type, 'sent_targeted', messageId: messageId);

      return Result.success(messageId);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to send targeted notification: $e'));
    }
  }

  /// Send bulk notifications to multiple targets
  Future<Result<List<String>>> sendBulkNotifications({
    required String title,
    required String body,
    required NotificationType type,
    required List<String> targets,
    required Map<String, dynamic> data,
    NotificationPriority priority = NotificationPriority.medium,
  }) async {
    try {
      final messageIds = <String>[];

      for (final target in targets) {
        final result = await sendTargetedNotification(
          title: title,
          body: body,
          type: type,
          target: target,
          data: data,
          priority: priority,
        );

        if (result.isSuccess) {
          messageIds.add(result.dataOrNull!);
        }
      }

      return Result.success(messageIds);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to send bulk notifications: $e'));
    }
  }

  /// Track notification analytics
  Future<void> _trackNotificationAnalytics(NotificationType type, String action, {String? messageId}) async {
    // This would integrate with analytics service
    debugPrint('Analytics: Notification $action for type ${type.name}${messageId != null ? ' (ID: $messageId)' : ''}');
  }


  /// Get channel for notification type
  String _getChannelForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return 'budget';
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return 'bills';
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return 'goals';
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return 'accounts';
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return 'income';
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return 'system';
      case NotificationType.custom:
        return 'general';
    }
  }

  /// Get action title for action button
  String _getActionTitle(String action) {
    switch (action) {
      case 'view':
        return 'View';
      case 'pay':
        return 'Pay Now';
      case 'dismiss':
        return 'Dismiss';
      case 'snooze':
        return 'Remind Later';
      case 'contribute':
        return 'Contribute';
      default:
        return action;
    }
  }

  /// Get notification style based on type
  String _getNotificationStyle(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
        return 'warning';
      case NotificationType.goalCelebration:
        return 'celebration';
      case NotificationType.systemSecurity:
        return 'security';
      case NotificationType.transactionReceipt:
        return 'transaction';
      default:
        return 'default';
    }
  }

  /// Create notification entity from FCM message
  Future<AppNotification?> _createNotificationFromFCM(dynamic message) async {
    try {
      final notification = message.notification;
      final data = message.data as Map<dynamic, dynamic>;

      if (notification == null) return null;

      // Parse notification type from data
      final typeString = data['type'] as String?;
      final notificationType = _parseNotificationType(typeString);

      // Parse priority from data
      final priorityString = data['priority'] as String?;
      final priority = _parseNotificationPriority(priorityString);

      // Create notification entity
      final appNotification = AppNotification(
        id: data['messageId'] as String? ?? 'fcm_${message.messageId ?? DateTime.now().millisecondsSinceEpoch}',
        title: notification.title ?? 'Notification',
        message: notification.body ?? '',
        type: notificationType,
        priority: priority,
        createdAt: DateTime.now(),
        scheduledFor: data['scheduledFor'] != null ? DateTime.parse(data['scheduledFor']) : null,
        actionUrl: data['actionUrl'] as String?,
        metadata: Map<String, dynamic>.from(data),
      );

      return appNotification;
    } catch (e) {
      debugPrint('Error creating notification from FCM message: $e');
      return null;
    }
  }

  /// Parse notification type from string
  NotificationType _parseNotificationType(String? typeString) {
    switch (typeString) {
      case 'budgetAlert':
        return NotificationType.budgetAlert;
      case 'budgetThreshold':
        return NotificationType.budgetThreshold;
      case 'billReminder':
        return NotificationType.billReminder;
      case 'goalMilestone':
        return NotificationType.goalMilestone;
      case 'accountAlert':
        return NotificationType.accountAlert;
      case 'systemUpdate':
        return NotificationType.systemUpdate;
      case 'transactionReceipt':
        return NotificationType.transactionReceipt;
      default:
        return NotificationType.custom;
    }
  }

  /// Parse notification priority from string
  NotificationPriority _parseNotificationPriority(String? priorityString) {
    switch (priorityString) {
      case 'low':
        return NotificationPriority.low;
      case 'medium':
        return NotificationPriority.medium;
      case 'high':
        return NotificationPriority.high;
      case 'critical':
        return NotificationPriority.critical;
      default:
        return NotificationPriority.medium;
    }
  }

  /// Dispose of resources
  void dispose() {
    _messageController.close();
    _tokenController.close();
    _notificationController.close();
  }
}