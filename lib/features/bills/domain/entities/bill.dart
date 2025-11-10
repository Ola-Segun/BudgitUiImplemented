import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';

part 'bill.freezed.dart';

/// Bill entity representing recurring payments
@freezed
class Bill with _$Bill {
  const factory Bill({
    required String id,
    required String name,
    required double amount,
    required DateTime dueDate,
    required BillFrequency frequency,
    required String categoryId,
    String? description,
    String? payee,
    // ═══ ACCOUNT RELATIONSHIP ═══
    String? defaultAccountId,  // Primary account for payments
    List<String>? allowedAccountIds,  // Alternative accounts for payments
    String? accountId,  // Legacy field for backward compatibility
    @Default(false) bool isAutoPay,
    @Default(false) bool isPaid,
    DateTime? lastPaidDate,
    DateTime? nextDueDate,
    String? website,
    String? notes,
    @Default(BillDifficulty.easy) BillDifficulty cancellationDifficulty,
    DateTime? lastPriceIncrease,
    @Default([]) List<BillPayment> paymentHistory,
    // ═══ VARIABLE AMOUNT SUPPORT ═══
    @Default(false) bool isVariableAmount,
    double? minAmount,
    double? maxAmount,
    // ═══ CURRENCY SUPPORT ═══
    String? currencyCode,
    // ═══ RECURRING FLEXIBILITY ═══
    @Default([]) List<RecurringPaymentRule> recurringPaymentRules,
  }) = _Bill;

  const Bill._();

  /// Calculate days until due
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueDay.difference(today).inDays;
  }

  /// Check if bill is overdue
  bool get isOverdue => daysUntilDue < 0 && !isPaid;

  /// Check if bill is due soon (within 3 days)
  bool get isDueSoon => daysUntilDue >= 0 && daysUntilDue <= 3;

  /// Check if bill is due today
  bool get isDueToday => daysUntilDue == 0;

  /// Calculate next due date based on frequency
  DateTime get calculatedNextDueDate {
    if (nextDueDate != null) return nextDueDate!;

    switch (frequency) {
      case BillFrequency.weekly:
        return dueDate.add(const Duration(days: 7));
      case BillFrequency.biWeekly:
        return dueDate.add(const Duration(days: 14));
      case BillFrequency.monthly:
        return DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
      case BillFrequency.quarterly:
        return DateTime(dueDate.year, dueDate.month + 3, dueDate.day);
      case BillFrequency.annually:
        return DateTime(dueDate.year + 1, dueDate.month, dueDate.day);
      case BillFrequency.custom:
        // For custom frequency, return due date as-is (would need custom logic)
        return dueDate;
    }
  }

  /// Get total amount paid in payment history
  double get totalPaid => paymentHistory.fold(0.0, (sum, payment) => sum + payment.amount);

  /// Get average payment amount
  double get averagePayment => paymentHistory.isEmpty
      ? amount
      : paymentHistory.fold(0.0, (sum, payment) => sum + payment.amount) / paymentHistory.length;

  /// Check if bill has payment history
  bool get hasPaymentHistory => paymentHistory.isNotEmpty;

  /// Get effective account ID (prioritizes defaultAccountId, falls back to accountId)
  String? get effectiveAccountId => defaultAccountId ?? accountId;

  /// Get all allowed account IDs (combines default and allowed accounts)
  List<String> get allAllowedAccountIds {
    final accounts = <String>[];
    if (defaultAccountId != null) accounts.add(defaultAccountId!);
    if (allowedAccountIds != null) accounts.addAll(allowedAccountIds!);
    if (accountId != null && !accounts.contains(accountId!)) accounts.add(accountId!);
    return accounts;
  }

  /// Check if account is allowed for this bill
  bool isAccountAllowed(String accountId) {
    return allAllowedAccountIds.contains(accountId);
  }

  /// Get payment amount for specific instance (considering variable amounts and recurring rules)
  double getPaymentAmountForInstance(int instanceNumber) {
    // Check recurring payment rules first
    final rule = recurringPaymentRules
        .where((rule) => rule.instanceNumber == instanceNumber && rule.isEnabled)
        .firstOrNull;

    if (rule != null && rule.amount != null) {
      return rule.amount!;
    }

    // For variable amount bills, return current amount
    if (isVariableAmount) {
      return amount;
    }

    return amount;
  }

  /// Get account for specific instance (considering recurring rules)
  String? getAccountForInstance(int instanceNumber) {
    // Check recurring payment rules first
    final rule = recurringPaymentRules
        .where((rule) => rule.instanceNumber == instanceNumber && rule.isEnabled)
        .firstOrNull;

    if (rule != null && rule.accountId != null) {
      return rule.accountId;
    }

    // Return default account
    return effectiveAccountId;
  }

  /// Validate bill data
  Result<Bill> validate() {
    if (name.trim().isEmpty) {
      return Result.error(Failure.validation(
        'Bill name cannot be empty',
        {'name': 'Name is required'},
      ));
    }

    if (amount <= 0) {
      return Result.error(Failure.validation(
        'Bill amount must be greater than zero',
        {'amount': 'Amount must be positive'},
      ));
    }

    if (categoryId.trim().isEmpty) {
      return Result.error(Failure.validation(
        'Category ID cannot be empty',
        {'categoryId': 'Category is required'},
      ));
    }

    // Validate variable amount constraints
    if (isVariableAmount) {
      if (minAmount != null && maxAmount != null && minAmount! >= maxAmount!) {
        return Result.error(Failure.validation(
          'Minimum amount must be less than maximum amount',
          {'minAmount': 'Must be < maxAmount', 'maxAmount': 'Must be > minAmount'},
        ));
      }

      if (minAmount != null && minAmount! <= 0) {
        return Result.error(Failure.validation(
          'Minimum amount must be positive',
          {'minAmount': 'Must be > 0'},
        ));
      }

      if (maxAmount != null && maxAmount! <= 0) {
        return Result.error(Failure.validation(
          'Maximum amount must be positive',
          {'maxAmount': 'Must be > 0'},
        ));
      }
    }

    // Validate recurring payment rules
    for (final rule in recurringPaymentRules) {
      final ruleResult = rule.validate();
      if (ruleResult.isError) {
        return Result.error(Failure.validation(
          'Invalid recurring payment rule: ${ruleResult.failureOrNull!.message}',
          {'recurringPaymentRules': (ruleResult.failureOrNull as ValidationFailure?)?.errors ?? {}},
        ));
      }
    }

    return Result.success(this);
  }
}

