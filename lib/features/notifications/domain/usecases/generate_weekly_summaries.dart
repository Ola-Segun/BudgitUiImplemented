import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/notification.dart';

/// Use case for generating weekly summary notifications
class GenerateWeeklySummaries {
  const GenerateWeeklySummaries(
    this._settingsRepository,
  );

  final SettingsRepository _settingsRepository;

  /// Generate weekly summary notifications
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

      // Check if it's time for weekly summary (e.g., every Sunday)
      final now = DateTime.now();
      if (now.weekday != DateTime.sunday) {
        return const Result.success([]);
      }

      // Generate weekly summary notification
      final notification = _createWeeklySummaryNotification();
      return Result.success([notification]);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to generate weekly summaries: $e'));
    }
  }

  AppNotification _createWeeklySummaryNotification() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return AppNotification(
      id: 'weekly_summary_${now.millisecondsSinceEpoch}',
      title: 'Weekly Financial Summary',
      message: 'Your weekly financial summary for ${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day} is ready. Check your dashboard for detailed insights.',
      type: NotificationType.systemUpdate,
      priority: NotificationPriority.medium,
      createdAt: now,
      metadata: {
        'summaryType': 'weekly',
        'weekStart': weekStart.toIso8601String(),
        'weekEnd': weekEnd.toIso8601String(),
      },
    );
  }
}