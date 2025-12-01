import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../recurring_incomes/domain/entities/recurring_income.dart';
import '../../../recurring_incomes/domain/repositories/recurring_income_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/notification.dart';

/// Use case for checking income reminders
class CheckIncomeReminders {
  const CheckIncomeReminders(
    this._recurringIncomeRepository,
    this._settingsRepository,
  );

  final RecurringIncomeRepository _recurringIncomeRepository;
  final SettingsRepository _settingsRepository;

  /// Check for income reminders and return notifications
  Future<Result<List<AppNotification>>> call() async {
    try {
      // Get settings to check if notifications are enabled
      final settingsResult = await _settingsRepository.getSettings();
      if (settingsResult.isError) {
        return Result.error(settingsResult.failureOrNull!);
      }

      final settings = settingsResult.dataOrNull!;
      if (!settings.notificationsEnabled || !settings.incomeRemindersEnabled) {
        return const Result.success([]);
      }

      // Get all recurring incomes
      final incomesResult = await _recurringIncomeRepository.getAll();
      if (incomesResult.isError) {
        return Result.error(incomesResult.failureOrNull!);
      }

      final incomes = incomesResult.dataOrNull!;
      final notifications = <AppNotification>[];

      for (final income in incomes) {
        if (!income.hasEnded) {
          final incomeNotifications = await _checkIncomeReminders(income);
          notifications.addAll(incomeNotifications);
        }
      }

      return Result.success(notifications);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to check income reminders: $e'));
    }
  }

  Future<List<AppNotification>> _checkIncomeReminders(RecurringIncome income) async {
    final notifications = <AppNotification>[];

    // Check for expected soon incomes
    if (income.isExpectedSoon) {
      notifications.add(_createExpectedSoonNotification(income));
    }

    // Check for overdue incomes
    if (income.isOverdue) {
      notifications.add(_createOverdueNotification(income));
    }

    return notifications;
  }

  AppNotification _createExpectedSoonNotification(RecurringIncome income) {
    final daysUntil = income.daysUntilNextExpected;
    final message = daysUntil == 0
        ? 'Your ${income.name} income is expected today (\$${income.amount.toStringAsFixed(2)}).'
        : 'Your ${income.name} income is expected in $daysUntil days (\$${income.amount.toStringAsFixed(2)}).';

    return AppNotification(
      id: 'income_expected_${income.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Income Expected Soon: ${income.name}',
      message: message,
      type: NotificationType.incomeReminder,
      priority: daysUntil <= 1 ? NotificationPriority.high : NotificationPriority.medium,
      createdAt: DateTime.now(),
      metadata: {
        'incomeId': income.id,
        'amount': income.amount,
        'daysUntilExpected': daysUntil,
        'frequency': income.frequency.name,
      },
    );
  }

  AppNotification _createOverdueNotification(RecurringIncome income) {
    final daysOverdue = -income.daysUntilNextExpected;
    return AppNotification(
      id: 'income_overdue_${income.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Income Overdue: ${income.name}',
      message: 'Your ${income.name} income is $daysOverdue days overdue (\$${income.amount.toStringAsFixed(2)}).',
      type: NotificationType.incomeReminder,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      metadata: {
        'incomeId': income.id,
        'amount': income.amount,
        'daysOverdue': daysOverdue,
        'frequency': income.frequency.name,
      },
    );
  }
}