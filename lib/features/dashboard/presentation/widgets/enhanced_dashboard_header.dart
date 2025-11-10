import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
                            context.go('/more/notifications');
                          }
                        },
                        tooltip: 'Notifications',
                        badgeCount: 3,
                      ),
                      SizedBox(width: AppDimensions.spacing1),
                      _HeaderIconButton(
                        icon: Icons.tune,
                        onPressed: () {
                          if (context.mounted) {
                            context.go('/more');
                          }
                        },
                        tooltip: 'More options',
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