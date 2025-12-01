import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/notification.dart';
import '../entities/notification_analytics.dart';
import '../repositories/notification_repository.dart';

/// Use case for checking goal milestones
class CheckGoalMilestones {
  const CheckGoalMilestones(
    this._goalRepository,
    this._settingsRepository,
    this._notificationRepository,
  );

  final GoalRepository _goalRepository;
  final SettingsRepository _settingsRepository;
  final NotificationRepository _notificationRepository;

  /// Check for goal milestones and return notifications
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

      // Get all goals
      final goalsResult = await _goalRepository.getAll();
      if (goalsResult.isError) {
        return Result.error(goalsResult.failureOrNull!);
      }

      final goals = goalsResult.dataOrNull!;
      final notifications = <AppNotification>[];

      for (final goal in goals) {
        final milestoneNotifications = await _checkGoalMilestones(goal);
        notifications.addAll(milestoneNotifications);
      }

      return Result.success(notifications);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to check goal milestones: $e'));
    }
  }

  Future<List<AppNotification>> _checkGoalMilestones(Goal goal) async {
    final notifications = <AppNotification>[];
    final progressPercentage = goal.progressPercentage * 100;

    // Define milestone thresholds
    final milestones = [25.0, 50.0, 75.0, 100.0];

    for (final milestone in milestones) {
      if (progressPercentage >= milestone) {
        // Check if we've already sent a notification for this milestone
        final milestoneKey = 'goal_${goal.id}_milestone_${milestone.round()}';
        final existingNotification = await _hasMilestoneBeenNotified(milestoneKey);

        if (!existingNotification) {
          final notification = _createMilestoneNotification(goal, milestone);
          if (notification != null) {
            notifications.add(notification);
            // Mark this milestone as notified (we'll store this in metadata)
            await _markMilestoneAsNotified(milestoneKey);
          }
        }
      }
    }

    return notifications;
  }

  Future<bool> _hasMilestoneBeenNotified(String milestoneKey) async {
    // Check if we've already sent this milestone notification
    // This is a simple implementation - in a real app, you'd want to track this in the database
    final analyticsResult = await _notificationRepository.getNotificationAnalytics();
    if (analyticsResult.isError) return false;

    final analytics = analyticsResult.dataOrNull!;
    return analytics.any((analytic) =>
        analytic.metadata?['milestoneKey'] == milestoneKey);
  }

  Future<void> _markMilestoneAsNotified(String milestoneKey) async {
    // This would typically be stored in a separate tracking table
    // For now, we'll just create an analytics entry
    final analytics = NotificationAnalytics(
      id: 'milestone_$milestoneKey',
      notificationId: milestoneKey,
      sentAt: DateTime.now(),
      metadata: {'milestoneKey': milestoneKey},
    );

    await _notificationRepository.saveNotificationAnalytics(analytics);
  }

  AppNotification? _createMilestoneNotification(Goal goal, double milestone) {
    final isCompleted = milestone >= 100.0;
    final priority = isCompleted
        ? NotificationPriority.high
        : NotificationPriority.medium;

    final title = isCompleted
        ? '🎉 Goal Completed: ${goal.title}'
        : '🎯 Goal Milestone: ${goal.title}';

    final message = isCompleted
        ? 'Congratulations! You\'ve reached your goal of \$${goal.targetAmount.toStringAsFixed(2)}.'
        : 'Great progress! You\'ve reached ${milestone.round()}% of your \$${goal.targetAmount.toStringAsFixed(2)} goal.';

    return AppNotification(
      id: 'goal_milestone_${goal.id}_${milestone.round()}_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: NotificationType.goalMilestone,
      priority: priority,
      createdAt: DateTime.now(),
      metadata: {
        'goalId': goal.id,
        'milestone': milestone,
        'progressPercentage': goal.progressPercentage * 100,
        'currentAmount': goal.currentAmount,
        'targetAmount': goal.targetAmount,
      },
    );
  }
}