import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';

/// Notification entity representing alerts and reminders
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String title,
    required String message,
    required NotificationType type,
    required NotificationPriority priority,
    required DateTime createdAt,
    DateTime? scheduledFor,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) = _AppNotification;

  const AppNotification._();

  /// Check if notification is scheduled for future
  bool get isScheduled => scheduledFor != null && scheduledFor!.isAfter(DateTime.now());

  /// Check if notification is overdue
  bool get isOverdue => scheduledFor != null && scheduledFor!.isBefore(DateTime.now());

  /// Get time until scheduled
  Duration? get timeUntilScheduled {
    if (scheduledFor == null) return null;
    return scheduledFor!.difference(DateTime.now());
  }
}

/// Notification types
enum NotificationType {
  budgetAlert,
  budgetThreshold,
  budgetRollover,
  budgetCategoryAlert,
  billReminder,
  billConfirmation,
  billOverdue,
  goalMilestone,
  goalReminder,
  goalCelebration,
  accountAlert,
  accountBalance,
  accountTransaction,
  accountSync,
  transactionReceipt,
  transactionSplit,
  transactionSuggestion,
  incomeReminder,
  incomeConfirmation,
  systemUpdate,
  systemBackup,
  systemExport,
  systemSecurity,
  custom,
}

/// Notification priority levels
enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

/// Notification channel for grouping
enum NotificationChannel {
  budget,
  bills,
  goals,
  accounts,
  system,
}