/// Bill payment record
@freezed
class BillPayment with _$BillPayment {
  const factory BillPayment({
    required String id,
    required double amount,
    required DateTime paymentDate,
    String? transactionId,
    String? notes,
    @Default(PaymentMethod.other) PaymentMethod method,
  }) = _BillPayment;

  const BillPayment._();

  /// Validate payment data
  Result<BillPayment> validate() {
    if (amount <= 0) {
      return Result.error(Failure.validation(
        'Payment amount must be greater than zero',
        {'amount': 'Amount must be positive'},
      ));
    }

    if (paymentDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return Result.error(Failure.validation(
        'Payment date cannot be in the future',
        {'paymentDate': 'Date cannot be in the future'},
      ));
    }

    return Result.success(this);
  }
}

/// Bill frequency enumeration
enum BillFrequency {
  weekly('Weekly'),
  biWeekly('Bi-weekly'),
  monthly('Monthly'),
  quarterly('Quarterly'),
  annually('Annually'),
  custom('Custom');

  const BillFrequency(this.displayName);

  final String displayName;

  /// Get frequency in days
  int get days {
    switch (this) {
      case BillFrequency.weekly:
        return 7;
      case BillFrequency.biWeekly:
        return 14;
      case BillFrequency.monthly:
        return 30; // Approximate
      case BillFrequency.quarterly:
        return 90; // Approximate
      case BillFrequency.annually:
        return 365; // Approximate
      case BillFrequency.custom:
        return 0; // Custom logic needed
    }
  }
}

/// Payment method enumeration
enum PaymentMethod {
  creditCard('Credit Card'),
  debitCard('Debit Card'),
  bankTransfer('Bank Transfer'),
  check('Check'),
  cash('Cash'),
  other('Other');

  const PaymentMethod(this.displayName);

  final String displayName;
}

