# Comprehensive Guide: Transforming Home & Transaction Pages + Universal UI Design System

## 📋 Table of Contents

### Part 1: Home Dashboard Transformation
1. Analysis of Current State vs Target
2. Component Mapping & Reuse Strategy
3. Enhanced Home Dashboard Implementation
4. Data Integration Points

### Part 2: Transaction Page Transformation
1. Analysis of Current State vs Target
2. Component Mapping & Reuse Strategy
3. Enhanced Transaction List Implementation
4. Advanced Filtering & Interactions

### Part 3: Universal UI Design System
1. Design Principles & Philosophy
2. Component Library Structure
3. Layout Patterns & Grid System
4. Animation & Interaction Guidelines
5. Implementation Templates for Any Screen

---

# PART 1: HOME DASHBOARD TRANSFORMATION

## 🎯 Phase 1: Analysis & Component Mapping

### Current Home Dashboard Components (Document 5)

**Existing Components:**
```
✓ _DashboardHeader - Period selector + notifications
✓ _FinancialSnapshotCard - Balance card with stats
✓ _IncomeExpenseActionsBar - Quick action buttons
✓ _BudgetOverviewWidget - Budget categories list
✓ _UpcomingPaymentsWidget - Bills and income
✓ _RecentTransactionsWidget - Transaction list
✓ _InsightsCard - Rotating insights
```

### Budget Screen Components Available for Reuse

**🔄 Reusable Components from Budget Screens:**
```
1. CircularBudgetIndicator - Use for net worth/balance visualization
2. DateSelectorPills - Replace current period selector
3. BudgetStatusBanner - Use for financial status messages
4. BudgetMetricCards - Replace _FinancialStatsCard
5. BudgetStatsRow - Three-column financial stats
6. BudgetBarChart - Add spending trend visualization
7. MiniTrendIndicator - Add to transaction items
```

### Transformation Mapping

| Current Component | Transform To | Reuse Component |
|------------------|--------------|-----------------|
| BalanceCard | Circular Progress + Stats | ✅ CircularBudgetIndicator |
| _DashboardHeader | Enhanced Header | ✅ DateSelectorPills |
| _FinancialStatsCard | Dual Metrics | ✅ BudgetMetricCards |
| _BudgetOverviewWidget | Enhanced Cards | ✅ MiniTrendIndicator |
| _IncomeExpenseActionsBar | Elevated Actions | New Enhanced Version |
| Basic Transaction List | Rich Transaction Cards | Enhanced Version |

---

## 🎨 Phase 2: Enhanced Home Dashboard Implementation

### 2.1 Enhanced Dashboard Header

```dart
// lib/features/dashboard/presentation/widgets/enhanced_dashboard_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/date_selector_pills.dart';

/// Enhanced dashboard header with date navigation
class EnhancedDashboardHeader extends ConsumerStatefulWidget {
  const EnhancedDashboardHeader({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  @override
  ConsumerState<EnhancedDashboardHeader> createState() => _EnhancedDashboardHeaderState();
}

class _EnhancedDashboardHeaderState extends ConsumerState<EnhancedDashboardHeader> {
  bool _showDateSelector = false;

  @override
  Widget build(BuildContext context) {
    final currentPeriod = DateFormat('MMMM yyyy').format(widget.selectedDate);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bar with period and actions
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.spacing3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Period selector
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDateSelector = !_showDateSelector;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing3,
                      vertical: AppDimensions.spacing2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppDimensions.spacing2),
                        Text(
                          currentPeriod,
                          style: AppTypographyExtended.metricLabel.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: AppDimensions.spacing2),
                        Icon(
                          _showDateSelector 
                              ? Icons.keyboard_arrow_up 
                              : Icons.keyboard_arrow_down,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action buttons
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing2,
                    vertical: AppDimensions.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorsExtended.pillBgUnselected,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.notifications_outlined,
                        onPressed: () {
                          if (context.mounted) {
                            // Navigate to notifications
                          }
                        },
                        tooltip: 'Notifications',
                        badgeCount: 3,
                      ),
                      SizedBox(width: AppDimensions.spacing1),
                      _HeaderIconButton(
                        icon: Icons.tune,
                        onPressed: () {
                          // Show filter options
                        },
                        tooltip: 'Filter',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date selector pills (collapsible)
          if (_showDateSelector)
            DateSelectorPills(
              startDate: DateTime(widget.selectedDate.year, widget.selectedDate.month, 1),
              endDate: DateTime(
                widget.selectedDate.year,
                widget.selectedDate.month + 1,
                0,
              ),
              selectedDate: widget.selectedDate,
              onDateSelected: (date) {
                widget.onDateChanged(date);
                setState(() {
                  _showDateSelector = false;
                });
              },
            ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon),
          iconSize: 20,
          onPressed: onPressed,
          tooltip: tooltip,
          padding: EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          color: AppColors.textSecondary,
        ),
        if (badgeCount != null && badgeCount! > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeCount! > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
```

### 2.2 Enhanced Financial Overview

