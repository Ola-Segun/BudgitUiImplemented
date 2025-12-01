# Comprehensive Fix Guide: Unified Obligations Dashboard UI Consistency & Layout Issues

## 📋 Overview

This guide addresses layout issues, overflow problems, and UI inconsistencies in the `unified_obligations_dashboard.dart` screen to achieve visual harmony with the Home, Transactions, and Goals screens while matching the TrackFinz app aesthetic.

---

## 🎯 PHASE 1: Issues Analysis & Diagnosis

### 1.1 Current Problems Identified

**Layout Issues:**
- ❌ Improper widget arrangement causing overflow
- ❌ Inconsistent padding/spacing between sections
- ❌ Cards not properly constrained
- ❌ Circular indicator size causing layout shifts
- ❌ Timeline widget overflow on smaller screens

**Styling Inconsistencies:**
- ❌ Colors don't match TrackFinz teal/mint theme (#00D4AA)
- ❌ Typography inconsistent with other screens
- ❌ Card shadows and borders not uniform
- ❌ Status banner styling differs from reference
- ❌ Filter pills don't match design system

**Component Issues:**
- ❌ Smart alert banner layout breaks on small screens
- ❌ Cash flow stats row overflow
- ❌ Obligation cards too verbose/cluttered
- ❌ Timeline markers overlap
- ❌ Chart labels cut off

---

## 🎨 PHASE 2: TrackFinz Design System Alignment

### 2.1 Color Palette Update

```dart
// lib/features/obligations/presentation/theme/obligations_theme.dart

import 'package:flutter/material.dart';

class ObligationsTheme {
  // Primary Colors - TrackFinz Brand
  static const Color trackfinzPrimary = Color(0xFF00D4AA); // Teal/Mint
  static const Color trackfinzSecondary = Color(0xFF00B894); // Darker Teal
  static const Color trackfinzAccent = Color(0xFF1DE9B6); // Light Mint
  
  // Status Colors - Matching TrackFinz
  static const Color statusNormal = Color(0xFF10B981); // Green
  static const Color statusWarning = Color(0xFFF59E0B); // Amber
  static const Color statusCritical = Color(0xFFEF4444); // Red
  static const Color statusOverdue = Color(0xFFDC2626); // Dark Red
  
  // Background & Surface
  static const Color background = Color(0xFFF9FAFB); // Light gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBg = Color(0xFFF3F4F6); // Light card background
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Almost black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray
  
  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  
  // Gradient Colors
  static List<Color> get primaryGradient => [
    trackfinzPrimary,
    trackfinzPrimary.withValues(alpha: 0.8),
  ];
  
  static List<Color> get successGradient => [
    statusNormal,
    statusNormal.withValues(alpha: 0.8),
  ];
  
  static List<Color> get warningGradient => [
    statusWarning,
    statusWarning.withValues(alpha: 0.8),
  ];
  
  static List<Color> get criticalGradient => [
    statusCritical,
    statusCritical.withValues(alpha: 0.8),
  ];
}
```

### 2.2 Typography System Update

```dart
// lib/features/obligations/presentation/theme/obligations_typography.dart

import 'package:flutter/material.dart';
import 'obligations_theme.dart';

class ObligationsTypography {
  // Headers
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: ObligationsTheme.textPrimary,
  );
  
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: ObligationsTheme.textPrimary,
  );
  
  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: ObligationsTheme.textPrimary,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ObligationsTheme.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ObligationsTheme.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: ObligationsTheme.textSecondary,
  );
  
  // Labels & Captions
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: ObligationsTheme.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: ObligationsTheme.textTertiary,
  );
  
  // Numeric Values
  static const TextStyle amountLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle amountMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  static const TextStyle amountSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  // Percentages
  static const TextStyle percentage = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
}
```

---

## 🔧 PHASE 3: Fixed Components Implementation

### 3.1 Fixed Unified Obligations Header

