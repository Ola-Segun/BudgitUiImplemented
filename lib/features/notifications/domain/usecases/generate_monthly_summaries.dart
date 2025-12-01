import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/notification.dart';

/// Use case for generating monthly summary notifications
class GenerateMonthlySummaries {
  const GenerateMonthlySummaries(
    this._settingsRepository,
  );

  final SettingsRepository _settingsRepository;

  /// Generate monthly summary notifications
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

      // Check if it's the first day of the month
      final now = DateTime.now();
      if (now.day != 1) {
        return const Result.success([]);
      }

      // Generate monthly summary notification
      final notification = _createMonthlySummaryNotification();
      return Result.success([notification]);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to generate monthly summaries: $e'));
    }
  }

  AppNotification _createMonthlySummaryNotification() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final monthName = _getMonthName(lastMonth.month);

    return AppNotification(
      id: 'monthly_summary_${now.millisecondsSinceEpoch}',
      title: 'Monthly Financial Summary',
      message: 'Your $monthName financial summary is ready. Review your spending patterns and goal progress.',
      type: NotificationType.systemUpdate,
      priority: NotificationPriority.medium,
      createdAt: now,
      metadata: {
        'summaryType': 'monthly',
        'month': lastMonth.month,
        'year': lastMonth.year,
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}