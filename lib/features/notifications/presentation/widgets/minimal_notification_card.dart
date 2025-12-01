import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../theme/notification_tokens.dart';
import '../../domain/entities/notification.dart';

/// Simplified notification card focusing on clarity and obvious interactions
class MinimalNotificationCard extends StatefulWidget {
  const MinimalNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<MinimalNotificationCard> createState() => _MinimalNotificationCardState();
}

class _MinimalNotificationCardState extends State<MinimalNotificationCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isUnread = !(widget.notification.isRead ?? false);
    final typeColor = NotificationTokens.typeColors[widget.notification.type]
        ?? ColorTokens.neutral500;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: Dismissible(
        key: ValueKey(widget.notification.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        onDismissed: (_) => widget.onDismiss(),
        child: AnimatedScale(
          scale: _isPressed ? NotificationTokens.pressScale : 1.0,
          duration: NotificationTokens.interactionDuration,
          curve: Curves.easeOut,
          child: Container(
            margin: EdgeInsets.only(bottom: NotificationTokens.cardSpacing),
            padding: EdgeInsets.all(NotificationTokens.cardPadding),
            decoration: BoxDecoration(
              color: isUnread
                  ? NotificationTokens.unreadBackground
                  : NotificationTokens.readBackground,
              borderRadius: BorderRadius.circular(NotificationTokens.cardRadius),
              border: Border.all(
                color: isUnread
                    ? typeColor.withValues(alpha: 0.2)
                    : ColorTokens.borderPrimary,
                width: NotificationTokens.cardBorderWidth,
              ),
              boxShadow: [
                if (isUnread)
                  BoxShadow(
                    color: typeColor.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Icon + Unread Indicator
                _buildIconColumn(typeColor, isUnread),

                SizedBox(width: DesignTokens.spacing3),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Badge + Timestamp Row
                      _buildHeaderRow(typeColor),

                      SizedBox(height: DesignTokens.spacing1),

                      // Title
                      Text(
                        widget.notification.title,
                        style: NotificationTokens.titleStyle.copyWith(
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: DesignTokens.spacing1),

                      // Message
                      Text(
                        widget.notification.message,
                        style: NotificationTokens.messageStyle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Chevron (subtle affordance)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: ColorTokens.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconColumn(Color typeColor, bool isUnread) {
    return Column(
      children: [
        // Type Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getNotificationIcon(widget.notification.type),
            color: typeColor,
            size: 20,
          ),
        ),

        // Unread Dot
        if (isUnread) ...[
          SizedBox(height: DesignTokens.spacing2),
          Container(
            width: NotificationTokens.unreadDotSize,
            height: NotificationTokens.unreadDotSize,
            decoration: BoxDecoration(
              color: NotificationTokens.unreadIndicator,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NotificationTokens.unreadIndicator.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderRow(Color typeColor) {
    return Row(
      children: [
        // Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _getTypeLabel(widget.notification.type),
            style: NotificationTokens.typeBadgeStyle.copyWith(
              color: typeColor,
            ),
          ),
        ),

        const Spacer(),

        // Timestamp
        Text(
          _formatTime(widget.notification.createdAt),
          style: NotificationTokens.timestampStyle,
        ),
      ],
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: ColorTokens.critical500,
        borderRadius: BorderRadius.circular(NotificationTokens.cardRadius),
      ),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return Icons.account_balance_wallet;

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
        return Icons.settings;

      case NotificationType.custom:
        return Icons.notifications;
    }
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
      case NotificationType.budgetThreshold:
      case NotificationType.budgetRollover:
      case NotificationType.budgetCategoryAlert:
        return 'BUDGET';

      case NotificationType.billReminder:
      case NotificationType.billConfirmation:
      case NotificationType.billOverdue:
        return 'BILL';

      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.goalCelebration:
        return 'GOAL';

      case NotificationType.accountAlert:
      case NotificationType.accountBalance:
      case NotificationType.accountTransaction:
      case NotificationType.accountSync:
        return 'ACCOUNT';

      case NotificationType.transactionReceipt:
      case NotificationType.transactionSplit:
      case NotificationType.transactionSuggestion:
        return 'TRANSACTION';

      case NotificationType.incomeReminder:
      case NotificationType.incomeConfirmation:
        return 'INCOME';

      case NotificationType.systemUpdate:
      case NotificationType.systemBackup:
      case NotificationType.systemExport:
      case NotificationType.systemSecurity:
        return 'SYSTEM';

      case NotificationType.custom:
        return 'INFO';
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