import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


/// Live budget validation widget with real-time feedback during budget creation
class LiveBudgetValidator extends StatefulWidget {
  const LiveBudgetValidator({
    super.key,
    required this.totalBudget,
    required this.categories,
    required this.onValidationChanged,
    this.minBudget = 0.0,
    this.maxBudget = double.infinity,
  });

  final double totalBudget;
  final List<BudgetCategoryValidationData> categories;
  final Function(BudgetValidationResult) onValidationChanged;
  final double minBudget;
  final double maxBudget;

  @override
  State<LiveBudgetValidator> createState() => _LiveBudgetValidatorState();
}

class _LiveBudgetValidatorState extends State<LiveBudgetValidator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  BudgetValidationResult _currentResult = const BudgetValidationResult();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _validateBudget();
  }

  @override
  void didUpdateWidget(LiveBudgetValidator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalBudget != widget.totalBudget ||
        oldWidget.categories != widget.categories) {
      _validateBudget();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _validateBudget() {
    final result = _performValidation();
    if (result != _currentResult) {
      setState(() => _currentResult = result);
      widget.onValidationChanged(result);

      // Animate on validation changes
      if (result.hasErrors || result.hasWarnings) {
        _animationController.forward().then((_) => _animationController.reverse());
      }
    }
  }

  BudgetValidationResult _performValidation() {
    final errors = <BudgetValidationError>[];
    final warnings = <BudgetValidationWarning>[];

    // Check total budget range
    if (widget.totalBudget < widget.minBudget) {
      errors.add(BudgetValidationError(
        type: BudgetValidationErrorType.budgetTooLow,
        message: 'Total budget must be at least \$${widget.minBudget.toStringAsFixed(2)}',
        severity: ValidationSeverity.error,
      ));
    }

    if (widget.totalBudget > widget.maxBudget && widget.maxBudget != double.infinity) {
      errors.add(BudgetValidationError(
        type: BudgetValidationErrorType.budgetTooHigh,
        message: 'Total budget cannot exceed \$${widget.maxBudget.toStringAsFixed(2)}',
        severity: ValidationSeverity.error,
      ));
    }

    // Check for empty categories
    final emptyCategories = widget.categories.where((cat) => cat.amount <= 0).toList();
    if (emptyCategories.isNotEmpty) {
      warnings.add(BudgetValidationWarning(
        type: BudgetValidationWarningType.emptyCategories,
        message: '${emptyCategories.length} categories have no budget allocated',
        affectedCategories: emptyCategories.map((c) => c.name).toList(),
      ));
    }

    // Check for over-allocated categories
    final overAllocatedCategories = widget.categories.where((cat) {
      final percentage = cat.amount / widget.totalBudget;
      return percentage > 0.8; // More than 80% in one category
    }).toList();

    if (overAllocatedCategories.isNotEmpty && widget.totalBudget > 0) {
      warnings.add(BudgetValidationWarning(
        type: BudgetValidationWarningType.overAllocatedCategory,
        message: 'Some categories are allocated more than 80% of total budget',
        affectedCategories: overAllocatedCategories.map((c) => c.name).toList(),
      ));
    }

    // Check for unbalanced distribution
    final totalAllocated = widget.categories.fold<double>(0, (sum, cat) => sum + cat.amount);
    final allocationDifference = (totalAllocated - widget.totalBudget).abs();

    if (allocationDifference > 0.01) { // More than $0.01 difference
      if (totalAllocated > widget.totalBudget) {
        errors.add(BudgetValidationError(
          type: BudgetValidationErrorType.overAllocated,
          message: 'Total allocated (\$${totalAllocated.toStringAsFixed(2)}) exceeds budget (\$${widget.totalBudget.toStringAsFixed(2)})',
          severity: ValidationSeverity.error,
        ));
      } else {
        warnings.add(BudgetValidationWarning(
          type: BudgetValidationWarningType.underAllocated,
          message: 'Total allocated (\$${totalAllocated.toStringAsFixed(2)}) is less than budget (\$${widget.totalBudget.toStringAsFixed(2)})',
        ));
      }
    }

    // Check for duplicate category names
    final categoryNames = widget.categories.map((c) => c.name.toLowerCase()).toList();
    final uniqueNames = categoryNames.toSet();
    if (uniqueNames.length != categoryNames.length) {
      errors.add(BudgetValidationError(
        type: BudgetValidationErrorType.duplicateCategories,
        message: 'Category names must be unique',
        severity: ValidationSeverity.error,
      ));
    }

    // Check for reasonable category amounts
    final unreasonableCategories = widget.categories.where((cat) {
      return cat.amount > widget.totalBudget * 0.9; // More than 90%
    }).toList();

    if (unreasonableCategories.isNotEmpty && widget.totalBudget > 100) {
      warnings.add(BudgetValidationWarning(
        type: BudgetValidationWarningType.unreasonableAllocation,
        message: 'Some categories have very high allocations relative to total budget',
        affectedCategories: unreasonableCategories.map((c) => c.name).toList(),
      ));
    }

    return BudgetValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      totalAllocated: totalAllocated,
      allocationDifference: allocationDifference,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_currentResult.hasIssues) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _currentResult.hasErrors
                  ? Colors.red.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _currentResult.hasErrors
                    ? Colors.red.shade200
                    : Colors.orange.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      _currentResult.hasErrors ? Icons.error_outline : Icons.warning,
                      color: _currentResult.hasErrors ? Colors.red : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentResult.hasErrors ? 'Validation Errors' : 'Validation Warnings',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _currentResult.hasErrors ? Colors.red : Colors.orange,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _currentResult.hasErrors
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentResult.errors.length + _currentResult.warnings.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _currentResult.hasErrors ? Colors.red : Colors.orange,
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Error messages
                ..._currentResult.errors.map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.cancel,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error.message,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.red.shade700,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )),

                // Warning messages
                ..._currentResult.warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              warning.message,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange.shade700,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, duration: 300.ms);
  }
}

