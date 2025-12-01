import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../entities/notification.dart';
import '../entities/notification_settings.dart';
import '../repositories/notification_repository.dart';
import '../usecases/check_all_notifications.dart';
import 'background_scheduler_service.dart';
import 'deep_linking_service.dart';
import 'fcm_service.dart';

/// Service for managing notifications
class NotificationService {
  NotificationService(this._checkAllNotifications, this._navigationService, [this._notificationRepository]);

  final CheckAllNotifications _checkAllNotifications;
  final NavigationService _navigationService;
  final NotificationRepository? _notificationRepository;

  final StreamController<List<AppNotification>> _notificationsController =
      StreamController<List<AppNotification>>.broadcast();

  /// Current list of notifications
  List<AppNotification> _currentNotifications = [];

  /// Stream of current notifications
  Stream<List<AppNotification>> get notifications => _notificationsController.stream;

  Timer? _periodicCheckTimer;

  /// Flutter Local Notifications plugin instance
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// FCM service for push notifications
  late final FCMService _fcmService;

  /// Deep linking service for navigation
  late final DeepLinkingService _deepLinkingService;

  /// Background scheduler service for periodic tasks
  late final BackgroundSchedulerService _backgroundSchedulerService;

  /// Current notification settings
  NotificationSettings? _currentSettings;

  /// Initialize the notification service
  Future<Result<void>> initialize([NotificationSettings? settings]) async {
    try {
      _currentSettings = settings;

      // Initialize FCM service
      _fcmService = FCMService(_flutterLocalNotificationsPlugin, _notificationRepository);
      final fcmResult = await _fcmService.initialize();
      if (fcmResult.isError) {
        debugPrint('FCM initialization failed: ${fcmResult.failureOrNull?.message}');
        // Continue with local notifications even if FCM fails
      }

      // Listen to FCM notifications and add them to our stream
      _fcmService.onNotificationCreated.listen((notification) {
        // Add to our current notifications and update stream
        _currentNotifications = [..._currentNotifications, notification];
        _notificationsController.add(_currentNotifications);
        debugPrint('FCM notification added to stream: ${notification.title}');
      });

      // Initialize deep linking service
      _deepLinkingService = DeepLinkingService(_navigationService);

      // Initialize background scheduler service
      _backgroundSchedulerService = BackgroundSchedulerService();
      final schedulerResult = await _backgroundSchedulerService.initialize();
      if (schedulerResult.isError) {
        debugPrint('Background scheduler initialization failed: ${schedulerResult.failureOrNull?.message}');
        // Continue without background scheduling
      }

      // Initialize flutter local notifications with enhanced channels
      await _initializeLocalNotifications();

      // Load existing notifications from storage
      await _loadExistingNotifications();

      // Check for notifications immediately
      await checkForNotifications();

      // Set up periodic checking (every hour)
      _periodicCheckTimer = Timer.periodic(
        const Duration(hours: 1),
        (_) => checkForNotifications(),
      );

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to initialize notification service: $e'));
    }
  }

