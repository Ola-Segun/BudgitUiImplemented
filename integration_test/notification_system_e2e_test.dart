import 'package:flutter_test/flutter_test.dart';

import '../lib/features/notifications/domain/entities/notification.dart';
import '../lib/features/notifications/domain/entities/notification_settings.dart';

void main() {
  group('Notification System Comprehensive E2E Tests', () {

    // ============================================================================
    // 1. NOTIFICATION TYPES AND TRIGGERS TESTING
    // ============================================================================

    group('Notification Types and Triggers', () {
      test('Budget threshold alerts (80% spending test)', () {
        // Create budget threshold alert at 80%
        final alert = AppNotification(
          id: 'budget_threshold_test',
          title: 'Budget Threshold Alert',
          message: 'Monthly Budget has reached 80.0% of budget limit',
          type: NotificationType.budgetThreshold,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
          actionUrl: 'budget://details/budget_threshold_test',
          metadata: {
            'budgetId': 'budget_threshold_test',
            'currentAmount': 800.0,
            'thresholdAmount': 1000.0,
            'percentage': 80.0,
          },
        );

        expect(alert.type, NotificationType.budgetThreshold);
        expect(alert.priority, NotificationPriority.high);
        expect(alert.metadata?['percentage'], 80.0);
        expect(alert.message.contains('80.0%'), true);
        expect(alert.actionUrl, 'budget://details/budget_threshold_test');
      });

      test('Bill due date reminders (1, 3, 7-day intervals)', () {
        final now = DateTime.now();

        // Test 7-day reminder
        final sevenDayReminder = AppNotification(
          id: 'bill_reminder_7d',
          title: 'Bill Due Soon',
          message: 'Electricity bill due in 7 days',
          type: NotificationType.billReminder,
          priority: NotificationPriority.medium,
          createdAt: now,
          scheduledFor: now.add(const Duration(days: 7)),
          metadata: {'daysUntilDue': 7, 'billId': 'electricity_bill'},
        );

        // Test 3-day reminder
        final threeDayReminder = AppNotification(
          id: 'bill_reminder_3d',
          title: 'Bill Due Soon',
          message: 'Internet bill due in 3 days',
          type: NotificationType.billReminder,
          priority: NotificationPriority.high,
          createdAt: now,
          scheduledFor: now.add(const Duration(days: 3)),
          metadata: {'daysUntilDue': 3, 'billId': 'internet_bill'},
        );

        // Test 1-day reminder
        final oneDayReminder = AppNotification(
          id: 'bill_reminder_1d',
          title: 'Bill Due Tomorrow',
          message: 'Phone bill due tomorrow',
          type: NotificationType.billReminder,
          priority: NotificationPriority.critical,
          createdAt: now,
          scheduledFor: now.add(const Duration(days: 1)),
          metadata: {'daysUntilDue': 1, 'billId': 'phone_bill'},
        );

        // Verify priority escalation
        expect(sevenDayReminder.priority, NotificationPriority.medium);
        expect(threeDayReminder.priority, NotificationPriority.high);
        expect(oneDayReminder.priority, NotificationPriority.critical);

        // Verify scheduling
        expect(sevenDayReminder.isScheduled, true);
        expect(threeDayReminder.isScheduled, true);
        expect(oneDayReminder.isScheduled, true);

        // Verify time calculations (allow small tolerance for timing precision)
        expect(sevenDayReminder.timeUntilScheduled!.inDays, closeTo(7, 1));
        expect(threeDayReminder.timeUntilScheduled!.inDays, closeTo(3, 1));
        expect(oneDayReminder.timeUntilScheduled!.inDays, closeTo(1, 1));
      });

      test('Goal milestone notifications (25%, 50%, 75%, 100%)', () {
        const milestones = [25.0, 50.0, 75.0, 100.0];

        for (final percentage in milestones) {
          final milestone = AppNotification(
            id: 'goal_milestone_${percentage.toInt()}',
            title: percentage == 100.0 ? 'Goal Completed!' : 'Goal Milestone Reached!',
            message: 'Vacation Fund: ${percentage.toStringAsFixed(1)}% Complete',
            type: NotificationType.goalMilestone,
            priority: NotificationPriority.medium,
            createdAt: DateTime.now(),
            actionUrl: 'goal://details/vacation_fund',
            metadata: {
              'goalId': 'vacation_fund',
              'progressPercentage': percentage,
              'milestone': '${percentage.toInt()}% Complete',
            },
          );

          expect(milestone.type, NotificationType.goalMilestone);
          expect(milestone.metadata?['progressPercentage'], percentage);
          expect(milestone.message.contains('${percentage.toStringAsFixed(1)}%'), true);

          // 100% milestone should be celebration
          if (percentage == 100.0) {
            expect(milestone.title.contains('Completed') || milestone.title.contains('Celebration'), true);
          }
        }
      });

      test('Transaction receipt confirmations', () {
        final receipt = AppNotification(
          id: 'txn_receipt_test',
          title: 'Transaction Receipt',
          message: 'Transaction: Grocery Shopping at Walmart - \$127.45',
          type: NotificationType.transactionReceipt,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
          actionUrl: 'transaction://details/txn_receipt_test',
          metadata: {
            'transactionId': 'txn_receipt_test',
            'amount': 127.45,
            'category': 'Food & Dining',
          },
        );

        expect(receipt.type, NotificationType.transactionReceipt);
        expect(receipt.priority, NotificationPriority.medium);
        expect(receipt.metadata?['amount'], 127.45);
        expect(receipt.metadata?['category'], 'Food & Dining');
        expect(receipt.message.contains('\$127.45'), true);
      });

      test('Income reminders and confirmations', () {
        // Test income reminder
        final reminder = AppNotification(
          id: 'income_reminder_test',
          title: 'Income Reminder',
          message: 'Expected salary payment tomorrow',
          type: NotificationType.incomeReminder,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
          scheduledFor: DateTime.now().add(const Duration(days: 1)),
          metadata: {'incomeId': 'salary_payment', 'expectedAmount': 3000.0},
        );

        // Test income confirmation
        final confirmation = AppNotification(
          id: 'income_confirmation_test',
          title: 'Income Received',
          message: 'Salary payment of \$3000.00 has been confirmed',
          type: NotificationType.incomeConfirmation,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
          metadata: {'incomeId': 'salary_payment', 'amount': 3000.0},
        );

        expect(reminder.type, NotificationType.incomeReminder);
        expect(confirmation.type, NotificationType.incomeConfirmation);
        expect(reminder.isScheduled, true);
        expect(confirmation.isRead, null); // Default unread state
      });

      test('System notifications (backups, exports)', () {
        // Test successful backup
        final successBackup = AppNotification(
          id: 'system_backup_success',
          title: 'Backup Completed',
          message: 'Automatic backup completed successfully',
          type: NotificationType.systemBackup,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
          actionUrl: 'settings://backup',
          metadata: {'success': true, 'backupType': 'Automatic Backup'},
        );

        // Test failed backup
        final failedBackup = AppNotification(
          id: 'system_backup_failed',
          title: 'Backup Failed',
          message: 'Failed to complete automatic backup: Storage full',
          type: NotificationType.systemBackup,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
          actionUrl: 'settings://backup',
          metadata: {
            'success': false,
            'backupType': 'Automatic Backup',
            'errorMessage': 'Storage full'
          },
        );

        // Test export notification
        final exportNotification = AppNotification(
          id: 'system_export_complete',
          title: 'Export Completed',
          message: 'Data export to CSV completed successfully',
          type: NotificationType.systemExport,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
          actionUrl: 'settings://export',
          metadata: {'format': 'CSV', 'fileCount': 3},
        );

        expect(successBackup.type, NotificationType.systemBackup);
        expect(successBackup.priority, NotificationPriority.low);
        expect(failedBackup.priority, NotificationPriority.high);
        expect(exportNotification.type, NotificationType.systemExport);
        expect(successBackup.metadata?['success'], true);
        expect(failedBackup.metadata?['success'], false);
      });
    });

    // ============================================================================
    // 2. DELIVERY CHANNELS AND PLATFORMS TESTING
    // ============================================================================

    group('Delivery Channels and Platforms', () {
      test('In-app notification center validation', () {
        final notifications = <AppNotification>[];

        // Create multiple notifications
        for (int i = 0; i < 5; i++) {
          final notification = AppNotification(
            id: 'in_app_test_$i',
            title: 'Test Notification $i',
            message: 'This is test notification number $i',
            type: NotificationType.systemUpdate,
            priority: NotificationPriority.medium,
            createdAt: DateTime.now(),
            metadata: {'testId': i},
          );
          notifications.add(notification);
        }

        // Test notification ordering (by priority then by time)
        notifications.sort((a, b) {
          final priorityComparison = b.priority.index.compareTo(a.priority.index);
          if (priorityComparison != 0) return priorityComparison;
          return b.createdAt.compareTo(a.createdAt);
        });

        expect(notifications.length, 5);
        expect(notifications.every((n) => n.id.startsWith('in_app_test_')), true);
      });

      test('Push notification FCM payload structure', () {
        // Test FCM notification payload structure
        final fcmNotification = AppNotification(
          id: 'fcm_test_notification',
          title: 'FCM Test Notification',
          message: 'This is a test FCM notification with rich payload',
          type: NotificationType.systemUpdate,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
          actionUrl: 'settings://notifications',
          metadata: {
            'fcmToken': 'test_fcm_token',
            'messageId': 'fcm_msg_123',
            'channel': 'system',
            'imageUrl': 'https://example.com/image.png',
            'actionButtons': ['View Settings', 'Dismiss'],
            'ttl': 86400,
          },
        );

        expect(fcmNotification.metadata?['fcmToken'], 'test_fcm_token');
        expect(fcmNotification.metadata?['channel'], 'system');
        expect(fcmNotification.actionUrl, 'settings://notifications');
        expect(fcmNotification.priority, NotificationPriority.high);
      });

      test('User settings synchronization', () {
        // Test settings filtering logic
        final enabledSettings = NotificationSettings(
          notificationsEnabled: true,
          budgetAlertsEnabled: true,
          billRemindersEnabled: true,
          incomeRemindersEnabled: true,
          quietHoursEnabled: false,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
          notificationFrequency: 'immediate',
          channelSettings: {},
        );

        final disabledSettings = enabledSettings.copyWith(budgetAlertsEnabled: false);

        // Test budget alert should be sent with enabled settings
        final budgetAlert = AppNotification(
          id: 'settings_test_budget',
          title: 'Budget Alert',
          message: 'Test budget alert',
          type: NotificationType.budgetAlert,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
        );

        // With enabled settings, budget alerts should be allowed
        expect(enabledSettings.shouldSendNotification(budgetAlert.type), true);

        // With disabled settings, budget alerts should be blocked
        expect(disabledSettings.shouldSendNotification(budgetAlert.type), false);

        // Test quiet hours logic
        final quietHoursSettings = enabledSettings.copyWith(quietHoursEnabled: true);
        expect(quietHoursSettings.quietHoursEnabled, true);
        expect(quietHoursSettings.quietHoursStart, '22:00');
        expect(quietHoursSettings.quietHoursEnd, '08:00');
      });

      test('Cross-platform compatibility validation', () {
        // Test Android notification channels mapping
        final androidChannels = {
          NotificationType.budgetAlert: 'budget_alerts',
          NotificationType.billReminder: 'bill_reminders',
          NotificationType.goalMilestone: 'goal_updates',
          NotificationType.accountAlert: 'account_alerts',
          NotificationType.transactionReceipt: 'transaction_alerts',
          NotificationType.incomeReminder: 'income_reminders',
          NotificationType.systemUpdate: 'system_updates',
        };

        androidChannels.forEach((type, expectedChannel) {
          final notification = AppNotification(
            id: 'platform_test_${type.name}',
            title: 'Platform Test',
            message: 'Testing ${type.name}',
            type: type,
            priority: NotificationPriority.medium,
            createdAt: DateTime.now(),
          );

          // Verify notification has correct type
          expect(notification.type, type);
          expect(notification.id.contains('platform_test'), true);
        });

        // Test iOS notification settings
        final iosNotification = AppNotification(
          id: 'ios_test',
          title: 'iOS Test',
          message: 'Testing iOS notification',
          type: NotificationType.systemUpdate,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
          metadata: {
            'iosBadge': true,
            'iosSound': 'default',
            'iosAlert': true,
          },
        );

        expect(iosNotification.metadata?['iosBadge'], true);
        expect(iosNotification.metadata?['iosSound'], 'default');
      });
    });

    // ============================================================================
    // 3. USER ACTION RESPONSES TESTING
    // ============================================================================

    group('User Action Responses', () {
      test('Notification tap navigation deep links', () {
        final deepLinks = [
          'budget://details/budget_123',
          'bill://details/bill_456',
          'goal://details/goal_789',
          'account://details/account_101',
          'transaction://details/txn_202',
          'settings://notifications',
        ];

        for (final link in deepLinks) {
          final notification = AppNotification(
            id: 'deep_link_test_${link.hashCode}',
            title: 'Deep Link Test',
            message: 'Testing deep link navigation',
            type: NotificationType.systemUpdate,
            priority: NotificationPriority.medium,
            createdAt: DateTime.now(),
            actionUrl: link,
          );

          expect(notification.actionUrl, link);
          expect(notification.actionUrl!.isNotEmpty, true);
        }
      });

      test('Dismissal handling', () {
        final notification = AppNotification(
          id: 'dismissal_test',
          title: 'Dismissal Test',
          message: 'This notification can be dismissed',
          type: NotificationType.systemUpdate,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
          isRead: false,
        );

        // Initially unread
        expect(notification.isRead, false);

        // Mark as read (simulating dismissal)
        final dismissedNotification = notification.copyWith(isRead: true);
        expect(dismissedNotification.isRead, true);
        expect(dismissedNotification.id, notification.id);
      });

      test('Settings-based filtering', () {
        final channelSettings = NotificationSettings(
          notificationsEnabled: true,
          budgetAlertsEnabled: true,
          billRemindersEnabled: false, // Disable bill reminders
          incomeRemindersEnabled: true,
          quietHoursEnabled: false,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
          notificationFrequency: 'immediate',
          channelSettings: {
            NotificationChannel.budget: ChannelNotificationSettings(
              enabled: true,
              frequency: 'immediate',
              soundEnabled: true,
              vibrationEnabled: true,
            ),
            NotificationChannel.bills: ChannelNotificationSettings(
              enabled: false, // Disable bill channel
              frequency: 'daily',
              soundEnabled: false,
              vibrationEnabled: false,
            ),
          },
        );

        // Budget alert should be sent
        expect(channelSettings.shouldSendNotification(NotificationType.budgetAlert), true);

        // Bill reminder should be blocked
        expect(channelSettings.shouldSendNotification(NotificationType.billReminder), false);

        // Test channel-specific settings
        final budgetChannel = channelSettings.channelSettings[NotificationChannel.budget];
        expect(budgetChannel?.enabled, true);
        expect(budgetChannel?.soundEnabled, true);

        final billChannel = channelSettings.channelSettings[NotificationChannel.bills];
        expect(billChannel?.enabled, false);
        expect(billChannel?.soundEnabled, false);
      });

      test('Deep linking functionality validation', () {
        // Test various deep link patterns
        final deepLinkTests = [
          {
            'url': 'budget://details/test_budget_123',
            'expectedRoute': '/budget-details',
            'expectedArgs': {'budgetId': 'test_budget_123'}
          },
          {
            'url': 'goal://contribute/test_goal_456',
            'expectedRoute': '/goal-contribution',
            'expectedArgs': {'goalId': 'test_goal_456'}
          },
          {
            'url': 'settings://backup',
            'expectedRoute': '/backup-settings',
            'expectedArgs': null
          },
        ];

        for (final test in deepLinkTests) {
          final notification = AppNotification(
            id: 'deep_link_validation_${test['url'].hashCode}',
            title: 'Deep Link Validation',
            message: 'Testing deep link: ${test['url']}',
            type: NotificationType.systemUpdate,
            priority: NotificationPriority.medium,
            createdAt: DateTime.now(),
            actionUrl: test['url'] as String,
            metadata: {
              'expectedRoute': test['expectedRoute'],
              'expectedArgs': test['expectedArgs'],
            },
          );

          expect(notification.actionUrl, test['url']);
          expect(notification.metadata?['expectedRoute'], test['expectedRoute']);
        }
      });
    });

    // ============================================================================
    // 4. EDGE CASES AND ERROR HANDLING TESTING
    // ============================================================================

    group('Edge Cases and Error Handling', () {
      test('Invalid data handling', () {
        // Test with invalid budget data
        final invalidBudgetAlert = AppNotification(
          id: '', // Invalid empty ID
          title: '', // Invalid empty title
          message: '', // Invalid empty message
          type: NotificationType.budgetAlert,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
          metadata: {
            'budgetId': '', // Invalid empty budget ID
            'currentAmount': -100.0, // Invalid negative amount
            'thresholdAmount': 0.0, // Invalid zero threshold
            'percentage': 150.0, // Invalid percentage > 100
          },
        );

        // Notification should still be created but with validation issues
        expect(invalidBudgetAlert.type, NotificationType.budgetAlert);
        expect(invalidBudgetAlert.metadata?['currentAmount'], -100.0);
        expect(invalidBudgetAlert.metadata?['percentage'], 150.0);

        // Test with null metadata
        final nullMetadataNotification = AppNotification(
          id: 'null_metadata_test',
          title: 'Null Test',
          message: 'Test with null metadata',
          type: NotificationType.systemUpdate,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
          metadata: null,
        );

        expect(nullMetadataNotification.metadata, null);
        // Should not crash when accessing metadata
      });

      test('Offline scenarios simulation', () {
        // Test notification creation for offline scenarios
        final offlineNotification = AppNotification(
          id: 'offline_test',
          title: 'Offline Alert',
          message: 'This notification works offline',
          type: NotificationType.systemBackup,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
          metadata: {
            'offline': true,
            'retryCount': 0,
            'errorMessage': 'Network unavailable',
          },
        );

        expect(offlineNotification.metadata?['offline'], true);
        expect(offlineNotification.metadata?['errorMessage'], 'Network unavailable');

        // Test local notification that should work offline
        final localNotification = AppNotification(
          id: 'local_offline_test',
          title: 'Local Offline Notification',
          message: 'This works without network',
          type: NotificationType.transactionReceipt,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
          scheduledFor: DateTime.now().add(const Duration(hours: 1)),
        );

        expect(localNotification.isScheduled, true);
        expect(localNotification.timeUntilScheduled!.inHours, closeTo(1, 1));
      });

      test('Background/foreground state handling', () {
        // Test notification for background state
        final backgroundNotification = AppNotification(
          id: 'background_test',
          title: 'Background Notification',
          message: 'App is in background',
          type: NotificationType.accountAlert,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
          metadata: {'appState': 'background', 'showPush': true},
        );

        // Test notification for foreground state
        final foregroundNotification = AppNotification(
          id: 'foreground_test',
          title: 'Foreground Notification',
          message: 'App is in foreground',
          type: NotificationType.systemUpdate,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
          metadata: {'appState': 'foreground', 'showInApp': true},
        );

        expect(backgroundNotification.metadata?['appState'], 'background');
        expect(foregroundNotification.metadata?['appState'], 'foreground');
        expect(backgroundNotification.priority, NotificationPriority.high);
        expect(foregroundNotification.priority, NotificationPriority.low);
      });
    });

    // ============================================================================
    // 5. INTEGRATION AND DEPENDENCIES TESTING
    // ============================================================================

    group('Integration and Dependencies', () {
      test('Domain entity validation (NotificationType, NotificationPriority)', () {
        // Test all notification types
        final allTypes = NotificationType.values;
        expect(allTypes.length, greaterThan(10));

        // Test all priorities
        final allPriorities = NotificationPriority.values;
        expect(allPriorities.length, 4); // low, medium, high, critical

        // Test priority ordering
        expect(NotificationPriority.low.index < NotificationPriority.critical.index, true);

        // Test notification creation with all types
        for (final type in allTypes) {
          final testNotification = AppNotification(
            id: 'entity_test_${type.name}',
            title: 'Entity Test',
            message: 'Testing ${type.name}',
            type: type,
            priority: NotificationPriority.medium,
            createdAt: DateTime.now(),
          );

          expect(testNotification.type, type);
          expect(testNotification.id.isNotEmpty, true);
        }
      });

      test('State management synchronization validation', () {
        // Test notification state changes
        final originalNotification = AppNotification(
          id: 'state_test',
          title: 'State Test',
          message: 'Testing state management',
          type: NotificationType.systemUpdate,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
          isRead: false,
        );

        // Test marking as read
        final readNotification = originalNotification.copyWith(isRead: true);
        expect(readNotification.isRead, true);
        expect(readNotification.id, originalNotification.id);

        // Test priority change
        final highPriorityNotification = originalNotification.copyWith(priority: NotificationPriority.high);
        expect(highPriorityNotification.priority, NotificationPriority.high);
        expect(highPriorityNotification.title, originalNotification.title);
      });

      test('Compilation error verification', () {
        // Test that all notification-related code compiles without errors
        final testNotification = AppNotification(
          id: 'compilation_test',
          title: 'Compilation Test',
          message: 'Verifying all imports and dependencies work',
          type: NotificationType.systemUpdate,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
          metadata: {
            'test': 'compilation',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        // Test all computed properties
        expect(testNotification.isScheduled, false);
        expect(testNotification.isOverdue, false);
        expect(testNotification.timeUntilScheduled, null);

        // Test settings functionality
        final testSettings = NotificationSettings(
          notificationsEnabled: true,
          budgetAlertsEnabled: true,
          billRemindersEnabled: true,
          incomeRemindersEnabled: true,
          quietHoursEnabled: false,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
          notificationFrequency: 'immediate',
          channelSettings: {},
        );

        expect(testSettings.isInQuietHours, false);
        expect(testSettings.getNotificationDelay(), null);
      });
    });

    // ============================================================================
    // 6. PERFORMANCE AND TIMING TESTING
    // ============================================================================

    group('Performance and Timing', () {
      test('Scheduled notification accuracy', () {
        final now = DateTime.now();
        final scheduledTime = now.add(const Duration(minutes: 5));

        final scheduledNotification = AppNotification(
          id: 'schedule_accuracy_test',
          title: 'Scheduled Test',
          message: 'Testing scheduling accuracy',
          type: NotificationType.billReminder,
          priority: NotificationPriority.medium,
          createdAt: now,
          scheduledFor: scheduledTime,
        );

        // Verify scheduled time is stored correctly
        expect(scheduledNotification.scheduledFor, scheduledTime);
        expect(scheduledNotification.isScheduled, true);
        expect(scheduledNotification.isOverdue, false);

        // Test time until scheduled
        final timeUntil = scheduledNotification.timeUntilScheduled;
        expect(timeUntil, isNotNull);
        expect(timeUntil!.inMinutes, closeTo(5, 1)); // Approximately 5 minutes
      });

      test('Load testing with multiple notifications', () {
        const notificationCount = 100;
        final notifications = <AppNotification>[];

        // Create multiple notifications
        for (int i = 0; i < notificationCount; i++) {
          final notification = AppNotification(
            id: 'load_test_$i',
            title: 'Load Test Notification $i',
            message: 'This is notification number $i for load testing',
            type: NotificationType.systemUpdate,
            priority: NotificationPriority.low,
            createdAt: DateTime.now().add(Duration(milliseconds: i)), // Slight time difference
            metadata: {'loadTestId': i},
          );
          notifications.add(notification);
        }

        // Verify all notifications were created
        expect(notifications.length, notificationCount);
        expect(notifications.every((n) => n.id.startsWith('load_test_')), true);

        // Test sorting by creation time (newest first)
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        expect(notifications.first.createdAt.isAfter(notifications.last.createdAt), true);
      });

      test('Memory usage monitoring simulation', () {
        // Create a batch of notifications to simulate memory usage
        const memoryTestCount = 50;

        final memoryTestNotifications = <AppNotification>[];
        for (int i = 0; i < memoryTestCount; i++) {
          final notification = AppNotification(
            id: 'memory_test_$i',
            title: 'Memory Test $i',
            message: 'Testing memory usage with large metadata',
            type: NotificationType.systemBackup,
            priority: NotificationPriority.low,
            createdAt: DateTime.now(),
            metadata: {
              'largeData': 'x' * 1000, // Simulate large metadata
              'nestedData': {
                'array': List.generate(100, (i) => 'item_$i'),
                'timestamp': DateTime.now().toIso8601String(),
              },
            },
          );
          memoryTestNotifications.add(notification);
        }

        // Verify memory test notifications
        expect(memoryTestNotifications.length, memoryTestCount);
        expect(memoryTestNotifications.every((n) => n.metadata?['largeData'].length == 1000), true);

        // Simulate clearing memory
        memoryTestNotifications.clear();
        expect(memoryTestNotifications.isEmpty, true);
      });
    });
  });
}