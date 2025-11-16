import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/design_system/typography_tokens.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/inputs/currency_input.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/domain/entities/goal_contribution.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../domain/entities/transaction.dart';

/// Goal allocation section for transaction forms
/// Allows users to allocate portions of income transactions to savings goals
class GoalAllocationSection extends ConsumerStatefulWidget {
  final double transactionAmount;
  final TransactionType transactionType;
  final ValueChanged<List<GoalContribution>> onAllocationsChanged;

  const GoalAllocationSection({
    Key? key,
    required this.transactionAmount,
    required this.transactionType,
    required this.onAllocationsChanged,
  }) : super(key: key);

  @override
  ConsumerState<GoalAllocationSection> createState() => _GoalAllocationSectionState();
}

class _GoalAllocationSectionState extends ConsumerState<GoalAllocationSection> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);
  final ValueNotifier<List<GoalContribution>> _allocations = ValueNotifier([]);
  final ValueNotifier<int> _retryCount = ValueNotifier(0);

  @override
  void dispose() {
    _isExpanded.dispose();
    _allocations.dispose();
    _retryCount.dispose();
    super.dispose();
  }

  void _toggleGoalSelection(Goal goal, double maxAmount) {
    final currentAllocations = _allocations.value;
    final existingAllocation = currentAllocations.where((a) => a.goalId == goal.id).firstOrNull;

    if (existingAllocation != null) {
      // Remove allocation
      _allocations.value = currentAllocations.where((a) => a.goalId != goal.id).toList();
    } else {
      // Add allocation with suggested amount
      final suggestedAmount = _calculateSuggestedAmount(goal, maxAmount);
      final newAllocation = GoalContribution(
        id: const Uuid().v4(),
        goalId: goal.id,
        amount: suggestedAmount,
        date: DateTime.now(),
      );
      _allocations.value = [...currentAllocations, newAllocation];
    }

    widget.onAllocationsChanged(_allocations.value);
  }

  double _calculateSuggestedAmount(Goal goal, double maxAmount) {
    final remaining = goal.targetAmount - goal.currentAmount;
    // Prevent over-allocation and ensure positive amounts
    return min(maxAmount * 0.1, remaining).clamp(0.0, maxAmount);
  }

  void _updateAllocation(String goalId, double amount) {
    // Prevent negative amounts and over-allocation
    final clampedAmount = amount.clamp(0.0, widget.transactionAmount);

    final updatedAllocations = _allocations.value.map((allocation) {
      if (allocation.goalId == goalId) {
        return allocation.copyWith(amount: clampedAmount);
      }
      return allocation;
    }).toList();

    _allocations.value = updatedAllocations;
    widget.onAllocationsChanged(updatedAllocations);
  }

  void _removeAllocation(String goalId) {
    _allocations.value = _allocations.value.where((a) => a.goalId != goalId).toList();
    widget.onAllocationsChanged(_allocations.value);
  }

  void _retryLoadGoals() {
    setState(() {
      _retryCount.value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only show for income transactions
    if (widget.transactionType != TransactionType.income) {
      return const SizedBox.shrink();
    }

    // Use a key to force rebuild on retry
    final eligibleGoalsAsync = ref.watch(eligibleGoalsForAllocationProvider((
      transactionAmount: widget.transactionAmount,
      transactionType: widget.transactionType,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with expand/collapse
        InkWell(
          onTap: () => _isExpanded.value = !_isExpanded.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const Gap(8),
                Text(
                  'Allocate to goals',
                  style: TypographyTokens.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<List<GoalContribution>>(
                  valueListenable: _allocations,
                  builder: (context, allocations, _) {
                    if (allocations.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${allocations.length} goal${allocations.length > 1 ? 's' : ''}',
                          style: TypographyTokens.labelSm.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const Gap(8),
                ValueListenableBuilder<bool>(
                  valueListenable: _isExpanded,
                  builder: (context, isExpanded, _) {
                    return Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Expandable content
        ValueListenableBuilder<bool>(
          valueListenable: _isExpanded,
          builder: (context, isExpanded, _) {
            if (!isExpanded) return const SizedBox.shrink();

            return Column(
              children: [
                const Gap(12),
                eligibleGoalsAsync.when(
                  data: (goals) {
                    if (goals.isEmpty) {
                      return _NoGoalsPrompt(
                        onCreateGoal: () => _showCreateGoalSheet(context),
                      );
                    }

                    return Column(
                      children: [
                        // Goal selection chips
                        ValueListenableBuilder<List<GoalContribution>>(
                          valueListenable: _allocations,
                          builder: (context, allocations, _) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: goals.map((goal) {
                                final isSelected = allocations.any((a) => a.goalId == goal.id);
                                return _GoalSelectionChip(
                                  goal: goal,
                                  isSelected: isSelected,
                                  onTap: () => _toggleGoalSelection(goal, widget.transactionAmount),
                                );
                              }).toList(),
                            );
                          },
                        ),

                        const Gap(16),

                        // Allocation inputs for selected goals
                        ValueListenableBuilder<List<GoalContribution>>(
                          valueListenable: _allocations,
                          builder: (context, allocations, _) {
                            return Column(
                              children: allocations.map((allocation) {
                                final goal = goals.firstWhere(
                                  (g) => g.id == allocation.goalId,
                                  orElse: () => goals.first, // Fallback to prevent crashes
                                );
                                return _GoalAllocationInput(
                                  goal: goal,
                                  allocation: allocation,
                                  maxAmount: widget.transactionAmount,
                                  onAmountChanged: (amount) => _updateAllocation(allocation.goalId, amount),
                                  onRemove: () => _removeAllocation(allocation.goalId),
                                );
                              }).toList(),
                            );
                          },
                        ),

                        const Gap(12),

                        // Total allocation summary
                        ValueListenableBuilder<List<GoalContribution>>(
                          valueListenable: _allocations,
                          builder: (context, allocations, _) {
                            return _AllocationSummary(
                              transactionAmount: widget.transactionAmount,
                              allocations: allocations,
                            );
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading goals...'),
                        ],
                      ),
                    ),
                  ),
                  error: (error, stack) => _GoalsErrorWidget(
                    error: error,
                    stackTrace: stack,
                    onRetry: _retryLoadGoals,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showCreateGoalSheet(BuildContext context) {
    // TODO: Navigate to goal creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal creation not implemented yet')),
    );
  }
}

/// Widget to display when goals fail to load
class _GoalsErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final VoidCallback onRetry;

  const _GoalsErrorWidget({
    required this.error,
    required this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkError = error.toString().contains('Connection') || 
                          error.toString().contains('Network') ||
                          error.toString().contains('timeout');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const Gap(12),
          Text(
            'Failed to load goals',
            style: TypographyTokens.bodyLg.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const Gap(8),
          Text(
            _getErrorMessage(),
            style: TypographyTokens.bodyMd.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              const Gap(8),
              TextButton(
                onPressed: () => _showErrorDetails(context),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getErrorMessage() {
    final errorStr = error.toString();
    if (errorStr.contains('Connection') || errorStr.contains('Network')) {
      return 'Unable to connect to load goals. Please check your connection and try again.';
    } else if (errorStr.contains('timeout')) {
      return 'Loading goals is taking too long. Please try again.';
    } else if (errorStr.contains('permission') || errorStr.contains('storage')) {
      return 'Unable to access storage. Please check app permissions.';
    } else if (errorStr.contains('circular')) {
      return 'System initialization issue. Please restart the app.';
    } else {
      return errorStr.length > 100 
          ? '${errorStr.substring(0, 100)}...'
          : errorStr;
    }
  }

  void _showErrorDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Error Type: ${error.runtimeType}',
                style: TypographyTokens.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Message: $error',
                style: TypographyTokens.bodySm,
              ),
              const SizedBox(height: 16),
              Text(
                'Stack Trace:',
                style: TypographyTokens.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  stackTrace.toString(),
                  style: TypographyTokens.bodyXs.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Goal selection chip widget
class _GoalSelectionChip extends StatelessWidget {
  final Goal goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalSelectionChip({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(goal.title),
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: Icon(
        Icons.flag_rounded,
        size: 16,
        color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      labelStyle: TypographyTokens.labelSm.copyWith(
        color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Individual goal allocation input widget
class _GoalAllocationInput extends StatelessWidget {
  final Goal goal;
  final GoalContribution allocation;
  final double maxAmount;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onRemove;

  const _GoalAllocationInput({
    required this.goal,
    required this.allocation,
    required this.maxAmount,
    required this.onAmountChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal.targetAmount - goal.currentAmount;
    final suggestedAmount = min(maxAmount * 0.1, remaining).clamp(0.0, maxAmount);

    // Check for validation errors
    final hasOverAllocation = allocation.amount > maxAmount;
    final exceedsGoalRemaining = allocation.amount > remaining;
    final isZeroAmount = allocation.amount <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Goal icon with error state
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (hasOverAllocation || exceedsGoalRemaining || isZeroAmount)
                        ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: (hasOverAllocation || exceedsGoalRemaining || isZeroAmount)
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const Gap(12),

                // Goal info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TypographyTokens.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Need: \$${remaining.toStringAsFixed(0)} more',
                        style: TypographyTokens.bodySm.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Show error messages
                      if (hasOverAllocation)
                        Text(
                          'Amount exceeds transaction limit',
                          style: TypographyTokens.labelSm.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      else if (exceedsGoalRemaining)
                        Text(
                          'Amount exceeds goal remaining',
                          style: TypographyTokens.labelSm.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      else if (isZeroAmount)
                        Text(
                          'Amount must be greater than zero',
                          style: TypographyTokens.labelSm.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),

                // Remove button
                IconButton(
                  icon: Icon(Icons.close_rounded),
                  iconSize: 20,
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const Gap(12),

            // Amount input
            Row(
              children: [
                Expanded(
                  child: CurrencyInput(
                    label: 'Amount to contribute',
                    controller: TextEditingController(text: allocation.amount.toStringAsFixed(2)),
                    onChanged: (value) => onAmountChanged(value ?? 0),
                    errorText: hasOverAllocation
                        ? 'Exceeds transaction amount'
                        : exceedsGoalRemaining
                            ? 'Exceeds goal remaining'
                            : isZeroAmount
                                ? 'Must be greater than zero'
                                : null,
                  ),
                ),
                const Gap(12),

                // Quick action buttons
                Column(
                  children: [
                    _QuickAmountButton(
                      label: 'Suggested',
                      amount: suggestedAmount,
                      onTap: () => onAmountChanged(suggestedAmount),
                      enabled: suggestedAmount > 0,
                    ),
                    const Gap(4),
                    _QuickAmountButton(
                      label: 'All needed',
                      amount: min(remaining, maxAmount),
                      onTap: () => onAmountChanged(min(remaining, maxAmount)),
                      enabled: remaining > 0,
                    ),
                  ],
                ),
              ],
            ),

            const Gap(12),

            // Progress preview (only show if valid amount)
            if (!hasOverAllocation && !exceedsGoalRemaining && !isZeroAmount)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'After contribution:',
                    style: TypographyTokens.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(4),
                  LinearProgressIndicator(
                    value: (goal.currentAmount + allocation.amount) / goal.targetAmount,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const Gap(4),
                  Text(
                    '${((goal.currentAmount + allocation.amount) / goal.targetAmount * 100).toStringAsFixed(1)}% complete',
                    style: TypographyTokens.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Quick amount selection button
class _QuickAmountButton extends StatelessWidget {
  final String label;
  final double amount;
  final VoidCallback onTap;
  final bool enabled;

  const _QuickAmountButton({
    required this.label,
    required this.amount,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(0, 32),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TypographyTokens.labelSm.copyWith(
                color: enabled ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '\$${amount.toStringAsFixed(0)}',
              style: TypographyTokens.labelSm.copyWith(
                fontWeight: FontWeight.w600,
                color: enabled ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Allocation summary widget
class _AllocationSummary extends StatelessWidget {
  final double transactionAmount;
  final List<GoalContribution> allocations;

  const _AllocationSummary({
    required this.transactionAmount,
    required this.allocations,
  });

  @override
  Widget build(BuildContext context) {
    final totalAllocated = allocations.fold<double>(0, (sum, a) => sum + a.amount);
    final remaining = transactionAmount - totalAllocated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Transaction amount',
            amount: transactionAmount,
            style: TypographyTokens.bodyMd,
          ),
          const Gap(8),
          _SummaryRow(
            label: 'To goals (${allocations.length})',
            amount: totalAllocated,
            style: TypographyTokens.bodyMd.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(height: 16),
          _SummaryRow(
            label: 'Remaining',
            amount: remaining,
            style: TypographyTokens.bodyLg.copyWith(
              fontWeight: FontWeight.w600,
            ),
            showWarning: remaining < 0,
          ),
        ],
      ),
    );
  }
}

/// Summary row widget
class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final TextStyle style;
  final bool showWarning;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.style,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: style.copyWith(
            color: showWarning ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ],
    );
  }
}

/// No goals prompt widget
class _NoGoalsPrompt extends StatelessWidget {
  final VoidCallback onCreateGoal;

  const _NoGoalsPrompt({required this.onCreateGoal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const Gap(12),
          Text(
            'No active goals yet',
            style: TypographyTokens.bodyLg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            'Create your first savings goal to start allocating income automatically.',
            style: TypographyTokens.bodyMd.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          OutlinedButton.icon(
            onPressed: onCreateGoal,
            icon: const Icon(Icons.add),
            label: const Text('Create Goal'),
          ),
        ],
      ),
    );
  }
}