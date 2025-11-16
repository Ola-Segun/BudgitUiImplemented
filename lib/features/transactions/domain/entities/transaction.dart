import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../goals/domain/entities/goal_contribution.dart';

part 'transaction.freezed.dart';

/// Transaction entity - represents a financial transaction
/// Pure domain entity with no dependencies
@freezed
class Transaction with _$Transaction {
   const factory Transaction({
     required String id,
     required String title,
     required double amount,
     required TransactionType type,
     required DateTime date,
     required String categoryId,
     String? accountId, // Optional for transfers
     String? toAccountId, // Destination account for transfers
     double? transferFee, // Fee for transfers
     String? description,
     String? receiptUrl,
     @Default([]) List<String> tags,
     String? currencyCode, // Currency code (USD, EUR, etc.)
     List<GoalContribution>? goalAllocations, // NEW: Goal allocations
   }) = _Transaction;

  const Transaction._();

  /// Check if transaction is income
  bool get isIncome => type == TransactionType.income;

  /// Check if transaction is expense
  bool get isExpense => type == TransactionType.expense;

  /// Check if transaction is a transfer
  bool get isTransfer => type == TransactionType.transfer && toAccountId != null;


  /// Get effective amount for balance calculations
  /// For the account referenced by accountId
  double get effectiveAmount {
    switch (type) {
      case TransactionType.income:
        return amount;
      case TransactionType.expense:
        return -amount;
      case TransactionType.transfer:
        // For transfers: source account loses amount + fee
        return -(amount + (transferFee ?? 0));
    }
  }

  /// Get formatted amount with sign
  String get signedAmount => isIncome ? '+${currencyCode ?? 'USD'} ${amount.toStringAsFixed(2)}' : '-${currencyCode ?? 'USD'} ${amount.toStringAsFixed(2)}';

  /// Get absolute amount
  double get absoluteAmount => amount.abs();

  /// Get total goal allocations amount
  double get totalGoalAllocations =>
      goalAllocations?.fold<double>(0.0, (sum, a) => sum + (a.amount ?? 0.0)) ?? 0.0;

  /// Get net amount after goal allocations
  double get netAmount => amount - totalGoalAllocations;

  /// Check if transaction has goal allocations
  bool get hasGoalAllocations =>
      goalAllocations != null && goalAllocations!.isNotEmpty;
}

/// Transaction type enum
enum TransactionType {
   income,
   expense,
   transfer;

   String get displayName {
     switch (this) {
       case TransactionType.income:
         return 'Income';
       case TransactionType.expense:
         return 'Expense';
       case TransactionType.transfer:
         return 'Transfer';
     }
   }

   bool get isIncome => this == TransactionType.income;
   bool get isExpense => this == TransactionType.expense;
   bool get isTransfer => this == TransactionType.transfer;
}

/// Transaction category entity
@freezed
class TransactionCategory with _$TransactionCategory {
  const factory TransactionCategory({
    required String id,
    required String name,
    required String icon,
    required int color,
    required TransactionType type,
    @Default(0) int order,
    @Default(false) bool isArchived,
    @Default(0) int usageCount,
  }) = _TransactionCategory;

  const TransactionCategory._();

  /// Create default categories
  static List<TransactionCategory> get defaultCategories => [
    // Income categories
    const TransactionCategory(
      id: 'salary',
      name: 'Salary',
      icon: 'work',
      color: 0xFF10B981, // Green
      type: TransactionType.income,
      order: 0,
    ),
    const TransactionCategory(
      id: 'freelance',
      name: 'Freelance',
      icon: 'computer',
      color: 0xFF3B82F6, // Blue
      type: TransactionType.income,
      order: 1,
    ),
    const TransactionCategory(
      id: 'investment',
      name: 'Investment',
      icon: 'trending_up',
      color: 0xFF8B5CF6, // Purple
      type: TransactionType.income,
      order: 2,
    ),

    // Expense categories
    const TransactionCategory(
      id: 'food',
      name: 'Food & Dining',
      icon: 'restaurant',
      color: 0xFFF59E0B, // Yellow
      type: TransactionType.expense,
      order: 0,
    ),
    const TransactionCategory(
      id: 'transport',
      name: 'Transportation',
      icon: 'directions_car',
      color: 0xFFEF4444, // Red
      type: TransactionType.expense,
      order: 1,
    ),
    const TransactionCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: 'shopping_bag',
      color: 0xFFEC4899, // Pink
      type: TransactionType.expense,
      order: 2,
    ),
    const TransactionCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: 'movie',
      color: 0xFFF97316, // Orange
      type: TransactionType.expense,
      order: 3,
    ),
    const TransactionCategory(
      id: 'utilities',
      name: 'Utilities',
      icon: 'bolt',
      color: 0xFF06B6D4, // Cyan
      type: TransactionType.expense,
      order: 4,
    ),
    const TransactionCategory(
      id: 'healthcare',
      name: 'Healthcare',
      icon: 'local_hospital',
      color: 0xFFDC2626, // Dark red
      type: TransactionType.expense,
      order: 5,
    ),
    const TransactionCategory(
      id: 'other',
      name: 'Other',
      icon: 'category',
      color: 0xFF64748B, // Gray
      type: TransactionType.expense,
      order: 6,
    ),

    // Goal-related expense categories
    const TransactionCategory(
      id: 'emergency_fund',
      name: 'Emergency Fund',
      icon: 'security',
      color: 0xFFDC2626, // Red
      type: TransactionType.expense,
      order: 7,
    ),
    const TransactionCategory(
      id: 'vacation',
      name: 'Vacation',
      icon: 'beach_access',
      color: 0xFF059669, // Green
      type: TransactionType.expense,
      order: 8,
    ),
    const TransactionCategory(
      id: 'home_down_payment',
      name: 'Home Down Payment',
      icon: 'home',
      color: 0xFF7C3AED, // Purple
      type: TransactionType.expense,
      order: 9,
    ),
    const TransactionCategory(
      id: 'debt_payoff',
      name: 'Debt Payoff',
      icon: 'credit_card_off',
      color: 0xFFEA580C, // Orange
      type: TransactionType.expense,
      order: 10,
    ),
    const TransactionCategory(
      id: 'car_purchase',
      name: 'Car Purchase',
      icon: 'directions_car',
      color: 0xFF2563EB, // Blue
      type: TransactionType.expense,
      order: 11,
    ),
    const TransactionCategory(
      id: 'education',
      name: 'Education',
      icon: 'school',
      color: 0xFF7C2D12, // Brown
      type: TransactionType.expense,
      order: 12,
    ),
    const TransactionCategory(
      id: 'retirement',
      name: 'Retirement',
      icon: 'account_balance',
      color: 0xFF0D9488, // Teal
      type: TransactionType.expense,
      order: 13,
    ),
    const TransactionCategory(
      id: 'investment',
      name: 'Investment',
      icon: 'trending_up',
      color: 0xFF16A34A, // Green
      type: TransactionType.expense,
      order: 14,
    ),
    const TransactionCategory(
      id: 'wedding',
      name: 'Wedding',
      icon: 'favorite',
      color: 0xFFBE185D, // Pink
      type: TransactionType.expense,
      order: 15,
    ),
  ];
}