```dart
// lib/features/dashboard/presentation/widgets/enhanced_financial_overview.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';
import '../../../budgets/presentation/widgets/budget_metric_cards.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart';
import '../../../budgets/presentation/widgets/budget_status_banner.dart';
import '../../domain/entities/dashboard_data.dart';

/// Enhanced financial overview with circular indicator
class EnhancedFinancialOverview extends StatelessWidget {
  const EnhancedFinancialOverview({
    super.key,
    required this.snapshot,
  });

  final FinancialSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final netWorth = snapshot.netWorth;
    final income = snapshot.incomeThisMonth;
    final expenses = snapshot.expensesThisMonth;
    final savingsRate = income > 0 ? (income - expenses) / income : 0.0;
    final expenseRate = income > 0 ? expenses / income : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: Text(
            'Financial Overview',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: -0.1, duration: 400.ms),
        
        SizedBox(height: AppDimensions.spacing4),

        // Circular Indicator - Net Worth
        Center(
          child: CircularBudgetIndicator(
            percentage: expenseRate.clamp(0.0, 1.0),
            spent: expenses,
            total: income > 0 ? income : expenses,
            size: 220,
            strokeWidth: 22,
          ),
        ).animate()
          .fadeIn(duration: 600.ms, delay: 200.ms)
          .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, delay: 200.ms, curve: Curves.elasticOut),
        
        SizedBox(height: AppDimensions.spacing4),

        // Status Banner
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: _FinancialStatusBanner(
            netWorth: netWorth,
            income: income,
            expenses: expenses,
          ),
        ).animate()
          .fadeIn(duration: 400.ms, delay: 400.ms)
          .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms),
        
        SizedBox(height: AppDimensions.spacing4),

        // Metric Cards
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Savings Rate',
                  percentage: savingsRate,
                  icon: Icons.trending_up,
                  isPositive: savingsRate > 0,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms)
                  .slideX(begin: -0.1, duration: 400.ms, delay: 500.ms),
              ),
              SizedBox(width: AppDimensions.spacing4),
              Expanded(
                child: _MetricCard(
                  title: 'Expense Rate',
                  percentage: expenseRate,
                  icon: Icons.trending_down,
                  isPositive: false,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 600.ms)
                  .slideX(begin: 0.1, duration: 400.ms, delay: 600.ms),
              ),
            ],
          ),
        ),
        
        SizedBox(height: AppDimensions.spacing4),

        // Stats Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: BudgetStatsRow(
            allotted: income,
            used: expenses,
            remaining: netWorth,
          ),
        ).animate()
          .fadeIn(duration: 400.ms, delay: 700.ms)
          .slideY(begin: 0.1, duration: 400.ms, delay: 700.ms),
      ],
    );
  }
}

class _FinancialStatusBanner extends StatelessWidget {
  const _FinancialStatusBanner({
    required this.netWorth,
    required this.income,
    required this.expenses,
  });

  final double netWorth;
  final double income;
  final double expenses;

  String _getStatusMessage() {
    if (netWorth < 0) {
      return 'Expenses exceed income by ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(-netWorth)}';
    } else if (expenses > income * 0.9) {
      return 'You\'re spending 90% of your income';
    } else {
      return 'You\'re saving ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(netWorth)} this month';
    }
  }

  Color _getStatusColor() {
    if (netWorth < 0) return AppColorsExtended.statusOverBudget;
    if (expenses > income * 0.9) return AppColorsExtended.statusWarning;
    return AppColorsExtended.statusNormal;
  }

  String _getStatusLabel() {
    if (netWorth < 0) return 'Critical';
    if (expenses > income * 0.9) return 'Warning';
    return 'Healthy';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColorsExtended.cardBgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              netWorth >= 0 ? Icons.trending_up : Icons.trending_down,
              size: 18,
              color: statusColor,
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),
          Expanded(
            child: Text(
              _getStatusMessage(),
              style: AppTypographyExtended.statusMessage.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacing2),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.spacing2),
          Text(
            _getStatusLabel(),
            style: AppTypographyExtended.statusMessage.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.percentage,
    required this.icon,
    required this.isPositive,
  });

  final String title;
  final double percentage;
  final IconData icon;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive 
        ? AppColorsExtended.statusNormal 
        : AppColorsExtended.statusCritical;
    
    return Container(
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          SizedBox(height: AppDimensions.spacing3),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: percentage),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '${(value * 100).toInt()}%',
                style: AppTypographyExtended.metricPercentage.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.3 Enhanced Quick Actions Bar

```dart
// lib/features/dashboard/presentation/widgets/enhanced_quick_actions.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';

class EnhancedQuickActions extends StatelessWidget {
  const EnhancedQuickActions({
    super.key,
    required this.onIncomePressed,
    required this.onExpensePressed,
    required this.onTransferPressed,
  });

