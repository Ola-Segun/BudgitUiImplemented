import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import 'check_account_alerts.dart';
import 'check_bill_reminders.dart';
import 'check_budget_alerts.dart';
import 'check_goal_milestones.dart';
import 'check_income_reminders.dart';
import '../entities/notification.dart';

/// Use case for checking all types of notifications
class CheckAllNotifications {
  const CheckAllNotifications(
    this._checkBudgetAlerts,
    this._checkBillReminders,
    this._checkAccountAlerts,
    this._checkGoalMilestones,
    this._checkIncomeReminders,
  );

  final CheckBudgetAlerts _checkBudgetAlerts;
  final CheckBillReminders _checkBillReminders;
  final CheckAccountAlerts _checkAccountAlerts;
  final CheckGoalMilestones _checkGoalMilestones;
  final CheckIncomeReminders _checkIncomeReminders;

  /// Check for all types of notifications
  Future<Result<List<AppNotification>>> call() async {
    try {
      final results = await Future.wait([
        _checkBudgetAlerts(),
        _checkBillReminders(),
        _checkAccountAlerts(),
        _checkGoalMilestones(),
        _checkIncomeReminders(),
      ]);

      // Check for errors
      for (final result in results) {
        if (result.isError) {
          return Result.error(result.failureOrNull!);
        }
      }

      final allNotifications = results
          .map((result) => result.dataOrNull!)
          .expand((notifications) => notifications)
          .toList();

      // Sort by priority (critical first) and then by creation time
      allNotifications.sort((a, b) {
        // First sort by priority (higher priority first)
        final priorityComparison = b.priority.index.compareTo(a.priority.index);
        if (priorityComparison != 0) return priorityComparison;

        // Then sort by creation time (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });

      return Result.success(allNotifications);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to check all notifications: $e'));
    }
  }
}