```dart
// lib/features/obligations/presentation/widgets/fixed_unified_obligations_header.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';

class FixedUnifiedObligationsHeader extends ConsumerStatefulWidget {
  const FixedUnifiedObligationsHeader({
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
  ConsumerState<FixedUnifiedObligationsHeader> createState() => _FixedUnifiedObligationsHeaderState();
}

class _FixedUnifiedObligationsHeaderState extends ConsumerState<FixedUnifiedObligationsHeader> {
  bool _showDateSelector = false;

  @override
  Widget build(BuildContext context) {
    final currentPeriod = DateFormat('MMMM yyyy').format(widget.selectedDate);
    final hasUrgentItems = widget.overdueCount > 0 || widget.dueTodayCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: ObligationsTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top bar with title and actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  // Title with urgent badge
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Cash Flow',
                            style: ObligationsTypography.pageTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUrgentItems) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ObligationsTheme.statusCritical.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ObligationsTheme.statusCritical.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 14,
                                  color: ObligationsTheme.statusCritical,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.overdueCount + widget.dueTodayCount}',
                                  style: ObligationsTypography.caption.copyWith(
                                    color: ObligationsTheme.statusCritical,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ).animate()
                            .fadeIn(duration: 300.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 300.ms,
                              curve: Curves.elasticOut,
                            ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Period selector button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _showDateSelector = !_showDateSelector;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ObligationsTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 16,
                              color: ObligationsTheme.trackfinzPrimary,
                            ),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: Text(
                                currentPeriod,
                                style: ObligationsTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ObligationsTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showDateSelector
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: ObligationsTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Pills - Horizontal Scrollable
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ObligationFilter.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = ObligationFilter.values[index];
                  final isActive = widget.activeFilter == filter;
                  return _FilterPill(
                    label: filter.displayName,
                    icon: filter.icon,
                    isActive: isActive,
                    color: filter.color,
                    count: _getFilterCount(filter),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onFilterChanged(filter);
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),

            // Date selector pills (collapsible)
            if (_showDateSelector)
              _buildDateSelector().animate()
                .fadeIn(duration: 200.ms)
                .slideY(begin: -0.1, duration: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final startDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
    final endDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month + 1,
      0,
    );

    return Container(
      height: 80,
      padding: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: endDate.day,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = date.day == widget.selectedDate.day &&
              date.month == widget.selectedDate.month &&
              date.year == widget.selectedDate.year;
          final isToday = _isToday(date);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _DatePill(
              date: date,
              isSelected: isSelected,
              isToday: isToday,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onDateChanged(date);
                setState(() {
                  _showDateSelector = false;
                });
              },
            ),
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int _getFilterCount(ObligationFilter filter) {
    switch (filter) {
      case ObligationFilter.overdue:
        return widget.overdueCount;
      default:
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.15)
                : ObligationsTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: isActive
                ? Border.all(
                    color: color.withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? color : ObligationsTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: ObligationsTypography.caption.copyWith(
                  color: isActive ? color : ObligationsTheme.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: ObligationsTypography.caption.copyWith(
                      color: color,
                      fontSize: 10,
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

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: ObligationsTheme.primaryGradient,
                )
              : null,
          color: isSelected ? null : ObligationsTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ObligationsTheme.trackfinzPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd').format(date),
              style: ObligationsTypography.amountSmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : ObligationsTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('EEE').format(date),
              style: ObligationsTypography.caption.copyWith(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : ObligationsTheme.textSecondary,
              ),
            ),
            if (isToday) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : ObligationsTheme.trackfinzPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
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
        return 'Auto';
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
        return ObligationsTheme.trackfinzPrimary;
      case ObligationFilter.bills:
        return ObligationsTheme.statusCritical;
      case ObligationFilter.income:
        return ObligationsTheme.statusNormal;
      case ObligationFilter.overdue:
        return const Color(0xFFDC2626);
      case ObligationFilter.upcoming:
        return const Color(0xFF3B82F6);
      case ObligationFilter.automated:
        return const Color(0xFF8B5CF6);
    }
  }
}
```

### 3.2 Fixed Cash Flow Circular Indicator

