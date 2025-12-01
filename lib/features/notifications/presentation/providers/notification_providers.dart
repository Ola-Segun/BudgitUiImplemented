import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart' as core_providers;
import '../../../../core/navigation/navigation_service.dart';
import '../../../settings/presentation/providers/settings_providers.dart' as settings_providers;
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/usecases/check_account_alerts.dart';
import '../../domain/usecases/check_all_notifications.dart';
import '../../domain/usecases/check_bill_reminders.dart';
import '../../domain/usecases/check_budget_alerts.dart';
import '../../domain/usecases/check_goal_milestones.dart';
import '../../domain/usecases/check_income_reminders.dart';
import '../notifiers/notification_notifier.dart';
import '../notifiers/notification_settings_notifier.dart';
import '../states/notification_state.dart';
import '../states/notification_settings_state.dart';

// Use case providers
final checkBudgetAlertsProvider = Provider<CheckBudgetAlerts>((ref) {
  final budgetRepository = ref.watch(core_providers.budgetRepositoryProvider);
  final settingsRepository = ref.watch(settings_providers.settingsRepositoryProvider);
  final calculateBudgetStatus = ref.watch(core_providers.calculateBudgetStatusProvider);

  return CheckBudgetAlerts(
    budgetRepository,
    settingsRepository,
    calculateBudgetStatus,
  );
});

final checkBillRemindersProvider = Provider<CheckBillReminders>((ref) {
  final billRepository = ref.watch(core_providers.billRepositoryProvider);
  final settingsRepository = ref.watch(settings_providers.settingsRepositoryProvider);
  final formattingService = ref.watch(settings_providers.formattingServiceProvider);

  return CheckBillReminders(billRepository, settingsRepository, formattingService);
});

final checkAccountAlertsProvider = Provider<CheckAccountAlerts>((ref) {
  final accountRepository = ref.watch(core_providers.accountRepositoryProvider);
  final settingsRepository = ref.watch(settings_providers.settingsRepositoryProvider);

  return CheckAccountAlerts(accountRepository, settingsRepository);
});

final checkGoalMilestonesProvider = Provider<CheckGoalMilestones>((ref) {
  final goalRepository = ref.watch(core_providers.goalRepositoryProvider);
  final settingsRepository = ref.watch(settings_providers.settingsRepositoryProvider);
  final notificationRepository = ref.watch(core_providers.notificationRepositoryProvider);

  return CheckGoalMilestones(goalRepository, settingsRepository, notificationRepository);
});

final checkIncomeRemindersProvider = Provider<CheckIncomeReminders>((ref) {
  final recurringIncomeRepository = ref.watch(core_providers.recurringIncomeRepositoryProvider);
  final settingsRepository = ref.watch(settings_providers.settingsRepositoryProvider);

  return CheckIncomeReminders(recurringIncomeRepository, settingsRepository);
});

final checkAllNotificationsProvider = Provider<CheckAllNotifications>((ref) {
  final checkBudgetAlerts = ref.watch(checkBudgetAlertsProvider);
  final checkBillReminders = ref.watch(checkBillRemindersProvider);
  final checkAccountAlerts = ref.watch(checkAccountAlertsProvider);
  final checkGoalMilestones = ref.watch(checkGoalMilestonesProvider);
  final checkIncomeReminders = ref.watch(checkIncomeRemindersProvider);

  return CheckAllNotifications(
    checkBudgetAlerts,
    checkBillReminders,
    checkAccountAlerts,
    checkGoalMilestones,
    checkIncomeReminders,
  );
});

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final checkAllNotifications = ref.watch(checkAllNotificationsProvider);
  final navigationService = ref.watch(core_providers.navigationServiceProvider);
  final notificationRepository = ref.watch(core_providers.notificationRepositoryProvider);
  return NotificationService(checkAllNotifications, navigationService, notificationRepository);
});

// State notifier provider
final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<NotificationState>>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationNotifier(notificationService);
});

// Convenience providers
final currentNotificationsProvider = Provider<AsyncValue<List<AppNotification>>>((ref) {
  final notificationState = ref.watch(notificationNotifierProvider);
  return notificationState.when(
    data: (state) => AsyncValue.data(state.notifications),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(currentNotificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => !(n.isRead ?? false)).length,
    orElse: () => 0,
  );
});

// Notification settings providers
final notificationSettingsNotifierProvider = StateNotifierProvider<NotificationSettingsNotifier, AsyncValue<NotificationSettingsState>>((ref) {
  return NotificationSettingsNotifier();
});

final notificationSettingsProvider = Provider<AsyncValue<NotificationSettings>>((ref) {
  final settingsState = ref.watch(notificationSettingsNotifierProvider);
  return settingsState.when(
    data: (state) => AsyncValue.data(state.settings),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});