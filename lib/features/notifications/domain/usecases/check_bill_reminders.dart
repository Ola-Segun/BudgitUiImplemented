import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../bills/domain/entities/bill.dart';
import '../../../bills/domain/repositories/bill_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../settings/domain/services/formatting_service.dart';
import '../entities/notification.dart';

/// Use case for checking bill reminders
class CheckBillReminders {
  const CheckBillReminders(
    this._billRepository,
    this._settingsRepository,
    this._formattingService,
  );

  final BillRepository _billRepository;
  final SettingsRepository _settingsRepository;
  final FormattingService _formattingService;

  /// Check for bill reminders and return notifications
  Future<Result<List<AppNotification>>> call() async {
    try {
      // Get settings to check if bill reminders are enabled
      final settingsResult = await _settingsRepository.getSettings();
      if (settingsResult.isError) {
        return Result.error(settingsResult.failureOrNull!);
      }

      final settings = settingsResult.dataOrNull!;
      if (!settings.billRemindersEnabled) {
        return const Result.success([]);
      }

      // Get all bills
      final billsResult = await _billRepository.getAll();
      if (billsResult.isError) {
        return Result.error(billsResult.failureOrNull!);
      }

      final bills = billsResult.dataOrNull!;
      final notifications = <AppNotification>[];

      for (final bill in bills) {
        final billReminders = _createBillReminders(bill);
        notifications.addAll(billReminders);
      }

      return Result.success(notifications);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to check bill reminders: $e'));
    }
  }

  List<AppNotification> _createBillReminders(Bill bill) {
    // Skip if bill is already paid
    if (bill.isPaid) return [];

    final notifications = <AppNotification>[];
    final now = DateTime.now();
    final daysUntilDue = bill.daysUntilDue;

    // Define reminder intervals as per Guide.md (lines 703-709)
    final formattedAmount = _formattingService.formatCurrency(bill.amount);
    final reminderIntervals = [
      {'days': 7, 'message': '${bill.name} due in one week ($formattedAmount)'},
      {'days': 3, 'message': '${bill.name} due soon'},
      {'days': 1, 'message': 'Reminder: ${bill.name} due tomorrow'},
      {'days': 0, 'message': '${bill.name} is due today'},
    ];

    // Check each reminder interval
    for (final interval in reminderIntervals) {
      final daysBefore = interval['days'] as int;
      final message = interval['message'] as String;

      // Calculate when this reminder should be shown
      final reminderDate = bill.dueDate.subtract(Duration(days: daysBefore));

      // Only create reminder if it's time to show it (within reasonable window)
      if (reminderDate.isBefore(now) || reminderDate.isAtSameMomentAs(now)) {
        final priority = bill.isOverdue
            ? NotificationPriority.critical
            : daysBefore == 0
                ? NotificationPriority.high
                : daysBefore <= 3
                    ? NotificationPriority.medium
                    : NotificationPriority.low;

        final title = bill.isOverdue
            ? '⚠️ ${bill.name} payment overdue'
            : daysBefore == 7
                ? 'Bill Reminder'
                : daysBefore == 3
                    ? 'Bill Reminder'
                    : daysBefore == 1
                        ? 'Bill Reminder'
                        : 'Bill Due Today';

        notifications.add(AppNotification(
          id: 'bill_reminder_${bill.id}_${daysBefore}_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          message: message,
          type: NotificationType.billReminder,
          priority: priority,
          createdAt: DateTime.now(),
          scheduledFor: reminderDate,
          metadata: {
            'billId': bill.id,
            'dueDate': bill.dueDate.toString().split(' ')[0],
            'amount': bill.amount,
            'daysUntilDue': daysUntilDue,
            'isOverdue': bill.isOverdue,
            'reminderType': daysBefore == 7 ? '7_days' : daysBefore == 3 ? '3_days' : daysBefore == 1 ? '1_day' : 'due_today',
          },
        ));
      }
    }

    // Special handling for overdue bills
    if (bill.isOverdue) {
      notifications.add(AppNotification(
        id: 'bill_overdue_${bill.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: '⚠️ ${bill.name} payment overdue',
        message: '⚠️ ${bill.name} payment overdue',
        type: NotificationType.billReminder,
        priority: NotificationPriority.critical,
        createdAt: DateTime.now(),
        scheduledFor: bill.dueDate, // Schedule for due date, but show as overdue
        metadata: {
          'billId': bill.id,
          'dueDate': bill.dueDate.toString().split(' ')[0],
          'amount': bill.amount,
          'daysUntilDue': daysUntilDue,
          'isOverdue': true,
          'reminderType': 'overdue',
        },
      ));
    }

    return notifications;
  }
}