/// Data class for budget category validation
class BudgetCategoryValidationData {
  const BudgetCategoryValidationData({
    required this.name,
    required this.amount,
    this.categoryId,
  });

  final String name;
  final double amount;
  final String? categoryId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetCategoryValidationData &&
        other.name == name &&
        other.amount == amount &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode => name.hashCode ^ amount.hashCode ^ categoryId.hashCode;
}

/// Validation result data class
class BudgetValidationResult {
  const BudgetValidationResult({
    this.isValid = true,
    this.errors = const [],
    this.warnings = const [],
    this.totalAllocated = 0.0,
    this.allocationDifference = 0.0,
  });

  final bool isValid;
  final List<BudgetValidationError> errors;
  final List<BudgetValidationWarning> warnings;
  final double totalAllocated;
  final double allocationDifference;

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => hasErrors || hasWarnings;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetValidationResult &&
        other.isValid == isValid &&
        other.errors == errors &&
        other.warnings == warnings &&
        other.totalAllocated == totalAllocated &&
        other.allocationDifference == allocationDifference;
  }

  @override
  int get hashCode =>
      isValid.hashCode ^
      errors.hashCode ^
      warnings.hashCode ^
      totalAllocated.hashCode ^
      allocationDifference.hashCode;
}

/// Validation error data class
class BudgetValidationError {
  const BudgetValidationError({
    required this.type,
    required this.message,
    this.severity = ValidationSeverity.error,
    this.affectedCategories = const [],
  });

  final BudgetValidationErrorType type;
  final String message;
  final ValidationSeverity severity;
  final List<String> affectedCategories;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetValidationError &&
        other.type == type &&
        other.message == message &&
        other.severity == severity &&
        other.affectedCategories == affectedCategories;
  }

  @override
  int get hashCode =>
      type.hashCode ^ message.hashCode ^ severity.hashCode ^ affectedCategories.hashCode;
}

/// Validation warning data class
class BudgetValidationWarning {
  const BudgetValidationWarning({
    required this.type,
    required this.message,
    this.affectedCategories = const [],
  });

  final BudgetValidationWarningType type;
  final String message;
  final List<String> affectedCategories;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetValidationWarning &&
        other.type == type &&
        other.message == message &&
        other.affectedCategories == affectedCategories;
  }

  @override
  int get hashCode => type.hashCode ^ message.hashCode ^ affectedCategories.hashCode;
}

/// Validation error types
enum BudgetValidationErrorType {
  budgetTooLow,
  budgetTooHigh,
  overAllocated,
  duplicateCategories,
}

/// Validation warning types
enum BudgetValidationWarningType {
  emptyCategories,
  overAllocatedCategory,
  underAllocated,
  unreasonableAllocation,
}

/// Validation severity levels
enum ValidationSeverity {
  error,
  warning,
}