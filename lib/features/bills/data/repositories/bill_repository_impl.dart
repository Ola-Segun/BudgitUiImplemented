import 'dart:developer' as developer;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/domain/usecases/add_transaction.dart';
import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../datasources/bill_hive_datasource.dart';

/// Implementation of BillRepository using Hive data source
class BillRepositoryImpl implements BillRepository {
  BillRepositoryImpl(
    this._transactionRepository,
    this._addTransaction,
  ) : _dataSource = BillHiveDataSource();

  final TransactionRepository _transactionRepository;
  final AddTransaction _addTransaction;
  final BillHiveDataSource _dataSource;

  @override
  Future<Result<List<Bill>>> getAll() => _dataSource.getAll();

  @override
  Future<Result<Bill?>> getById(String id) => _dataSource.getById(id);

  @override
  Future<Result<List<Bill>>> getDueWithin(int days) => _dataSource.getDueWithin(days);

  @override
  Future<Result<List<Bill>>> getOverdue() => _dataSource.getOverdue();

  @override
  Future<Result<List<Bill>>> getPaidThisMonth() => _dataSource.getPaidThisMonth();

  @override
  Future<Result<List<Bill>>> getUnpaidThisMonth() => _dataSource.getUnpaidThisMonth();

  @override
  Future<Result<Bill>> add(Bill bill) => _dataSource.add(bill);

  @override
  Future<Result<Bill>> update(Bill bill) => _dataSource.update(bill);

  @override
  Future<Result<void>> delete(String id) => _dataSource.delete(id);

  @override
  Future<Result<Bill>> markAsPaid(String billId, BillPayment payment, {String? accountId}) async {
    // Get bill details first
    final billResult = await _dataSource.getById(billId);
    if (billResult.isError) {
      return Result.error(billResult.failureOrNull!);
    }

    final bill = billResult.dataOrNull;
    if (bill == null) {
      return Result.error(Failure.validation('Bill not found', {'billId': 'Bill does not exist'}));
    }

    // Determine which account to use for payment
    final accountIdToUse = accountId ?? bill.accountId;
    if (accountIdToUse == null) {
      return Result.error(Failure.validation(
        'No account specified for bill payment',
        {'accountId': 'Account is required for bill payment'}
      ));
    }

    // Proceed with marking as paid using the proper usecase pattern
    return _dataSource.markAsPaid(billId, payment, _addTransaction, accountId: accountId);
  }

  @override
  Future<Result<Bill>> markAsUnpaid(String billId) => _dataSource.markAsUnpaid(billId);

  @override
  Future<Result<BillStatus>> getBillStatus(String billId) async {
    final billResult = await _dataSource.getById(billId);
    if (billResult.isError) {
      return Result.error(billResult.failureOrNull!);
    }

    final bill = billResult.dataOrNull;
    if (bill == null) {
      return Result.error(Failure.validation('Bill not found', {'billId': 'Bill does not exist'}));
    }

    // Calculate status (this logic could be moved to a use case)
    final daysUntilDue = bill.daysUntilDue;
    final isOverdue = bill.isOverdue;
    final isDueSoon = bill.isDueSoon;
    final isDueToday = bill.isDueToday;

    BillUrgency urgency;
    if (isOverdue) {
      urgency = BillUrgency.overdue;
    } else if (isDueToday) {
      urgency = BillUrgency.dueToday;
    } else if (isDueSoon) {
      urgency = BillUrgency.dueSoon;
    } else {
      urgency = BillUrgency.normal;
    }

    final status = BillStatus(
      bill: bill,
      daysUntilDue: daysUntilDue,
      isOverdue: isOverdue,
      isDueSoon: isDueSoon,
      isDueToday: isDueToday,
      urgency: urgency,
    );

    return Result.success(status);
  }

