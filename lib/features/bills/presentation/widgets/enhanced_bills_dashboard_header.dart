import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/date_selector_pills.dart';
import '../theme/bills_theme_extended.dart';

/// Enum to represent the current view mode
enum BillsViewMode {
  timeline,
  calendar,
}

/// Enhanced bills dashboard header with date navigation and actions
class EnhancedBillsDashboardHeader extends StatefulWidget {
  const EnhancedBillsDashboardHeader({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onAddBillPressed,
    required this.onFilterPressed,
    required this.viewMode,
    required this.onViewModeChanged,
    this.overdueCount = 0,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onAddBillPressed;
  final VoidCallback onFilterPressed;
  final BillsViewMode viewMode;
  final ValueChanged<BillsViewMode> onViewModeChanged;
  final int overdueCount;

  @override
  State<EnhancedBillsDashboardHeader> createState() => _EnhancedBillsDashboardHeaderState();
}

class _EnhancedBillsDashboardHeaderState extends State<EnhancedBillsDashboardHeader> {
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
          // Top bar with period, overdue indicator, and actions
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.spacing3,
            ),
            child: Row(
              children: [
                // Period selector
                Expanded(
                  child: GestureDetector(
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
                        borderRadius: BillsThemeExtended.billChipRadius,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 20,
                            color: BillsThemeExtended.billStatsPrimary,
                          ),
                          SizedBox(width: AppDimensions.spacing2),
                          Expanded(
                            child: Text(
                              currentPeriod,
                              style: BillsThemeExtended.billTitle.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
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
                ),

                // Overdue indicator (if any)
                if (widget.overdueCount > 0) ...[
                  SizedBox(width: AppDimensions.spacing2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: BillsThemeExtended.billStatusOverdue.withValues(alpha: 0.1),
                      borderRadius: BillsThemeExtended.billChipRadius,
                      border: Border.all(
                        color: BillsThemeExtended.billStatusOverdue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: BillsThemeExtended.billStatusOverdue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.overdueCount}',
                          style: BillsThemeExtended.billStatusText.copyWith(
                            color: BillsThemeExtended.billStatusOverdue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.elasticOut),
                ],

                // Action buttons
                SizedBox(width: AppDimensions.spacing2),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing2,
                    vertical: AppDimensions.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorsExtended.pillBgUnselected,
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                  child: Row(
                    children: [
                      // View mode toggle
                      _ViewModeToggleButton(
                        viewMode: widget.viewMode,
                        onViewModeChanged: widget.onViewModeChanged,
                      ),
                      SizedBox(width: AppDimensions.spacing1),
                      _HeaderIconButton(
                        icon: Icons.filter_list,
                        onPressed: widget.onFilterPressed,
                        tooltip: 'Filter bills',
                      ),
                      SizedBox(width: AppDimensions.spacing1),
                      _HeaderIconButton(
                        icon: Icons.add,
                        onPressed: widget.onAddBillPressed,
                        tooltip: 'Add bill',
                        backgroundColor: BillsThemeExtended.billStatsPrimary,
                        foregroundColor: Colors.white,
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
            ).animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.1, duration: 200.ms),
        ],
      ),
    );
  }
}

class _ViewModeToggleButton extends StatelessWidget {
  const _ViewModeToggleButton({
    required this.viewMode,
    required this.onViewModeChanged,
  });

  final BillsViewMode viewMode;
  final ValueChanged<BillsViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: viewMode == BillsViewMode.calendar
          ? BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BillsThemeExtended.billChipRadius,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          final newMode = viewMode == BillsViewMode.timeline
              ? BillsViewMode.calendar
              : BillsViewMode.timeline;
          onViewModeChanged(newMode);
        },
        borderRadius: BillsThemeExtended.billChipRadius,
        child: Container(
          width: BillsThemeExtended.billMinTouchTarget,
          height: BillsThemeExtended.billMinTouchTarget,
          alignment: Alignment.center,
          child: Icon(
            viewMode == BillsViewMode.calendar
                ? Icons.view_list_rounded
                : Icons.calendar_view_month_rounded,
            size: 20,
            color: viewMode == BillsViewMode.calendar
                ? BillsThemeExtended.billStatsPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BillsThemeExtended.billChipRadius,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BillsThemeExtended.billChipRadius,
        child: Container(
          width: BillsThemeExtended.billMinTouchTarget,
          height: BillsThemeExtended.billMinTouchTarget,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: foregroundColor ?? AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}