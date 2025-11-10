import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/insight.dart';
import '../repositories/insight_repository.dart';

/// Use case for comparing spending between different periods
class CompareSpendingPeriods {
  const CompareSpendingPeriods(this._repository);

  final InsightRepository _repository;

  /// Execute the use case to compare spending periods
  Future<Result<List<Insight>>> call({
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    required DateTime previousPeriodStart,
    required DateTime previousPeriodEnd,
  }) async {
    try {
      // Get summaries for both periods
      final currentSummaryResult = await _repository.generateMonthlySummary(currentPeriodStart);
      final previousSummaryResult = await _repository.generateMonthlySummary(previousPeriodStart);

      if (currentSummaryResult.isError || previousSummaryResult.isError) {
        return Result.error(Failure.unknown('Failed to generate period summaries'));
      }

      final currentSummary = currentSummaryResult.dataOrNull!;
      final previousSummary = previousSummaryResult.dataOrNull!;

      final insights = <Insight>[];

      // Compare total expenses
      final expenseComparison = _compareMetric(
        'Total Expenses',
        currentSummary.totalExpenses,
        previousSummary.totalExpenses,
        'expenses',
      );
      if (expenseComparison != null) {
        insights.add(expenseComparison);
      }

      // Compare savings
      final savingsComparison = _compareMetric(
        'Savings',
        currentSummary.totalSavings,
        previousSummary.totalSavings,
        'savings',
      );
      if (savingsComparison != null) {
        insights.add(savingsComparison);
      }

      // Compare savings rate
      final savingsRateComparison = _compareMetric(
        'Savings Rate',
        currentSummary.savingsRate,
        previousSummary.savingsRate,
        'savings_rate',
        isPercentage: true,
      );
      if (savingsRateComparison != null) {
        insights.add(savingsRateComparison);
      }

      // Compare budget adherence
      final budgetAdherenceComparison = _compareMetric(
        'Budget Adherence',
        currentSummary.budgetAdherence,
        previousSummary.budgetAdherence,
        'budget_adherence',
        isPercentage: true,
      );
      if (budgetAdherenceComparison != null) {
        insights.add(budgetAdherenceComparison);
      }

      // Compare category spending
      final categoryComparisons = _compareCategorySpending(
        currentSummary.categoryBreakdown,
        previousSummary.categoryBreakdown,
      );
      insights.addAll(categoryComparisons);

      return Result.success(insights);
    } catch (e) {
      return Result.error(Failure.unknown('Failed to compare spending periods: $e'));
    }
  }

  /// Compare a single metric between periods
  Insight? _compareMetric(
    String metricName,
    double currentValue,
    double previousValue,
    String metricId, {
    bool isPercentage = false,
  }) {
    if (previousValue == 0) return null;

    final changeAmount = currentValue - previousValue;
    final changePercentage = (changeAmount / previousValue) * 100;

    // Only create insight for significant changes (10%+ difference)
    if (changePercentage.abs() < 10) return null;

    final direction = changeAmount > 0 ? 'increased' : 'decreased';
    final valueFormat = isPercentage ? '${currentValue.toStringAsFixed(1)}%' : '\$${currentValue.toStringAsFixed(2)}';
    final changeFormat = isPercentage
        ? '${changePercentage.abs().toStringAsFixed(1)}%'
        : '\$${changeAmount.abs().toStringAsFixed(2)}';

    String title;
    String message;
    InsightPriority priority;

    if (metricId == 'savings' && changeAmount > 0) {
      title = 'Improved savings performance';
      message = 'Your savings $direction by $changeFormat compared to the previous period. '
          'Current savings: $valueFormat. Keep up the excellent work!';
      priority = InsightPriority.low;
    } else if (metricId == 'expenses' && changeAmount < 0) {
      title = 'Reduced spending';
      message = 'Great job! Your expenses $direction by $changeFormat. '
          'Current expenses: $valueFormat. This is a positive trend.';
      priority = InsightPriority.medium;
    } else if (metricId == 'expenses' && changeAmount > 0) {
      title = 'Increased spending';
      message = 'Your expenses $direction by $changeFormat compared to the previous period. '
          'Current expenses: $valueFormat. Consider reviewing your spending habits.';
      priority = changePercentage > 25 ? InsightPriority.high : InsightPriority.medium;
    } else if (metricId == 'savings_rate' && changeAmount > 0) {
      title = 'Better savings rate';
      message = 'Your savings rate improved by ${changePercentage.abs().toStringAsFixed(1)}% '
          'to $valueFormat. This shows better financial discipline.';
      priority = InsightPriority.low;
    } else if (metricId == 'budget_adherence' && changeAmount > 0) {
      title = 'Improved budget adherence';
      message = 'Your budget adherence improved by ${changePercentage.abs().toStringAsFixed(1)}% '
          'to $valueFormat. You\'re doing well staying within your budget!';
      priority = InsightPriority.low;
    } else {
      title = '$metricName $direction';
      message = 'Your $metricName $direction by $changeFormat compared to the previous period. '
          'Current value: $valueFormat.';
      priority = changePercentage.abs() > 25 ? InsightPriority.high : InsightPriority.medium;
    }

    return Insight(
      id: 'comparison_${metricId}_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: InsightType.comparison,
      generatedAt: DateTime.now(),
      amount: changeAmount,
      percentage: changePercentage,
      priority: priority,
    );
  }

  /// Compare spending across categories
  List<Insight> _compareCategorySpending(
    List<CategoryAnalysis> currentCategories,
    List<CategoryAnalysis> previousCategories,
  ) {
    final insights = <Insight>[];

    // Create maps for easy lookup
    final currentMap = {for (final cat in currentCategories) cat.categoryId: cat};
    final previousMap = {for (final cat in previousCategories) cat.categoryId: cat};

    // Find categories that exist in both periods
    final commonCategoryIds = currentMap.keys.toSet().intersection(previousMap.keys.toSet());

    for (final categoryId in commonCategoryIds) {
      final current = currentMap[categoryId]!;
      final previous = previousMap[categoryId]!;

      final changeAmount = current.totalSpent - previous.totalSpent;
      final changePercentage = previous.totalSpent > 0 ? (changeAmount / previous.totalSpent) * 100 : 0.0;

      // Only create insights for significant changes (20%+ difference)
      if (changePercentage.abs() >= 20) {
        final direction = changeAmount > 0 ? 'increased' : 'decreased';
        final insight = Insight(
          id: 'category_comparison_${categoryId}_${DateTime.now().millisecondsSinceEpoch}',
          title: '${current.categoryName} spending $direction significantly',
          message: 'Your spending in ${current.categoryName} $direction by ${changePercentage.abs().toStringAsFixed(1)}% '
              'compared to the previous period. Current spending: \$${current.totalSpent.toStringAsFixed(2)}. '
              '${changeAmount > 0 ? 'Consider reviewing this category.' : 'Great job reducing spending here!'}',
          type: InsightType.categoryAnalysis,
          generatedAt: DateTime.now(),
          categoryId: categoryId,
          amount: changeAmount,
          percentage: changePercentage,
          priority: changePercentage.abs() > 50 ? InsightPriority.high : InsightPriority.medium,
        );
        insights.add(insight);
      }
    }

    return insights;
  }
}