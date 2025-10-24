import 'package:flutter/material.dart';

import '../../../../core/error/result.dart';
import '../../../bills/domain/entities/bill.dart';
import '../../../recurring_incomes/domain/entities/recurring_income.dart';
import '../../../settings/domain/entities/settings.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for scheduling payment reminders
class SchedulePaymentReminders {
  const SchedulePaymentReminders(this._repository);

  final NotificationRepository _repository;

  /// Schedule reminders for upcoming bills and incomes
  Future<Result<void>> call({
    required List<Bill> bills,
    required List<RecurringIncome> incomes,
    required AppSettings settings,
  }) async {
    try {
      // Only schedule if notifications are enabled
      if (!settings.notificationsEnabled) {
        return Result.success(null);
      }

      final notifications = <AppNotification>[];

      // Schedule bill reminders
      if (settings.billRemindersEnabled) {
        notifications.addAll(_createBillReminders(bills, settings));
      }

      // Schedule income reminders
      if (settings.incomeRemindersEnabled) {
        notifications.addAll(_createIncomeReminders(incomes, settings));
      }

      // Schedule all notifications
      for (final notification in notifications) {
        await _repository.schedule(notification);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to schedule payment reminders: $e'));
    }
  }

  List<AppNotification> _createBillReminders(List<Bill> bills, AppSettings settings) {
    final notifications = <AppNotification>[];

    for (final bill in bills) {
      if (bill.isPaid) continue;

      final daysUntilDue = bill.daysUntilDue;

      // Schedule reminder based on settings
      if (daysUntilDue <= settings.billReminderDays && daysUntilDue >= 0) {
        final scheduledTime = bill.dueDate.subtract(Duration(days: settings.billReminderDays));

        // Only schedule if the time is in the future
        if (scheduledTime.isAfter(DateTime.now())) {
          notifications.add(AppNotification(
            id: 'bill_reminder_${bill.id}',
            title: 'Bill Due Soon',
            message: '${bill.name} is due in $daysUntilDue day${daysUntilDue == 1 ? '' : 's'}',
            type: NotificationType.billReminder,
            priority: daysUntilDue <= 1 ? NotificationPriority.high : NotificationPriority.medium,
            createdAt: DateTime.now(),
            scheduledFor: scheduledTime,
            metadata: {
              'billId': bill.id,
              'amount': bill.amount,
              'dueDate': bill.dueDate.toIso8601String(),
            },
          ));
        }
      }
    }

    return notifications;
  }

  List<AppNotification> _createIncomeReminders(List<RecurringIncome> incomes, AppSettings settings) {
    final notifications = <AppNotification>[];

    for (final income in incomes) {
      if (income.hasEnded) continue;

      final daysUntilExpected = income.daysUntilExpected;

      // Schedule reminder based on settings
      if (daysUntilExpected <= settings.incomeReminderDays && daysUntilExpected >= 0) {
        final expectedDate = income.nextExpectedDate;
        if (expectedDate != null) {
          final scheduledTime = expectedDate.subtract(Duration(days: settings.incomeReminderDays));

          // Only schedule if the time is in the future
          if (scheduledTime.isAfter(DateTime.now())) {
            notifications.add(AppNotification(
              id: 'income_reminder_${income.id}',
              title: 'Income Expected Soon',
              message: '${income.name} is expected in $daysUntilExpected day${daysUntilExpected == 1 ? '' : 's'}',
              type: NotificationType.custom, // Using custom for income reminders
              priority: NotificationPriority.medium,
              createdAt: DateTime.now(),
              scheduledFor: scheduledTime,
              metadata: {
                'incomeId': income.id,
                'amount': income.amount,
                'expectedDate': expectedDate.toIso8601String(),
              },
            ));
          }
        }
      }
    }

    return notifications;
  }
}