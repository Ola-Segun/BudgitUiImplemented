import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import '../widgets/add_contribution_bottom_sheet.dart';
import '../widgets/edit_goal_bottom_sheet.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/goal_timeline_card.dart';

/// Screen for displaying detailed goal information and managing contributions
class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({
    super.key,
    required this.goalId,
  });

  final String goalId;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final goalStateAsync = ref.watch(goalNotifierProvider);
    final contributionsAsync = ref.watch(goalContributionsProvider(widget.goalId));

    // Find the goal from the notifier state
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
      appBar: AppBar(
        title: goalAsync.when(
          data: (goal) => Text(goal?.title ?? 'Goal Details'),
          loading: () => const Text('Loading...'),
          error: (error, stack) => const Text('Goal Details'),
        ),
        actions: [
          goalAsync.when(
            data: (goal) {
              if (goal == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, ref, goal, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit Goal'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Goal', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: goalAsync.when(
        data: (goal) {
          if (goal == null) {
            return const Center(
              child: Text('Goal not found'),
            );
          }

          return _buildGoalDetail(context, ref, goal, contributionsAsync);
        },
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(goalProvider(widget.goalId)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContributionSheet(context, ref),
        tooltip: 'Add Contribution',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalDetail(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
    AsyncValue<List<dynamic>> contributionsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(goalNotifierProvider.notifier).loadGoals(),
        ]);
      },
      child: ListView(
        padding: AppTheme.screenPaddingAll,
        children: [
          // Goal Progress Card
          GoalProgressCard(goal: goal),
          const SizedBox(height: 24),

          // Goal Timeline Card
          GoalTimelineCard(goal: goal),
          const SizedBox(height: 24),

          // Goal Information
          _buildGoalInfo(context, goal),
          const SizedBox(height: 24),

          // Contribution History
          _buildContributionHistory(context, contributionsAsync),
        ],
      ),
    );
  }

  Widget _buildGoalInfo(BuildContext context, Goal goal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Category
            Consumer(
              builder: (context, ref, child) {
                final categoryStateAsync = ref.watch(categoryNotifierProvider);
                return categoryStateAsync.when(
                  data: (categoryState) {
                    final category = categoryState.getCategoryById(goal.categoryId);
                    final categoryName = category?.name ?? goal.categoryId.replaceAll('_', ' ').toUpperCase();
                    return _buildInfoRow('Category', categoryName);
                  },
                  loading: () => _buildInfoRow('Category', goal.categoryId.replaceAll('_', ' ').toUpperCase()),
                  error: (error, stack) => _buildInfoRow('Category', goal.categoryId.replaceAll('_', ' ').toUpperCase()),
                );
              },
            ),

            // Priority
            _buildInfoRow('Priority', goal.priority.displayName),

            // Target Amount
            _buildInfoRow('Target Amount', goal.formattedTargetAmount),

            // Current Amount
            _buildInfoRow('Current Amount', goal.formattedCurrentAmount),

            // Remaining Amount
            _buildInfoRow('Remaining', goal.formattedRemainingAmount),

            // Monthly Contribution Needed
            if (!goal.isCompleted)
              _buildInfoRow(
                'Monthly Needed',
                '\$${goal.requiredMonthlyContribution.toStringAsFixed(2)}',
              ),

            // Description
            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                goal.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Tags
            if (goal.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: goal.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionHistory(
    BuildContext context,
    AsyncValue<List<dynamic>> contributionsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Contribution History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to full contribution list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all contributions - Coming soon!')),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        contributionsAsync.when(
          data: (contributions) {
            if (contributions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timeline_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No contributions yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start contributing to reach your goal',
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

            // Show only recent 10 contributions
            final recentContributions = contributions.take(10).toList();

            return Column(
              children: recentContributions.map((contribution) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: contribution.amount > 0
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        contribution.amount > 0 ? Icons.add : Icons.remove,
                        color: contribution.amount > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      contribution.formattedAmount,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: contribution.amount > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('MMM dd, yyyy').format(contribution.date)),
                        if (contribution.note != null && contribution.note!.isNotEmpty)
                          Text(contribution.note!),
                      ],
                    ),
                    trailing: Text(
                      contribution.type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Failed to load contributions: $error'),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
    String action,
  ) {
    switch (action) {
      case 'edit':
        _showEditGoalSheet(context, ref, goal);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, goal);
        break;
    }
  }

  Future<void> _showAddContributionSheet(BuildContext context, WidgetRef ref) async {
    await AppBottomSheet.show(
      context: context,
      child: AddContributionBottomSheet(
        goalId: widget.goalId,
        onSubmit: (contribution) async {
          final success = await ref
              .read(goalNotifierProvider.notifier)
              .addContribution(widget.goalId, contribution);

          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contribution added successfully')),
            );
          }
        },
      ),
    );
  }

  Future<void> _showEditGoalSheet(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    final result = await AppBottomSheet.show<bool>(
      context: context,
      child: EditGoalBottomSheet(goal: goal),
    );

    if (result == true && mounted) {
      ref.invalidate(goalProvider(widget.goalId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal updated successfully')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
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

    if (confirmed == true) {
      final success = await ref
          .read(goalNotifierProvider.notifier)
          .deleteGoal(goal.id);

      if (success && mounted) {
        context.go('/goals'); // Go back to goals list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal deleted successfully')),
        );
      }
    }
  }
}