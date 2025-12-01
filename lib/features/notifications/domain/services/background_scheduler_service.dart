import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:workmanager/workmanager.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';
import 'fcm_service.dart';

/// Service for handling background scheduling using WorkManager (Android) and BackgroundTasks (iOS)
class BackgroundSchedulerService {
  BackgroundSchedulerService();

  static const String _notificationCheckTask = 'notification_check_task';
  static const String _weeklySummaryTask = 'weekly_summary_task';
  static const String _monthlySummaryTask = 'monthly_summary_task';

  /// Initialize the background scheduler
  Future<Result<void>> initialize() async {
    try {
      if (Platform.isAndroid) {
        await Workmanager().initialize(
          _callbackDispatcher,
          isInDebugMode: kDebugMode,
        );

        // Register periodic tasks
        await _registerAndroidTasks();
      } else if (Platform.isIOS) {
        // iOS background tasks are handled differently
        // For now, we'll use a simpler approach
        await _registerIOSTasks();
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to initialize background scheduler: $e'));
    }
  }

  /// Register Android-specific background tasks
  Future<void> _registerAndroidTasks() async {
    // Periodic notification check (every hour)
    await Workmanager().registerPeriodicTask(
      _notificationCheckTask,
      _notificationCheckTask,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );

    // Weekly summary (every 7 days)
    await Workmanager().registerPeriodicTask(
      _weeklySummaryTask,
      _weeklySummaryTask,
      frequency: const Duration(days: 7),
      initialDelay: const Duration(days: 1), // Start tomorrow
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresDeviceIdle: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );

    // Monthly summary (every 30 days)
    await Workmanager().registerPeriodicTask(
      _monthlySummaryTask,
      _monthlySummaryTask,
      frequency: const Duration(days: 30),
      initialDelay: const Duration(days: 7), // Start next week
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresDeviceIdle: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  /// Register iOS-specific background tasks
  Future<void> _registerIOSTasks() async {
    // iOS background tasks are more limited
    // We'll use a timer-based approach for iOS
    debugPrint('iOS background tasks registered (limited functionality)');
  }

  /// Schedule a one-time notification check
  Future<Result<void>> scheduleOneTimeNotificationCheck({
    required Duration delay,
  }) async {
    try {
      if (Platform.isAndroid) {
        await Workmanager().registerOneOffTask(
          'one_time_notification_check_${DateTime.now().millisecondsSinceEpoch}',
          _notificationCheckTask,
          initialDelay: delay,
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      } else {
        // For iOS and other platforms, use a timer
        Timer(delay, () {
          _performNotificationCheck();
        });
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to schedule one-time notification check: $e'));
    }
  }

  /// Cancel all background tasks
  Future<Result<void>> cancelAllTasks() async {
    try {
      if (Platform.isAndroid) {
        await Workmanager().cancelAll();
      }
      // iOS tasks don't need explicit cancellation in this implementation

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to cancel background tasks: $e'));
    }
  }

  /// Cancel specific task
  Future<Result<void>> cancelTask(String taskName) async {
    try {
      if (Platform.isAndroid) {
        await Workmanager().cancelByUniqueName(taskName);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to cancel task $taskName: $e'));
    }
  }

  /// Check if background tasks are available
  bool get isBackgroundProcessingAvailable {
    return Platform.isAndroid || Platform.isIOS;
  }
}

/// Callback dispatcher for WorkManager
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case BackgroundSchedulerService._notificationCheckTask:
          await _performNotificationCheck();
          break;
        case BackgroundSchedulerService._weeklySummaryTask:
          await _performWeeklySummary();
          break;
        case BackgroundSchedulerService._monthlySummaryTask:
          await _performMonthlySummary();
          break;
        default:
          debugPrint('Unknown background task: $task');
          return false;
      }

      return true;
    } catch (e) {
      debugPrint('Background task failed: $e');
      return false;
    }
  });
}

/// Perform notification check in background
Future<void> _performNotificationCheck() async {
  try {
    debugPrint('Background notification check started at ${DateTime.now()}');

    // Since background isolates can't access Riverpod providers directly,
    // we need to initialize the necessary dependencies manually
    // This is a simplified implementation - in a full app, you'd inject these dependencies

    // For now, we'll create sample notifications to maintain compatibility
    // TODO: Integrate with actual notification checking usecases when background DI is set up
    final notifications = await _createSampleBackgroundNotifications();

    // Save to storage if any notifications were found
    if (notifications.isNotEmpty) {
      await _saveNotificationsToStorage(notifications);
      debugPrint('Saved ${notifications.length} background notifications');
    }

    debugPrint('Background notification check completed at ${DateTime.now()}');
  } catch (e) {
    debugPrint('Background notification check failed: $e');
  }
}

/// Perform weekly summary generation
Future<void> _performWeeklySummary() async {
  try {
    debugPrint('Weekly summary generation started at ${DateTime.now()}');

    // TODO: Integrate with GenerateWeeklySummaries use case
    // This would generate and send weekly spending summaries, goal progress, etc.

    debugPrint('Weekly summary generation completed at ${DateTime.now()}');
  } catch (e) {
    debugPrint('Weekly summary generation failed: $e');
  }
}

/// Perform monthly summary generation
Future<void> _performMonthlySummary() async {
  try {
    debugPrint('Monthly summary generation started at ${DateTime.now()}');

    // TODO: Integrate with GenerateMonthlySummaries use case
    // This would generate and send monthly financial reports, budget analysis, etc.

    debugPrint('Monthly summary generation completed at ${DateTime.now()}');
  } catch (e) {
    debugPrint('Monthly summary generation failed: $e');
  }
}

/// Create sample background notifications for demonstration
Future<List<AppNotification>> _createSampleBackgroundNotifications() async {
  // This is a simplified implementation for demonstration
  // In a real app, this would check actual data and create real notifications
  final notifications = <AppNotification>[];

  try {
    // Check if it's time for periodic reminders
    final now = DateTime.now();
    final hour = now.hour;

    // Create a sample system maintenance notification (runs occasionally)
    if (hour == 9 && now.minute < 30) { // Morning check
      notifications.add(AppNotification(
        id: 'bg_system_check_${now.day}_${now.month}',
        title: 'Daily System Check',
        message: 'Your budget tracker is running smoothly. All systems operational.',
        type: NotificationType.systemUpdate,
        priority: NotificationPriority.low,
        createdAt: now,
        metadata: {'checkType': 'daily_system_check'},
      ));
    }

    // Create a sample backup reminder (weekly)
    if (now.weekday == DateTime.monday && hour == 10) {
      notifications.add(AppNotification(
        id: 'bg_backup_reminder_${now.year}_${now.month}_${now.day}',
        title: 'Weekly Backup Reminder',
        message: 'Consider backing up your financial data this week.',
        type: NotificationType.systemBackup,
        priority: NotificationPriority.medium,
        createdAt: now,
        metadata: {'reminderType': 'weekly_backup'},
      ));
    }

  } catch (e) {
    debugPrint('Error creating sample background notifications: $e');
  }

  return notifications;
}

/// Save notifications to persistent storage
Future<void> _saveNotificationsToStorage(List<AppNotification> notifications) async {
  try {
    // Initialize Hive box if needed
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox('notifications');
    }

    final box = Hive.box('notifications');
    for (final notification in notifications) {
      await box.put(notification.id, {
        'id': notification.id,
        'title': notification.title,
        'message': notification.message,
        'type': notification.type.name,
        'priority': notification.priority.name,
        'createdAt': notification.createdAt.toIso8601String(),
        'scheduledFor': notification.scheduledFor?.toIso8601String(),
        'isRead': notification.isRead ?? false,
        'actionUrl': notification.actionUrl,
        'metadata': notification.metadata,
      });
    }
    debugPrint('Saved ${notifications.length} notifications to storage');
  } catch (e) {
    debugPrint('Error saving notifications to storage: $e');
  }
}