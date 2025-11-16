import 'package:hive/hive.dart';

import '../../../goals/domain/entities/goal_contribution.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_dto.g.dart';

/// Data Transfer Object for Transaction entity
/// Used for Hive storage - never expose domain entities directly to storage
@HiveType(typeId: 0)
class TransactionDto extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String type; // Store as string for Hive compatibility

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late String categoryId;

  @HiveField(6)
  String? accountId;

  @HiveField(7)
  String? toAccountId; // Destination account for transfers

  @HiveField(8)
  double? transferFee; // Fee for transfers

  @HiveField(9)
  String? description;

  @HiveField(10)
  String? receiptUrl;

  @HiveField(11)
  List<String>? tags;

  @HiveField(12)
  late String currencyCode;

  @HiveField(13)
  List<String>? goalAllocationIds; // References to goal contributions

  /// Default constructor
  TransactionDto();

  /// Named constructor for creating from domain entity
  TransactionDto.fromDomain(Transaction transaction) {
    id = transaction.id;
    title = transaction.title;
    amount = transaction.amount;
    type = transaction.type.name; // Convert enum to string
    date = transaction.date;
    categoryId = transaction.categoryId;
    accountId = transaction.accountId;
    toAccountId = transaction.toAccountId;
    transferFee = transaction.transferFee;
    description = transaction.description;
    receiptUrl = transaction.receiptUrl;
    tags = transaction.tags;
    currencyCode = transaction.currencyCode ?? 'USD';
    goalAllocationIds = transaction.goalAllocations?.map((a) => a.id).toList();
  }

  /// Convert to domain entity
  Transaction toDomain() {
    return Transaction(
      id: id,
      title: title,
      amount: amount,
      type: TransactionType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => TransactionType.expense, // Default fallback
      ),
      date: date,
      categoryId: categoryId,
      accountId: accountId,
      toAccountId: toAccountId,
      transferFee: transferFee,
      description: description,
      receiptUrl: receiptUrl,
      tags: tags ?? [],
      currencyCode: currencyCode,
      goalAllocations: null, // Will be populated by repository
    );
  }

  /// Convert to domain entity with goal allocations
  /// Used by repository to populate goal allocations after loading
  Transaction toDomainWithAllocations(List<GoalContribution>? allocations) {
    return Transaction(
      id: id,
      title: title,
      amount: amount,
      type: TransactionType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => TransactionType.expense, // Default fallback
      ),
      date: date,
      categoryId: categoryId,
      accountId: accountId,
      toAccountId: toAccountId,
      transferFee: transferFee,
      description: description,
      receiptUrl: receiptUrl,
      tags: tags ?? [],
      currencyCode: currencyCode,
      goalAllocations: allocations,
    );
  }
}

/// Data Transfer Object for TransactionCategory entity
@HiveType(typeId: 1)
class TransactionCategoryDto extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late int color;

  @HiveField(4)
  late String type; // Store as string for Hive compatibility

  @HiveField(5)
  late bool isArchived;

  @HiveField(6)
  late int usageCount;

  /// Default constructor
  TransactionCategoryDto();

  /// Named constructor for creating from domain entity
  TransactionCategoryDto.fromDomain(TransactionCategory category) {
    id = category.id;
    name = category.name;
    icon = category.icon;
    color = category.color;
    type = category.type.name; // Convert enum to string
    isArchived = category.isArchived;
    usageCount = category.usageCount;
  }

  /// Convert to domain entity
  TransactionCategory toDomain() {
    return TransactionCategory(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: TransactionType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => TransactionType.expense, // Default fallback
      ),
      isArchived: isArchived,
      usageCount: usageCount,
    );
  }
}