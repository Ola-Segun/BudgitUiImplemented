import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../features/goals/domain/entities/goal.dart';
import '../../../features/goals/domain/entities/goal_contribution.dart';
import '../../../features/goals/presentation/providers/goal_providers.dart';
import '../../../features/transactions/domain/entities/transaction.dart';
import 'modern_design_constants.dart';

/// Modern goal allocation selector widget
/// Provides toggle-based goal allocation with modern design
class ModernGoalAllocationSelector extends ConsumerStatefulWidget {
  final double transactionAmount;
  final TransactionType transactionType;
  final ValueChanged<List<GoalContribution>> onAllocationsChanged;

  const ModernGoalAllocationSelector({
    super.key,
    required this.transactionAmount,
    required this.transactionType,
    required this.onAllocationsChanged,
  });

  @override
  ConsumerState<ModernGoalAllocationSelector> createState() => _ModernGoalAllocationSelectorState();
}

class _ModernGoalAllocationSelectorState extends ConsumerState<ModernGoalAllocationSelector> {
  final ValueNotifier<List<GoalContribution>> _allocations = ValueNotifier([]);
  final ValueNotifier<int> _retryCount = ValueNotifier(0);
  bool _allocationEnabled = false;

  @override
  void dispose() {
    _allocations.dispose();
    _retryCount.dispose();
    super.dispose();
  }

