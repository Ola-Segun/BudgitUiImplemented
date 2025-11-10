Comprehensive Transformation Guide: Goals, Bills & Recurring Incomes Screens
📋 Overview
This guide transforms the Goals, Bills, and Recurring Incomes screens to match the aesthetic and visual sophistication of the enhanced Budget List/Detail screens, Home page, and Transaction pages. We'll leverage existing advanced components and create new ones following the established design system.

🎯 PHASE 1: Design System Consistency
1.1 Reusable Components from Budget Screens
Components to Reuse:
dart// Already available from budget implementation:
- CircularBudgetIndicator → Use for goal progress
- DateSelectorPills → Use for bill due date selection
- BudgetStatusBanner → Adapt for bill/income status
- BudgetMetricCards → Use for goal/bill metrics
- BudgetStatsRow → Use for three-column statistics
- BudgetBarChart → Use for spending/income trends
- MiniTrendIndicator → Use for quick trend views
1.2 Extended Theme Integration
dart// lib/features/goals/presentation/theme/goals_theme_extended.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';

class GoalsThemeExtended {
  // Goal-specific colors
  static const Color goalPrimary = Color(0xFF6366F1); // Indigo
  static const Color goalSecondary = Color(0xFF8B5CF6); // Purple
  static const Color goalSuccess = Color(0xFF10B981); // Green
  static const Color goalWarning = Color(0xFFF59E0B); // Amber
  
  // Priority colors
  static const Color priorityHigh = Color(0xFFEF4444); // Red
  static const Color priorityMedium = Color(0xFFF59E0B); // Orange
  static const Color priorityLow = Color(0xFF6B7280); // Gray
  
  // Progress colors - reuse from budget
  static const Color progressNormal = AppColorsExtended.statusNormal;
  static const Color progressWarning = AppColorsExtended.statusWarning;
  static const Color progressCritical = AppColorsExtended.statusCritical;
}

// lib/features/bills/presentation/theme/bills_theme_extended.dart

class BillsThemeExtended {
  // Bill-specific colors
  static const Color billPrimary = Color(0xFFEC4899); // Pink
  static const Color billSecondary = Color(0xFF8B5CF6); // Purple
  
  // Urgency colors - reuse from budget
  static const Color urgencyNormal = AppColorsExtended.statusNormal;
  static const Color urgencySoon = AppColorsExtended.statusWarning;
  static const Color urgencyToday = AppColorsExtended.statusCritical;
  static const Color urgencyOverdue = AppColorsExtended.statusOverBudget;
  
  // Payment status colors
  static const Color statusPaid = Color(0xFF10B981); // Green
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  static const Color statusFailed = Color(0xFFEF4444); // Red
}

// lib/features/recurring_incomes/presentation/theme/income_theme_extended.dart

class IncomeThemeExtended {
  // Income-specific colors
  static const Color incomePrimary = Color(0xFF14B8A6); // Teal
  static const Color incomeSecondary = Color(0xFF06B6D4); // Cyan
  
  // Receipt status colors
  static const Color statusReceived = Color(0xFF10B981); // Green
  static const Color statusExpected = Color(0xFF3B82F6); // Blue
  static const Color statusOverdue = Color(0xFFEF4444); // Red
}

🎨 PHASE 2: Enhanced Goals Screen Components
2.1 Circular Goal Progress Indicator (Reusing CircularBudgetIndicator)
dart// lib/features/goals/presentation/widgets/circular_goal_indicator.dart

import 'package:flutter/material.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';
import '../theme/goals_theme_extended.dart';
import '../../domain/entities/goal.dart';

/// Wrapper around CircularBudgetIndicator customized for goals
class CircularGoalIndicator extends StatelessWidget {
  const CircularGoalIndicator({
    super.key,
    required this.goal,
    this.size = 200,
    this.strokeWidth = 20,
  });

  final Goal goal;
  final double size;
  final double strokeWidth;