  final VoidCallback onIncomePressed;
  final VoidCallback onExpensePressed;
  final VoidCallback onTransferPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
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
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  size: 20,
                  color: AppColorsExtended.budgetPrimary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                'Quick Actions',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.arrow_downward,
                  label: 'Income',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.statusNormal,
                      AppColorsExtended.statusNormal.withValues(alpha: 0.8),
                    ],
                  ),
                  onPressed: onIncomePressed,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 100.ms, curve: Curves.elasticOut),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.arrow_upward,
                  label: 'Expense',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.statusCritical,
                      AppColorsExtended.statusCritical.withValues(alpha: 0.8),
                    ],
                  ),
                  onPressed: onExpensePressed,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 200.ms, curve: Curves.elasticOut),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Transfer',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.budgetSecondary,
                      AppColorsExtended.budgetSecondary.withValues(alpha: 0.8),
                    ],
                  ),
                  onPressed: onTransferPressed,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 300.ms, curve: Curves.elasticOut),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12.0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(height: AppDimensions.spacing2),
              Text(
                label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2.4 Enhanced Budget Overview

```dart
// lib/features/dashboard/presentation/widgets/enhanced_budget_overview_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/mini_trend_indicator.dart';
import '../../domain/entities/dashboard_data.dart';

class EnhancedBudgetOverviewWidget extends StatelessWidget {
  const EnhancedBudgetOverviewWidget({
    super.key,
    required this.budgetOverview,
  });

  final List<BudgetCategoryOverview> budgetOverview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
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
                  color: AppColorsExtended.budgetSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  size: 20,
                  color: AppColorsExtended.budgetSecondary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  'Budget Overview',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    context.go('/budgets');
                  }
                },
                child: Text(
                  'See All',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColorsExtended.budgetPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),
          
          if (budgetOverview.isEmpty)
            _buildEmptyState(context)
          else
            ...budgetOverview.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < budgetOverview.length - 1 ? 12 : 0,
                ),
                child: _EnhancedBudgetCategoryCard(
                  category: category,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                  .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 100 * index)),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Budgets Yet',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first budget to start\ntracking your spending',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              context.go('/budgets');
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Budget'),
            style: TextButton.styleFrom(
              foregroundColor: AppColorsExtended.budgetPrimary,
            ),
          ),
        ],
      ),
    );
  }

class _EnhancedBudgetCategoryCard extends StatelessWidget {
  const _EnhancedBudgetCategoryCard({
    required this.category,
  });

  final BudgetCategoryOverview category;

  Color _getProgressColor(BudgetHealthStatus status) {
    switch (status) {
      case BudgetHealthStatus.healthy:
        return AppColorsExtended.statusNormal;
      case BudgetHealthStatus.warning:
        return AppColorsExtended.statusWarning;
      case BudgetHealthStatus.critical:
        return AppColorsExtended.statusCritical;
      case BudgetHealthStatus.overBudget:
        return AppColorsExtended.statusOverBudget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = category.spent / category.budget;
    final progressColor = _getProgressColor(category.status);
    final isOverBudget = category.status == BudgetHealthStatus.overBudget;

    // Mock trend data - replace with actual historical data
    final trendData = List.generate(7, (i) => category.spent / 7 * (1 + (i * 0.1)));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
        border: isOverBudget
            ? Border.all(
                color: progressColor.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category indicator dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: progressColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              
              // Category name
              Expanded(
                child: Text(
                  category.categoryName,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Mini trend indicator
              MiniTrendIndicator(
                values: trendData,
                color: progressColor,
                width: 50,
                height: 20,
              ),
              
              SizedBox(width: AppDimensions.spacing2),
              
              // Percentage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppDimensions.spacing3),
          
          // Progress bar
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        progressColor,
                        progressColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppDimensions.spacing2),
          
          // Amount details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(category.spent),
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'of ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(category.budget)}',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          if (isOverBudget) ...[
            SizedBox(height: AppDimensions.spacing2),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: progressColor,
                ),
                SizedBox(width: AppDimensions.spacing1),
                Text(
                  'Over budget by ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(category.spent - category.budget)}',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
```

### 2.5 Enhanced Recent Transactions

```dart
// lib/features/dashboard/presentation/widgets/enhanced_recent_transactions.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

class EnhancedRecentTransactions extends ConsumerWidget {
  const EnhancedRecentTransactions({
    super.key,
    required this.recentTransactions,
  });

  final List<Transaction> recentTransactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
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
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: AppColorsExtended.budgetPrimary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    context.go('/transactions');
                  }
                },
                child: Text(
                  'See All',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColorsExtended.budgetPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),
          
          if (recentTransactions.isEmpty)
            _buildEmptyState(context)
          else
            ...recentTransactions.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final transaction = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < recentTransactions.length - 1 ? 8 : 0,
                ),
                child: _EnhancedTransactionCard(
                  transaction: transaction,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * index))
                  .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 50 * index)),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses and\nincome by adding transactions',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EnhancedTransactionCard extends ConsumerWidget {
  const _EnhancedTransactionCard({
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense 
        ? AppColorsExtended.statusCritical 
        : AppColorsExtended.statusNormal;
    
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    final categories = ref.watch(transactionCategoriesProvider);
    final category = categories.where((c) => c.id == transaction.categoryId).firstOrNull;
    final categoryIcon = categoryIconColorService.getIconForCategory(transaction.categoryId);
    final categoryColor = categoryIconColorService.getColorForCategory(transaction.categoryId);
    final categoryName = category?.name ?? 'Unknown Category';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (context.mounted) {
            context.go('/transactions/${transaction.id}');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Category Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  categoryIcon,
                  size: 20,
                  color: categoryColor,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description ?? 'Transaction',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            categoryName,
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: categoryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 10,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(transaction.date),
                          style: AppTypographyExtended.metricLabel.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'}${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(transaction.amount)}',
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isExpense ? 'Expense' : 'Income',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: amountColor,
                        fontSize: 9,
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

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}
```

### 2.6 Complete Enhanced Home Dashboard Screen

```dart
// lib/features/dashboard/presentation/screens/home_dashboard_screen_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer' as developer;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../transactions/presentation/widgets/scan_receipt_fab.dart';
import '../../../transactions/presentation/widgets/add_transaction_bottom_sheet.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/enhanced_dashboard_header.dart';
import '../widgets/enhanced_financial_overview.dart';
import '../widgets/enhanced_quick_actions.dart';
import '../widgets/enhanced_budget_overview_widget.dart';
import '../widgets/enhanced_upcoming_payments_widget.dart';
import '../widgets/enhanced_recent_transactions.dart';
import '../widgets/enhanced_insights_card.dart';

/// Enhanced Home Dashboard Screen with modern UI
class HomeDashboardScreenEnhanced extends ConsumerStatefulWidget {
  const HomeDashboardScreenEnhanced({super.key});

  @override
  ConsumerState<HomeDashboardScreenEnhanced> createState() => _HomeDashboardScreenEnhancedState();
}

class _HomeDashboardScreenEnhancedState extends ConsumerState<HomeDashboardScreenEnhanced> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    developer.log('HomeDashboardScreenEnhanced initialized', name: 'HomeDashboard');
  }

  @override
  void dispose() {
    developer.log('HomeDashboardScreenEnhanced disposed', name: 'HomeDashboard');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    developer.log('Building HomeDashboardScreenEnhanced', name: 'HomeDashboard');
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            EnhancedDashboardHeader(
              selectedDate: _selectedDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            
            // Main Content
            Expanded(
              child: dashboardAsync.when(
                loading: () => const LoadingView(),
                error: (error, stack) {
                  developer.log('Dashboard error: $error', name: 'HomeDashboard', error: error);
                  return _buildErrorState(error);
                },
                data: (dashboardData) => _buildDashboardContent(dashboardData),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const ScanReceiptFAB(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error loading dashboard'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ref.refresh(dashboardDataProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardData dashboardData) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardDataProvider);
      },
      child: SingleChildScrollView(
        key: const PageStorageKey('dashboard_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Financial Overview with Circular Indicator
              EnhancedFinancialOverview(
                snapshot: dashboardData.financialSnapshot,
              ),
              SizedBox(height: AppDimensions.sectionGap),
              
              // Quick Actions
              EnhancedQuickActions(
                onIncomePressed: () => _showIncomeSheet(context),
                onExpensePressed: () => _showExpenseSheet(context),
                onTransferPressed: () {
                  // TODO: Implement transfer
                },
              ).animate()
                .fadeIn(duration: 400.ms, delay: 800.ms)
                .slideY(begin: 0.1, duration: 400.ms, delay: 800.ms),
              
              SizedBox(height: AppDimensions.sectionGap),
              
              // Budget Overview
              if (dashboardData.budgetOverview.isNotEmpty) ...[
                EnhancedBudgetOverviewWidget(
                  budgetOverview: dashboardData.budgetOverview,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 900.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 900.ms),
                SizedBox(height: AppDimensions.sectionGap),
              ],
              
              // Upcoming Payments & Income
              if (dashboardData.upcomingBills.isNotEmpty || 
                  dashboardData.upcomingIncomes.isNotEmpty) ...[
                EnhancedUpcomingPaymentsWidget(
                  upcomingBills: dashboardData.upcomingBills,
                  upcomingIncomes: dashboardData.upcomingIncomes,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 1000.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 1000.ms),
                SizedBox(height: AppDimensions.sectionGap),
              ],
              
              // Recent Transactions
              if (dashboardData.recentTransactions.isNotEmpty) ...[
                EnhancedRecentTransactions(
                  recentTransactions: dashboardData.recentTransactions,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 1100.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 1100.ms),
                SizedBox(height: AppDimensions.sectionGap),
              ],
              
              // Insights
              if (dashboardData.insights.isNotEmpty) ...[
                EnhancedInsightsCard(
                  insights: dashboardData.insights,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 1200.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 1200.ms),
                SizedBox(height: AppDimensions.sectionGap),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showIncomeSheet(BuildContext context) async {
    if (!context.mounted) return;
    
    await AppBottomSheet.show(
      context: context,
      child: AddTransactionBottomSheet(
        initialType: TransactionType.income,
        onSubmit: (transaction) async {
          final success = await ref
              .read(transactionNotifierProvider.notifier)
              .addTransaction(transaction);
          
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Income added successfully')),
            );
          }
        },
      ),
    );
  }

  Future<void> _showExpenseSheet(BuildContext context) async {
    if (!context.mounted) return;
    
    await AppBottomSheet.show(
      context: context,
      child: AddTransactionBottomSheet(
        initialType: TransactionType.expense,
        onSubmit: (transaction) async {
          final success = await ref
              .read(transactionNotifierProvider.notifier)
              .addTransaction(transaction);
          
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense added successfully')),
            );
          }
        },
      ),
    );
  }
}
```

### 2.7 Enhanced Upcoming Payments Widget

```dart
// lib/features/dashboard/presentation/widgets/enhanced_upcoming_payments_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../bills/domain/entities/bill.dart';
import '../../../recurring_incomes/domain/entities/recurring_income.dart';

class EnhancedUpcomingPaymentsWidget extends StatelessWidget {
  const EnhancedUpcomingPaymentsWidget({
    super.key,
    required this.upcomingBills,
    required this.upcomingIncomes,
  });

  final List<Bill> upcomingBills;
  final List<RecurringIncomeStatus> upcomingIncomes;

  @override
  Widget build(BuildContext context) {
    final combinedItems = _combineAndSortItems();

    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
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
                  color: AppColorsExtended.budgetTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule,
                  size: 20,
                  color: AppColorsExtended.budgetTertiary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  'Upcoming',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildLegend(),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),
          
          if (combinedItems.isEmpty)
            _buildEmptyState()
          else
            ...combinedItems.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < combinedItems.length - 1 ? 8 : 0,
                ),
                child: item.isBill
                    ? _EnhancedBillCard(bill: item.bill!)
                    : _EnhancedIncomeCard(incomeStatus: item.incomeStatus!),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * index))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 50 * index));
            }),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(
          color: AppColorsExtended.statusCritical,
          label: 'Bills',
        ),
        const SizedBox(width: 12),
        _LegendItem(
          color: AppColorsExtended.statusNormal,
          label: 'Income',
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming payments',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<_CombinedItem> _combineAndSortItems() {
    final items = <_CombinedItem>[];

    for (final bill in upcomingBills) {
      items.add(_CombinedItem(
        date: bill.dueDate,
        isBill: true,
        bill: bill,
      ));
    }

    for (final incomeStatus in upcomingIncomes) {
      items.add(_CombinedItem(
        date: incomeStatus.income.nextExpectedDate ?? DateTime.now(),
        isBill: false,
        incomeStatus: incomeStatus,
      ));
    }

    items.sort((a, b) {
      final aUrgency = _getItemUrgency(a);
      final bUrgency = _getItemUrgency(b);
      final urgencyComparison = bUrgency.index.compareTo(aUrgency.index);
      if (urgencyComparison != 0) return urgencyComparison;
      return a.date.compareTo(b.date);
    });

    return items;
  }

  _ItemUrgency _getItemUrgency(_CombinedItem item) {
    if (item.isBill) {
      final bill = item.bill!;
      if (bill.isOverdue) return _ItemUrgency.overdue;
      if (bill.isDueToday) return _ItemUrgency.dueToday;
      if (bill.isDueSoon) return _ItemUrgency.dueSoon;
      return _ItemUrgency.normal;
    } else {
      final incomeStatus = item.incomeStatus!;
      if (incomeStatus.isOverdue) return _ItemUrgency.overdue;
      if (incomeStatus.isExpectedToday) return _ItemUrgency.dueToday;
      if (incomeStatus.isExpectedSoon) return _ItemUrgency.dueSoon;
      return _ItemUrgency.normal;
    }
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypographyExtended.metricLabel.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CombinedItem {
  const _CombinedItem({
    required this.date,
    required this.isBill,
    this.bill,
    this.incomeStatus,
  });

  final DateTime date;
  final bool isBill;
  final Bill? bill;
  final RecurringIncomeStatus? incomeStatus;
}

enum _ItemUrgency {
  overdue,
  dueToday,
  dueSoon,
  normal,
}

class _EnhancedBillCard extends StatelessWidget {
  const _EnhancedBillCard({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final daysUntilDue = bill.daysUntilDue;
    final isOverdue = bill.isOverdue;
    final isDueSoon = bill.isDueSoon;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isOverdue) {
      statusColor = AppColorsExtended.statusOverBudget;
      statusText = '${daysUntilDue.abs()}d overdue';
      statusIcon = Icons.error_outline;
    } else if (daysUntilDue == 0) {
      statusColor = AppColorsExtended.statusCritical;
      statusText = 'Due today';
      statusIcon = Icons.warning_amber_rounded;
    } else if (daysUntilDue == 1) {
      statusColor = AppColorsExtended.statusWarning;
      statusText = 'Tomorrow';
      statusIcon = Icons.access_time;
    } else if (isDueSoon) {
      statusColor = AppColorsExtended.statusWarning;
      statusText = 'In ${daysUntilDue}d';
      statusIcon = Icons.access_time;
    } else {
      statusColor = AppColors.primary;
      statusText = 'In ${daysUntilDue}d';
      statusIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
        border: isOverdue
            ? Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Status indicator line
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),
          
          // Bill icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColorsExtended.statusCritical.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt,
              size: 18,
              color: AppColorsExtended.statusCritical,
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),
          
          // Bill details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Amount and action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.amount),
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColorsExtended.statusCritical,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorsExtended.statusNormal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 12,
                      color: AppColorsExtended.statusNormal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pay',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColorsExtended.statusNormal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnhancedIncomeCard extends StatelessWidget {
  const _EnhancedIncomeCard({required this.incomeStatus});

  final RecurringIncomeStatus incomeStatus;

  @override
  Widget build(BuildContext context) {
    final daysUntilExpected = incomeStatus.daysUntilExpected;
    final isOverdue = incomeStatus.isOverdue;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isOverdue) {
      statusColor = AppColorsExtended.statusWarning;
      statusText = '${daysUntilExpected.abs()}d overdue';
      statusIcon = Icons.warning_amber_rounded;
    } else if (daysUntilExpected == 0) {
      statusColor = AppColorsExtended.statusNormal;
      statusText = 'Expected today';
      statusIcon = Icons.check_circle_outline;
    } else if (daysUntilExpected == 1) {
      statusColor = AppColorsExtended.statusNormal;
      statusText = 'Tomorrow';
      statusIcon = Icons.access_time;
    } else {
      statusColor = AppColors.primary;
      statusText = 'In ${daysUntilExpected}d';
      statusIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Status indicator line
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),
          
          // Income icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColorsExtended.statusNormal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_downward,
              size: 18,
              color: AppColorsExtended.statusNormal,
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),
          
          // Income details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incomeStatus.income.name,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Amount and action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(incomeStatus.income.amount)}',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColorsExtended.statusNormal,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 12,
                      color: AppColorsExtended.budgetPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Record',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColorsExtended.budgetPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 2.8 Enhanced Insights Card

```dart
// lib/features/dashboard/presentation/widgets/enhanced_insights_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../insights/domain/entities/insight.dart';

class EnhancedInsightsCard extends StatefulWidget {
  const EnhancedInsightsCard({
    super.key,
    required this.insights,
  });

  final List<Insight> insights;

  @override
  State<EnhancedInsightsCard> createState() => _EnhancedInsightsCardState();
}

class _EnhancedInsightsCardState extends State<EnhancedInsightsCard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.insights.isEmpty) return const SizedBox.shrink();

    final currentInsight = widget.insights[_currentIndex];

    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getInsightColor(currentInsight.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb,
                      size: 20,
                      color: _getInsightColor(currentInsight.type),
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacing2),
                  Text(
                    'Insights',
                    style: AppTypographyExtended.statsValue.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousInsight,
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.insights.length}',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextInsight,
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _InsightContent(
              key: ValueKey(_currentIndex),
              insight: currentInsight,
            ),
          ),
          
          if (widget.insights.length > 1) ...[
            SizedBox(height: AppDimensions.spacing3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.insights.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex
                        ? _getInsightColor(currentInsight.type)
                        : AppColors.borderSubtle,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _nextInsight() {
    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.insights.length;
    });
  }

  void _previousInsight() {
    if (!mounted) return;
    setState(() {
      _currentIndex = _currentIndex > 0 ? _currentIndex - 1 : widget.insights.length - 1;
    });
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.spendingTrend:
        return AppColorsExtended.budgetPrimary;
      case InsightType.budgetAlert:
        return AppColorsExtended.statusCritical;
      case InsightType.savingsOpportunity:
        return AppColorsExtended.statusNormal;
      case InsightType.unusualActivity:
        return AppColorsExtended.statusWarning;
      case InsightType.goalProgress:
        return AppColorsExtended.budgetSecondary;
      case InsightType.billReminder:
        return AppColorsExtended.statusWarning;
      case InsightType.categoryAnalysis:
        return AppColorsExtended.budgetTertiary;
      case InsightType.monthlySummary:
        return AppColors.primary;
      case InsightType.comparison:
        return AppColorsExtended.budgetPrimary;
      case InsightType.recommendation:
        return AppColorsExtended.budgetSecondary;
    }
  }
}

