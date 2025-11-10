import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import '../states/goal_state.dart';
import 'goals_list_screen_enhanced.dart';

/// Goals dashboard screen - now uses enhanced design
class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(goalNotifierProvider);
    final stats = ref.watch(goalStatsProvider);

    return Scaffold(
      body: goalState.when(
        data: (state) => const GoalsListScreenEnhanced(), // Use enhanced screen
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(goalNotifierProvider),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<GoalStats> stats,
    GoalState state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh
      },
      child: ListView(
        padding: AppTheme.screenPaddingAll,
        children: [
          // View Toggle
          _buildViewToggle(context, ref, state),

          // Statistics Cards
          stats.when(
            data: (stats) => _buildStatsCards(context, stats),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Goals Section
          _buildGoalsSection(context, state),

          // Quick Actions
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, GoalStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                context,
                'Total Goals',
                stats.totalGoals.toString(),
                Icons.flag,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                context,
                'Completed',
                '${stats.completedGoals}/${stats.totalGoals}',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                context,
                'Total Target',
                '\$${stats.totalTargetAmount.toStringAsFixed(0)}',
                Icons.attach_money,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                context,
                'Progress',
                '${(stats.overallProgress * 100).round()}%',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewToggle(BuildContext context, WidgetRef ref, GoalState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment<bool>(
            value: false,
            label: Text('Active Goals'),
            icon: Icon(Icons.play_arrow),
          ),
          ButtonSegment<bool>(
            value: true,
            label: Text('All Goals'),
            icon: Icon(Icons.list),
          ),
        ],
        selected: {state.showAllGoals},
        onSelectionChanged: (Set<bool> selected) {
          final showAll = selected.first;
          ref.read(goalNotifierProvider.notifier).setShowAllGoals(showAll);
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primaryContainer;
              }
              return Theme.of(context).colorScheme.surface;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.onPrimaryContainer;
              }
              return Theme.of(context).colorScheme.onSurface;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context, GoalState state) {
    final sectionTitle = state.showAllGoals ? 'All Goals' : 'Active Goals';
    final goals = state.filteredGoals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (goals.isEmpty) ...[
          _buildEmptyGoals(context, state.showAllGoals),
        ] else ...[
          Column(
            children: goals.map((goal) => _buildGoalCard(context, goal)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyGoals(BuildContext context, bool showAllGoals) {
    final title = showAllGoals ? 'No goals found' : 'No active goals';
    final subtitle = showAllGoals
        ? 'Create your first financial goal to start saving'
        : 'Create your first financial goal to start saving, or view all goals to see completed ones';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal) {
    final progressColor = goal.isOverdue ? Colors.red : Colors.green;
    final daysRemaining = goal.daysRemaining;

    return InkWell(
      onTap: () => context.go('/goals/${goal.id}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.priority == GoalPriority.high
                          ? Colors.red.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.priority.displayName,
                      style: TextStyle(
                        color: goal.priority == GoalPriority.high ? Colors.red : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                goal.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    daysRemaining > 0
                        ? '$daysRemaining days left'
                        : goal.isOverdue
                            ? 'Overdue'
                            : 'Completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: goal.isOverdue ? Colors.red : Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: goal.progressPercentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
              const SizedBox(height: 4),
              Text(
                '${goal.progressText} complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildQuickActionButton(
          context,
          'Add Goal',
          Icons.add,
          Colors.blue,
          () => context.go('/goals/add'),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}