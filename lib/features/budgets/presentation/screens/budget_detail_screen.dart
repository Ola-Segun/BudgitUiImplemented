import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../../core/di/providers.dart' as core_providers;
import '../../domain/entities/budget.dart' as budget_entity;
import '../../../../core/theme/app_colors_extended.dart' as app_colors_extended;
import '../providers/budget_providers.dart';
import '../widgets/circular_budget_indicator.dart';
import '../widgets/budget_status_banner.dart';
import '../widgets/budget_metric_cards.dart';
import '../widgets/budget_stats_row.dart';
import '../widgets/budget_bar_chart.dart';
import '../widgets/enhanced_progress_bar.dart';
import '../widgets/interactive_budget_chart.dart';
import 'budget_edit_screen.dart';

/// Enhanced Budget Detail Screen with advanced visualizations
class BudgetDetailScreen extends ConsumerStatefulWidget {
  const BudgetDetailScreen({
    super.key,
    required this.budgetId,
  });

  final String budgetId;

  @override
  ConsumerState<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends ConsumerState<BudgetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetAsync = ref.watch(budgetProvider(widget.budgetId));
    final budgetStatusAsync = ref.watch(budgetStatusProvider(widget.budgetId));
    ref.watch(categoryNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: budgetAsync.when(
        data: (budget) {
          if (budget == null) {
            return const Center(child: Text('Budget not found'));
          }
          return _buildBudgetDetail(context, ref, budget, budgetStatusAsync);
        },
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(budgetProvider(widget.budgetId)),
        ),
      ),
    );
  }

  Widget _buildBudgetDetail(
    BuildContext context,
    WidgetRef ref,
    budget_entity.Budget budget,
    AsyncValue<budget_entity.BudgetStatus?> budgetStatusAsync,
  ) {
    return CustomScrollView(
      slivers: [
        // Animated App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showBudgetOptions(context, ref, budget),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              budget.name,
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                    AppColors.surface,
                  ],
                ),
              ),
              child: budgetStatusAsync.when(
                data: (status) {
                  if (status == null) return const SizedBox.shrink();
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: CircularBudgetIndicator(
                        percentage: status.totalSpent / status.totalBudget,
                        spent: status.totalSpent,
                        total: status.totalBudget,
                        size: 120,
                        strokeWidth: 12,
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(budgetNotifierProvider.notifier).loadBudgets();
            },
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Banner
                  budgetStatusAsync.when(
                    data: (status) {
                      if (status == null) return const SizedBox.shrink();
                      return BudgetStatusBanner(
                        remainingAmount: status.remainingAmount,
                        health: status.overallHealth,
                      ).animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, duration: 400.ms);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Metric Cards
                  budgetStatusAsync.when(
                    data: (status) {
                      if (status == null) return const SizedBox.shrink();
                      return BudgetMetricCards(
                        usageRate: status.totalSpent / status.totalBudget,
                        allotmentRate: _calculateAllotmentRate(status),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Stats Row
                  budgetStatusAsync.when(
                    data: (status) {
                      if (status == null) return const SizedBox.shrink();
                      return BudgetStatsRow(
                        allotted: status.totalBudget,
                        used: status.totalSpent,
                        remaining: status.remainingAmount,
                      ).animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, duration: 400.ms, delay: 200.ms);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Category Breakdown
                  _buildCategoryBreakdown(context, budget, budgetStatusAsync),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Interactive Budget Chart
                  _buildInteractiveChart(budget, budgetStatusAsync),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Budget Information
                  _buildBudgetInfo(context, budget),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Recent Transactions
                  _buildTransactionHistory(context, ref, budget),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    budget_entity.Budget budget,
    AsyncValue<budget_entity.BudgetStatus?> budgetStatusAsync,
  ) {
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    final categoryNotifier = ref.watch(categoryNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsExtended.budgetSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  size: 20,
                  color: AppColorsExtended.budgetSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Category Breakdown',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          budgetStatusAsync.when(
            data: (status) {
              if (status == null || status.categoryStatuses.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No spending data available',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Aggregate duplicate categories by categoryId
              final aggregatedCategories = <String, _AggregatedCategory>{};
              for (final categoryStatus in status.categoryStatuses) {
                final categoryId = categoryStatus.categoryId;
                if (aggregatedCategories.containsKey(categoryId)) {
                  // Add to existing aggregated category
                  final existing = aggregatedCategories[categoryId]!;
                  aggregatedCategories[categoryId] = _AggregatedCategory(
                    categoryId: categoryId,
                    totalSpent: existing.totalSpent + categoryStatus.spent,
                    totalBudget: existing.totalBudget + categoryStatus.budget,
                    status: categoryStatus.status.index > existing.status ? categoryStatus.status.index : existing.status,
                  );
                } else {
                  // Create new aggregated category
                  aggregatedCategories[categoryId] = _AggregatedCategory(
                    categoryId: categoryId,
                    totalSpent: categoryStatus.spent,
                    totalBudget: categoryStatus.budget,
                    status: categoryStatus.status.index,
                  );
                }
              }

              return Column(
                children: aggregatedCategories.values.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final aggregatedCategory = entry.value;
                  final budgetCategory = budget.categories.firstWhere(
                    (cat) => cat.id == aggregatedCategory.categoryId,
                    orElse: () => budget_entity.BudgetCategory(
                      id: aggregatedCategory.categoryId,
                      name: 'Unknown Category',
                      amount: aggregatedCategory.totalBudget,
                    ),
                  );

                  final transactionCategory = categoryNotifier.getCategoryById(aggregatedCategory.categoryId);
                  final displayName = transactionCategory?.name ?? budgetCategory.name;
                  final displayIcon = transactionCategory != null
                      ? categoryIconColorService.getIconForCategory(transactionCategory.id)
                      : Icons.category;
                  final displayColor = transactionCategory != null
                      ? categoryIconColorService.getColorForCategory(transactionCategory.id)
                      : AppColors.primary;

                  return Padding(
                    padding: EdgeInsets.only(bottom: index < aggregatedCategories.length - 1 ? 16 : 0),
                    child: EnhancedProgressBar(
                      categoryName: displayName,
                      icon: displayIcon,
                      color: displayColor,
                      spent: aggregatedCategory.totalSpent,
                      budget: aggregatedCategory.totalBudget,
                      animationDelay: Duration(milliseconds: 100 * index),
                      isInteractive: true,
                      onTap: () => _showCategoryDetails(context, displayName, aggregatedCategory, displayColor),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Failed to load category data: $error'),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 300.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 300.ms);
  }

  Widget _buildInteractiveChart(budget_entity.Budget budget, AsyncValue<budget_entity.BudgetStatus?> budgetStatusAsync) {
    return budgetStatusAsync.when(
      data: (status) {
        if (status == null || status.categoryStatuses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text('No data available for chart'),
            ),
          );
        }

        // Prepare chart data
        final chartData = status.categoryStatuses.map((categoryStatus) {
          final budgetCategory = budget.categories.firstWhere(
            (cat) => cat.id == categoryStatus.categoryId,
            orElse: () => budget_entity.BudgetCategory(
              id: categoryStatus.categoryId,
              name: 'Unknown',
              amount: categoryStatus.budget,
            ),
          );

          final transactionCategory = ref.watch(categoryNotifierProvider.notifier).getCategoryById(categoryStatus.categoryId);
          final displayName = transactionCategory?.name ?? budgetCategory.name;
          final displayColor = transactionCategory != null
              ? ref.watch(categoryIconColorServiceProvider).getColorForCategory(transactionCategory.id)
              : AppColors.primary;

          return BudgetChartCategory(
            name: displayName,
            spentAmount: categoryStatus.spent,
            budgetAmount: categoryStatus.budget,
            color: displayColor,
          );
        }).toList();

        return InteractiveBudgetChart(
          categoryData: chartData,
          totalBudget: status.totalBudget,
          totalSpent: status.totalSpent,
          height: 350,
          showLegend: true,
          isInteractive: true,
        );
      },
      loading: () => Container(
        height: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text('Failed to load chart: $error'),
        ),
      ),
    );
  }

  Widget _buildBudgetInfo(BuildContext context, budget_entity.Budget budget) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsExtended.budgetTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColorsExtended.budgetTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Budget Information',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _InfoRow(
            label: 'Type',
            value: budget.type.displayName,
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Period',
            value: '${DateFormat('MMM dd').format(budget.startDate)} - ${DateFormat('MMM dd, yyyy').format(budget.endDate)}',
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Total Budget',
            value: NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(budget.totalBudget),
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Status',
            value: budget.isActive ? 'Active' : 'Inactive',
            icon: budget.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
            valueColor: budget.isActive ? AppColorsExtended.statusNormal : AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Rollover',
            value: budget.allowRollover ? 'Enabled' : 'Disabled',
            icon: budget.allowRollover ? Icons.autorenew : Icons.block,
            valueColor: budget.allowRollover ? AppColorsExtended.statusNormal : AppColors.textSecondary,
          ),

          if (budget.description != null && budget.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorsExtended.pillBgUnselected,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Description',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    budget.description!,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 500.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildTransactionHistory(BuildContext context, WidgetRef ref, budget_entity.Budget budget) {
    final categoryIds = budget.categories.map((c) => c.id).toSet();
    final transactionStateAsync = ref.watch(transactionNotifierProvider);
    ref.watch(categoryNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: AppColorsExtended.budgetPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all transactions
                },
                child: Text(
                  'View All',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColorsExtended.budgetPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          transactionStateAsync.when(
            data: (state) {
              final transactions = state.transactions.where((transaction) {
                if (!categoryIds.contains(transaction.categoryId)) return false;
                return transaction.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
                    transaction.date.isBefore(budget.endDate.add(const Duration(days: 1))) &&
                    transaction.type == TransactionType.expense;
              }).toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              if (transactions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Lottie Animation for empty transactions
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Lottie.asset(
                          'assets/animations/empty_transactions.json',
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                        ),
                      ).animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 16),

                      Text(
                        'No transactions found',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms),

                      const SizedBox(height: 8),

                      Text(
                        'Transactions for this budget\nwill appear here',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn(duration: 300.ms, delay: 300.ms),
                    ],
                  ),
                );
              }

              final recentTransactions = transactions.take(5).toList();
              final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

              return Column(
                children: recentTransactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  final categoryIcon = categoryIconColorService.getIconForCategory(transaction.categoryId);
                  final categoryColor = categoryIconColorService.getColorForCategory(transaction.categoryId);

                  return Padding(
                    padding: EdgeInsets.only(bottom: index < recentTransactions.length - 1 ? 12 : 0),
                    child: _TransactionItem(
                      transaction: transaction,
                      icon: categoryIcon,
                      color: categoryColor,
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                      .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 100 * index)),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load transactions',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 600.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 600.ms);
  }

  // Helper methods
  double _calculateAllotmentRate(budget_entity.BudgetStatus status) {
    final now = DateTime.now();
    final budget = status.budget;
    final totalDays = budget.endDate.difference(budget.startDate).inDays;
    final daysElapsed = now.difference(budget.startDate).inDays;
    final timeProgress = (daysElapsed / totalDays).clamp(0.0, 1.0);

    final idealSpendingRate = timeProgress;
    final actualSpendingRate = status.totalSpent / status.totalBudget;

    return (actualSpendingRate / (idealSpendingRate == 0 ? 0.01 : idealSpendingRate)).clamp(0.0, 2.0);
  }

  Future<List<BudgetChartData>> _getDailyData(budget_entity.Budget budget, budget_entity.BudgetStatus? status) async {
    final now = DateTime.now();
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Get transaction repository from providers
    final transactionRepository = ref.read(core_providers.transactionRepositoryProvider);

    final dailyData = <BudgetChartData>[];

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayOfWeek = date.weekday % 7;
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Get transactions for this day that belong to budget categories
      final categoryIds = budget.categories.map((c) => c.id).toSet();
      double dailyAmount = 0.0;

      try {
        // Get all transactions for the day
        final transactionsResult = await transactionRepository.getByDateRange(dayStart, dayEnd);
        if (transactionsResult.isSuccess) {
          final dayTransactions = transactionsResult.dataOrNull ?? [];
          // Filter by budget categories and expense type
          final budgetTransactions = dayTransactions.where((transaction) =>
            categoryIds.contains(transaction.categoryId) &&
            transaction.type == TransactionType.expense &&
            transaction.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(budget.endDate.add(const Duration(days: 1)))
          ).toList();

          dailyAmount = budgetTransactions.fold<double>(0.0, (sum, transaction) => sum + transaction.amount);
        }
      } catch (e) {
        // On error, use 0 for the day
        dailyAmount = 0.0;
      }

      dailyData.add(BudgetChartData(
        label: weekDays[dayOfWeek],
        value: dailyAmount,
      ));
    }

    return dailyData;
  }

  Future<List<BudgetChartData>> _getWeeklyData(budget_entity.Budget budget, budget_entity.BudgetStatus? status) async {
    final now = DateTime.now();
    final transactionRepository = ref.read(core_providers.transactionRepositoryProvider);
    final categoryIds = budget.categories.map((c) => c.id).toSet();

    final weeklyData = <BudgetChartData>[];

    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (3 - i) * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weekLabel = 'Week ${i + 1}';

      double weeklyAmount = 0.0;

      try {
        // Get transactions for this week
        final transactionsResult = await transactionRepository.getByDateRange(weekStart, weekEnd);
        if (transactionsResult.isSuccess) {
          final weekTransactions = transactionsResult.dataOrNull ?? [];
          // Filter by budget categories and expense type
          final budgetTransactions = weekTransactions.where((transaction) =>
            categoryIds.contains(transaction.categoryId) &&
            transaction.type == TransactionType.expense &&
            transaction.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(budget.endDate.add(const Duration(days: 1)))
          ).toList();

          weeklyAmount = budgetTransactions.fold<double>(0.0, (sum, transaction) => sum + transaction.amount);
        }
      } catch (e) {
        // On error, use 0 for the week
        weeklyAmount = 0.0;
      }

      weeklyData.add(BudgetChartData(
        label: weekLabel,
        value: weeklyAmount,
      ));
    }

    return weeklyData;
  }

  void _showCategoryDetails(BuildContext context, String categoryName, _AggregatedCategory category, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Category Details',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress visualization
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${((category.totalSpent / category.totalBudget) * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (category.totalSpent / category.totalBudget).clamp(0.0, 1.0),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Spent',
                    '\$${category.totalSpent.toStringAsFixed(2)}',
                    Icons.trending_up,
                    color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Budget',
                    '\$${category.totalBudget.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Remaining',
                    '\$${(category.totalBudget - category.totalSpent).toStringAsFixed(2)}',
                    Icons.trending_down,
                    (category.totalBudget - category.totalSpent) >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Status',
                    _getStatusText(category.status),
                    _getStatusIcon(category.status),
                    _getStatusColor(category.status),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0: return 'Healthy';
      case 1: return 'Warning';
      case 2: return 'Critical';
      case 3: return 'Over Budget';
      default: return 'Unknown';
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0: return Icons.check_circle;
      case 1: return Icons.warning;
      case 2: return Icons.error;
      case 3: return Icons.cancel;
      default: return Icons.help;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: return Colors.green;
      case 1: return Colors.orange;
      case 2: return Colors.red;
      case 3: return Colors.red.shade800;
      default: return Colors.grey;
    }
  }

  void _showBudgetOptions(BuildContext context, WidgetRef ref, budget_entity.Budget budget) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
              ),
              title: const Text('Edit Budget'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BudgetEditScreen(budget: budget),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              ),
              title: const Text('Delete Budget'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, budget);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    budget_entity.Budget budget,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete "${budget.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(budgetNotifierProvider.notifier)
          .deleteBudget(budget.id);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget deleted successfully')),
        );
      }
    }
  }
}

/// Category Progress Item
class _CategoryProgressItem extends StatelessWidget {
  const _CategoryProgressItem({
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.spent,
    required this.budget,
    required this.status,
  });

  final String categoryName;
  final IconData icon;
  final Color color;
  final double spent;
  final double budget;
  final budget_entity.BudgetHealth status;

  Color _getHealthColor(budget_entity.BudgetHealth health) {
    switch (health) {
      case budget_entity.BudgetHealth.healthy:
        return app_colors_extended.AppColorsExtended.statusNormal;
      case budget_entity.BudgetHealth.warning:
        return app_colors_extended.AppColorsExtended.statusWarning;
      case budget_entity.BudgetHealth.critical:
        return app_colors_extended.AppColorsExtended.statusCritical;
      case budget_entity.BudgetHealth.overBudget:
        return app_colors_extended.AppColorsExtended.statusOverBudget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (spent / budget).clamp(0.0, 1.0);
    final healthColor = _getHealthColor(status);
    final isOverBudget = status == budget_entity.BudgetHealth.overBudget;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
        border: isOverBudget ? Border.all(
          color: healthColor.withValues(alpha: 0.3),
          width: 2,
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(progress * 100).toInt()}% used',
                      style: AppTypography.caption.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(spent),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: healthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        healthColor,
                        healthColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: healthColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(budget)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (isOverBudget)
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: healthColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${(spent - budget).toStringAsFixed(0)} over',
                      style: AppTypography.caption.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  '\$${(budget - spent).toStringAsFixed(0)} left',
                  style: AppTypography.caption.copyWith(
                    color: AppColorsExtended.statusNormal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Info Row Widget
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Helper class for aggregating category data
class _AggregatedCategory {
  const _AggregatedCategory({
    required this.categoryId,
    required this.totalSpent,
    required this.totalBudget,
    required this.status,
  });

  final String categoryId;
  final double totalSpent;
  final double totalBudget;
  final int status;
}

/// Determine budget health based on spending percentage
BudgetHealth _getBudgetHealth(double percentage) {
  if (percentage > 100) return BudgetHealth.overBudget;
  if (percentage > 90) return BudgetHealth.critical;
  if (percentage > 75) return BudgetHealth.warning;
  return BudgetHealth.healthy;
}

/// Transaction Item Widget
class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.transaction,
    required this.icon,
    required this.color,
  });

  final Transaction transaction;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Transaction',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, yyyy').format(transaction.date),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(transaction.amount),
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}