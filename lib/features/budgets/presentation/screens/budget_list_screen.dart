import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/budget.dart' as budget_entities;
import '../providers/budget_providers.dart';
import '../states/budget_state.dart';
import '../widgets/circular_budget_indicator.dart';
import '../widgets/date_selector_pills.dart';
import '../widgets/budget_status_banner.dart';
import '../widgets/budget_metric_cards.dart';
import '../widgets/budget_stats_row.dart';
import '../widgets/budget_bar_chart.dart';
import '../widgets/enhanced_budget_card.dart';
import 'budget_creation_screen.dart';
import 'budget_detail_screen.dart';

/// Data class for aggregated budget information
class AggregatedBudgetData {
  const AggregatedBudgetData({
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingAmount,
    required this.overallHealth,
    required this.startDate,
    required this.endDate,
  });

  factory AggregatedBudgetData.empty() {
    return AggregatedBudgetData(
      totalBudget: 0.0,
      totalSpent: 0.0,
      remainingAmount: 0.0,
      overallHealth: budget_entities.BudgetHealth.healthy,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
    );
  }

  final double totalBudget;
  final double totalSpent;
  final double remainingAmount;
  final budget_entities.BudgetHealth overallHealth;
  final DateTime startDate;
  final DateTime endDate;
}

/// Enhanced Budget List Screen with advanced visualizations and modular components
class BudgetListScreen extends ConsumerStatefulWidget {
  const BudgetListScreen({super.key});

