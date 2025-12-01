import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/financial_obligation.dart';
import '../../../bills/presentation/providers/bill_providers.dart';
import '../../../recurring_incomes/presentation/providers/recurring_income_providers.dart';

/// Provider that combines bills and recurring income into unified obligations
final financialObligationsProvider = Provider<List<FinancialObligation>>((ref) {
  final billState = ref.watch(billNotifierProvider);
  final incomeState = ref.watch(recurringIncomeNotifierProvider);

  final obligations = <FinancialObligation>[];

  // Add bills
  billState.maybeWhen(
    loaded: (bills, summary) {
      for (final bill in bills) {
        obligations.add(FinancialObligation(
          id: bill.id,
          name: bill.name,
          amount: bill.amount,
          type: ObligationType.bill,
          frequency: _convertBillFrequency(bill.frequency),
          nextDate: bill.dueDate,
          status: bill.isPaid ? ObligationStatus.completed : ObligationStatus.pending,
          accountId: bill.accountId,
          categoryId: bill.categoryId,
          description: bill.description,
          payee: bill.payee,
          isAutomated: bill.isAutoPay,
          lastProcessedDate: bill.lastPaidDate,
          history: bill.paymentHistory.map((p) => ObligationHistory(
            id: p.id,
            date: p.paymentDate,
            amount: p.amount,
            status: ObligationStatus.completed,
            notes: p.notes,
            transactionId: p.transactionId,
          )).toList(),
        ));
      }
    },
    orElse: () {},
  );

  // Add recurring income
  incomeState.maybeWhen(
    loaded: (incomes, summary) {
      for (final income in incomes) {
        if (income.nextExpectedDate != null) {
          obligations.add(FinancialObligation(
            id: income.id,
            name: income.name,
            amount: income.amount,
            type: ObligationType.income,
            frequency: _convertIncomeFrequency(income.frequency),
            nextDate: income.nextExpectedDate!,
            status: ObligationStatus.pending,
            accountId: income.accountId,
            categoryId: income.categoryId,
            description: income.description,
            payee: income.payer,
            isAutomated: false, // Income is typically not automated
            lastProcessedDate: income.lastReceivedDate,
            history: income.incomeHistory.map((h) => ObligationHistory(
              id: h.id,
              date: h.receivedDate,
              amount: h.amount,
              status: ObligationStatus.completed,
              notes: h.notes,
              transactionId: h.transactionId,
            )).toList(),
          ));
        }
      }
    },
    orElse: () {},
  );

  // Sort by next date
  obligations.sort((a, b) => a.nextDate.compareTo(b.nextDate));

  return obligations;
});

/// Provider for obligations summary statistics
final obligationsSummaryProvider = Provider<FinancialObligationsSummary>((ref) {
  final obligations = ref.watch(financialObligationsProvider);

  final bills = obligations.where((o) => o.type == ObligationType.bill).toList();
  final incomes = obligations.where((o) => o.type == ObligationType.income).toList();

  final upcomingBills = bills.where((b) =>
    b.daysUntilNext >= 0 && b.daysUntilNext <= 30 && b.status != ObligationStatus.completed
  ).toList();

  final upcomingIncome = incomes.where((i) =>
    i.daysUntilNext >= 0 && i.daysUntilNext <= 30 && i.status != ObligationStatus.completed
  ).toList();

  final overdueCount = obligations.where((o) => o.isOverdue).length;
  final dueTodayCount = obligations.where((o) => o.isDueToday).length;
  final dueSoonCount = obligations.where((o) => o.isDueSoon).length;

  // Calculate monthly totals
  double monthlyBills = 0;
  for (final bill in bills) {
    monthlyBills += _getMonthlyAmount(bill);
  }

  double monthlyIncome = 0;
  for (final income in incomes) {
    monthlyIncome += _getMonthlyAmount(income);
  }

  final automatedCount = obligations.where((o) => o.isAutomated == true).length;

  return FinancialObligationsSummary(
    totalBills: bills.length,
    totalIncome: incomes.length,
    netCashFlow: monthlyIncome - monthlyBills,
    upcomingBills: upcomingBills,
    upcomingIncome: upcomingIncome,
    overdueCount: overdueCount,
    dueTodayCount: dueTodayCount,
    dueSoonCount: dueSoonCount,
    monthlyBillTotal: monthlyBills,
    monthlyIncomeTotal: monthlyIncome,
    automatedCount: automatedCount,
  );
});

// Helper functions

ObligationFrequency _convertBillFrequency(dynamic frequency) {
  // Handle both enum and string cases
  if (frequency is String) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return ObligationFrequency.daily;
      case 'weekly':
        return ObligationFrequency.weekly;
      case 'biweekly':
      case 'bi-weekly':
        return ObligationFrequency.biweekly;
      case 'monthly':
        return ObligationFrequency.monthly;
      case 'quarterly':
        return ObligationFrequency.quarterly;
      case 'annually':
      case 'yearly':
        return ObligationFrequency.annually;
      default:
        return ObligationFrequency.monthly;
    }
  }

  // Handle enum cases
  switch (frequency) {
    case dynamic f when f.toString().contains('daily'):
      return ObligationFrequency.daily;
    case dynamic f when f.toString().contains('weekly'):
      return ObligationFrequency.weekly;
    case dynamic f when f.toString().contains('biWeekly') || f.toString().contains('biweekly'):
      return ObligationFrequency.biweekly;
    case dynamic f when f.toString().contains('monthly'):
      return ObligationFrequency.monthly;
    case dynamic f when f.toString().contains('quarterly'):
      return ObligationFrequency.quarterly;
    case dynamic f when f.toString().contains('annually') || f.toString().contains('yearly'):
      return ObligationFrequency.annually;
    default:
      return ObligationFrequency.monthly;
  }
}

ObligationFrequency _convertIncomeFrequency(dynamic frequency) {
  // Handle both enum and string cases
  if (frequency is String) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return ObligationFrequency.daily;
      case 'weekly':
        return ObligationFrequency.weekly;
      case 'biweekly':
      case 'bi-weekly':
        return ObligationFrequency.biweekly;
      case 'monthly':
        return ObligationFrequency.monthly;
      case 'quarterly':
        return ObligationFrequency.quarterly;
      case 'annually':
        return ObligationFrequency.annually;
      default:
        return ObligationFrequency.monthly;
    }
  }

  // Handle enum cases
  switch (frequency) {
    case dynamic f when f.toString().contains('daily'):
      return ObligationFrequency.daily;
    case dynamic f when f.toString().contains('weekly'):
      return ObligationFrequency.weekly;
    case dynamic f when f.toString().contains('biWeekly') || f.toString().contains('biweekly'):
      return ObligationFrequency.biweekly;
    case dynamic f when f.toString().contains('monthly'):
      return ObligationFrequency.monthly;
    case dynamic f when f.toString().contains('quarterly'):
      return ObligationFrequency.quarterly;
    case dynamic f when f.toString().contains('annually'):
      return ObligationFrequency.annually;
    default:
      return ObligationFrequency.monthly;
  }
}

double _getMonthlyAmount(FinancialObligation obligation) {
  switch (obligation.frequency) {
    case ObligationFrequency.daily:
      return obligation.amount * 30;
    case ObligationFrequency.weekly:
      return obligation.amount * 4.33;
    case ObligationFrequency.biweekly:
      return obligation.amount * 2.16;
    case ObligationFrequency.monthly:
      return obligation.amount;
    case ObligationFrequency.quarterly:
      return obligation.amount / 3;
    case ObligationFrequency.annually:
      return obligation.amount / 12;
  }
}