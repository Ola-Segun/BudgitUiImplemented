import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../theme/app_colors.dart';

/// Critical alerts banner that displays high-priority notifications
class CriticalAlertsBanner extends ConsumerWidget {
  const CriticalAlertsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(currentNotificationsProvider);

    return notificationsAsync.when(
      data: (notifications) {
        final criticalAlerts = _getCriticalAlerts(notifications);
        if (criticalAlerts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Critical Alerts',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ...criticalAlerts.map((alert) => _buildAlertItem(alert)),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  List<AppNotification> _getCriticalAlerts(List<AppNotification> notifications) {
    return notifications.where((notification) {
      // Filter for critical/high priority notifications
      final priority = notification.priority ?? NotificationPriority.medium;
      return priority == NotificationPriority.high ||
             priority == NotificationPriority.critical;
    }).toList();
  }

  Widget _buildAlertItem(AppNotification alert) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.error.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (alert.message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      alert.message,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            _getPriorityIcon(alert.priority),
            color: AppColors.error,
            size: 16,
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Icons.error;
      case NotificationPriority.high:
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}