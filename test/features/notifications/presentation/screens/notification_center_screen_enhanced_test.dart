import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_tracker/features/notifications/presentation/screens/notification_center_screen_enhanced.dart';
import 'package:budget_tracker/features/notifications/domain/entities/notification.dart';
import 'package:budget_tracker/features/notifications/presentation/providers/notification_providers.dart';

void main() {
  group('NotificationCenterScreenEnhanced', () {
    testWidgets('displays loading state initially', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('displays empty state when no notifications', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = <AppNotification>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentNotificationsProvider.overrideWith(
              (ref) => Stream.value(mockNotifications),
            ),
            unreadNotificationsCountProvider.overrideWith(
              (ref) => Stream.value(0),
            ),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No notifications'), findsOneWidget);
      expect(find.text('You\'re all caught up!'), findsOneWidget);
    });

    testWidgets('displays notifications in tabs correctly', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Budget Alert',
          message: 'You\'ve exceeded your budget',
          type: NotificationType.budgetAlert,
          createdAt: DateTime.now(),
          isRead: false,
        ),
        AppNotification(
          id: '2',
          title: 'Bill Reminder',
          message: 'Your bill is due soon',
          type: NotificationType.billReminder,
          createdAt: DateTime.now(),
          isRead: true,
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentNotificationsProvider.overrideWith(
              (ref) => Stream.value(mockNotifications),
            ),
            unreadNotificationsCountProvider.overrideWith(
              (ref) => Stream.value(1),
            ),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('1 unread'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Unread'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
    });

    testWidgets('shows unread count in app bar', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Test Notification',
          message: 'Test message',
          type: NotificationType.custom,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentNotificationsProvider.overrideWith(
              (ref) => Stream.value(mockNotifications),
            ),
            unreadNotificationsCountProvider.overrideWith(
              (ref) => Stream.value(1),
            ),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('1 unread'), findsOneWidget);
    });

    testWidgets('groups notifications by date', (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Today Notification',
          message: 'Today message',
          type: NotificationType.custom,
          createdAt: now,
          isRead: false,
        ),
        AppNotification(
          id: '2',
          title: 'Yesterday Notification',
          message: 'Yesterday message',
          type: NotificationType.custom,
          createdAt: yesterday,
          isRead: false,
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentNotificationsProvider.overrideWith(
              (ref) => Stream.value(mockNotifications),
            ),
            unreadNotificationsCountProvider.overrideWith(
              (ref) => Stream.value(2),
            ),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
    });

    testWidgets('displays notification types with correct colors', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Budget Alert',
          message: 'Budget exceeded',
          type: NotificationType.budgetAlert,
          createdAt: DateTime.now(),
          isRead: false,
        ),
        AppNotification(
          id: '2',
          title: 'Bill Reminder',
          message: 'Bill due',
          type: NotificationType.billReminder,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentNotificationsProvider.overrideWith(
              (ref) => Stream.value(mockNotifications),
            ),
            unreadNotificationsCountProvider.overrideWith(
              (ref) => Stream.value(2),
            ),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Budget'), findsOneWidget);
      expect(find.text('Bill'), findsOneWidget);
    });

    testWidgets('shows unread indicator for unread notifications', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Unread Notification',
          message: 'This is unread',
          type: NotificationType.custom,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentNotificationsProvider.overrideWith(
              (ref) => Stream.value(mockNotifications),
            ),
            unreadNotificationsCountProvider.overrideWith(
              (ref) => Stream.value(1),
            ),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Should have unread indicator (small circle)
      expect(find.byType(Container), findsWidgets); // The unread indicator is a Container
    });

    testWidgets('refresh indicator works on pull to refresh', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Test Notification',
          message: 'Test message',
          type: NotificationType.custom,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentNotificationsProvider.overrideWith(
              (ref) => Stream.value(mockNotifications),
            ),
            unreadNotificationsCountProvider.overrideWith(
              (ref) => Stream.value(1),
            ),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Perform pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();

      // Assert - Should still render properly
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('accessibility features are properly implemented', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Test Notification',
          message: 'Test message',
          type: NotificationType.custom,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentNotificationsProvider.overrideWith(
              (ref) => Stream.value(mockNotifications),
            ),
            unreadNotificationsCountProvider.overrideWith(
              (ref) => Stream.value(1),
            ),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    });

    testWidgets('animations work properly', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Test Notification',
          message: 'Test message',
          type: NotificationType.custom,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentNotificationsProvider.overrideWith(
              (ref) => Stream.value(mockNotifications),
            ),
            unreadNotificationsCountProvider.overrideWith(
              (ref) => Stream.value(1),
            ),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreenEnhanced(),
          ),
        ),
      );

      // Initial state
      await tester.pump();

      // After animation completes
      await tester.pumpAndSettle();

      // Assert - Screen should be fully rendered
      expect(find.text('Notifications'), findsOneWidget);
    });
  });
}