  @override
  Future<Result<List<BillStatus>>> getAllBillStatuses() async {
    final billsResult = await _dataSource.getAll();
    if (billsResult.isError) {
      return Result.error(billsResult.failureOrNull!);
    }

    final bills = billsResult.dataOrNull ?? [];
    final statuses = <BillStatus>[];

    for (final bill in bills) {
      final statusResult = await getBillStatus(bill.id);
      if (statusResult.isSuccess) {
        statuses.add(statusResult.dataOrNull!);
      }
    }

    // Sort by urgency
    statuses.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      if (a.isDueSoon && !b.isDueSoon) return -1;
      if (!a.isDueSoon && b.isDueSoon) return 1;
      return a.daysUntilDue.compareTo(b.daysUntilDue);
    });

    return Result.success(statuses);
  }

  @override
  Future<Result<BillsSummary>> getBillsSummary() async {
    final allBillsResult = await _dataSource.getAll();
    if (allBillsResult.isError) {
      return Result.error(allBillsResult.failureOrNull!);
    }

    final allBills = allBillsResult.dataOrNull ?? [];
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Calculate metrics
    final totalBills = allBills.length;
    final currentMonthBills = allBills.where((bill) {
      final billMonth = DateTime(bill.dueDate.year, bill.dueDate.month);
      return billMonth == currentMonth;
    }).toList();

    final paidThisMonth = currentMonthBills.where((bill) => bill.isPaid).length;
    final dueThisMonth = currentMonthBills.length;
    final overdue = allBills.where((bill) => bill.isOverdue).length;

    final totalMonthlyAmount = currentMonthBills.fold<double>(0.0, (sum, bill) => sum + bill.amount);
    final paidAmount = currentMonthBills.where((bill) => bill.isPaid).fold<double>(0.0, (sum, bill) => sum + bill.amount);
    final remainingAmount = totalMonthlyAmount - paidAmount;

    // Get upcoming bills
    final upcomingBillsResult = await _dataSource.getDueWithin(30);
    if (upcomingBillsResult.isError) {
      return Result.error(upcomingBillsResult.failureOrNull!);
    }

    final upcomingBillsRaw = upcomingBillsResult.dataOrNull ?? [];
    final upcomingBillStatuses = <BillStatus>[];

    for (final bill in upcomingBillsRaw.take(5)) {
      final statusResult = await getBillStatus(bill.id);
      if (statusResult.isSuccess) {
        upcomingBillStatuses.add(statusResult.dataOrNull!);
      }
    }

    final summary = BillsSummary(
      totalBills: totalBills,
      paidThisMonth: paidThisMonth,
      dueThisMonth: dueThisMonth,
      overdue: overdue,
      totalMonthlyAmount: totalMonthlyAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      upcomingBills: upcomingBillStatuses,
    );

    return Result.success(summary);
  }

  @override
  Future<Result<Bill>> updateNextDueDate(String billId) => _dataSource.updateNextDueDate(billId);

  @override
  Future<Result<void>> reconcileBillPayments(String billId) async {
    try {
      // Get bill details
      final billResult = await _dataSource.getById(billId);
      if (billResult.isError) {
        return Result.error(billResult.failureOrNull!);
      }

      final bill = billResult.dataOrNull;
      if (bill == null) {
        return Result.error(Failure.validation('Bill not found', {'billId': 'Bill does not exist'}));
      }

      bool reconciliationPerformed = false;
      final issues = <String>[];

      // Step 1: Check for payments without transaction IDs
      for (final payment in bill.paymentHistory) {
        if (payment.transactionId == null) {
          // Payment missing transaction - this is a critical data integrity issue
          issues.add('Payment ${payment.id} has no associated transaction');

          // Attempt to recreate the missing transaction
          try {
            final recreatedTransaction = Transaction(
              id: 'bill_${billId}_${payment.id}',
              title: '${bill.name} Payment',
              amount: payment.amount,
              categoryId: bill.categoryId,
              date: payment.paymentDate,
              type: TransactionType.expense,
              accountId: bill.effectiveAccountId,
              description: 'Payment for ${bill.name}',
            );

            final addResult = await _addTransaction(recreatedTransaction);
            if (addResult.isSuccess) {
              // Update payment with transaction ID
              final updatedPayment = payment.copyWith(transactionId: recreatedTransaction.id);
              final updatedBill = bill.copyWith(
                paymentHistory: bill.paymentHistory.map(
                  (p) => p.id == payment.id ? updatedPayment : p
                ).toList(),
              );

              await _dataSource.update(updatedBill);
              reconciliationPerformed = true;
              issues.add('Recreated transaction for payment ${payment.id}');
            } else {
              issues.add('Failed to recreate transaction for payment ${payment.id}: ${addResult.failureOrNull?.message}');
            }
          } catch (e) {
            issues.add('Error recreating transaction for payment ${payment.id}: $e');
          }
        } else {
          // Payment has transaction ID - verify transaction exists
          final transactionResult = await _transactionRepository.getById(payment.transactionId!);
          if (transactionResult.isError || transactionResult.dataOrNull == null) {
            issues.add('Transaction ${payment.transactionId} for payment ${payment.id} is missing');

            // Attempt to recreate the missing transaction
            try {
              final recreatedTransaction = Transaction(
                id: payment.transactionId!, // Use the original ID
                title: '${bill.name} Payment',
                amount: payment.amount,
                categoryId: bill.categoryId,
                date: payment.paymentDate,
                type: TransactionType.expense,
                accountId: bill.effectiveAccountId,
                description: 'Payment for ${bill.name}',
              );

              final addResult = await _addTransaction(recreatedTransaction);
              if (addResult.isSuccess) {
                reconciliationPerformed = true;
                issues.add('Recreated missing transaction ${payment.transactionId}');
              } else {
                issues.add('Failed to recreate missing transaction ${payment.transactionId}: ${addResult.failureOrNull?.message}');
              }
            } catch (e) {
              issues.add('Error recreating missing transaction ${payment.transactionId}: $e');
            }
          }
        }
      }

      // Step 2: Verify bill payment status consistency
      final hasPayments = bill.paymentHistory.isNotEmpty;
      final totalPaid = bill.totalPaid;
      final shouldBePaid = hasPayments && totalPaid >= bill.amount;

      if (bill.isPaid != shouldBePaid) {
        issues.add('Bill payment status inconsistent: isPaid=${bill.isPaid}, should be $shouldBePaid');

        // Correct the payment status
        final correctedBill = bill.copyWith(isPaid: shouldBePaid);
        await _dataSource.update(correctedBill);
        reconciliationPerformed = true;
        issues.add('Corrected bill payment status to $shouldBePaid');
      }

      // Step 3: Check for orphaned transactions (transactions that reference this bill but bill doesn't know about them)
      // This would require searching transactions by description or a bill reference field
      // For now, we'll skip this as it would require additional indexing

      // Log reconciliation results
      if (reconciliationPerformed) {
        developer.log(
          'Bill $billId reconciliation completed. Issues found and addressed: ${issues.join("; ")}',
          name: 'BillReconciliation'
        );
      } else if (issues.isNotEmpty) {
        developer.log(
          'Bill $billId reconciliation found issues but could not fully resolve: ${issues.join("; ")}',
          name: 'BillReconciliation'
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to reconcile bill payments: $e'));
    }
  }

  @override
  Future<Result<bool>> nameExists(String name, {String? excludeId}) async {
    try {
      final billsResult = await _dataSource.getAll();
      if (billsResult.isError) {
        return Result.error(billsResult.failureOrNull!);
      }

      final bills = billsResult.dataOrNull ?? [];
      final trimmedName = name.trim().toLowerCase();

      final exists = bills.any((bill) {
        if (excludeId != null && bill.id == excludeId) {
          return false;
        }
        return bill.name.trim().toLowerCase() == trimmedName;
      });

      return Result.success(exists);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to check if bill name exists: $e'));
    }
  }
}