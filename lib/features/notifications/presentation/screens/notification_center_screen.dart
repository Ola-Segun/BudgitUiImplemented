import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/notification.dart';
import '../providers/notification_providers.dart';

// Accessibility utilities
class AccessibilityUtils {
  // Ensure minimum touch target size (48x48dp)
  static const double minTouchTargetSize = 48.0;

  // Check if color meets contrast requirements
  static bool meetsContrastRatio(Color foreground, Color background) {
    // Simple luminance calculation for contrast checking
    double getLuminance(Color color) {
      final r = color.r / 255.0;
      final g = color.g / 255.0;
      final b = color.b / 255.0;
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    final fgLuminance = getLuminance(foreground);
    final bgLuminance = getLuminance(background);
    final contrast = (fgLuminance > bgLuminance)
        ? (fgLuminance + 0.05) / (bgLuminance + 0.05)
        : (bgLuminance + 0.05) / (fgLuminance + 0.05);

    return contrast >= 4.5;
  }

  // Get accessible text color based on background
  static Color getAccessibleTextColor(Color background) {
    return ColorTokens.isLight(background)
        ? ColorTokens.textPrimary
        : ColorTokens.textInverse;
  }
}

/// Screen for displaying notification center with all notifications
class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen>
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
      appBar: AppBar(
        backgroundColor: ColorTokens.surfacePrimary,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TypographyTokens.heading3,
        ),
        actions: [
          if (unreadCount > 0)
            Semantics(
              label: '$unreadCount unread notifications',
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing2,
                  vertical: DesignTokens.spacing1,
                ),
                decoration: BoxDecoration(
                  color: ColorTokens.teal500,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Text(
                  '$unreadCount',
                  style: TypographyTokens.captionMd.copyWith(
                    color: Colors.white,
                    fontWeight: TypographyTokens.weightSemiBold,
                  ),
                ),
              ),
            ),
          // TODO: Add mark all as read functionality
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Semantics(
                label: 'All notifications tab',
                child: Text('All', style: TypographyTokens.labelMd),
              ),
            ),
            Tab(
              child: Semantics(
                label: 'Unread notifications tab',
                child: Text('Unread', style: TypographyTokens.labelMd),
              ),
            ),
            Tab(
              child: Semantics(
                label: 'Read notifications tab',
                child: Text('Read', style: TypographyTokens.labelMd),
              ),
            ),
          ],
        ),
      ),
      body: Semantics(
        label: 'Notifications list',
        hint: 'Swipe between tabs to view different notification categories',
        child: notificationsAsync.when(
          data: (notifications) => _buildNotificationList(context, notifications),
          loading: () => const LoadingView(),
          error: (error, stack) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.refresh(notificationNotifierProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, List<AppNotification> allNotifications) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFilteredList(allNotifications, (n) => true), // All
        _buildFilteredList(allNotifications, (n) => !(n.isRead ?? false)), // Unread
        _buildFilteredList(allNotifications, (n) => n.isRead ?? false), // Read
      ],
    );
  }

  Widget _buildFilteredList(
    List<AppNotification> notifications,
    bool Function(AppNotification) filter,
  ) {
    final filteredNotifications = notifications.where(filter).toList();

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    // Group by date
    final groupedNotifications = _groupNotificationsByDate(filteredNotifications);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationNotifierProvider.notifier).checkForNotifications();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          final entry = groupedNotifications.entries.elementAt(index);
          return _buildNotificationGroup(context, entry.key, entry.value);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Semantics(
      label: 'No notifications available',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: ColorTokens.neutral500,
              semanticLabel: 'Empty notifications icon',
            ),
            SizedBox(height: DesignTokens.spacing4),
            Text(
              'No notifications',
              style: TypographyTokens.heading4,
              semanticsLabel: 'No notifications message',
            ),
            SizedBox(height: DesignTokens.spacing2),
            Text(
              'You\'re all caught up!',
              style: TypographyTokens.bodyMd.copyWith(
                color: ColorTokens.textSecondary,
              ),
              textAlign: TextAlign.center,
              semanticsLabel: 'All caught up message',
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<AppNotification>> _groupNotificationsByDate(List<AppNotification> notifications) {
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
      } else {
        dateKey = DateFormat('MMM dd, yyyy').format(notification.createdAt);
      }

      groups.putIfAbsent(dateKey, () => []).add(notification);
    }

    return groups;
  }

  Widget _buildNotificationGroup(BuildContext context, String date, List<AppNotification> notifications) {
    return Semantics(
      label: 'Notifications from $date',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing2),
            child: Text(
              date,
              style: TypographyTokens.heading6.copyWith(
                color: ColorTokens.teal500,
                fontWeight: TypographyTokens.weightSemiBold,
              ),
              semanticsLabel: 'Date header: $date',
            ),
          ),
          ...notifications.map((notification) => _buildNotificationTile(context, notification)),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, AppNotification notification) {
    final isUnread = !(notification.isRead ?? false);

    return Semantics(
      label: '${isUnread ? "Unread" : "Read"} notification: ${notification.title}',
      hint: 'Double tap to ${isUnread ? "mark as read and " : ""}view details',
      child: Card(
        margin: EdgeInsets.only(bottom: DesignTokens.spacing2),
        color: isUnread ? ColorTokens.teal500.withValues(alpha: 0.05) : ColorTokens.surfacePrimary,
        shadowColor: ColorTokens.neutral900.withValues(alpha: 0.1),
        child: ListTile(
          contentPadding: EdgeInsets.all(DesignTokens.spacing4),
          leading: Container(
            width: AccessibilityUtils.minTouchTargetSize,
            height: AccessibilityUtils.minTouchTargetSize,
            padding: EdgeInsets.all(DesignTokens.spacing2),
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: DesignTokens.iconMd,
              semanticLabel: '${notification.type.toString().split('.').last} notification icon',
            ),
          ),
          title: Text(
            notification.title,
            style: TypographyTokens.bodyLg.copyWith(
              fontWeight: isUnread ? TypographyTokens.weightSemiBold : TypographyTokens.weightRegular,
              color: ColorTokens.textPrimary,
            ),
            semanticsLabel: 'Title: ${notification.title}',
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: TypographyTokens.bodyMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
                semanticsLabel: 'Message: ${notification.message}',
              ),
              SizedBox(height: DesignTokens.spacing1),
              Text(
                _formatTime(notification.createdAt),
                style: TypographyTokens.captionMd.copyWith(
                  color: ColorTokens.textTertiary,
                ),
                semanticsLabel: 'Received ${_formatTime(notification.createdAt)}',
              ),
            ],
          ),
          trailing: isUnread
              ? Semantics(
                  label: 'Unread indicator',
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: ColorTokens.teal500,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
          onTap: () => _handleNotificationTap(context, notification),
          onLongPress: () => _showNotificationActions(context, notification),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
        return Colors.orange;
      case NotificationType.billReminder:
        return Colors.blue;
      case NotificationType.goalMilestone:
        return Colors.green;
      case NotificationType.accountAlert:
        return Colors.red;
      case NotificationType.systemUpdate:
        return Colors.purple;
      case NotificationType.custom:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
        return Icons.warning;
      case NotificationType.billReminder:
        return Icons.schedule;
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    // Mark as read if not already
    if (!(notification.isRead ?? false)) {
      ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
    }

    // Handle action URL or specific navigation
    if (notification.actionUrl != null) {
      // TODO: Navigate to action URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigate to: ${notification.actionUrl}')),
      );
    }
  }

  void _showNotificationActions(BuildContext context, AppNotification notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorTokens.surfacePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
      ),
      builder: (context) => Semantics(
        label: 'Notification actions for ${notification.title}',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: 'Mark notification as read',
              hint: 'Double tap to mark this notification as read',
              child: ListTile(
                leading: Icon(
                  Icons.check,
                  color: ColorTokens.success500,
                  size: DesignTokens.iconMd,
                ),
                title: Text(
                  'Mark as read',
                  style: TypographyTokens.bodyLg,
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
                  Navigator.pop(context);
                },
                contentPadding: EdgeInsets.all(DesignTokens.spacing4),
                minLeadingWidth: AccessibilityUtils.minTouchTargetSize,
              ),
            ),
            // TODO: Add delete functionality when implemented
          ],
        ),
      ),
    );
  }
}