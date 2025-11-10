import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../theme/goals_theme_extended.dart';
import '../widgets/circular_goal_indicator.dart';
import '../widgets/goal_metric_cards.dart';
import '../widgets/enhanced_goal_timeline.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import '../states/goal_state.dart';

/// Enhanced Goals dashboard with advanced visualizations
class GoalsListScreenEnhanced extends ConsumerStatefulWidget {
  const GoalsListScreenEnhanced({super.key});

  @override
  ConsumerState<GoalsListScreenEnhanced> createState() => _GoalsListScreenEnhancedState();
}

class _GoalsListScreenEnhancedState extends ConsumerState<GoalsListScreenEnhanced>
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
    final goalState = ref.watch(goalNotifierProvider);
    final stats = ref.watch(goalStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Financial Goals',
          style: AppTypography.h1.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => context.go('/goals/templates'),
              style: TextButton.styleFrom(
                backgroundColor: GoalsThemeExtended.goalPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'New Goal',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: goalState.when(
        data: (state) => _buildBody(state, stats),
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(goalNotifierProvider),
        ),
      ),
    );
  }

  Widget _buildBody(GoalState state, AsyncValue<GoalStats> statsAsync) {
    if (state.goals.isEmpty) {
      return _buildEmptyState();
    }

    final activeGoals = state.goals.where((g) => !g.isCompleted).toList();
    final featuredGoal = activeGoals.isNotEmpty ? activeGoals.first : state.goals.first;

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh
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
            // Featured Goal - Circular Indicator
            Center(
              child: CircularGoalIndicator(
                goal: featuredGoal,
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),
            ),
            SizedBox(height: AppDimensions.sectionGap),

            // Goal Metric Cards
            GoalMetricCards(goal: featuredGoal),
            SizedBox(height: AppDimensions.sectionGap),

            // Stats Overview (Reuse BudgetStatsRow pattern)
            statsAsync.when(
              data: (stats) => _buildStatsOverview(stats),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            SizedBox(height: AppDimensions.sectionGap),

            // Enhanced Timeline
            EnhancedGoalTimeline(goal: featuredGoal),
            SizedBox(height: AppDimensions.sectionGap),

            // Tab View for Active/All Goals
            _buildGoalsTabView(state),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(GoalStats stats) {
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
                  Icons.analytics,
                  size: 20,
                  color: GoalsThemeExtended.goalPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Goals Overview',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(
                label: 'Total Goals',
                value: stats.totalGoals.toDouble(),
                color: GoalsThemeExtended.goalPrimary,
                prefix: '',
                suffix: '',
              ),
              _VerticalDivider(),
              _StatColumn(
                label: 'Completed',
                value: stats.completedGoals.toDouble(),
                color: GoalsThemeExtended.goalSuccess,
                prefix: '',
                suffix: '',
              ),
              _VerticalDivider(),
              _StatColumn(
                label: 'Progress',
                value: stats.overallProgress * 100,
                color: GoalsThemeExtended.goalSecondary,
                prefix: '',
                suffix: '%',
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 400.ms)
      .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms);
  }

  Widget _buildGoalsTabView(GoalState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, size: 18),
                      const SizedBox(width: 6),
                      Text('Active (${state.goals.where((g) => !g.isCompleted).length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.list, size: 18),
                      const SizedBox(width: 6),
                      Text('All (${state.goals.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Views
          SizedBox(
            height: 500, // Adjust based on content
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Goals
                _buildGoalsList(
                  state.goals.where((g) => !g.isCompleted).toList(),
                ),

                // All Goals
                _buildGoalsList(state.goals),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 500.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildGoalsList(List<Goal> goals) {
    if (goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No goals found',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first goal to start tracking progress',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Slidable(
            key: ValueKey(goal.id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _showEditSheet(context, goal),
                  backgroundColor: GoalsThemeExtended.goalPrimary,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Edit',
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _confirmDelete(context, ref, goal),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            child: _EnhancedGoalCard(goal: goal)
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 100 * index)),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            decoration: BoxDecoration(
              color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag,
              size: 64,
              color: GoalsThemeExtended.goalPrimary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'No goals yet',
            style: AppTypography.h1.copyWith(
              fontSize: 24,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Set your first financial goal and\nstart working towards your dreams',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),
          SizedBox(height: AppDimensions.spacing5),
          ElevatedButton.icon(
            onPressed: () => context.go('/goals/templates'),
            icon: const Icon(Icons.add),
            label: const Text('Create Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: GoalsThemeExtended.goalPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 400.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, Goal goal) {
    HapticFeedback.lightImpact();
    // Navigate to edit screen
    context.go('/goals/${goal.id}/edit');
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Goal goal) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(goalNotifierProvider.notifier)
          .deleteGoal(goal.id);

      if (success && context.mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal deleted successfully')),
        );
      }
    }
  }
}

/// Enhanced Goal Card Component
class _EnhancedGoalCard extends ConsumerWidget {
  const _EnhancedGoalCard({
    required this.goal,
  });

  final Goal goal;

  Color _getPriorityColor() {
    switch (goal.priority) {
      case GoalPriority.high:
        return GoalsThemeExtended.priorityHigh;
      case GoalPriority.medium:
        return GoalsThemeExtended.priorityMedium;
      case GoalPriority.low:
        return GoalsThemeExtended.priorityLow;
    }
  }

  Color _getHealthColor() {
    if (goal.isCompleted) return GoalsThemeExtended.goalSuccess;
    if (goal.isOverdue) return GoalsThemeExtended.goalWarning;
    final progress = goal.progressPercentage;
    if (progress >= 0.75) return GoalsThemeExtended.goalPrimary;
    if (progress >= 0.5) return GoalsThemeExtended.goalSecondary;
    return GoalsThemeExtended.priorityMedium;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = goal.progressPercentage;
    final healthColor = _getHealthColor();
    final priorityColor = _getPriorityColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/goals/${goal.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: goal.isCompleted ? Border.all(
              color: GoalsThemeExtended.goalSuccess.withValues(alpha: 0.3),
              width: 2,
            ) : null,
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
              // Header Row
              Row(
                children: [
                  // Goal Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      goal.isCompleted ? Icons.check_circle : Icons.flag,
                      size: 20,
                      color: healthColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Goal Name & Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          goal.categoryId.replaceAll('_', ' ').toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      goal.priority.displayName,
                      style: AppTypography.caption.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Section
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            healthColor,
                            healthColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: healthColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Amount Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Current Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.formattedCurrentAmount,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: healthColor,
                        ),
                      ),
                    ],
                  ),

                  // Progress Percentage
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: healthColor,
                      ),
                    ),
                  ),

                  // Target Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Target',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.formattedTargetAmount,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer Info
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    goal.isCompleted
                        ? 'Completed'
                        : '${goal.daysRemaining} days ${goal.isOverdue ? "overdue" : "left"}',
                    style: AppTypography.caption.copyWith(
                      color: goal.isOverdue ? GoalsThemeExtended.goalWarning : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (!goal.isCompleted) ...[
                    Icon(
                      goal.remainingAmount > 0 ? Icons.arrow_upward : Icons.check_circle_outline,
                      size: 14,
                      color: goal.remainingAmount > 0
                          ? GoalsThemeExtended.goalSecondary
                          : GoalsThemeExtended.goalSuccess,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      goal.remainingAmount > 0
                          ? '${goal.formattedRemainingAmount} to go'
                          : 'Goal reached!',
                      style: AppTypography.caption.copyWith(
                        color: goal.remainingAmount > 0
                            ? GoalsThemeExtended.goalSecondary
                            : GoalsThemeExtended.goalSuccess,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
    this.prefix = '\$',
    this.suffix = '',
  });

  final String label;
  final double value;
  final Color color;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypographyExtended.statsLabel,
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: value),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                '$prefix${animatedValue.toInt()}$suffix',
                style: AppTypographyExtended.statsValue.copyWith(
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.borderSubtle,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}