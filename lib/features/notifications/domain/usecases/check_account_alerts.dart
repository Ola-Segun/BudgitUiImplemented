import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/notification.dart';

/// Use case for checking account alerts
class CheckAccountAlerts {
  const CheckAccountAlerts(
    this._accountRepository,
    this._settingsRepository,
  );

  final AccountRepository _accountRepository;
  final SettingsRepository _settingsRepository;

  /// Check for account alerts and return notifications
  Future<Result<List<AppNotification>>> call() async {
    try {
      // Get settings to check if notifications are enabled
      final settingsResult = await _settingsRepository.getSettings();
      if (settingsResult.isError) {
        return Result.error(settingsResult.failureOrNull!);
      }

      final settings = settingsResult.dataOrNull!;
      if (!settings.notificationsEnabled) {
        return const Result.success([]);
      }

      // Get all accounts
      final accountsResult = await _accountRepository.getAll();
      if (accountsResult.isError) {
        return Result.error(accountsResult.failureOrNull!);
      }

      final accounts = accountsResult.dataOrNull!;
      final notifications = <AppNotification>[];

      for (final account in accounts) {
        if (account.isActive) {
          final accountNotifications = await _checkAccountAlerts(account);
          notifications.addAll(accountNotifications);
        }
      }

      return Result.success(notifications);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to check account alerts: $e'));
    }
  }

  Future<List<AppNotification>> _checkAccountAlerts(Account account) async {
    final notifications = <AppNotification>[];

    // Check for overdrawn accounts
    if (account.isOverdrawn) {
      notifications.add(_createOverdrawnNotification(account));
    }

    // Check for credit cards over limit
    if (account.isOverLimit) {
      notifications.add(_createOverLimitNotification(account));
    }

    // Check for accounts needing reconciliation
    if (account.needsReconciliation) {
      notifications.add(_createReconciliationNeededNotification(account));
    }

    // Check for low balance warnings (for bank accounts)
    if (account.type == AccountType.bankAccount && account.currentBalance < 100) {
      notifications.add(_createLowBalanceNotification(account));
    }

    // Check for upcoming due dates (loans/credit cards)
    if (account.dueDate != null) {
      final daysUntilDue = account.dueDate!.difference(DateTime.now()).inDays;
      if (daysUntilDue >= 0 && daysUntilDue <= 7) {
        notifications.add(_createDueDateNotification(account, daysUntilDue));
      }
    }

    return notifications;
  }

  AppNotification _createOverdrawnNotification(Account account) {
    return AppNotification(
      id: 'account_overdrawn_${account.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Account Overdrawn: ${account.name}',
      message: 'Your ${account.name} account is overdrawn with a balance of \$${account.currentBalance.toStringAsFixed(2)}.',
      type: NotificationType.accountAlert,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      metadata: {
        'accountId': account.id,
        'alertType': 'overdrawn',
        'currentBalance': account.currentBalance,
      },
    );
  }

  AppNotification _createOverLimitNotification(Account account) {
    final overLimitAmount = account.currentBalance - (account.creditLimit ?? 0);
    return AppNotification(
      id: 'account_over_limit_${account.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Credit Card Over Limit: ${account.name}',
      message: 'Your ${account.name} credit card is over the limit by \$${overLimitAmount.toStringAsFixed(2)}.',
      type: NotificationType.accountAlert,
      priority: NotificationPriority.critical,
      createdAt: DateTime.now(),
      metadata: {
        'accountId': account.id,
        'alertType': 'over_limit',
        'creditLimit': account.creditLimit,
        'currentBalance': account.currentBalance,
        'overLimitAmount': overLimitAmount,
      },
    );
  }

  AppNotification _createReconciliationNeededNotification(Account account) {
    final discrepancy = account.balanceDiscrepancy ?? 0;
    return AppNotification(
      id: 'account_reconciliation_${account.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Account Reconciliation Needed: ${account.name}',
      message: 'Your ${account.name} account has a balance discrepancy of \$${discrepancy.abs().toStringAsFixed(2)}. Please reconcile your transactions.',
      type: NotificationType.accountAlert,
      priority: NotificationPriority.medium,
      createdAt: DateTime.now(),
      metadata: {
        'accountId': account.id,
        'alertType': 'reconciliation_needed',
        'discrepancy': discrepancy,
      },
    );
  }

  AppNotification _createLowBalanceNotification(Account account) {
    return AppNotification(
      id: 'account_low_balance_${account.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Low Balance Warning: ${account.name}',
      message: 'Your ${account.name} account balance is low: \$${account.currentBalance.toStringAsFixed(2)}.',
      type: NotificationType.accountAlert,
      priority: NotificationPriority.medium,
      createdAt: DateTime.now(),
      metadata: {
        'accountId': account.id,
        'alertType': 'low_balance',
        'currentBalance': account.currentBalance,
      },
    );
  }

  AppNotification _createDueDateNotification(Account account, int daysUntilDue) {
    final dueMessage = daysUntilDue == 0
        ? 'is due today'
        : daysUntilDue == 1
            ? 'is due tomorrow'
            : 'is due in $daysUntilDue days';

    return AppNotification(
      id: 'account_due_date_${account.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Payment Due Soon: ${account.name}',
      message: 'Your ${account.name} payment of \$${account.minimumPayment?.toStringAsFixed(2) ?? 'N/A'} $dueMessage.',
      type: NotificationType.accountAlert,
      priority: daysUntilDue <= 1 ? NotificationPriority.high : NotificationPriority.medium,
      createdAt: DateTime.now(),
      metadata: {
        'accountId': account.id,
        'alertType': 'due_date',
        'dueDate': account.dueDate?.toIso8601String(),
        'daysUntilDue': daysUntilDue,
        'minimumPayment': account.minimumPayment,
      },
    );
  }
}