import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/insight.dart';
import '../repositories/insight_repository.dart';

/// Use case for analyzing spending trends and generating insights
class AnalyzeSpendingTrends {
  const AnalyzeSpendingTrends(this._repository);

  final InsightRepository _repository;

  /// Execute the use case to analyze spending trends
  Future<Result<List<Insight>>> call({
    DateTime? startDate,
    DateTime? endDate,
    int monthsToAnalyze = 6,
  }) async {
    try {
      final now = DateTime.now();
      final analysisStart = startDate ?? DateTime(now.year, now.month - monthsToAnalyze, 1);
      final analysisEnd = endDate ?? now;

      // Generate spending trends data
      final trendsResult = await _repository.generateSpendingTrends(analysisStart, analysisEnd);
      if (trendsResult.isError) {
        return Result.error(trendsResult.failureOrNull!);
      }

      final trends = trendsResult.dataOrNull ?? [];

      // Generate insights from trends
      final insights = <Insight>[];

      // Analyze each trend for significant changes
      for (final trend in trends) {
        if (trend.isSignificant) {
          final insight = _createTrendInsight(trend);
          insights.add(insight);
        }
      }

      // Generate period comparison insights
      final comparisonInsights = await _generatePeriodComparisonInsights(analysisStart, analysisEnd);
      insights.addAll(comparisonInsights);

      // Generate anomaly detection insights
      final anomalyInsights = await _generateAnomalyInsights(analysisStart, analysisEnd);
      insights.addAll(anomalyInsights);

      return Result.success(insights);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to analyze spending trends: $e'));
    }
  }

  /// Create insight from a significant spending trend
  Insight _createTrendInsight(SpendingTrend trend) {
    final direction = trend.direction;
    final percentage = trend.changePercentage.abs();
    final categoryName = trend.categoryName ?? trend.categoryId;

    String title;
    String message;
    InsightPriority priority;

    switch (direction) {
      case TrendDirection.increasing:
        title = 'Increasing spending in $categoryName';
        message = 'Your spending in $categoryName has increased by ${percentage.toStringAsFixed(1)}% '
            'compared to the previous period. Consider reviewing your budget for this category.';
        priority = percentage > 50 ? InsightPriority.high : InsightPriority.medium;
        break;

      case TrendDirection.decreasing:
        title = 'Decreasing spending in $categoryName';
        message = 'Great job! Your spending in $categoryName has decreased by ${percentage.toStringAsFixed(1)}%. '
            'Keep up the good work on managing this expense.';
        priority = InsightPriority.low;
        break;

      case TrendDirection.stable:
        title = 'Stable spending in $categoryName';
        message = 'Your spending in $categoryName has remained stable. This shows good consistency in your budgeting.';
        priority = InsightPriority.low;
        break;
    }

    return Insight(
      id: 'trend_${trend.categoryId}_${trend.period.millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: InsightType.spendingTrend,
      generatedAt: DateTime.now(),
      categoryId: trend.categoryId,
      amount: trend.amount,
      percentage: trend.changePercentage,
      priority: priority,
    );
  }

  /// Generate period comparison insights
  Future<List<Insight>> _generatePeriodComparisonInsights(DateTime startDate, DateTime endDate) async {
    final insights = <Insight>[];

    try {
      // Compare current month with previous month
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final previousMonth = DateTime(now.year, now.month - 1, 1);

      final currentSummaryResult = await _repository.generateMonthlySummary(currentMonth);
      final previousSummaryResult = await _repository.generateMonthlySummary(previousMonth);

      if (currentSummaryResult.isSuccess && previousSummaryResult.isSuccess) {
        final current = currentSummaryResult.dataOrNull!;
        final previous = previousSummaryResult.dataOrNull!;

        final expenseChange = current.totalExpenses - previous.totalExpenses;
        final expenseChangePercent = previous.totalExpenses > 0
            ? (expenseChange / previous.totalExpenses) * 100
            : 0.0;

        if (expenseChangePercent.abs() >= 10) {
          final direction = expenseChange > 0 ? 'increased' : 'decreased';
          final insight = Insight(
            id: 'period_comparison_${currentMonth.millisecondsSinceEpoch}',
            title: 'Monthly spending ${direction} by ${expenseChangePercent.abs().toStringAsFixed(1)}%',
            message: 'Your total expenses this month ${direction} by \$${expenseChange.abs().toStringAsFixed(2)} '
                'compared to last month. ${expenseChange > 0 ? 'Consider reviewing your spending habits.' : 'Great job on reducing expenses!'}',
            type: InsightType.comparison,
            generatedAt: DateTime.now(),
            amount: expenseChange,
            percentage: expenseChangePercent,
            priority: expenseChangePercent.abs() > 25 ? InsightPriority.high : InsightPriority.medium,
          );
          insights.add(insight);
        }
      }
    } catch (e) {
      // Silently handle errors in period comparison
    }

    return insights;
  }

  /// Generate anomaly detection insights
  Future<List<Insight>> _generateAnomalyInsights(DateTime startDate, DateTime endDate) async {
    final insights = <Insight>[];

    try {
      // Get transactions for the period
      final transactionsResult = await _repository.generateSpendingTrends(startDate, endDate);
      if (transactionsResult.isError) return insights;

      final trends = transactionsResult.dataOrNull ?? [];

      // Simple anomaly detection: transactions significantly above average
      for (final trend in trends) {
        // Check for unusual spikes (more than 200% of previous period)
        if (trend.changePercentage > 200) {
          final insight = Insight(
            id: 'anomaly_${trend.categoryId}_${trend.period.millisecondsSinceEpoch}',
            title: 'Unusual spending spike in ${trend.categoryName ?? trend.categoryId}',
            message: 'You spent \$${trend.amount.toStringAsFixed(2)} in ${trend.categoryName ?? trend.categoryId} '
                'this period, which is ${trend.changePercentage.toStringAsFixed(0)}% higher than usual. '
                'This might be worth reviewing.',
            type: InsightType.unusualActivity,
            generatedAt: DateTime.now(),
            categoryId: trend.categoryId,
            amount: trend.amount,
            percentage: trend.changePercentage,
            priority: InsightPriority.high,
          );
          insights.add(insight);
        }
      }
    } catch (e) {
      // Silently handle errors in anomaly detection
    }

    return insights;
  }
}