  void _toggleGoalAllocation(Goal goal) {
    final currentAllocations = _allocations.value;
    final existingAllocation = currentAllocations.where((a) => a.goalId == goal.id).firstOrNull;

    if (existingAllocation != null) {
      // Remove allocation
      _allocations.value = currentAllocations.where((a) => a.goalId != goal.id).toList();
    } else {
      // Add allocation with smart amount
      final suggestedAmount = _calculateSuggestedAmount(goal);
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

  double _calculateSuggestedAmount(Goal goal) {
    final remaining = goal.targetAmount - goal.currentAmount;
    // Suggest 10% of transaction amount or remaining goal amount, whichever is smaller
    return min(widget.transactionAmount * 0.1, remaining).clamp(0.0, widget.transactionAmount);
  }

  void _updateAllocationAmount(String goalId, double amount) {
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

  void _onAllocationToggleChanged(bool enabled) {
    setState(() {
      _allocationEnabled = enabled;
      if (!enabled) {
        // Clear all allocations when disabled
        _allocations.value = [];
      }
    });
    widget.onAllocationsChanged(_allocations.value);
  }

  @override
  Widget build(BuildContext context) {
    // Only show for income transactions
    if (widget.transactionType != TransactionType.income) {
      return const SizedBox.shrink();
    }

    // Only show if amount is valid and positive
    if (widget.transactionAmount <= 0) {
      return const SizedBox.shrink();
    }

    final eligibleGoalsAsync = ref.watch(eligibleGoalsForAllocationProvider((
      transactionAmount: widget.transactionAmount,
      transactionType: widget.transactionType,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: spacing_md),
          child: Row(
            children: [
              Icon(
                Icons.flag_rounded,
                color: ModernColors.accentGreen,
                size: 20,
              ),
              const SizedBox(width: spacing_sm),
              Text(
                'Include in Goals',
                style: ModernTypography.bodyLarge.copyWith(
                  color: ModernColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Switch(
                value: _allocationEnabled,
                onChanged: _onAllocationToggleChanged,
                activeThumbColor: ModernColors.accentGreen,
                activeTrackColor: ModernColors.accentGreen.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),

        // Goals list (only show when allocation is enabled)
        if (_allocationEnabled) ...[
          eligibleGoalsAsync.when(
            data: (goals) {
              if (goals.isEmpty) {
                return _buildNoGoalsState();
              }

              return Column(
                children: [
                  // Goal cards
                  ...goals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: spacing_sm),
                    child: _GoalAllocationCard(
                      goal: goal,
                      transactionAmount: widget.transactionAmount,
                      allocation: _allocations.value.where((a) => a.goalId == goal.id).firstOrNull,
                      onToggle: () => _toggleGoalAllocation(goal),
                      onAmountChanged: (amount) => _updateAllocationAmount(goal.id, amount),
                      onRemove: () => _removeAllocation(goal.id),
                    ),
                  )),

                  // Allocation summary
                  if (_allocations.value.isNotEmpty) ...[
                    const SizedBox(height: spacing_md),
                    _AllocationSummary(
                      transactionAmount: widget.transactionAmount,
                      allocations: _allocations.value,
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => _buildErrorState(error, stack),
          ),
        ],
      ],
    );
  }

  Widget _buildNoGoalsState() {
    return Container(
      padding: const EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightSurface,
        borderRadius: BorderRadius.circular(radius_md),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: ModernColors.textSecondary,
          ),
          const SizedBox(height: spacing_md),
          Text(
            'No active goals yet',
            style: ModernTypography.bodyLarge.copyWith(
              color: ModernColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: spacing_sm),
          Text(
            'Create savings goals to start allocating income automatically.',
            style: ModernTypography.bodyLarge.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, StackTrace stack) {
    return Container(
      padding: const EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(radius_md),
        border: Border.all(color: ModernColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: ModernColors.error,
          ),
          const SizedBox(height: spacing_md),
          Text(
            'Failed to load goals',
            style: ModernTypography.bodyLarge.copyWith(
              color: ModernColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: spacing_sm),
          Text(
            'Please try again or check your connection.',
            style: ModernTypography.bodyLarge.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: spacing_md),
          OutlinedButton.icon(
            onPressed: _retryLoadGoals,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ModernColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual goal allocation card - Compact design
class _GoalAllocationCard extends StatefulWidget {
  final Goal goal;
  final double transactionAmount;
  final GoalContribution? allocation;
  final VoidCallback onToggle;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onRemove;

  const _GoalAllocationCard({
    required this.goal,
    required this.transactionAmount,
    required this.allocation,
    required this.onToggle,
    required this.onAmountChanged,
    required this.onRemove,
  });

  @override
  State<_GoalAllocationCard> createState() => _GoalAllocationCardState();
}

class _GoalAllocationCardState extends State<_GoalAllocationCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernAnimations.normal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _backgroundAnimation = ColorTween(
      begin: ModernColors.primaryGray,
      end: ModernColors.accentGreen.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _amountController = TextEditingController(
      text: widget.allocation?.amount.toStringAsFixed(0) ?? '0',
    );

    if (widget.allocation != null) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_GoalAllocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allocation != widget.allocation) {
      if (widget.allocation != null) {
        _animationController.forward();
        _amountController.text = widget.allocation!.amount.toStringAsFixed(0);
      } else {
        _animationController.reverse();
        _amountController.text = '0';
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isAllocated = widget.allocation != null;
    final progress = widget.goal.targetAmount > 0 ? widget.goal.currentAmount / widget.goal.targetAmount : 0.0;

    return Semantics(
      label: '${widget.goal.title} goal, ${(progress * 100).toInt()}% complete',
      value: isAllocated ? 'allocated' : 'not allocated',
      button: true,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main compact card
                GestureDetector(
                  onTap: _handleTap,
                  child: Container(
                    height: 48, // Compact height like other form fields
                    padding: const EdgeInsets.symmetric(horizontal: spacing_md, vertical: spacing_sm),
                    decoration: BoxDecoration(
                      color: _backgroundAnimation.value ?? ModernColors.primaryGray,
                      borderRadius: BorderRadius.circular(radius_md),
                    ),
                    child: Row(
                      children: [
                        // Icon prefix
                        Icon(
                          Icons.flag_rounded, // Using flag icon for goals
                          size: 20,
                          color: isAllocated ? ModernColors.accentGreen : ModernColors.textSecondary,
                        ),
                        const SizedBox(width: spacing_sm),

                        // Goal title
                        Expanded(
                          child: Text(
                            widget.goal.title,
                            style: ModernTypography.bodyLarge.copyWith(
                              color: ModernColors.textPrimary,
                              fontWeight: isAllocated ? FontWeight.w600 : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Progress percentage
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: ModernTypography.labelMedium.copyWith(
                            color: isAllocated ? ModernColors.accentGreen : ModernColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: spacing_sm),

                        // Selection indicator
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAllocated ? ModernColors.accentGreen : ModernColors.lightSurface,
                            border: Border.all(
                              color: isAllocated ? ModernColors.accentGreen : ModernColors.borderColor,
                              width: 2,
                            ),
                          ),
                          child: isAllocated
                              ? const Icon(Icons.check, size: 12, color: ModernColors.lightBackground)
                              : null,
                        ),

                        // Remove button (only when allocated)
                        if (isAllocated) ...[
                          const SizedBox(width: spacing_xs),
                          IconButton(
                            icon: Icon(Icons.close, size: 16, color: ModernColors.textSecondary),
                            onPressed: widget.onRemove,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Compact amount input with percentage display (only when allocated)
                if (isAllocated) ...[
                  const SizedBox(height: spacing_xs),
                  Container(
                    height: 38,
                    margin: const EdgeInsets.only(left: spacing_lg, right: spacing_md),
                    padding: const EdgeInsets.symmetric(horizontal: spacing_md),
                    decoration: BoxDecoration(
                      color: ModernColors.lightSurface,
                      borderRadius: BorderRadius.circular(radius_sm),
                      border: Border.all(color: ModernColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        // Dollar amount input
                        Text(
                          '\$',
                          style: ModernTypography.bodyLarge.copyWith(
                            color: ModernColors.textSecondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 25,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: ModernTypography.bodyLarge.copyWith(
                              color: ModernColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 25,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              hintText: '0',
                            ),
                            onChanged: (value) {
                              // Allow empty string or valid decimal numbers
                              if (value.isEmpty) {
                                widget.onAmountChanged(0.0);
                              } else {
                                final amount = double.tryParse(value);
                                if (amount != null && amount >= 0) {
                                  widget.onAmountChanged(amount);
                                }
                              }
                            },
                          ),
                        ),

                        // Percentage display - calculate from current input value
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _amountController,
                          builder: (context, textValue, child) {
                            final currentAmount = double.tryParse(textValue.text) ?? 0.0;
                            final percentage = widget.transactionAmount > 0
                                ? (currentAmount / widget.transactionAmount) * 100
                                : 0.0;
                            return Container(
                              padding: const EdgeInsets.only(left: spacing_xs),
                              child: Text(
                                '(${percentage.toStringAsFixed(1)}%)',
                                style: ModernTypography.labelMedium.copyWith(
                                  color: ModernColors.accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.all(spacing_md),
      decoration: BoxDecoration(
        color: ModernColors.lightSurface,
        borderRadius: BorderRadius.circular(radius_md),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction amount',
                style: ModernTypography.bodyLarge.copyWith(
                  color: ModernColors.textSecondary,
                ),
              ),
              Text(
                '\$${transactionAmount.toStringAsFixed(2)}',
                style: ModernTypography.bodyLarge.copyWith(
                  color: ModernColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: spacing_xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To ${allocations.length} goal${allocations.length > 1 ? 's' : ''}',
                style: ModernTypography.bodyLarge.copyWith(
                  color: ModernColors.accentGreen,
                ),
              ),
              Text(
                '\$${totalAllocated.toStringAsFixed(2)}',
                style: ModernTypography.bodyLarge.copyWith(
                  color: ModernColors.accentGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: spacing_md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining',
                style: ModernTypography.bodyLarge.copyWith(
                  color: ModernColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${remaining.toStringAsFixed(2)}',
                style: ModernTypography.bodyLarge.copyWith(
                  color: remaining >= 0 ? ModernColors.textPrimary : ModernColors.error,
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