class _InsightContent extends StatelessWidget {
  const _InsightContent({
    super.key,
    required this.insight,
  });

  final Insight insight;

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.spendingTrend:
        return AppColorsExtended.budgetPrimary;
      case InsightType.budgetAlert:
        return AppColorsExtended.statusCritical;
      case InsightType.savingsOpportunity:
        return AppColorsExtended.statusNormal;
      case InsightType.unusualActivity:
        return AppColorsExtended.statusWarning;
      case InsightType.goalProgress:
        return AppColorsExtended.budgetSecondary;
      case InsightType.billReminder:
        return AppColorsExtended.statusWarning;
      case InsightType.categoryAnalysis:
        return AppColorsExtended.budgetTertiary;
      case InsightType.monthlySummary:
        return AppColors.primary;
      case InsightType.comparison:
        return AppColorsExtended.budgetPrimary;
      case InsightType.recommendation:
        return AppColorsExtended.budgetSecondary;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.spendingTrend:
        return Icons.trending_up;
      case InsightType.budgetAlert:
        return Icons.warning_amber_rounded;
      case InsightType.savingsOpportunity:
        return Icons.savings;
      case InsightType.unusualActivity:
        return Icons.error_outline;
      case InsightType.goalProgress:
        return Icons.flag;
      case InsightType.billReminder:
        return Icons.receipt;
      case InsightType.categoryAnalysis:
        return Icons.pie_chart;
      case InsightType.monthlySummary:
        return Icons.calendar_month;
      case InsightType.comparison:
        return Icons.compare_arrows;
      case InsightType.recommendation:
        return Icons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    final insightColor = _getInsightColor(insight.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            insightColor.withValues(alpha: 0.1),
            insightColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insightColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insightColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getInsightIcon(insight.type),
                  color: insightColor,
                  size: 18,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  insight.title,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing3),
          Text(
            insight.message,
            style: AppTypographyExtended.metricLabel.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (insight.amount != null) ...[
            SizedBox(height: AppDimensions.spacing3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: insightColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: insightColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(insight.amount),
                    style: AppTypographyExtended.statsValue.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: insightColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

# PART 2: TRANSACTION PAGE TRANSFORMATION

## 🎯 Phase 1: Transaction List Enhancement

### 1.1 Enhanced Transaction Header

```dart
// lib/features/transactions/presentation/widgets/enhanced_transaction_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';

class EnhancedTransactionHeader extends ConsumerWidget {
  const EnhancedTransactionHeader({
    super.key,
    required this.onFilterPressed,
    required this.onSearchChanged,
    this.hasActiveFilters = false,
  });

  final VoidCallback onFilterPressed;
  final ValueChanged<String> onSearchChanged;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Filter Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: AppTypographyExtended.circularProgressPercentage.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: hasActiveFilters
                          ? AppColorsExtended.budgetPrimary.withValues(alpha: 0.1)
                          : AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: hasActiveFilters
                            ? AppColorsExtended.budgetPrimary
                            : AppColors.textSecondary,
                      ),
                      onPressed: onFilterPressed,
                      tooltip: 'Filter',
                    ),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColorsExtended.budgetPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing3),
          
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColorsExtended.pillBgUnselected,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: AppTypographyExtended.metricLabel.copyWith(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 1.2 Enhanced Transaction Stats Card

```dart
// lib/features/transactions/presentation/widgets/enhanced_transaction_stats_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../states/transaction_state.dart';

class EnhancedTransactionStatsCard extends StatelessWidget {
  const EnhancedTransactionStatsCard({
    super.key,
    required this.stats,
  });

  final TransactionStats stats;

  @override
  Widget build(BuildContext context) {
    final savingsRate = stats.totalIncome > 0
        ? (stats.totalIncome - stats.totalExpenses) / stats.totalIncome
        : 0.0;

    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.budgetPrimary,
            AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                'This Month',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1, duration: 400.ms),
          
          SizedBox(height: AppDimensions.spacing4),
          
          // Main Stats Row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Income',
                  amount: stats.totalIncome,
                  icon: Icons.arrow_downward,
                  color: Colors.white,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 100.ms),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Expenses',
                  amount: stats.totalExpenses,
                  icon: Icons.arrow_upward,
                  color: Colors.white,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 200.ms),
              ),
            ],
          ),
          
          SizedBox(height: AppDimensions.spacing4),
          
          // Savings Rate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      savingsRate > 0 ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: AppDimensions.spacing2),
                    Text(
                      'Savings Rate',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: savingsRate),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '${(value * 100).toInt()}%',
                      style: AppTypographyExtended.statsValue.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 300.ms),
          
          SizedBox(height: AppDimensions.spacing3),
          
          // Transaction Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Transactions',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stats.transactionCount}',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: 400.ms, delay: 400.ms),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: color.withValues(alpha: 0.8),
            ),
            SizedBox(width: AppDimensions.spacing1),
            Text(
              label,
              style: AppTypographyExtended.metricLabel.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing2),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: amount),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value),
              style: AppTypographyExtended.statsValue.copyWith(
                fontSize: 22,
                color: color,
              ),
            );
          },
        ),
      ],
    );
  }
}
1.3 Enhanced Transaction Tile
dart// lib/features/transactions/presentation/widgets/enhanced_transaction_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

