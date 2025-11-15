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
import '../../../budgets/presentation/widgets/budget_status_banner.dart';
import '../../../budgets/domain/entities/budget.dart' as budget_entity;
import '../../../budgets/presentation/widgets/budget_stats_row.dart';
import '../../../budgets/presentation/widgets/budget_bar_chart.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import '../theme/goals_theme_extended.dart';
import '../widgets/add_contribution_bottom_sheet.dart';
import '../widgets/edit_goal_bottom_sheet.dart';
import '../widgets/enhanced_goal_progress_card.dart';
import '../widgets/enhanced_goal_timeline_card.dart';
import '../widgets/enhanced_goal_information_card.dart';
import '../widgets/enhanced_contribution_history.dart';
import '../widgets/enhanced_goal_app_bar.dart';

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
    debugPrint('🔍 GoalDetailScreenEnhanced: Building screen for goalId: ${widget.goalId}');

    final goalStateAsync = ref.watch(goalNotifierProvider);
    final contributionsAsync = ref.watch(goalContributionsProvider(widget.goalId));

    debugPrint('🔍 GoalDetailScreenEnhanced: goalStateAsync: ${goalStateAsync.runtimeType}');
    debugPrint('🔍 GoalDetailScreenEnhanced: contributionsAsync: ${contributionsAsync.runtimeType}');

    final goalAsync = goalStateAsync.when(
      data: (state) {
        debugPrint('🔍 GoalDetailScreenEnhanced: goalState data received, goals count: ${state.goals.length}');
        final matchingGoals = state.goals.where((g) => g.id == widget.goalId);
        final Goal? goal = matchingGoals.isNotEmpty ? matchingGoals.first : null;
        debugPrint('🔍 GoalDetailScreenEnhanced: Found goal: ${goal?.title ?? 'null'}');
        return AsyncValue<Goal?>.data(goal);
      },
      loading: () {
        debugPrint('🔍 GoalDetailScreenEnhanced: goalState loading');
        return const AsyncValue<Goal?>.loading();
      },
      error: (error, stack) {
        debugPrint('🔍 GoalDetailScreenEnhanced: goalState error: $error');
        return AsyncValue<Goal?>.error(error, stack);
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: goalAsync.when(
        data: (goal) {
          if (goal == null) {
            debugPrint('🔍 GoalDetailScreenEnhanced: Goal not found');
            return const Center(child: Text('Goal not found'));
          }
          debugPrint('🔍 GoalDetailScreenEnhanced: Building goal detail for: ${goal.title}');
          return _buildGoalDetail(context, goal, contributionsAsync);
        },
        loading: () {
          debugPrint('🔍 GoalDetailScreenEnhanced: Showing loading view');
          return const LoadingView();
        },
        error: (error, stack) {
          debugPrint('🔍 GoalDetailScreenEnhanced: Showing error view: $error');
          return ErrorView(
            message: error.toString(),
            onRetry: () => ref.refresh(goalProvider(widget.goalId)),
          );
        },
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
        EnhancedGoalAppBar(
          goal: goal,
          onBackPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          onMorePressed: () {
            HapticFeedback.lightImpact();
            _showGoalOptions(context, goal);
          },
        ),

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
                  BudgetStatusBanner(
                    remainingAmount: goal.remainingAmount,
                    health: goal.isCompleted
                        ? budget_entity.BudgetHealth.healthy
                        : goal.isOverdue
                            ? budget_entity.BudgetHealth.overBudget
                            : goal.progressPercentage >= 0.75
                                ? budget_entity.BudgetHealth.warning
                                : budget_entity.BudgetHealth.healthy,
                    showDot: true,
                  ).animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, duration: 400.ms),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Enhanced Goal Progress Card
                  EnhancedGoalProgressCard(goal: goal),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Stats Row
                  BudgetStatsRow(
                    allotted: goal.targetAmount,
                    used: goal.currentAmount,
                    remaining: goal.remainingAmount,
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Enhanced Goal Timeline Card
                  EnhancedGoalTimelineCard(goal: goal),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Contribution Trends Chart
                  _buildContributionTrendsChart(goal, contributionsAsync),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Enhanced Goal Information Card
                  EnhancedGoalInformationCard(goal: goal),

                  SizedBox(height: AppDimensions.sectionGap),

                  // Enhanced Contribution History
                  EnhancedContributionHistory(
                    contributionsAsync: contributionsAsync,
                    onViewAll: () {
                      // Navigate to full contribution list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View all contributions - Coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildContributionTrendsChart(
    Goal goal,
    AsyncValue<List<dynamic>> contributionsAsync,
  ) {
    debugPrint('🔍 GoalDetailScreenEnhanced: Building contribution trends chart');

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
                    data: (contributions) {
                      debugPrint('🔍 GoalDetailScreenEnhanced: Weekly contributions data: ${contributions.length} items');
                      final data = _getWeeklyContributionData(contributions);
                      debugPrint('🔍 GoalDetailScreenEnhanced: Weekly chart data: ${data.length} points');
                      return BudgetBarChart(
                        data: data,
                        title: 'Weekly Contributions',
                        period: 'Last 7 Days',
                        height: 200,
                      );
                    },
                    loading: () {
                      debugPrint('🔍 GoalDetailScreenEnhanced: Weekly contributions loading');
                      return const Center(child: CircularProgressIndicator());
                    },
                    error: (error, stack) {
                      debugPrint('🔍 GoalDetailScreenEnhanced: Weekly contributions error: $error');
                      return const Center(child: Text('Failed to load chart'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: contributionsAsync.when(
                    data: (contributions) {
                      debugPrint('🔍 GoalDetailScreenEnhanced: Monthly contributions data: ${contributions.length} items');
                      final data = _getMonthlyContributionData(contributions);
                      debugPrint('🔍 GoalDetailScreenEnhanced: Monthly chart data: ${data.length} points');
                      return BudgetBarChart(
                        data: data,
                        title: 'Monthly Contributions',
                        period: 'Last 6 Months',
                        height: 200,
                      );
                    },
                    loading: () {
                      debugPrint('🔍 GoalDetailScreenEnhanced: Monthly contributions loading');
                      return const Center(child: CircularProgressIndicator());
                    },
                    error: (error, stack) {
                      debugPrint('🔍 GoalDetailScreenEnhanced: Monthly contributions error: $error');
                      return const Center(child: Text('Failed to load chart'));
                    },
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



  Future<void> _showAddContributionSheet(BuildContext context) async {
    debugPrint('🔍 GoalDetailScreenEnhanced: Showing add contribution sheet');

    await AppBottomSheet.show(
      context: context,
      child: AddContributionBottomSheet(
        goalId: widget.goalId,
        onSubmit: (contribution) async {
          debugPrint('🔍 GoalDetailScreenEnhanced: Submitting contribution: ${contribution.amount}');
          final success = await ref
              .read(goalNotifierProvider.notifier)
              .addContribution(widget.goalId, contribution);

          debugPrint('🔍 GoalDetailScreenEnhanced: Contribution submission result: $success');

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
          } else if (mounted) {
            debugPrint('🔍 GoalDetailScreenEnhanced: Contribution submission failed');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to add contribution'),
                backgroundColor: Colors.red,
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
    debugPrint('🔍 GoalDetailScreenEnhanced: Showing edit goal sheet for: ${goal.title}');

    await AppBottomSheet.show(
      context: context,
      child: EditGoalBottomSheet(
        goal: goal,
        onSubmit: (updatedGoal) async {
          debugPrint('🔍 GoalDetailScreenEnhanced: Updating goal: ${updatedGoal.title}');
          final success = await ref
              .read(goalNotifierProvider.notifier)
              .updateGoal(updatedGoal);

          debugPrint('🔍 GoalDetailScreenEnhanced: Goal update result: $success');

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
            debugPrint('🔍 GoalDetailScreenEnhanced: Goal update failed');
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
    debugPrint('🔍 GoalDetailScreenEnhanced: Showing delete confirmation for: ${goal.title}');

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

    debugPrint('🔍 GoalDetailScreenEnhanced: Delete confirmation result: $confirmed');

    if (confirmed == true) {
      debugPrint('🔍 GoalDetailScreenEnhanced: Deleting goal: ${goal.id}');
      final success = await ref
          .read(goalNotifierProvider.notifier)
          .deleteGoal(goal.id);

      debugPrint('🔍 GoalDetailScreenEnhanced: Delete result: $success');

      if (success && mounted) {
        HapticFeedback.mediumImpact();
        context.go('/goals');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        debugPrint('🔍 GoalDetailScreenEnhanced: Delete failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete goal'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper methods for chart data processing
  List<BudgetChartData> _getWeeklyContributionData(List<dynamic> contributions) {
    debugPrint('🔍 GoalDetailScreenEnhanced: Processing weekly contribution data for ${contributions.length} contributions');

    // Group contributions by day for the last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final Map<String, double> dailyTotals = {};

    // Initialize all days with 0
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('MMM dd').format(date);
      dailyTotals[key] = 0.0;
    }

    // Sum contributions by day
    for (final contribution in contributions) {
      if (contribution.date.isAfter(weekAgo)) {
        final key = DateFormat('MMM dd').format(contribution.date);
        dailyTotals[key] = (dailyTotals[key] ?? 0.0) + contribution.amount;
      }
    }

    // Convert to chart format
    final data = dailyTotals.entries.map((entry) {
      return BudgetChartData(
        label: entry.key,
        value: entry.value,
        color: GoalsThemeExtended.goalPrimary,
      );
    }).toList().reversed.toList(); // Reverse to show oldest first

    debugPrint('🔍 GoalDetailScreenEnhanced: Weekly data processed: ${data.length} points');
    return data;
  }

  List<BudgetChartData> _getMonthlyContributionData(List<dynamic> contributions) {
    debugPrint('🔍 GoalDetailScreenEnhanced: Processing monthly contribution data for ${contributions.length} contributions');

    // Group contributions by month for the last 6 months
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    final Map<String, double> monthlyTotals = {};

    // Initialize all months with 0
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('MMM yyyy').format(date);
      monthlyTotals[key] = 0.0;
    }

    // Sum contributions by month
    for (final contribution in contributions) {
      if (contribution.date.isAfter(sixMonthsAgo)) {
        final key = DateFormat('MMM yyyy').format(contribution.date);
        monthlyTotals[key] = (monthlyTotals[key] ?? 0.0) + contribution.amount;
      }
    }

    // Convert to chart format
    final data = monthlyTotals.entries.map((entry) {
      return BudgetChartData(
        label: entry.key,
        value: entry.value,
        color: GoalsThemeExtended.goalPrimary,
      );
    }).toList();

    debugPrint('🔍 GoalDetailScreenEnhanced: Monthly data processed: ${data.length} points');
    return data;
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