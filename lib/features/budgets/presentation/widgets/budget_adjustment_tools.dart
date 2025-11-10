import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Budget adjustment tools with drag handles for category rebalancing and smart suggestions
class BudgetAdjustmentTools extends StatefulWidget {
  const BudgetAdjustmentTools({
    super.key,
    required this.categories,
    required this.totalBudget,
    required this.onCategoriesChanged,
    this.enableDragAdjustment = true,
    this.enableSmartSuggestions = true,
    this.onSuggestionApplied,
  });

  final List<BudgetCategoryAdjustmentData> categories;
  final double totalBudget;
  final Function(List<BudgetCategoryAdjustmentData>) onCategoriesChanged;
  final bool enableDragAdjustment;
  final bool enableSmartSuggestions;
  final Function(BudgetAdjustmentSuggestion)? onSuggestionApplied;

  @override
  State<BudgetAdjustmentTools> createState() => _BudgetAdjustmentToolsState();
}

class _BudgetAdjustmentToolsState extends State<BudgetAdjustmentTools>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  List<BudgetAdjustmentSuggestion> _suggestions = [];
  final bool _isDragging = false;
  int? _draggedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _generateSuggestions();
  }

  @override
  void didUpdateWidget(BudgetAdjustmentTools oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories ||
        oldWidget.totalBudget != widget.totalBudget) {
      _generateSuggestions();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateSuggestions() {
    _suggestions = [];

    if (!widget.enableSmartSuggestions) return;

    final totalAllocated = widget.categories.fold<double>(0, (sum, cat) => sum + cat.amount);
    final difference = widget.totalBudget - totalAllocated;

    // Suggestion 1: Balance remaining amount
    if (difference.abs() > 0.01) {
      final suggestionType = difference > 0
          ? BudgetSuggestionType.distributeRemaining
          : BudgetSuggestionType.reduceOverAllocation;

      _suggestions.add(BudgetAdjustmentSuggestion(
        type: suggestionType,
        title: difference > 0 ? 'Distribute Remaining Budget' : 'Reduce Over-Allocation',
        description: difference > 0
            ? 'Add \$${difference.toStringAsFixed(2)} to categories proportionally'
            : 'Reduce categories by \$${difference.abs().toStringAsFixed(2)}',
        impact: difference.abs(),
        affectedCategories: widget.categories.map((c) => c.name).toList(),
        action: () => _applyBalanceSuggestion(difference),
      ));
    }

    // Suggestion 2: Balance high-low categories
    final sortedCategories = List<BudgetCategoryAdjustmentData>.from(widget.categories)
      ..sort((a, b) => (a.amount / widget.totalBudget).compareTo(b.amount / widget.totalBudget));

    if (sortedCategories.length >= 3) {
      final lowest = sortedCategories.first;
      final highest = sortedCategories.last;
      final lowPercentage = lowest.amount / widget.totalBudget;
      final highPercentage = highest.amount / widget.totalBudget;

      if (highPercentage > lowPercentage * 2 && lowPercentage < 0.05) {
        _suggestions.add(BudgetAdjustmentSuggestion(
          type: BudgetSuggestionType.balanceCategories,
          title: 'Balance Category Distribution',
          description: 'Move funds from ${highest.name} to ${lowest.name} for better balance',
          impact: (highest.amount * 0.1).clamp(0, lowest.amount * 2),
          affectedCategories: [highest.name, lowest.name],
          action: () => _applyBalanceCategoriesSuggestion(highest, lowest),
        ));
      }
    }

    // Suggestion 3: Round to nearest dollar
    final unroundedCategories = widget.categories.where((cat) {
      final decimal = cat.amount - cat.amount.floor();
      return decimal != 0.0;
    }).toList();

    if (unroundedCategories.isNotEmpty) {
      _suggestions.add(BudgetAdjustmentSuggestion(
        type: BudgetSuggestionType.roundAmounts,
        title: 'Round to Nearest Dollar',
        description: 'Round ${unroundedCategories.length} categories to clean dollar amounts',
        impact: unroundedCategories.fold<double>(0, (sum, cat) {
          final rounded = cat.amount.roundToDouble();
          return sum + (rounded - cat.amount).abs();
        }),
        affectedCategories: unroundedCategories.map((c) => c.name).toList(),
        action: () => _applyRoundingSuggestion(unroundedCategories),
      ));
    }

    setState(() {});
  }

  void _applyBalanceSuggestion(double difference) {
    final updatedCategories = List<BudgetCategoryAdjustmentData>.from(widget.categories);

    if (difference > 0) {
      // Distribute remaining amount proportionally
      final totalCurrent = widget.categories.fold<double>(0, (sum, cat) => sum + cat.amount);
      for (var i = 0; i < updatedCategories.length; i++) {
        final proportion = updatedCategories[i].amount / totalCurrent;
        updatedCategories[i] = updatedCategories[i].copyWith(
          amount: updatedCategories[i].amount + (difference * proportion),
        );
      }
    } else {
      // Reduce proportionally
      final reductionFactor = (widget.totalBudget) / widget.categories.fold<double>(0, (sum, cat) => sum + cat.amount);
      for (var i = 0; i < updatedCategories.length; i++) {
        updatedCategories[i] = updatedCategories[i].copyWith(
          amount: updatedCategories[i].amount * reductionFactor,
        );
      }
    }

    widget.onCategoriesChanged(updatedCategories);
    widget.onSuggestionApplied?.call(_suggestions.firstWhere((s) => s.type == BudgetSuggestionType.distributeRemaining));
  }

  void _applyBalanceCategoriesSuggestion(
    BudgetCategoryAdjustmentData from,
    BudgetCategoryAdjustmentData to,
  ) {
    const transferAmount = 50.0; // Fixed transfer for simplicity
    final updatedCategories = List<BudgetCategoryAdjustmentData>.from(widget.categories);

    final fromIndex = updatedCategories.indexWhere((c) => c.id == from.id);
    final toIndex = updatedCategories.indexWhere((c) => c.id == to.id);

    if (fromIndex != -1 && toIndex != -1) {
      updatedCategories[fromIndex] = updatedCategories[fromIndex].copyWith(
        amount: updatedCategories[fromIndex].amount - transferAmount,
      );
      updatedCategories[toIndex] = updatedCategories[toIndex].copyWith(
        amount: updatedCategories[toIndex].amount + transferAmount,
      );
    }

    widget.onCategoriesChanged(updatedCategories);
    widget.onSuggestionApplied?.call(_suggestions.firstWhere((s) => s.type == BudgetSuggestionType.balanceCategories));
  }

  void _applyRoundingSuggestion(List<BudgetCategoryAdjustmentData> unroundedCategories) {
    final updatedCategories = List<BudgetCategoryAdjustmentData>.from(widget.categories);

    for (final category in unroundedCategories) {
      final index = updatedCategories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        final rounded = category.amount.roundToDouble();
        updatedCategories[index] = updatedCategories[index].copyWith(amount: rounded);
      }
    }

    widget.onCategoriesChanged(updatedCategories);
    widget.onSuggestionApplied?.call(_suggestions.firstWhere((s) => s.type == BudgetSuggestionType.roundAmounts));
  }

  void _handleDragAdjustment(int fromIndex, int toIndex, double transferAmount) {
    final updatedCategories = List<BudgetCategoryAdjustmentData>.from(widget.categories);

    // Ensure we don't go negative
    final actualTransfer = transferAmount.clamp(0, updatedCategories[fromIndex].amount);

    updatedCategories[fromIndex] = updatedCategories[fromIndex].copyWith(
      amount: updatedCategories[fromIndex].amount - actualTransfer,
    );
    updatedCategories[toIndex] = updatedCategories[toIndex].copyWith(
      amount: updatedCategories[toIndex].amount + actualTransfer,
    );

    widget.onCategoriesChanged(updatedCategories);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Smart Suggestions Section
        if (widget.enableSmartSuggestions && _suggestions.isNotEmpty)
          _buildSuggestionsSection(),

        const SizedBox(height: 24),

        // Drag Adjustment Section
        if (widget.enableDragAdjustment)
          _buildDragAdjustmentSection(),
      ],
    );
  }

  Widget _buildSuggestionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Smart Suggestions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_suggestions.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ..._suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSuggestionCard(suggestion),
              )),
        ],
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildSuggestionCard(BudgetAdjustmentSuggestion suggestion) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$${suggestion.impact.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Affects: ${suggestion.affectedCategories.take(2).join(', ')}${suggestion.affectedCategories.length > 2 ? ' +${suggestion.affectedCategories.length - 2}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        suggestion.action();
                        HapticFeedback.lightImpact();
                      },
                      icon: const Icon(Icons.auto_fix_high, size: 16),
                      label: const Text('Apply'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragAdjustmentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.drag_handle,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Drag to Adjust',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Drag between categories to rebalance your budget amounts.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),

          const SizedBox(height: 20),

          // Category adjustment grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: widget.categories.length,
            itemBuilder: (context, index) => _buildDraggableCategoryCard(
              widget.categories[index],
              index,
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: 0.1, duration: 500.ms, delay: 200.ms);
  }

  Widget _buildDraggableCategoryCard(BudgetCategoryAdjustmentData category, int index) {
    final isDragged = _draggedIndex == index;
    final percentage = widget.totalBudget > 0 ? (category.amount / widget.totalBudget) * 100 : 0.0;

    return LongPressDraggable<int>(
      data: index,
      onDragStarted: () {
        setState(() => _draggedIndex = index);
        HapticFeedback.mediumImpact();
      },
      onDragEnd: (details) {
        setState(() => _draggedIndex = null);
      },
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.05,
          child: _buildCategoryCardContent(category, percentage, isDragged: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCategoryCardContent(category, percentage, isDragged: false),
      ),
      child: DragTarget<int>(
        onAcceptWithDetails: (details) {
          if (details.data != index) {
            _showTransferDialog(details.data, index);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return _buildCategoryCardContent(
            category,
            percentage,
            isDragged: isDragged,
            isTarget: candidateData.isNotEmpty,
          );
        },
      ),
    );
  }

  Widget _buildCategoryCardContent(
    BudgetCategoryAdjustmentData category,
    double percentage, {
    bool isDragged = false,
    bool isTarget = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTarget
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTarget
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: isTarget ? 2 : 1,
        ),
        boxShadow: isDragged
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.drag_indicator,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            '\$${category.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),

          const SizedBox(height: 4),

          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: (category.amount / widget.totalBudget).clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(int fromIndex, int toIndex) {
    final fromCategory = widget.categories[fromIndex];
    final toCategory = widget.categories[toIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Transfer from ${fromCategory.name} to ${toCategory.name}'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                hintText: '0.00',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                // Store the value for use in onPressed
                final amount = double.tryParse(value) ?? 0.0;
                // Update the dialog's state if needed
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // For demo purposes, transfer a fixed amount
              _handleDragAdjustment(fromIndex, toIndex, 25.0);
              Navigator.pop(context);
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
}

/// Data class for budget category adjustment
class BudgetCategoryAdjustmentData {
  const BudgetCategoryAdjustmentData({
    required this.id,
    required this.name,
    required this.amount,
    this.color,
    this.icon,
  });

  final String id;
  final String name;
  final double amount;
  final Color? color;
  final IconData? icon;

  BudgetCategoryAdjustmentData copyWith({
    String? id,
    String? name,
    double? amount,
    Color? color,
    IconData? icon,
  }) {
    return BudgetCategoryAdjustmentData(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetCategoryAdjustmentData &&
        other.id == id &&
        other.name == name &&
        other.amount == amount;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ amount.hashCode;
}

/// Budget adjustment suggestion data class
class BudgetAdjustmentSuggestion {
  const BudgetAdjustmentSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.impact,
    required this.affectedCategories,
    required this.action,
  });

  final BudgetSuggestionType type;
  final String title;
  final String description;
  final double impact;
  final List<String> affectedCategories;
  final VoidCallback action;
}

/// Types of budget adjustment suggestions
enum BudgetSuggestionType {
  distributeRemaining,
  balanceCategories,
  roundAmounts,
  reduceOverAllocation,
}