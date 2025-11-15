Comprehensive Implementation Analysis: Integrating Goal Contributions via Add Transaction
Executive Summary
This guide provides a complete implementation strategy for allowing users to contribute to savings goals directly through the transaction creation flow. This creates a seamless experience where adding a transaction can simultaneously track spending/income and contribute to goal progress.

1. Product Analysis & User Experience Design
1.1 User Stories
Primary User Story:

"As a user, when I receive my paycheck, I want to allocate $200 to my 'Emergency Fund' goal directly while recording the income transaction, so I don't have to perform two separate actions."

Secondary User Stories:

"As a user, I want to see which goals I can contribute to when adding a transaction"
"As a user, I want to split a single transaction across multiple goals"
"As a user, I want the app to suggest goal contributions based on my budget"
"As a user, I want to see my goal progress update immediately after contributing"

1.2 UX Flow Design
Add Transaction Flow (Enhanced)
================================

1. User taps "Add Transaction"
   ↓
2. Bottom sheet appears with transaction form
   ↓
3. User enters amount: $1,000 (Income - Salary)
   ↓
4. User selects category: "Income > Salary"
   ↓
5. [NEW] Goal Contribution Section appears
   - Shows: "Allocate to goals?" (collapsible)
   - If expanded, shows eligible goals
   ↓
6. User selects "Emergency Fund" goal
   ↓
7. [NEW] Allocation interface shows:
   - Slider/Input: How much to allocate?
   - Default: Suggested amount based on goal target
   - Shows: Remaining after allocation
   ↓
8. User allocates $200 to Emergency Fund
   ↓
9. [NEW] Summary shows:
   - Transaction: $1,000 (Income)
   - Goal contribution: $200 → Emergency Fund
   - Net remaining: $800
   ↓
10. User taps "Save"
    ↓
11. Success feedback:
    - "Transaction added!"
    - "Emergency Fund: $200 contributed! (Progress: 65%)"
    - Celebratory animation if milestone reached
1.3 UI Component Design
dart// lib/features/transactions/presentation/widgets/goal_allocation_section.dart

