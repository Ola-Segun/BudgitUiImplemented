import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/features/notifications/domain/entities/notification_analytics.dart';

void main() {
  group('NotificationAnalytics', () {
    final testId = 'test_id';
    final testNotificationId = 'notification_123';
    final testSentAt = DateTime(2023, 1, 1, 10, 0, 0);
    final testReadAt = DateTime(2023, 1, 1, 10, 5, 0);
    final testClickedAt = DateTime(2023, 1, 1, 10, 10, 0);
    final testActionTaken = 'read';
    final testMetadata = {'source': 'test'};

    test('should create NotificationAnalytics with required fields', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
      );

      expect(analytics.id, testId);
      expect(analytics.notificationId, testNotificationId);
      expect(analytics.sentAt, testSentAt);
      expect(analytics.readAt, isNull);
      expect(analytics.clickedAt, isNull);
      expect(analytics.actionTaken, isNull);
      expect(analytics.metadata, isNull);
    });

    test('should create NotificationAnalytics with all fields', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
        readAt: testReadAt,
        clickedAt: testClickedAt,
        actionTaken: testActionTaken,
        metadata: testMetadata,
      );

      expect(analytics.id, testId);
      expect(analytics.notificationId, testNotificationId);
      expect(analytics.sentAt, testSentAt);
      expect(analytics.readAt, testReadAt);
      expect(analytics.clickedAt, testClickedAt);
      expect(analytics.actionTaken, testActionTaken);
      expect(analytics.metadata, testMetadata);
    });

    test('wasRead should return true when readAt is not null', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
        readAt: testReadAt,
      );

      expect(analytics.wasRead, isTrue);
    });

    test('wasRead should return false when readAt is null', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
      );

      expect(analytics.wasRead, isFalse);
    });

    test('wasClicked should return true when clickedAt is not null', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
        clickedAt: testClickedAt,
      );

      expect(analytics.wasClicked, isTrue);
    });

    test('wasClicked should return false when clickedAt is null', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
      );

      expect(analytics.wasClicked, isFalse);
    });

    test('timeToRead should return correct duration when read', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
        readAt: testReadAt,
      );

      final expectedDuration = testReadAt.difference(testSentAt);
      expect(analytics.timeToRead, expectedDuration);
    });

    test('timeToRead should return null when not read', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
      );

      expect(analytics.timeToRead, isNull);
    });

    test('timeToClick should return correct duration when clicked', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
        clickedAt: testClickedAt,
      );

      final expectedDuration = testClickedAt.difference(testSentAt);
      expect(analytics.timeToClick, expectedDuration);
    });

    test('timeToClick should return null when not clicked', () {
      final analytics = NotificationAnalytics(
        id: testId,
        notificationId: testNotificationId,
        sentAt: testSentAt,
      );

      expect(analytics.timeToClick, isNull);
    });
  });

  group('NotificationAction', () {
    test('should have correct enum values', () {
      expect(NotificationAction.markAsRead, equals(NotificationAction.markAsRead));
      expect(NotificationAction.dismiss, equals(NotificationAction.dismiss));
      expect(NotificationAction.navigateToScreen, equals(NotificationAction.navigateToScreen));
      expect(NotificationAction.performAction, equals(NotificationAction.performAction));
      expect(NotificationAction.custom, equals(NotificationAction.custom));
    });
  });
}