  Color _getProgressColor() {
    final progress = goal.progressPercentage;
    if (progress >= 1.0) return GoalsThemeExtended.goalSuccess;
    if (progress >= 0.75) return GoalsThemeExtended.goalPrimary;
    if (progress >= 0.5) return GoalsThemeExtended.goalSecondary;
    return GoalsThemeExtended.goalWarning;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Reuse budget's circular indicator
        CircularBudgetIndicator(
          percentage: goal.progressPercentage,
          spent: goal.currentAmount,
          total: goal.targetAmount,
          size: size,
          strokeWidth: strokeWidth,
        ),
        
        // Optional: Goal-specific overlay
        if (goal.isCompleted)
          Positioned(
            bottom: size * 0.15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: GoalsThemeExtended.goalSuccess,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: GoalsThemeExtended.goalSuccess.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Completed!',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
2.2 Enhanced Goal Status Cards (Reusing BudgetMetricCards Pattern)
dart// lib/features/goals/presentation/widgets/goal_metric_cards.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../theme/goals_theme_extended.dart';
import '../../domain/entities/goal.dart';

class GoalMetricCards extends StatelessWidget {
  const GoalMetricCards({
    super.key,
    required this.goal,
  });

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final daysPercentage = goal.daysRemaining > 0 
        ? (goal.daysRemaining / (goal.deadline.difference(goal.createdAt).inDays)).clamp(0.0, 1.0)
        : 0.0;
    
    final savingsRate = goal.currentAmount > 0
        ? (goal.currentAmount / (DateTime.now().difference(goal.createdAt).inDays.clamp(1, 1000))).clamp(0.0, 1000.0)
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _GoalMetricCard(
            title: 'Progress',
            value: goal.progressPercentage,
            displayValue: '${(goal.progressPercentage * 100).toInt()}%',
            icon: Icons.trending_up,
            color: GoalsThemeExtended.goalPrimary,
            subtitle: goal.formattedCurrentAmount,
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GoalMetricCard(
            title: 'Time Left',
            value: daysPercentage,
            displayValue: '${goal.daysRemaining}d',
            icon: Icons.calendar_today,
            color: goal.isOverdue 
                ? GoalsThemeExtended.goalWarning 
                : GoalsThemeExtended.goalSecondary,
            subtitle: goal.isOverdue ? 'Overdue' : 'Remaining',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms),
        ),
      ],
    );
  }
}

