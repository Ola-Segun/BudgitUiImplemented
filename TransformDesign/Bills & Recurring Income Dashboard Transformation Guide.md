# Comprehensive Unified Bills & Recurring Income Dashboard Transformation Guide

## 🎯 Executive Overview

This guide transforms the separate Bills and Recurring Income screens into a **unified Financial Obligations Dashboard** that combines all recurring financial commitments (both outgoing and incoming) into a cohesive, visually stunning interface inspired by the enhanced Budget, Home, and Transaction designs.

---

## 📋 Table of Contents

### Part 1: Unified Dashboard Architecture
1. Design Philosophy & Information Hierarchy
2. Unified Data Model
3. Component Inventory & Reuse Strategy

### Part 2: Core Components Implementation
1. Unified Dashboard Header
2. Financial Health Overview (Circular Indicator)
3. Cash Flow Timeline Visualization
4. Unified Obligations List
5. Quick Actions Bar
6. Insights & Analytics

### Part 3: Advanced Features
1. Interactive Calendar View
2. Smart Filtering & Categorization
3. Payment Automation Interface
4. Predictive Analytics Dashboard

### Part 4: Complete Implementation Guide
1. File Structure
2. State Management
3. Navigation & Routing
4. Animation Choreography

---

# PART 1: UNIFIED DASHBOARD ARCHITECTURE

## 1.1 Design Philosophy

### Core Principles

**1. Unified Cash Flow View**
- Treat bills (outgoing) and income (incoming) as parts of a single cash flow story
- Use color coding consistently: Red/Orange for bills, Green/Teal for income
- Show net cash flow prominently

**2. Predictive & Proactive**
- Highlight upcoming obligations before they're due
- Show cash flow projections
- Alert users to potential shortfalls

**3. Visual Hierarchy**
```
Priority 1: Net Cash Flow Status (Circular Indicator)
Priority 2: Urgent Items (Overdue/Due Today)
Priority 3: Upcoming Timeline (Next 30 days)
Priority 4: Historical Trends & Analytics
Priority 5: All Obligations List
```

**4. Simplicity Through Smart Grouping**
- Group by urgency, not type
- Use progressive disclosure
- Minimize cognitive load

---

## 1.2 Unified Data Model

```dart
// lib/features/financial_obligations/domain/entities/financial_obligation.dart

import 'package:flutter/material.dart';

/// Unified model representing both bills and recurring income
class FinancialObligation {
  const FinancialObligation({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.nextDate,
    required this.status,
    this.accountId,
    this.categoryId,
    this.description,
    this.payee,
    this.isAutomated,
    this.lastProcessedDate,
    this.history,
  });

  final String id;
  final String name;
  final double amount;
  final ObligationType type;
  final ObligationFrequency frequency;
  final DateTime nextDate;
  final ObligationStatus status;
  final String? accountId;
  final String? categoryId;
  final String? description;
  final String? payee;
  final bool? isAutomated;
  final DateTime? lastProcessedDate;
  final List<ObligationHistory>? history;

  // Computed properties
  int get daysUntilNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDay = DateTime(nextDate.year, nextDate.month, nextDate.day);
    return nextDay.difference(today).inDays;
  }

  bool get isOverdue => daysUntilNext < 0 && status != ObligationStatus.completed;
  bool get isDueToday => daysUntilNext == 0 && status != ObligationStatus.completed;
  bool get isDueSoon => daysUntilNext > 0 && daysUntilNext <= 7;
  bool get isUpcoming => daysUntilNext > 7 && daysUntilNext <= 30;

  ObligationUrgency get urgency {
    if (isOverdue) return ObligationUrgency.overdue;
    if (isDueToday) return ObligationUrgency.dueToday;
    if (isDueSoon) return ObligationUrgency.dueSoon;
    return ObligationUrgency.normal;
  }

  Color get typeColor => type == ObligationType.bill
      ? const Color(0xFFEF4444) // Red for bills
      : const Color(0xFF10B981); // Green for income

  String get formattedAmount => NumberFormat.currency(
        symbol: '\$',
        decimalDigits: 0,
      ).format(amount);
}

enum ObligationType {
  bill,
  income;

  String get displayName {
    switch (this) {
      case ObligationType.bill:
        return 'Bill';
      case ObligationType.income:
        return 'Income';
    }
  }

  IconData get icon {
    switch (this) {
      case ObligationType.bill:
        return Icons.arrow_upward;
      case ObligationType.income:
        return Icons.arrow_downward;
    }
  }
}

enum ObligationFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  annually;

  String get displayName {
    switch (this) {
      case ObligationFrequency.daily:
        return 'Daily';
      case ObligationFrequency.weekly:
        return 'Weekly';
      case ObligationFrequency.biweekly:
        return 'Bi-weekly';
      case ObligationFrequency.monthly:
        return 'Monthly';
      case ObligationFrequency.quarterly:
        return 'Quarterly';
      case ObligationFrequency.annually:
        return 'Annually';
    }
  }
}

enum ObligationStatus {
  pending,
  completed,
  failed,
  skipped;

  String get displayName {
    switch (this) {
      case ObligationStatus.pending:
        return 'Pending';
      case ObligationStatus.completed:
        return 'Completed';
      case ObligationStatus.failed:
        return 'Failed';
      case ObligationStatus.skipped:
        return 'Skipped';
    }
  }
}

enum ObligationUrgency {
  overdue,
  dueToday,
  dueSoon,
  normal;

  String get displayName {
    switch (this) {
      case ObligationUrgency.overdue:
        return 'Overdue';
      case ObligationUrgency.dueToday:
        return 'Due Today';
      case ObligationUrgency.dueSoon:
        return 'Due Soon';
      case ObligationUrgency.normal:
        return 'Upcoming';
    }
  }

  Color get color {
    switch (this) {
      case ObligationUrgency.overdue:
        return const Color(0xFFDC2626); // Red-600
      case ObligationUrgency.dueToday:
        return const Color(0xFFEA580C); // Orange-600
      case ObligationUrgency.dueSoon:
        return const Color(0xFFF59E0B); // Amber-500
      case ObligationUrgency.normal:
        return const Color(0xFF3B82F6); // Blue-500
    }
  }
}

class ObligationHistory {
  const ObligationHistory({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    this.notes,
    this.transactionId,
  });

  final String id;
  final DateTime date;
  final double amount;
  final ObligationStatus status;
  final String? notes;
  final String? transactionId;
}

/// Summary model for dashboard statistics
class FinancialObligationsSummary {
  const FinancialObligationsSummary({
    required this.totalBills,
    required this.totalIncome,
    required this.netCashFlow,
    required this.upcomingBills,
    required this.upcomingIncome,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.dueSoonCount,
    required this.monthlyBillTotal,
    required this.monthlyIncomeTotal,
    required this.automatedCount,
  });

  final int totalBills;
  final int totalIncome;
  final double netCashFlow;
  final List<FinancialObligation> upcomingBills;
  final List<FinancialObligation> upcomingIncome;
  final int overdueCount;
  final int dueTodayCount;
  final int dueSoonCount;
  final double monthlyBillTotal;
  final double monthlyIncomeTotal;
  final int automatedCount;

  double get cashFlowRatio => monthlyIncomeTotal > 0
      ? monthlyBillTotal / monthlyIncomeTotal
      : 0.0;

  bool get isHealthy => netCashFlow > 0 && overdueCount == 0;
  bool get needsAttention => overdueCount > 0 || dueTodayCount > 0;
  bool get isCritical => netCashFlow < 0 || overdueCount > 3;
}
```