class EnhancedTransactionTile extends ConsumerWidget {
  const EnhancedTransactionTile({
    super.key,
    required this.transaction,
    this.showDateLabel = false,
  });

  final Transaction transaction;
  final bool showDateLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense 
        ? AppColorsExtended.statusCritical 
        : AppColorsExtended.statusNormal;
    
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    final categories = ref.watch(transactionCategoriesProvider);
    final category = categories.where((c) => c.id == transaction.categoryId).firstOrNull;
    final categoryIcon = categoryIconColorService.getIconForCategory(transaction.categoryId);
    final categoryColor = categoryIconColorService.getColorForCategory(transaction.categoryId);
    final categoryName = category?.name ?? 'Unknown';

    return Slidable(
      key: ValueKey(transaction.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editTransaction(context, transaction),
            backgroundColor: AppColorsExtended.budgetPrimary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteTransaction(context, ref, transaction),
            backgroundColor: AppColorsExtended.statusCritical,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (context.mounted) {
              context.go('/transactions/${transaction.id}');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Category Icon with gradient background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    categoryIcon,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppDimensions.spacing3),
                
                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? 'Transaction',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: categoryColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              categoryName,
                              style: AppTypographyExtended.metricLabel.copyWith(
                                color: categoryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(transaction.date),
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Amount with badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '-' : '+'}${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(transaction.amount)}',
                      style: AppTypographyExtended.statsValue.copyWith(
                        fontSize: 16,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: amountColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 10,
                            color: amountColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isExpense ? 'OUT' : 'IN',
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: amountColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context, Transaction transaction) {
    HapticFeedback.lightImpact();
    // Navigate to edit
    // TODO: Implement edit transaction
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColorsExtended.statusCritical,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(transactionNotifierProvider.notifier)
          .deleteTransaction(transaction.id);

      if (success && context.mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    }
  }
}
1.4 Enhanced Transaction List Screen
dart// lib/features/transactions/presentation/screens/transaction_list_screen_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import '../states/transaction_state.dart';
import '../widgets/enhanced_transaction_header.dart';
import '../widgets/enhanced_transaction_stats_card.dart';
import '../widgets/enhanced_transaction_tile.dart';
import '../widgets/add_transaction_bottom_sheet.dart';
import '../widgets/transaction_filters_bottom_sheet.dart';

/// Enhanced Transaction List Screen with modern UI
class TransactionListScreenEnhanced extends ConsumerStatefulWidget {
  const TransactionListScreenEnhanced({super.key});

  @override
  ConsumerState<TransactionListScreenEnhanced> createState() => _TransactionListScreenEnhancedState();
}

class _TransactionListScreenEnhancedState extends ConsumerState<TransactionListScreenEnhanced> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionNotifierProvider.notifier).initializeWithPagination();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionNotifierProvider);
    final stats = ref.watch(transactionStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            EnhancedTransactionHeader(
              onFilterPressed: () => _showFilterSheet(context),
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                ref.read(transactionNotifierProvider.notifier).searchTransactions(query);
              },
              hasActiveFilters: transactionState.value?.filter != null,
            ),
            
            // Main Content
            Expanded(
              child: transactionState.when(
                data: (state) => _buildBody(state, stats),
                loading: () => const LoadingView(),
                error: (error, stack) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.refresh(transactionNotifierProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildBody(TransactionState state, TransactionStats stats) {
    if (state.transactions.isEmpty && !state.isLoading) {
      return _buildEmptyState();
    }

    if (state.transactions.isEmpty && state.isLoading) {
      return const LoadingView();
    }

    final groupedTransactions = state.transactionsByDate;

    if (groupedTransactions.isEmpty) {
      if (state.transactions.isNotEmpty && (state.searchQuery != null || state.filter != null)) {
        return _buildNoMatchesState();
      }
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(transactionNotifierProvider.notifier).loadTransactions();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        itemCount: _calculateItemCount(groupedTransactions, state),
        itemBuilder: (context, index) {
          return _buildListItem(context, index, groupedTransactions, stats, state);
        },
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Map<DateTime, List<Transaction>> groupedTransactions,
    TransactionStats stats,
    TransactionState state,
  ) {
    int currentIndex = 0;

    // Stats Card (index 0)
    if (index == currentIndex++) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: EnhancedTransactionStatsCard(stats: stats)
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic),
      );
    }

    // Transactions grouped by date
    for (final entry in groupedTransactions.entries) {
      final date = entry.key;
      final dayTransactions = entry.value;

      // Date header
      if (index == currentIndex++) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
          child: _DateHeader(date: date)
              .animate()
              .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * (currentIndex ~/ 2)))
              .slideX(begin: -0.1, duration: 300.ms, delay: Duration(milliseconds: 50 * (currentIndex ~/ 2))),
        );
      }

      // Transactions for this date
      for (final transaction in dayTransactions) {
        if (index == currentIndex++) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: EnhancedTransactionTile(transaction: transaction)
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 30 * (currentIndex - 1)))
                .slideX(begin: 0.05, duration: 400.ms, delay: Duration(milliseconds: 30 * (currentIndex - 1))),
          );
        }
      }

      // Spacing after date group
      if (index == currentIndex++) {
        return SizedBox(height: AppDimensions.spacing4);
      }
    }

    // Load More Button
    if (state.hasMoreData && !state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing4),
        child: Center(
          child: TextButton.icon(
            onPressed: () => ref.read(transactionNotifierProvider.notifier).loadMoreTransactions(),
            icon: const Icon(Icons.expand_more),
            label: const Text('Load More'),
            style: TextButton.styleFrom(
              foregroundColor: AppColorsExtended.budgetPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      );
    } else if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            decoration: BoxDecoration(
              color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColorsExtended.budgetPrimary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'No transactions yet',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 24,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Add your first transaction to\nstart tracking your finances',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildNoMatchesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            decoration: BoxDecoration(
              color: AppColorsExtended.statusWarning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: AppColorsExtended.statusWarning,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'No matching transactions',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 24,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Try adjusting your search\nor filters',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),
          SizedBox(height: AppDimensions.spacing5),
          TextButton.icon(
            onPressed: () {
              ref.read(transactionNotifierProvider.notifier).clearFilter();
              ref.read(transactionNotifierProvider.notifier).clearSearch();
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear Filters'),
            style: TextButton.styleFrom(
              foregroundColor: AppColorsExtended.statusWarning,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.budgetPrimary,
            AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddTransactionSheet(context),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Add Transaction',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 600.ms)
      .slideY(begin: 0.1, duration: 300.ms, delay: 600.ms, curve: Curves.elasticOut);
  }

  int _calculateItemCount(Map<DateTime, List<Transaction>> groupedTransactions, TransactionState state) {
    int count = 1; // Stats card

    for (final dayTransactions in groupedTransactions.values) {
      count += 1 + dayTransactions.length + 1; // header + transactions + spacing
    }

    if (state.hasMoreData || state.isLoadingMore) {
      count += 1;
    }

    return count;
  }

  Future<void> _showAddTransactionSheet(BuildContext context) async {
    await AppBottomSheet.show(
      context: context,
      child: AddTransactionBottomSheet(
        onSubmit: (transaction) async {
          final success = await ref
              .read(transactionNotifierProvider.notifier)
              .addTransaction(transaction);

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction added successfully')),
            );
          }
        },
      ),
    );
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final currentState = ref.read(transactionNotifierProvider).value;
    if (currentState == null) return;

    final categories = ref.read(transactionCategoriesProvider);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterBottomSheet(
        currentFilter: currentState.filter,
        categories: categories,
        onApplyFilter: (filter) {
          ref.read(transactionNotifierProvider.notifier).applyFilter(filter);
          Navigator.pop(context);
        },
        onClearFilter: () {
          ref.read(transactionNotifierProvider.notifier).clearFilter();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMMM dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing3,
        vertical: AppDimensions.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              size: 14,
              color: AppColorsExtended.budgetPrimary,
            ),
          ),
          SizedBox(width: AppDimensions.spacing2),
          Text(
            _formatDate(),
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}