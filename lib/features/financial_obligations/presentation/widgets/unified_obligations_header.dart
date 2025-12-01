import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/date_selector_pills.dart';
import '../../domain/entities/financial_obligation.dart';

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