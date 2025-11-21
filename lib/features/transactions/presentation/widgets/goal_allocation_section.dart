import 'package:flutter/material.dart';

import '../../../../core/design_system/modern/modern_goal_allocation_selector.dart';
import '../../../goals/domain/entities/goal_contribution.dart';
import '../../domain/entities/transaction.dart';

/// Goal allocation section for transaction forms
/// Uses the modern compact goal allocation selector component
class GoalAllocationSection extends StatelessWidget {
  final double transactionAmount;
  final TransactionType transactionType;
  final ValueChanged<List<GoalContribution>> onAllocationsChanged;

  const GoalAllocationSection({
    super.key,
    required this.transactionAmount,
    required this.transactionType,
    required this.onAllocationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ModernGoalAllocationSelector(
      transactionAmount: transactionAmount,
      transactionType: transactionType,
      onAllocationsChanged: onAllocationsChanged,
    );
  }
}