class _GoalMetricCard extends StatefulWidget {
  const _GoalMetricCard({
    required this.title,
    required this.value,
    required this.displayValue,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final String title;
  final double value;
  final String displayValue;
  final IconData icon;
  final Color color;
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
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Icon container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 16),
          
          // Display value
          Text(
            widget.displayValue,
            style: AppTypographyExtended.metricPercentage.copyWith(
              color: widget.color,
            ),
          ),
          const SizedBox(height: 4),
          
          // Title
          Text(
            widget.title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          
          // Subtitle
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
2.3 Goal Timeline Visualization (Enhanced)
dart// lib/features/goals/presentation/widgets/enhanced_goal_timeline.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../theme/goals_theme_extended.dart';
import '../../domain/entities/goal.dart';

class EnhancedGoalTimeline extends StatelessWidget {
  const EnhancedGoalTimeline({
    super.key,
    required this.goal,
  });

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDays = goal.deadline.difference(goal.createdAt).inDays;
    final elapsedDays = now.difference(goal.createdAt).inDays;
    final timeProgress = (elapsedDays / totalDays).clamp(0.0, 1.0);

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GoalsThemeExtended.goalSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timeline,
                  size: 20,
                  color: GoalsThemeExtended.goalSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Goal Timeline',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Timeline visualization
          SizedBox(
            height: 80,
            child: Stack(
              children: [
                // Background track
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                
                // Progress track
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: timeProgress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GoalsThemeExtended.goalPrimary,
                            GoalsThemeExtended.goalSecondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ).animate()
                      .scaleX(
                        duration: 1000.ms,
                        curve: Curves.easeOutCubic,
                        begin: 0.0,
                        end: 1.0,
                      ),
                  ),
                ),
                
                // Start marker
                _buildTimelineMarker(
                  context,
                  0.0,
                  'Started',
                  DateFormat('MMM dd').format(goal.createdAt),
                  Icons.flag,
                  GoalsThemeExtended.goalSuccess,
                  true,
                ),
                
                // Current position marker
                if (!goal.isCompleted && timeProgress < 1.0)
                  _buildTimelineMarker(
                    context,
                    timeProgress,
                    'Today',
                    DateFormat('MMM dd').format(now),
                    Icons.circle,
                    GoalsThemeExtended.goalPrimary,
                    true,
                  ),
                
                // End marker
                _buildTimelineMarker(
                  context,
                  1.0,
                  goal.isCompleted ? 'Completed' : 'Target',
                  DateFormat('MMM dd').format(goal.deadline),
                  goal.isCompleted ? Icons.check_circle : Icons.flag_outlined,
                  goal.isCompleted 
                      ? GoalsThemeExtended.goalSuccess 
                      : goal.isOverdue 
                          ? GoalsThemeExtended.goalWarning 
                          : GoalsThemeExtended.goalSecondary,
                  goal.isCompleted,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimelineStat(
                context,
                'Days Elapsed',
                '$elapsedDays',
                Icons.history,
                GoalsThemeExtended.goalPrimary,
              ),
              _buildVerticalDivider(),
              _buildTimelineStat(
                context,
                goal.isOverdue ? 'Days Overdue' : 'Days Left',
                '${goal.daysRemaining.abs()}',
                goal.isOverdue ? Icons.warning : Icons.schedule,
                goal.isOverdue 
                    ? GoalsThemeExtended.goalWarning 
                    : GoalsThemeExtended.goalSecondary,
              ),
              _buildVerticalDivider(),
              _buildTimelineStat(
                context,
                'Total Days',
                '$totalDays',
                Icons.calendar_today,
                AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 400.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 400.ms);
  }

  Widget _buildTimelineMarker(
    BuildContext context,
    double position,
    String label,
    String date,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Positioned(
      left: position == 0.0 
          ? 0 
          : position == 1.0 
              ? null 
              : MediaQuery.of(context).size.width * position - 60,
      right: position == 1.0 ? 0 : null,
      top: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date label
          Text(
            date,
            style: AppTypography.caption.copyWith(
              color: isActive ? color : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          
          // Status label
          Text(
            label,
            style: AppTypographyExtended.datePillLabel.copyWith(
              color: isActive ? color : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          
          // Icon marker
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? color : AppColors.borderSubtle,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: isActive ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ).animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 200 + (position * 100).toInt()))
        .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, delay: Duration(milliseconds: 200 + (position * 100).toInt())),
    );
  }

  Widget _buildTimelineStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypographyExtended.statsValue.copyWith(
              color: color,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypographyExtended.statsLabel,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.borderSubtle,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
2.4 Enhanced Goals List Screen
dart// lib/features/goals/presentation/screens/goals_list_screen_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../theme/goals_theme_extended.dart';
import '../widgets/circular_goal_indicator.dart';
import '../widgets/goal_metric_cards.dart';
import '../widgets/mini_trend_indicator.dart';
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
              onPressed: () => context.go('/goals/add'),
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
                  child: Row(RetryBContinuedart                    mainAxisAlignment: MainAxisAlignment.center,
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
          child: _EnhancedGoalCard(goal: goal)
              .animate()
              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
              .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 100 * index)),
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
            onPressed: () => context.go('/goals/add'),
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
                        Consumer(
                          builder: (context, ref, child) {
                            final categoryStateAsync = ref.watch(categoryNotifierProvider);
                            return categoryStateAsync.when(
                              data: (categoryState) {
                                final category = categoryState.getCategoryById(goal.categoryId);
                                final categoryName = category?.name ?? 
                                    goal.categoryId.replaceAll('_', ' ').toUpperCase();
                                return Text(
                                  categoryName,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                              loading: () => Text(
                                goal.categoryId.replaceAll('_', ' ').toUpperCase(),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              error: (_, __) => Text(
                                goal.categoryId.replaceAll('_', ' ').toUpperCase(),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
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

💳 PHASE 3: Enhanced Bills Screen Components
3.1 Bill Status Indicator (Reusing BudgetStatusBanner Pattern)
dart// lib/features/bills/presentation/widgets/bill_status_banner_enhanced.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../theme/bills_theme_extended.dart';
import '../../domain/entities/bill.dart';

class BillStatusBannerEnhanced extends StatelessWidget {
  const BillStatusBannerEnhanced({
    super.key,
    required this.bill,
    this.showDot = true,
  });

  final Bill bill;
  final bool showDot;

  String _getStatusMessage() {
    if (bill.isPaid) {
      return 'Payment completed successfully';
    } else if (bill.isOverdue) {
      return '${bill.daysUntilDue.abs()} days overdue - Pay immediately';
    } else if (bill.isDueToday) {
      return 'Due today - ${bill.formattedAmount} payment required';
    } else if (bill.isDueSoon) {
      return 'Due in ${bill.daysUntilDue} days - Plan your payment';
    } else {
      return '${bill.daysUntilDue} days until due';
    }
  }

  Color _getStatusColor() {
    if (bill.isPaid) return BillsThemeExtended.statusPaid;
    if (bill.isOverdue) return BillsThemeExtended.urgencyOverdue;
    if (bill.isDueToday) return BillsThemeExtended.urgencyToday;
    if (bill.isDueSoon) return BillsThemeExtended.urgencySoon;
    return BillsThemeExtended.urgencyNormal;
  }

  String _getStatusLabel() {
    if (bill.isPaid) return 'Paid';
    if (bill.isOverdue) return 'Overdue';
    if (bill.isDueToday) return 'Due Today';
    if (bill.isDueSoon) return 'Due Soon';
    return 'Upcoming';
  }

  IconData _getStatusIcon() {
    if (bill.isPaid) return Icons.check_circle;
    if (bill.isOverdue) return Icons.warning;
    if (bill.isDueToday) return Icons.alarm;
    if (bill.isDueSoon) return Icons.schedule;
    return Icons.event_available;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Status Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusMessage(),
                  style: AppTypographyExtended.statusMessage.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (bill.accountId != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Linked to account',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Status Badge
          if (showDot)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                _getStatusLabel(),
                style: AppTypographyExtended.statusMessage.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
3.2 Bills Dashboard Enhanced
dart// lib/features/bills/presentation/screens/bills_dashboard_screen_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart'; // Reuse
import '../../../budgets/presentation/widgets/budget_bar_chart.dart'; // Reuse
import '../theme/bills_theme_extended.dart';
import '../widgets/bill_status_banner_enhanced.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_providers.dart';

/// Enhanced Bills Dashboard with advanced visualizations
class BillsDashboardScreenEnhanced extends ConsumerStatefulWidget {
  const BillsDashboardScreenEnhanced({super.key});

  @override
  ConsumerState<BillsDashboardScreenEnhanced> createState() => 
      _BillsDashboardScreenEnhancedState();
}

class _BillsDashboardScreenEnhancedState 
    extends ConsumerState<BillsDashboardScreenEnhanced> 
    with SingleTickerProviderStateMixin {
  String? _selectedAccountFilterId;
  bool _showLinkedOnly = false;
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
    final billState = ref.watch(billNotifierProvider);
    final upcomingBills = ref.watch(upcomingBillsProvider);
    final summary = ref.watch(billsSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Bills & Payments',
          style: AppTypography.h1.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => context.go('/more/bills/add'),
              style: TextButton.styleFrom(
                backgroundColor: BillsThemeExtended.billPrimary,
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
                    'New Bill',
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
      body: billState.when(
        initial: () => const LoadingView(),
        loading: () => const LoadingView(),
        loaded: (bills, loadedSummary) => _buildDashboard(
          context,
          bills,
          loadedSummary,
          upcomingBills,
        ),
        error: (message, bills, errorSummary) => ErrorView(
          message: message,
          onRetry: () => ref.refresh(billNotifierProvider),
        ),
        billLoaded: (_, __) => const SizedBox.shrink(),
        billSaved: (_) => const SizedBox.shrink(),
        billDeleted: () => const SizedBox.shrink(),
        paymentMarked: (_) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    List<Bill> bills,
    BillsSummary summary,
    List<BillStatus> upcomingBills,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(billNotifierProvider.notifier).refresh();
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
            // Summary Stats (Reuse BudgetStatsRow pattern)
            _buildSummaryStats(summary),
            SizedBox(height: AppDimensions.sectionGap),

            // Upcoming Bills Section
            _buildUpcomingBillsSection(upcomingBills),
            SizedBox(height: AppDimensions.sectionGap),

            // Monthly Spending Chart
            _buildMonthlySpendingChart(bills),
            SizedBox(height: AppDimensions.sectionGap),

            // Account Filters
            _buildAccountFilters(),
            const SizedBox(height: 16),

            // All Bills List
            _buildAllBillsSection(bills),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(BillsSummary summary) {
    return BudgetStatsRow(
      allotted: summary.totalBills.toDouble(),
      used: summary.paidThisMonth.toDouble(),
      remaining: (summary.totalBills - summary.paidThisMonth).toDouble(),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildUpcomingBillsSection(List<BillStatus> upcomingBills) {
    final filteredBills = _filterUpcomingBills(upcomingBills);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Upcoming Bills',
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BillsThemeExtended.billPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${filteredBills.length}',
                style: AppTypography.bodyMedium.copyWith(
                  color: BillsThemeExtended.billPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
        
        const SizedBox(height: 16),
        
        if (filteredBills.isEmpty)
          _buildEmptyUpcomingBills()
        else
          ...filteredBills.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EnhancedBillStatusCard(status: status)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 300 + (index * 100)))
                  .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 300 + (index * 100))),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildMonthlySpendingChart(List<Bill> bills) {
    final chartData = _generateMonthlyChartData(bills);

    return BudgetBarChart(
      data: chartData,
      title: 'Monthly Bill Payments',
      period: 'Last 6 Months',
      height: 200,
    ).animate()
      .fadeIn(duration: 500.ms, delay: 400.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 400.ms);
  }

  Widget _buildAccountFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Account',
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final accountsAsync = ref.watch(filteredAccountsProvider);
            return accountsAsync.when(
              data: (accounts) {
                return Wrap(
                  spacing: 8,RetryBContinuedart                  runSpacing: 8,
                  children: [
                    // All bills filter
                    FilterChip(
                      label: Text(
                        'All Bills',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      selected: _selectedAccountFilterId == null && !_showLinkedOnly,
                      selectedColor: BillsThemeExtended.billPrimary.withValues(alpha: 0.2),
                      checkmarkColor: BillsThemeExtended.billPrimary,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedAccountFilterId = null;
                            _showLinkedOnly = false;
                          });
                        }
                      },
                    ),
                    // Linked bills only filter
                    FilterChip(
                      label: Text(
                        'Linked Only',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      selected: _showLinkedOnly,
                      selectedColor: BillsThemeExtended.billSecondary.withValues(alpha: 0.2),
                      checkmarkColor: BillsThemeExtended.billSecondary,
                      onSelected: (selected) {
                        setState(() {
                          _showLinkedOnly = selected;
                          if (selected) _selectedAccountFilterId = null;
                        });
                      },
                    ),
                    // Individual account filters
                    ...accounts.map((account) {
                      return FilterChip(
                        avatar: Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: Color(account.type.color),
                        ),
                        label: Text(
                          account.displayName,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        selected: _selectedAccountFilterId == account.id,
                        selectedColor: Color(account.type.color).withValues(alpha: 0.2),
                        checkmarkColor: Color(account.type.color),
                        onSelected: (selected) {
                          setState(() {
                            _selectedAccountFilterId = selected ? account.id : null;
                            _showLinkedOnly = false;
                          });
                        },
                      );
                    }),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading accounts: $error'),
            );
          },
        ),
      ],
    ).animate()
      .fadeIn(duration: 400.ms, delay: 500.ms)
      .slideX(begin: -0.1, duration: 400.ms, delay: 500.ms);
  }

  Widget _buildAllBillsSection(List<Bill> bills) {
    final filteredBills = _filterBills(bills);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _getFilteredBillsTitle(),
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BillsThemeExtended.billSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${filteredBills.length}',
                style: AppTypography.bodyMedium.copyWith(
                  color: BillsThemeExtended.billSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 600.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 600.ms),
        
        const SizedBox(height: 16),
        
        if (filteredBills.isEmpty)
          _buildEmptyFilteredBills()
        else
          ...filteredBills.asMap().entries.map((entry) {
            final index = entry.key;
            final bill = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EnhancedBillCard(bill: bill)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 100)))
                  .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 100))),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildEmptyUpcomingBills() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming bills',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All your bills are paid or no bills are due soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilteredBills() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.filter_list_off,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No bills found',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters to see more bills',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedAccountFilterId = null;
                _showLinkedOnly = false;
              });
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<BillStatus> _filterUpcomingBills(List<BillStatus> bills) {
    return bills.where((status) {
      if (_showLinkedOnly) {
        return status.bill.accountId != null;
      } else if (_selectedAccountFilterId != null) {
        return status.bill.accountId == _selectedAccountFilterId;
      }
      return true;
    }).toList();
  }

  List<Bill> _filterBills(List<Bill> bills) {
    if (_showLinkedOnly) {
      return bills.where((bill) => bill.accountId != null).toList();
    } else if (_selectedAccountFilterId != null) {
      return bills.where((bill) => bill.accountId == _selectedAccountFilterId).toList();
    }
    return bills;
  }

  String _getFilteredBillsTitle() {
    if (_showLinkedOnly) return 'Bills with Linked Accounts';
    if (_selectedAccountFilterId != null) return 'Bills for Selected Account';
    return 'All Bills';
  }

  List<BudgetChartData> _generateMonthlyChartData(List<Bill> bills) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    
    return List.generate(6, (index) {
      final monthIndex = (now.month - 6 + index) % 12;
      // Calculate actual bill amounts for each month
      final monthlyTotal = bills.fold(0.0, (sum, bill) {
        // Simplified calculation - in real app, use payment history
        return sum + (bill.amount / 12);
      });
      
      return BudgetChartData(
        label: months[monthIndex],
        value: monthlyTotal,
        color: BillsThemeExtended.billPrimary,
      );
    });
  }
}

/// Enhanced Bill Status Card
class _EnhancedBillStatusCard extends StatelessWidget {
  const _EnhancedBillStatusCard({
    required this.status,
  });

  final BillStatus status;

  Color _getUrgencyColor() {
    switch (status.urgency) {
      case BillUrgency.overdue:
        return BillsThemeExtended.urgencyOverdue;
      case BillUrgency.dueToday:
        return BillsThemeExtended.urgencyToday;
      case BillUrgency.dueSoon:
        return BillsThemeExtended.urgencySoon;
      case BillUrgency.normal:
        return BillsThemeExtended.urgencyNormal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/more/bills/${status.bill.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: status.urgency == BillUrgency.overdue ? Border.all(
              color: urgencyColor.withValues(alpha: 0.3),
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
          child: Row(
            children: [
              // Urgency Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  status.urgency == BillUrgency.overdue 
                      ? Icons.warning 
                      : Icons.receipt,
                  size: 20,
                  color: urgencyColor,
                ),
              ),
              const SizedBox(width: 12),
              
              // Bill Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.bill.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: urgencyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.urgency == BillUrgency.overdue
                              ? '${status.daysUntilDue.abs()} days overdue'
                              : '${status.daysUntilDue} days left',
                          style: AppTypography.caption.copyWith(
                            color: urgencyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Amount & Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    status.bill.formattedAmount,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: urgencyColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.urgency.displayName,
                      style: AppTypography.caption.copyWith(
                        color: urgencyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Bill Card (similar pattern to Goal Card)
class _EnhancedBillCard extends ConsumerWidget {
  const _EnhancedBillCard({
    required this.bill,
  });

  final Bill bill;

  Color _getStatusColor() {
    if (bill.isPaid) return BillsThemeExtended.statusPaid;
    if (bill.isOverdue) return BillsThemeExtended.urgencyOverdue;
    if (bill.isDueToday) return BillsThemeExtended.urgencyToday;
    if (bill.isDueSoon) return BillsThemeExtended.urgencySoon;
    return BillsThemeExtended.urgencyNormal;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/more/bills/${bill.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: bill.isPaid ? Border.all(
              color: BillsThemeExtended.statusPaid.withValues(alpha: 0.3),
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
                  // Bill Icon with Account Indicator
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          bill.isPaid ? Icons.check_circle : Icons.receipt,
                          size: 20,
                          color: statusColor,
                        ),
                      ),
                      if (bill.accountId != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.link,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  
                  // Bill Name & Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bill.frequency.displayName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  if (bill.isPaid)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BillsThemeExtended.statusPaid.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: BillsThemeExtended.statusPaid,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Paid',
                            style: AppTypography.caption.copyWith(
                              color: BillsThemeExtended.statusPaid,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
              
              // Amount and Due Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bill.formattedAmount,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // Due Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Due Date',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM dd').format(bill.dueDate),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
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
                    bill.isPaid
                        ? 'Paid'
                        : bill.isOverdue
                            ? '${bill.daysUntilDue.abs()} days overdue'
                            : '${bill.daysUntilDue} days left',
                    style: AppTypography.caption.copyWith(
                      color: bill.isOverdue 
                          ? BillsThemeExtended.urgencyOverdue 
                          : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (bill.accountId != null) ...[
                    Icon(
                      Icons.account_balance_wallet,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Linked',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.link_off,
                      size: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Not linked',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
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

💰 PHASE 4: Enhanced Recurring Incomes Screen Components
4.1 Income Status Cards (Reusing Metric Card Pattern)
dart// lib/features/recurring_incomes/presentation/widgets/income_metric_cards.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../theme/income_theme_extended.dart';
import '../../domain/entities/recurring_income.dart';

class IncomeMetricCards extends StatelessWidget {
  const IncomeMetricCards({
    super.key,
    required this.summary,
  });

  final RecurringIncomesSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _IncomeMetricCard(
            title: 'Expected',
            value: summary.expectedAmount,
            displayValue: '\$${summary.expectedAmount.toStringAsFixed(0)}',
            icon: Icons.schedule,
            color: IncomeThemeExtended.incomeSecondary,
            subtitle: 'This Month',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _IncomeMetricCard(
            title: 'Received',
            value: summary.receivedThisMonth,
            displayValue: '\$${summary.receivedThisMonth.toStringAsFixed(0)}',
            icon: Icons.check_circle,
            color: IncomeThemeExtended.statusReceived,
            subtitle: 'This Month',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms),
        ),
      ],
    );
  }
}

class _IncomeMetricCard extends StatefulWidget {
  const _IncomeMetricCard({
    required this.title,
    required this.value,
    required this.displayValue,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final String title;
  final double value;
  final String displayValue;
  final IconData icon;
  final Color color;
  final String subtitle;

  @override
  State<_IncomeMetricCard> createState() => _IncomeMetricCardState();
}

class _IncomeMetricCardState extends State<_IncomeMetricCard> 
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
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 16),
          
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '\$${_animation.value.toStringAsFixed(0)}',
                style: AppTypographyExtended.metricPercentage.copyWith(
                  color: widget.color,
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
4.2 Enhanced Recurring Income Dashboard
dart// lib/features/recurring_incomes/presentation/screens/recurring_income_dashboard_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart';
import '../../../budgets/presentation/widgets/budget_bar_chart.dart';
import '../theme/income_theme_extended.dart';
import '../widgets/income_metric_cards.dart';
import '../../domain/entities/recurring_income.dart';
import '../providers/recurring_income_providers.dart';

/// Enhanced Recurring Income Dashboard with advanced visualizations
class RecurringIncomeDashboardEnhanced extends ConsumerStatefulWidget {
  const RecurringIncomeDashboardEnhanced({super.key});

  @override
  ConsumerState<RecurringIncomeDashboardEnhanced> createState() => 
      _RecurringIncomeDashboardEnhancedState();
}

class _RecurringIncomeDashboardEnhancedState 
    extends ConsumerState<RecurringIncomeDashboardEnhanced> {
  
  @override
  Widget build(BuildContext context) {
    final incomeState = ref.watch(recurringIncomeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Recurring Incomes',
          style: AppTypography.h1.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => context.go('/more/incomes/add'),
              style: TextButton.styleFrom(
                backgroundColor: IncomeThemeExtended.incomePrimary,
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
                    'New Income',
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
      body: incomeState.when(
        initial: () => const LoadingView(),
        loading: () => const LoadingView(),
        loaded: (incomes, summary) => _buildDashboard(incomes, summary),
        incomeLoaded: (income, status) => const LoadingView(),
        incomeSaved: (income) => const LoadingView(),
        receiptRecorded: (income) => const LoadingView(),
        incomeDeleted: () => const LoadingView(),
        error: (message, incomes, summary) => ErrorView(
          message: message,
          onRetry: () => ref.refresh(recurringIncomeNotifierProvider),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    List<RecurringIncome> incomes,
    RecurringIncomesSummary summary,
  ) {
    if (incomes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(recurringIncomeNotifierProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:RetryBContinuedart EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income Metric Cards
            IncomeMetricCards(summary: summary),
            SizedBox(height: AppDimensions.sectionGap),

            // Stats Overview (Reuse BudgetStatsRow pattern)
            _buildStatsOverview(summary),
            SizedBox(height: AppDimensions.sectionGap),

            // Monthly Income Chart
            _buildMonthlyIncomeChart(incomes),
            SizedBox(height: AppDimensions.sectionGap),

            // Upcoming Incomes
            if (summary.upcomingIncomes.isNotEmpty) ...[
              _buildUpcomingIncomesSection(summary.upcomingIncomes),
              SizedBox(height: AppDimensions.sectionGap),
            ],

            // All Incomes List
            _buildAllIncomesSection(incomes),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(RecurringIncomesSummary summary) {
    return BudgetStatsRow(
      allotted: summary.expectedAmount,
      used: summary.receivedThisMonth,
      remaining: summary.expectedAmount - summary.receivedThisMonth,
    ).animate()
      .fadeIn(duration: 400.ms, delay: 400.ms)
      .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms);
  }

  Widget _buildMonthlyIncomeChart(List<RecurringIncome> incomes) {
    final chartData = _generateMonthlyChartData(incomes);

    return BudgetBarChart(
      data: chartData,
      title: 'Monthly Income Tracking',
      period: 'Last 6 Months',
      height: 200,
    ).animate()
      .fadeIn(duration: 500.ms, delay: 500.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildUpcomingIncomesSection(List<RecurringIncomeStatus> upcomingIncomes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Upcoming Incomes',
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: IncomeThemeExtended.incomePrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${upcomingIncomes.length}',
                style: AppTypography.bodyMedium.copyWith(
                  color: IncomeThemeExtended.incomePrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 600.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 600.ms),
        
        const SizedBox(height: 16),
        
        ...upcomingIncomes.asMap().entries.map((entry) {
          final index = entry.key;
          final status = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _EnhancedIncomeStatusCard(status: status)
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 100)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 100))),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAllIncomesSection(List<RecurringIncome> incomes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'All Incomes',
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: IncomeThemeExtended.incomeSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${incomes.length}',
                style: AppTypography.bodyMedium.copyWith(
                  color: IncomeThemeExtended.incomeSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 800.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 800.ms),
        
        const SizedBox(height: 16),
        
        ...incomes.asMap().entries.map((entry) {
          final index = entry.key;
          final income = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _EnhancedIncomeCard(income: income)
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 900 + (index * 100)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 900 + (index * 100))),
          );
        }).toList(),
      ],
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
              color: IncomeThemeExtended.incomePrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: IncomeThemeExtended.incomePrimary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'No recurring incomes',
            style: AppTypography.h1.copyWith(
              fontSize: 24,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Add your first recurring income to\nstart tracking your regular earnings',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),
          SizedBox(height: AppDimensions.spacing5),
          ElevatedButton.icon(
            onPressed: () => context.go('/more/incomes/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Income'),
            style: ElevatedButton.styleFrom(
              backgroundColor: IncomeThemeExtended.incomePrimary,
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

  List<BudgetChartData> _generateMonthlyChartData(List<RecurringIncome> incomes) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    
    return List.generate(6, (index) {
      final monthIndex = (now.month - 6 + index) % 12;
      // Calculate actual income amounts for each month
      final monthlyTotal = incomes.fold(0.0, (sum, income) {
        // Simplified calculation - in real app, use income history
        return sum + (income.amount / 12);
      });
      
      return BudgetChartData(
        label: months[monthIndex],
        value: monthlyTotal,
        color: IncomeThemeExtended.incomePrimary,
      );
    });
  }
}

/// Enhanced Income Status Card
class _EnhancedIncomeStatusCard extends StatelessWidget {
  const _EnhancedIncomeStatusCard({
    required this.status,
  });

  final RecurringIncomeStatus status;

  Color _getUrgencyColor() {
    switch (status.urgency) {
      case RecurringIncomeUrgency.overdue:
        return IncomeThemeExtended.statusOverdue;
      case RecurringIncomeUrgency.expectedToday:
        return IncomeThemeExtended.incomeSecondary;
      case RecurringIncomeUrgency.expectedSoon:
        return IncomeThemeExtended.statusExpected;
      case RecurringIncomeUrgency.normal:
        return IncomeThemeExtended.incomePrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/more/incomes/${status.income.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: status.urgency == RecurringIncomeUrgency.overdue ? Border.all(
              color: urgencyColor.withValues(alpha: 0.3),
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
          child: Row(
            children: [
              // Urgency Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  status.urgency == RecurringIncomeUrgency.overdue 
                      ? Icons.warning 
                      : Icons.trending_up,
                  size: 20,
                  color: urgencyColor,
                ),
              ),
              const SizedBox(width: 12),
              
              // Income Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.income.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: urgencyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.isOverdue
                              ? '${status.daysUntilExpected.abs()} days overdue'
                              : status.daysUntilExpected == 0
                                  ? 'Expected today'
                                  : 'In ${status.daysUntilExpected} days',
                          style: AppTypography.caption.copyWith(
                            color: urgencyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Amount & Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${status.income.amount.toStringAsFixed(0)}',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: urgencyColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.urgency.displayName,
                      style: AppTypography.caption.copyWith(
                        color: urgencyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Income Card
class _EnhancedIncomeCard extends StatelessWidget {
  const _EnhancedIncomeCard({
    required this.income,
  });

  final RecurringIncome income;

  Color _getStatusColor() {
    if (income.hasEnded) return AppColors.textSecondary;
    return IncomeThemeExtended.incomePrimary;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isActive = !income.hasEnded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/more/incomes/${income.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: !isActive ? Border.all(
              color: AppColors.borderSubtle,
              width: 1,
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
                  // Income Icon with Account Indicator
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isActive ? Icons.trending_up : Icons.stop_circle,
                          size: 20,
                          color: statusColor,
                        ),
                      ),
                      if (income.defaultAccountId != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.link,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  
                  // Income Name & Frequency
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          income.name,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: isActive ? null : TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          income.frequency.displayName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Ended',
                      style: AppTypography.caption.copyWith(
                        color: statusColor,
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
              
              // Amount and Next Expected
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${income.amount.toStringAsFixed(0)}',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // Next Expected
                  if (income.nextExpectedDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Next Expected',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM dd').format(income.nextExpectedDate!),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
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
                    Icons.history,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${income.incomeHistory.length} receipts',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (income.defaultAccountId != null) ...[
                    Icon(
                      Icons.account_balance_wallet,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Linked',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.link_off,
                      size: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Not linked',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
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
```

---

## 📝 PHASE 5: Implementation Checklist & Summary

### 5.1 Complete File Structure
```
lib/
├── features/
│   ├── goals/
│   │   ├── presentation/
│   │   │   ├── theme/
│   │   │   │   └── goals_theme_extended.dart ⭐ NEW
│   │   │   ├── screens/
│   │   │   │   └── goals_list_screen_enhanced.dart ⭐ ENHANCED
│   │   │   └── widgets/
│   │   │       ├── circular_goal_indicator.dart ⭐ NEW
│   │   │       ├── goal_metric_cards.dart ⭐ NEW
│   │   │       └── enhanced_goal_timeline.dart ⭐ NEW
│   │
│   ├── bills/
│   │   ├── presentation/
│   │   │   ├── theme/
│   │   │   │   └── bills_theme_extended.dart ⭐ NEW
│   │   │   ├── screens/
│   │   │   │   └── bills_dashboard_screen_enhanced.dart ⭐ ENHANCED
│   │   │   └── widgets/
│   │   │       └── bill_status_banner_enhanced.dart ⭐ NEW
│   │
│   └── recurring_incomes/
│       ├── presentation/
│       │   ├── theme/
│       │   │   └── income_theme_extended.dart ⭐ NEW
│       │   ├── screens/
│       │   │   └── recurring_income_dashboard_enhanced.dart ⭐ ENHANCED
│       │   └── widgets/
│       │       └── income_metric_cards.dart ⭐ NEW
5.2 Components Reused from Budget Implementation
✅ CircularBudgetIndicator → Used for goal progress
✅ DateSelectorPills → Can be adapted for bill due dates
✅ BudgetStatusBanner → Adapted for bill/income status
✅ BudgetMetricCards → Pattern reused for goal/income metrics
✅ BudgetStatsRow → Used for three-column statistics
✅ BudgetBarChart → Used for spending/income trends
✅ MiniTrendIndicator → Available for quick trend views
5.3 Key Design Patterns Applied

Consistent Color Theming: Each feature has its own theme extension while maintaining overall design coherence
Animation Consistency: All screens use flutter_animate with staggered timing
Card-Based Layout: Uniform card styling with shadows and rounded corners
Status Indicators: Color-coded status with icons and badges
Progressive Enhancement: Empty states, loading states, and error states all styled consistently
Haptic Feedback: Tactile responses on user interactions
Responsive Typography: Using established typography scales

5.4 Implementation Notes
For Goals:

Reuse CircularBudgetIndicator with goal-specific colors
Timeline visualization shows progress over time
Priority badges use consistent styling
Completion states clearly marked

For Bills:

Urgency color-coding matches budget health indicators
Account linkage shown with visual indicators
Payment history integrated into detail views
Due date tracking with countdown

For Recurring Incomes:

Expected vs received clearly differentiated
Account linkage visualized
Receipt history accessible
Frequency indicators prominent

5.5 Additional Enhancements to Consider
dart// Optional: Add floating summary cards
// lib/core/widgets/floating_summary_card.dart

class FloatingSummaryCard extends StatelessWidget {
  const FloatingSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.h3.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: -0.1, duration: 400.ms, curve: Curves.elasticOut);
  }
}

🚀 Final Summary
This comprehensive transformation ensures that Goals, Bills, and Recurring Incomes screens maintain visual and functional consistency with the enhanced Budget and Home screens while providing:
✅ Visual Cohesion: Unified design language across all financial management features
✅ Component Reusability: Maximum leverage of existing budget components
✅ Enhanced UX: Smooth animations, haptic feedback, and intuitive interactions
✅ Data Visualization: Charts, progress indicators, and status badges
✅ Accessibility: Proper color contrast, semantic markup, and screen reader support
✅ Performance: Optimized animations and efficient widget rebuilds
✅ Maintainability: Clear component structure and documentation
All screens now follow the same elevated aesthetic with circular progress indicators, metric cards, timeline visualizations, and interactive charts established in the budget implementation.