/// Recurring payment rule for flexible payment patterns
@freezed
class RecurringPaymentRule with _$RecurringPaymentRule {
  const factory RecurringPaymentRule({
    required String id,
    required int instanceNumber,  // Which occurrence (1st, 2nd, etc.)
    String? accountId,  // Specific account for this instance
    double? amount,  // Specific amount for this instance (overrides bill amount)
    String? notes,
    @Default(true) bool isEnabled,
  }) = _RecurringPaymentRule;

  const RecurringPaymentRule._();

  /// Validate rule data
  Result<RecurringPaymentRule> validate() {
    if (instanceNumber < 1) {
      return Result.error(Failure.validation(
        'Instance number must be positive',
        {'instanceNumber': 'Must be >= 1'},
      ));
    }

    if (amount != null && amount! <= 0) {
      return Result.error(Failure.validation(
        'Amount must be positive if specified',
        {'amount': 'Must be > 0'},
      ));
    }

    return Result.success(this);
  }
}

/// Bill cancellation difficulty
enum BillDifficulty {
  easy('Easy'),
  moderate('Moderate'),
  difficult('Difficult');

  const BillDifficulty(this.displayName);

  final String displayName;

  /// Get color for difficulty level
  String get color {
    switch (this) {
      case BillDifficulty.easy:
        return '#10B981'; // Green
      case BillDifficulty.moderate:
        return '#F59E0B'; // Yellow
      case BillDifficulty.difficult:
        return '#EF4444'; // Red
    }
  }
}

/// Bill status summary
@freezed
class BillStatus with _$BillStatus {
  const factory BillStatus({
    required Bill bill,
    required int daysUntilDue,
    required bool isOverdue,
    required bool isDueSoon,
    required bool isDueToday,
    required BillUrgency urgency,
  }) = _BillStatus;

  const BillStatus._();
}

/// Bill urgency level
enum BillUrgency {
  normal('Normal'),
  dueSoon('Due Soon'),
  dueToday('Due Today'),
  overdue('Overdue');

  const BillUrgency(this.displayName);

  final String displayName;

  /// Get color for urgency level
  String get color {
    switch (this) {
      case BillUrgency.normal:
        return '#6B7280'; // Gray
      case BillUrgency.dueSoon:
        return '#F59E0B'; // Yellow
      case BillUrgency.dueToday:
        return '#EF4444'; // Red
      case BillUrgency.overdue:
        return '#DC2626'; // Dark Red
    }
  }
}

