import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/empty_state_pattern.dart';
import '../../../../core/design_system/patterns/status_badge_pattern.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/notification.dart';
import '../providers/notification_providers.dart';

class NotificationCenterScreenEnhanced extends ConsumerStatefulWidget {
  const NotificationCenterScreenEnhanced({super.key});

  @override
  ConsumerState<NotificationCenterScreenEnhanced> createState() =>
      _NotificationCenterScreenEnhancedState();
}

class _NotificationCenterScreenEnhancedState
    extends ConsumerState<NotificationCenterScreenEnhanced>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(currentNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: _buildAppBar(context, unreadCount),
      body: notificationsAsync.when(
        data: (notifications) => _buildNotificationList(notifications),
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(notificationNotifierProvider),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int unreadCount) {
    return AppBar(
      backgroundColor: ColorTokens.surfacePrimary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: TypographyTokens.heading3,
          ),
          if (unreadCount > 0)
            Text(
              '$unreadCount unread',
              style: TypographyTokens.captionMd.copyWith(
                color: ColorTokens.teal500,
              ),
            ),
        ],
      ),
      actions: [
        if (unreadCount > 0)
          TextButton.icon(
            onPressed: () => _markAllAsRead(),
            icon: Icon(
              Icons.done_all,
              size: DesignTokens.iconSm,
              color: ColorTokens.teal500,
            ),
            label: Text(
              'Mark all read',
              style: TypographyTokens.labelSm.copyWith(
                color: ColorTokens.teal500,
              ),
            ),
          ),
        SizedBox(width: DesignTokens.spacing2),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: ColorTokens.teal500,
        unselectedLabelColor: ColorTokens.textSecondary,
        labelStyle: TypographyTokens.labelMd.copyWith(
          fontWeight: TypographyTokens.weightBold,
        ),
        unselectedLabelStyle: TypographyTokens.labelMd,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: ColorTokens.teal500,
            width: 3,
          ),
          insets: EdgeInsets.symmetric(horizontal: DesignTokens.spacing6),
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Unread'),
          Tab(text: 'Read'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<AppNotification> allNotifications) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFilteredList(allNotifications, (n) => true),
        _buildFilteredList(allNotifications, (n) => !(n.isRead ?? false)),
        _buildFilteredList(allNotifications, (n) => n.isRead ?? false),
      ],
    );
  }

  Widget _buildFilteredList(
    List<AppNotification> notifications,
    bool Function(AppNotification) filter,
  ) {
    final filteredNotifications = notifications.where(filter).toList();

    if (filteredNotifications.isEmpty) {
      return EmptyStatePattern(
        icon: Icons.notifications_none_outlined,
        iconColor: ColorTokens.neutral500,
        title: 'No notifications',
        description: 'You\'re all caught up!',
      );
    }

    final groupedNotifications = _groupNotificationsByDate(filteredNotifications);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationNotifierProvider.notifier).checkForNotifications();
      },
      color: ColorTokens.teal500,
      child: ListView.builder(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        itemCount: _calculateItemCount(groupedNotifications),
        itemBuilder: (context, index) {
          return _buildListItem(context, index, groupedNotifications);
        },
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Map<String, List<AppNotification>> groupedNotifications,
  ) {
    int currentIndex = 0;

    for (final entry in groupedNotifications.entries) {
      final date = entry.key;
      final notifications = entry.value;

      // Date header
      if (index == currentIndex++) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing3),
          child: _DateHeader(date: date).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal),
        );
      }

      // Notifications for this date
      for (final notification in notifications) {
        if (index == currentIndex++) {
          final notificationIndex = currentIndex - 2; // Adjust for headers
          return Padding(
            padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
            child: _NotificationCard(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onMarkRead: () => _markAsRead(notification),
              onDelete: () => _deleteNotification(notification),
            ).animate()
              .fadeIn(
                duration: DesignTokens.durationNormal,
                delay: Duration(milliseconds: 50 * (notificationIndex % 10)),
              )
              .slideX(
                begin: 0.1,
                duration: DesignTokens.durationNormal,
                delay: Duration(milliseconds: 50 * (notificationIndex % 10)),
              ),
          );
        }
      }
    }

    return const SizedBox.shrink();
  }

  int _calculateItemCount(Map<String, List<AppNotification>> groupedNotifications) {
    int count = 0;
    for (final entry in groupedNotifications.entries) {
      count += 1 + entry.value.length; // header + notifications
    }
    return count;
  }

  Map<String, List<AppNotification>> _groupNotificationsByDate(
    List<AppNotification> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<AppNotification>>{};

    for (final notification in notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String dateKey;
      if (notificationDate == today) {
        dateKey = 'Today';
      } else if (notificationDate == yesterday) {
        dateKey = 'Yesterday';
      } else if (now.difference(notificationDate).inDays < 7) {
        dateKey = DateFormat('EEEE').format(notification.createdAt);
      } else {
        dateKey = DateFormat('MMM dd, yyyy').format(notification.createdAt);
      }

      groups.putIfAbsent(dateKey, () => []).add(notification);
    }

    return groups;
  }

  void _handleNotificationTap(AppNotification notification) {
    if (!(notification.isRead ?? false)) {
      _markAsRead(notification);
    }

    if (notification.actionUrl != null) {
      // TODO: Navigate to action URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigate to: ${notification.actionUrl}'),
          backgroundColor: ColorTokens.info500,
        ),
      );
    }
  }

  void _markAsRead(AppNotification notification) {
    HapticFeedback.lightImpact();
    ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
  }

  void _deleteNotification(AppNotification notification) {
    HapticFeedback.mediumImpact();
    // TODO: Implement delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        backgroundColor: ColorTokens.success500,
      ),
    );
  }

  void _markAllAsRead() {
    HapticFeedback.mediumImpact();
    // TODO: Implement mark all as read
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: ColorTokens.success500,
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing3,
        vertical: DesignTokens.spacing2,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: DesignTokens.iconSm,
            color: ColorTokens.teal500,
          ),
          SizedBox(width: DesignTokens.spacing2),
          Text(
            date,
            style: TypographyTokens.labelMd.copyWith(
              color: ColorTokens.teal500,
              fontWeight: TypographyTokens.weightBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
    required this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isUnread = !(notification.isRead ?? false);
    final notificationColor = _getNotificationColor(notification.type);

    return Slidable(
      key: ValueKey(notification.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.4,
        children: [
          if (isUnread)
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onMarkRead();
              },
              backgroundColor: ColorTokens.success500,
              foregroundColor: Colors.white,
              icon: Icons.done,
              label: 'Read',
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(DesignTokens.radiusMd),
              ),
            ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              onDelete();
            },
            backgroundColor: ColorTokens.critical500,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(DesignTokens.radiusMd),
              left: isUnread ? Radius.zero : Radius.circular(DesignTokens.radiusMd),
            ),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: isUnread
                  ? ColorTokens.surfacePrimary
                  : ColorTokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: isUnread
                    ? ColorTokens.withOpacity(notificationColor, 0.3)
                    : Colors.transparent,
                width: isUnread ? 2 : 1,
              ),
              boxShadow: isUnread ? DesignTokens.elevationLow : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with gradient
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        notificationColor,
                        ColorTokens.darken(notificationColor, 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    boxShadow: isUnread
                        ? DesignTokens.elevationColored(
                            notificationColor,
                            alpha: 0.3,
                          )
                        : null,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: Colors.white,
                    size: DesignTokens.iconMd,
                  ),
                ),
                SizedBox(width: DesignTokens.spacing3),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TypographyTokens.bodyLg.copyWith(
                                fontWeight: isUnread
                                    ? TypographyTokens.weightBold
                                    : TypographyTokens.weightSemiBold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: DesignTokens.spacing2),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: notificationColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorTokens.withOpacity(
                                      notificationColor,
                                      0.5,
                                    ),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: DesignTokens.spacing1),
                      Text(
                        notification.message,
                        style: TypographyTokens.bodyMd.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: DesignTokens.spacing2),
                      Row(
                        children: [
                          StatusBadgePattern(
                            label: _getNotificationTypeLabel(notification.type),
                            color: notificationColor,
                            size: StatusBadgeSize.small,
                            variant: StatusBadgeVariant.subtle,
                          ),
                          SizedBox(width: DesignTokens.spacing2),
                          Icon(
                            Icons.access_time,
                            size: DesignTokens.iconXs,
                            color: ColorTokens.textTertiary,
                          ),
                          SizedBox(width: DesignTokens.spacing1),
                          Text(
                            _formatTime(notification.createdAt),
                            style: TypographyTokens.captionSm.copyWith(
                              color: ColorTokens.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
        return ColorTokens.warning500;
      case NotificationType.billReminder:
        return ColorTokens.info500;
      case NotificationType.goalMilestone:
        return ColorTokens.success500;
      case NotificationType.accountAlert:
        return ColorTokens.critical500;
      case NotificationType.systemUpdate:
        return ColorTokens.purple600;
      case NotificationType.custom:
        return ColorTokens.neutral500;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
        return Icons.warning_amber_rounded;
      case NotificationType.billReminder:
        return Icons.receipt_long;
      case NotificationType.goalMilestone:
        return Icons.flag;
      case NotificationType.accountAlert:
        return Icons.account_balance;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      case NotificationType.custom:
        return Icons.notifications;
    }
  }

  String _getNotificationTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
        return 'Budget';
      case NotificationType.billReminder:
        return 'Bill';
      case NotificationType.goalMilestone:
        return 'Goal';
      case NotificationType.accountAlert:
        return 'Account';
      case NotificationType.systemUpdate:
        return 'System';
      case NotificationType.custom:
        return 'Info';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }
}