---

## 1.3 Component Inventory & Reuse Strategy

### Components from Budget Implementation (Reuse)

| Component | Original Use | New Use in Obligations |
|-----------|-------------|------------------------|
| `CircularBudgetIndicator` | Budget progress | Net cash flow visualization |
| `DateSelectorPills` | Date navigation | Period selection |
| `BudgetStatusBanner` | Budget alerts | Cash flow status alerts |
| `BudgetMetricCards` | Budget metrics | Bill/Income summary cards |
| `BudgetStatsRow` | Three-column stats | Bills/Income/Net stats |
| `BudgetBarChart` | Spending trends | Cash flow trends |
| `MiniTrendIndicator` | Category trends | Obligation history sparklines |

### New Components to Create

1. **UnifiedObligationsHeader** - Smart header with filters
2. **CashFlowCircularIndicator** - Adapted circular progress
3. **ObligationTimeline** - Visual timeline of upcoming items
4. **ObligationCard** - Unified card for bills and income
5. **CashFlowProjection** - Forward-looking cash flow chart
6. **SmartAlertBanner** - Proactive warnings
7. **AutomationToggleCard** - Manage autopay settings

---

# PART 2: CORE COMPONENTS IMPLEMENTATION

## 2.1 Unified Dashboard Header

```dart
// lib/features/financial_obligations/presentation/widgets/unified_obligations_header.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/date_selector_pills.dart';

/// Unified header for Financial Obligations Dashboard
class UnifiedObligationsHeader extends ConsumerStatefulWidget {
  const UnifiedObligationsHeader({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.activeFilter,
    required this.onFilterChanged,
    this.overdueCount = 0,
    this.dueTodayCount = 0,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final ObligationFilter activeFilter;
  final ValueChanged<ObligationFilter> onFilterChanged;
  final int overdueCount;
  final int dueTodayCount;

  @override
  ConsumerState<UnifiedObligationsHeader> createState() => _UnifiedObligationsHeaderState();
}

class _UnifiedObligationsHeaderState extends ConsumerState<UnifiedObligationsHeader> {
  bool _showDateSelector = false;

  @override
  Widget build(BuildContext context) {
    final currentPeriod = DateFormat('MMMM yyyy').format(widget.selectedDate);
    final hasUrgentItems = widget.overdueCount > 0 || widget.dueTodayCount > 0;

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
          // Top bar with title and actions
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.spacing3,
            ),
            child: Row(
              children: [
                // Title with urgent badge
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Cash Flow',
                        style: AppTypographyExtended.circularProgressPercentage.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (hasUrgentItems) ...[
                        SizedBox(width: AppDimensions.spacing2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.overdueCount + widget.dueTodayCount}',
                                style: AppTypographyExtended.metricLabel.copyWith(
                                  color: const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ).animate()
                          .fadeIn(duration: 300.ms)
                          .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.elasticOut),
                      ],
                    ],
                  ),
                ),
                
                // Period selector button
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 18,
                          color: AppColorsExtended.budgetPrimary,
                        ),
                        SizedBox(width: AppDimensions.spacing2),
                        Text(
                          currentPeriod,
                          style: AppTypographyExtended.metricLabel.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: AppDimensions.spacing1),
                        Icon(
                          _showDateSelector
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
            child: Row(
              children: ObligationFilter.values.map((filter) {
                final isActive = widget.activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterPill(
                    label: filter.displayName,
                    icon: filter.icon,
                    isActive: isActive,
                    color: filter.color,
                    count: _getFilterCount(filter),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onFilterChanged(filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: AppDimensions.spacing3),

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
            ).animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.1, duration: 200.ms),
        ],
      ),
    );
  }

  int _getFilterCount(ObligationFilter filter) {
    // This would come from state/provider in real implementation
    switch (filter) {
      case ObligationFilter.all:
        return 0;
      case ObligationFilter.bills:
        return 0;
      case ObligationFilter.income:
        return 0;
      case ObligationFilter.overdue:
        return widget.overdueCount;
      case ObligationFilter.upcoming:
        return 0;
      case ObligationFilter.automated:
        return 0;
    }
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
    this.count,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.15)
                : AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(20),
            border: isActive
                ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? color : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: isActive ? color : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum ObligationFilter {
  all,
  bills,
  income,
  overdue,
  upcoming,
  automated;

  String get displayName {
    switch (this) {
      case ObligationFilter.all:
        return 'All';
      case ObligationFilter.bills:
        return 'Bills';
      case ObligationFilter.income:
        return 'Income';
      case ObligationFilter.overdue:
        return 'Urgent';
      case ObligationFilter.upcoming:
        return 'Upcoming';
      case ObligationFilter.automated:
        return 'Automated';
    }
  }

  IconData get icon {
    switch (this) {
      case ObligationFilter.all:
        return Icons.grid_view_rounded;
      case ObligationFilter.bills:
        return Icons.arrow_upward_rounded;
      case ObligationFilter.income:
        return Icons.arrow_downward_rounded;
      case ObligationFilter.overdue:
        return Icons.warning_amber_rounded;
      case ObligationFilter.upcoming:
        return Icons.schedule_rounded;
      case ObligationFilter.automated:
        return Icons.autorenew_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ObligationFilter.all:
        return AppColorsExtended.budgetPrimary;
      case ObligationFilter.bills:
        return const Color(0xFFEF4444); // Red
      case ObligationFilter.income:
        return const Color(0xFF10B981); // Green
      case ObligationFilter.overdue:
        return const Color(0xFFDC2626); // Dark Red
      case ObligationFilter.upcoming:
        return const Color(0xFF3B82F6); // Blue
      case ObligationFilter.automated:
        return const Color(0xFF8B5CF6); // Purple
    }
  }
}
```

## 2.2 Cash Flow Circular Indicator