  /// Initialize local notifications with platform-specific channels
  Future<void> _initializeLocalNotifications() async {
    // Create notification channels for Android
    final androidChannels = <AndroidNotificationChannel>[
      AndroidNotificationChannel(
        'budget_alerts',
        'Budget Alerts',
        description: 'Notifications about budget limits and spending alerts',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'bill_reminders',
        'Bill Reminders',
        description: 'Reminders for upcoming and overdue bills',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'goal_updates',
        'Goal Updates',
        description: 'Updates on savings goals progress',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'account_alerts',
        'Account Alerts',
        description: 'Alerts about account balances and transactions',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'transaction_alerts',
        'Transaction Alerts',
        description: 'Notifications about transaction activities',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'income_reminders',
        'Income Reminders',
        description: 'Reminders for expected income',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'system_updates',
        'System Updates',
        description: 'App updates and system notifications',
        importance: Importance.defaultImportance,
        playSound: false,
      ),
    ];

    // Create channels on Android
    for (final channel in androidChannels) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Initialize settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Check for new notifications
  Future<Result<List<AppNotification>>> checkForNotifications() async {
    final result = await _checkAllNotifications();

    if (result.isSuccess) {
      final notifications = result.dataOrNull!;
      _currentNotifications = notifications;
      _notificationsController.add(notifications);

      // Save notifications to persistent storage
      await _saveNotificationsToRepository(notifications);

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
    try {
      // Update persistent storage
      if (_notificationRepository != null) {
        await _notificationRepository!.markAsRead(notificationId);
      }

      // Update current notifications list
      _currentNotifications = _currentNotifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      _notificationsController.add(_currentNotifications);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      // Clear persistent storage
      if (_notificationRepository != null) {
        await _notificationRepository!.clearAllData();
      }

      // Clear current notifications
      _currentNotifications = [];
      _notificationsController.add([]);
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  /// Show in-app notifications for high priority items
  void _showInAppNotifications(List<AppNotification> notifications) {
    final highPriorityNotifications = notifications.where(
      (notification) => notification.priority == NotificationPriority.high ||
                        notification.priority == NotificationPriority.critical,
    );

    for (final notification in highPriorityNotifications) {
      if (notification.isRead != true && shouldSendNotification(notification)) {
        // Don't send notifications during quiet hours
        if (isInQuietHours) continue;

        // Schedule local notification for bill reminders, budget alerts, and transaction receipts
        if (notification.type == NotificationType.billReminder ||
            notification.type == NotificationType.budgetAlert ||
            notification.type == NotificationType.transactionReceipt) {
          _showImmediateLocalNotification(notification);
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
    // Only schedule if the notification has a scheduled time and is allowed by settings
    if (notification.scheduledFor == null || !shouldSendNotification(notification)) return;

    final scheduledTime = notification.scheduledFor!;
    final now = DateTime.now();

    // Don't schedule notifications for past times
    if (scheduledTime.isBefore(now)) return;

    // Don't schedule during quiet hours
    if (isInQuietHours) return;

    // Apply frequency delay if configured
    final delay = getNotificationDelay();
    final effectiveScheduledTime = delay != null
        ? scheduledTime.add(delay)
        : scheduledTime;

    // Get channel ID based on notification type
    final channelId = _getChannelIdForNotification(notification.type);
    final channelName = _getChannelNameForType(notification.type);
    final channelDescription = _getChannelDescriptionForType(notification.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: _getImportanceForPriority(notification.priority),
      priority: _getPriorityForPriority(notification.priority),
      showWhen: true,
      icon: '@mipmap/ic_launcher',
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
      tz.TZDateTime.from(effectiveScheduledTime, tz.local),
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

  /// Show immediate local notification
  Future<void> _showImmediateLocalNotification(AppNotification notification) async {
    // Get channel ID based on notification type
    final channelId = _getChannelIdForNotification(notification.type);
    final channelName = _getChannelNameForType(notification.type);
    final channelDescription = _getChannelDescriptionForType(notification.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: _getImportanceForPriority(notification.priority),
      priority: _getPriorityForPriority(notification.priority),
      showWhen: true,
      icon: '@mipmap/ic_launcher',
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

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      notification.title,
      notification.message,
      details,
    );
  }

  /// Handle notification tap
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    debugPrint('Notification tapped with payload: $payload');

    try {
      // Try to handle as deep link
      final deepLinkResult = await _deepLinkingService.handleDeepLink(payload);
      if (deepLinkResult.isSuccess) {
        final action = deepLinkResult.dataOrNull!;
        _deepLinkingService.navigateTo(action);
        debugPrint('Navigated to: ${action.route}');
      } else {
        debugPrint('Failed to handle deep link: ${deepLinkResult.failureOrNull?.message}');
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  /// Update notification settings
  void updateSettings(NotificationSettings settings) {
    _currentSettings = settings;
  }

  /// Check if notification should be sent based on current settings
  bool shouldSendNotification(AppNotification notification) {
    if (_currentSettings == null) return true; // Default to enabled if no settings

    return _currentSettings!.shouldSendNotification(notification.type);
  }

  /// Get notification delay based on settings
  Duration? getNotificationDelay() {
    return _currentSettings?.getNotificationDelay();
  }

  /// Check if current time is within quiet hours
  bool get isInQuietHours {
    return _currentSettings?.isInQuietHours ?? false;
  }

  /// Load existing notifications from persistent storage
  Future<void> _loadExistingNotifications() async {
    try {
      if (_notificationRepository != null) {
        final result = await _notificationRepository!.getAllNotifications(
          limit: 100, // Load last 100 notifications
          offset: 0,
        );

        if (result.isSuccess) {
          final notifications = result.dataOrNull ?? [];
          _currentNotifications = notifications;
          _notificationsController.add(notifications);
          debugPrint('Loaded ${notifications.length} existing notifications from storage');
        } else {
          debugPrint('Failed to load existing notifications: ${result.failureOrNull?.message}');
        }
      }
    } catch (e) {
      debugPrint('Error loading existing notifications: $e');
    }
  }

  /// Save notifications to persistent storage
  Future<void> _saveNotificationsToRepository(List<AppNotification> notifications) async {
    try {
      if (_notificationRepository != null) {
        for (final notification in notifications) {
          final result = await _notificationRepository!.saveNotification(notification);
          if (result.isError) {
            debugPrint('Failed to save notification ${notification.id}: ${result.failureOrNull?.message}');
          }
        }
        debugPrint('Saved ${notifications.length} notifications to storage');
      }
    } catch (e) {
      debugPrint('Error saving notifications to repository: $e');
    }
  }

  /// Get channel ID for notification type
  String _getChannelIdForNotification(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return 'budget_alerts';
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return 'bill_reminders';
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return 'goal_updates';
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
        return 'account_alerts';
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return 'transaction_alerts';
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return 'income_reminders';
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return 'system_updates';
      case NotificationType.custom:
        return 'general';
    }
  }

  /// Get channel name for notification type
  String _getChannelNameForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return 'Budget Alerts';
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return 'Bill Reminders';
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return 'Goal Updates';
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
        return 'Account Alerts';
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return 'Transaction Alerts';
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return 'Income Reminders';
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return 'System Updates';
      case NotificationType.custom:
        return 'General Notifications';
    }
  }

  /// Get channel description for notification type
  String _getChannelDescriptionForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return 'Notifications about budget limits and spending alerts';
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return 'Reminders for upcoming and overdue bills';
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return 'Updates on savings goals progress';
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
        return 'Alerts about account balances and transactions';
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return 'Notifications about transaction activities';
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return 'Reminders for expected income';
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return 'App updates and system notifications';
      case NotificationType.custom:
        return 'General app notifications';
    }
  }

  /// Get Android importance for notification priority
  Importance _getImportanceForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.medium:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.critical:
        return Importance.max;
    }
  }

  /// Get Android priority for notification priority
  Priority _getPriorityForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.medium:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.critical:
        return Priority.max;
    }
  }

  /// Dispose of the service
  void dispose() {
    _periodicCheckTimer?.cancel();
    _notificationsController.close();
    _fcmService.dispose();
    _deepLinkingService.dispose();
    _backgroundSchedulerService.cancelAllTasks();
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

  /// Create sample test notifications for verification
  Future<Result<List<AppNotification>>> createTestNotifications() async {
    try {
      final testNotifications = [
        AppNotification(
          id: 'test_budget_alert_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Test Budget Alert',
          message: 'This is a test budget alert notification',
          type: NotificationType.budgetAlert,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
          actionUrl: 'budget://test',
          metadata: {'test': true, 'type': 'budget'},
        ),
        AppNotification(
          id: 'test_transaction_receipt_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Test Transaction Receipt',
          message: 'This is a test transaction receipt notification',
          type: NotificationType.transactionReceipt,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
          actionUrl: 'transaction://test',
          metadata: {'test': true, 'type': 'transaction'},
        ),
        AppNotification(
          id: 'test_goal_milestone_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Test Goal Milestone',
          message: 'This is a test goal milestone notification',
          type: NotificationType.goalMilestone,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
          actionUrl: 'goal://test',
          metadata: {'test': true, 'type': 'goal'},
        ),
      ];

      // Save all test notifications to repository
      await _saveNotificationsToRepository(testNotifications);

      // Update current notifications
      _currentNotifications = [..._currentNotifications, ...testNotifications];
      _notificationsController.add(_currentNotifications);

      debugPrint('Created ${testNotifications.length} test notifications');

      return Result.success(testNotifications);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to create test notifications: $e'));
    }
  }

  /// Create budget threshold alert notification
  Future<Result<AppNotification>> createBudgetThresholdAlert({
    required String budgetId,
    required String budgetName,
    required double currentAmount,
    required double thresholdAmount,
    required double percentage,
  }) async {
    try {
      final notification = AppNotification(
        id: 'budget_threshold_$budgetId',
        title: 'Budget Threshold Alert',
        message: '$budgetName has reached ${percentage.toStringAsFixed(1)}% of budget limit',
        type: NotificationType.budgetThreshold,
        priority: NotificationPriority.high,
        createdAt: DateTime.now(),
        actionUrl: 'budget://details/$budgetId',
        metadata: {
          'budgetId': budgetId,
          'currentAmount': currentAmount,
          'thresholdAmount': thresholdAmount,
          'percentage': percentage,
        },
      );

      // Save to repository
      if (_notificationRepository != null) {
        final saveResult = await _notificationRepository!.saveNotification(notification);
        if (saveResult.isError) {
          debugPrint('Failed to save budget threshold notification: ${saveResult.failureOrNull?.message}');
        }
      }

      // Show immediately if high priority
      if (shouldSendNotification(notification)) {
        scheduleLocalNotification(notification);
      }

      return Result.success(notification);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to create budget threshold alert: $e'));
    }
  }

  /// Create transaction receipt notification
  Future<Result<AppNotification>> createTransactionReceipt({
    required String transactionId,
    required String description,
    required double amount,
    required String category,
  }) async {
    try {
      final notification = AppNotification(
        id: 'transaction_receipt_$transactionId',
        title: 'Transaction Receipt',
        message: 'Transaction: $description - \$${amount.toStringAsFixed(2)}',
        type: NotificationType.transactionReceipt,
        priority: NotificationPriority.high,
        createdAt: DateTime.now(),
        actionUrl: 'transaction://details/$transactionId',
        metadata: {
          'transactionId': transactionId,
          'amount': amount,
          'category': category,
        },
      );

      // Save to repository
      if (_notificationRepository != null) {
        final saveResult = await _notificationRepository!.saveNotification(notification);
        if (saveResult.isError) {
          debugPrint('Failed to save transaction receipt notification: ${saveResult.failureOrNull?.message}');
        }
      }

      if (shouldSendNotification(notification)) {
        scheduleLocalNotification(notification);
      }

      return Result.success(notification);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to create transaction receipt: $e'));
    }
  }

  /// Create goal milestone notification
  Future<Result<AppNotification>> createGoalMilestone({
    required String goalId,
    required String goalName,
    required double progressPercentage,
    required String milestone,
  }) async {
    try {
      final notification = AppNotification(
        id: 'goal_milestone_$goalId',
        title: 'Goal Milestone Reached!',
        message: '$goalName: $milestone (${progressPercentage.toStringAsFixed(1)}% complete)',
        type: NotificationType.goalMilestone,
        priority: NotificationPriority.medium,
        createdAt: DateTime.now(),
        actionUrl: 'goal://details/$goalId',
        metadata: {
          'goalId': goalId,
          'progressPercentage': progressPercentage,
          'milestone': milestone,
        },
      );

      // Save to repository
      if (_notificationRepository != null) {
        final saveResult = await _notificationRepository!.saveNotification(notification);
        if (saveResult.isError) {
          debugPrint('Failed to save goal milestone notification: ${saveResult.failureOrNull?.message}');
        }
      }

      if (shouldSendNotification(notification)) {
        scheduleLocalNotification(notification);
      }

      return Result.success(notification);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to create goal milestone notification: $e'));
    }
  }

  /// Create system backup notification
  Future<Result<AppNotification>> createSystemBackupAlert({
    required bool success,
    required String backupType,
    String? errorMessage,
  }) async {
    try {
      final notification = AppNotification(
        id: 'system_backup_${DateTime.now().millisecondsSinceEpoch}',
        title: success ? 'Backup Completed' : 'Backup Failed',
        message: success
            ? '$backupType backup completed successfully'
            : 'Failed to complete $backupType backup: ${errorMessage ?? "Unknown error"}',
        type: NotificationType.systemBackup,
        priority: success ? NotificationPriority.low : NotificationPriority.high,
        createdAt: DateTime.now(),
        actionUrl: 'settings://backup',
        metadata: {
          'success': success,
          'backupType': backupType,
          'errorMessage': errorMessage,
        },
      );

      // Save to repository
      if (_notificationRepository != null) {
        final saveResult = await _notificationRepository!.saveNotification(notification);
        if (saveResult.isError) {
          debugPrint('Failed to save system backup notification: ${saveResult.failureOrNull?.message}');
        }
      }

      if (shouldSendNotification(notification)) {
        scheduleLocalNotification(notification);
      }

      return Result.success(notification);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to create system backup notification: $e'));
    }
  }

  /// Create account balance alert
  Future<Result<AppNotification>> createAccountBalanceAlert({
    required String accountId,
    required String accountName,
    required double currentBalance,
    required double threshold,
  }) async {
    try {
      final notification = AppNotification(
        id: 'account_balance_$accountId',
        title: 'Low Balance Alert',
        message: '$accountName balance is below threshold: \$${currentBalance.toStringAsFixed(2)}',
        type: NotificationType.accountBalance,
        priority: NotificationPriority.high,
        createdAt: DateTime.now(),
        actionUrl: 'account://details/$accountId',
        metadata: {
          'accountId': accountId,
          'currentBalance': currentBalance,
          'threshold': threshold,
        },
      );

      // Save to repository
      if (_notificationRepository != null) {
        final saveResult = await _notificationRepository!.saveNotification(notification);
        if (saveResult.isError) {
          debugPrint('Failed to save account balance notification: ${saveResult.failureOrNull?.message}');
        }
      }

      if (shouldSendNotification(notification)) {
        scheduleLocalNotification(notification);
      }

      return Result.success(notification);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to create account balance alert: $e'));
    }
  }

  /// Create bill confirmation notification
  Future<Result<AppNotification>> createBillConfirmation({
    required String billId,
    required String billName,
    required double amount,
    required DateTime dueDate,
  }) async {
    try {
      final notification = AppNotification(
        id: 'bill_confirmation_$billId',
        title: 'Bill Payment Confirmed',
        message: 'Payment of \$${amount.toStringAsFixed(2)} for $billName has been confirmed',
        type: NotificationType.billConfirmation,
        priority: NotificationPriority.medium,
        createdAt: DateTime.now(),
        actionUrl: 'bill://details/$billId',
        metadata: {
          'billId': billId,
          'amount': amount,
          'dueDate': dueDate.toIso8601String(),
        },
      );

      // Save to repository
      if (_notificationRepository != null) {
        final saveResult = await _notificationRepository!.saveNotification(notification);
        if (saveResult.isError) {
          debugPrint('Failed to save bill confirmation notification: ${saveResult.failureOrNull?.message}');
        }
      }

      if (shouldSendNotification(notification)) {
        scheduleLocalNotification(notification);
      }

      return Result.success(notification);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to create bill confirmation: $e'));
    }
  }

  /// Send FCM notification with rich payload
  Future<Result<String>> sendRichFCMNotification({
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
      final result = await _fcmService.sendRichNotification(
        title: title,
        body: body,
        type: type,
        data: data,
        actionButtons: actionButtons,
        priority: priority,
        requiresInteraction: requiresInteraction,
        timeToLive: timeToLive,
      );
      return result;
    } catch (e) {
      return Result.error(Failure.unknown('Failed to send rich FCM notification: $e'));
    }
  }

  /// Send targeted FCM notification
  Future<Result<String>> sendTargetedFCMNotification({
    required String title,
    required String body,
    required NotificationType type,
    required String target,
    required Map<String, dynamic> data,
    NotificationPriority priority = NotificationPriority.medium,
  }) async {
    try {
      final result = await _fcmService.sendTargetedNotification(
        title: title,
        body: body,
        type: type,
        target: target,
        data: data,
        priority: priority,
      );
      return result;
    } catch (e) {
      return Result.error(Failure.unknown('Failed to send targeted FCM notification: $e'));
    }
  }

  /// Send bulk FCM notifications
  Future<Result<List<String>>> sendBulkFCMNotifications({
    required String title,
    required String body,
    required NotificationType type,
    required List<String> targets,
    required Map<String, dynamic> data,
    NotificationPriority priority = NotificationPriority.medium,
  }) async {
    try {
      final result = await _fcmService.sendBulkNotifications(
        title: title,
        body: body,
        type: type,
        targets: targets,
        data: data,
        priority: priority,
      );
      return result;
    } catch (e) {
      return Result.error(Failure.unknown('Failed to send bulk FCM notifications: $e'));
    }
  }
}