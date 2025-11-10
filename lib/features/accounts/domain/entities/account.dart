import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:budget_tracker/features/accounts/domain/entities/account_type_theme.dart';

part 'account.freezed.dart';

/// Account entity - represents a financial account
/// Pure domain entity with no dependencies
@freezed
class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    required AccountType type,
    // Hybrid balance system
    double? cachedBalance, // Eager updated on transactions
    DateTime? lastBalanceUpdate,
    double? reconciledBalance, // Calculated from transactions
    DateTime? lastReconciliation,
    // Backward compatibility - for migration
    double? balance,
    String? description,
    String? institution,
    String? accountNumber,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Type-specific fields
    double? creditLimit, // For credit cards
    double? availableCredit, // For credit cards
    double? interestRate, // For loans/investments
    double? minimumPayment, // For loans/credit cards
    DateTime? dueDate, // For loans/credit cards
    @Default(true) bool isActive,
    // Bank connection fields
    @Default(false) bool isBankConnected,
    String? bankConnectionId,
    DateTime? lastSyncedAt,
    BankConnectionStatus? connectionStatus,
  }) = _Account;

  const Account._();

  /// Check if account is asset (positive balance increases net worth)
  bool get isAsset => type.isAsset;

  /// Check if account is liability (negative balance increases net worth)
  bool get isLiability => type.isLiability;

  /// Get current balance - uses cached balance, falls back to balance for backward compatibility
  double get currentBalance => cachedBalance ?? balance ?? 0.0;

  /// Get available balance (for credit cards, this is credit limit - balance)
  double get availableBalance {
    if (type == AccountType.creditCard && creditLimit != null) {
      return creditLimit! - currentBalance;
    }
    return currentBalance;
  }

  /// Get utilization rate for credit cards
  double? get utilizationRate {
    if (type == AccountType.creditCard && creditLimit != null && creditLimit! > 0) {
      return (currentBalance / creditLimit!).clamp(0.0, 1.0);
    }
    return null;
  }

  /// Check if account is overdrawn (for checking/savings)
  bool get isOverdrawn => type == AccountType.bankAccount && currentBalance < 0;

  /// Check if credit card is over limit
  bool get isOverLimit => type == AccountType.creditCard && creditLimit != null && currentBalance > creditLimit!;

  /// Check if balance needs reconciliation
  bool get needsReconciliation {
    if (reconciledBalance == null || cachedBalance == null) return false;
    return (cachedBalance! - reconciledBalance!).abs() > 0.01;
  }

  /// Get balance discrepancy if any
  double? get balanceDiscrepancy {
    if (reconciledBalance == null || cachedBalance == null) return null;
    return cachedBalance! - reconciledBalance!;
  }

  /// Get display name with institution
  String get displayName => institution != null ? '$name ($institution)' : name;

  /// Get formatted balance with currency
  String get formattedBalance => '${isLiability ? '-' : ''}${currency ?? 'USD'} ${currentBalance.abs().toStringAsFixed(2)}';

  /// Get formatted available balance
  String get formattedAvailableBalance => '${currency ?? 'USD'} ${availableBalance.toStringAsFixed(2)}';

  /// Validate balance fields
  bool get isValidBalance {
    // Cached balance should be reasonable if provided
    if (cachedBalance != null && (cachedBalance!.isNaN || cachedBalance!.isInfinite)) return false;

    // If reconciled balance exists, it should also be reasonable
    if (reconciledBalance != null && (reconciledBalance!.isNaN || reconciledBalance!.isInfinite)) {
      return false;
    }

    // For backward compatibility, if both balance and cachedBalance are provided, they should match
    if (balance != null && cachedBalance != null && (balance! - cachedBalance!).abs() > 0.01) {
      return false;
    }

    return true;
  }
}

/// Account type enum with configurable theming
enum AccountType {
  bankAccount,
  creditCard,
  loan,
  investment,
  manualAccount;

  String get displayName {
    switch (this) {
      case AccountType.bankAccount:
        return 'Bank Account';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.loan:
        return 'Loan';
      case AccountType.investment:
        return 'Investment';
      case AccountType.manualAccount:
        return 'Manual Account';
    }
  }

  /// Get theme for this account type, using custom theme if available, otherwise default
  AccountTypeTheme getTheme(Map<String, AccountTypeTheme> customThemes) {
    final accountTypeName = name;
    return customThemes[accountTypeName] ?? AccountTypeTheme.defaultThemeFor(accountTypeName);
  }

  /// Get icon for this account type using theme system
  IconData getIcon(Map<String, AccountTypeTheme> customThemes) {
    return getTheme(customThemes).iconData;
  }

  /// Get color for this account type using theme system
  Color getColor(Map<String, AccountTypeTheme> customThemes) {
    return getTheme(customThemes).color;
  }

  /// Legacy icon getter for backward compatibility
  String get icon {
    switch (this) {
      case AccountType.bankAccount:
        return 'account_balance';
      case AccountType.creditCard:
        return 'credit_card';
      case AccountType.loan:
        return 'account_balance_wallet';
      case AccountType.investment:
        return 'trending_up';
      case AccountType.manualAccount:
        return 'edit';
    }
  }

  /// Legacy color getter for backward compatibility
  int get color {
    switch (this) {
      case AccountType.bankAccount:
        return 0xFF10B981; // Green
      case AccountType.creditCard:
        return 0xFF3B82F6; // Blue
      case AccountType.loan:
        return 0xFFEF4444; // Red
      case AccountType.investment:
        return 0xFF8B5CF6; // Purple
      case AccountType.manualAccount:
        return 0xFF64748B; // Gray
    }
  }

  /// Check if this account type represents an asset
  bool get isAsset => this == AccountType.bankAccount || this == AccountType.investment || this == AccountType.manualAccount;

  /// Check if this account type represents a liability
    bool get isLiability => this == AccountType.creditCard || this == AccountType.loan;
  }
  
  /// Bank connection status enum
  enum BankConnectionStatus {
    connected,
    connecting,
    disconnected,
    error,
    requiresReauth;
  
    String get displayName {
      switch (this) {
        case BankConnectionStatus.connected:
          return 'Connected';
        case BankConnectionStatus.connecting:
          return 'Connecting';
        case BankConnectionStatus.disconnected:
          return 'Disconnected';
        case BankConnectionStatus.error:
          return 'Connection Error';
        case BankConnectionStatus.requiresReauth:
          return 'Re-authorization Required';
      }
    }
  
    String get color {
      switch (this) {
        case BankConnectionStatus.connected:
          return '#10B981'; // Green
        case BankConnectionStatus.connecting:
          return '#F59E0B'; // Yellow
        case BankConnectionStatus.disconnected:
          return '#64748B'; // Gray
        case BankConnectionStatus.error:
          return '#EF4444'; // Red
        case BankConnectionStatus.requiresReauth:
          return '#F97316'; // Orange
      }
    }
  }