```dart
// lib/features/financial_obligations/presentation/widgets/cash_flow_circular_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';

/// Circular indicator showing net cash flow (income - bills)
class CashFlowCircularIndicator extends StatelessWidget {
  const CashFlowCircularIndicator({
    super.key,
    required this.monthlyIncome,
    required this.monthlyBills,
    this.size = 240,
    this.strokeWidth = 24,
  });

  final double monthlyIncome;
  final double monthlyBills;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final netCashFlow = monthlyIncome - monthlyBills;
    final billPercentage = monthlyIncome > 0 ? monthlyBills / monthlyIncome : 0.0;
    final isHealthy = netCashFlow > 0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Base circular indicator (reusing budget component)
        CircularBudgetIndicator(
          percentage: billPercentage.clamp(0.0, 1.0),
          spent: monthlyBills,
          total: monthlyIncome > 0 ? monthlyIncome : monthlyBills,
          size: size,
          strokeWidth: strokeWidth,
        ),

        // Center content - Net Cash Flow
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Net cash flow label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isHealthy
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHealthy
                      ? const Color(0xFF10B981).withValues(alpha: 0.3)
                      : const Color(0xFFEF4444).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isHealthy ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: isHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Net Flow',
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: isHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 400.ms, delay: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, delay: 600.ms),
            
            const SizedBox(height: 12),

            // Net amount
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: netCashFlow),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  NumberFormat.currency(symbol: isHealthy ? '+\$' : '-\$', decimalDigits: 0)
                      .format(value.abs()),
                  style: AppTypographyExtended.circularProgressPercentage.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: isHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            // Percentage of income saved/overspent
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: (netCashFlow / monthlyIncome).clamp(-1.0, 1.0)),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  '${(value * 100).abs().toInt()}% ${isHealthy ? 'saved' : 'over'}',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                );
              },
            ),
          ],
        ),

        // Status indicators around the circle
        _buildStatusIndicators(context),
      ],
    );
  }

  Widget _buildStatusIndicators(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Income indicator (top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _StatusPill(
                label: 'Income',
                amount: monthlyIncome,
                icon: Icons.arrow_downward,
                color: const Color(0xFF10B981),
              ).animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: -0.3, duration: 400.ms, delay: 200.ms, curve: Curves.elasticOut),
            ),
          ),

          // Bills indicator (bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _StatusPill(
                label: 'Bills',
                amount: monthlyBills,
                icon: Icons.arrow_upward,
                color: const Color(0xFFEF4444),
              ).animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.3, duration: 400.ms, delay: 400.ms, curve: Curves.elasticOut),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount),
                style: AppTypographyExtended.metricLabel.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
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
## 2.3 Unified Obligation Timeline

```dart
// lib/features/financial_obligations/presentation/widgets/obligation_timeline.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/financial_obligation.dart';

/// Visual timeline of upcoming obligations (next 30 days)
class ObligationTimeline extends StatelessWidget {
  const ObligationTimeline({
    super.key,
    required this.obligations,
    this.maxDays = 30,
  });

  final List<FinancialObligation> obligations;
  final int maxDays;