  @override
  ConsumerState<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends ConsumerState<BudgetListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late DateTime _selectedDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetNotifierProvider);
    final statsState = ref.watch(budgetStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'My Budget',
          style: AppTypography.h1.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => _showManageBudgetsSheet(context),
              style: TextButton.styleFrom(
                backgroundColor: AppColorsExtended.pillBgUnselected,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                minimumSize: const Size(48, 48), // Ensure minimum touch target
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Manage',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: budgetState.when(
        data: (state) => _buildBody(state, statsState),
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(budgetNotifierProvider),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildBody(BudgetState state, AsyncValue<BudgetStats> statsState) {
    if (state.budgets.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate aggregated data for all active budgets
    final aggregatedData = _calculateAggregatedBudgetData(state);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(budgetNotifierProvider.notifier).loadBudgets();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Progress Indicator
            Center(
              child: CircularBudgetIndicator(
                percentage: aggregatedData.totalSpent / aggregatedData.totalBudget,
                spent: aggregatedData.totalSpent,
                total: aggregatedData.totalBudget,
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),
            ),
            SizedBox(height: AppDimensions.sectionGap),

            // Date Selector
            DateSelectorPills(
              startDate: aggregatedData.startDate,
              endDate: aggregatedData.endDate,
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ).animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, duration: 400.ms, delay: 200.ms),

            SizedBox(height: AppDimensions.sectionGap),

            // Status Banner
            BudgetStatusBanner(
              remainingAmount: aggregatedData.remainingAmount,
              health: aggregatedData.overallHealth,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideX(begin: -0.1, duration: 400.ms, delay: 300.ms),

            SizedBox(height: AppDimensions.sectionGap),

            // Metric Cards
            BudgetMetricCards(
              usageRate: aggregatedData.totalSpent / aggregatedData.totalBudget,
              allotmentRate: _calculateAllotmentRateForAggregated(aggregatedData),
            ),

            SizedBox(height: AppDimensions.sectionGap),

            // Stats Row
            Consumer(
              builder: (context, ref, child) {
                final statsAsync = ref.watch(budgetStatsProvider);
                final totalActiveCosts = statsAsync.maybeWhen(
                  data: (stats) => stats.totalActiveCosts,
                  orElse: () => 0.0,
                );

                return BudgetStatsRow(
                  allotted: aggregatedData.totalBudget,
                  used: aggregatedData.totalSpent,
                  remaining: aggregatedData.remainingAmount,
                  totalActiveCosts: totalActiveCosts,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms);
              },
            ),

            SizedBox(height: AppDimensions.sectionGap),

            // Chart Tabs
            _buildChartSection(state, aggregatedData),

            SizedBox(height: AppDimensions.sectionGap),

            // Budget List Section
            _buildBudgetListSection(state),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BudgetState state, AggregatedBudgetData aggregatedData) {
    return Container(
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
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderSubtle,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 3,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 40),
              ),
              tabs: const [
                Tab(text: 'Last Week'),
                Tab(text: 'Past Year'),
              ],
            ),
          ),

          // Tab Views
          SizedBox(
            height: 340,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Weekly Chart
                BudgetBarChart(
                    data: _getWeeklyData(state, aggregatedData),
                    title: 'Last Week',
                    period: '\$${_getTotalWeekly(state, aggregatedData).toStringAsFixed(2)}',
                    height: 200,
                  ),
                

                // Yearly Chart
                BudgetBarChart(
                    data: _getYearlyData(state, aggregatedData),
                    title: 'Past Year',
                    period: '2025',
                    height: 200,
                  ),
                
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 500.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildBudgetListSection(BudgetState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Budgets',
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.budgets.length}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColorsExtended.budgetPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 600.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 600.ms),

        const SizedBox(height: 16),

        ...state.budgets.asMap().entries.map((entry) {
          final index = entry.key;
          final budget = entry.value;
          final status = state.budgetStatuses
              .where((s) => s.budget.id == budget.id)
              .firstOrNull;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EnhancedBudgetCard(
              budget: budget,
              status: status,
              onTap: () => _navigateToBudgetDetail(budget),
            ).animate()
              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 100)))
              .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 100))),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation
          SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/animations/empty_budget.json',
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ).animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),

          SizedBox(height: AppDimensions.spacing4),

          Text(
            'No budgets yet',
            style: AppTypography.h1.copyWith(
              fontSize: 24,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),

          SizedBox(height: AppDimensions.spacing2),

          Text(
            'Create your first budget to start\ntracking your spending',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 400.ms),

          SizedBox(height: AppDimensions.spacing5),

          ElevatedButton.icon(
            onPressed: () => _navigateToBudgetCreation(),
            icon: const Icon(Icons.add),
            label: const Text('Create Budget'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsExtended.budgetPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 500.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 500.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(budgetNotifierProvider).value?.isLoading ?? false;
        return Container(
          height: 56.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColorsExtended.budgetPrimary,
                AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : () {
                HapticFeedback.mediumImpact();
                _navigateToBudgetCreation();
              },
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      isLoading ? 'Creating...' : 'New Budget',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate()
          .fadeIn(duration: 300.ms, delay: 800.ms)
          .slideY(begin: 0.1, duration: 300.ms, delay: 800.ms, curve: Curves.elasticOut);
      },
    );
  }

  // Helper methods
  AggregatedBudgetData _calculateAggregatedBudgetData(BudgetState state) {
    final activeBudgets = state.activeBudgets;
    if (activeBudgets.isEmpty) {
      return AggregatedBudgetData.empty();
    }

    // Aggregate data from all active budgets
    double totalBudget = 0.0;
    double totalSpent = 0.0;
    DateTime? earliestStart;
    DateTime? latestEnd;
    budget_entities.BudgetHealth overallHealth = budget_entities.BudgetHealth.healthy;

    for (final budget in activeBudgets) {
      final status = state.budgetStatuses.where((s) => s.budget.id == budget.id).firstOrNull;
      if (status != null) {
        totalBudget += status.totalBudget;
        totalSpent += status.totalSpent;

        // Update date range
        if (earliestStart == null || budget.startDate.isBefore(earliestStart)) {
          earliestStart = budget.startDate;
        }
        if (latestEnd == null || budget.endDate.isAfter(latestEnd)) {
          latestEnd = budget.endDate;
        }

        // Determine overall health (worst health wins)
        if (status.overallHealth.index > overallHealth.index) {
          overallHealth = status.overallHealth;
        }
      }
    }

    return AggregatedBudgetData(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      remainingAmount: totalBudget - totalSpent,
      overallHealth: overallHealth,
      startDate: earliestStart ?? DateTime.now(),
      endDate: latestEnd ?? DateTime.now().add(const Duration(days: 30)),
    );
  }

  double _calculateAllotmentRateForAggregated(AggregatedBudgetData data) {
    // Calculate how much of the budget period has passed
    final now = DateTime.now();
    final totalDays = data.endDate.difference(data.startDate).inDays;
    final daysElapsed = now.difference(data.startDate).inDays;
    final timeProgress = (daysElapsed / totalDays).clamp(0.0, 1.0);

    // Ideal spending rate based on time
    final idealSpendingRate = timeProgress;
    final actualSpendingRate = data.totalSpent / data.totalBudget;

    // Allotment rate is how well spending aligns with time
    return (actualSpendingRate / idealSpendingRate).clamp(0.0, 2.0);
  }


  List<BudgetChartData> _getWeeklyData(BudgetState state, AggregatedBudgetData aggregatedData) {
    final now = DateTime.now();
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Generate mock data for demo - replace with actual spending data
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayOfWeek = date.weekday % 7;

      // Mock values - replace with actual transaction data
      final baseAmount = aggregatedData.totalSpent / 7;
      final variance = (index * 0.3) - 0.9; // Create variation
      final amount = baseAmount * (1 + variance);

      return BudgetChartData(
        label: weekDays[dayOfWeek],
        value: amount.clamp(0, double.infinity),
      );
    });
  }

  List<BudgetChartData> _getYearlyData(BudgetState state, AggregatedBudgetData aggregatedData) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Generate mock data for past 6 months - replace with actual data
    return List.generate(6, (index) {
      final monthIndex = (now.month - 6 + index) % 12;

      // Mock values - replace with actual transaction data
      final baseAmount = aggregatedData.totalBudget * 0.8;
      final variance = (index * 0.2) - 0.5;
      final amount = baseAmount * (1 + variance);

      return BudgetChartData(
        label: months[monthIndex],
        value: amount.clamp(0, double.infinity),
      );
    });
  }

  double _getTotalWeekly(BudgetState state, AggregatedBudgetData aggregatedData) {
    return _getWeeklyData(state, aggregatedData)
        .fold(0.0, (sum, item) => sum + item.value);
  }

  void _navigateToBudgetDetail(budget_entities.Budget budget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetDetailScreen(budgetId: budget.id),
      ),
    );
  }

  void _navigateToBudgetCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BudgetCreationScreen(),
      ),
    );
  }

  void _showManageBudgetsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ManageBudgetsSheet(),
    );
  }
}

/// Manage Budgets Bottom Sheet
class _ManageBudgetsSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Manage Budgets',
            style: AppTypography.h2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // Options
          _ManageOption(
            icon: Icons.filter_list,
            title: 'Filter Budgets',
            subtitle: 'Filter by type, status, or date',
            onTap: () {
              Navigator.pop(context);
              // Show filter sheet
            },
          ),
          const SizedBox(height: 8),
          _ManageOption(
            icon: Icons.edit,
            title: 'Edit Categories',
            subtitle: 'Manage budget categories',
            onTap: () {
              Navigator.pop(context);
              // Navigate to category management
            },
          ),
          const SizedBox(height: 8),
          _ManageOption(
            icon: Icons.archive,
            title: 'Archived Budgets',
            subtitle: 'View past budgets',
            onTap: () {
              Navigator.pop(context);
              // Navigate to archived budgets
            },
          ),
          const SizedBox(height: 8),
          _ManageOption(
            icon: Icons.settings,
            title: 'Budget Settings',
            subtitle: 'Configure budget preferences',
            onTap: () {
              Navigator.pop(context);
              // Navigate to budget settings
            },
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _ManageOption extends StatelessWidget {
  const _ManageOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: AppColorsExtended.budgetPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}