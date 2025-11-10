import 'dart:math' as math;

import 'package:hive/hive.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../../../budgets/domain/repositories/budget_repository.dart';
import '../models/insight_dto.dart';
import '../../domain/entities/insight.dart';

/// Hive-based data source for insight operations
class InsightHiveDataSource {
  static const String _insightsBoxName = 'insights';
  static const String _reportsBoxName = 'financial_reports';

  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;

  Box<InsightDto>? _insightsBox;
  Box<FinancialReportDto>? _reportsBox;

  InsightHiveDataSource(this._transactionRepository, this._budgetRepository);

  /// Initialize the data source
  Future<void> init() async {
    // Wait for Hive to be initialized
    await HiveStorage.init();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(InsightDtoAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(FinancialReportDtoAdapter());
    }

    // Handle box opening with proper type checking
    if (!Hive.isBoxOpen(_insightsBoxName)) {
      _insightsBox = await Hive.openBox<InsightDto>(_insightsBoxName);
    } else {
      try {
        _insightsBox = Hive.box<InsightDto>(_insightsBoxName);
      } catch (e) {
        // If the box is already open with wrong type, close and reopen
        if (e.toString().contains('Box<dynamic>')) {
          await Hive.box(_insightsBoxName).close();
          _insightsBox = await Hive.openBox<InsightDto>(_insightsBoxName);
        } else {
          rethrow;
        }
      }
    }

    if (!Hive.isBoxOpen(_reportsBoxName)) {
      _reportsBox = await Hive.openBox<FinancialReportDto>(_reportsBoxName);
    } else {
      try {
        _reportsBox = Hive.box<FinancialReportDto>(_reportsBoxName);
      } catch (e) {
        // If the box is already open with wrong type, close and reopen
        if (e.toString().contains('Box<dynamic>')) {
          await Hive.box(_reportsBoxName).close();
          _reportsBox = await Hive.openBox<FinancialReportDto>(_reportsBoxName);
        } else {
          rethrow;
        }
      }
    }
  }

  // ===== INSIGHT OPERATIONS =====

  /// Get all insights
  Future<Result<List<Insight>>> getAllInsights() async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _insightsBox!.values.toList();
      final insights = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by generated date (newest first)
      insights.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

