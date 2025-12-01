import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Unified model representing both bills and recurring income
class FinancialObligation {
  const FinancialObligation({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.nextDate,
    required this.status,
    this.accountId,
    this.categoryId,
    this.description,
    this.payee,
    this.isAutomated,
    this.lastProcessedDate,
    this.history,
  });

  final String id;
  final String name;
  final double amount;
  final ObligationType type;
  final ObligationFrequency frequency;
  final DateTime nextDate;
  final ObligationStatus status;
  final String? accountId;
  final String? categoryId;
  final String? description;
  final String? payee;
  final bool? isAutomated;
  final DateTime? lastProcessedDate;
  final List<ObligationHistory>? history;

  // Computed properties
  int get daysUntilNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDay = DateTime(nextDate.year, nextDate.month, nextDate.day);
    return nextDay.difference(today).inDays;
  }

  bool get isOverdue => daysUntilNext < 0 && status != ObligationStatus.completed;
  bool get isDueToday => daysUntilNext == 0 && status != ObligationStatus.completed;
  bool get isDueSoon => daysUntilNext > 0 && daysUntilNext <= 7;
  bool get isUpcoming => daysUntilNext > 7 && daysUntilNext <= 30;

  ObligationUrgency get urgency {
    if (isOverdue) return ObligationUrgency.overdue;
    if (isDueToday) return ObligationUrgency.dueToday;
    if (isDueSoon) return ObligationUrgency.dueSoon;
    return ObligationUrgency.normal;
  }

  Color get typeColor => type == ObligationType.bill
      ? const Color(0xFFEF4444) // Red for bills
      : const Color(0xFF10B981); // Green for income

  String get formattedAmount => NumberFormat.currency(
        symbol: '\$',
        decimalDigits: 0,
      ).format(amount);
}

enum ObligationType {
  bill,
  income;

  String get displayName {
    switch (this) {
      case ObligationType.bill:
        return 'Bill';
      case ObligationType.income:
        return 'Income';
    }
  }

  IconData get icon {
    switch (this) {
      case ObligationType.bill:
        return Icons.arrow_upward;
      case ObligationType.income:
        return Icons.arrow_downward;
    }
  }
}

enum ObligationFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  annually;

  String get displayName {
    switch (this) {
      case ObligationFrequency.daily:
        return 'Daily';
      case ObligationFrequency.weekly:
        return 'Weekly';
      case ObligationFrequency.biweekly:
        return 'Bi-weekly';
      case ObligationFrequency.monthly:
        return 'Monthly';
      case ObligationFrequency.quarterly:
        return 'Quarterly';
      case ObligationFrequency.annually:
        return 'Annually';
    }
  }
}

enum ObligationStatus {
  pending,
  completed,
  failed,
  skipped;

  String get displayName {
    switch (this) {
      case ObligationStatus.pending:
        return 'Pending';
      case ObligationStatus.completed:
        return 'Completed';
      case ObligationStatus.failed:
        return 'Failed';
      case ObligationStatus.skipped:
        return 'Skipped';
    }
  }
}

enum ObligationUrgency {
  overdue,
  dueToday,
  dueSoon,
  normal;

  String get displayName {
    switch (this) {
      case ObligationUrgency.overdue:
        return 'Overdue';
      case ObligationUrgency.dueToday:
        return 'Due Today';
      case ObligationUrgency.dueSoon:
        return 'Due Soon';
      case ObligationUrgency.normal:
        return 'Upcoming';
    }
  }

  Color get color {
    switch (this) {
      case ObligationUrgency.overdue:
        return const Color(0xFFDC2626); // Red-600
      case ObligationUrgency.dueToday:
        return const Color(0xFFEA580C); // Orange-600
      case ObligationUrgency.dueSoon:
        return const Color(0xFFF59E0B); // Amber-500
      case ObligationUrgency.normal:
        return const Color(0xFF3B82F6); // Blue-500
    }
  }
}

class ObligationHistory {
  const ObligationHistory({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    this.notes,
    this.transactionId,
  });

  final String id;
  final DateTime date;
  final double amount;
  final ObligationStatus status;
  final String? notes;
  final String? transactionId;
}

/// Summary model for dashboard statistics
class FinancialObligationsSummary {
  const FinancialObligationsSummary({
    required this.totalBills,
    required this.totalIncome,
    required this.netCashFlow,
    required this.upcomingBills,
    required this.upcomingIncome,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.dueSoonCount,
    required this.monthlyBillTotal,
    required this.monthlyIncomeTotal,
    required this.automatedCount,
  });

  final int totalBills;
  final int totalIncome;
  final double netCashFlow;
  final List<FinancialObligation> upcomingBills;
  final List<FinancialObligation> upcomingIncome;
  final int overdueCount;
  final int dueTodayCount;
  final int dueSoonCount;
  final double monthlyBillTotal;
  final double monthlyIncomeTotal;
  final int automatedCount;

  double get cashFlowRatio => monthlyIncomeTotal > 0
      ? monthlyBillTotal / monthlyIncomeTotal
      : 0.0;

  bool get isHealthy => netCashFlow > 0 && overdueCount == 0;
  bool get needsAttention => overdueCount > 0 || dueTodayCount > 0;
  bool get isCritical => netCashFlow < 0 || overdueCount > 3;
}