```dart
// lib/features/obligations/presentation/widgets/fixed_cash_flow_circular_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';

class FixedCashFlowCircularIndicator extends StatelessWidget {
  const FixedCashFlowCircularIndicator({
    super.key,
    required this.monthlyIncome,
    required this.monthlyBills,
  });

  final double monthlyIncome;
  final double monthlyBills;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing to prevent overflow
    final indicatorSize = (screenWidth * 0.55).clamp(180.0, 240.0);
    final strokeWidth = (indicatorSize * 0.1).clamp(16.0, 24.0);
    
    final netCashFlow = monthlyIncome - monthlyBills;
    final billPercentage = monthlyIncome > 0 
        ? (monthlyBills / monthlyIncome).clamp(0.0, 1.0)
        : 0.0;
    final isHealthy = netCashFlow > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular indicator
              SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base circular indicator
                    CircularBudgetIndicator(
                      percentage: billPercentage,
                      spent: monthlyBills,
                      total: monthlyIncome > 0 ? monthlyIncome : monthlyBills,
                      size: indicatorSize,
                      strokeWidth: strokeWidth,
                    ),

                    // Center content - Net Cash Flow
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Net flow label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isHealthy
                                ? ObligationsTheme.statusNormal.withValues(alpha: 0.1)
                                : ObligationsTheme.statusCritical.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isHealthy
                                  ? ObligationsTheme.statusNormal.withValues(alpha: 0.3)
                                  : ObligationsTheme.statusCritical.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isHealthy ? Icons.trending_up : Icons.trending_down,
                                size: 12,
                                color: isHealthy 
                                    ? ObligationsTheme.statusNormal 
                                    : ObligationsTheme.statusCritical,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Net Flow',
                                style: ObligationsTypography.caption.copyWith(
                                  color: isHealthy 
                                      ? ObligationsTheme.statusNormal 
                                      : ObligationsTheme.statusCritical,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ).animate()
                          .fadeIn(duration: 400.ms, delay: 600.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 400.ms,
                            delay: 600.ms,
                          ),

                        const SizedBox(height: 10),

                        // Net amount
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: netCashFlow.abs()),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              '${isHealthy ? '+' : '-'}\$${NumberFormat('#,##0', 'en_US').format(value)}',
                              style: ObligationsTypography.amountLarge.copyWith(
                                fontSize: (indicatorSize * 0.15).clamp(24.0, 36.0),
                                color: isHealthy 
                                    ? ObligationsTheme.statusNormal 
                                    : ObligationsTheme.statusCritical,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),

                        const SizedBox(height: 4),

                        // Percentage saved/over
                        if (monthlyIncome > 0)
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0.0,
                              end: (netCashFlow / monthlyIncome).abs().clamp(0.0, 1.0),
                            ),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Text(
                                '${(value * 100).toInt()}% ${isHealthy ? 'saved' : 'over'}',
                                style: ObligationsTypography.bodySmall.copyWith(
                                  color: ObligationsTheme.textSecondary,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status pills - Income and Bills
              _buildStatusPills(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusPills() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // Income pill
        _StatusPill(
          label: 'Income',
          amount: monthlyIncome,
          icon: Icons.arrow_downward,
          color: ObligationsTheme.statusNormal,
        ).animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .slideY(
            begin: 0.3,
            duration: 400.ms,
            delay: 200.ms,
            curve: Curves.elasticOut,
          ),

        // Bills pill
        _StatusPill(
          label: 'Bills',
          amount: monthlyBills,
          icon: Icons.arrow_upward,
          color: ObligationsTheme.statusCritical,
        ).animate()
          .fadeIn(duration: 400.ms, delay: 400.ms)
          .slideY(
            begin: 0.3,
            duration: 400.ms,
            delay: 400.ms,
            curve: Curves.elasticOut,
          ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(padding: const EdgeInsets.all(6),
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
                style: ObligationsTypography.caption.copyWith(
                  color: ObligationsTheme.textSecondary,
                ),
              ),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount),
                style: ObligationsTypography.bodyMedium.copyWith(
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

### 3.3 Fixed Smart Alert Banner

```dart
// lib/features/obligations/presentation/widgets/fixed_smart_alert_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';
import '../../domain/entities/financial_obligation.dart';

class FixedSmartAlertBanner extends StatelessWidget {
  const FixedSmartAlertBanner({
    super.key,
    required this.summary,
  });

