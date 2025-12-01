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
import '../../domain/entities/notification_analytics.dart';
import '../providers/notification_providers.dart';

@Deprecated('Use MinimalNotificationScreen instead')
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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;
  bool _isSelectionMode = false;
  Set<String> _selectedNotifications = {};
  NotificationType? _filterType;
  NotificationPriority? _filterPriority;
  DateTimeRange? _filterDateRange;
  bool _showAnalytics = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(currentNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: _buildAppBar(context, unreadCount),
      body: Column(
        children: [
          if (_isSearchMode) _buildSearchBar(),
          if (_showAnalytics) _buildAnalyticsDashboard(),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) => _buildNotificationList(_filterNotifications(notifications)),
              loading: () => const LoadingView(),
              error: (error, stack) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.refresh(notificationNotifierProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode ? _buildBulkActions() : null,
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
        IconButton(
          onPressed: () => setState(() => _isSearchMode = !_isSearchMode),
          icon: Icon(
            _isSearchMode ? Icons.search_off : Icons.search,
            color: ColorTokens.teal500,
            size: DesignTokens.iconMd,
          ),
        ),
        IconButton(
          onPressed: () => _showFilterDialog(context),
          icon: Icon(
            Icons.filter_list,
            color: ColorTokens.teal500,
            size: DesignTokens.iconMd,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _showAnalytics = !_showAnalytics),
          icon: Icon(
            Icons.analytics,
            color: ColorTokens.teal500,
            size: DesignTokens.iconMd,
          ),
        ),
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
              isSelectionMode: _isSelectionMode,
              isSelected: _selectedNotifications.contains(notification.id),
              onSelectionChanged: (selected) {
                if (selected) {
                  _toggleSelection(notification.id);
                } else {
                  _toggleSelection(notification.id);
                }
              },
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

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        border: Border(
          bottom: BorderSide(color: ColorTokens.neutral300, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                prefixIcon: Icon(
                  Icons.search,
                  color: ColorTokens.teal500,
                  size: DesignTokens.iconMd,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  borderSide: BorderSide(color: ColorTokens.neutral300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  borderSide: BorderSide(color: ColorTokens.teal500),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing3,
                  vertical: DesignTokens.spacing2,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          IconButton(
            onPressed: () => setState(() => _isSearchMode = false),
            icon: Icon(
              Icons.close,
              color: ColorTokens.neutral500,
              size: DesignTokens.iconMd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsDashboard() {
    // TODO: Implement analytics dashboard with real data
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        border: Border(
          bottom: BorderSide(color: ColorTokens.neutral300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Analytics',
                style: TypographyTokens.heading4.copyWith(
                  color: ColorTokens.teal500,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _showAnalytics = false),
                icon: Icon(
                  Icons.close,
                  color: ColorTokens.neutral500,
                  size: DesignTokens.iconMd,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spacing3),
          Row(
            children: [
              _AnalyticsCard(
                title: 'Total',
                value: '0',
                icon: Icons.notifications,
                color: ColorTokens.teal500,
              ),
              SizedBox(width: DesignTokens.spacing2),
              _AnalyticsCard(
                title: 'Read',
                value: '0',
                icon: Icons.done_all,
                color: ColorTokens.success500,
              ),
              SizedBox(width: DesignTokens.spacing2),
              _AnalyticsCard(
                title: 'Clicked',
                value: '0',
                icon: Icons.touch_app,
                color: ColorTokens.info500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<AppNotification> _filterNotifications(List<AppNotification> notifications) {
    return notifications.where((notification) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!notification.title.toLowerCase().contains(query) &&
            !notification.message.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Type filter
      if (_filterType != null && notification.type != _filterType) {
        return false;
      }

      // Priority filter
      if (_filterPriority != null && notification.priority != _filterPriority) {
        return false;
      }

      // Date range filter
      if (_filterDateRange != null) {
        if (notification.createdAt.isBefore(_filterDateRange!.start) ||
            notification.createdAt.isAfter(_filterDateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildBulkActions() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing2),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        boxShadow: DesignTokens.elevationMedium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            onPressed: _markSelectedAsRead,
            heroTag: 'mark_read',
            backgroundColor: ColorTokens.success500,
            child: Icon(
              Icons.done_all,
              color: Colors.white,
              size: DesignTokens.iconMd,
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          FloatingActionButton.small(
            onPressed: _deleteSelected,
            heroTag: 'delete',
            backgroundColor: ColorTokens.critical500,
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: DesignTokens.iconMd,
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          FloatingActionButton.small(
            onPressed: _clearSelection,
            heroTag: 'clear',
            backgroundColor: ColorTokens.neutral500,
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: DesignTokens.iconMd,
            ),
          ),
        ],
      ),
    );
  }

  void _markSelectedAsRead() {
    // TODO: Implement bulk mark as read
    setState(() {
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Selected notifications marked as read'),
        backgroundColor: ColorTokens.success500,
      ),
    );
  }

  void _deleteSelected() {
    // TODO: Implement bulk delete
    setState(() {
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Selected notifications deleted'),
        backgroundColor: ColorTokens.critical500,
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
  }

  void _toggleSelection(String notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
        if (_selectedNotifications.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNotifications.add(notificationId);
        _isSelectionMode = true;
      }
    });
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorTokens.surfacePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
      builder: (context) => _FilterDialog(
        currentTypeFilter: _filterType,
        currentPriorityFilter: _filterPriority,
        currentDateRange: _filterDateRange,
        onFiltersChanged: (type, priority, dateRange) {
          setState(() {
            _filterType = type;
            _filterPriority = priority;
            _filterDateRange = dateRange;
          });
          Navigator.of(context).pop();
        },
        onClearFilters: () {
          setState(() {
            _filterType = null;
            _filterPriority = null;
            _filterDateRange = null;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(DesignTokens.spacing3),
        decoration: BoxDecoration(
          color: ColorTokens.surfacePrimary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: ColorTokens.neutral300, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: DesignTokens.iconMd,
            ),
            SizedBox(height: DesignTokens.spacing1),
            Text(
              value,
              style: TypographyTokens.heading3.copyWith(
                color: color,
                fontWeight: TypographyTokens.weightBold,
              ),
            ),
            Text(
              title,
              style: TypographyTokens.captionMd.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  const _FilterDialog({
    required this.currentTypeFilter,
    required this.currentPriorityFilter,
    required this.currentDateRange,
    required this.onFiltersChanged,
    required this.onClearFilters,
  });

  final NotificationType? currentTypeFilter;
  final NotificationPriority? currentPriorityFilter;
  final DateTimeRange? currentDateRange;
  final Function(NotificationType?, NotificationPriority?, DateTimeRange?) onFiltersChanged;
  final VoidCallback onClearFilters;

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  NotificationType? _selectedType;
  NotificationPriority? _selectedPriority;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentTypeFilter;
    _selectedPriority = widget.currentPriorityFilter;
    _selectedDateRange = widget.currentDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filter Notifications',
                style: TypographyTokens.heading4.copyWith(
                  color: ColorTokens.teal500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onClearFilters,
                child: Text(
                  'Clear All',
                  style: TypographyTokens.labelMd.copyWith(
                    color: ColorTokens.critical500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spacing4),

          // Type filter
          Text(
            'Notification Type',
            style: TypographyTokens.bodyLg.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),
          Wrap(
            spacing: DesignTokens.spacing2,
            runSpacing: DesignTokens.spacing2,
            children: [
              _FilterChip(
                label: 'All Types',
                selected: _selectedType == null,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedType = null);
                },
              ),
              ...NotificationType.values.map((type) => _FilterChip(
                    label: _getTypeLabel(type),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() => _selectedType = selected ? type : null);
                    },
                  )),
            ],
          ),
          SizedBox(height: DesignTokens.spacing4),

          // Priority filter
          Text(
            'Priority',
            style: TypographyTokens.bodyLg.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),
          Wrap(
            spacing: DesignTokens.spacing2,
            runSpacing: DesignTokens.spacing2,
            children: [
              _FilterChip(
                label: 'All Priorities',
                selected: _selectedPriority == null,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedPriority = null);
                },
              ),
              ...NotificationPriority.values.map((priority) => _FilterChip(
                    label: _getPriorityLabel(priority),
                    selected: _selectedPriority == priority,
                    onSelected: (selected) {
                      setState(() => _selectedPriority = selected ? priority : null);
                    },
                  )),
            ],
          ),
          SizedBox(height: DesignTokens.spacing4),

          // Date range filter
          Text(
            'Date Range',
            style: TypographyTokens.bodyLg.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),
          InkWell(
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                initialDateRange: _selectedDateRange,
              );
              if (range != null) {
                setState(() => _selectedDateRange = range);
              }
            },
            child: Container(
              padding: EdgeInsets.all(DesignTokens.spacing3),
              decoration: BoxDecoration(
                border: Border.all(color: ColorTokens.neutral300),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: ColorTokens.teal500,
                    size: DesignTokens.iconMd,
                  ),
                  SizedBox(width: DesignTokens.spacing2),
                  Expanded(
                    child: Text(
                      _selectedDateRange != null
                          ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}'
                          : 'Select date range',
                      style: TypographyTokens.bodyMd,
                    ),
                  ),
                  if (_selectedDateRange != null)
                    IconButton(
                      onPressed: () => setState(() => _selectedDateRange = null),
                      icon: Icon(
                        Icons.clear,
                        size: DesignTokens.iconSm,
                        color: ColorTokens.neutral500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: DesignTokens.spacing4),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onFiltersChanged(
                _selectedType,
                _selectedPriority,
                _selectedDateRange,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.teal500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: TypographyTokens.labelLg.copyWith(
                  fontWeight: TypographyTokens.weightSemiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return 'Budget';
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return 'Bill';
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return 'Goal';
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
        return 'Account';
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return 'Transaction';
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return 'Income';
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return 'System';
      case NotificationType.custom:
        return 'Info';
    }
  }

  String _getPriorityLabel(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.medium:
        return 'Medium';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.critical:
        return 'Critical';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: ColorTokens.withOpacity(ColorTokens.teal500, 0.1),
      checkmarkColor: ColorTokens.teal500,
      backgroundColor: ColorTokens.surfaceSecondary,
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
    required this.isSelectionMode,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final isUnread = !(notification.isRead ?? false);
    final notificationColor = _getNotificationColor(notification.type);

    return Slidable(
      key: ValueKey(notification.id),
      endActionPane: isSelectionMode ? null : ActionPane(
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
            if (isSelectionMode) {
              onSelectionChanged(!isSelected);
            } else {
              onTap();
            }
          },
          onLongPress: () {
            if (!isSelectionMode) {
              onSelectionChanged(true);
            }
          },
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorTokens.withOpacity(ColorTokens.teal500, 0.1)
                  : isUnread
                      ? ColorTokens.surfacePrimary
                      : ColorTokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: isSelected
                    ? ColorTokens.teal500
                    : isUnread
                        ? ColorTokens.withOpacity(notificationColor, 0.3)
                        : Colors.transparent,
                width: isSelected || isUnread ? 2 : 1,
              ),
              boxShadow: isUnread ? DesignTokens.elevationLow : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection checkbox or icon
                if (isSelectionMode)
                  Padding(
                    padding: EdgeInsets.only(right: DesignTokens.spacing3),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) => onSelectionChanged(value ?? false),
                      activeColor: ColorTokens.teal500,
                    ),
                  )
                else
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
                          if (isUnread && !isSelectionMode)
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
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return ColorTokens.warning500;
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return ColorTokens.info500;
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return ColorTokens.success500;
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
        return ColorTokens.critical500;
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return ColorTokens.teal500;
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return ColorTokens.success500;
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return ColorTokens.purple600;
      case NotificationType.custom:
        return ColorTokens.neutral500;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return Icons.warning_amber_rounded;
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return Icons.receipt_long;
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return Icons.flag;
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
        return Icons.account_balance;
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return Icons.receipt;
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return Icons.trending_up;
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return Icons.system_update;
      case NotificationType.custom:
        return Icons.notifications;
    }
  }

  String _getNotificationTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return 'Budget';
      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return 'Bill';
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return 'Goal';
      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
        return 'Account';
      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return 'Transaction';
      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return 'Income';
      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
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