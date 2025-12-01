import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../theme/notification_tokens.dart';
import '../widgets/minimal_notification_card.dart';
import '../utils/notification_action_handler.dart';
import '../providers/notification_providers.dart';
import '../../domain/entities/notification.dart';

/// Simplified notification screen focusing on clarity and ease of navigation
class MinimalNotificationScreen extends ConsumerStatefulWidget {
  const MinimalNotificationScreen({super.key});

  @override
  ConsumerState<MinimalNotificationScreen> createState() => _MinimalNotificationScreenState();
}

class _MinimalNotificationScreenState extends ConsumerState<MinimalNotificationScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Simplified to 2 tabs
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
      body: SafeArea(
        child: Column(
          children: [
            // Simplified Header
            _buildHeader(context, unreadCount),

            // Main Content
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) => _buildNotificationList(notifications),
                loading: () => const LoadingView(),
                error: (error, stack) => ErrorView(
                  message: 'Unable to load notifications',
                  onRetry: () => ref.refresh(notificationNotifierProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int unreadCount) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        border: Border(
          bottom: BorderSide(
            color: ColorTokens.borderPrimary,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              SizedBox(width: DesignTokens.spacing3),

              // Title
              Text(
                'Notifications',
                style: TypographyTokens.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              // Mark All Read (only show if there are unread)
              if (unreadCount > 0)
                TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _markAllAsRead();
                  },
                  child: Text(
                    'Mark all read',
                    style: TypographyTokens.labelSm.copyWith(
                      color: ColorTokens.teal500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: DesignTokens.spacing3),

          // Simple Tab Bar (All / Unread)
          _buildSimpleTabBar(unreadCount),
        ],
      ),
    );
  }

  Widget _buildSimpleTabBar(int unreadCount) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: ColorTokens.teal500,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: ColorTokens.textSecondary,
        labelStyle: TypographyTokens.labelMd.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TypographyTokens.labelMd,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(
            child: Text('All'),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Unread'),
                if (unreadCount > 0) ...[
                  SizedBox(width: DesignTokens.spacing1),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _tabController.index == 1
                          ? Colors.white.withValues(alpha: 0.2)
                          : ColorTokens.teal500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: TypographyTokens.captionSm.copyWith(
                        color: _tabController.index == 1
                            ? Colors.white
                            : ColorTokens.teal500,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<AppNotification> allNotifications) {
    return TabBarView(
      controller: _tabController,
      physics: NotificationTokens.scrollPhysics,
      children: [
        _buildList(allNotifications, showAll: true),
        _buildList(allNotifications, showAll: false),
      ],
    );
  }

  Widget _buildList(List<AppNotification> allNotifications, {required bool showAll}) {
    final notifications = showAll
        ? allNotifications
        : allNotifications.where((n) => !(n.isRead ?? false)).toList();

    if (notifications.isEmpty) {
      return _buildEmptyState(showAll);
    }

    // Group by date for better organization
    final groupedNotifications = _groupNotificationsByDate(notifications);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationNotifierProvider.notifier).checkForNotifications();
      },
      color: ColorTokens.teal500,
      child: ListView.builder(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        physics: NotificationTokens.scrollPhysics,
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
    Map<DateTime, List<AppNotification>> groupedNotifications,
  ) {
    int currentIndex = 0;

    for (final entry in groupedNotifications.entries) {
      final date = entry.key;
      final notifications = entry.value;

      // Date header
      if (index == currentIndex++) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: DesignTokens.spacing2,
            top: currentIndex > 1 ? DesignTokens.spacing4 : 0,
          ),
          child: _buildDateHeader(date),
        );
      }

      // Notifications for this date
      for (final notification in notifications) {
        if (index == currentIndex++) {
          return MinimalNotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onDismiss: () => _dismissNotification(notification),
          );
        }
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String dateText;
    if (dateOnly == today) {
      dateText = 'Today';
    } else if (dateOnly == yesterday) {
      dateText = 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      dateText = DateFormat('EEEE').format(date);
    } else {
      dateText = DateFormat('MMM dd, yyyy').format(date);
    }

    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: ColorTokens.textSecondary,
        ),
        SizedBox(width: DesignTokens.spacing1),
        Text(
          dateText,
          style: TypographyTokens.labelSm.copyWith(
            color: ColorTokens.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool showAll) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing5),
            decoration: BoxDecoration(
              color: ColorTokens.teal500.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              showAll ? Icons.inbox_outlined : Icons.check_circle_outline,
              size: 64,
              color: ColorTokens.teal500,
            ),
          ),
          SizedBox(height: DesignTokens.spacing4),
          Text(
            showAll ? 'No notifications' : 'All caught up!',
            style: TypographyTokens.heading4.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),
          Text(
            showAll
                ? 'You don\'t have any notifications yet'
                : 'You\'ve read all your notifications',
            style: TypographyTokens.bodyMd.copyWith(
              color: ColorTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _calculateItemCount(Map<DateTime, List<AppNotification>> groupedNotifications) {
    int count = 0;
    for (final entry in groupedNotifications.entries) {
      count += 1 + entry.value.length; // header + notifications
    }
    return count;
  }

  Map<DateTime, List<AppNotification>> _groupNotificationsByDate(
    List<AppNotification> notifications,
  ) {
    final groups = <DateTime, List<AppNotification>>{};

    for (final notification in notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      groups.putIfAbsent(notificationDate, () => []).add(notification);
    }

    // Sort groups by date (most recent first)
    final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedGroups = <DateTime, List<AppNotification>>{};
    for (final key in sortedKeys) {
      sortedGroups[key] = groups[key]!;
    }

    return sortedGroups;
  }

  void _handleNotificationTap(AppNotification notification) {
    HapticFeedback.mediumImpact();

    // Mark as read
    if (!(notification.isRead ?? false)) {
      ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
    }

    // Handle the action
    NotificationActionHandler.handleNotificationAction(context, notification);
  }

  void _dismissNotification(AppNotification notification) {
    HapticFeedback.mediumImpact();

    // Mark as read when dismissed
    ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification dismissed'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: ColorTokens.teal500,
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    // TODO: Implement mark all as read
    ref.read(notificationNotifierProvider.notifier).clearAllNotifications();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: ColorTokens.success500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}