  @override
  Widget build(BuildContext context) {
    final upcomingObligations = obligations
        .where((o) => o.daysUntilNext >= 0 && o.daysUntilNext <= maxDays)
        .toList()
      ..sort((a, b) => a.nextDate.compareTo(b.nextDate));

    if (upcomingObligations.isEmpty) {
      return _buildEmptyTimeline();
    }

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsExtended.budgetTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timeline,
                  size: 20,
                  color: AppColorsExtended.budgetTertiary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  'Next 30 Days',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildTimelineLegend(),
            ],
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1, duration: 400.ms),
          
          SizedBox(height: AppDimensions.spacing4),

          // Timeline visualization
          _buildTimelineVisualization(upcomingObligations),

          SizedBox(height: AppDimensions.spacing4),

          // Upcoming items list
          ...upcomingObligations.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TimelineObligationCard(
                obligation: obligation,
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 100 * index)),
            );
          }),

          if (upcomingObligations.length > 5) ...[
            SizedBox(height: AppDimensions.spacing2),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Navigate to full timeline view
                },
                icon: const Icon(Icons.expand_more, size: 18),
                label: Text(
                  'View ${upcomingObligations.length - 5} More',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColorsExtended.budgetPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendDot(color: const Color(0xFFEF4444), label: 'Bills'),
        const SizedBox(width: 12),
        _LegendDot(color: const Color(0xFF10B981), label: 'Income'),
      ],
    );
  }

  Widget _buildTimelineVisualization(List<FinancialObligation> obligations) {
    return SizedBox(
      height: 60,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          
          return Stack(
            children: [
              // Timeline base line
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColorsExtended.pillBgUnselected,
                        AppColorsExtended.pillBgUnselected.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),

              // Today marker
              Positioned(
                top: 20,
                left: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Today',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColorsExtended.budgetPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColorsExtended.budgetPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ).animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5), duration: 400.ms),
              ),

              // Obligation markers
              ...obligations.take(10).map((obligation) {
                final position = (obligation.daysUntilNext / maxDays) * width;
                return Positioned(
                  top: 25,
                  left: position.clamp(20.0, width - 20),
                  child: _TimelineMarker(
                    obligation: obligation,
                  ).animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 200 + (obligation.daysUntilNext * 10)),
                    )
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      duration: 400.ms,
                      delay: Duration(milliseconds: 200 + (obligation.daysUntilNext * 10)),
                    ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyTimeline() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming obligations',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up for the next 30 days',
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({
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

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({
    required this.obligation,
  });

  final FinancialObligation obligation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: obligation.typeColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: obligation.typeColor.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _TimelineObligationCard extends StatelessWidget {
  const _TimelineObligationCard({
    required this.obligation,
  });

  final FinancialObligation obligation;

  @override
  Widget build(BuildContext context) {
    final isOverdue = obligation.isOverdue;
    final isDueToday = obligation.isDueToday;
    final isBill = obligation.type == ObligationType.bill;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          final route = isBill ? '/more/bills/${obligation.id}' : '/more/incomes/${obligation.id}';
          context.go(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(12),
            border: (isOverdue || isDueToday)
                ? Border.all(
                    color: obligation.urgency.color.withValues(alpha: 0.3),
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Timeline indicator line
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: obligation.typeColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: obligation.typeColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Obligation icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: obligation.typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  obligation.type.icon,
                  size: 18,
                  color: obligation.typeColor,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Obligation details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      obligation.name,
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
                          _getStatusIcon(),
                          size: 12,
                          color: obligation.urgency.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(),
                          style: AppTypographyExtended.metricLabel.copyWith(
                            color: obligation.urgency.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount and type badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    obligation.formattedAmount,
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: obligation.typeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: obligation.typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      obligation.type.displayName,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: obligation.typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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

  IconData _getStatusIcon() {
    if (obligation.isOverdue) return Icons.error_outline;
    if (obligation.isDueToday) return Icons.warning_amber_rounded;
    if (obligation.isDueSoon) return Icons.access_time;
    return Icons.schedule;
  }

  String _getStatusText() {
    if (obligation.isOverdue) {
      return '${obligation.daysUntilNext.abs()}d overdue';
    } else if (obligation.isDueToday) {
      return 'Due today';
    } else if (obligation.daysUntilNext == 1) {
      return 'Tomorrow';
    } else {
      return 'In ${obligation.daysUntilNext}d';
    }
  }
}
```

## 2.4 Enhanced Obligation Card

```dart
// lib/features/financial_obligations/presentation/widgets/enhanced_obligation_card.dart

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
import '../../../budgets/presentation/widgets/mini_trend_indicator.dart';
import '../../domain/entities/financial_obligation.dart';

/// Enhanced unified card for both bills and recurring income
class EnhancedObligationCard extends ConsumerWidget {
  const EnhancedObligationCard({
    super.key,
    required this.obligation,
    this.onEdit,
    this.onDelete,
    this.onMarkComplete,
  });

  final FinancialObligation obligation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBill = obligation.type == ObligationType.bill;
    final isOverdue = obligation.isOverdue;
    final isDueToday = obligation.isDueToday;

    // Mock trend data - replace with actual historical data
    final trendData = List.generate(7, (i) => obligation.amount * (0.9 + (i * 0.02)));

    return Slidable(
      key: ValueKey(obligation.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.lightImpact();
              onEdit?.call();
            },
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
          if (onMarkComplete != null)
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.mediumImpact();
                onMarkComplete?.call();
              },
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              icon: Icons.check_circle,
              label: isBill ? 'Pay' : 'Receive',
              borderRadius: BorderRadius.circular(12),
            ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              onDelete?.call();
            },
            backgroundColor: const Color(0xFFEF4444),
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
            final route = isBill ? '/more/bills/${obligation.id}' : '/more/incomes/${obligation.id}';
            context.go(route);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: (isOverdue || isDueToday)
                  ? Border.all(
                      color: obligation.urgency.color.withValues(alpha: 0.3),
                      width: 2,
                    )
                  : Border.all(
                      color: AppColors.borderSubtle,
                      width: 1,
                    ),
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
                // Header Row
                Row(
                  children: [
                    // Type indicator with gradient
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                obligation.typeColor,
                                obligation.typeColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: obligation.typeColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            obligation.type.icon,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                        // Automation indicator
                        if (obligation.isAutomated == true)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.autorenew,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: AppDimensions.spacing3),

                    // Obligation name and frequency
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obligation.name,
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
                                  color: obligation.typeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: obligation.typeColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  obligation.frequency.displayName,
                                  style: AppTypographyExtended.metricLabel.copyWith(
                                    color: obligation.typeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (obligation.isAutomated == true) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.autorenew,
                                        size: 10,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Auto',
                                        style: AppTypographyExtended.metricLabel.copyWith(
                                          color: const Color(0xFF8B5CF6),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Amount and urgency badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          obligation.formattedAmount,
                          style: AppTypographyExtended.statsValue.copyWith(
                            fontSize: 18,
                            color: obligation.typeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: obligation.urgency.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            obligation.urgency.displayName,
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: obligation.urgency.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: AppDimensions.spacing4),

                // Progress/Status Row
                Row(
                  children: [
                    // Status icon and text
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 16,
                            color: obligation.urgency.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(),
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: obligation.urgency.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mini trend indicator
                    MiniTrendIndicator(
                      values: trendData,
                      color: obligation.typeColor,
                      width: 60,
                      height: 24,
                    ),
                  ],
                ),

                SizedBox(height: AppDimensions.spacing3),

                // Footer Row
                Row(
                  children: [
                    // Due date
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(obligation.nextDate),
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),

                    const Spacer(),

                    // Account link indicator
                    if (obligation.accountId != null) ...[
                      Icon(
                        Icons.account_balance_wallet,
                        size: 12,
                        color: AppColorsExtended.budgetSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Linked',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColorsExtended.budgetSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.link_off,
                        size: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Not linked',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    if (obligation.isOverdue) return Icons.error_outline;
    if (obligation.isDueToday) return Icons.warning_amber_rounded;
    if (obligation.isDueSoon) return Icons.access_time;
    return Icons.schedule;
  }

  String _getStatusText() {
    if (obligation.isOverdue) {
      return '${obligation.daysUntilNext.abs()} days overdue';
    } else if (obligation.isDueToday) {
      return 'Due today';
    } else if (obligation.daysUntilNext == 1) {
      return 'Tomorrow';
    } else if (obligation.daysUntilNext <= 7) {
      return 'In ${obligation.daysUntilNext} days';
    } else {
      return DateFormat('MMM dd').format(obligation.nextDate);
    }
  }
}
```

## 2.5 Smart Alert Banner

```dart
// lib/features/financial_obligations/presentation/widgets/smart_alert_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/financial_obligation.dart';

/// Smart banner showing proactive alerts and warnings
class SmartAlertBanner extends StatelessWidget {
  const SmartAlertBanner({
    super.key,
    required this.summary,
  });

  final FinancialObligationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final alert = _determineAlert();
    if (alert == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            alert.color.withValues(alpha: 0.15),
            alert.color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: alert.isCritical
            ? [
                BoxShadow(
                  color: alert.color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Alert icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alert.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                ```dart
                BoxShadow(
                  color: alert.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              alert.icon,
              size: 24,
              color: alert.color,
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Alert content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: alert.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        alert.level.displayName,
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: alert.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (alert.subMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    alert.subMessage!,
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action button (optional)
          if (alert.actionLabel != null) ...[
            SizedBox(width: AppDimensions.spacing2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: alert.color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: alert.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                alert.actionLabel!,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: -0.1, duration: 400.ms, curve: Curves.easeOutCubic)
      .then()
      .shimmer(
        duration: 2000.ms,
        color: Colors.white.withValues(alpha: 0.3),
      );
  }

  _AlertData? _determineAlert() {
    // Critical: Overdue items
    if (summary.overdueCount > 0) {
      return _AlertData(
        level: AlertLevel.critical,
        icon: Icons.error_rounded,
        message: 'You have ${summary.overdueCount} overdue ${summary.overdueCount == 1 ? 'item' : 'items'}',
        subMessage: 'Action required to avoid late fees or missed income',
        actionLabel: 'Review',
        isCritical: true,
      );
    }

    // Warning: Due today
    if (summary.dueTodayCount > 0) {
      return _AlertData(
        level: AlertLevel.warning,
        icon: Icons.warning_amber_rounded,
        message: '${summary.dueTodayCount} ${summary.dueTodayCount == 1 ? 'item is' : 'items are'} due today',
        subMessage: 'Total amount: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(_getTodayTotal())}',
        actionLabel: 'View',
        isCritical: false,
      );
    }

    // Info: Negative cash flow
    if (summary.netCashFlow < 0) {
      return _AlertData(
        level: AlertLevel.info,
        icon: Icons.trending_down,
        message: 'Bills exceed income by ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(summary.netCashFlow.abs())}',
        subMessage: 'Consider reviewing your budget or increasing income',
        actionLabel: null,
        isCritical: false,
      );
    }

    // Success: All clear
    if (summary.overdueCount == 0 && summary.dueTodayCount == 0 && summary.netCashFlow > 0) {
      return _AlertData(
        level: AlertLevel.success,
        icon: Icons.check_circle_rounded,
        message: 'All obligations are on track',
        subMessage: 'Next payment due ${_getNextDueText()}',
        actionLabel: null,
        isCritical: false,
      );
    }

    return null;
  }

  double _getTodayTotal() {
    return summary.upcomingBills
        .where((b) => b.isDueToday)
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  String _getNextDueText() {
    final allUpcoming = [
      ...summary.upcomingBills,
      ...summary.upcomingIncome,
    ]..sort((a, b) => a.nextDate.compareTo(b.nextDate));

    if (allUpcoming.isEmpty) return 'None';

    final next = allUpcoming.first;
    if (next.daysUntilNext == 1) return 'tomorrow';
    return 'in ${next.daysUntilNext} days';
  }
}

class _AlertData {
  const _AlertData({
    required this.level,
    required this.icon,
    required this.message,
    this.subMessage,
    this.actionLabel,
    required this.isCritical,
  });

  final AlertLevel level;
  final IconData icon;
  final String message;
  final String? subMessage;
  final String? actionLabel;
  final bool isCritical;

  Color get color => level.color;
}

enum AlertLevel {
  critical,
  warning,
  info,
  success;

  String get displayName {
    switch (this) {
      case AlertLevel.critical:
        return 'CRITICAL';
      case AlertLevel.warning:
        return 'WARNING';
      case AlertLevel.info:
        return 'INFO';
      case AlertLevel.success:
        return 'ALL CLEAR';
    }
  }

  Color get color {
    switch (this) {
      case AlertLevel.critical:
        return const Color(0xFFDC2626); // Red-600
      case AlertLevel.warning:
        return const Color(0xFFEA580C); // Orange-600
      case AlertLevel.info:
        return const Color(0xFF3B82F6); // Blue-500
      case AlertLevel.success:
        return const Color(0xFF10B981); // Green-500
    }
  }
}
```

## 2.6 Cash Flow Stats Row

```dart
// lib/features/financial_obligations/presentation/widgets/cash_flow_stats_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/financial_obligation.dart';

/// Three-column stats showing bills, income, and net cash flow
class CashFlowStatsRow extends StatelessWidget {
  const CashFlowStatsRow({
    super.key,
    required this.summary,
  });

  final FinancialObligationsSummary summary;

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
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              label: 'Monthly Bills',
              value: summary.monthlyBillTotal,
              icon: Icons.arrow_upward,
              color: const Color(0xFFEF4444),
              count: summary.totalBills,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.2, duration: 400.ms, delay: 100.ms),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.borderSubtle,
          ),
          Expanded(
            child: _StatColumn(
              label: 'Monthly Income',
              value: summary.monthlyIncomeTotal,
              icon: Icons.arrow_downward,
              color: const Color(0xFF10B981),
              count: summary.totalIncome,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, duration: 400.ms, delay: 200.ms),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.borderSubtle,
          ),
          Expanded(
            child: _StatColumn(
              label: 'Net Cash Flow',
              value: summary.netCashFlow,
              icon: summary.netCashFlow >= 0 ? Icons.trending_up : Icons.trending_down,
              color: summary.netCashFlow >= 0 
                  ? const Color(0xFF10B981) 
                  : const Color(0xFFEF4444),
              isNet: true,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(begin: 0.2, duration: 400.ms, delay: 300.ms),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.count,
    this.isNet = false,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final int? count;
  final bool isNet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        SizedBox(height: AppDimensions.spacing2),

        // Value
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Text(
              isNet && value >= 0
                  ? NumberFormat.currency(symbol: '+\$', decimalDigits: 0).format(animatedValue)
                  : NumberFormat.currency(symbol: isNet ? '-\$' : '\$', decimalDigits: 0).format(animatedValue.abs()),
              style: AppTypographyExtended.statsValue.copyWith(
                fontSize: 20,
                color: color,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
        const SizedBox(height: 4),

        // Label
        Text(
          label,
          style: AppTypographyExtended.statsLabel.copyWith(
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Count badge (if provided)
        if (count != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

---

# PART 3: COMPLETE UNIFIED DASHBOARD SCREEN

```dart
// lib/features/financial_obligations/presentation/screens/unified_obligations_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer' as developer;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/financial_obligations_providers.dart';
import '../widgets/unified_obligations_header.dart';
import '../widgets/cash_flow_circular_indicator.dart';
import '../widgets/smart_alert_banner.dart';
import '../widgets/cash_flow_stats_row.dart';
import '../widgets/obligation_timeline.dart';
import '../widgets/enhanced_obligation_card.dart';
import '../widgets/cash_flow_projection_chart.dart';

/// Unified dashboard combining bills and recurring income
class UnifiedObligationsDashboard extends ConsumerStatefulWidget {
  const UnifiedObligationsDashboard({super.key});

  @override
  ConsumerState<UnifiedObligationsDashboard> createState() => _UnifiedObligationsDashboardState();
}

class _UnifiedObligationsDashboardState extends ConsumerState<UnifiedObligationsDashboard> {
  late DateTime _selectedDate;
  ObligationFilter _activeFilter = ObligationFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    developer.log('UnifiedObligationsDashboard initialized', name: 'Obligations');
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building UnifiedObligationsDashboard', name: 'Obligations');
    final obligationsAsync = ref.watch(financialObligationsProvider);
    final summaryAsync = ref.watch(obligationsSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Unified Header
            UnifiedObligationsHeader(
              selectedDate: _selectedDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              activeFilter: _activeFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _activeFilter = filter;
                });
              },
              overdueCount: summaryAsync.value?.overdueCount ?? 0,
              dueTodayCount: summaryAsync.value?.dueTodayCount ?? 0,
            ),

            // Main Content
            Expanded(
              child: obligationsAsync.when(
                loading: () => const LoadingView(),
                error: (error, stack) {
                  developer.log('Obligations error: $error', name: 'Obligations', error: error);
                  return ErrorView(
                    message: error.toString(),
                    onRetry: () => ref.refresh(financialObligationsProvider),
                  );
                },
                data: (obligations) {
                  return summaryAsync.when(
                    loading: () => const LoadingView(),
                    error: (error, stack) => ErrorView(
                      message: error.toString(),
                      onRetry: () => ref.refresh(obligationsSummaryProvider),
                    ),
                    data: (summary) => _buildDashboard(obligations, summary),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildDashboard(
    List<FinancialObligation> obligations,
    FinancialObligationsSummary summary,
  ) {
    final filteredObligations = _filterObligations(obligations);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(financialObligationsProvider);
        ref.invalidate(obligationsSummaryProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Alert Banner
            if (summary.overdueCount > 0 || summary.dueTodayCount > 0 || summary.netCashFlow < 0)
              SmartAlertBanner(summary: summary),
            
            if (summary.overdueCount > 0 || summary.dueTodayCount > 0 || summary.netCashFlow < 0)
              SizedBox(height: AppDimensions.sectionGap),

            // Circular Cash Flow Indicator
            Center(
              child: CashFlowCircularIndicator(
                monthlyIncome: summary.monthlyIncomeTotal,
                monthlyBills: summary.monthlyBillTotal,
              ),
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),
            
            SizedBox(height: AppDimensions.sectionGap),

            // Cash Flow Stats Row
            CashFlowStatsRow(summary: summary),
            
            SizedBox(height: AppDimensions.sectionGap),

            // Timeline of upcoming obligations
            if (filteredObligations.where((o) => o.daysUntilNext >= 0 && o.daysUntilNext <= 30).isNotEmpty) ...[
              ObligationTimeline(obligations: filteredObligations),
              SizedBox(height: AppDimensions.sectionGap),
            ],

            // Cash Flow Projection Chart
            CashFlowProjectionChart(
              obligations: obligations,
              summary: summary,
            ).animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.1, duration: 500.ms, delay: 400.ms),
            
            SizedBox(height: AppDimensions.sectionGap),

            // All Obligations List
            _buildObligationsList(filteredObligations),
          ],
        ),
      ),
    );
  }

  Widget _buildObligationsList(List<FinancialObligation> obligations) {
    if (obligations.isEmpty) {
      return _buildEmptyState();
    }

    // Group by urgency
    final overdue = obligations.where((o) => o.isOverdue).toList();
    final dueToday = obligations.where((o) => o.isDueToday).toList();
    final dueSoon = obligations.where((o) => o.isDueSoon).toList();
    final upcoming = obligations.where((o) => o.isUpcoming).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          _getSectionTitle(),
          style: AppTypography.h2.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ).animate()
          .fadeIn(duration: 400.ms, delay: 500.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 500.ms),
        
        const SizedBox(height: 16),

        // Overdue section
        if (overdue.isNotEmpty) ...[
          _buildSectionLabel('Overdue', overdue.length, const Color(0xFFDC2626)),
          const SizedBox(height: 12),
          ...overdue.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 600 + (index * 50)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 600 + (index * 50))),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Due today section
        if (dueToday.isNotEmpty) ...[
          _buildSectionLabel('Due Today', dueToday.length, const Color(0xFFEA580C)),
          const SizedBox(height: 12),
          ...dueToday.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 50)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 50))),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Due soon section
        if (dueSoon.isNotEmpty) ...[
          _buildSectionLabel('Due Soon', dueSoon.length, const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          ...dueSoon.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 800 + (index * 50)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 800 + (index * 50))),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Upcoming section
        if (upcoming.isNotEmpty) ...[
          _buildSectionLabel('Upcoming', upcoming.length, const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          ...upcoming.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 900 + (index * 50)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 900 + (index * 50))),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypographyExtended.metricLabel.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
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
              Icons.event_available_outlined,
              size: 64,
              color: AppColorsExtended.budgetPrimary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'No obligations found',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 24,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Add bills and income sources to\ntrack your cash flow',
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
          onTap: () => _showAddObligationSheet(),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Add',
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
      .fadeIn(duration: 300.ms, delay: 1000.ms)
      .slideY(begin: 0.1, duration: 300.ms, delay: 1000.ms, curve: Curves.elasticOut);
  }

  List<FinancialObligation> _filterObligations(List<FinancialObligation> obligations) {
    switch (_activeFilter) {
      case ObligationFilter.all:
        return obligations;
      case ObligationFilter.bills:
        return obligations.where((o) => o.type == ObligationType.bill).toList();
      case ObligationFilter.income:
        return obligations.where((o) => o.type == ObligationType.income).toList();
      case ObligationFilter.overdue:
        return obligations.where((o) => o.isOverdue || o.isDueToday).toList();
      case ObligationFilter.upcoming:
        return obligations.where((o) => o.isUpcoming || o.isDueSoon).toList();
      case ObligationFilter.automated:
        return obligations.where((o) => o.isAutomated == true).toList();
    }
  }

  String _getSectionTitle() {
    switch (_activeFilter) {
      case ObligationFilter.all:
        return 'All Obligations';
      case ObligationFilter.bills:
        return 'Bills';
      case ObligationFilter.income:
        return 'Income Sources';
      case ObligationFilter.overdue:
        return 'Urgent Items';
      case ObligationFilter.upcoming:
        return 'Upcoming';
      case ObligationFilter.automated:
        return 'Automated';
    }
  }

  void _showAddObligationSheet() {
    // Show bottom sheet to choose bill or income
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddObligationTypeSheet(
        onTypeSelected: (type) {
          Navigator.pop(context);
          if (type == ObligationType.bill) {
            // Navigate to add bill
            context.go('/more/bills/add');
          } else {
            // Navigate to add income
            context.go('/more/incomes/add');
          }
        },
      ),
    );
  }

  void _editObligation(FinancialObligation obligation) {
    final isBill = obligation.type == ObligationType.bill;
    final route = isBill 
        ? '/more/bills/${obligation.id}/edit' 
        : '/more/incomes/${obligation.id}/edit';
    context.go(route);
  }

  Future<void> _deleteObligation(FinancialObligation obligation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Obligation'),
        content: Text(
          'Are you sure you want to delete "${obligation.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Delete obligation through provider
      final isBill = obligation.type == ObligationType.bill;
      if (isBill) {
        // await ref.read(billNotifierProvider.notifier).deleteBill(obligation.id);
      } else {
        // await ref.read(incomeNotifierProvider.notifier).deleteIncome(obligation.id);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obligation deleted')),
      );
    }
  }

  void _markComplete(FinancialObligation obligation) {
    final isBill = obligation.type == ObligationType.bill;
    final route = isBill 
        ? '/more/bills/${obligation.id}/pay' 
        : '/more/incomes/${obligation.id}/receive';
    context.go(route);
  }
}

class _AddObligationTypeSheet extends StatelessWidget {
  const _AddObligationTypeSheet({
    required this.onTypeSelected,
  });

  final ValueChanged<ObligationType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Add New Obligation',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the type of obligation to add',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Bill option
          _TypeOption(
            icon: Icons.arrow_upward,
            label: 'Bill',
            description: 'Recurring payment or expense',
            color: const Color(0xFFEF4444),
            onTap: () => onTypeSelected(ObligationType.bill),
          ),
          const SizedBox(height: 12),

          // Income option
          _TypeOption(
            icon: Icons.arrow_downward,
            label: 'Income',
            description: 'Recurring income or revenue',
            color: const Color(0xFF10B981),
            onTap: () => onTypeSelected(ObligationType.income),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 2.7 Cash Flow Projection Chart

```dart
// lib/features/financial_obligations/presentation/widgets/cash_flow_projection_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/budget_bar_chart.dart';
import '../../domain/entities/financial_obligation.dart';

/// Chart showing projected cash flow for next 6 months
class CashFlowProjectionChart extends StatelessWidget {
  const CashFlowProjectionChart({
    super.key,
    required this.obligations,
    required this.summary,
  });

  final List<FinancialObligation> obligations;
  final FinancialObligationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final chartData = _generateProjectionData();

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsExtended.budgetSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.show_chart,
                  size: 20,
                  color: AppColorsExtended.budgetSecondary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  'Cash Flow Projection',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: 16),

          // Chart
          SizedBox(
            height: 200,
            child: _CustomCashFlowChart(data: chartData),
          ),

          const SizedBox(height: 16),

          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorsExtended.pillBgUnselected,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColorsExtended.budgetPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getProjectionSummary(),
                    style: AppTypographyExtended.metricLabel.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(
          color: const Color(0xFF10B981),
          label: 'Income',
        ),
        const SizedBox(width: 12),
        _LegendItem(
          color: const Color(0xFFEF4444),
          label: 'Bills',
        ),
        const SizedBox(width: 12),
        _LegendItem(
          color: AppColorsExtended.budgetPrimary,
          label: 'Net',
        ),
      ],
    );
  }

  List<_MonthProjection> _generateProjectionData() {
    final now = DateTime.now();
    final projections = <_MonthProjection>[];

    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month + i, 1);
      final monthName = DateFormat('MMM').format(month);

      double monthlyIncome = 0;
      double monthlyBills = 0;

      for (final obligation in obligations) {
        // Simplified projection - in real app, calculate based on frequency
        if (obligation.type == ObligationType.income) {
          monthlyIncome += _getMonthlyAmount(obligation);
        } else {
          monthlyBills += _getMonthlyAmount(obligation);
        }
      }

      projections.add(_MonthProjection(
        month: monthName,
        income: monthlyIncome,
        bills: monthlyBills,
        netCashFlow: monthlyIncome - monthlyBills,
      ));
    }

    return projections;
  }

  double _getMonthlyAmount(FinancialObligation obligation) {
    // Convert obligation amount to monthly equivalent
    switch (obligation.frequency) {
      case ObligationFrequency.daily:
        return obligation.amount * 30;
      case ObligationFrequency.weekly:
        return obligation.amount * 4.33;
      case ObligationFrequency.biweekly:
        return obligation.amount * 2.16;
      case ObligationFrequency.monthly:
        return obligation.amount;
      case ObligationFrequency.quarterly:
        return obligation.amount / 3;
      case ObligationFrequency.annually:
        return obligation.amount / 12;
    }
  }

  String _getProjectionSummary() {
    final projections = _generateProjectionData();
    final avgNetFlow = projections.fold(0.0, (sum, p) => sum + p.netCashFlow) / projections.length;
    
    if (avgNetFlow > 0) {
      return 'Based on current obligations, you\'ll save an average of ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(avgNetFlow)}/month over the next 6 months.';
    } else {
      return 'Warning: Your projected expenses exceed income by an average of ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(avgNetFlow.abs())}/month. Consider reviewing your budget.';
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypographyExtended.metricLabel.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MonthProjection {
  const _MonthProjection({
    required this.month,
    required this.income,
    required this.bills,
    required this.netCashFlow,
  });

  final String month;
  final double income;
  final double bills;
  final double netCashFlow;
}

class _CustomCashFlowChart extends StatelessWidget {
  const _CustomCashFlowChart({
    required this.data,
  });

  final List<_MonthProjection> data;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<double>(
      0,
      (max, projection) => [max, projection.income, projection.bills].reduce((a, b) => a > b ? a : b),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth / data.length) - 24;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: data.asMap().entries.map((entry) {
            final index = entry.key;
            final projection = entry.value;
            
            return _ChartBar(
              projection: projection,
              maxValue: maxValue,
              barWidth: barWidth,
              height: constraints.maxHeight - 30,
            ).animate()
              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
              .slideY(begin: 0.3, duration: 400.ms, delay: Duration(milliseconds: 100 * index), curve: Curves.easeOutCubic);
          }).toList(),
        );
      },
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.projection,
    required this.maxValue,
    required this.barWidth,
    required this.height,
  });

  final _MonthProjection projection;
  final double maxValue;
  final double barWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final incomeHeight = (projection.income / maxValue) * height;
    final billsHeight = (projection.bills / maxValue) * height;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Values
        if (projection.income > projection.bills)
          Text(
            '+${NumberFormat.compact().format(projection.netCashFlow)}',
            style: AppTypographyExtended.metricLabel.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
            ),
          )
        else
          Text(
            '-${NumberFormat.compact().format(projection.netCashFlow.abs())}',
            style: AppTypographyExtended.metricLabel.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEF4444),
            ),
          ),
        const SizedBox(height: 4),
        
        // Bars
        SizedBox(
          width: barWidth,
          height: height,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Income bar (background)
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: barWidth / 2 - 2,
                  height: incomeHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.8),
                        const Color(0xFF10B981),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
              
              // Bills bar (foreground)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: barWidth / 2 - 2,
                  height: billsHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFEF4444).withValues(alpha: 0.8),
                        const Color(0xFFEF4444),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Month label
        Text(
          projection.month,
          style: AppTypographyExtended.metricLabel.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
```

---

# PART 4: STATE MANAGEMENT & PROVIDERS

```dart
// lib/features/financial_obligations/presentation/providers/financial_obligations_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/financial_obligation.dart';
import '../../../bills/presentation/providers/bill_providers.dart';
import '../../../recurring_incomes/presentation/providers/recurring_income_providers.dart';

/// Provider that combines bills and recurring income into unified obligations
final financialObligationsProvider = Provider<List<FinancialObligation>>((ref) {
  final billState = ref.watch(billNotifierProvider);
  final incomeState = ref.watch(recurringIncomeNotifierProvider);

  final obligations = <FinancialObligation>[];

  // Add bills
  billState.maybeWhen(
    loaded: (bills, summary) {
      for (final bill in bills) {
        obligations.add(FinancialObligation(
          id: bill.id,
          name: bill.name,
          amount: bill.amount,
          type: ObligationType.bill,
          frequency: _convertBillFrequency(bill.frequency),
          nextDate: bill.dueDate,
          status: bill.isPaid ? ObligationStatus.completed : ObligationStatus.pending,
          accountId: bill.accountId,
          description: bill.description,
          payee: bill.payee,
          isAutomated: bill.isAutoPay,
          lastProcessedDate: bill.lastPaidDate,
          history: bill.paymentHistory.map((p) => ObligationHistory(
            id: p.id,
            date: p.paymentDate,
            amount: p.amount,
            status: ObligationStatus.completed,
            notes: p.notes,
            transactionId: p.transactionId,
          )).toList(),
        ));
      }
    },
    orElse: () {},
  );

  // Add recurring income
  incomeState.maybeWhen(
    loaded: (incomes, summary) {
      for (final income in incomes) {
        if (income.nextExpectedDate != null) {
          obligations.add(FinancialObligation(
            id: income.id,
            name: income.name,
            amount: income.amount,
            type: ObligationType.income,
            frequency: _convertIncomeFrequency(income.frequency),
            nextDate: income.nextExpectedDate!,
            status: ObligationStatus.pending,
            accountId: income.defaultAccountId,
            description: income.description,
            payee: income.payer,
            isAutomated: false, // Income is typically not automated
            lastProcessedDate: income.incomeHistory.isNotEmpty 
                ? income.incomeHistory.last.receivedDate 
                : null,
            history: income.incomeHistory.map((h) => ObligationHistory(
              id: h.id,
              date: h.receivedDate,
              amount: h.amount,
              status: ObligationStatus.completed,
              notes: h.notes,
              transactionId: h.transactionId,
            )).toList(),
          ));
        }
      }
    },
    orElse: () {},
  );

  // Sort by next date
  obligations.sort((a, b) => a.nextDate.compareTo(b.nextDate));

  return obligations;
});

/// Provider for obligations summary statistics
final obligationsSummaryProvider = Provider<FinancialObligationsSummary>((ref) {
  final obligations = ref.watch(financialObligationsProvider);

  final bills = obligations.where((o) => o.type == ObligationType.bill).toList();
  final incomes = obligations.where((o) => o.type == ObligationType.income).toList();

  final upcomingBills = bills.where((b) => 
    b.daysUntilNext >= 0 && b.daysUntilNext <= 30 && b.status != ObligationStatus.completed
  ).toList();

  final upcomingIncome = incomes.where((i) => 
    i.daysUntilNext >= 0 && i.daysUntilNext <= 30 && i.status != ObligationStatus.completed
  ).toList();

  final overdueCount = obligations.where((o) => o.isOverdue).length;
  final dueTodayCount = obligations.where((o) => o.isDueToday).length;
  final dueSoonCount = obligations.where((o) => o.isDueSoon).length;

  // Calculate monthly totals
  double monthlyBills = 0;
  for (final bill in bills) {
    monthlyBills += _getMonthlyAmount(bill);
  }

  double monthlyIncome = 0;
  for (final income in incomes) {
    monthlyIncome += _getMonthlyAmount(income);
  }

  final automatedCount = obligations.where((o) => o.isAutomated == true).length;

  return FinancialObligationsSummary(
    totalBills: bills.length,
    totalIncome: incomes.length,
    netCashFlow: monthlyIncome - monthlyBills,
    upcomingBills: upcomingBills,
    upcomingIncome: upcomingIncome,
    overdueCount: overdueCount,
    dueTodayCount: dueTodayCount,
    dueSoonCount: dueSoonCount,
    monthlyBillTotal: monthlyBills,
    monthlyIncomeTotal: monthlyIncome,
    automatedCount: automatedCount,
  );
});

// Helper functions

ObligationFrequency _convertBillFrequency(BillFrequency frequency) {
  switch (frequency) {
    case BillFrequency.daily:
      return ObligationFrequency.daily;
    case BillFrequency.weekly:
      return ObligationFrequency.weekly;
    case BillFrequency.biweekly:
      return ObligationFrequency.biweekly;
    case BillFrequency.monthly:
      return ObligationFrequency.monthly;
    case BillFrequency.quarterly:
      return ObligationFrequency.quarterly;
    case BillFrequency.annually:
      return ObligationFrequency.annually;
  }
}

ObligationFrequency _convertIncomeFrequency(RecurringIncomeFrequency frequency) {
  switch (frequency) {
    case RecurringIncomeFrequency.daily:
      return ObligationFrequency.daily;
    case RecurringIncomeFrequency.weekly:
      return ObligationFrequency.weekly;
    case RecurringIncomeFrequency.biweekly:
      return ObligationFrequency.biweekly;
    case RecurringIncomeFrequency.monthly:
      return ObligationFrequency.monthly;
    case RecurringIncomeFrequency.quarterly:
      return ObligationFrequency.quarterly;
    case RecurringIncomeFrequency.annually:
      return ObligationFrequency.annually;
  }
}

double _getMonthlyAmount(FinancialObligation obligation) {
  switch (obligation.frequency) {
    case ObligationFrequency.daily:
      return obligation.amount * 30;
    case ObligationFrequency.weekly:
      return obligation.amount * 4.33;
    case ObligationFrequency.biweekly:
      return obligation.amount * 2.16;
    case ObligationFrequency.monthly:
      return obligation.amount;
    case ObligationFrequency.quarterly:
      return obligation.amount / 3;
    case ObligationFrequency.annually:
      return obligation.amount / 12;
  }
}
```

---

# PART 5: ROUTING CONFIGURATION

```dart
// lib/core/routing/app_router.dart - Add unified dashboard route

import 'package:go_router/go_router.dart';
import '../../features/financial_obligations/presentation/screens/unified_obligations_dashboard.dart';

// Add to your existing routes
GoRoute(
  path: '/cash-flow',
  name: 'cash-flow',
  builder: (context, state) => const UnifiedObligationsDashboard(),
),

// Navigation from main tabs
// Update your bottom navigation to include cash flow tab
```

---

# PART 6: IMPLEMENTATION CHECKLIST

## ✅ Phase 1: Foundation (Week 1)
- [ ] Create `financial_obligation.dart` unified data model
- [ ] Set up `financial_obligations_providers.dart` 
- [ ] Create `unified_obligations_header.dart`
- [ ] Implement `cash_flow_circular_indicator.dart`
- [ ] Set up routing and navigation

## ✅ Phase 2: Core Components (Week 2)
- [ ] Implement `smart_alert_banner.dart`
- [ ] Create `cash_flow_stats_row.dart`
- [ ] Build `obligation_timeline.dart`
- [ ] Develop `enhanced_obligation_card.dart`
- [ ] Add swipe actions and interactions

## ✅ Phase 3: Advanced Features (Week 3)
- [ ] Implement `cash_flow_projection_chart.dart`
- [ ] Add filtering and sorting logic
- [ ] Create add/edit obligation flows
- [ ] Implement mark as complete functionality
- [ ] Add automation toggle features

## ✅ Phase 4: Polish & Testing (Week 4)
- [ ] Add all animations using flutter_animate
- [ ] Implement haptic feedback
- [ ] Add empty states and error handling
- [ ] Performance optimization
- [ ] User testing and refinements

---

# SUMMARY

This comprehensive guide provides:

1. **Unified Data Model** - Single `FinancialObligation` entity combining bills and income
2. **Smart Visualization** - Circular progress indicator showing net cash flow
3. **Proactive Alerts** - Smart banner highlighting urgent items and issues
4. **Timeline View** - Visual representation of upcoming 30 days
5. **Advanced Filtering** - Six filter options (All, Bills, Income, Urgent, Upcoming, Automated)
6. **Projection Charts** - 6-month cash flow forecast
7. **Consistent Design** - Matches enhanced Budget/Home/Transaction aesthetics
8. **Simplified UX** - Grouped by urgency, not type; reduced cognitive load
9. **Complete Interactions** - Swipe actions, quick pay/receive, edit/delete
10. **State Management** - Providers combining existing bill and income data

The unified dashboard eliminates confusion between separate screens while maintaining all existing functionality and adding powerful new features for better financial planning.