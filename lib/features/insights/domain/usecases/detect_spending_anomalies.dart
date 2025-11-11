import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/insight.dart';

/// Use case for detecting unusual spending patterns and anomalies
class DetectSpendingAnomalies {
  const DetectSpendingAnomalies(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  /// Simple square root calculation using Newton's method
  double _sqrt(double x) {
    if (x < 0) return 0;
    if (x == 0 || x == 1) return x;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  /// Execute the use case to detect spending anomalies
  Future<Result<List<Insight>>> call({
    DateTime? startDate,
    int monthsToAnalyze = 6,
    double anomalyThreshold = 2.0, // Standard deviations
  }) async {
    try {
      final now = DateTime.now();
      final analysisStart = startDate ?? DateTime(now.year, now.month - monthsToAnalyze, 1);
      final analysisEnd = now;

      // Get all transactions for analysis period
      final transactionsResult = await _transactionRepository.getByDateRange(analysisStart, analysisEnd);
      if (transactionsResult.isError) {
        return Result.error(transactionsResult.failureOrNull!);
      }

      final transactions = transactionsResult.dataOrNull ?? [];
      final insights = <Insight>[];

      // Detect various types of anomalies
      final largeTransactionAnomalies = await _detectLargeTransactionAnomalies(transactions, anomalyThreshold);
      insights.addAll(largeTransactionAnomalies);

      final categorySpikeAnomalies = await _detectCategorySpendingSpikes(transactions, anomalyThreshold);
      insights.addAll(categorySpikeAnomalies);

      final unusualFrequencyAnomalies = await _detectUnusualTransactionFrequency(transactions);
      insights.addAll(unusualFrequencyAnomalies);

      final roundNumberAnomalies = await _detectRoundNumberAnomalies(transactions);
      insights.addAll(roundNumberAnomalies);

      return Result.success(insights);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to detect spending anomalies: $e'));
    }
  }

  /// Detect transactions that are unusually large compared to historical spending
  Future<List<Insight>> _detectLargeTransactionAnomalies(
    List<Transaction> transactions,
    double threshold,
  ) async {
    final insights = <Insight>[];

    // Group transactions by category
    final categoryTransactions = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryTransactions[transaction.categoryId] ??= [];
        categoryTransactions[transaction.categoryId]!.add(transaction);
      }
    }

    for (final entry in categoryTransactions.entries) {
      final categoryId = entry.key;
      final categoryTxns = entry.value;

      if (categoryTxns.length < 3) continue; // Need minimum data for analysis

      // Calculate mean and standard deviation
      final amounts = categoryTxns.map((t) => t.amount).toList();
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = amounts.map((a) => (a - mean) * (a - mean)).reduce((a, b) => a + b) / amounts.length;
      final stdDev = variance > 0 ? _sqrt(variance) : 0.0;

      if (stdDev == 0) continue;

      // Find transactions that exceed threshold
      for (final transaction in categoryTxns) {
        final zScore = (transaction.amount - mean) / stdDev;
        if (zScore > threshold) {
          final insight = Insight(
            id: 'anomaly_large_${transaction.id}',
            title: 'Unusually large transaction detected',
            message: 'A transaction of \$${transaction.amount.toStringAsFixed(2)} in ${transaction.categoryId} '
                'is ${zScore.toStringAsFixed(1)} standard deviations above the category average. '
                'This might be worth reviewing.',
            type: InsightType.unusualActivity,
            generatedAt: DateTime.now(),
            categoryId: transaction.categoryId,
            transactionId: transaction.id,
            amount: transaction.amount,
            percentage: zScore * 100, // Store z-score as percentage for display
            priority: zScore > 3 ? InsightPriority.urgent : InsightPriority.high,
          );
          insights.add(insight);
        }
      }
    }

    return insights;
  }

