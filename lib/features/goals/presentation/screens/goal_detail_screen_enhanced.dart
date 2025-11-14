import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';
import '../../../budgets/presentation/widgets/budget_status_banner.dart';
import '../../../budgets/domain/entities/budget.dart' as budget_entity;
import '../../../budgets/presentation/widgets/budget_metric_cards.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart';
import '../../../budgets/presentation/widgets/budget_bar_chart.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import '../theme/goals_theme_extended.dart';
import '../widgets/add_contribution_bottom_sheet.dart';
import '../widgets/edit_goal_bottom_sheet.dart';
import '../widgets/enhanced_goal_timeline.dart';
import '../widgets/enhanced_contribution_card.dart';

/// Enhanced Goal Detail Screen with advanced visualizations
class GoalDetailScreenEnhanced extends ConsumerStatefulWidget {
  const GoalDetailScreenEnhanced({
    super.key,
    required this.goalId,
  });

  final String goalId;

  @override
  ConsumerState<GoalDetailScreenEnhanced> createState() => _GoalDetailScreenEnhancedState();
}

class _GoalDetailScreenEnhancedState extends ConsumerState<GoalDetailScreenEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedContributionDate;

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
    final goalStateAsync = ref.watch(goalNotifierProvider);
    final contributionsAsync = ref.watch(goalContributionsProvider(widget.goalId));

    final goalAsync = goalStateAsync.when(
      data: (state) {
        final matchingGoals = state.goals.where((g) => g.id == widget.goalId);
        final Goal? goal = matchingGoals.isNotEmpty ? matchingGoals.first : null;
        return AsyncValue<Goal?>.data(goal);
      },
      loading: () => const AsyncValue<Goal?>.loading(),
      error: (error, stack) => AsyncValue<Goal?>.error(error, stack),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: goalAsync.when(
        data: (goal) {
          if (goal == null) {
            return const Center(child: Text('Goal not found'));
          }
          return _buildGoalDetail(context, goal, contributionsAsync);
        },
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(goalProvider(widget.goalId)),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildGoalDetail(
    BuildContext context,
    Goal goal,
    AsyncValue<List<dynamic>> contributionsAsync,
  ) {
    return CustomScrollView(
      slivers: [
        // Enhanced App Bar with Hero
        _buildEnhancedAppBar(goal),

        // Content
        SliverToBoxAdapter(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(goalNotifierProvider.notifier).loadGoals();
            },
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Banner
                  _buildGoalStatusBanner(goal).animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, duration: 400.ms),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Metric Cards
                  _buildGoalMetricCards(goal),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Stats Row
                  _buildGoalStatsRow(goal).animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Enhanced Timeline
                  EnhancedGoalTimeline(goal: goal),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Contribution Trends Chart
                  _buildContributionTrendsChart(goal, contributionsAsync),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Goal Information
                  _buildGoalInformation(goal),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Contribution History
                  _buildContributionHistory(contributionsAsync),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedAppBar(Goal goal) {
    final healthColor = _getGoalHealthColor(goal);

    return SliverAppBar(
      expandedHeight: 260,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            HapticFeedback.lightImpact();
            _showGoalOptions(context, goal);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          goal.title,
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
                healthColor.withValues(alpha: 0.1),
                AppColors.surface,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Hero(
                tag: 'goal_${goal.id}',
                child: CircularBudgetIndicator(
                  percentage: goal.progressPercentage,
                  spent: goal.currentAmount,
                  total: goal.targetAmount,
                  size: 140,
                  strokeWidth: 16,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalStatusBanner(Goal goal) {
    String statusMessage;
    budget_entity.BudgetHealth health;

    if (goal.isCompleted) {
      statusMessage = 'Goal completed! You reached your target of ${goal.formattedTargetAmount}';
      health = budget_entity.BudgetHealth.healthy;
    } else if (goal.isOverdue) {
      statusMessage = 'Goal is ${goal.daysRemaining.abs()} days overdue. You need ${goal.formattedRemainingAmount} more';
      health = budget_entity.BudgetHealth.overBudget;
    } else if (goal.progressPercentage >= 0.75) {
      statusMessage = 'Almost there! Just ${goal.formattedRemainingAmount} to go';
      health = budget_entity.BudgetHealth.warning;
    } else if (goal.progressPercentage >= 0.5) {
      statusMessage = 'Great progress! Keep contributing to reach your goal';
      health = budget_entity.BudgetHealth.warning;
    } else {
      statusMessage = 'Keep going! You need about ${goal.formattedRemainingAmount} to reach your goal';
      health = budget_entity.BudgetHealth.healthy;
    }

    return BudgetStatusBanner(
      remainingAmount: goal.remainingAmount,
      health: health,
      showDot: true,
    );
  }

  Widget _buildGoalMetricCards(Goal goal) {
    // Calculate velocity (how fast the goal is being achieved)
    final totalDays = goal.deadline.difference(goal.createdAt).inDays;
    final elapsedDays = DateTime.now().difference(goal.createdAt).inDays;
    final timeProgress = elapsedDays / totalDays;
    final progressRatio = goal.progressPercentage / (timeProgress == 0 ? 0.01 : timeProgress);
    final velocity = progressRatio.clamp(0.0, 2.0);

    // Calculate pace (current vs required)
    final requiredDailyContribution = goal.remainingAmount / (goal.daysRemaining > 0 ? goal.daysRemaining : 1);
    final actualDailyContribution = goal.currentAmount / (elapsedDays > 0 ? elapsedDays : 1);
    final pace = actualDailyContribution / (requiredDailyContribution == 0 ? 0.01 : requiredDailyContribution);

    return Row(
      children: [
        Expanded(
          child: _GoalMetricCard(
            title: 'Progress Rate',
            percentage: velocity,
            icon: Icons.trending_up,
            isIncreasing: velocity > 1.0,
            subtitle: velocity > 1.0 ? 'Ahead of schedule' : 'Behind schedule',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GoalMetricCard(
            title: 'Daily Pace',
            percentage: pace.clamp(0.0, 2.0),
            icon: Icons.speed,
            isIncreasing: pace > 1.0,
            subtitle: '\$${actualDailyContribution.toStringAsFixed(2)}/day',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms),
        ),
      ],
    );
  }

  Widget _buildGoalStatsRow(Goal goal) {
    return BudgetStatsRow(
      allotted: goal.targetAmount,
      used: goal.currentAmount,
      remaining: goal.remainingAmount,
    );
  }

  Widget _buildContributionTrendsChart(
    Goal goal,
    AsyncValue<List<dynamic>> contributionsAsync,
  ) {
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
              labelColor: GoalsThemeExtended.goalPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: GoalsThemeExtended.goalPrimary,
                  width: 3,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 40),
              ),
              tabs: const [
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: contributionsAsync.when(
                    data: (contributions) => BudgetBarChart(
                      data: _getWeeklyContributionData(contributions),
                      title: 'Weekly Contributions',
                      period: 'Last 7 Days',
                      height: 200,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Failed to load chart')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: contributionsAsync.when(
                    data: (contributions) => BudgetBarChart(
                      data: _getMonthlyContributionData(contributions),
                      title: 'Monthly Contributions',
                      period: 'Last 6 Months',
                      height: 200,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Failed to load chart')),
                  ),
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

  Widget _buildGoalInformation(Goal goal) {
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    final categoryColor = categoryIconColorService.getColorForCategory(goal.categoryId);
    final categoryNotifier = ref.watch(categoryNotifierProvider.notifier);
    final category = categoryNotifier.getCategoryById(goal.categoryId);
    final categoryName = category?.name ?? goal.categoryId.replaceAll('_', ' ').toUpperCase();

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
                  color: GoalsThemeExtended.goalTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: GoalsThemeExtended.goalTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Goal Information',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _InfoRow(
            label: 'Category',
            value: categoryName,
            icon: Icons.category_outlined,
            valueColor: categoryColor,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Priority',
            value: goal.priority.displayName,
            icon: Icons.flag_outlined,
            valueColor: _getPriorityColor(goal.priority),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Target Amount',
            value: goal.formattedTargetAmount,
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Monthly Required',
            value: '\$${goal.requiredMonthlyContribution.toStringAsFixed(2)}',
            icon: Icons.calendar_month,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Status',
            value: goal.isCompleted ? 'Completed' : goal.isOverdue ? 'Overdue' : 'In Progress',
            icon: goal.isCompleted ? Icons.check_circle_outline : Icons.pending_outlined,
            valueColor: goal.isCompleted
                ? GoalsThemeExtended.goalSuccess
                : goal.isOverdue
                    ? GoalsThemeExtended.goalWarning
                    : GoalsThemeExtended.goalPrimary,
          ),

          if (goal.description.isNotEmpty) ...[
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
                    goal.description,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ],

          if (goal.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tags',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: goal.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppTypography.caption.copyWith(
                      color: GoalsThemeExtended.goalPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 600.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 600.ms);
  }

  Widget _buildContributionHistory(AsyncValue<List<dynamic>> contributionsAsync) {
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
                  color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.history,
                  size: 20,
                  color: GoalsThemeExtended.goalPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Contribution History',
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full contribution list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View all contributions - Coming soon!')),
                  );
                },
                child: Text(
                  'View All',
                  style: AppTypography.bodyMedium.copyWith(
                    color: GoalsThemeExtended.goalPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          contributionsAsync.when(
            data: (contributions) {
              if (contributions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timeline_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No contributions yet',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start contributing to reach your goal',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final recentContributions = contributions.take(10).toList();
              return Column(
                children: recentContributions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final contribution = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < recentContributions.length - 1 ? 12 : 0,
                    ),
                    child: EnhancedContributionCard(
                      contribution: contribution,
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
                    'Failed to load contributions',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 700.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 700.ms);
  }

  Widget _buildFAB() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GoalsThemeExtended.goalPrimary,
            GoalsThemeExtended.goalPrimary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showAddContributionSheet(context);
          },
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Add Contribution',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
  }

  // Helper methods
  Color _getGoalHealthColor(Goal goal) {
    if (goal.isCompleted) return GoalsThemeExtended.goalSuccess;
    if (goal.isOverdue) return GoalsThemeExtended.goalWarning;
    final progress = goal.progressPercentage;
    if (progress >= 0.75) return GoalsThemeExtended.goalPrimary;
    if (progress >= 0.5) return GoalsThemeExtended.goalSecondary;
    return GoalsThemeExtended.goalWarning;
  }


  Color _getPriorityColor(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.high:
        return GoalsThemeExtended.priorityHigh;
      case GoalPriority.medium:
        return GoalsThemeExtended.priorityMedium;
      case GoalPriority.low:
        return GoalsThemeExtended.priorityLow;
    }
  }

  List<BudgetChartData> _getWeeklyContributionData(List<dynamic> contributions) {
    final now = DateTime.now();
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dailyData = <String, double>{};

    // Initialize all days
    for (var i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayKey = DateFormat('yyyy-MM-dd').format(date);
      dailyData[dayKey] = 0.0;
    }

    // Aggregate contributions
    for (final contribution in contributions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(contribution.date);
      if (dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = dailyData[dateKey]! + contribution.amount.abs();
      }
    }

    return dailyData.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final mapEntry = entry.value;
      final date = now.subtract(Duration(days: 6 - index));
      return BudgetChartData(
        label: weekDays[date.weekday % 7],
        value: mapEntry.value,
        color: GoalsThemeExtended.goalPrimary,
      );
    }).toList();
  }

  List<BudgetChartData> _getMonthlyContributionData(List<dynamic> contributions) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final monthlyData = <String, double>{};

    // Initialize last 6 months
    for (var i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('yyyy-MM').format(date);
      monthlyData[monthKey] = 0.0;
    }

    // Aggregate contributions
    for (final contribution in contributions) {
      final monthKey = DateFormat('yyyy-MM').format(contribution.date);
      if (monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = monthlyData[monthKey]! + contribution.amount.abs();
      }
    }

    return monthlyData.entries.map((entry) {
      final date = DateTime.parse('${entry.key}-01');
      final monthIndex = date.month - 1;
      return BudgetChartData(
        label: DateFormat('MMM').format(date),
        value: entry.value,
        color: GoalsThemeExtended.goalSecondary,
      );
    }).toList();
  }

  Future<void> _showAddContributionSheet(BuildContext context) async {
    await AppBottomSheet.show(
      context: context,
      child: AddContributionBottomSheet(
        goalId: widget.goalId,
        onSubmit: (contribution) async {
          final success = await ref
              .read(goalNotifierProvider.notifier)
              .addContribution(widget.goalId, contribution);

          if (success && mounted) {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Contribution added successfully'),
                backgroundColor: GoalsThemeExtended.goalSuccess,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showGoalOptions(BuildContext context, Goal goal) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _OptionTile(
              icon: Icons.edit,
              title: 'Edit Goal',
              color: GoalsThemeExtended.goalPrimary,
              onTap: () {
                Navigator.pop(context);
                _showEditGoalSheet(context, goal);
              },
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.share,
              title: 'Share Progress',
              color: GoalsThemeExtended.goalSecondary,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share functionality - Coming soon!')),
                );
              },
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.archive,
              title: 'Archive Goal',
              color: AppColors.textSecondary,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Archive functionality - Coming soon!')),
                );
              },
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.delete,
              title: 'Delete Goal',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, goal);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditGoalSheet(BuildContext context, Goal goal) async {
    await AppBottomSheet.show(
      context: context,
      child: EditGoalBottomSheet(
        goal: goal,
        onSubmit: (updatedGoal) async {
          final success = await ref
              .read(goalNotifierProvider.notifier)
              .updateGoal(updatedGoal);

          if (success && mounted) {
            HapticFeedback.mediumImpact();
            ref.invalidate(goalProvider(widget.goalId));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Goal updated successfully'),
                backgroundColor: GoalsThemeExtended.goalSuccess,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update goal'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Goal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Goal'),
        content: Text(
          'Are you sure you want to delete "${goal.title}"? This action cannot be undone.',
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

    if (confirmed == true) {
      final success = await ref
          .read(goalNotifierProvider.notifier)
          .deleteGoal(goal.id);

      if (success && mounted) {
        HapticFeedback.mediumImpact();
        context.go('/goals');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Goal Metric Card Widget
class _GoalMetricCard extends StatefulWidget {
  const _GoalMetricCard({
    required this.title,
    required this.percentage,
    required this.icon,
    required this.isIncreasing,
    required this.subtitle,
  });

  final String title;
  final double percentage;
  final IconData icon;
  final bool isIncreasing;
  final String subtitle;

  @override
  State<_GoalMetricCard> createState() => _GoalMetricCardState();
}

class _GoalMetricCardState extends State<_GoalMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.percentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(_GoalMetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: oldWidget.percentage,
        end: widget.percentage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isIncreasing
        ? GoalsThemeExtended.goalSuccess
        : GoalsThemeExtended.goalWarning;

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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '${(_animation.value * 100).toInt()}%',
                style: AppTypographyExtended.metricPercentage.copyWith(
                  color: color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          Text(
            widget.title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            widget.subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
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

/// Option Tile Widget
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}