      return Result.success(insights);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get insights: $e'));
    }
  }

  /// Get insight by ID
  Future<Result<Insight?>> getInsightById(String id) async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = _insightsBox!.get(id);
      if (dto == null) {
        return Result.success(null);
      }

      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.error(Failure.cache('Failed to get insight: $e'));
    }
  }

  /// Get recent insights
  Future<Result<List<Insight>>> getRecentInsights({int limit = 20}) async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _insightsBox!.values.toList();
      final insights = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by generated date (newest first) and take limit
      insights.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
      final recent = insights.take(limit).toList();

      return Result.success(recent);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get recent insights: $e'));
    }
  }

  /// Get unread insights
  Future<Result<List<Insight>>> getUnreadInsights() async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _insightsBox!.values.where((dto) => !dto.isRead).toList();
      final insights = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by generated date (newest first)
      insights.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

      return Result.success(insights);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get unread insights: $e'));
    }
  }

  /// Get insights by type
  Future<Result<List<Insight>>> getInsightsByType(InsightType type) async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _insightsBox!.values.where((dto) => dto.type == type.name).toList();
      final insights = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by generated date (newest first)
      insights.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

      return Result.success(insights);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get insights by type: $e'));
    }
  }

  /// Get insights by priority
  Future<Result<List<Insight>>> getInsightsByPriority(InsightPriority priority) async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _insightsBox!.values.where((dto) => dto.priority == priority.name).toList();
      final insights = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by generated date (newest first)
      insights.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

      return Result.success(insights);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get insights by priority: $e'));
    }
  }

  /// Mark insight as read
  Future<Result<Insight>> markInsightAsRead(String insightId) async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = _insightsBox!.get(insightId);
      if (dto == null) {
        return Result.error(Failure.notFound('Insight not found'));
      }

      dto.isRead = true;
      await _insightsBox!.put(insightId, dto);

      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.error(Failure.cache('Failed to mark insight as read: $e'));
    }
  }

  /// Mark all insights as read
  Future<Result<void>> markAllInsightsAsRead() async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _insightsBox!.values.toList();
      for (final dto in dtos) {
        dto.isRead = true;
        await _insightsBox!.put(dto.id, dto);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to mark all insights as read: $e'));
    }
  }

  /// Archive insight
  Future<Result<Insight>> archiveInsight(String insightId) async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = _insightsBox!.get(insightId);
      if (dto == null) {
        return Result.error(Failure.notFound('Insight not found'));
      }

      dto.isArchived = true;
      await _insightsBox!.put(insightId, dto);

      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.error(Failure.cache('Failed to archive insight: $e'));
    }
  }

  /// Delete insight
  Future<Result<void>> deleteInsight(String insightId) async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      await _insightsBox!.delete(insightId);
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to delete insight: $e'));
    }
  }

  /// Clear old insights
  Future<Result<int>> clearOldInsights(int daysOld) async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final dtos = _insightsBox!.values.where((dto) => dto.generatedAt.isBefore(cutoffDate)).toList();

      for (final dto in dtos) {
        await _insightsBox!.delete(dto.id);
      }

      return Result.success(dtos.length);
    } catch (e) {
      return Result.error(Failure.cache('Failed to clear old insights: $e'));
    }
  }

  // ===== FINANCIAL REPORT OPERATIONS =====

  /// Create financial report
  Future<Result<FinancialReport>> createFinancialReport(FinancialReport report) async {
    try {
      if (_reportsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = FinancialReportDto.fromDomain(report);
      await _reportsBox!.put(report.id, dto);

      return Result.success(report);
    } catch (e) {
      return Result.error(Failure.cache('Failed to create financial report: $e'));
    }
  }

  /// Get all financial reports
  Future<Result<List<FinancialReport>>> getAllFinancialReports() async {
    try {
      if (_reportsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dtos = _reportsBox!.values.toList();
      final reports = dtos.map((dto) => dto.toDomain()).toList();

      // Sort by generated date (newest first)
      reports.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

      return Result.success(reports);
    } catch (e) {
      return Result.error(Failure.cache('Failed to get financial reports: $e'));
    }
  }

  /// Get financial report by ID
  Future<Result<FinancialReport?>> getFinancialReportById(String id) async {
    try {
      if (_reportsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = _reportsBox!.get(id);
      if (dto == null) {
        return Result.success(null);
      }

      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.error(Failure.cache('Failed to get financial report: $e'));
    }
  }

  /// Delete financial report
  Future<Result<void>> deleteFinancialReport(String reportId) async {
    try {
      if (_reportsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      await _reportsBox!.delete(reportId);
      return Result.success(null);
    } catch (e) {
      return Result.error(Failure.cache('Failed to delete financial report: $e'));
    }
  }

  /// Export financial report (placeholder - would implement actual export logic)
  Future<Result<String>> exportFinancialReport(String reportId, String format) async {
    try {
      if (_reportsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      final dto = _reportsBox!.get(reportId);
      if (dto == null) {
        return Result.error(Failure.notFound('Financial report not found'));
      }

      // Mark as exported
      dto.isExported = true;
      await _reportsBox!.put(reportId, dto);

      // Placeholder for actual export logic
      // In a real implementation, this would generate and save the file
      final filePath = '/exports/report_$reportId.$format';

      return Result.success(filePath);
    } catch (e) {
      return Result.error(Failure.cache('Failed to export financial report: $e'));
    }
  }

  // ===== BUSINESS LOGIC METHODS =====

  /// Generate insights summary (complex business logic)
  Future<Result<InsightsSummary>> generateInsightsSummary() async {
    try {
      if (_insightsBox == null) {
        return Result.error(Failure.cache('Data source not initialized'));
      }

      // Get recent insights
      final recentInsightsResult = await getRecentInsights(limit: 10);
      if (recentInsightsResult.isError) {
        return Result.error(recentInsightsResult.failureOrNull!);
      }

      // Calculate financial health score
      final healthScoreResult = await calculateFinancialHealthScore();
      if (healthScoreResult.isError) {
        return Result.error(healthScoreResult.failureOrNull!);
      }

      // Generate current month summary
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthlySummaryResult = await generateMonthlySummary(monthStart);
      if (monthlySummaryResult.isError) {
        return Result.error(monthlySummaryResult.failureOrNull!);
      }

      // Get key spending trends (last 3 months)
      final trendsStart = DateTime(now.year, now.month - 3, 1);
      final trendsResult = await generateSpendingTrends(trendsStart, now);
      if (trendsResult.isError) {
        return Result.error(trendsResult.failureOrNull!);
      }

      // Get category analysis for current month
      final categoryAnalysisResult = await generateCategoryAnalysis(monthStart);
      if (categoryAnalysisResult.isError) {
        return Result.error(categoryAnalysisResult.failureOrNull!);
      }

      final summary = InsightsSummary(
        recentInsights: recentInsightsResult.dataOrNull!,
        healthScore: healthScoreResult.dataOrNull!,
        currentMonthSummary: monthlySummaryResult.dataOrNull!,
        keyTrends: trendsResult.dataOrNull!,
        categoryAnalysis: categoryAnalysisResult.dataOrNull!,
        generatedAt: DateTime.now(),
      );

      return Result.success(summary);
    } catch (e) {
      return Result.error(Failure.cache('Failed to generate insights summary: $e'));
    }
  }

  /// Generate monthly summary
  Future<Result<MonthlySummary>> generateMonthlySummary(DateTime month) async {
    try {
      // Calculate month end date
      final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      // Get all transactions for the month
      final transactionsResult = await _transactionRepository.getByDateRange(month, monthEnd);
      if (transactionsResult.isError) {
        return Result.error(transactionsResult.failureOrNull!);
      }

      final transactions = transactionsResult.dataOrNull!;

      // Calculate total income
      final totalIncome = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      // Calculate total expenses
      final totalExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      // Calculate savings and savings rate
      final totalSavings = totalIncome - totalExpenses;
      final savingsRate = totalIncome > 0 ? (totalSavings / totalIncome) * 100 : 0.0;

      // Calculate transaction statistics
      final totalTransactions = transactions.length;
      final averageTransactionAmount = totalTransactions > 0
          ? transactions.fold<double>(0.0, (sum, t) => sum + t.amount) / totalTransactions
          : 0.0;

      final largestExpense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (max, t) => t.amount > max ? t.amount : max);

      // Group transactions by category for analysis
      final categoryTotals = <String, double>{};
      final categoryTransactionCounts = <String, int>{};
      final categoryNames = <String, String>{};

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.expense) {
          categoryTotals[transaction.categoryId] = (categoryTotals[transaction.categoryId] ?? 0.0) + transaction.amount;
          categoryTransactionCounts[transaction.categoryId] = (categoryTransactionCounts[transaction.categoryId] ?? 0) + 1;
          // Note: categoryNames would need to be populated from category repository
          categoryNames[transaction.categoryId] = transaction.categoryId; // Placeholder
        }
      }

      // Find top spending category
      String topSpendingCategory = '';
      double maxSpending = 0.0;
      categoryTotals.forEach((categoryId, amount) {
        if (amount > maxSpending) {
          maxSpending = amount;
          topSpendingCategory = categoryNames[categoryId] ?? categoryId;
        }
      });

      // Generate category breakdown (placeholder - would need budget data)
      final categoryBreakdown = categoryTotals.entries.map((entry) {
        final categoryId = entry.key;
        final spent = entry.value;
        final budget = spent * 1.2; // Placeholder budget calculation
        final percentageOfBudget = budget > 0 ? (spent / budget) * 100 : 0.0;
        final percentageOfTotal = totalExpenses > 0 ? (spent / totalExpenses) * 100 : 0.0;

        return CategoryAnalysis(
          categoryId: categoryId,
          categoryName: categoryNames[categoryId] ?? categoryId,
          totalSpent: spent,
          budgetAmount: budget,
          percentageOfBudget: percentageOfBudget,
          percentageOfTotalSpending: percentageOfTotal,
          transactionCount: categoryTransactionCounts[categoryId] ?? 0,
          averageTransactionAmount: (categoryTransactionCounts[categoryId] ?? 0) > 0
              ? spent / (categoryTransactionCounts[categoryId] ?? 1)
              : 0.0,
          period: month,
          status: percentageOfBudget > 100
              ? CategoryHealthStatus.overBudget
              : percentageOfBudget > 75
                  ? CategoryHealthStatus.warning
                  : CategoryHealthStatus.good,
        );
      }).toList();

      // Placeholder budget adherence (would need actual budget data)
      final budgetAdherence = categoryBreakdown.isNotEmpty
          ? categoryBreakdown.fold<double>(0.0, (sum, cat) => sum + (100.0 - cat.percentageOfBudget.abs())) / categoryBreakdown.length
          : 100.0;

      // Placeholder trends (would need historical data)
      final trends = <SpendingTrend>[];

      final summary = MonthlySummary(
        month: month,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        totalSavings: totalSavings,
        savingsRate: savingsRate,
        budgetAdherence: budgetAdherence.clamp(0.0, 100.0),
        categoryBreakdown: categoryBreakdown,
        trends: trends,
        totalTransactions: totalTransactions,
        averageTransactionAmount: averageTransactionAmount,
        largestExpense: largestExpense,
        topSpendingCategory: topSpendingCategory,
      );

      return Result.success(summary);
    } catch (e) {
      return Result.error(Failure.cache('Failed to generate monthly summary: $e'));
    }
  }

  /// Calculate financial health score
  Future<Result<FinancialHealthScore>> calculateFinancialHealthScore() async {
    try {
      final now = DateTime.now();
      final analysisPeriod = DateTime(now.year, now.month - 3, 1); // Last 3 months

      // Get transactions for analysis period
      final transactionsResult = await _transactionRepository.getByDateRange(analysisPeriod, now);
      if (transactionsResult.isError) {
        return Result.error(transactionsResult.failureOrNull!);
      }

      final transactions = transactionsResult.dataOrNull ?? [];

      // Calculate component scores
      final savingsRateScore = await _calculateSavingsRateScore(transactions);
      final budgetAdherenceScore = await _calculateBudgetAdherenceScore();
      final spendingPatternsScore = await _calculateSpendingPatternsScore(transactions);
      final incomeStabilityScore = await _calculateIncomeStabilityScore(transactions);

      final componentScores = {
        'savings_rate': savingsRateScore,
        'budget_adherence': budgetAdherenceScore,
        'spending_patterns': spendingPatternsScore,
        'income_stability': incomeStabilityScore,
      };

      // Calculate overall score (weighted average)
      final overallScore = ((savingsRateScore * 0.3) +
                          (budgetAdherenceScore * 0.3) +
                          (spendingPatternsScore * 0.2) +
                          (incomeStabilityScore * 0.2)).round();

      // Determine grade
      final grade = _getGradeFromScore(overallScore);

      // Generate insights
      final insights = _generateHealthInsights(componentScores, transactions);

      final score = FinancialHealthScore(
        overallScore: overallScore.clamp(0, 100),
        grade: grade,
        componentScores: componentScores,
        strengths: insights.strengths,
        weaknesses: insights.weaknesses,
        recommendations: insights.recommendations,
        calculatedAt: DateTime.now(),
      );

      return Result.success(score);
    } catch (e) {
      return Result.error(Failure.cache('Failed to calculate financial health score: $e'));
    }
  }

  /// Generate spending trends
  Future<Result<List<SpendingTrend>>> generateSpendingTrends(DateTime startDate, DateTime endDate) async {
    try {
      final trends = <SpendingTrend>[];

      // Get all transactions for the period
      final transactionsResult = await _transactionRepository.getByDateRange(startDate, endDate);
      if (transactionsResult.isError) {
        return Result.error(transactionsResult.failureOrNull!);
      }

      final transactions = transactionsResult.dataOrNull ?? [];

      // Group transactions by category and month
      final categoryMonthlyData = <String, Map<DateTime, double>>{};

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.expense) {
          final monthKey = DateTime(transaction.date.year, transaction.date.month, 1);

          categoryMonthlyData[transaction.categoryId] ??= {};
          categoryMonthlyData[transaction.categoryId]![monthKey] =
              (categoryMonthlyData[transaction.categoryId]![monthKey] ?? 0.0) + transaction.amount;
        }
      }

      // Calculate trends for each category
      for (final entry in categoryMonthlyData.entries) {
        final categoryId = entry.key;
        final monthlyAmounts = entry.value;

        // Sort months chronologically
        final sortedMonths = monthlyAmounts.keys.toList()..sort();

        for (int i = 1; i < sortedMonths.length; i++) {
          final currentMonth = sortedMonths[i];
          final previousMonth = sortedMonths[i - 1];

          final currentAmount = monthlyAmounts[currentMonth] ?? 0.0;
          final previousAmount = monthlyAmounts[previousMonth] ?? 0.0;

          if (previousAmount > 0) {
            final changeAmount = currentAmount - previousAmount;
            final changePercentage = (changeAmount / previousAmount) * 100;

            TrendDirection direction;
            if (changePercentage > 5) {
              direction = TrendDirection.increasing;
            } else if (changePercentage < -5) {
              direction = TrendDirection.decreasing;
            } else {
              direction = TrendDirection.stable;
            }

            // Get category name (placeholder - would need category repository)
            final categoryName = categoryId; // Placeholder

            final trend = SpendingTrend(
              period: currentMonth,
              amount: currentAmount,
              previousAmount: previousAmount,
              changeAmount: changeAmount,
              changePercentage: changePercentage,
              direction: direction,
              categoryId: categoryId,
              categoryName: categoryName,
            );

            trends.add(trend);
          }
        }
      }

      // Sort trends by period (newest first)
      trends.sort((a, b) => b.period.compareTo(a.period));

      return Result.success(trends);
    } catch (e) {
      return Result.error(Failure.cache('Failed to generate spending trends: $e'));
    }
  }

  /// Generate category analysis
  Future<Result<List<CategoryAnalysis>>> generateCategoryAnalysis(DateTime period) async {
    try {
      // Placeholder implementation - would analyze transaction data
      final analysis = <CategoryAnalysis>[];

      return Result.success(analysis);
    } catch (e) {
      return Result.error(Failure.cache('Failed to generate category analysis: $e'));
    }
  }

  /// Calculate savings rate score from transactions
  Future<int> _calculateSavingsRateScore(List<Transaction> transactions) async {
    if (transactions.isEmpty) return 50; // Neutral score for no data

    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    if (totalIncome == 0) return 0; // No income means no savings possible

    final savingsRate = ((totalIncome - totalExpenses) / totalIncome) * 100;

    // Score based on savings rate benchmarks
    if (savingsRate >= 20) return 100; // Excellent (20%+ savings)
    if (savingsRate >= 15) return 85;  // Very good
    if (savingsRate >= 10) return 70;  // Good
    if (savingsRate >= 5) return 50;   // Fair
    if (savingsRate >= 0) return 30;   // Poor but not negative
    return 0; // Negative savings rate
  }

  /// Calculate budget adherence score from budgets and transactions
  Future<int> _calculateBudgetAdherenceScore() async {
    try {
      // Get active budgets
      final budgetsResult = await _getBudgetsForAdherence();
      if (budgetsResult.isError || budgetsResult.dataOrNull!.isEmpty) {
        return 70; // Neutral score if no budgets
      }

      final budgets = budgetsResult.dataOrNull!;
      double totalAdherence = 0.0;
      int budgetCount = 0;

      for (final budget in budgets) {
        final adherence = await _calculateSingleBudgetAdherence(budget);
        totalAdherence += adherence;
        budgetCount++;
      }

      if (budgetCount == 0) return 70;

      final averageAdherence = totalAdherence / budgetCount;
      return averageAdherence.round().clamp(0, 100);
    } catch (e) {
      return 50; // Neutral score on error
    }
  }

  /// Calculate spending patterns score from transaction analysis
  Future<int> _calculateSpendingPatternsScore(List<Transaction> transactions) async {
    if (transactions.isEmpty) return 50;

    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    if (expenses.isEmpty) return 100; // No expenses is excellent

    // Analyze spending consistency and volatility
    final monthlySpending = <int, double>{};
    for (final expense in expenses) {
      final monthKey = expense.date.year * 12 + expense.date.month;
      monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0.0) + expense.amount;
    }

    if (monthlySpending.length < 2) return 70; // Need at least 2 months for pattern analysis

    // Calculate spending volatility (coefficient of variation)
    final spendingValues = monthlySpending.values.toList();
    final mean = spendingValues.reduce((a, b) => a + b) / spendingValues.length;
    if (mean == 0) return 100;

    final variance = spendingValues.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / spendingValues.length;
    final stdDev = math.sqrt(variance);
    final cv = stdDev / mean; // Coefficient of variation

    // Lower volatility (more consistent spending) gets higher score
    if (cv <= 0.1) return 100; // Very consistent
    if (cv <= 0.2) return 85;  // Consistent
    if (cv <= 0.3) return 70;  // Moderately consistent
    if (cv <= 0.5) return 50;  // Variable
    return 30; // Highly variable
  }

  /// Calculate income stability score from transaction analysis
  Future<int> _calculateIncomeStabilityScore(List<Transaction> transactions) async {
    if (transactions.isEmpty) return 50;

    final incomes = transactions.where((t) => t.type == TransactionType.income).toList();
    if (incomes.isEmpty) return 0; // No income data

    // Group income by month
    final monthlyIncome = <int, double>{};
    for (final income in incomes) {
      final monthKey = income.date.year * 12 + income.date.month;
      monthlyIncome[monthKey] = (monthlyIncome[monthKey] ?? 0.0) + income.amount;
    }

    if (monthlyIncome.length < 2) return 70; // Need at least 2 months for stability analysis

    // Calculate income stability (coefficient of variation)
    final incomeValues = monthlyIncome.values.toList();
    final mean = incomeValues.reduce((a, b) => a + b) / incomeValues.length;
    if (mean == 0) return 0;

    final variance = incomeValues.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / incomeValues.length;
    final stdDev = math.sqrt(variance);
    final cv = stdDev / mean; // Coefficient of variation

    // Lower volatility (more stable income) gets higher score
    if (cv <= 0.05) return 100; // Very stable
    if (cv <= 0.1) return 90;  // Stable
    if (cv <= 0.2) return 75;  // Moderately stable
    if (cv <= 0.3) return 60;  // Variable
    if (cv <= 0.5) return 40;  // Unstable
    return 20; // Highly unstable
  }

  /// Get grade from overall score
  FinancialHealthGrade _getGradeFromScore(int score) {
    if (score >= 90) return FinancialHealthGrade.excellent;
    if (score >= 70) return FinancialHealthGrade.good;
    if (score >= 50) return FinancialHealthGrade.fair;
    if (score >= 30) return FinancialHealthGrade.poor;
    return FinancialHealthGrade.critical;
  }

  /// Generate health insights based on component scores
  _HealthInsights _generateHealthInsights(Map<String, int> componentScores, List<Transaction> transactions) {
    final strengths = <String>[];
    final weaknesses = <String>[];
    final recommendations = <String>[];

    // Analyze savings rate
    final savingsScore = componentScores['savings_rate'] ?? 50;
    if (savingsScore >= 80) {
      strengths.add('Excellent savings rate');
    } else if (savingsScore >= 60) {
      strengths.add('Good savings habits');
    } else if (savingsScore >= 40) {
      weaknesses.add('Savings rate could be improved');
      recommendations.add('Aim to save at least 10-15% of your income');
    } else {
      weaknesses.add('Low or negative savings rate');
      recommendations.add('Focus on building an emergency fund and increasing savings');
    }

    // Analyze budget adherence
    final budgetScore = componentScores['budget_adherence'] ?? 50;
    if (budgetScore >= 80) {
      strengths.add('Strong budget adherence');
    } else if (budgetScore >= 60) {
      strengths.add('Good budget management');
    } else if (budgetScore >= 40) {
      weaknesses.add('Budget adherence needs attention');
      recommendations.add('Track spending more closely against your budget');
    } else {
      weaknesses.add('Poor budget adherence');
      recommendations.add('Create a realistic budget and stick to it');
    }

    // Analyze spending patterns
    final spendingScore = componentScores['spending_patterns'] ?? 50;
    if (spendingScore >= 80) {
      strengths.add('Consistent spending patterns');
    } else if (spendingScore >= 60) {
      strengths.add('Moderately consistent spending');
    } else if (spendingScore >= 40) {
      weaknesses.add('Variable spending patterns');
      recommendations.add('Analyze spending trends and identify areas for consistency');
    } else {
      weaknesses.add('Highly variable spending');
      recommendations.add('Work on stabilizing spending habits');
    }

    // Analyze income stability
    final incomeScore = componentScores['income_stability'] ?? 50;
    if (incomeScore >= 80) {
      strengths.add('Stable income');
    } else if (incomeScore >= 60) {
      strengths.add('Relatively stable income');
    } else if (incomeScore >= 40) {
      weaknesses.add('Variable income');
      recommendations.add('Consider building income stability through side work or investments');
    } else {
      weaknesses.add('Unstable income');
      recommendations.add('Focus on income diversification and emergency fund building');
    }

    // Add general recommendations based on overall performance
    final overallScore = componentScores.values.fold<double>(0, (sum, score) => sum + score) / componentScores.length;
    if (overallScore < 50) {
      recommendations.add('Consider consulting a financial advisor for personalized guidance');
    }

    return _HealthInsights(strengths, weaknesses, recommendations);
  }

  /// Helper method to get budgets for adherence calculation
  Future<Result<List<Budget>>> _getBudgetsForAdherence() async {
    try {
      // Get active budgets for current period
      final budgetsResult = await _budgetRepository.getActive();
      if (budgetsResult.isError) {
        return Result.error(budgetsResult.failureOrNull!);
      }

      return budgetsResult;
    } catch (e) {
      return Result.error(Failure.unknown('Failed to get budgets for adherence: $e'));
    }
  }

  /// Calculate adherence for a single budget
  Future<double> _calculateSingleBudgetAdherence(Budget budget) async {
    try {
      // Get transactions for the budget period
      final transactionsResult = await _transactionRepository.getByDateRange(budget.startDate, budget.endDate);
      if (transactionsResult.isError) {
        return 75.0; // Default adherence on error
      }

      final transactions = transactionsResult.dataOrNull ?? [];

      // Calculate actual spending for budget categories
      double totalSpent = 0.0;
      for (final category in budget.categories) {
        final categorySpending = transactions
            .where((t) => t.type == TransactionType.expense && t.categoryId == category.id)
            .fold<double>(0.0, (sum, t) => sum + t.amount);
        totalSpent += categorySpending;
      }

      // Calculate adherence percentage
      final budgetAmount = budget.totalBudget;
      if (budgetAmount == 0) return 100.0; // Perfect adherence if no budget set

      final adherencePercentage = (totalSpent / budgetAmount) * 100;

      // Convert to adherence score (100% is perfect, but over-budget is penalized)
      if (adherencePercentage <= 100) {
        return 100.0 - adherencePercentage; // Closer to budget = higher score
      } else {
        // Over budget - penalize based on how much over
        final overBudgetPercentage = adherencePercentage - 100;
        return (100.0 - overBudgetPercentage).clamp(0.0, 100.0);
      }
    } catch (e) {
      return 75.0; // Default adherence on error
    }
  }

  /// Close the boxes
  Future<void> close() async {
    await _insightsBox?.close();
    await _reportsBox?.close();
    _insightsBox = null;
    _reportsBox = null;
  }
}

/// Helper class for health insights
class _HealthInsights {
  const _HealthInsights(this.strengths, this.weaknesses, this.recommendations);

  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
}