import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';
import '../widgets/budget_edit_bottom_sheet.dart';

/// Card widget for displaying budget information
class BudgetCard extends ConsumerWidget {
  const BudgetCard({
    super.key,
    required this.budget,
    this.status,
    this.onTap,
  });

  final Budget budget;
  final BudgetStatus? status;
  final VoidCallback? onTap;

  Color _getHealthColor(BudgetHealth health) {
    switch (health) {
      case BudgetHealth.healthy:
        return const Color(0xFF10B981); // Green
      case BudgetHealth.warning:
        return const Color(0xFFF59E0B); // Yellow
      case BudgetHealth.critical:
        return const Color(0xFFEF4444); // Red
      case BudgetHealth.overBudget:
        return const Color(0xFFDC2626); // Dark Red
    }
  }

  void _editBudget(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    // Show edit budget bottom sheet
    BudgetEditBottomSheet.show(
      context: context,
      budget: budget,
      onSubmit: (updatedBudget) async {
        await ref
            .read(budgetNotifierProvider.notifier)
            .updateBudget(updatedBudget);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget updated successfully')),
          );
        }
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete "${budget.name}"?',
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
          .read(budgetNotifierProvider.notifier)
          .deleteBudget(budget.id);

      if (success && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Budget deleted')),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = status != null ? status!.totalSpent / status!.totalBudget : 0.0;
    final health = status?.overallHealth ?? BudgetHealth.healthy;

    return Slidable(
      key: ValueKey(budget.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // Delete action (red)
          SlidableAction(
            onPressed: (_) => _confirmDelete(context, ref),
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            autoClose: true,
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // Edit action (blue)
          SlidableAction(
            onPressed: (_) => _editBudget(context, ref),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            autoClose: true,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          budget.type.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getHealthColor(health).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      health.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getHealthColor(health),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Bar
              if (status != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0.0,
                          end: progress.clamp(0.0, 1.0),
                        ),
                        duration: AppAnimations.normal,
                        curve: AppAnimations.easeOut,
                        builder: (context, animatedProgress, child) {
                          return LinearProgressIndicator(
                            value: animatedProgress,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(health)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.0,
                        end: progress,
                      ),
                      duration: AppAnimations.normal,
                      curve: AppAnimations.easeOut,
                      builder: (context, animatedProgress, child) {
                        return Text(
                          '${(animatedProgress * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Amount Details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spent',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(
                            NumberFormat.currency(symbol: '\$').format(status!.totalSpent),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _getHealthColor(health),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Budget',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(
                            NumberFormat.currency(symbol: '\$').format(status!.totalBudget),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Remaining/Over budget
                Row(
                  children: [
                    Icon(
                      status!.remainingAmount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 16,
                      color: status!.remainingAmount >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status!.remainingAmount >= 0
                          ? '${NumberFormat.currency(symbol: '\$').format(status!.remainingAmount)} remaining'
                          : '${NumberFormat.currency(symbol: '\$').format(-status!.remainingAmount)} over budget',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: status!.remainingAmount >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${status!.daysRemaining} days left',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ] else ...[
                // No status available
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No spending data available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Date Range
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('MMM dd').format(budget.startDate)} - ${DateFormat('MMM dd, yyyy').format(budget.endDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }
}