  /// Detect unusual spikes in category spending compared to recent history
  Future<List<Insight>> _detectCategorySpendingSpikes(
    List<Transaction> transactions,
    double threshold,
  ) async {
    final insights = <Insight>[];

    // Group by category and week
    final categoryWeeklySpending = <String, Map<DateTime, double>>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        // Get week start (Monday)
        final weekStart = transaction.date.subtract(Duration(days: transaction.date.weekday - 1));
        final weekKey = DateTime(weekStart.year, weekStart.month, weekStart.day);

        categoryWeeklySpending[transaction.categoryId] ??= {};
        categoryWeeklySpending[transaction.categoryId]![weekKey] =
            (categoryWeeklySpending[transaction.categoryId]![weekKey] ?? 0.0) + transaction.amount;
      }
    }

    for (final entry in categoryWeeklySpending.entries) {
      final categoryId = entry.key;
      final weeklyAmounts = entry.value;

      if (weeklyAmounts.length < 4) continue; // Need at least 4 weeks of data

      final sortedWeeks = weeklyAmounts.keys.toList()..sort();
      final recentWeeks = sortedWeeks.sublist(sortedWeeks.length - 4); // Last 4 weeks

      if (recentWeeks.length < 2) continue;

      // Calculate average of previous weeks
      final previousWeeks = recentWeeks.sublist(0, recentWeeks.length - 1);
      final previousAverage = previousWeeks.map((week) => weeklyAmounts[week] ?? 0.0).reduce((a, b) => a + b) / previousWeeks.length;

      // Check current week against average
      final currentWeek = recentWeeks.last;
      final currentAmount = weeklyAmounts[currentWeek] ?? 0.0;

      if (previousAverage > 0) {
        final ratio = currentAmount / previousAverage;
        if (ratio > threshold) {
          final insight = Insight(
            id: 'anomaly_spike_${categoryId}_${currentWeek.millisecondsSinceEpoch}',
            title: 'Unusual spending spike in $categoryId',
            message: 'Spending in $categoryId this week (\$${currentAmount.toStringAsFixed(2)}) '
                'is ${(ratio * 100).toStringAsFixed(0)}% higher than the previous ${previousWeeks.length}-week average. '
                'This could indicate unusual activity.',
            type: InsightType.unusualActivity,
            generatedAt: DateTime.now(),
            categoryId: categoryId,
            amount: currentAmount,
            percentage: (ratio - 1) * 100, // Percentage increase
            priority: ratio > 3 ? InsightPriority.urgent : InsightPriority.high,
          );
          insights.add(insight);
        }
      }
    }

    return insights;
  }

  /// Detect unusual transaction frequency patterns
  Future<List<Insight>> _detectUnusualTransactionFrequency(List<Transaction> transactions) async {
    final insights = <Insight>[];

    // Group by category and day
    final categoryDailyTransactions = <String, Map<DateTime, int>>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final dayKey = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);

        categoryDailyTransactions[transaction.categoryId] ??= {};
        categoryDailyTransactions[transaction.categoryId]![dayKey] =
            (categoryDailyTransactions[transaction.categoryId]![dayKey] ?? 0) + 1;
      }
    }

    for (final entry in categoryDailyTransactions.entries) {
      final categoryId = entry.key;
      final dailyCounts = entry.value;

      if (dailyCounts.length < 7) continue; // Need at least a week of data

      // Calculate average daily transactions
      final totalTransactions = dailyCounts.values.reduce((a, b) => a + b);
      final averageDaily = totalTransactions / dailyCounts.length;

      // Find days with unusually high transaction counts
      for (final dayEntry in dailyCounts.entries) {
        final count = dayEntry.value;
        if (count > averageDaily * 3 && count >= 5) { // At least 3x average and 5+ transactions
          final insight = Insight(
            id: 'anomaly_frequency_${categoryId}_${dayEntry.key.millisecondsSinceEpoch}',
            title: 'Unusual transaction frequency detected',
            message: '$count transactions in $categoryId on ${dayEntry.key.toString().split(' ')[0]} '
                'is unusually high compared to the average of ${averageDaily.toStringAsFixed(1)} transactions per day. '
                'This might indicate bulk purchases or unusual spending patterns.',
            type: InsightType.unusualActivity,
            generatedAt: DateTime.now(),
            categoryId: categoryId,
            amount: count.toDouble(),
            priority: InsightPriority.medium,
          );
          insights.add(insight);
        }
      }
    }

    return insights;
  }

  /// Detect transactions with round numbers that might indicate suspicious activity
  Future<List<Insight>> _detectRoundNumberAnomalies(List<Transaction> transactions) async {
    final insights = <Insight>[];

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final amount = transaction.amount;
        final amountStr = amount.toStringAsFixed(2);

        // Check for round hundreds (like 100.00, 200.00, etc.)
        final isRoundHundred = amount >= 100 && amount % 100 == 0 && amountStr.endsWith('.00');

        // Check for round thousands
        final isRoundThousand = amount >= 1000 && amount % 1000 == 0 && amountStr.endsWith('.00');

        if (isRoundHundred || isRoundThousand) {
          final insight = Insight(
            id: 'anomaly_round_${transaction.id}',
            title: 'Round number transaction detected',
            message: 'A transaction of \$${amount.toStringAsFixed(2)} appears to be a round number. '
                'While not necessarily suspicious, round number transactions can sometimes indicate '
                'cash withdrawals or other patterns worth monitoring.',
            type: InsightType.unusualActivity,
            generatedAt: DateTime.now(),
            categoryId: transaction.categoryId,
            transactionId: transaction.id,
            amount: amount,
            priority: InsightPriority.low,
          );
          insights.add(insight);
        }
      }
    }

    return insights;
  }
}
