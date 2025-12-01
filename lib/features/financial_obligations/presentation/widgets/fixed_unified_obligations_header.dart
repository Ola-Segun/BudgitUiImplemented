import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/obligations_theme.dart';

enum ObligationFilter {
  all,
  bills,
  income,
  overdue,
  upcoming,
  automated,
}

class UnifiedObligationsHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
          // Top bar - ENHANCED
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH,
              AppDimensions.spacing3,
              AppDimensions.screenPaddingH,
              AppDimensions.spacing2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash Flow',
                      style: AppTypographyExtended.circularProgressPercentage.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM yyyy').format(selectedDate),
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // Action buttons
                Row(
                  children: [
                    // Notifications badge
                    if (overdueCount > 0 || dueTodayCount > 0)
                      _NotificationBadge(
                        overdueCount: overdueCount,
                        dueTodayCount: dueTodayCount,
                      ),
                    const SizedBox(width: 8),

                    // Calendar button
                    _HeaderIconButton(
                      icon: Icons.calendar_month,
                      onPressed: () => _showDatePicker(context),
                      tooltip: 'Select month',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter chips - ENHANCED
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH,
              0,
              AppDimensions.screenPaddingH,
              AppDimensions.spacing3,
            ),
            child: Row(
              children: ObligationFilter.values.map((filter) {
                final isSelected = filter == activeFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    filter: filter,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onFilterChanged(filter);
                    },
                    overdueCount: filter == ObligationFilter.overdue ? overdueCount : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ObligationsTheme.trackfinzPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({
    required this.overdueCount,
    required this.dueTodayCount,
  });

  final int overdueCount;
  final int dueTodayCount;

  @override
  Widget build(BuildContext context) {
    final totalCount = overdueCount + dueTodayCount;
    final isUrgent = overdueCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUrgent
              ? [
                  ObligationsTheme.statusCritical,
                  ObligationsTheme.statusCritical.withValues(alpha: 0.8),
                ]
              : [
                  ObligationsTheme.statusWarning,
                  ObligationsTheme.statusWarning.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? ObligationsTheme.statusCritical : ObligationsTheme.statusWarning)
                .withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.error_outline : Icons.warning_amber,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$totalCount',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.elasticOut);
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: 20,
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.onTap,
    this.overdueCount,
  });

  final ObligationFilter filter;
  final bool isSelected;
  final VoidCallback onTap;
  final int? overdueCount;

  String get _label {
    switch (filter) {
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

  IconData get _icon {
    switch (filter) {
      case ObligationFilter.all:
        return Icons.apps;
      case ObligationFilter.bills:
        return Icons.arrow_upward;
      case ObligationFilter.income:
        return Icons.arrow_downward;
      case ObligationFilter.overdue:
        return Icons.priority_high;
      case ObligationFilter.upcoming:
        return Icons.schedule;
      case ObligationFilter.automated:
        return Icons.sync;
    }
  }

  Color get _color {
    if (!isSelected) return AppColors.textSecondary;

    switch (filter) {
      case ObligationFilter.bills:
        return ObligationsTheme.statusCritical;
      case ObligationFilter.income:
        return ObligationsTheme.statusNormal;
      case ObligationFilter.overdue:
        return ObligationsTheme.statusCritical;
      default:
        return ObligationsTheme.trackfinzPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _color.withValues(alpha: 0.15),
                      _color.withValues(alpha: 0.08),
                    ],
                  )
                : null,
            color: isSelected ? null : AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: _color.withValues(alpha: 0.3), width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 16, color: _color),
              const SizedBox(width: 6),
              Text(
                _label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: _color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (overdueCount != null && overdueCount! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$overdueCount',
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: _color,
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