class GoalAllocationSection extends ConsumerWidget {
  final double transactionAmount;
  final TransactionType transactionType;
  final ValueChanged<List<GoalContribution>> onAllocationsChanged;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eligibleGoals = ref.watch(eligibleGoalsForAllocationProvider);
    final allocations = useState<List<GoalContribution>>([]);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with expand/collapse
        InkWell(
          onTap: () => isExpanded.value = !isExpanded.value,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: AppColors.primary,
                  size: AppDimensions.iconSm,
                ),
                Gap(AppSpacing.sm),
                Text(
                  'Allocate to goals',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                if (allocations.value.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${allocations.value.length} goal${allocations.value.length > 1 ? 's' : ''}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Gap(AppSpacing.sm),
                Icon(
                  isExpanded.value 
                    ? Icons.keyboard_arrow_up_rounded 
                    : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        
        // Expandable content
        if (isExpanded.value) ...[
          Gap(AppSpacing.md),
          
          eligibleGoals.when(
            data: (goals) {
              if (goals.isEmpty) {
                return _NoGoalsPrompt(
                  onCreateGoal: () => context.push('/goals/create'),
                );
              }
              
              return Column(
                children: [
                  // Goal selection chips
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: goals.map((goal) {
                      final isSelected = allocations.value
                          .any((a) => a.goalId == goal.id);
                      
                      return _GoalSelectionChip(
                        goal: goal,
                        isSelected: isSelected,
                        onTap: () => _toggleGoalSelection(
                          goal,
                          allocations,
                          transactionAmount,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  Gap(AppSpacing.lg),
                  
                  // Allocation inputs for selected goals
                  ...allocations.value.map((allocation) {
                    final goal = goals.firstWhere(
                      (g) => g.id == allocation.goalId,
                    );
                    
                    return _GoalAllocationInput(
                      goal: goal,
                      allocation: allocation,
                      maxAmount: transactionAmount,
                      onAmountChanged: (amount) {
                        _updateAllocation(
                          allocations,
                          allocation.goalId,
                          amount,
                        );
                        onAllocationsChanged(allocations.value);
                      },
                      onRemove: () {
                        allocations.value = allocations.value
                            .where((a) => a.goalId != allocation.goalId)
                            .toList();
                        onAllocationsChanged(allocations.value);
                      },
                    );
                  }).toList(),
                  
                  Gap(AppSpacing.md),
                  
                  // Total allocation summary
                  _AllocationSummary(
                    transactionAmount: transactionAmount,
                    allocations: allocations.value,
                  ),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Text(
              'Failed to load goals',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GoalAllocationInput extends StatelessWidget {
  final Goal goal;
  final GoalContribution allocation;
  final double maxAmount;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onRemove;
  
  @override
  Widget build(BuildContext context) {
    final remaining = goal.targetAmount - goal.currentAmount;
    final suggestedAmount = min(maxAmount * 0.1, remaining);
    
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Goal icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  goal.icon,
                  color: AppColors.primary,
                  size: AppDimensions.iconSm,
                ),
              ),
              Gap(AppSpacing.md),
              
              // Goal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(AppSpacing.xs),
                    Text(
                      'Need: \$${remaining.toStringAsFixed(0)} more',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Remove button
              IconButton(
                icon: Icon(Icons.close_rounded),
                iconSize: AppDimensions.iconSm,
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          
          Gap(AppSpacing.md),
          
          // Amount input
          Row(
            children: [
              Expanded(
                child: CurrencyInputField(
                  label: 'Amount to contribute',
                  controller: TextEditingController(
                    text: allocation.amount.toStringAsFixed(2),
                  ),
                  onChanged: onAmountChanged,
                  errorText: allocation.amount > maxAmount
                      ? 'Exceeds transaction amount'
                      : null,
                ),
              ),
              Gap(AppSpacing.md),
              
              // Quick action buttons
              Column(
                children: [
                  _QuickAmountButton(
                    label: 'Suggested',
                    amount: suggestedAmount,
                    onTap: () => onAmountChanged(suggestedAmount),
                  ),
                  Gap(AppSpacing.xs),
                  _QuickAmountButton(
                    label: 'All needed',
                    amount: min(remaining, maxAmount),
                    onTap: () => onAmountChanged(min(remaining, maxAmount)),
                  ),
                ],
              ),
            ],
          ),
          
          Gap(AppSpacing.md),
          
          // Progress preview
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'After contribution:',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Gap(AppSpacing.xs),
              LinearProgressIndicator(
                value: (goal.currentAmount + allocation.amount) / 
                       goal.targetAmount,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(AppColors.success),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              Gap(AppSpacing.xs),
              Text(
                '${((goal.currentAmount + allocation.amount) / goal.targetAmount * 100).toStringAsFixed(1)}% complete',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 200.ms)
      .slideY(begin: 0.1, end: 0);
  }
}

class _AllocationSummary extends StatelessWidget {
  final double transactionAmount;
  final List<GoalContribution> allocations;
  
  @override
  Widget build(BuildContext context) {
    final totalAllocated = allocations.fold<double>(
      0,
      (sum, a) => sum + a.amount,
    );
    final remaining = transactionAmount - totalAllocated;
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: AppDimensions.borderRadiusMd,
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Transaction amount',
            amount: transactionAmount,
            style: AppTypography.bodyMedium,
          ),
          Gap(AppSpacing.sm),
          _SummaryRow(
            label: 'To goals (${allocations.length})',
            amount: totalAllocated,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          Divider(height: AppSpacing.lg),
          _SummaryRow(
            label: 'Remaining',
            amount: remaining,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            showWarning: remaining < 0,
          ),
        ],
      ),
    );
  }
}

2. Domain Layer Implementation
2.1 Domain Entities
dart// lib/features/goals/domain/entities/goal_contribution.dart

@freezed
class GoalContribution with _$GoalContribution {
  const factory GoalContribution({
    required String id,
    required String goalId,
    required double amount,
    required DateTime date,
    String? transactionId, // Link to source transaction
    String? note,
  }) = _GoalContribution;
  
  factory GoalContribution.fromJson(Map<String, dynamic> json) =>
      _$GoalContributionFromJson(json);
}

// lib/features/goals/domain/entities/goal.dart

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String name,
    required double targetAmount,
    required double currentAmount,
    required DateTime targetDate,
    required DateTime createdDate,
    required IconData icon,
    String? description,
    Color? color,
    GoalPriority? priority,
    @Default(false) bool isCompleted,
    @Default([]) List<GoalContribution> contributions,
  }) = _Goal;
  
  factory Goal.fromJson(Map<String, dynamic> json) =>
      _$GoalFromJson(json);
}

// Add computed properties
extension GoalExtensions on Goal {
  double get remainingAmount => targetAmount - currentAmount;
  
  double get percentageComplete => 
      (currentAmount / targetAmount * 100).clamp(0, 100);
  
  bool get isOnTrack {
    final daysElapsed = DateTime.now().difference(createdDate).inDays;
    final totalDays = targetDate.difference(createdDate).inDays;
    
    if (totalDays == 0) return currentAmount >= targetAmount;
    
    final expectedPercentage = (daysElapsed / totalDays) * 100;
    return percentageComplete >= expectedPercentage;
  }
  
  double get monthlyContributionNeeded {
    final remaining = targetAmount - currentAmount;
    final monthsLeft = targetDate.difference(DateTime.now()).inDays / 30;
    
    if (monthsLeft <= 0) return remaining;
    return remaining / monthsLeft;
  }
}

// lib/features/transactions/domain/entities/transaction.dart

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required double amount,
    required String categoryId,
    required DateTime date,
    required TransactionType type,
    String? description,
    String? note,
    String? receiptPath,
    List<String>? tags,
    @Default(false) bool isRecurring,
    
    // NEW: Goal allocations
    List<GoalContribution>? goalAllocations,
  }) = _Transaction;
  
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

extension TransactionExtensions on Transaction {
  double get totalGoalAllocations =>
      goalAllocations?.fold(0, (sum, a) => sum + a.amount) ?? 0;
  
  double get netAmount => amount - totalGoalAllocations;
  
  bool get hasGoalAllocations =>
      goalAllocations != null && goalAllocations!.isNotEmpty;
}
2.2 Repository Interfaces
dart// lib/features/goals/domain/repositories/goal_repository.dart

abstract class GoalRepository {
  Future<Result<List<Goal>>> getAll();
  Future<Result<Goal>> getById(String id);
  Future<Result<List<Goal>>> getActive(); // Not completed
  Future<Result<Goal>> create(Goal goal);
  Future<Result<Goal>> update(Goal goal);
  Future<Result<void>> delete(String id);
  
  // NEW: Contribution methods
  Future<Result<Goal>> addContribution(
    String goalId,
    GoalContribution contribution,
  );
  
  Future<Result<List<Goal>>> getEligibleForAllocation(
    double amount,
    TransactionType transactionType,
  );
}
2.3 Use Cases
dart// lib/features/transactions/domain/usecases/add_transaction_with_goal_allocation.dart

class AddTransactionWithGoalAllocation {
  final TransactionRepository _transactionRepository;
  final GoalRepository _goalRepository;
  final NotificationService _notificationService;
  
  AddTransactionWithGoalAllocation(
    this._transactionRepository,
    this._goalRepository,
    this._notificationService,
  );
  
  Future<Result<TransactionWithGoalUpdates>> call(
    Transaction transaction,
  ) async {
    // 1. Validate transaction
    final validationResult = _validateTransaction(transaction);
    if (validationResult != null) {
      return Result.error(validationResult);
    }
    
    // 2. Validate goal allocations
    if (transaction.hasGoalAllocations) {
      final allocationValidation = await _validateAllocations(transaction);
      if (allocationValidation != null) {
        return Result.error(allocationValidation);
      }
    }
    
    // 3. Add transaction
    final txResult = await _transactionRepository.add(transaction);
    if (txResult.isError) {
      return Result.error(txResult.failureOrNull!);
    }
    
    final addedTransaction = txResult.dataOrNull!;
    
    // 4. Process goal contributions
    final updatedGoals = <Goal>[];
    
    if (transaction.hasGoalAllocations) {
      for (final allocation in transaction.goalAllocations!) {
        // Link contribution to transaction
        final contributionWithTx = allocation.copyWith(
          transactionId: addedTransaction.id,
        );
        
        // Add contribution to goal
        final goalResult = await _goalRepository.addContribution(
          allocation.goalId,
          contributionWithTx,
        );
        
        if (goalResult.isSuccess) {
          final updatedGoal = goalResult.dataOrNull!;
          updatedGoals.add(updatedGoal);
          
          // Check for milestones
          await _checkMilestones(updatedGoal, allocation.amount);
        }
      }
    }
    
    return Result.success(
      TransactionWithGoalUpdates(
        transaction: addedTransaction,
        updatedGoals: updatedGoals,
      ),
    );
  }
  
  Failure? _validateTransaction(Transaction transaction) {
    if (transaction.amount <= 0) {
      return Failure.validation(
        'Amount must be greater than zero',
        {'amount': 'Must be positive'},
      );
    }
    
    // Validate allocations don't exceed transaction amount
    if (transaction.hasGoalAllocations) {
      final totalAllocated = transaction.totalGoalAllocations;
      if (totalAllocated > transaction.amount) {
        return Failure.validation(
          'Goal allocations exceed transaction amount',
          {
            'allocations': 'Total: \$$totalAllocated exceeds \$${transaction.amount}'
          },
        );
      }
    }
    
    return null;
  }
  
  Future<Failure?> _validateAllocations(Transaction transaction) async {
    for (final allocation in transaction.goalAllocations!) {
      // Check goal exists
      final goalResult = await _goalRepository.getById(allocation.goalId);
      
      if (goalResult.isError) {
        return Failure.validation(
          'Invalid goal reference',
          {'goal': 'Goal ${allocation.goalId} not found'},
        );
      }
      
      final goal = goalResult.dataOrNull!;
      
      // Check goal is not completed
      if (goal.isCompleted) {
        return Failure.validation(
          'Cannot contribute to completed goal',
          {'goal': '${goal.name} is already completed'},
        );
      }
      
      // Check allocation amount
      if (allocation.amount <= 0) {
        return Failure.validation(
          'Invalid allocation amount',
          {'amount': 'Must be greater than zero'},
        );
      }
    }
    
    return null;
  }
  
  Future<void> _checkMilestones(Goal goal, double contributionAmount) async {
    final previousPercentage = goal.percentageComplete - 
        (contributionAmount / goal.targetAmount * 100);
    
    final milestones = [25, 50, 75, 100];
    
    for (final milestone in milestones) {
      if (previousPercentage < milestone && 
          goal.percentageComplete >= milestone) {
        // Milestone reached!
        await _notificationService.sendGoalMilestone(
          goal: goal,
          milestone: milestone,
        );
        
        // Trigger celebration UI
        // (handled in presentation layer)
        break;
      }
    }
  }
}

// Result wrapper
@freezed
class TransactionWithGoalUpdates with _$TransactionWithGoalUpdates {
  const factory TransactionWithGoalUpdates({
    required Transaction transaction,
    required List<Goal> updatedGoals,
  }) = _TransactionWithGoalUpdates;
}

// lib/features/goals/domain/usecases/get_eligible_goals_for_allocation.dart

class GetEligibleGoalsForAllocation {
  final GoalRepository _repository;
  
  GetEligibleGoalsForAllocation(this._repository);
  
  Future<Result<List<Goal>>> call({
    required double amount,
    required TransactionType transactionType,
  }) async {
    // Get all active goals
    final result = await _repository.getActive();
    
    return result.when(
      success: (goals) {
        // Filter based on transaction type and other criteria
        final eligible = goals.where((goal) {
          // Only show for income or specific expense categories
          if (transactionType == TransactionType.expense) {
            return false; // Or allow for specific categories like "Savings"
          }
          
          // Don't show completed goals
          if (goal.isCompleted) {
            return false;
          }
          
          // Don't show if goal needs less than $1
          if (goal.remainingAmount < 1) {
            return false;
          }
          
          return true;
        }).toList();
        
        // Sort by priority and progress
        eligible.sort((a, b) {
          // High priority first
          final priorityCompare = _comparePriority(a.priority, b.priority);
          if (priorityCompare != 0) return priorityCompare;
          
          // Then by closest to completion
          return b.percentageComplete.compareTo(a.percentageComplete);
        });
        
        return Result.success(eligible);
      },
      error: (failure) => Result.error(failure),
    );
  }
  
  int _comparePriority(GoalPriority? a, GoalPriority? b) {
    const priorities = {
      GoalPriority.high: 3,
      GoalPriority.medium: 2,
      GoalPriority.low: 1,
      null: 0,
    };
    
    return priorities[b]!.compareTo(priorities[a]!);
  }
}

// lib/features/goals/domain/usecases/suggest_goal_allocation.dart

class SuggestGoalAllocation {
  final GoalRepository _goalRepository;
  final BudgetRepository _budgetRepository;
  
  SuggestGoalAllocation(this._goalRepository, this._budgetRepository);
  
  Future<Result<Map<String, double>>> call({
    required double amount,
    required TransactionType transactionType,
  }) async {
    if (transactionType != TransactionType.income) {
      return Result.success({});
    }
    
    // Get active goals
    final goalsResult = await _goalRepository.getActive();
    if (goalsResult.isError) {
      return Result.error(goalsResult.failureOrNull!);
    }
    
    final goals = goalsResult.dataOrNull!;
    if (goals.isEmpty) {
      return Result.success({});
    }
    
    // Get current budget to determine savings capacity
    final budgetResult = await _budgetRepository.getCurrentBudget();
    final savingsPercentage = budgetResult.when(
      success: (budget) => _calculateSavingsPercentage(budget),
      error: (_) => 0.20, // Default to 20%
    );
    
    final availableForGoals = amount * savingsPercentage;
    final suggestions = <String, double>{};
    
    // Distribute based on priority and progress
    var remainingAmount = availableForGoals;
    
    // Sort goals by priority
    final sortedGoals = goals.toList()
      ..sort((a, b) {
        // High priority & least progress first
        final priorityCompare = _comparePriority(a.priority, b.priority);
        if (priorityCompare != 0) return priorityCompare;
        
        return a.percentageComplete.compareTo(b.percentageComplete);
      });
    
    for (final goal in sortedGoals) {
      if (remainingAmount <= 0) break;
      
      // Calculate suggested amount
      final monthlyNeeded = goal.monthlyContributionNeeded;
      final suggestedAmount = min(
        min(monthlyNeeded, goal.remainingAmount),
        remainingAmount,
      );
      
      if (suggestedAmount >= 1) { // At least $1
        suggestions[goal.id] = suggestedAmount;
        remainingAmount -= suggestedAmount;
      }
    }
    
    return Result.success(suggestions);
  }
  
  double _calculateSavingsPercentage(Budget budget) {
    // Find savings/goals category in budget
    final savingsCategory = budget.categories.firstWhereOrNull(
      (c) => c.name.toLowerCase().contains('savings') ||
             c.name.toLowerCase().contains('goals'),
    );
    
    if (savingsCategory != null) {
      final totalBudget = budget.categories
          .fold(0.0, (sum, c) => sum + c.amount);
      
      return savingsCategory.amount / totalBudget;
    }
    
    return 0.20; // Default to 20%
  }
  
  int _comparePriority(GoalPriority? a, GoalPriority? b) {
    const priorities = {
      GoalPriority.high: 3,
      GoalPriority.medium: 2,
      GoalPriority.low: 1,
      null: 0,
    };
    
    return priorities[b]!.compareTo(priorities[a]!);
  }
}

3. Data Layer Implementation
3.1 Data Models & Mappers
dart// lib/features/goals/data/models/goal_contribution_dto.dart

@HiveType(typeId: 3)
class GoalContributionDTO extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String goalId;
  
  @HiveField(2)
  double amount;
  
  @HiveField(3)
  int timestamp;
  
  @HiveField(4)
  String? transactionId;
  
  @HiveField(5)
  String? note;
  
  GoalContributionDTO({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.timestamp,
    this.transactionId,
    this.note,
  });
}

// lib/features/goals/data/models/goal_contribution_mapper.dart

class GoalContributionMapper {
  static GoalContribution toDomain(GoalContributionDTO dto) {
    return GoalContribution(
      id: dto.id,
      goalId: dto.goalId,
      amount: dto.amount,
      date: DateTime.fromMillisecondsSinceEpoch(dto.timestamp),
      transactionId: dto.transactionId,
      note: dto.note,
    );
  }
  
  static GoalContributionDTO toDTO(GoalContribution domain) {
    return GoalContributionDTO(
      id: domain.id,
      goalId: domain.goalId,
      amount: domain.amount,
      timestamp: domain.date.millisecondsSinceEpoch,
      transactionId: domain.transactionId,
      note: domain.note,
    );
  }
}

// lib/features/goals/data/models/goal_dto.dart

@HiveType(typeId: 2)
class GoalDTO extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  double targetAmount;
  
  @HiveField(3)
  double currentAmount;
  
  @HiveField(4)
  int targetDateTimestamp;
  
  @HiveField(5)
  int createdDateTimestamp;
  
  @HiveField(6)
  int iconCodePoint;
  
  @HiveField(7)
  String? description;
  
  @HiveField(8)
  int? colorValue;
  
  @HiveField(9)
  String? priority;
  
  @HiveField(10)
  bool isCompleted;
  
  @HiveField(11)
  List<String> contributionIds; // References to contributions
  
  GoalDTO({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDateTimestamp,
    required this.createdDateTimestamp,
    required this.iconCodePoint,
    this.description,
    this.colorValue,
    this.priority,
    this.isCompleted = false,
    this.contributionIds = const [],
  });
}

// Update TransactionDTO to include goal allocations
@HiveType(typeId: 0)
class TransactionDTO extends HiveObject {
  // ... existing fields ...
  
  @HiveField(10)
  List<String>? goalAllocationIds; // References to contributions
  
  // ... rest of implementation ...
}
3.2 Repository Implementation
dart// lib/features/goals/data/repositories/goal_repository_impl.dart

class GoalRepositoryImpl implements GoalRepository {
  final Box<GoalDTO> _goalBox;
  final Box<GoalContributionDTO> _contributionBox;
  
  GoalRepositoryImpl({
    required Box<GoalDTO> goalBox,
    required Box<GoalContributionDTO> contributionBox,
  })  : _goalBox = goalBox,
        _contributionBox = contributionBox;
  
  @override
  Future<Result<Goal>> addContribution(RetrySContinuedart  @override
  Future<Result<Goal>> addContribution(
    String goalId,
    GoalContribution contribution,
  ) async {
    try {
      // 1. Get goal
      final goalDTO = _goalBox.get(goalId);
      if (goalDTO == null) {
        return Result.error(
          Failure.cache('Goal not found: $goalId'),
        );
      }
      
      // 2. Save contribution
      final contributionDTO = GoalContributionMapper.toDTO(contribution);
      await _contributionBox.put(contribution.id, contributionDTO);
      
      // 3. Update goal
      goalDTO.contributionIds = [
        ...goalDTO.contributionIds,
        contribution.id,
      ];
      goalDTO.currentAmount += contribution.amount;
      
      // 4. Check if goal is completed
      if (goalDTO.currentAmount >= goalDTO.targetAmount) {
        goalDTO.isCompleted = true;
      }
      
      await goalDTO.save();
      
      // 5. Convert to domain and return
      final updatedGoal = await _toDomainWithContributions(goalDTO);
      return Result.success(updatedGoal);
      
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to add contribution: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
  
  @override
  Future<Result<List<Goal>>> getEligibleForAllocation(
    double amount,
    TransactionType transactionType,
  ) async {
    try {
      // Get all active goals
      final activeGoals = _goalBox.values
          .where((dto) => !dto.isCompleted)
          .toList();
      
      // Convert to domain with contributions
      final goals = await Future.wait(
        activeGoals.map((dto) => _toDomainWithContributions(dto)),
      );
      
      return Result.success(goals);
      
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to fetch eligible goals: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
  
  @override
  Future<Result<List<Goal>>> getActive() async {
    try {
      final activeGoalDTOs = _goalBox.values
          .where((dto) => !dto.isCompleted)
          .toList();
      
      final goals = await Future.wait(
        activeGoalDTOs.map((dto) => _toDomainWithContributions(dto)),
      );
      
      return Result.success(goals);
      
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to fetch active goals: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
  
  // Helper method to load goal with all contributions
  Future<Goal> _toDomainWithContributions(GoalDTO dto) async {
    // Load all contributions for this goal
    final contributions = dto.contributionIds
        .map((id) => _contributionBox.get(id))
        .whereType<GoalContributionDTO>()
        .map(GoalContributionMapper.toDomain)
        .toList();
    
    return Goal(
      id: dto.id,
      name: dto.name,
      targetAmount: dto.targetAmount,
      currentAmount: dto.currentAmount,
      targetDate: DateTime.fromMillisecondsSinceEpoch(dto.targetDateTimestamp),
      createdDate: DateTime.fromMillisecondsSinceEpoch(dto.createdDateTimestamp),
      icon: IconData(dto.iconCodePoint, fontFamily: 'MaterialIcons'),
      description: dto.description,
      color: dto.colorValue != null ? Color(dto.colorValue!) : null,
      priority: dto.priority != null 
          ? GoalPriority.values.firstWhere((e) => e.name == dto.priority)
          : null,
      isCompleted: dto.isCompleted,
      contributions: contributions,
    );
  }
  
  @override
  Future<Result<List<Goal>>> getAll() async {
    try {
      final goals = await Future.wait(
        _goalBox.values.map((dto) => _toDomainWithContributions(dto)),
      );
      
      return Result.success(goals);
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to fetch goals: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
  
  @override
  Future<Result<Goal>> getById(String id) async {
    try {
      final dto = _goalBox.get(id);
      if (dto == null) {
        return Result.error(
          Failure.cache('Goal not found: $id'),
        );
      }
      
      final goal = await _toDomainWithContributions(dto);
      return Result.success(goal);
      
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to fetch goal: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
  
  @override
  Future<Result<Goal>> create(Goal goal) async {
    try {
      final dto = GoalDTO(
        id: goal.id,
        name: goal.name,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        targetDateTimestamp: goal.targetDate.millisecondsSinceEpoch,
        createdDateTimestamp: goal.createdDate.millisecondsSinceEpoch,
        iconCodePoint: goal.icon.codePoint,
        description: goal.description,
        colorValue: goal.color?.value,
        priority: goal.priority?.name,
        isCompleted: goal.isCompleted,
        contributionIds: [],
      );
      
      await _goalBox.put(goal.id, dto);
      
      return Result.success(goal);
      
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to create goal: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
  
  @override
  Future<Result<Goal>> update(Goal goal) async {
    try {
      final existingDTO = _goalBox.get(goal.id);
      if (existingDTO == null) {
        return Result.error(
          Failure.cache('Goal not found: ${goal.id}'),
        );
      }
      
      // Update fields
      existingDTO.name = goal.name;
      existingDTO.targetAmount = goal.targetAmount;
      existingDTO.targetDateTimestamp = goal.targetDate.millisecondsSinceEpoch;
      existingDTO.iconCodePoint = goal.icon.codePoint;
      existingDTO.description = goal.description;
      existingDTO.colorValue = goal.color?.value;
      existingDTO.priority = goal.priority?.name;
      
      await existingDTO.save();
      
      final updatedGoal = await _toDomainWithContributions(existingDTO);
      return Result.success(updatedGoal);
      
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to update goal: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
  
  @override
  Future<Result<void>> delete(String id) async {
    try {
      final dto = _goalBox.get(id);
      if (dto == null) {
        return Result.error(
          Failure.cache('Goal not found: $id'),
        );
      }
      
      // Delete all contributions
      for (final contributionId in dto.contributionIds) {
        await _contributionBox.delete(contributionId);
      }
      
      // Delete goal
      await _goalBox.delete(id);
      
      return Result.success(null);
      
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to delete goal: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
}

// lib/features/transactions/data/repositories/transaction_repository_impl.dart

class TransactionRepositoryImpl implements TransactionRepository {
  final Box<TransactionDTO> _transactionBox;
  final Box<GoalContributionDTO> _contributionBox;
  
  TransactionRepositoryImpl({
    required Box<TransactionDTO> transactionBox,
    required Box<GoalContributionDTO> contributionBox,
  })  : _transactionBox = transactionBox,
        _contributionBox = contributionBox;
  
  @override
  Future<Result<Transaction>> add(Transaction transaction) async {
    try {
      // 1. Save goal contributions first
      final contributionIds = <String>[];
      
      if (transaction.hasGoalAllocations) {
        for (final contribution in transaction.goalAllocations!) {
          final dto = GoalContributionMapper.toDTO(contribution);
          await _contributionBox.put(contribution.id, dto);
          contributionIds.add(contribution.id);
        }
      }
      
      // 2. Save transaction
      final dto = TransactionDTO(
        id: transaction.id,
        amount: transaction.amount,
        categoryId: transaction.categoryId,
        timestamp: transaction.date.millisecondsSinceEpoch,
        type: transaction.type == TransactionType.income ? 'income' : 'expense',
        description: transaction.description,
        note: transaction.note,
        receiptPath: transaction.receiptPath,
        tags: transaction.tags,
        isRecurring: transaction.isRecurring,
        goalAllocationIds: contributionIds.isNotEmpty ? contributionIds : null,
      );
      
      await _transactionBox.put(transaction.id, dto);
      
      return Result.success(transaction);
      
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to add transaction: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
  
  @override
  Future<Result<List<Transaction>>> getAll() async {
    try {
      final transactions = await Future.wait(
        _transactionBox.values.map((dto) => _toDomainWithAllocations(dto)),
      );
      
      return Result.success(transactions);
      
    } on HiveError catch (e) {
      return Result.error(
        Failure.cache('Failed to fetch transactions: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Failure.unknown('Unexpected error: $e'),
      );
    }
  }
  
  // Helper to load transaction with goal allocations
  Future<Transaction> _toDomainWithAllocations(TransactionDTO dto) async {
    // Load goal allocations if present
    List<GoalContribution>? allocations;
    
    if (dto.goalAllocationIds != null && dto.goalAllocationIds!.isNotEmpty) {
      allocations = dto.goalAllocationIds!
          .map((id) => _contributionBox.get(id))
          .whereType<GoalContributionDTO>()
          .map(GoalContributionMapper.toDomain)
          .toList();
    }
    
    return Transaction(
      id: dto.id,
      amount: dto.amount,
      categoryId: dto.categoryId,
      date: DateTime.fromMillisecondsSinceEpoch(dto.timestamp),
      type: dto.type == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
      description: dto.description,
      note: dto.note,
      receiptPath: dto.receiptPath,
      tags: dto.tags,
      isRecurring: dto.isRecurring,
      goalAllocations: allocations,
    );
  }
  
  // ... other repository methods ...
}

4. Presentation Layer Implementation
4.1 State Management
dart// lib/features/transactions/presentation/providers/transaction_form_provider.dart

@freezed
class TransactionFormState with _$TransactionFormState {
  const factory TransactionFormState({
    @Default('') String amount,
    String? categoryId,
    @Default('') String description,
    String? note,
    required DateTime date,
    @Default(TransactionType.expense) TransactionType type,
    @Default([]) List<GoalContribution> goalAllocations,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _TransactionFormState;
}

@riverpod
class TransactionForm extends _$TransactionForm {
  @override
  TransactionFormState build() {
    return TransactionFormState(
      date: DateTime.now(),
    );
  }
  
  void setAmount(String amount) {
    state = state.copyWith(amount: amount);
  }
  
  void setCategory(String categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }
  
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }
  
  void setNote(String note) {
    state = state.copyWith(note: note);
  }
  
  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }
  
  void setType(TransactionType type) {
    state = state.copyWith(type: type);
  }
  
  void setGoalAllocations(List<GoalContribution> allocations) {
    state = state.copyWith(goalAllocations: allocations);
  }
  
  void addGoalAllocation(GoalContribution allocation) {
    final updated = [...state.goalAllocations, allocation];
    state = state.copyWith(goalAllocations: updated);
  }
  
  void removeGoalAllocation(String goalId) {
    final updated = state.goalAllocations
        .where((a) => a.goalId != goalId)
        .toList();
    state = state.copyWith(goalAllocations: updated);
  }
  
  void updateGoalAllocation(String goalId, double amount) {
    final updated = state.goalAllocations.map((a) {
      if (a.goalId == goalId) {
        return a.copyWith(amount: amount);
      }
      return a;
    }).toList();
    state = state.copyWith(goalAllocations: updated);
  }
  
  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, error: null);
    
    // Validate
    final amount = double.tryParse(state.amount);
    if (amount == null || amount <= 0) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Please enter a valid amount',
      );
      return false;
    }
    
    if (state.categoryId == null) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Please select a category',
      );
      return false;
    }
    
    // Create transaction
    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: state.categoryId!,
      date: state.date,
      type: state.type,
      description: state.description.isNotEmpty ? state.description : null,
      note: state.note?.isNotEmpty == true ? state.note : null,
      goalAllocations: state.goalAllocations.isNotEmpty 
          ? state.goalAllocations 
          : null,
    );
    
    // Submit
    final useCase = ref.read(addTransactionWithGoalAllocationProvider);
    final result = await useCase(transaction);
    
    return result.when(
      success: (data) {
        // Success - notify listeners
        ref.invalidate(transactionNotifierProvider);
        ref.invalidate(goalNotifierProvider);
        
        // Show success message with goal updates
        if (data.updatedGoals.isNotEmpty) {
          _showGoalSuccessMessage(data);
        }
        
        state = state.copyWith(isSubmitting: false);
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isSubmitting: false,
          error: failure.when(
            network: (msg) => msg,
            server: (msg, _) => msg,
            cache: (msg) => msg,
            validation: (msg, _) => msg,
            unknown: (msg) => msg,
          ),
        );
        return false;
      },
    );
  }
  
  void _showGoalSuccessMessage(TransactionWithGoalUpdates data) {
    final goals = data.updatedGoals;
    
    if (goals.length == 1) {
      final goal = goals.first;
      final contribution = state.goalAllocations.firstWhere(
        (a) => a.goalId == goal.id,
      );
      
      SmartDialog.showToast(
        '✅ \$${contribution.amount.toStringAsFixed(0)} added to ${goal.name}!\n'
        '${goal.percentageComplete.toStringAsFixed(0)}% complete',
        displayTime: Duration(seconds: 3),
      );
      
      // Check for milestone celebration
      if (goal.percentageComplete >= 100) {
        _showGoalCompletionCelebration(goal);
      } else if (goal.percentageComplete >= 75 && 
                 goal.percentageComplete - (contribution.amount / goal.targetAmount * 100) < 75) {
        _showMilestoneCelebration(goal, 75);
      }
    } else {
      SmartDialog.showToast(
        '✅ Contributed to ${goals.length} goals!',
        displayTime: Duration(seconds: 2),
      );
    }
  }
  
  void _showGoalCompletionCelebration(Goal goal) {
    // Trigger confetti animation and show celebration dialog
    // Implementation in UI layer
  }
  
  void _showMilestoneCelebration(Goal goal, int milestone) {
    // Show milestone reached notification
    // Implementation in UI layer
  }
  
  void reset() {
    state = TransactionFormState(date: DateTime.now());
  }
}

// Provider for eligible goals
@riverpod
Future<List<Goal>> eligibleGoalsForAllocation(
  EligibleGoalsForAllocationRef ref,
) async {
  final formState = ref.watch(transactionFormProvider);
  final amount = double.tryParse(formState.amount) ?? 0;
  
  if (amount <= 0 || formState.type == TransactionType.expense) {
    return [];
  }
  
  final useCase = ref.read(getEligibleGoalsForAllocationProvider);
  final result = await useCase(
    amount: amount,
    transactionType: formState.type,
  );
  
  return result.when(
    success: (goals) => goals,
    error: (_) => [],
  );
}

// Provider for suggested allocations
@riverpod
Future<Map<String, double>> suggestedGoalAllocations(
  SuggestedGoalAllocationsRef ref,
) async {
  final formState = ref.watch(transactionFormProvider);
  final amount = double.tryParse(formState.amount) ?? 0;
  
  if (amount <= 0 || formState.type == TransactionType.expense) {
    return {};
  }
  
  final useCase = ref.read(suggestGoalAllocationProvider);
  final result = await useCase(
    amount: amount,
    transactionType: formState.type,
  );
  
  return result.when(
    success: (suggestions) => suggestions,
    error: (_) => {},
  );
}

// Use case providers
@riverpod
AddTransactionWithGoalAllocation addTransactionWithGoalAllocation(
  AddTransactionWithGoalAllocationRef ref,
) {
  return GetIt.instance<AddTransactionWithGoalAllocation>();
}

@riverpod
GetEligibleGoalsForAllocation getEligibleGoalsForAllocation(
  GetEligibleGoalsForAllocationRef ref,
) {
  return GetIt.instance<GetEligibleGoalsForAllocation>();
}

@riverpod
SuggestGoalAllocation suggestGoalAllocation(
  SuggestGoalAllocationRef ref,
) {
  return GetIt.instance<SuggestGoalAllocation>();
}
4.2 Enhanced Add Transaction Bottom Sheet
dart// lib/features/transactions/presentation/widgets/add_transaction_bottom_sheet.dart

class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  final ValueChanged<Transaction>? onSubmit;
  final Transaction? editingTransaction;
  
  const AddTransactionBottomSheet({
    Key? key,
    this.onSubmit,
    this.editingTransaction,
  }) : super(key: key);
  
  @override
  ConsumerState<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState
    extends ConsumerState<AddTransactionBottomSheet> {
  
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with editing transaction if provided
    if (widget.editingTransaction != null) {
      final tx = widget.editingTransaction!;
      _amountController.text = tx.amount.toStringAsFixed(2);
      _descriptionController.text = tx.description ?? '';
      _noteController.text = tx.note ?? '';
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(transactionFormProvider.notifier)
          ..setAmount(tx.amount.toString())
          ..setCategory(tx.categoryId)
          ..setDescription(tx.description ?? '')
          ..setNote(tx.note ?? '')
          ..setDate(tx.date)
          ..setType(tx.type);
        
        if (tx.goalAllocations != null) {
          ref.read(transactionFormProvider.notifier)
              .setGoalAllocations(tx.goalAllocations!);
        }
      });
    }
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final categories = ref.watch(categoriesProvider);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppDimensions.borderRadiusTopXl,
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.sm,
                  ),
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: AppSpacing.screenPaddingHorizontal,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.editingTransaction != null
                            ? 'Edit Transaction'
                            : 'Add Transaction',
                        style: AppTypography.headlineLarge,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              Divider(height: 1),
              
              // Form content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: AppSpacing.screenPaddingAll,
                  children: [
                    // Transaction type toggle
                    _TransactionTypeToggle(
                      type: formState.type,
                      onChanged: (type) {
                        ref.read(transactionFormProvider.notifier).setType(type);
                        HapticService.selection();
                      },
                    ),
                    Gap(AppSpacing.xl),
                    
                    // Amount input
                    CurrencyInputField(
                      label: 'Amount',
                      controller: _amountController,
                      onChanged: (value) {
                        ref.read(transactionFormProvider.notifier)
                            .setAmount(value.toString());
                      },
                      errorText: formState.error?.contains('amount') == true
                          ? formState.error
                          : null,
                    ),
                    Gap(AppSpacing.lg),
                    
                    // Category selection
                    categories.when(
                      data: (cats) => CategorySelector(
                        selectedCategory: formState.categoryId,
                        onCategorySelected: (categoryId) {
                          ref.read(transactionFormProvider.notifier)
                              .setCategory(categoryId);
                          HapticService.light();
                        },
                        categories: cats,
                      ),
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (_, __) => Text('Failed to load categories'),
                    ),
                    Gap(AppSpacing.lg),
                    
                    // Description
                    AppTextField(
                      label: 'Description',
                      hint: 'What was this for?',
                      controller: _descriptionController,
                      onChanged: (value) {
                        ref.read(transactionFormProvider.notifier)
                            .setDescription(value);
                      },
                    ),
                    Gap(AppSpacing.lg),
                    
                    // Date picker
                    _DatePickerField(
                      date: formState.date,
                      onDateSelected: (date) {
                        ref.read(transactionFormProvider.notifier).setDate(date);
                      },
                    ),
                    Gap(AppSpacing.xl),
                    
                    // === GOAL ALLOCATION SECTION ===
                    // Only show for income transactions
                    if (formState.type == TransactionType.income) ...[
                      GoalAllocationSection(
                        transactionAmount: double.tryParse(formState.amount) ?? 0,
                        transactionType: formState.type,
                        onAllocationsChanged: (allocations) {
                          ref.read(transactionFormProvider.notifier)
                              .setGoalAllocations(allocations);
                        },
                      ),
                      Gap(AppSpacing.xl),
                    ],
                    
                    // Note (optional, collapsible)
                    _CollapsibleSection(
                      title: 'Add Note',
                      icon: Icons.note_rounded,
                      child: AppTextField(
                        label: '',
                        hint: 'Additional details...',
                        controller: _noteController,
                        maxLines: 3,
                        onChanged: (value) {
                          ref.read(transactionFormProvider.notifier)
                              .setNote(value);
                        },
                      ),
                    ),
                    
                    // Bottom spacing for keyboard
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 100),
                  ],
                ),
              ),
              
              // Submit button (fixed at bottom)
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: AppButton(
                    label: widget.editingTransaction != null
                        ? 'Update Transaction'
                        : 'Add Transaction',
                    onPressed: formState.isSubmitting ? null : _handleSubmit,
                    isLoading: formState.isSubmitting,
                    isFullWidth: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _handleSubmit() async {
    HapticService.medium();
    
    final success = await ref.read(transactionFormProvider.notifier).submit();
    
    if (success && mounted) {
      HapticService.heavy();
      Navigator.pop(context);
      
      // Show success feedback
      final formState = ref.read(transactionFormProvider);
      if (formState.goalAllocations.isNotEmpty) {
        // Goal contributions were made - show special feedback
        _showGoalContributionSuccess(formState.goalAllocations);
      } else {
        SmartDialog.showToast('Transaction added successfully!');
      }
    } else if (mounted) {
      // Error - shake animation
      HapticService.heavy();
      // Show error in UI (already in form state)
    }
  }
  
  void _showGoalContributionSuccess(List<GoalContribution> allocations) {
    if (allocations.length == 1) {
      final allocation = allocations.first;
      final goalResult = ref.read(goalByIdProvider(allocation.goalId));
      
      goalResult.whenData((goal) {
        SmartDialog.show(
          builder: (context) => _GoalContributionSuccessDialog(
            goal: goal,
            contribution: allocation,
          ),
        );
      });
    } else {
      SmartDialog.showToast(
        '✅ Transaction added with ${allocations.length} goal contributions!',
        displayTime: Duration(seconds: 3),
      );
    }
  }
}

// Success dialog with celebration
class _GoalContributionSuccessDialog extends StatelessWidget {
  final Goal goal;
  final GoalContribution contribution;
  
  const _GoalContributionSuccessDialog({
    required this.goal,
    required this.contribution,
  });
  
  @override
  Widget build(BuildContext context) {
    final isCompleted = goal.percentageComplete >= 100;
    final isMilestone = goal.percentageComplete % 25 < 5;
    
    return Container(
      margin: EdgeInsets.all(AppSpacing.xl),
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxRetrySContinuedart      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppDimensions.borderRadiusXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Celebration animation
          if (isCompleted)
            Lottie.asset(
              'assets/animations/celebration.json',
              width: 200,
              height: 200,
              repeat: false,
            )
          else if (isMilestone)
            Lottie.asset(
              'assets/animations/milestone.json',
              width: 150,
              height: 150,
              repeat: false,
            )
          else
            Icon(
              Icons.check_circle_rounded,
              size: 80,
              color: AppColors.success,
            ).animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
          
          Gap(AppSpacing.lg),
          
          // Message
          Text(
            isCompleted
                ? '🎉 Goal Completed!'
                : isMilestone
                    ? '🎯 Milestone Reached!'
                    : 'Contribution Added!',
            style: AppTypography.headlineLarge.copyWith(
              color: isCompleted ? AppColors.success : AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(AppSpacing.md),
          
          Text(
            '\$${contribution.amount.toStringAsFixed(0)} added to',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(AppSpacing.xs),
          
          Text(
            goal.name,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(AppSpacing.xl),
          
          // Progress circle
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: goal.percentageComplete / 100,
                  strokeWidth: 12,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(
                    isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${goal.percentageComplete.toStringAsFixed(0)}%',
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    Text(
                      'complete',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(AppSpacing.xl),
          
          // Stats
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: AppDimensions.borderRadiusMd,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current amount:',
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      '\$${goal.currentAmount.toStringAsFixed(0)}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Gap(AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target amount:',
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      '\$${goal.targetAmount.toStringAsFixed(0)}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (!isCompleted) ...[
                  Divider(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Still needed:',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${goal.remainingAmount.toStringAsFixed(0)}',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Gap(AppSpacing.xl),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'View Goal',
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/goals/${goal.id}');
                  },
                ),
              ),
              Gap(AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Done',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Transaction type toggle
class _TransactionTypeToggle extends StatelessWidget {
  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;
  
  const _TransactionTypeToggle({
    required this.type,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: AppDimensions.borderRadiusMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Expense',
              icon: Icons.remove_circle_outline_rounded,
              isSelected: type == TransactionType.expense,
              color: AppColors.danger,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Income',
              icon: Icons.add_circle_outline_rounded,
              isSelected: type == TransactionType.income,
              color: AppColors.success,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  
  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
      borderRadius: AppDimensions.borderRadiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusMd,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppDimensions.iconSm,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              Gap(AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Date picker field
class _DatePickerField extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;
  
  const _DatePickerField({
    required this.date,
    required this.onDateSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withOpacity(0.3),
          borderRadius: AppDimensions.borderRadiusMd,
          border: Border.all(
            color: AppColors.border.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: AppDimensions.iconSm,
              color: AppColors.primary,
            ),
            Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(date),
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _showDatePicker(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (selected != null) {
      HapticService.light();
      onDateSelected(selected);
    }
  }
}

// Collapsible section
class _CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  
  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.child,
  });
  
  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
            HapticService.selection();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: AppDimensions.iconSm,
                  color: AppColors.primary,
                ),
                Gap(AppSpacing.sm),
                Text(
                  widget.title,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          widget.child.animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: -0.1, end: 0),
      ],
    );
  }
}
```

---

## 5. Integration Points & Data Flow

### 5.1 Complete Data Flow Diagram
```
User Action: Add Transaction with Goal Allocation
================================================

1. USER INTERACTION
   ├─ User opens "Add Transaction" bottom sheet
   ├─ Enters amount: $1,000 (Income)
   ├─ Selects category: "Salary"
   ├─ Expands "Allocate to goals" section
   │  ├─ System fetches eligible goals
   │  └─ Displays active goals sorted by priority
   ├─ User selects "Emergency Fund"
   ├─ Enters allocation: $200
   └─ Taps "Add Transaction"

2. PRESENTATION LAYER
   ├─ TransactionForm.submit() called
   ├─ Validates form data
   ├─ Creates Transaction entity with goal allocations
   └─ Calls AddTransactionWithGoalAllocation use case

3. DOMAIN LAYER (Use Case)
   ├─ AddTransactionWithGoalAllocation.call()
   ├─ Validates transaction (amount > 0)
   ├─ Validates allocations (total ≤ transaction amount)
   ├─ Calls TransactionRepository.add()
   ├─ For each goal allocation:
   │  ├─ Links contribution to transaction
   │  ├─ Calls GoalRepository.addContribution()
   │  └─ Checks for milestones (25%, 50%, 75%, 100%)
   └─ Returns TransactionWithGoalUpdates

4. DATA LAYER (Repository)
   ├─ TransactionRepositoryImpl.add()
   │  ├─ Saves each GoalContribution to Hive
   │  ├─ Links contribution IDs to transaction
   │  └─ Saves TransactionDTO to Hive
   └─ GoalRepositoryImpl.addContribution()
      ├─ Saves GoalContributionDTO to Hive
      ├─ Updates Goal.currentAmount += contribution
      ├─ Updates Goal.contributionIds list
      ├─ Checks if goal completed (current ≥ target)
      └─ Saves updated GoalDTO to Hive

5. STORAGE LAYER (Hive)
   ├─ Box<TransactionDTO>.put(transaction)
   ├─ Box<GoalContributionDTO>.put(contributions)
   └─ Box<GoalDTO>.put(updatedGoals)

6. RESPONSE FLOW (Back to UI)
   ├─ Use case returns success with updated goals
   ├─ TransactionForm updates state
   ├─ Invalidates providers (triggers UI refresh)
   │  ├─ transactionNotifierProvider
   │  └─ goalNotifierProvider
   ├─ Shows success message with goal progress
   ├─ If milestone reached:
   │  └─ Shows celebration dialog
   └─ Closes bottom sheet

7. UI UPDATES
   ├─ Transaction list refreshes (new transaction appears)
   ├─ Dashboard budget card updates
   ├─ Goals screen shows updated progress
   └─ Goal detail shows new contribution
5.2 Database Schema (Hive)
dart// Hive Box Structure
// ==================

Box<TransactionDTO>: 'transactions'
├─ Key: transaction.id (String)
└─ Value: TransactionDTO {
     id, amount, categoryId, timestamp, type,
     description, note, receiptPath, tags,
     isRecurring, goalAllocationIds: [contribution_ids]
   }

Box<GoalDTO>: 'goals'
├─ Key: goal.id (String)
└─ Value: GoalDTO {
     id, name, targetAmount, currentAmount,
     targetDateTimestamp, createdDateTimestamp,
     iconCodePoint, description, colorValue,
     priority, isCompleted,
     contributionIds: [contribution_ids]
   }

Box<GoalContributionDTO>: 'goal_contributions'
├─ Key: contribution.id (String)
└─ Value: GoalContributionDTO {
     id, goalId, amount, timestamp,
     transactionId (link back to source),
     note
   }

// Relationships
// =============
Transaction 1 ─────→ N GoalContribution
                      ↓
Goal        1 ←───── N GoalContribution
5.3 Query Patterns
dart// Common queries needed for the feature

// 1. Get all transactions with their goal allocations
Future<List<Transaction>> getTransactionsWithAllocations() async {
  final transactionBox = Hive.box<TransactionDTO>('transactions');
  final contributionBox = Hive.box<GoalContributionDTO>('goal_contributions');
  
  final transactions = transactionBox.values.map((dto) {
    // Load contributions for this transaction
    final allocations = dto.goalAllocationIds
        ?.map((id) => contributionBox.get(id))
        .whereType<GoalContributionDTO>()
        .map(GoalContributionMapper.toDomain)
        .toList();
    
    return TransactionMapper.toDomain(dto, allocations);
  }).toList();
  
  return transactions;
}

// 2. Get goal with all contributions
Future<Goal> getGoalWithContributions(String goalId) async {
  final goalBox = Hive.box<GoalDTO>('goals');
  final contributionBox = Hive.box<GoalContributionDTO>('goal_contributions');
  
  final goalDTO = goalBox.get(goalId);
  if (goalDTO == null) throw Exception('Goal not found');
  
  // Load all contributions
  final contributions = goalDTO.contributionIds
      .map((id) => contributionBox.get(id))
      .whereType<GoalContributionDTO>()
      .map(GoalContributionMapper.toDomain)
      .toList();
  
  return GoalMapper.toDomain(goalDTO, contributions);
}

// 3. Get all contributions for a date range (for insights)
Future<List<GoalContribution>> getContributionsInRange(
  DateTime start,
  DateTime end,
) async {
  final contributionBox = Hive.box<GoalContributionDTO>('goal_contributions');
  
  final startMs = start.millisecondsSinceEpoch;
  final endMs = end.millisecondsSinceEpoch;
  
  return contributionBox.values
      .where((dto) => dto.timestamp >= startMs && dto.timestamp <= endMs)
      .map(GoalContributionMapper.toDomain)
      .toList();
}

// 4. Get transaction contribution total for a goal
Future<double> getTotalContributionsFromTransactions(String goalId) async {
  final contributionBox = Hive.box<GoalContributionDTO>('goal_contributions');
  
  return contributionBox.values
      .where((dto) => dto.goalId == goalId && dto.transactionId != null)
      .fold(0.0, (sum, dto) => sum + dto.amount);
}

// 5. Find transactions that contributed to a specific goal
Future<List<Transaction>> getTransactionsForGoal(String goalId) async {
  final transactionBox = Hive.box<TransactionDTO>('transactions');
  final contributionBox = Hive.box<GoalContributionDTO>('goal_contributions');
  
  // Get all contributions for this goal
  final goalContributions = contributionBox.values
      .where((dto) => dto.goalId == goalId)
      .toList();
  
  // Get transaction IDs
  final transactionIds = goalContributions
      .map((c) => c.transactionId)
      .whereType<String>()
      .toSet();
  
  // Fetch transactions
  return transactionIds
      .map((id) => transactionBox.get(id))
      .whereType<TransactionDTO>()
      .map((dto) => TransactionMapper.toDomain(dto))
      .toList();
}

6. Testing Strategy
6.1 Unit Tests
dart// test/features/transactions/domain/usecases/add_transaction_with_goal_allocation_test.dart

void main() {
  late AddTransactionWithGoalAllocation useCase;
  late MockTransactionRepository mockTransactionRepo;
  late MockGoalRepository mockGoalRepo;
  late MockNotificationService mockNotificationService;
  
  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockGoalRepo = MockGoalRepository();
    mockNotificationService = MockNotificationService();
    
    useCase = AddTransactionWithGoalAllocation(
      mockTransactionRepo,
      mockGoalRepo,
      mockNotificationService,
    );
  });
  
  group('AddTransactionWithGoalAllocation', () {
    final testGoal = Goal(
      id: 'goal1',
      name: 'Emergency Fund',
      targetAmount: 1000,
      currentAmount: 500,
      targetDate: DateTime.now().add(Duration(days: 365)),
      createdDate: DateTime.now().subtract(Duration(days: 30)),
      icon: Icons.savings,
    );
    
    final testContribution = GoalContribution(
      id: 'contrib1',
      goalId: 'goal1',
      amount: 200,
      date: DateTime.now(),
    );
    
    final testTransaction = Transaction(
      id: 'tx1',
      amount: 1000,
      categoryId: 'income',
      date: DateTime.now(),
      type: TransactionType.income,
      goalAllocations: [testContribution],
    );
    
    test('should add transaction and update goal successfully', () async {
      // Arrange
      when(mockGoalRepo.getById('goal1'))
          .thenAnswer((_) async => Result.success(testGoal));
      
      when(mockTransactionRepo.add(any))
          .thenAnswer((_) async => Result.success(testTransaction));
      
      final updatedGoal = testGoal.copyWith(
        currentAmount: testGoal.currentAmount + testContribution.amount,
      );
      
      when(mockGoalRepo.addContribution('goal1', any))
          .thenAnswer((_) async => Result.success(updatedGoal));
      
      // Act
      final result = await useCase(testTransaction);
      
      // Assert
      expect(result, isA<Success<TransactionWithGoalUpdates>>());
      
      final data = result.dataOrNull!;
      expect(data.transaction.id, testTransaction.id);
      expect(data.updatedGoals.length, 1);
      expect(data.updatedGoals.first.currentAmount, 700);
      
      verify(mockTransactionRepo.add(testTransaction)).called(1);
      verify(mockGoalRepo.addContribution('goal1', any)).called(1);
    });
    
    test('should return error if allocations exceed transaction amount', () async {
      // Arrange
      final invalidContribution = testContribution.copyWith(amount: 1500);
      final invalidTransaction = testTransaction.copyWith(
        goalAllocations: [invalidContribution],
      );
      
      // Act
      final result = await useCase(invalidTransaction);
      
      // Assert
      expect(result, isA<Error<TransactionWithGoalUpdates>>());
      expect(result.failureOrNull, isA<ValidationFailure>());
      
      verifyNever(mockTransactionRepo.add(any));
      verifyNever(mockGoalRepo.addContribution(any, any));
    });
    
    test('should return error if goal does not exist', () async {
      // Arrange
      when(mockGoalRepo.getById('goal1'))
          .thenAnswer((_) async => Result.error(Failure.cache('Not found')));
      
      // Act
      final result = await useCase(testTransaction);
      
      // Assert
      expect(result, isA<Error<TransactionWithGoalUpdates>>());
      expect(result.failureOrNull, isA<ValidationFailure>());
      
      verifyNever(mockTransactionRepo.add(any));
      verifyNever(mockGoalRepo.addContribution(any, any));
    });
    
    test('should not allow contribution to completed goal', () async {
      // Arrange
      final completedGoal = testGoal.copyWith(isCompleted: true);
      
      when(mockGoalRepo.getById('goal1'))
          .thenAnswer((_) async => Result.success(completedGoal));
      
      // Act
      final result = await useCase(testTransaction);
      
      // Assert
      expect(result, isA<Error<TransactionWithGoalUpdates>>());
      expect(result.failureOrNull, isA<ValidationFailure>());
    });
    
    test('should send notification on milestone', () async {
      // Arrange
      final goalAt70Percent = testGoal.copyWith(currentAmount: 700);
      
      when(mockGoalRepo.getById('goal1'))
          .thenAnswer((_) async => Result.success(goalAt70Percent));
      
      when(mockTransactionRepo.add(any))
          .thenAnswer((_) async => Result.success(testTransaction));
      
      final updatedGoalAt90Percent = goalAt70Percent.copyWith(
        currentAmount: 900, // 90% - crosses 75% milestone
      );
      
      when(mockGoalRepo.addContribution('goal1', any))
          .thenAnswer((_) async => Result.success(updatedGoalAt90Percent));
      
      // Act
      await useCase(testTransaction);
      
      // Assert
      verify(mockNotificationService.sendGoalMilestone(
        goal: updatedGoalAt90Percent,
        milestone: 75,
      )).called(1);
    });
    
    test('should handle multiple goal allocations', () async {
      // Arrange
      final goal2 = testGoal.copyWith(id: 'goal2', name: 'Vacation');
      final contribution2 = testContribution.copyWith(
        id: 'contrib2',
        goalId: 'goal2',
        amount: 300,
      );
      
      final multiGoalTransaction = testTransaction.copyWith(
        goalAllocations: [testContribution, contribution2],
      );
      
      when(mockGoalRepo.getById('goal1'))
          .thenAnswer((_) async => Result.success(testGoal));
      when(mockGoalRepo.getById('goal2'))
          .thenAnswer((_) async => Result.success(goal2));
      
      when(mockTransactionRepo.add(any))
          .thenAnswer((_) async => Result.success(multiGoalTransaction));
      
      when(mockGoalRepo.addContribution(any, any))
          .thenAnswer((_) async => Result.success(testGoal));
      
      // Act
      final result = await useCase(multiGoalTransaction);
      
      // Assert
      expect(result, isA<Success<TransactionWithGoalUpdates>>());
      expect(result.dataOrNull!.updatedGoals.length, 2);
      
      verify(mockGoalRepo.addContribution('goal1', any)).called(1);
      verify(mockGoalRepo.addContribution('goal2', any)).called(1);
    });
  });
}
6.2 Integration Tests
dart// test/features/transactions/integration/transaction_goal_allocation_integration_test.dart

void main() {
  testWidgets('complete transaction with goal allocation flow', (tester) async {
    // Setup test environment
    await Hive.initFlutter();
    await Hive.openBox<TransactionDTO>('test_transactions');
    await Hive.openBox<GoalDTO>('test_goals');
    await Hive.openBox<GoalContributionDTO>('test_contributions');
    
    // Create test goal
    final testGoal = Goal(
      id: 'test_goal',
      name: 'Emergency Fund',
      targetAmount: 1000,
      currentAmount: 500,
      targetDate: DateTime.now().add(Duration(days: 365)),
      createdDate: DateTime.now(),
      icon: Icons.savings,
    );
    
    // Save goal to database
    final goalRepo = GoalRepositoryImpl(
      goalBox: Hive.box('test_goals'),
      contributionBox: Hive.box('test_contributions'),
    );
    await goalRepo.create(testGoal);
    
    // Pump app
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: DashboardScreen(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: tester.element(find.byType(Scaffold)),
                  builder: (context) => AddTransactionBottomSheet(),
                );
              },
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
    
    // 1. Tap FAB to open add transaction sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    
    // 2. Verify bottom sheet opened
    expect(find.text('Add Transaction'), findsOneWidget);
    
    // 3. Select Income type
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    
    // 4. Enter amount
    await tester.enterText(
      find.byKey(Key('amount_field')),
      '1000',
    );
    await tester.pumpAndSettle();
    
    // 5. Select category
    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();
    
    // 6. Expand goal allocation section
    await tester.tap(find.text('Allocate to goals'));
    await tester.pumpAndSettle();
    
    // 7. Verify goal appears
    expect(find.text('Emergency Fund'), findsOneWidget);
    
    // 8. Select goal
    await tester.tap(find.text('Emergency Fund'));
    await tester.pumpAndSettle();
    
    // 9. Enter allocation amount
    await tester.enterText(
      find.byKey(Key('goal_allocation_amount')),
      '200',
    );
    await tester.pumpAndSettle();
    
    // 10. Verify summary shows correct amounts
    expect(find.text('Transaction amount'), findsOneWidget);
    expect(find.text('\$1,000.00'), findsOneWidget);
    expect(find.text('To goals (1)'), finRetrySContinuedart    expect(find.text('To goals (1)'), findsOneWidget);
    expect(find.text('\$200.00'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('\$800.00'), findsOneWidget);
    
    // 11. Submit transaction
    await tester.tap(find.text('Add Transaction'));
    await tester.pumpAndSettle();
    
    // 12. Verify success message
    expect(find.textContaining('added to Emergency Fund'), findsOneWidget);
    
    // 13. Verify bottom sheet closed
    expect(find.text('Add Transaction'), findsNothing);
    
    // 14. Verify transaction was saved
    final transactionRepo = TransactionRepositoryImpl(
      transactionBox: Hive.box('test_transactions'),
      contributionBox: Hive.box('test_contributions'),
    );
    final transactions = await transactionRepo.getAll();
    expect(transactions.dataOrNull!.length, 1);
    
    final savedTransaction = transactions.dataOrNull!.first;
    expect(savedTransaction.amount, 1000);
    expect(savedTransaction.goalAllocations?.length, 1);
    expect(savedTransaction.goalAllocations!.first.amount, 200);
    
    // 15. Verify goal was updated
    final updatedGoalResult = await goalRepo.getById('test_goal');
    final updatedGoal = updatedGoalResult.dataOrNull!;
    expect(updatedGoal.currentAmount, 700); // 500 + 200
    expect(updatedGoal.contributions.length, 1);
    
    // Cleanup
    await Hive.deleteFromDisk();
  });
  
  testWidgets('prevents allocation exceeding transaction amount', (tester) async {
    // Setup
    await Hive.initFlutter();
    await Hive.openBox<GoalDTO>('test_goals');
    
    final testGoal = Goal(
      id: 'test_goal',
      name: 'Vacation',
      targetAmount: 5000,
      currentAmount: 1000,
      targetDate: DateTime.now().add(Duration(days: 180)),
      createdDate: DateTime.now(),
      icon: Icons.flight,
    );
    
    final goalRepo = GoalRepositoryImpl(
      goalBox: Hive.box('test_goals'),
      contributionBox: Hive.box('test_contributions'),
    );
    await goalRepo.create(testGoal);
    
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AddTransactionBottomSheet(),
        ),
      ),
    );
    
    // Enter amount
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byKey(Key('amount_field')), '500');
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();
    
    // Expand goals and select
    await tester.tap(find.text('Allocate to goals'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Vacation'));
    await tester.pumpAndSettle();
    
    // Try to allocate more than transaction amount
    await tester.enterText(
      find.byKey(Key('goal_allocation_amount')),
      '600',
    );
    await tester.pumpAndSettle();
    
    // Verify error message
    expect(find.text('Exceeds transaction amount'), findsOneWidget);
    
    // Submit button should be disabled or show error
    await tester.tap(find.text('Add Transaction'));
    await tester.pumpAndSettle();
    
    // Verify transaction was not saved
    expect(find.textContaining('Goal allocations exceed'), findsOneWidget);
    
    // Cleanup
    await Hive.deleteFromDisk();
  });
  
  testWidgets('celebrates milestone achievement', (tester) async {
    // Setup goal at 70%
    await Hive.initFlutter();
    await Hive.openBox<GoalDTO>('test_goals');
    await Hive.openBox<GoalContributionDTO>('test_contributions');
    await Hive.openBox<TransactionDTO>('test_transactions');
    
    final testGoal = Goal(
      id: 'test_goal',
      name: 'House Down Payment',
      targetAmount: 10000,
      currentAmount: 7000, // 70%
      targetDate: DateTime.now().add(Duration(days: 365)),
      createdDate: DateTime.now(),
      icon: Icons.home,
    );
    
    final goalRepo = GoalRepositoryImpl(
      goalBox: Hive.box('test_goals'),
      contributionBox: Hive.box('test_contributions'),
    );
    await goalRepo.create(testGoal);
    
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AddTransactionBottomSheet(),
        ),
      ),
    );
    
    // Add transaction that will push goal to 77% (crosses 75% milestone)
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byKey(Key('amount_field')), '1000');
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Allocate to goals'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('House Down Payment'));
    await tester.pumpAndSettle();
    
    await tester.enterText(
      find.byKey(Key('goal_allocation_amount')),
      '700',
    );
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Add Transaction'));
    await tester.pumpAndSettle();
    
    // Wait for celebration dialog
    await tester.pumpAndSettle(Duration(seconds: 1));
    
    // Verify milestone celebration appears
    expect(find.text('🎯 Milestone Reached!'), findsOneWidget);
    expect(find.text('77%'), findsOneWidget); // Updated percentage
    
    // Cleanup
    await Hive.deleteFromDisk();
  });
}
6.3 Widget Tests
dart// test/features/transactions/presentation/widgets/goal_allocation_section_test.dart

void main() {
  group('GoalAllocationSection Widget Tests', () {
    testWidgets('shows collapsed state by default', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GoalAllocationSection(
                transactionAmount: 1000,
                transactionType: TransactionType.income,
                onAllocationsChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      
      // Verify header is visible
      expect(find.text('Allocate to goals'), findsOneWidget);
      
      // Verify content is hidden
      expect(find.byType(Wrap), findsNothing);
    });
    
    testWidgets('expands when tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eligibleGoalsForAllocationProvider.overrideWith(
              (ref) => Future.value([
                Goal(
                  id: 'goal1',
                  name: 'Emergency Fund',
                  targetAmount: 1000,
                  currentAmount: 500,
                  targetDate: DateTime.now().add(Duration(days: 365)),
                  createdDate: DateTime.now(),
                  icon: Icons.savings,
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GoalAllocationSection(
                transactionAmount: 1000,
                transactionType: TransactionType.income,
                onAllocationsChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      
      // Tap to expand
      await tester.tap(find.text('Allocate to goals'));
      await tester.pumpAndSettle();
      
      // Verify goals are visible
      expect(find.text('Emergency Fund'), findsOneWidget);
    });
    
    testWidgets('hides for expense transactions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GoalAllocationSection(
                transactionAmount: 100,
                transactionType: TransactionType.expense,
                onAllocationsChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      
      // Should not render at all for expenses
      expect(find.text('Allocate to goals'), findsNothing);
    });
    
    testWidgets('shows goal selection chips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eligibleGoalsForAllocationProvider.overrideWith(
              (ref) => Future.value([
                Goal(
                  id: 'goal1',
                  name: 'Emergency Fund',
                  targetAmount: 1000,
                  currentAmount: 500,
                  targetDate: DateTime.now().add(Duration(days: 365)),
                  createdDate: DateTime.now(),
                  icon: Icons.savings,
                ),
                Goal(
                  id: 'goal2',
                  name: 'Vacation',
                  targetAmount: 5000,
                  currentAmount: 2000,
                  targetDate: DateTime.now().add(Duration(days: 180)),
                  createdDate: DateTime.now(),
                  icon: Icons.flight,
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GoalAllocationSection(
                transactionAmount: 1000,
                transactionType: TransactionType.income,
                onAllocationsChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      
      // Expand
      await tester.tap(find.text('Allocate to goals'));
      await tester.pumpAndSettle();
      
      // Verify both goals shown
      expect(find.text('Emergency Fund'), findsOneWidget);
      expect(find.text('Vacation'), findsOneWidget);
    });
    
    testWidgets('adds allocation input when goal selected', (tester) async {
      final allocations = <GoalContribution>[];
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eligibleGoalsForAllocationProvider.overrideWith(
              (ref) => Future.value([
                Goal(
                  id: 'goal1',
                  name: 'Emergency Fund',
                  targetAmount: 1000,
                  currentAmount: 500,
                  targetDate: DateTime.now().add(Duration(days: 365)),
                  createdDate: DateTime.now(),
                  icon: Icons.savings,
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GoalAllocationSection(
                transactionAmount: 1000,
                transactionType: TransactionType.income,
                onAllocationsChanged: (newAllocations) {
                  allocations.addAll(newAllocations);
                },
              ),
            ),
          ),
        ),
      );
      
      // Expand and select goal
      await tester.tap(find.text('Allocate to goals'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Emergency Fund'));
      await tester.pumpAndSettle();
      
      // Verify allocation input appears
      expect(find.text('Amount to contribute'), findsOneWidget);
      expect(find.text('Need: \$500 more'), findsOneWidget);
      
      // Verify quick action buttons
      expect(find.text('Suggested'), findsOneWidget);
      expect(find.text('All needed'), findsOneWidget);
    });
    
    testWidgets('updates allocation summary correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eligibleGoalsForAllocationProvider.overrideWith(
              (ref) => Future.value([
                Goal(
                  id: 'goal1',
                  name: 'Emergency Fund',
                  targetAmount: 1000,
                  currentAmount: 500,
                  targetDate: DateTime.now().add(Duration(days: 365)),
                  createdDate: DateTime.now(),
                  icon: Icons.savings,
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GoalAllocationSection(
                transactionAmount: 1000,
                transactionType: TransactionType.income,
                onAllocationsChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      
      // Expand and select goal
      await tester.tap(find.text('Allocate to goals'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Emergency Fund'));
      await tester.pumpAndSettle();
      
      // Enter allocation amount
      await tester.enterText(
        find.byKey(Key('goal_allocation_amount')),
        '200',
      );
      await tester.pumpAndSettle();
      
      // Verify summary updates
      expect(find.text('Transaction amount'), findsOneWidget);
      expect(find.text('\$1,000.00'), findsOneWidget);
      expect(find.text('To goals (1)'), findsOneWidget);
      expect(find.text('\$200.00'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('\$800.00'), findsOneWidget);
    });
    
    testWidgets('shows error when allocation exceeds transaction', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eligibleGoalsForAllocationProvider.overrideWith(
              (ref) => Future.value([
                Goal(
                  id: 'goal1',
                  name: 'Emergency Fund',
                  targetAmount: 1000,
                  currentAmount: 500,
                  targetDate: DateTime.now().add(Duration(days: 365)),
                  createdDate: DateTime.now(),
                  icon: Icons.savings,
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GoalAllocationSection(
                transactionAmount: 500,
                transactionType: TransactionType.income,
                onAllocationsChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Allocate to goals'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Emergency Fund'));
      await tester.pumpAndSettle();
      
      // Try to allocate more than available
      await tester.enterText(
        find.byKey(Key('goal_allocation_amount')),
        '600',
      );
      await tester.pumpAndSettle();
      
      // Verify error message
      expect(find.text('Exceeds transaction amount'), findsOneWidget);
    });
  });
}

7. Edge Cases & Error Handling
7.1 Edge Cases to Handle
dart// lib/features/transactions/domain/usecases/add_transaction_with_goal_allocation.dart

class AddTransactionWithGoalAllocation {
  // ... existing code ...
  
  Future<Result<TransactionWithGoalUpdates>> call(
    Transaction transaction,
  ) async {
    // EDGE CASE 1: Zero or negative amounts
    if (transaction.amount <= 0) {
      return Result.error(
        Failure.validation(
          'Transaction amount must be positive',
          {'amount': 'Must be greater than zero'},
        ),
      );
    }
    
    // EDGE CASE 2: Future dated transactions with goal allocations
    if (transaction.date.isAfter(DateTime.now()) && 
        transaction.hasGoalAllocations) {
      // Decision: Allow but warn user, or disallow?
      // For now: Allow but don't update goal until transaction date
      _logger.warning(
        'Future-dated transaction with goal allocation: ${transaction.id}',
      );
    }
    
    // EDGE CASE 3: Empty goal allocations list
    if (transaction.goalAllocations?.isEmpty == true) {
      // Treat as no allocations
      return await _addTransactionWithoutGoals(transaction);
    }
    
    // EDGE CASE 4: Multiple allocations to same goal
    final goalIds = transaction.goalAllocations!.map((a) => a.goalId).toList();
    final uniqueGoalIds = goalIds.toSet();
    
    if (goalIds.length != uniqueGoalIds.length) {
      return Result.error(
        Failure.validation(
          'Cannot allocate to the same goal multiple times',
          {'allocations': 'Duplicate goal allocations detected'},
        ),
      );
    }
    
    // EDGE CASE 5: Total allocations exceed transaction amount
    final totalAllocated = transaction.totalGoalAllocations;
    if (totalAllocated > transaction.amount) {
      return Result.error(
        Failure.validation(
          'Goal allocations exceed transaction amount',
          {
            'allocations': 
                'Total \$${totalAllocated.toStringAsFixed(2)} exceeds '
                '\$${transaction.amount.toStringAsFixed(2)}'
          },
        ),
      );
    }
    
    // EDGE CASE 6: Allocation with zero or negative amount
    for (final allocation in transaction.goalAllocations!) {
      if (allocation.amount <= 0) {
        return Result.error(
          Failure.validation(
            'Invalid allocation amount',
            {'allocation': 'Amount must be greater than zero'},
          ),
        );
      }
    }
    
    // EDGE CASE 7: Allocating to non-existent goal
    for (final allocation in transaction.goalAllocations!) {
      final goalResult = await _goalRepository.getById(allocation.goalId);
      
      if (goalResult.isError) {
        return Result.error(
          Failure.validation(
            'Invalid goal reference',
            {'goal': 'Goal ${allocation.goalId} not found'},
          ),
        );
      }
      
      final goal = goalResult.dataOrNull!;
      
      // EDGE CASE 8: Allocating to completed goal
      if (goal.isCompleted) {
        return Result.error(
          Failure.validation(
            'Cannot contribute to completed goal',
            {'goal': '${goal.name} is already completed'},
          ),
        );
      }
      
      // EDGE CASE 9: Allocation exceeds remaining goal amount
      // Decision: Allow over-contribution or cap at remaining?
      // For now: Allow but warn
      if (allocation.amount > goal.remainingAmount) {
        _logger.warning(
          'Allocation of \$${allocation.amount} exceeds remaining '
          '\$${goal.remainingAmount} for goal ${goal.name}',
        );
      }
      
      // EDGE CASE 10: Goal target date already passed
      if (goal.targetDate.isBefore(DateTime.now()) && !goal.isCompleted) {
        _logger.warning(
          'Contributing to overdue goal: ${goal.name}',
        );
      }
    }
    
    // EDGE CASE 11: Expense transaction with goal allocations
    if (transaction.type == TransactionType.expense) {
      // Decision: Disallow or allow for specific categories?
      // For now: Disallow to prevent confusion
      return Result.error(
        Failure.validation(
          'Cannot allocate expenses to goals',
          {'type': 'Only income can be allocated to goals'},
        ),
      );
    }
    
    // Continue with normal flow...
    return await _processTransaction(transaction);
  }
  
  Future<Result<TransactionWithGoalUpdates>> _processTransaction(
    Transaction transaction,
  ) async {
    try {
      // Add transaction
      final txResult = await _transactionRepository.add(transaction);
      if (txResult.isError) {
        return Result.error(txResult.failureOrNull!);
      }
      
      final addedTransaction = txResult.dataOrNull!;
      final updatedGoals = <Goal>[];
      
      // Process each allocation
      for (final allocation in transaction.goalAllocations!) {
        try {
          // Link to transaction
          final contributionWithTx = allocation.copyWith(
            transactionId: addedTransaction.id,
          );
          
          // Add to goal
          final goalResult = await _goalRepository.addContribution(
            allocation.goalId,
            contributionWithTx,
          );
          
          if (goalResult.isSuccess) {
            final updatedGoal = goalResult.dataOrNull!;
            updatedGoals.add(updatedGoal);
            
            // Check milestones
            await _checkMilestones(updatedGoal, allocation.amount);
          } else {
            // EDGE CASE 12: Partial failure - some goals updated, some failed
            _logger.error(
              'Failed to update goal ${allocation.goalId}: '
              '${goalResult.failureOrNull}',
            );
            
            // Continue processing other goals
            // Could implement rollback here if needed
          }
        } catch (e, stackTrace) {
          _logger.error(
            'Unexpected error processing allocation: $e',
            e,
            stackTrace,
          );
          // Continue with other allocations
        }
      }
      
      return Result.success(
        TransactionWithGoalUpdates(
          transaction: addedTransaction,
          updatedGoals: updatedGoals,
        ),
      );
      
    } catch (e, stackTrace) {
      _logger.error('Failed to process transaction: $e', e, stackTrace);
      
      // EDGE CASE 13: Database error during transaction
      return Result.error(
        Failure.unknown('Failed to process transaction: $e'),
      );
    }
  }
}
7.2 Rollback Strategy
dart// lib/features/transactions/domain/usecases/rollback_transaction.dart

class RollbackTransaction {
  final TransactionRepository _transactionRepository;
  final GoalRepository _goalRepository;
  
  RollbackTransaction(
    this._transactionRepository,
    this._goalRepository,
  );
  
  /// Rollback a transaction and its goal contributions
  /// Use case: User deletes transaction after it was added
  Future<Result<void>> call(String transactionId) async {
    try {
      // 1. Get transaction with allocations
      final txResult = await _transactionRepository.getById(transactionId);
      if (txResult.isError) {
        return Result.error(txResult.failureOrNull!);
      }
      
      final transaction = txResult.dataOrNull!;
      
      // 2. Rollback goal contributions
      if (transaction.hasGoalAllocations) {
        for (final allocation in transaction.goalAllocations!) {
          // Get current goal state
          final goalResult = await _goalRepository.getById(allocation.goalId);
          
          if (goalResult.isSuccess) {
            final goal = goalResult.dataOrNull!;
            
            // Subtract contribution amount
            final updatedGoal = goal.copyWith(
              currentAmount: goal.currentAmount - allocation.amount,
              contributions: goal.contributions
                  .where((c) => c.id != allocation.id)
                  .toList(),
              isCompleted: false, // Reset if was completed by this contribution
            );
            
            await _goalRepository.update(updatedGoal);
          }
        }
      }
      
      // 3. Delete transaction
      final deleteResult = await _transactionRepository.delete(transactionId);
      
      return deleteResult;
      
    } catch (e) {
      return Result.error(
        Failure.unknown('Failed to rollback transaction: $e'),
      );
    }
  }
}

8. Performance Optimizations
8.1 Lazy Loading Goals
dart// lib/features/goals/presentation/providers/goal_providers.dart

@riverpod
Future<List<Goal>> paginatedEligibleGoals(
  PaginatedEligibleGoalsRef ref, {
  required int page,
  required int pageSize,
}) async {
  final useCase = ref.read(getEligibleGoalsForAllocationProvider);
  
  // Get all eligible goals
  final result = await useCase(
    amount: 1000, // Use a default or get from form
    transactionType: TransactionType.income,
  );
  
  return result.when(
    success: (goals) {
      final start = page * pageSize;
      final end = min(start + pageSize, goals.length);
      
      if (start >= goals.length) return [];
      
      return goals.sublist(start, end);
    },
    error: (_) => [],
  );
}
8.2 Debounced Suggestions
dart// lib/features/transactions/presentation/providers/transaction_form_provider.dart

class TransactionForm extends _$TransactionForm {
  Timer? _suggestionDebounce;
  
  @override
  TransactionFormState build() {
    ref.onDispose(() {
      _suggestionDebounce?.cancel();
    });
    
    return TransactionFormState(date: DateTime.now());
  }
  
  void setAmount(String amount) {
    state = state.copyWith(amount: amount);
    
    // Debounce suggestion calculation
    _suggestionDebounce?.cancel();
    _suggestionDebounce = Timer(Duration(milliseconds: 500), () {
      _updateSuggestions();
    });
  }
  
  Future<void> _updateSuggestions() async {
    final amount = double.tryParse(state.amount);
    if (amount == null || amount <= 0) return;
    
    // Trigger suggestion provider update
    ref.invalidate(suggestedGoalAllocationsProvider);
  }
}
8.3 Caching Goal Data
dart// lib/features/goals/presentation/providers/goal_cache_provider.dart

@riverpod
class GoalCache extends _$GoalCache {
  final _cache = <String, Goal>{};
  Timer? _invalidationTimer;
  
  @override
  Map<String, Goal> build() {
    // Auto-invalidate cache after 5 minutes
    _invalidationTimer = Timer(Duration(minutes: 5), () {
      _cache.clear();
      ref.invalidateSelf();
    });
    
    ref.onDispose(() {
      _invalidationTimer?.cancel();
    });
    
    return {};
  }
  
  Goal? getGoal(String id) {
    return _cache[id];
  }
  
  void cacheGoal(Goal goal) {
    _cache[goal.id] = goal;
  }
  
  void cacheGoals(List<Goal> goals) {
    for (final goal in goals) {
      _cache[goal.id] = goal;
    }
  }
  
  void invalidateGoal(String id) {
    _cache.remove(id);
  }
  
  void clearCache() {
    _cache.clear();
  }
}

// Use in repository
@riverpod
Future<Goal> cachedGoal(CachedGoalRef ref, String id) async {
  // Check cache first
  final cached = ref.read(goalCacheProvider.notifier).getGoal(id);
  if (cached != null) return cached;
  
  // Fetch from repository
  final result = await ref.read(goalRepositoryProvider).getById(id);
  
  return result.when(
    success: (goal) {
      // Cache for future use
      ref.read(goalCacheProvider.notifier).cacheGoal(goal);
      return goal;
    },
    error: (failure) => throw Exception(failure.toString()),
  );
}

9. Analytics & Monitoring
9.1 Track Key Events
dart// lib/core/analytics/analytics_events.dart

class AnalyticsEvents {
  static const goalAllocationAttempted = 'goal_allocation_attempted';
  static const goalAllocationCompleted = 'goal_allocation_completed';
  static const goalAllocationFailed = 'goal_allocation_failed';
  static const goalMilestoneReached = 'goal_milestone_reached';
  static const goalCompleted = 'goal_completed';
}

// In use case
class AddTransactionWithGoalAllocation {
  final AnalyticsService _analytics;
  
  Future<Result<TransactionWithGoalUpdates>> call(
    Transaction transaction,
  ) async {
    if (transaction.hasGoalAllocations) {
      await _analytics.logEvent(
        AnalyticsEvents.goalAllocationAttempted,
        parameters: {
          'transaction_amount': transaction.amount,
          'allocation_count': transaction.goalAllocations!.length,
          'total_allocated': transaction.totalGoalAllocations,
        },
      );
    }
    
    // ... process transaction ...
    
    if (result.isSuccess && transaction.hasGoalAllocations) {
      await _analytics.logEvent(
        AnalyticsEvents.goalAllocationCompleted,
        parameters: {
          'transaction_id': transaction.id,
          'goals_updated': result.dataOrNull!.updatedGoals.length,
        },
      );
    }
    
    return result;
  }
}
9.2 Performance Metrics
dart// lib/core/monitoring/performance_monitor.dart

class PerformanceMonitor {
  static Future<T> trackOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      
      stopwatch.stop();
      
      // Log performance metric
      _logMetric(
        operationName,
        stopwatch.elapsedMilliseconds,
        success: true,
      );
      
      return result;
      
    } catch (e) {
      stopwatch.stop();
      
      _logMetric(
        operationName,
        stopwatch.elapsedMilliseconds,
        success: false,
      );
      
      rethrow;
    }
  }
  
  static void _logMetric(String operation, int duration, {required bool success}) {
    FirebaseAnalytics.instance.logEvent(
      name: 'performance_metric',
      parameters: {
        'operation': operation,
        'duration_ms': duration,
        'success': success,
      },
    );
    
    // Also log to console in debug mode
    if (kDebugMode) {
      print('⏱️ $operation: ${duration}ms (${success ? 'SUCCESS' : 'FAILED'})');
    }
  }
}

// Usage in repository
Future<Result<Transaction>> add(Transaction transaction) async {
  return await PerformanceMonitor.trackOperation(
    operationName: 'add_transaction_with_goals',
    operation: () => _addTransactionInternal(transaction),
  );RetrySContinuedart  );
}

10. User Feedback & Success States
10.1 Progressive Success Feedback
dart// lib/features/transactions/presentation/widgets/success_feedback.dart

class TransactionSuccessFeedback {
  static void show({
    required BuildContext context,
    required Transaction transaction,
    required List<Goal> updatedGoals,
  }) {
    if (updatedGoals.isEmpty) {
      // Simple success for transaction without goals
      _showSimpleSuccess(context, transaction);
    } else if (updatedGoals.length == 1) {
      // Detailed success for single goal
      _showSingleGoalSuccess(context, transaction, updatedGoals.first);
    } else {
      // Summary for multiple goals
      _showMultipleGoalsSuccess(context, transaction, updatedGoals);
    }
  }
  
  static void _showSimpleSuccess(
    BuildContext context,
    Transaction transaction,
  ) {
    HapticFeedback.mediumImpact();
    
    SmartDialog.showToast(
      '✅ Transaction added: \$${transaction.amount.toStringAsFixed(2)}',
      displayTime: Duration(seconds: 2),
    );
  }
  
  static void _showSingleGoalSuccess(
    BuildContext context,
    Transaction transaction,
    Goal goal,
  ) {
    HapticFeedback.heavyImpact();
    
    final allocation = transaction.goalAllocations!.first;
    
    // Check if goal was completed
    if (goal.isCompleted) {
      _showGoalCompletionCelebration(context, goal, allocation);
      return;
    }
    
    // Check if milestone reached
    final previousPercentage = 
        ((goal.currentAmount - allocation.amount) / goal.targetAmount) * 100;
    final currentPercentage = goal.percentageComplete;
    
    final milestoneCrossed = _getMilestoneCrossed(
      previousPercentage,
      currentPercentage,
    );
    
    if (milestoneCrossed != null) {
      _showMilestoneCelebration(context, goal, allocation, milestoneCrossed);
    } else {
      _showStandardGoalSuccess(context, goal, allocation);
    }
  }
  
  static void _showGoalCompletionCelebration(
    BuildContext context,
    Goal goal,
    GoalContribution allocation,
  ) {
    // Play celebration sound
    // SystemSound.play(SystemSoundType.alert);
    
    SmartDialog.show(
      alignment: Alignment.center,
      builder: (context) => Container(
        margin: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppDimensions.borderRadiusXl,
          boxShadow: AppDimensions.shadowLg,
        ),
        child: Stack(
          children: [
            // Confetti animation overlay
            Positioned.fill(
              child: ConfettiWidget(
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [
                  AppColors.success,
                  AppColors.primary,
                  AppColors.warning,
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/goal_completed.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                  ),
                  
                  Text(
                    '🎉 Goal Completed!',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(AppSpacing.md),
                  
                  Text(
                    goal.name,
                    style: AppTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(AppSpacing.md),
                  
                  Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: AppDimensions.borderRadiusMd,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.savings_rounded,
                              color: AppColors.success,
                              size: 32,
                            ),
                            Gap(AppSpacing.md),
                            Text(
                              '\$${goal.targetAmount.toStringAsFixed(0)}',
                              style: AppTypography.displayMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Gap(AppSpacing.sm),
                        Text(
                          'Target amount reached!',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(AppSpacing.xl),
                  
                  // Motivational message
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: AppDimensions.borderRadiusMd,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getMotivationalMessage(goal),
                          style: AppTypography.bodyLarge.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(AppSpacing.sm),
                        Text(
                          'Time to celebrate! 🎊',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(AppSpacing.xl),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Share',
                          variant: AppButtonVariant.outline,
                          icon: Icons.share_rounded,
                          onPressed: () {
                            Navigator.pop(context);
                            _shareGoalCompletion(goal);
                          },
                        ),
                      ),
                      Gap(AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          label: 'View Goal',
                          icon: Icons.flag_rounded,
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/goals/${goal.id}');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  static void _showMilestoneCelebration(
    BuildContext context,
    Goal goal,
    GoalContribution allocation,
    int milestone,
  ) {
    HapticFeedback.heavyImpact();
    
    SmartDialog.show(
      alignment: Alignment.center,
      builder: (context) => Container(
        margin: EdgeInsets.all(AppSpacing.xl),
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppDimensions.borderRadiusXl,
          boxShadow: AppDimensions.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/milestone_${milestone}.json',
              width: 150,
              height: 150,
              repeat: false,
            ),
            
            Text(
              '🎯 ${milestone}% Milestone!',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppSpacing.md),
            
            Text(
              goal.name,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(AppSpacing.lg),
            
            // Progress indicator
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: goal.percentageComplete / 100,
                    strokeWidth: 12,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$milestone%',
                        style: AppTypography.displaySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'complete',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
            Gap(AppSpacing.xl),
            
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                borderRadius: AppDimensions.borderRadiusMd,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current:',
                        style: AppTypography.bodyMedium,
                      ),
                      Text(
                        '\$${goal.currentAmount.toStringAsFixed(0)}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Gap(AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining:',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${goal.remainingAmount.toStringAsFixed(0)}',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(AppSpacing.xl),
            
            Text(
              _getMilestoneMessage(milestone),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(AppSpacing.xl),
            
            AppButton(
              label: 'Continue',
              onPressed: () => Navigator.pop(context),
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  static void _showStandardGoalSuccess(
    BuildContext context,
    Goal goal,
    GoalContribution allocation,
  ) {
    SmartDialog.showToast(
      '✅ \$${allocation.amount.toStringAsFixed(0)} added to ${goal.name}\n'
      '${goal.percentageComplete.toStringAsFixed(0)}% complete',
      displayTime: Duration(seconds: 3),
    );
  }
  
  static void _showMultipleGoalsSuccess(
    BuildContext context,
    Transaction transaction,
    List<Goal> updatedGoals,
  ) {
    HapticFeedback.mediumImpact();
    
    final totalAllocated = transaction.totalGoalAllocations;
    
    SmartDialog.show(
      alignment: Alignment.center,
      builder: (context) => Container(
        margin: EdgeInsets.all(AppSpacing.xl),
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppDimensions.borderRadiusXl,
          boxShadow: AppDimensions.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 80,
              color: AppColors.success,
            ).animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
            Gap(AppSpacing.lg),
            
            Text(
              'Contributions Added!',
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppSpacing.md),
            
            Text(
              '\$${totalAllocated.toStringAsFixed(0)} distributed across ${updatedGoals.length} goals',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(AppSpacing.xl),
            
            // List of updated goals
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: updatedGoals.length,
                separatorBuilder: (_, __) => Gap(AppSpacing.md),
                itemBuilder: (context, index) {
                  final goal = updatedGoals[index];
                  final allocation = transaction.goalAllocations!
                      .firstWhere((a) => a.goalId == goal.id);
                  
                  return Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: AppDimensions.borderRadiusMd,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            goal.icon,
                            color: AppColors.primary,
                            size: AppDimensions.iconMd,
                          ),
                        ),
                        Gap(AppSpacing.md),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.name,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Gap(AppSpacing.xs),
                              Text(
                                '+\$${allocation.amount.toStringAsFixed(0)} • ${goal.percentageComplete.toStringAsFixed(0)}% complete',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: AppDimensions.iconMd,
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(delay: (index * 100).ms)
                    .slideX(begin: -0.1, end: 0);
                },
              ),
            ),
            Gap(AppSpacing.xl),
            
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'View Goals',
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/goals');
                    },
                  ),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Done',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  static int? _getMilestoneCrossed(
    double previousPercentage,
    double currentPercentage,
  ) {
    const milestones = [25, 50, 75];
    
    for (final milestone in milestones) {
      if (previousPercentage < milestone && currentPercentage >= milestone) {
        return milestone;
      }
    }
    
    return null;
  }
  
  static String _getMotivationalMessage(Goal goal) {
    final messages = [
      'Outstanding achievement! Your dedication has paid off!',
      'You did it! Your financial goal is now a reality!',
      'Incredible work! You\'ve reached your savings target!',
      'Congratulations on this amazing accomplishment!',
      'Your persistence and discipline have led to success!',
    ];
    
    return messages[goal.id.hashCode % messages.length];
  }
  
  static String _getMilestoneMessage(int milestone) {
    switch (milestone) {
      case 25:
        return 'Great start! You\'re a quarter of the way there!';
      case 50:
        return 'Halfway there! Keep up the excellent work!';
      case 75:
        return 'Almost there! You\'re in the home stretch!';
      default:
        return 'Keep going! You\'re making great progress!';
    }
  }
  
  static Future<void> _shareGoalCompletion(Goal goal) async {
    // Share functionality
    try {
      await Share.share(
        'I just completed my "${goal.name}" savings goal of '
        '\$${goal.targetAmount.toStringAsFixed(0)} using Budget Tracker! 🎉',
        subject: 'Goal Completed!',
      );
    } catch (e) {
      print('Error sharing: $e');
    }
  }
}

11. Documentation & Developer Guide
11.1 Implementation Checklist
markdown# Goal Allocation Feature - Implementation Checklist

## Phase 1: Foundation (Week 1)
- [ ] Create domain entities
  - [ ] GoalContribution entity
  - [ ] Update Transaction entity with goalAllocations
  - [ ] Update Goal entity with contributions list
- [ ] Create repository interfaces
  - [ ] Add addContribution to GoalRepository
  - [ ] Add getEligibleForAllocation to GoalRepository
- [ ] Setup Hive data models
  - [ ] GoalContributionDTO
  - [ ] Update TransactionDTO
  - [ ] Update GoalDTO
- [ ] Create mappers
  - [ ] GoalContributionMapper
  - [ ] Update TransactionMapper
  - [ ] Update GoalMapper

## Phase 2: Business Logic (Week 2)
- [ ] Implement use cases
  - [ ] AddTransactionWithGoalAllocation
  - [ ] GetEligibleGoalsForAllocation
  - [ ] SuggestGoalAllocation
  - [ ] RollbackTransaction (for error recovery)
- [ ] Add validation logic
  - [ ] Allocation amount validation
  - [ ] Goal eligibility checks
  - [ ] Completed goal prevention
- [ ] Implement milestone detection
  - [ ] 25%, 50%, 75%, 100% detection
  - [ ] Notification triggers

## Phase 3: Data Layer (Week 3)
- [ ] Implement repository methods
  - [ ] GoalRepositoryImpl.addContribution
  - [ ] GoalRepositoryImpl.getEligibleForAllocation
  - [ ] TransactionRepositoryImpl updates
- [ ] Add database queries
  - [ ] Get transactions with allocations
  - [ ] Get goals with contributions
  - [ ] Get contributions in date range
- [ ] Implement data source methods
  - [ ] Save contributions to Hive
  - [ ] Link contributions to transactions
  - [ ] Update goal current amounts

## Phase 4: Presentation Layer (Week 4)
- [ ] Create state management
  - [ ] TransactionFormProvider updates
  - [ ] EligibleGoalsProvider
  - [ ] SuggestedAllocationsProvider
- [ ] Build UI components
  - [ ] GoalAllocationSection
  - [ ] GoalSelectionChip
  - [ ] GoalAllocationInput
  - [ ] AllocationSummary
- [ ] Update Add Transaction sheet
  - [ ] Integrate goal allocation section
  - [ ] Add form validation
  - [ ] Handle submission

## Phase 5: Success Feedback (Week 5)
- [ ] Implement success states
  - [ ] Simple transaction success
  - [ ] Single goal contribution success
  - [ ] Multiple goals success
  - [ ] Milestone celebration dialog
  - [ ] Goal completion celebration
- [ ] Add animations
  - [ ] Lottie animations for celebrations
  - [ ] Confetti effects
  - [ ] Progress animations
- [ ] Add haptic feedback
  - [ ] Light feedback for selections
  - [ ] Medium for actions
  - [ ] Heavy for celebrations

## Phase 6: Testing (Week 6)
- [ ] Unit tests
  - [ ] Use case tests
  - [ ] Validation logic tests
  - [ ] Milestone detection tests
- [ ] Integration tests
  - [ ] Full flow test
  - [ ] Error handling tests
  - [ ] Edge case tests
- [ ] Widget tests
  - [ ] GoalAllocationSection tests
  - [ ] Form validation tests
  - [ ] Success dialog tests

## Phase 7: Polish (Week 7)
- [ ] Performance optimization
  - [ ] Lazy loading goals
  - [ ] Debounced suggestions
  - [ ] Goal data caching
- [ ] Analytics integration
  - [ ] Track allocation attempts
  - [ ] Track completion rates
  - [ ] Track milestone achievements
- [ ] Error handling
  - [ ] User-friendly error messages
  - [ ] Rollback on failures
  - [ ] Offline support

## Phase 8: Documentation (Week 8)
- [ ] Code documentation
  - [ ] Document all public APIs
  - [ ] Add usage examples
  - [ ] Document edge cases
- [ ] User documentation
  - [ ] In-app tutorial
  - [ ] Help articles
  - [ ] Video walkthrough
- [ ] Developer documentation
  - [ ] Architecture diagram
  - [ ] Data flow diagram
  - [ ] API reference
11.2 API Reference
dart/**
 * Goal Allocation API Reference
 * ==============================
 * 
 * This document provides a comprehensive reference for integrating
 * goal contributions into the transaction flow.
 */

// DOMAIN LAYER
// ============

/**
 * GoalContribution
 * 
 * Represents a contribution made to a savings goal.
 * Can be standalone or linked to a transaction.
 * 
 * Properties:
 * - id: Unique identifier
 * - goalId: Reference to the goal
 * - amount: Contribution amount
 * - date: When the contribution was made
 * - transactionId: Optional link to source transaction
 * - note: Optional note
 * 
 * Usage:
 * ```dart
 * final contribution = GoalContribution(
 *   id: uuid.v4(),
 *   goalId: 'goal123',
 *   amount: 200.0,
 *   date: DateTime.now(),
 *   transactionId: 'tx456',
 * );
 * ```
 */
@freezed
class GoalContribution with _$GoalContribution {
  const factory GoalContribution({
    required String id,
    required String goalId,
    required double amount,
    required DateTime date,
    String? transactionId,
    String? note,
  }) = _GoalContribution;
}

/**
 * AddTransactionWithGoalAllocation
 * 
 * Use case for adding a transaction with optional goal allocations.
 * 
 * Responsibilities:
 * - Validates transaction and allocations
 * - Saves transaction to database
 * - Updates all affected goals
 * - Detects and triggers milestone celebrations
 * - Handles partial failures gracefully
 * 
 * Parameters:
 * - transaction: Transaction entity with optional goalAllocations
 * 
 * Returns:
 * - Result<TransactionWithGoalUpdates>: Success with updated goals or failure
 * 
 * Validation Rules:
 * 1. Transaction amount must be > 0
 * 2. Total allocations must not exceed transaction amount
 * 3. Each allocation amount must be > 0
 * 4. Goals must exist and not be completed
 * 5. No duplicate goal allocations
 * 6. Only income transactions can have allocations
 * 
 * Example:
 * ```dart
 * final transaction = Transaction(
 *   id: uuid.v4(),
 *   amount: 1000,
 *   categoryId: 'salary',
 *   date: DateTime.now(),
 *   type: TransactionType.income,
 *   goalAllocations: [
 *     GoalContribution(
 *       id: uuid.v4(),
 *       goalId: 'emergency_fund',
 *       amount: 200,
 *       date: DateTime.now(),
 *     ),
 *   ],
 * );
 * 
 * final result = await addTransactionWithGoalAllocation(transaction);
 * 
 * result.when(
 *   success: (data) {
 *     print('Transaction added');
 *     print('${data.updatedGoals.length} goals updated');
 *   },
 *   error: (failure) => print('Error: $failure'),
 * );
 * ```
 */

// PRESENTATION LAYER
// ==================

/**
 * GoalAllocationSection
 * 
 * Widget for selecting and allocating transaction amounts to goals.
 * 
 * Properties:
 * - transactionAmount: Total transaction amount available
 * - transactionType: Income or Expense (only shows for income)
 * - onAllocationsChanged: Callback when allocations change
 * 
 * Features:
 * - Collapsible section
 * - Fetches eligible goals automatically
 * - Shows goal progress preview
 * - Validates allocations in real-time
 * - Provides quick action buttons (Suggested, All needed)
 * - Displays allocation summary
 * 
 * Usage:
 * ```dart
 * GoalAllocationSection(
 *   transactionAmount: 1000,
 *   transactionType: TransactionType.income,
 *   onAllocationsChanged: (allocations) {
 *     // Update form state
 *     ref.read(transactionFormProvider.notifier)
 *         .setGoalAllocations(allocations);
 *   },
 * )
 * ```
 */

// DATA LAYER
// ==========

/**
 * GoalRepository.addContribution
 * 
 * Adds a contribution to a goal and updates its current amount.
 * 
 * Parameters:
 * - goalId: The goal to contribute to
 * - contribution: The contribution to add
 * 
 * Returns:
 * - Result<Goal>: Updated goal with new contribution
 * 
 * Side Effects:
 * - Saves contribution to database
 * - Updates goal's current amount
 * - Adds contribution to goal's contributions list
 * - Marks goal as completed if target reached
 * 
 * Example:
 * ```dart
 * final result = await goalRepository.addContribution(
 *   'goal123',
 *   contribution,
 * );
 * ```
 */

// TESTING
// =======

/**
 * Testing Goal Allocations
 * 
 * Unit Test Example:
 * ```dart
 * test('should add transaction with goal allocation', () async {
 *   // Arrange
 *   final transaction = Transaction(...);
 *   when(mockRepository.add(any)).thenAnswer((_) async => Result.success(transaction));
 *   
 *   // Act
 *   final result = await useCase(transaction);
 *   
 *   // Assert
 *   expect(result, isA<Success>());
 *   verify(mockGoalRepository.addContribution(any, any)).called(1);
 * });
 * ```
 * 
 * Widget Test Example:
 * ```dart
 * testWidgets('should display goal allocation section', (tester) async {
 *   await tester.pumpWidget(GoalAllocationSection(...));
 *   expect(find.text('Allocate to goals'), findsOneWidget);
 * });
 * ```
 */

12. Summary & Recommendations
12.1 Key Implementation Points

Clean Separation of Concerns

Domain logic isolated in use cases
UI components are dumb and reactive
Data layer handles persistence only


User Experience First

Progressive disclosure (collapsed by default)
Instant feedback and validation
Celebratory moments for milestones
Clear error messages


Performance Optimized

Lazy loading of goals
Debounced suggestions
Efficient database queries
Cached data where appropriate


Robust Error Handling

Comprehensive validation
Graceful degradation
Rollback on partial failures
Clear error messages


Well Tested

Unit tests for business logic
Integration tests for full flow
Widget tests for UI components
Edge case coverage



12.2 Success Metrics
Track these metrics post-implementation:

Adoption Rate: % of income transactions with goal allocations
Goal Completion Rate: % of goals completed via transaction allocations
Average Allocation: Average amount/percentage allocated to goals
Time to Goal: Reduction in time to complete goals
User Satisfaction: App store ratings mentioning this feature

12.3 Future Enhancements
Consider these additions in future iterations:

Smart Allocation

ML-based suggestions based on user behavior
Automatic allocation rules
Round-up contributions


Advanced Features

Recurring transaction allocations
Split income across multiple goals automatically
Goal prioritization system


Social Features

Share goal achievements
Collaborative goals with family
Goal templates from community


Integrations

Direct bank account transfers to goal "accounts"
Investment account integration
Bill payment integration




This comprehensive guide provides everything needed for an AI copilot to implement the goal allocation feature from scratch. The architecture is clean, testable, and follows Flutter/Dart best practices while maintaining excellent UX throughout.