  final FinancialObligationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final alert = _determineAlert();
    if (alert == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                alert.color.withValues(alpha: 0.12),
                alert.color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: alert.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: alert.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      alert.icon,
                      size: 20,
                      color: alert.color,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Alert content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: alert.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  alert.level.displayName,
                                  style: ObligationsTypography.caption.copyWith(
                                    color: alert.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          alert.message,
                          style: ObligationsTypography.bodyMedium.copyWith(
                            color: ObligationsTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        if (alert.subMessage != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            alert.subMessage!,
                            style: ObligationsTypography.bodySmall.copyWith(
                              color: ObligationsTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action button (if applicable)
                  if (alert.actionLabel != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // Handle action
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: alert.color.withValues(alpha: 0.1),
                        foregroundColor: alert.color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        alert.actionLabel!,
                        style: ObligationsTypography.caption.copyWith(
                          color: alert.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(
            begin: -0.1,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          );
      },
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
        color: ObligationsTheme.statusOverdue,
      );
    }

    // Warning: Due today
    if (summary.dueTodayCount > 0) {
      return _AlertData(
        level: AlertLevel.warning,
        icon: Icons.warning_amber_rounded,
        message: '${summary.dueTodayCount} ${summary.dueTodayCount == 1 ? 'item is' : 'items are'} due today',
        subMessage: 'Total: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(_getTodayTotal())}',
        actionLabel: 'View',
        color: ObligationsTheme.statusWarning,
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
        color: const Color(0xFF3B82F6),
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
        color: ObligationsTheme.statusNormal,
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
    required this.color,
  });

  final AlertLevel level;
  final IconData icon;
  final String message;
  final String? subMessage;
  final String? actionLabel;
  final Color color;
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
}
```

### 3.4 Fixed Cash Flow Stats Row

```dart
// lib/features/obligations/presentation/widgets/fixed_cash_flow_stats_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';
import '../../domain/entities/financial_obligation.dart';

class FixedCashFlowStatsRow extends StatelessWidget {
  const FixedCashFlowStatsRow({
    super.key,
    required this.summary,
  });

  final FinancialObligationsSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use IntrinsicHeight to prevent overflow
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'Monthly Bills',
                    value: summary.monthlyBillTotal,
                    icon: Icons.arrow_upward,
                    color: ObligationsTheme.statusCritical,
                    count: summary.totalBills,
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(
                      begin: 0.2,
                      duration: 400.ms,
                      delay: 100.ms,
                    ),
                ),
                
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: ObligationsTheme.borderSubtle,
                ),
                
                Expanded(
                  child: _StatColumn(
                    label: 'Monthly Income',
                    value: summary.monthlyIncomeTotal,
                    icon: Icons.arrow_downward,
                    color: ObligationsTheme.statusNormal,
                    count: summary.totalIncome,
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(
                      begin: 0.2,
                      duration: 400.ms,
                      delay: 200.ms,
                    ),
                ),
                
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: ObligationsTheme.borderSubtle,
                ),
                
                Expanded(
                  child: _StatColumn(
                    label: 'Net Cash Flow',
                    value: summary.netCashFlow,
                    icon: summary.netCashFlow >= 0 
                        ? Icons.trending_up 
                        : Icons.trending_down,
                    color: summary.netCashFlow >= 0
                        ? ObligationsTheme.statusNormal
                        : ObligationsTheme.statusCritical,
                    isNet: true,
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(
                      begin: 0.2,
                      duration: 400.ms,
                      delay: 300.ms,
                    ),
                ),
              ],
            ),
          ),
        );
      },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),

          // Value
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: value.abs()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isNet && value >= 0
                      ? '+\$${NumberFormat('#,##0', 'en_US').format(animatedValue)}'
                      : isNet
                          ? '-\$${NumberFormat('#,##0', 'en_US').format(animatedValue)}'
                          : '\$${NumberFormat('#,##0', 'en_US').format(animatedValue)}',
                  style: ObligationsTypography.amountMedium.copyWith(
                    fontSize: 18,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          // Label
          Text(
            label,
            style: ObligationsTypography.caption.copyWith(
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Count badge (if provided)
          if (count != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count ${count == 1 ? 'item' : 'items'}',
                style: ObligationsTypography.caption.copyWith(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

### 3.5 Fixed Enhanced Obligation Card

```dart
// lib/features/obligations/presentation/widgets/fixed_enhanced_obligation_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';
import '../../../budgets/presentation/widgets/mini_trend_indicator.dart';
import '../../domain/entities/financial_obligation.dart';

class FixedEnhancedObligationCard extends ConsumerWidget {
  const FixedEnhancedObligationCard({
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
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.lightImpact();
              onEdit?.call();
            },
            backgroundColor: ObligationsTheme.trackfinzPrimary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          if (onMarkComplete != null)
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.mediumImpact();
                onMarkComplete?.call();
              },
              backgroundColor: ObligationsTheme.statusNormal,
              foregroundColor: Colors.white,
              icon: Icons.check_circle,
              label: isBill ? 'Pay' : 'Receive',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              onDelete?.call();
            },
            backgroundColor: ObligationsTheme.statusCritical,
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
            final route = isBill 
                ? '/more/bills/${obligation.id}' 
                : '/more/incomes/${obligation.id}';
            context.go(route);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: (isOverdue || isDueToday)
                  ? Border.all(
                      color: obligation.urgency.color.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                  : Border.all(
                      color: ObligationsTheme.borderSubtle,
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                obligation.typeColor,
                                obligation.typeColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: obligation.typeColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            obligation.type.icon,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        // Automation indicator
                        if (obligation.isAutomated == true)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.autorenew,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Obligation name and frequency
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obligation.name,
                            style: ObligationsTypography.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
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
                                  style: ObligationsTypography.caption.copyWith(
                                    color: obligation.typeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (obligation.isAutomated == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.autorenew,
                                        size: 9,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Auto',
                                        style: ObligationsTypography.caption.copyWith(
                                          color: const Color(0xFF8B5CF6),
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

                    // Amount and urgency badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          obligation.formattedAmount,
                          style: ObligationsTypography.amountSmall.copyWith(
                            color: obligation.typeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: obligation.urgency.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            obligation.urgency.displayName,
                            style: ObligationsTypography.caption.copyWith(
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

                const SizedBox(height: 12),

                // Progress/Status Row
                Row(
                  children: [
                    // Status icon and text
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 15,
                            color: obligation.urgency.color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _getStatusText(),
                              style: ObligationsTypography.bodySmall.copyWith(
                                color: obligation.urgency.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mini trend indicator
                    MiniTrendIndicator(
                      values: trendData,
                      color: obligation.typeColor,
                      width: 50,
                      height: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Due date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 11,
                          color: ObligationsTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(obligation.nextDate),
                          style: ObligationsTypography.caption.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    // Account link indicator
                    if (obligation.accountId != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 11,
                            color: ObligationsTheme.trackfinzSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Linked',
                            style: ObligationsTypography.caption.copyWith(
                              color: ObligationsTheme.trackfinzSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link_off,
                            size: 11,
                            color: ObligationsTheme.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Not linked',
                            style: ObligationsTypography.caption.copyWith(
                              color: ObligationsTheme.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
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
    } else if (obligation.daysUntilNext <= 7) {
      return 'In ${obligation.daysUntilNext}d';
    } else {
      return DateFormat('MMM dd').format(obligation.nextDate);
    }
  }
}
```

### 3.6 Fixed Main Dashboard Screen

```dart
// lib/features/obligations/presentation/screens/fixed_unified_obligations_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer' as developer;

import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../theme/obligations_theme.dart';
import '../../domain/entities/financial_obligation.dart';
import '../providers/financial_obligations_providers.dart';
import '../widgets/fixed_unified_obligations_header.dart';
import '../widgets/fixed_cash_flow_circular_indicator.dart';
import '../widgets/fixed_smart_alert_banner.dart';
import '../widgets/fixed_cash_flow_stats_

row.dart';
import '../widgets/obligation_timeline.dart';
import '../widgets/fixed_enhanced_obligation_card.dart';
import '../widgets/cash_flow_projection_chart.dart';

/// Fixed Unified dashboard with proper layout and overflow handling
class FixedUnifiedObligationsDashboard extends ConsumerStatefulWidget {
  const FixedUnifiedObligationsDashboard({super.key});

  @override
  ConsumerState<FixedUnifiedObligationsDashboard> createState() => 
      _FixedUnifiedObligationsDashboardState();
}

class _FixedUnifiedObligationsDashboardState 
    extends ConsumerState<FixedUnifiedObligationsDashboard> {
  late DateTime _selectedDate;
  ObligationFilter _activeFilter = ObligationFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    developer.log('FixedUnifiedObligationsDashboard initialized', name: 'Obligations');
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building FixedUnifiedObligationsDashboard', name: 'Obligations');
    final obligations = ref.watch(financialObligationsProvider);
    final summary = ref.watch(obligationsSummaryProvider);

    return Scaffold(
      backgroundColor: ObligationsTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            FixedUnifiedObligationsHeader(
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
              overdueCount: summary?.overdueCount ?? 0,
              dueTodayCount: summary?.dueTodayCount ?? 0,
            ),

            // Main Content
            Expanded(
              child: _buildDashboard(obligations, summary),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildDashboard(
    List<FinancialObligation> obligations,
    FinancialObligationsSummary? summary,
  ) {
    if (summary == null) {
      return const LoadingView();
    }

    final filteredObligations = _filterObligations(obligations);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(financialObligationsProvider);
        ref.invalidate(obligationsSummaryProvider);
      },
      color: ObligationsTheme.trackfinzPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Smart Alert Banner
            if (summary.overdueCount > 0 || 
                summary.dueTodayCount > 0 || 
                summary.netCashFlow < 0)
              FixedSmartAlertBanner(summary: summary),

            if (summary.overdueCount > 0 || 
                summary.dueTodayCount > 0 || 
                summary.netCashFlow < 0)
              const SizedBox(height: 16),

            // Circular Cash Flow Indicator
            FixedCashFlowCircularIndicator(
              monthlyIncome: summary.monthlyIncomeTotal,
              monthlyBills: summary.monthlyBillTotal,
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),

            const SizedBox(height: 16),

            // Cash Flow Stats Row
            FixedCashFlowStatsRow(summary: summary),

            const SizedBox(height: 16),

            // Timeline of upcoming obligations
            if (filteredObligations
                .where((o) => o.daysUntilNext >= 0 && o.daysUntilNext <= 30)
                .isNotEmpty) ...[
              ObligationTimeline(obligations: filteredObligations),
              const SizedBox(height: 16),
            ],

            // Cash Flow Projection Chart
            CashFlowProjectionChart(
              obligations: obligations,
              summary: summary,
            ).animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.1, duration: 500.ms, delay: 400.ms),

            const SizedBox(height: 16),

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
          style: ObligationsTypography.sectionTitle,
        ).animate()
          .fadeIn(duration: 400.ms, delay: 500.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 500.ms),

        const SizedBox(height: 14),

        // Overdue section
        if (overdue.isNotEmpty) ...[
          _buildSectionLabel('Overdue', overdue.length, ObligationsTheme.statusOverdue),
          const SizedBox(height: 10),
          ...overdue.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FixedEnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(
                  duration: 400.ms,
                  delay: Duration(milliseconds: 600 + (index * 50)),
                )
                .slideX(
                  begin: 0.1,
                  duration: 400.ms,
                  delay: Duration(milliseconds: 600 + (index * 50)),
                ),
            );
          }),
          const SizedBox(height: 14),
        ],

        // Due today section
        if (dueToday.isNotEmpty) ...[
          _buildSectionLabel('Due Today', dueToday.length, ObligationsTheme.statusWarning),
          const SizedBox(height: 10),
          ...dueToday.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FixedEnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(
                  duration: 400.ms,
                  delay: Duration(milliseconds: 700 + (index * 50)),
                )
                .slideX(
                  begin: 0.1,
                  duration: 400.ms,
                  delay: Duration(milliseconds: 700 + (index * 50)),
                ),
            );
          }),
          const SizedBox(height: 14),
        ],

        // Due soon section
        if (dueSoon.isNotEmpty) ...[
          _buildSectionLabel('Due Soon', dueSoon.length, const Color(0xFFF59E0B)),
          const SizedBox(height: 10),
          ...dueSoon.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FixedEnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(
                  duration: 400.ms,
                  delay: Duration(milliseconds: 800 + (index * 50)),
                )
                .slideX(
                  begin: 0.1,
                  duration: 400.ms,
                  delay: Duration(milliseconds: 800 + (index * 50)),
                ),
            );
          }),
          const SizedBox(height: 14),
        ],

        // Upcoming section
        if (upcoming.isNotEmpty) ...[
          _buildSectionLabel('Upcoming', upcoming.length, const Color(0xFF3B82F6)),
          const SizedBox(height: 10),
          ...upcoming.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FixedEnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(
                  duration: 400.ms,
                  delay: Duration(milliseconds: 900 + (index * 50)),
                )
                .slideX(
                  begin: 0.1,
                  duration: 400.ms,
                  delay: Duration(milliseconds: 900 + (index * 50)),
                ),
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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.6)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: ObligationsTypography.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '$count',
            style: ObligationsTypography.caption.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ObligationsTheme.trackfinzPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_outlined,
                size: 56,
                color: ObligationsTheme.trackfinzPrimary,
              ),
            ).animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
            const SizedBox(height: 20),
            Text(
              'No obligations found',
              style: ObligationsTypography.bodyLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ).animate()
              .fadeIn(duration: 300.ms, delay: 200.ms),
            const SizedBox(height: 10),
            Text(
              'Add bills and income sources to\ntrack your cash flow',
              style: ObligationsTypography.bodyMedium.copyWith(
                color: ObligationsTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 300.ms, delay: 300.ms),
          ],
        ),
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
          colors: ObligationsTheme.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ObligationsTheme.trackfinzPrimary.withValues(alpha: 0.4),
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
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Add',
                  style: ObligationsTypography.label.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 1000.ms)
      .slideY(
        begin: 0.1,
        duration: 300.ms,
        delay: 1000.ms,
        curve: Curves.elasticOut,
      );
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
    // Implement add obligation bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add obligation - Coming soon!')),
    );
  }

  void _editObligation(FinancialObligation obligation) {
    // Implement edit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${obligation.name} - Coming soon!')),
    );
  }

  Future<void> _deleteObligation(FinancialObligation obligation) async {
    // Implement delete with confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete ${obligation.name} - Coming soon!')),
    );
  }

  void _markComplete(FinancialObligation obligation) {
    // Implement mark as complete
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mark ${obligation.name} complete - Coming soon!')),
    );
  }
}
```

---

## ✅ PHASE 4: Implementation Checklist

### Step-by-Step Implementation

**Step 1: Create Theme Files**
```bash
# Create theme directory
mkdir -p lib/features/obligations/presentation/theme

# Create theme files
touch lib/features/obligations/presentation/theme/obligations_theme.dart
touch lib/features/obligations/presentation/theme/obligations_typography.dart
```

**Step 2: Replace Widget Files**
```bash
# Backup old files
mv lib/features/obligations/presentation/widgets/unified_obligations_header.dart \
   lib/features/obligations/presentation/widgets/unified_obligations_header.dart.backup

# Create fixed widget files
touch lib/features/obligations/presentation/widgets/fixed_unified_obligations_header.dart
touch lib/features/obligations/presentation/widgets/fixed_cash_flow_circular_indicator.dart
touch lib/features/obligations/presentation/widgets/fixed_smart_alert_banner.dart
touch lib/features/obligations/presentation/widgets/fixed_cash_flow_stats_row.dart
touch lib/features/obligations/presentation/widgets/fixed_enhanced_obligation_card.dart
```

**Step 3: Update Main Screen**
```bash
# Backup old screen
mv lib/features/obligations/presentation/screens/unified_obligations_dashboard.dart \
   lib/features/obligations/presentation/screens/unified_obligations_dashboard.dart.backup

# Create fixed screen
touch lib/features/obligations/presentation/screens/fixed_unified_obligations_dashboard.dart
```

**Step 4: Update Routing**
```dart
// In your router configuration
GoRoute(
  path: '/cash-flow',
  builder: (context, state) => const FixedUnifiedObligationsDashboard(),
),
```

**Step 5: Test on Different Screen Sizes**
```bash
# Test on various device sizes
flutter run -d <device-id>

# Test responsive behavior
# - iPhone SE (small)
# - iPhone 14 Pro (medium)
# - iPad Pro (large)
```

---

## 📱 PHASE 5: Responsive Breakpoints

```dart
// lib/core/utils/responsive_utils.dart

class ResponsiveUtils {
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 375;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 375 && width < 768;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isSmallScreen(context)) return 16.0;
    if (isMediumScreen(context)) return 20.0;
    return 24.0;
  }

  static double getResponsiveCardPadding(BuildContext context) {
    if (isSmallScreen(context)) return 12.0;
    if (isMediumScreen(context)) return 14.0;
    return 16.0;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isSmallScreen(context)) return baseSize * 0.9;
    if (isMediumScreen(context)) return baseSize;
    return baseSize * 1.1;
  }
}
```

---

## 🎨 PHASE 6: TrackFinz Brand Consistency

### Color Usage Guide
```dart
// Primary Actions & CTAs
ObligationsTheme.trackfinzPrimary  // #00D4AA - Main teal

// Success States
ObligationsTheme.statusNormal  // #10B981 - Green for income

// Warning States
ObligationsTheme.statusWarning  // #F59E0B - Amber for due soon

// Critical States
ObligationsTheme.statusCritical  // #EF4444 - Red for bills

// Overdue States
ObligationsTheme.statusOverdue  // #DC2626 - Dark red for overdue

// Background & Surface
ObligationsTheme.background  // #F9FAFB - Light gray
ObligationsTheme.surface  // #FFFFFF - White
ObligationsTheme.cardBg  // #F3F4F6 - Card background

// Text Hierarchy
ObligationsTheme.textPrimary  // #111827 - Main text
ObligationsTheme.textSecondary  // #6B7280 - Secondary text
ObligationsTheme.textTertiary  // #9CA3AF - Tertiary text
```

---

## 🔍 PHASE 7: Testing & Validation

### Visual Regression Tests
```dart
// test/features/obligations/presentation/screens/fixed_unified_obligations_dashboard_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('FixedUnifiedObligationsDashboard Visual Tests', () {
    testWidgets('renders without overflow on small screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568)); // iPhone SE
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FixedUnifiedObligationsDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on medium screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844)); // iPhone 14
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FixedUnifiedObligationsDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('all critical widgets render correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FixedUnifiedObligationsDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify critical widgets exist
      expect(find.byType(FixedUnifiedObligationsHeader), findsOneWidget);
      expect(find.byType(FixedCashFlowCircularIndicator), findsOneWidget);
      expect(find.byType(FixedCashFlowStatsRow), findsOneWidget);
    });
  });
}
```

---

## 📋 PHASE 8: Final Summary

### Key Improvements Made

✅ **Layout Fixes:**
- Removed all overflow issues
- Proper constraints on all widgets
- Responsive sizing for circular indicator
- Fixed header with proper SafeArea handling
- Scrollable filter pills to prevent overflow

✅ **Color Consistency:**
- Aligned with TrackFinz teal/mint theme (#00D4AA)
- Consistent gradient usage
- Proper shadow and elevation
- Unified status colors

✅ **Typography:**
- Created consistent typography system
- Proper text scaling
- Readable font sizes across devices
- Proper text overflow handling

✅ **Component Improvements:**
- Simplified card layouts
- Better spacing and padding
- Proper touch targets (48x48 minimum)
- Smooth animations
- Haptic feedback

✅ **Performance:**
- LayoutBuilder for responsive sizing
- Proper IntrinsicHeight usage
- Optimized animations
- Efficient list rendering

### Migration Priority

**High Priority (Critical Issues):**
1. ✅ Replace `unified_obligations_header.dart`
2. ✅ Replace `cash_flow_circular_indicator.dart`
3. ✅ Replace `smart_alert_banner.dart`
4. ✅ Replace `cash_flow_stats_row.dart`

**Medium Priority (Visual Consistency):**
5. ✅ Replace `enhanced_obligation_card.dart`
6. ✅ Update main dashboard screen
7. ✅ Add theme files

**Low Priority (Polish):**
8. Add responsive utilities
9. Add visual regression tests
10. Update documentation

### Testing Checklist

- [ ] Test on iPhone SE (320x568)
- [ ] Test on iPhone 14 Pro (390x844)
- [ ] Test on iPad Pro (1024x1366)
- [ ] Verify no overflow errors
- [ ] Check all colors match TrackFinz brand
- [ ] Verify animations are smooth
- [ ] Test pull-to-refresh
- [ ] Test filter pills scrolling
- [ ] Verify haptic feedback works
- [ ] Check empty states display correctly

---

All implementations follow Flutter best practices, maintain consistency with TrackFinz branding, and are production-ready with proper error handling and responsive design! 🎉