/// Subscription entity - special type of bill with cancellation tracking
@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String name,
    required double amount,
    required DateTime dueDate,
    required BillFrequency frequency,
    required String categoryId,
    String? description,
    String? payee,
    // ═══ ACCOUNT RELATIONSHIP ═══
    String? defaultAccountId,  // Primary account for payments
    List<String>? allowedAccountIds,  // Alternative accounts for payments
    String? accountId,  // Legacy field for backward compatibility
    @Default(false) bool isAutoPay,
    @Default(false) bool isPaid,
    DateTime? lastPaidDate,
    DateTime? nextDueDate,
    String? website,
    String? notes,
    @Default(BillDifficulty.easy) BillDifficulty cancellationDifficulty,
    DateTime? lastPriceIncrease,
    @Default([]) List<BillPayment> paymentHistory,
    // ═══ VARIABLE AMOUNT SUPPORT ═══
    @Default(false) bool isVariableAmount,
    double? minAmount,
    double? maxAmount,
    // ═══ CURRENCY SUPPORT ═══
    String? currencyCode,
    // ═══ RECURRING FLEXIBILITY ═══
    @Default([]) List<RecurringPaymentRule> recurringPaymentRules,
    // Subscription-specific fields
    @Default(false) bool isCancelled,
    DateTime? cancellationDate,
    String? cancellationReason,
    @Default([]) List<String> alternativeProviders,
    DateTime? trialEndDate,
    @Default(false) bool hasFreeTrial,
    DateTime? lastUsedDate,  // Track when subscription was last used
  }) = _Subscription;

  const Subscription._();

  /// Convert to Bill entity
  Bill toBill() {
    return Bill(
      id: id,
      name: name,
      amount: amount,
      dueDate: dueDate,
      frequency: frequency,
      categoryId: categoryId,
      description: description,
      payee: payee,
      defaultAccountId: defaultAccountId,
      allowedAccountIds: allowedAccountIds,
      accountId: accountId,
      isAutoPay: isAutoPay,
      isPaid: isPaid,
      lastPaidDate: lastPaidDate,
      nextDueDate: nextDueDate,
      website: website,
      notes: notes,
      cancellationDifficulty: cancellationDifficulty,
      lastPriceIncrease: lastPriceIncrease,
      paymentHistory: paymentHistory,
      isVariableAmount: isVariableAmount,
      minAmount: minAmount,
      maxAmount: maxAmount,
      currencyCode: currencyCode,
      recurringPaymentRules: recurringPaymentRules,
    );
  }

  /// Create from Bill entity
  factory Subscription.fromBill(Bill bill) {
    return Subscription(
      id: bill.id,
      name: bill.name,
      amount: bill.amount,
      dueDate: bill.dueDate,
      frequency: bill.frequency,
      categoryId: bill.categoryId,
      description: bill.description,
      payee: bill.payee,
      defaultAccountId: bill.defaultAccountId,
      allowedAccountIds: bill.allowedAccountIds,
      accountId: bill.accountId,
      isAutoPay: bill.isAutoPay,
      isPaid: bill.isPaid,
      lastPaidDate: bill.lastPaidDate,
      nextDueDate: bill.nextDueDate,
      website: bill.website,
      notes: bill.notes,
      cancellationDifficulty: bill.cancellationDifficulty,
      lastPriceIncrease: bill.lastPriceIncrease,
      paymentHistory: bill.paymentHistory,
      isVariableAmount: bill.isVariableAmount,
      minAmount: bill.minAmount,
      maxAmount: bill.maxAmount,
      currencyCode: bill.currencyCode,
      recurringPaymentRules: bill.recurringPaymentRules,
      lastUsedDate: null, // Initialize as null for new subscriptions
    );
  }

  /// Calculate days until due
  int get daysUntilDue => toBill().daysUntilDue;

  /// Check if subscription is overdue
  bool get isOverdue => toBill().isOverdue;

  /// Check if subscription is due soon
  bool get isDueSoon => toBill().isDueSoon;

  /// Check if subscription is due today
  bool get isDueToday => toBill().isDueToday;

  /// Calculate next due date based on frequency
  DateTime get calculatedNextDueDate => toBill().calculatedNextDueDate;

  /// Get total amount paid in payment history
  double get totalPaid => toBill().totalPaid;

  /// Get average payment amount
  double get averagePayment => toBill().averagePayment;

  /// Check if subscription has payment history
  bool get hasPaymentHistory => toBill().hasPaymentHistory;

  /// Check if subscription is considered unused (no last used date or last used > 30 days ago)
  bool get isUnused {
    if (lastUsedDate == null) return true;
    final daysSinceLastUse = DateTime.now().difference(lastUsedDate!).inDays;
    return daysSinceLastUse > 30; // Consider unused if not used in 30+ days
  }

  /// Get days since last used
  int? get daysSinceLastUsed {
    if (lastUsedDate == null) return null;
    return DateTime.now().difference(lastUsedDate!).inDays;
  }

  /// Validate subscription data
  Result<Subscription> validate() {
    final billResult = toBill().validate();
    if (billResult.isError) {
      return Result.error(billResult.failureOrNull!);
    }

    if (isCancelled && cancellationDate == null) {
      return Result.error(Failure.validation(
        'Cancellation date is required when subscription is cancelled',
        {'cancellationDate': 'Required when cancelled'},
      ));
    }

    return Result.success(this);
  }
}

/// Bills summary for dashboard
@freezed
class BillsSummary with _$BillsSummary {
  const factory BillsSummary({
    required int totalBills,
    required int paidThisMonth,
    required int dueThisMonth,
    required int overdue,
    required double totalMonthlyAmount,
    required double paidAmount,
    required double remainingAmount,
    required List<BillStatus> upcomingBills,
  }) = _BillsSummary;

  const BillsSummary._();

  /// Calculate payment progress percentage
  double get paymentProgress => totalMonthlyAmount > 0
      ? (paidAmount / totalMonthlyAmount).clamp(0.0, 1.0)
      : 0.0;
}