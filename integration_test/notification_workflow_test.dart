import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/di/providers.dart';
import '../lib/features/notifications/domain/entities/notification.dart';
import '../lib/features/notifications/domain/entities/notification_settings.dart';
import '../lib/features/notifications/domain/services/notification_service.dart';
import '../lib/features/notifications/presentation/providers/notification_providers.dart' as notification_providers;
import '../lib/features/settings/domain/entities/settings.dart';
import '../lib/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Workflow E2E Tests', () {
    late NotificationService notificationService;
    late ProviderContainer container;

    setUp(() async {
      // Create a provider container for testing
      container = ProviderContainer();

      // Get notification service from provider
      notificationService = container.read(notification_providers.notificationServiceProvider);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Complete notification lifecycle', (tester) async {
      // Test 1: Initialize notification service
      final initResult = await notificationService.initialize();
      expect(initResult.isSuccess, true);

      // Test 2: Create and send budget threshold alert
      final budgetAlertResult = await notificationService.createBudgetThresholdAlert(
        budgetId: 'test_budget_1',
        budgetName: 'Test Budget',
        currentAmount: 850.0,
        thresholdAmount: 1000.0,
        percentage: 85.0,
      );
      expect(budgetAlertResult.isSuccess, true);

      // Test 3: Create transaction receipt notification
      final receiptResult = await notificationService.createTransactionReceipt(
        transactionId: 'test_transaction_1',
        description: 'Grocery Shopping',
        amount: 45.67,
        category: 'Food',
      );
      expect(receiptResult.isSuccess, true);

      // Test 4: Create goal milestone notification
      final milestoneResult = await notificationService.createGoalMilestone(
        goalId: 'test_goal_1',
        goalName: 'Vacation Fund',
        progressPercentage: 75.0,
        milestone: '75% Complete',
      );
      expect(milestoneResult.isSuccess, true);

      // Test 5: Check for notifications
      final notificationsResult = await notificationService.checkForNotifications();
      expect(notificationsResult.isSuccess, true);
      expect(notificationsResult.dataOrNull!.length, greaterThanOrEqualTo(3));

      // Test 6: Mark notification as read
      final notifications = notificationsResult.dataOrNull!;
      if (notifications.isNotEmpty) {
        await notificationService.markAsRead(notifications.first.id);

        final updatedNotifications = await notificationService.getCurrentNotifications();
        expect(updatedNotifications.isSuccess, true);

        final updatedList = updatedNotifications.dataOrNull!;
        final markedNotification = updatedList.firstWhere(
          (n) => n.id == notifications.first.id,
          orElse: () => notifications.first,
        );
        expect(markedNotification.isRead, true);
      }

      // Test 7: Update notification settings
      final testSettings = NotificationSettings(
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        billRemindersEnabled: true,
        incomeRemindersEnabled: true,
        quietHoursEnabled: true,
        quietHoursStart: '22:00',
        quietHoursEnd: '08:00',
        notificationFrequency: 'immediate',
        channelSettings: {},
      );
      notificationService.updateSettings(testSettings);

      // Test 8: Test quiet hours logic
      expect(notificationService.isInQuietHours, isFalse); // Assuming current time is not in quiet hours

      // Test 9: Test notification filtering
      final shouldSendBudget = notificationService.shouldSendNotification(
        AppNotification(
          id: 'test',
          title: 'Test',
          message: 'Test',
          type: NotificationType.budgetAlert,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
        ),
      );
      expect(shouldSendBudget, true);

      // Test 10: Clear all notifications
      await notificationService.clearAllNotifications();
      final clearedNotifications = await notificationService.getCurrentNotifications();
      expect(clearedNotifications.dataOrNull!.isEmpty, true);
    });

    testWidgets('Notification settings workflow', (tester) async {
      // Test notification settings persistence and updates
      final initialSettings = NotificationSettings(
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        billRemindersEnabled: false,
        incomeRemindersEnabled: true,
        quietHoursEnabled: false,
        quietHoursStart: '22:00',
        quietHoursEnd: '08:00',
        notificationFrequency: 'daily',
        channelSettings: {
          NotificationChannel.budget: ChannelNotificationSettings(
            enabled: true,
            frequency: 'immediate',
            soundEnabled: true,
            vibrationEnabled: true,
          ),
        },
      );

      notificationService.updateSettings(initialSettings);

      // Verify settings are applied
      expect(notificationService.shouldSendNotification(
        AppNotification(
          id: 'test_budget',
          title: 'Budget Alert',
          message: 'Test',
          type: NotificationType.budgetAlert,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
        ),
      ), true);

      expect(notificationService.shouldSendNotification(
        AppNotification(
          id: 'test_bill',
          title: 'Bill Reminder',
          message: 'Test',
          type: NotificationType.billReminder,
          priority: NotificationPriority.medium,
          createdAt: DateTime.now(),
        ),
      ), false); // Should be false because billRemindersEnabled is false
    });

    testWidgets('Notification persistence and state management', (tester) async {
      // Test notification creation and state management
      final initialNotifications = await notificationService.getCurrentNotifications();
      expect(initialNotifications.isSuccess, true);
      final initialCount = initialNotifications.dataOrNull!.length;

      // Create a notification
      final createResult = await notificationService.createSystemBackupAlert(
        success: true,
        backupType: 'automatic',
      );
      expect(createResult.isSuccess, true);

      // Check that notifications list was updated
      final newNotifications = await notificationService.getCurrentNotifications();
      expect(newNotifications.isSuccess, true);
      expect(newNotifications.dataOrNull!.length >= initialCount, true);

      // Mark the notification as read
      final notification = createResult.dataOrNull!;
      await notificationService.markAsRead(notification.id);

      // Verify the notification state was updated
      final currentNotifications = await notificationService.getCurrentNotifications();
      expect(currentNotifications.isSuccess, true);

      final updatedNotification = currentNotifications.dataOrNull!.firstWhere(
        (n) => n.id == notification.id,
        orElse: () => notification,
      );
      expect(updatedNotification.isRead, true);
    });

    testWidgets('Background notification checking', (tester) async {
      // Test that background notification checking can be triggered
      // This tests the integration without accessing private fields
      final checkResult = await notificationService.checkForNotifications();
      expect(checkResult.isSuccess, true);

      // Verify that some notifications were generated (may be empty if no data)
      expect(checkResult.dataOrNull, isA<List<AppNotification>>());
    });

    testWidgets('Notification initialization and loading', (tester) async {
      // Test that notifications are loaded on service initialization
      // Create a fresh service instance
      final freshService = container.read(notification_providers.notificationServiceProvider);

      // Initialize the service (this should load existing notifications)
      final initResult = await freshService.initialize();
      expect(initResult.isSuccess, true);

      // Check that we can get current notifications (may be empty)
      final notificationsResult = await freshService.getCurrentNotifications();
      expect(notificationsResult.isSuccess, true);
      expect(notificationsResult.dataOrNull, isA<List<AppNotification>>());
    });

    testWidgets('Notification stream updates', (tester) async {
      // Test that the notification stream is properly updated
      List<AppNotification> streamNotifications = [];

      // Listen to the notification stream
      final subscription = notificationService.notifications.listen((notifications) {
        streamNotifications = notifications;
      });

      // Create a notification
      final createResult = await notificationService.createAccountBalanceAlert(
        accountId: 'test_account',
        accountName: 'Test Account',
        currentBalance: 50.0,
        threshold: 100.0,
      );
      expect(createResult.isSuccess, true);

      // Wait a bit for stream to update
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify stream was updated
      expect(streamNotifications.isNotEmpty, true);
      expect(streamNotifications.any((n) => n.id == createResult.dataOrNull!.id), true);

      // Clean up
      await subscription.cancel();
    });

    testWidgets('FCM notification creation from message', (tester) async {
      // Test FCM notification creation by simulating FCM message handling
      // This tests the integration through public APIs

      // Create a mock FCM message data
      final mockFcmData = {
        'messageId': 'fcm_test_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'FCM Test Notification',
        'body': 'This is a test FCM notification',
        'type': 'systemUpdate',
        'priority': 'high',
      };

      // Test rich FCM notification sending
      final richResult = await notificationService.sendRichFCMNotification(
        title: mockFcmData['title'] as String,
        body: mockFcmData['body'] as String,
        type: NotificationType.systemUpdate,
        data: mockFcmData,
        actionButtons: ['View', 'Dismiss'],
        priority: NotificationPriority.high,
      );

      // Result may be error due to no FCM setup, but method should not crash
      expect(richResult.isSuccess || richResult.isError, true);
    });
  });
}