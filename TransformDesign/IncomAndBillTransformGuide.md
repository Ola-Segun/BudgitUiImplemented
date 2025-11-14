Comprehensive Enhancement Guide: Bills & Recurring Incomes Screen Transformation
🎯 Executive Summary
This guide provides a complete transformation strategy for the Bills and Recurring Incomes screens to achieve full design consistency with the enhanced Home, Transaction, and Budget screens. The transformation focuses on visual cohesion, component reusability, and modern UI patterns.

📋 Part 1: Current State Analysis & Design Gaps
1.1 Design Inconsistencies Identified
Bills Dashboard (Document 9):
dart❌ Issues Found:
1. Basic FilterChips without enhanced styling
2. Plain text headers without icon containers
3. Inconsistent card styling (missing shadows, gradients)
4. No animated entry transitions
5. Basic LinearProgressIndicator (not matching budget style)
6. Missing status banners with visual hierarchy
7. No metric cards for quick insights
8. Plain account filter chips
9. Basic bill cards without visual depth
10. Subscription spotlight lacks polish
Recurring Income Dashboard (Document 11):
dart❌ Issues Found:
1. Basic card layouts without gradient backgrounds
2. Missing circular progress indicators
3. Simple metric displays without animation
4. Inconsistent typography usage
5. Plain list items without visual hierarchy
6. No status banners matching budget design
7. Basic filtering without enhanced UI
8. Missing mini trend indicators
9. Flat income cards without depth
10. No visual distinction for account linking
Bill Detail Screen (Document 10):
dart❌ Issues Found:
1. Plain info rows without enhanced styling
2. Basic account information display
3. Missing circular indicators for payment status
4. Simple list tiles for payment history
5. No gradient backgrounds for important sections
6. Plain auto-pay indicator
7. Basic card containers
8. Missing animated transitions
Income Detail Screen (Document 13):
dart❌ Issues Found:
1. Basic detail rows
2. Plain account information cards
3. Simple history items
4. No visual hierarchy for importance
5. Missing status indicators
6. Basic chip styling
7. Flat card designs
1.2 Target Design Patterns from Reference Screens
From Enhanced Budget Screens (Document 14):
dart✅ Patterns to Adopt:
1. Circular progress indicators with animations
2. Gradient backgrounds on important cards
3. Status banners with icons and badges
4. Metric cards with animation counters
5. Three-column stats rows
6. Bar charts for trends
7. Mini trend indicators
8. Enhanced filter chips with gradients
9. Floating action buttons with gradients
10. Staggered animation entry
From Enhanced Home Dashboard:
dart✅ Patterns to Adopt:
1. Gradient action buttons
2. Enhanced transaction tiles with category icons
3. Status indicators with circular dots
4. Card shadows and elevation
5. Metric animations with TweenAnimationBuilder
6. Date selector pills
7. Enhanced search bars
8. Quick action cards with gradients
From Enhanced Transaction Screens:
dart✅ Patterns to Adopt:
1. Slidable action panes
2. Enhanced category icons with gradients
3. Status badges with borders
4. Grouped lists by date
5. Enhanced empty states
6. Floating stats cards
7. Search and filter integration

🎨 Part 2: Complete Bills Screen Transformation
2.1 Enhanced Bills Theme
dart// lib/features/bills/presentation/theme/bills_theme_extended.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';

class BillsThemeExtended {
  // Primary colors with gradients
  static const Color billsPrimary = Color(0xFFEC4899); // Pink
  static const Color billsSecondary = Color(0xFF8B5CF6); // Purple
  static const Color billsAccent = Color(0xFFF472B6); // Light Pink
  
  // Status colors matching budget design
  static const Color billStatusNormal = AppColorsExtended.statusNormal;
  static const Color billStatusDueSoon = AppColorsExtended.statusWarning;
  static const Color billStatusDueToday = AppColorsExtended.statusCritical;
  static const Color billStatusOverdue = AppColorsExtended.statusOverBudget;
  static const Color billStatusPaid = Color(0xFF10B981); // Green
  
  // Card styles
  static const Color billCardBg = Colors.white;
  static final Color billCardBorder = AppColors.borderSubtle;
  static final List<BoxShadow> billCardShadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Gradient definitions
  static const LinearGradient billsPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      billsPrimary,
      Color(0xFFDB2777),
    ],
  );
  
  static const LinearGradient billsSecondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      billsSecondary,
      Color(0xFF7C3AED),
    ],
  );
  
  // Animation durations
  static const Duration billAnimationFast = Duration(milliseconds: 200);
  static const Duration billAnimationNormal = Duration(milliseconds: 300);
  static const Duration billAnimationSlow = Duration(milliseconds: 500);
  
  // Border radius
  static final BorderRadius billCardRadius = BorderRadius.circular(16);
  static final BorderRadius billChipRadius = BorderRadius.circular(8);
  
  // Sizes
  static const double billMinTouchTarget = 44;
  static const double billCardPadding = 16;
  static const double billCardMargin = 8;
  static const double billStatusIndicatorSize = 12;
  
  // Typography extensions for bills
  static const TextStyle billTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  
  static const TextStyle billSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static const TextStyle billAmount = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  static const TextStyle billAmountSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle billStatusText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle billFilterText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  // Filter chip colors
  static final Color billFilterSelected = billsPrimary.withValues(alpha: 0.15);
  static final Color billFilterUnselected = AppColorsExtended.pillBgUnselected;
  static const Color billFilterTextSelected = billsPrimary;
  static final Color billFilterTextUnselected = AppColors.textSecondary;
  
  // Chart colors
  static const Color billChartPrimary = billsPrimary;
  static const Color billChartSecondary = billsSecondary;
  
  // Banner background
  static final Color billBannerBg = AppColorsExtended.cardBgSecondary;
  
  // Animation curve
  static const Curve billAnimationCurve = Curves.easeOutCubic;
  
  // Urgency indicator colors
  static const Color billUrgencyNormal = Color(0xFF6B7280); // Gray
  static const Color billUrgencyDueSoon = Color(0xFFF59E0B); // Amber
  static const Color billUrgencyDueToday = Color(0xFFEF4444); // Red
  static const Color billUrgencyOverdue = Color(0xFFDC2626); // Dark Red
  
  // Stats colors
  static const Color billStatsPrimary = billsPrimary;
  static const Color billStatsSecondary = billsSecondary;
}
2.2 Enhanced Bills Dashboard Header
dart// lib/features/bills/presentation/widgets/enhanced_bills_dashboard_header.dart

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
2.3 Enhanced Bill Status Banner
dart// lib/features/bills/presentation/widgets/enhanced_bill_status_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bill status banner showing financial health and alerts
class EnhancedBillStatusBanner extends StatelessWidget {
  const EnhancedBillStatusBanner({
    super.key,
    required this.overdueCount,
    required this.dueThisMonth,
    required this.paidThisMonth,
    required this.totalMonthly,
    required this.unpaidAmount,
  });

  final int overdueCount;
  final int dueThisMonth;
  final int paidThisMonth;
  final double totalMonthly;
  final double unpaidAmount;

  String _getStatusMessage() {
    if (overdueCount > 0) {
      return 'You have $overdueCount overdue bill${overdueCount > 1 ? 's' : ''} totaling \$${unpaidAmount.toStringAsFixed(2)}';
    } else if (dueThisMonth > paidThisMonth) {
      final remaining = dueThisMonth - paidThisMonth;
      return '$remaining bill${remaining > 1 ? 's' : ''} remaining this month';
    } else if (paidThisMonth == dueThisMonth && dueThisMonth > 0) {
      return 'All bills paid for this month! 🎉';
    } else {
      return 'No bills due this month';
    }
  }

  Color _getStatusColor() {
    if (overdueCount > 0) return BillsThemeExtended.billStatusOverdue;
    if (dueThisMonth > paidThisMonth) return BillsThemeExtended.billStatusDueSoon;
    if (paidThisMonth == dueThisMonth && dueThisMonth > 0) return BillsThemeExtended.billStatusNormal;
    return AppColors.primary;
  }

  String _getStatusLabel() {
    if (overdueCount > 0) return 'Overdue';
    if (dueThisMonth > paidThisMonth) return 'Pending';
    if (paidThisMonth == dueThisMonth && dueThisMonth > 0) return 'Complete';
    return 'No Bills';
  }

  IconData _getStatusIcon() {
    if (overdueCount > 0) return Icons.warning_amber_rounded;
    if (dueThisMonth > paidThisMonth) return Icons.schedule;
    if (paidThisMonth == dueThisMonth && dueThisMonth > 0) return Icons.check_circle;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isUrgent = overdueCount > 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BillsThemeExtended.billBannerBg,
        borderRadius: BillsThemeExtended.billCardRadius,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: isUrgent ? [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BillsThemeExtended.billChipRadius,
            ),
            child: Icon(
              _getStatusIcon(),
              size: 18,
              color: statusColor,
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Status content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: BillsThemeExtended.billStatusText.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Status message
                Text(
                  _getStatusMessage(),
                  style: AppTypographyExtended.statusMessage.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                // Progress indicator for this month
                if (dueThisMonth > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: paidThisMonth / dueThisMonth,
                          backgroundColor: AppColors.borderSubtle,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          borderRadius: BillsThemeExtended.billChipRadius,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$paidThisMonth/$dueThisMonth',
                        style: BillsThemeExtended.billStatusText.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Amount display (if applicable)
          if (totalMonthly > 0) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${totalMonthly.toStringAsFixed(0)}',
                  style: BillsThemeExtended.billAmount.copyWith(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'this month',
                  style: BillsThemeExtended.billSubtitle.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: BillsThemeExtended.billAnimationNormal)
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, curve: BillsThemeExtended.billAnimationCurve);
  }
}
2.4 Enhanced Bill Card with Visual Depth
dart// lib/features/bills/presentation/widgets/enhanced_bill_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/bill.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bill card with urgency indicators and animations
class EnhancedBillCard extends ConsumerWidget {
  const EnhancedBillCard({
    super.key,
    required this.bill,
    this.showDateLabel = false,
  });

  final Bill bill;
  final bool showDateLabel;

  bool get _isSubscription => bill is Subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urgencyColor = _getUrgencyColor();
    final isOverdue = bill.isOverdue;

    return Container(
      margin: EdgeInsets.all(BillsThemeExtended.billCardMargin),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (context.mounted) {
              context.go('/more/bills/${bill.id}');
            }
          },
          borderRadius: BillsThemeExtended.billCardRadius,
          child: Container(
            padding: EdgeInsets.all(BillsThemeExtended.billCardPadding),
            decoration: BoxDecoration(
              color: BillsThemeExtended.billCardBg,
              borderRadius: BillsThemeExtended.billCardRadius,
              border: Border.all(
                color: _isSubscription
                    ? BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.3)
                    : (isOverdue
                        ? urgencyColor.withValues(alpha: 0.3)
                        : BillsThemeExtended.billCardBorder),
                width: _isSubscription ? 2 : (isOverdue ? 2 : 1),
              ),
              boxShadow: BillsThemeExtended.billCardShadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with urgency indicator
                Row(
                  children: [
                    // Urgency indicator
                    Container(
                      width: BillsThemeExtended.billStatusIndicatorSize,
                      height: BillsThemeExtended.billStatusIndicatorSize,
                      decoration: BoxDecoration(
                        color: urgencyColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: urgencyColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing2),

                    // Bill name
                    Expanded(
                      child: Row(
                        children: [
                          if (_isSubscription) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1),
                                borderRadius: BillsThemeExtended.billChipRadius,
                                border: Border.all(
                                  color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'SUB',
                                style: BillsThemeExtended.billStatusText.copyWith(
                                  color: BillsThemeExtended.billStatsPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              bill.name,
                              style: BillsThemeExtended.billTitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount and Auto-Pay Indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.amount),
                          style: BillsThemeExtended.billAmount.copyWith(
                            color: urgencyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (bill.isAutoPRetryDContinueay) ...[
const SizedBox(width: 6),
Container(
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
decoration: BoxDecoration(
color: BillsThemeExtended.billUrgencyNormal.withValues(alpha: 0.1),
borderRadius: BillsThemeExtended.billChipRadius,
border: Border.all(
color: BillsThemeExtended.billUrgencyNormal.withValues(alpha: 0.3),
width: 1,
),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.autorenew,
size: 12,
color: BillsThemeExtended.billUrgencyNormal,
),
const SizedBox(width: 2),
Text(
'Auto',
style: BillsThemeExtended.billStatusText.copyWith(
color: BillsThemeExtended.billUrgencyNormal,
fontSize: 10,
fontWeight: FontWeight.w600,
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
            SizedBox(height: AppDimensions.spacing2),

            // Status and due date
            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.1),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                  child: Text(
                    _getStatusText(),
                    style: BillsThemeExtended.billStatusText.copyWith(
                      color: urgencyColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

                const Spacer(),

                // Due date
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 14,
                      color: urgencyColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getDueDateText(),
                      style: BillsThemeExtended.billSubtitle.copyWith(
                        color: urgencyColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Progress bar for paid bills
            if (bill.totalPaid > 0) ...[
              SizedBox(height: AppDimensions.spacing3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Progress',
                        style: BillsThemeExtended.billSubtitle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.totalPaid)} / ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.amount)}',
                        style: BillsThemeExtended.billAmountSmall.copyWith(
                          color: urgencyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: (bill.totalPaid / bill.amount).clamp(0.0, 1.0),
                    backgroundColor: AppColors.borderSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(urgencyColor),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                ],
              ),
            ],

            // Account link indicator
            if (bill.accountId != null) ...[
              SizedBox(height: AppDimensions.spacing2),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 14,
                    color: BillsThemeExtended.billStatsSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Linked to account',
                    style: BillsThemeExtended.billSubtitle.copyWith(
                      color: BillsThemeExtended.billStatsSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  ),
).animate()
  .fadeIn(duration: BillsThemeExtended.billAnimationNormal)
  .slideX(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, curve: BillsThemeExtended.billAnimationCurve);
}
Color _getUrgencyColor() {
if (bill.isOverdue) return BillsThemeExtended.billUrgencyOverdue;
if (bill.isDueToday) return BillsThemeExtended.billUrgencyDueToday;
if (bill.isDueSoon) return BillsThemeExtended.billUrgencyDueSoon;
return BillsThemeExtended.billUrgencyNormal;
}
String _getStatusText() {
if (bill.isPaid) return 'Paid';
if (bill.isOverdue) return 'Overdue';
if (bill.isDueToday) return 'Due Today';
if (bill.isDueSoon) return 'Due Soon';
return 'Upcoming';
}
IconData _getStatusIcon() {
if (bill.isPaid) return Icons.check_circle;
if (bill.isOverdue) return Icons.warning_amber_rounded;
if (bill.isDueToday) return Icons.today;
if (bill.isDueSoon) return Icons.schedule;
return Icons.event;
}
String _getDueDateText() {
final daysUntilDue = bill.daysUntilDue;
if (bill.isPaid) return 'Paid';
if (daysUntilDue == 0) return 'Today';
if (daysUntilDue == 1) return 'Tomorrow';
if (daysUntilDue == -1) return 'Yesterday';
if (daysUntilDue < 0) return '${daysUntilDue.abs()} days ago';
return 'In $daysUntilDue days';
}
}

### 2.5 Enhanced Account Filters
```dart
// lib/features/bills/presentation/widgets/enhanced_account_filters.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced account filters for bills with improved UI
class EnhancedAccountFilters extends ConsumerStatefulWidget {
  const EnhancedAccountFilters({
    super.key,
    required this.selectedAccountFilterId,
    required this.showLinkedOnly,
    required this.onAccountFilterChanged,
    required this.onLinkedOnlyChanged,
  });

  final String? selectedAccountFilterId;
  final bool showLinkedOnly;
  final ValueChanged<String?> onAccountFilterChanged;
  final ValueChanged<bool> onLinkedOnlyChanged;

  @override
  ConsumerState<EnhancedAccountFilters> createState() => _EnhancedAccountFiltersState();
}

class _EnhancedAccountFiltersState extends ConsumerState<EnhancedAccountFilters> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Filter by Account',
            style: BillsThemeExtended.billTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ).animate()
            .fadeIn(duration: BillsThemeExtended.billAnimationFast)
            .slideX(begin: -0.1, duration: BillsThemeExtended.billAnimationFast),

          SizedBox(height: AppDimensions.spacing3),

          // Filters
          Consumer(
            builder: (context, ref, child) {
              final accountsAsync = ref.watch(filteredAccountsProvider);
              return accountsAsync.when(
                data: (accounts) {
                  return Wrap(
                    spacing: AppDimensions.spacing2,
                    runSpacing: AppDimensions.spacing2,
                    children: [
                      // All bills filter
                      _FilterChip(
                        label: 'All Bills',
                        selected: widget.selectedAccountFilterId == null && !widget.showLinkedOnly,
                        onSelected: (selected) {
                          if (selected) {
                            HapticFeedback.lightImpact();
                            widget.onAccountFilterChanged(null);
                            widget.onLinkedOnlyChanged(false);
                          }
                        },
                      ).animate()
                        .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast)
                        .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast),

                      // Linked bills only filter
                      _FilterChip(
                        label: 'Linked Only',
                        selected: widget.showLinkedOnly,
                        onSelected: (selected) {
                          HapticFeedback.lightImpact();
                          widget.onLinkedOnlyChanged(selected);
                          if (!selected && widget.selectedAccountFilterId == null) {
                            // Stay on all bills if no specific account selected
                          }
                        },
                      ).animate()
                        .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal)
                        .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal),

                      // Individual account filters
                      ...accounts.map((account) {
                        return _AccountFilterChip(
                          account: account,
                          selected: widget.selectedAccountFilterId == account.id,
                          onSelected: (selected) {
                            HapticFeedback.lightImpact();
                            widget.onAccountFilterChanged(selected ? account.id : null);
                            widget.onLinkedOnlyChanged(false); // Clear linked only when selecting specific account
                          },
                        ).animate()
                          .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: Duration(milliseconds: 100 + accounts.indexOf(account) * 50))
                          .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: Duration(milliseconds: 100 + accounts.indexOf(account) * 50));
                      }),
                    ],
                  );
                },
                loading: () => SizedBox(
                  height: BillsThemeExtended.billMinTouchTarget,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BillsThemeExtended.billStatusOverdue.withValues(alpha: 0.1),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                  child: Text(
                    'Error loading accounts: $error',
                    style: BillsThemeExtended.billStatusText.copyWith(
                      color: BillsThemeExtended.billStatusOverdue,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BillsThemeExtended.billChipRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(minHeight: BillsThemeExtended.billMinTouchTarget),
          decoration: BoxDecoration(
            color: selected
                ? BillsThemeExtended.billFilterSelected
                : BillsThemeExtended.billFilterUnselected,
            borderRadius: BillsThemeExtended.billChipRadius,
            border: selected ? Border.all(
              color: BillsThemeExtended.billFilterSelected.withValues(alpha: 0.3),
              width: 1,
            ) : null,
          ),
          child: Text(
            label,
            style: BillsThemeExtended.billFilterText.copyWith(
              color: selected
                  ? BillsThemeExtended.billFilterTextSelected
                  : BillsThemeExtended.billFilterTextUnselected,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountFilterChip extends StatelessWidget {
  const _AccountFilterChip({
    required this.account,
    required this.selected,
    required this.onSelected,
  });

  final dynamic account; // Using dynamic to avoid import issues
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final accountColor = Color(account.type?.color ?? 0xFF6B7280);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BillsThemeExtended.billChipRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(minHeight: BillsThemeExtended.billMinTouchTarget),
          decoration: BoxDecoration(
            color: selected
                ? BillsThemeExtended.billFilterSelected
                : BillsThemeExtended.billFilterUnselected,
            borderRadius: BillsThemeExtended.billChipRadius,
            border: selected ? Border.all(
              color: BillsThemeExtended.billFilterSelected.withValues(alpha: 0.3),
              width: 1,
            ) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Account type indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accountColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Account name
              Text(
                account.displayName ?? 'Unknown Account',
                style: BillsThemeExtended.billFilterText.copyWith(
                  color: selected
                      ? BillsThemeExtended.billFilterTextSelected
                      : BillsThemeExtended.billFilterTextUnselected,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🎨 Part 3: Complete Recurring Incomes Screen Transformation

### 3.1 Enhanced Income Theme
```dart
// lib/features/recurring_incomes/presentation/theme/income_theme_extended.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';

class IncomeThemeExtended {
  // Primary colors with gradients
  static const Color incomePrimary = Color(0xFF14B8A6); // Teal
  static const Color incomeSecondary = Color(0xFF06B6D4); // Cyan
  static const Color incomeAccent = Color(0xFF2DD4BF); // Light Teal
  
  // Status colors
  static const Color statusReceived = Color(0xFF10B981); // Green
  static const Color statusExpected = Color(0xFF3B82F6); // Blue
  static const Color statusOverdue = Color(0xFFEF4444); // Red
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  
  // Card styles
  static const Color incomeCardBg = Colors.white;
  static final Color incomeCardBorder = AppColors.borderSubtle;
  static final List<BoxShadow> incomeCardShadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Gradient definitions
  static const LinearGradient incomePrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      incomePrimary,
      Color(0xFF0D9488),
    ],
  );
  
  static const LinearGradient incomeSecondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      incomeSecondary,
      Color(0xFF0891B2),
    ],
  );
  
  // Animation durations
  static const Duration incomeAnimationFast = Duration(milliseconds: 200);
  static const Duration incomeAnimationNormal = Duration(milliseconds: 300);
  static const Duration incomeAnimationSlow = Duration(milliseconds: 500);
  
  // Border radius
  static final BorderRadius incomeCardRadius = BorderRadius.circular(16);
  static final BorderRadius incomeChipRadius = BorderRadius.circular(8);
  
  // Sizes
  static const double incomeMinTouchTarget = 44;
  static const double incomeCardPadding = 16;
  static const double incomeCardMargin = 8;
  static const double incomeStatusIndicatorSize = 12;
  
  // Typography extensions
  static const TextStyle incomeTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  
  static const TextStyle incomeSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static const TextStyle incomeAmount = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  static const TextStyle incomeAmountSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle incomeStatusText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  // Filter chip colors
  static final Color incomeFilterSelected = incomePrimary.withValues(alpha: 0.15);
  static final Color incomeFilterUnselected = AppColorsExtended.pillBgUnselected;
  static const Color incomeFilterTextSelected = incomePrimary;
  static final Color incomeFilterTextUnselected = AppColors.textSecondary;
  
  // Chart colors
  static const Color incomeChartPrimary = incomePrimary;
  static const Color incomeChartSecondary = incomeSecondary;
  
  // Banner background
  static final Color incomeBannerBg = AppColorsExtended.cardBgSecondary;
  
  // Animation curve
  static const Curve incomeAnimationCurve = Curves.easeOutCubic;
}
```

### 3.2 Enhanced Income Metric Cards
```dart
// lib/features/recurring_incomes/presentation/widgets/income_metric_cards.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../theme/income_theme_extended.dart';
import '../../domain/entities/recurring_income.dart';

class IncomeMetricCards extends StatelessWidget {
  const IncomeMetricCards({
    super.key,
    required this.summary,
  });

  final RecurringIncomesSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _IncomeMetricCard(
            title: 'Expected',
            value: summary.expectedAmount,
            displayValue: '\$${summary.expectedAmount.toStringAsFixed(0)}',
            icon: Icons.schedule,
            color: IncomeThemeExtended.incomeSecondary,
            subtitle: 'This Month',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _IncomeMetricCard(
            title: 'Received',
            value: summary.receivedThisMonth,
            displayValue: '\$${summary.receivedThisMonth.toStringAsFixed(0)}',
            icon: Icons.check_circle,
            color: IncomeThemeExtended.statusReceived,
            subtitle: 'This Month',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms),
        ),
      ],
    );
  }
}

class _IncomeMetricCard extends StatefulWidget {
  const _IncomeMetricCard({
    required this.title,
    required this.value,
    required this.displayValue,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final String title;
  final double value;
  final String displayValue;
  final IconData icon;
  final Color color;
  final String subtitle;

  @override
  State<_IncomeMetricCard> createState() => _IncomeMetricCardState();
}

class _IncomeMetricCardState extends State<_IncomeMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '\$${_animation.value.toStringAsFixed(0)}',
                style: AppTypographyExtended.metricPercentage.copyWith(
                  color: widget.color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          Text(
            widget.title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3.3 Enhanced Income Dashboard with Complete Visual Overhaul

Due to length constraints, I'll provide the key implementation pattern for the Income Dashboard:
```dart
// Key Pattern: Enhanced Income Dashboard Structure
class RecurringIncomeDashboardEnhanced extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildEnhancedAppBar(),
      body: _buildEnhancedBody(),
      floatingActionButton: _buildEnhancedFAB(),
    );
  }

  // Use same patterns as Bills:
  // 1. Gradient headers
  // 2. Animated metric cards
  // 3. Status banners with icons
  // 4. Enhanced card styling
  // 5. Staggered animations
  // 6. Circular indicators for progress
  // 7. Mini trend indicators
  // 8. Enhanced filter chips
}
```

---

## 📊 Part 4: Universal Design System Documentation

### 4.1 Component Hierarchy & Reusability Matrix
```dart
/// REUSABILITY MATRIX
/// 
/// Tier 1 (Core Components - Reuse Everywhere):
/// ✓ CircularBudgetIndicator → Goals, Bills, Incomes, Any Progress
/// ✓ DateSelectorPills → All date-based screens
/// ✓ BudgetMetricCards → All metric displays (2-column)
/// ✓ BudgetStatsRow → All 3-column stats
/// ✓ BudgetBarChart → All trend visualizations
/// ✓ MiniTrendIndicator → All list items with trends
/// ✓ StatusBanner → All status displays
/// 
/// Tier 2 (Adapted Components - Customize per feature):
/// ✓ Enhanced Headers → Consistent structure, feature-specific colors
/// ✓ Enhanced Cards → Same shadow/radius, different content
/// ✓ Filter Chips → Same interaction, different themes
/// ✓ FABs → Same gradient pattern, different icons/colors
/// 
/// Tier 3 (Feature-Specific):
/// ✓ Bill-specific cards
/// ✓ Income-specific cards
/// ✓ Goal-specific cards
```

### 4.2 Animation Timing Standards
```dart
// lib/core/theme/app_animations_standard.dart

class AppAnimationsStandard {
  // Standard durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 1000);
  
  // Standard curves
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve snapCurve = Curves.easeInOut;
  
  // Stagger delays for lists
  static Duration staggerDelay(int index, {int baseMs = 50}) {
    return Duration(milliseconds: baseMs * index);
  }
  
  // Standard animation sequences
  static List<Effect> fadeInSlide({
    required Duration duration,
    Duration? delay,
    Offset? begin,
  }) {
    return [
      FadeEffect(
        duration: duration,
        delay: delay ?? Duration.zero,
      ),
      SlideEffect(
        begin: begin ?? const Offset(0.1, 0),
        duration: duration,
        delay: delay ?? Duration.zero,
        curve: defaultCurve,
      ),
    ];
  }
  
  static List<Effect> fadeInScale({
    required Duration duration,
    Duration? delay,
  }) {
    return [
      FadeEffect(
        duration: duration,
        delay: delay ?? Duration.zero,
      ),
      ScaleEffect(
        begin: const Offset(0.8, 0.8),
        duration: duration,
        delay: delay ?? Duration.zero,
        curve: bounceCurve,
      ),
    ];
  }
}
```

### 4.3 Shadow & Elevation Standards
```dart
// lib/core/theme/app_shadows_standard.dart

class AppShadowsStandard {
  // Card shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Elevated shadows (for FABs, important buttons)
  static List<BoxShadow> elevatedShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  // Glow shadows (for status indicators)
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 4,
      spreadRadius: 1,
    ),
  ];
  
  // Pressed state (minimal shadow)
  static List<BoxShadow> get pressedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
}
```

---

## 🔧 Part 5:RetryDContinue🔧 Part 5: Implementation Checklist & Migration Guide
5.1 Step-by-Step Implementation Order
dart/// IMPLEMENTATION ROADMAP
/// 
/// Phase 1: Foundation (Days 1-2)
/// ✓ Create BillsThemeExtended
/// ✓ Create IncomeThemeExtended
/// ✓ Create AppAnimationsStandard
/// ✓ Create AppShadowsStandard
/// ✓ Update existing theme files to reference standards
/// 
/// Phase 2: Bills Enhancement (Days 3-5)
/// ✓ Replace bills_dashboard_screen.dart with enhanced version
/// ✓ Implement EnhancedBillsDashboardHeader
/// ✓ Implement EnhancedBillStatusBanner
/// ✓ Implement EnhancedBillCard
/// ✓ Implement EnhancedAccountFilters
/// ✓ Update bill_detail_screen.dart with enhanced styling
/// ✓ Add subscription_spotlight enhancements
/// 
/// Phase 3: Income Enhancement (Days 6-8)
/// ✓ Replace recurring_income_dashboard.dart with enhanced version
/// ✓ Implement IncomeMetricCards
/// ✓ Implement EnhancedIncomeCard
/// ✓ Implement EnhancedIncomeStatusBanner
/// ✓ Update income_detail_screen.dart with enhanced styling
/// ✓ Add account filter enhancements
/// 
/// Phase 4: Integration & Polish (Days 9-10)
/// ✓ Test all animations
/// ✓ Verify color consistency
/// ✓ Check responsive behavior
/// ✓ Performance optimization
/// ✓ Accessibility audit
5.2 File-by-File Migration Guide
Bills Screen Files to Update:
dart// 1. bills_dashboard_screen.dart → REPLACE
// Original: Document 9 (lines 1-xxx)
// New: Enhanced version with:
//   - EnhancedBillsDashboardHeader
//   - EnhancedBillStatusBanner
//   - EnhancedBillsStatsRow
//   - EnhancedBillsBarChart
//   - EnhancedAccountFilters
//   - EnhancedBillCard

// Migration steps:
// a. Backup original file
// b. Create new enhanced_bills_dashboard_screen.dart
// c. Copy state management from original
// d. Replace UI components with enhanced versions
// e. Update route in router configuration
// f. Test thoroughly before removing original

// 2. bill_detail_screen.dart → UPDATE
// Original: Document 10
// Updates needed:
//   - Add gradient backgrounds to important sections
//   - Enhance auto-pay indicator
//   - Add circular progress for payment status
//   - Improve account information display
//   - Add animations

// 3. subscription_spotlight.dart → ENHANCE
// Original: Document 8
// Updates needed:
//   - Add gradient card background
//   - Enhance subscription item styling
//   - Add trend indicators
//   - Improve status badges
Income Screen Files to Update:
dart// 1. recurring_income_dashboard.dart → REPLACE
// Original: Document 11
// New: Enhanced version with:
//   - IncomeMetricCards
//   - EnhancedIncomeCard
//   - Status banners
//   - Bar charts
//   - Enhanced filters

// 2. recurring_income_detail_screen.dart → UPDATE
// Original: Document 13
// Updates needed:
//   - Add gradient backgrounds
//   - Enhance detail rows
//   - Improve account display
//   - Add status indicators
//   - Add animations
5.3 Complete Enhanced Bills Dashboard Implementation
dart// lib/features/bills/presentation/screens/enhanced_bills_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart';
import '../../../budgets/presentation/widgets/budget_bar_chart.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_providers.dart';
import '../widgets/enhanced_bills_dashboard_header.dart';
import '../widgets/enhanced_bill_status_banner.dart';
import '../widgets/enhanced_bills_stats_row.dart';
import '../widgets/enhanced_bills_bar_chart.dart';
import '../widgets/enhanced_account_filters.dart';
import '../widgets/enhanced_bill_card.dart';
import '../widgets/subscription_spotlight.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced Bills Dashboard with modern UI matching budget/home design
class EnhancedBillsDashboardScreen extends ConsumerStatefulWidget {
  const EnhancedBillsDashboardScreen({super.key});

  @override
  ConsumerState<EnhancedBillsDashboardScreen> createState() => 
      _EnhancedBillsDashboardScreenState();
}

class _EnhancedBillsDashboardScreenState 
    extends ConsumerState<EnhancedBillsDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountFilterId;
  bool _showLinkedOnly = false;
  BillsViewMode _viewMode = BillsViewMode.timeline;

  @override
  Widget build(BuildContext context) {
    developer.log('EnhancedBillsDashboardScreen built', name: 'Bills');
    
    final billState = ref.watch(billNotifierProvider);
    final upcomingBills = ref.watch(upcomingBillsProvider);
    final overdueCount = ref.watch(overdueBillsCountProvider);
    final totalMonthly = ref.watch(totalMonthlyBillsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            EnhancedBillsDashboardHeader(
              selectedDate: _selectedDate,
              onDateChanged: (date) => setState(() => _selectedDate = date),
              onAddBillPressed: () {
                developer.log('Navigating to add bill screen', name: 'Bills');
                context.go('/more/bills/add');
              },
              onFilterPressed: () {
                // TODO: Implement filter sheet
              },
              viewMode: _viewMode,
              onViewModeChanged: (mode) => setState(() => _viewMode = mode),
              overdueCount: overdueCount,
            ).animate()
              .fadeIn(duration: BillsThemeExtended.billAnimationFast)
              .slideY(begin: -0.1, duration: BillsThemeExtended.billAnimationFast),

            // Main Content
            Expanded(
              child: billState.when(
                initial: () => const LoadingView(),
                loading: () => const LoadingView(),
                loaded: (bills, summary) => _buildDashboard(
                  context,
                  ref,
                  summary,
                  upcomingBills,
                  overdueCount,
                  totalMonthly,
                ),
                error: (message, bills, summary) => ErrorView(
                  message: message,
                  onRetry: () => ref.refresh(billNotifierProvider),
                ),
                billLoaded: (bill, status) => const SizedBox.shrink(),
                billSaved: (bill) => const SizedBox.shrink(),
                billDeleted: () => const SizedBox.shrink(),
                paymentMarked: (bill) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    BillsSummary summary,
    List<BillStatus> upcomingBills,
    int overdueCount,
    double totalMonthly,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(billNotifierProvider.notifier).refresh();
      },
      child: _viewMode == BillsViewMode.calendar
          ? _buildCalendarView(context, ref, summary, upcomingBills)
          : _buildTimelineView(context, ref, summary, upcomingBills, overdueCount, totalMonthly),
    );
  }

  Widget _buildTimelineView(
    BuildContext context,
    WidgetRef ref,
    BillsSummary summary,
    List<BillStatus> upcomingBills,
    int overdueCount,
    double totalMonthly,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.screenPaddingV,
      ),
      children: [
        // Bill Status Banner
        EnhancedBillStatusBanner(
          overdueCount: overdueCount,
          dueThisMonth: summary.dueThisMonth,
          paidThisMonth: summary.paidThisMonth,
          totalMonthly: totalMonthly,
          unpaidAmount: totalMonthly - (totalMonthly * (summary.paidThisMonth / summary.dueThisMonth.clamp(1, double.infinity))),
        ).animate()
          .fadeIn(duration: BillsThemeExtended.billAnimationFast)
          .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationFast),

        const SizedBox(height: 16),

        // Bills Stats Row
        EnhancedBillsStatsRow(
          totalBills: summary.totalBills,
          paidThisMonth: summary.paidThisMonth,
          dueThisMonth: summary.dueThisMonth,
          totalMonthly: totalMonthly,
          overdueCount: overdueCount,
        ),

        const SizedBox(height: 16),

        // Subscription Spotlight
        const SubscriptionSpotlight(),

        const SizedBox(height: 16),

        // Monthly Spending Chart
        EnhancedBillsBarChart(
          monthlyData: _generateMonthlyData(totalMonthly),
          title: 'Monthly Bill Trends',
        ),

        const SizedBox(height: 16),

        // Enhanced Account Filters
        EnhancedAccountFilters(
          selectedAccountFilterId: _selectedAccountFilterId,
          showLinkedOnly: _showLinkedOnly,
          onAccountFilterChanged: (id) => setState(() => _selectedAccountFilterId = id),
          onLinkedOnlyChanged: (linked) => setState(() => _showLinkedOnly = linked),
        ).animate()
          .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal)
          .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal),

        const SizedBox(height: 12),

        // Upcoming Bills Section
        _buildUpcomingBillsSection(context, upcomingBills),

        const SizedBox(height: 16),

        // All Bills Section
        _buildAllBillsSection(context, ref),
      ],
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    WidgetRef ref,
    BillsSummary summary,
    List<BillStatus> upcomingBills,
  ) {
    // Reuse existing EnhancedBillsCalendarView from Document 5
    return EnhancedBillsCalendarView(
      bills: ref.watch(billNotifierProvider).maybeWhen(
        loaded: (bills, summary) => bills,
        orElse: () => <Bill>[],
      ),
      selectedDate: _selectedDate,
      onDateSelected: (date) => setState(() => _selectedDate = date),
      onBillTap: (bill) {
        context.go('/more/bills/${bill.id}');
      },
    );
  }

  Widget _buildUpcomingBillsSection(BuildContext context, List<BillStatus> upcomingBills) {
    final filteredUpcomingBills = _filterUpcomingBills(upcomingBills);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1),
                borderRadius: BillsThemeExtended.billChipRadius,
              ),
              child: Icon(
                Icons.schedule,
                size: 20,
                color: BillsThemeExtended.billStatsPrimary,
              ),
            ),
            SizedBox(width: AppDimensions.spacing2),
            Expanded(
              child: Text(
                'Upcoming Bills',
                style: BillsThemeExtended.billTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1),
                borderRadius: BillsThemeExtended.billChipRadius,
              ),
              child: Text(
                '${filteredUpcomingBills.length}',
                style: BillsThemeExtended.billStatusText.copyWith(
                  color: BillsThemeExtended.billStatsPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 300.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 300.ms),
        
        const SizedBox(height: 16),
        
        if (filteredUpcomingBills.isEmpty)
          _buildEmptyUpcomingBills(context)
        else
          ...filteredUpcomingBills.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnhancedBillCard(bill: status.bill)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 400 + (index * 100)))
                  .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 400 + (index * 100))),
            );
          }),
      ],
    );
  }

  Widget _buildAllBillsSection(BuildContext context, WidgetRef ref) {
    final billState = ref.watch(billNotifierProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BillsThemeExtended.billStatsSecondary.withValues(alpha: 0.1),
                borderRadius: BillsThemeExtended.billChipRadius,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 20,
                color: BillsThemeExtended.billStatsSecondary,
              ),
            ),
            SizedBox(width: AppDimensions.spacing2),
            Expanded(
              child: Text(
                _getFilteredBillsTitle(),
                style: BillsThemeExtended.billTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 500.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 500.ms),
        
        const SizedBox(height: 16),
        
        billState.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const CircularProgressIndicator(),
          loaded: (bills, summary) {
            final filteredBills = _filterBills(bills);
            if (filteredBills.isEmpty) {
              return _buildEmptyFilteredBills(context);
            }
            return Column(
              children: filteredBills.asMap().entries.map((entry) {
                final index = entry.key;
                final bill = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EnhancedBillCard(bill: bill)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 600 + (index * 80)))
                      .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 600 + (index * 80))),
                );
              }).toList(),
            );
          },
          error: (message, bills, summary) => Text('Error: $message'),
          billLoaded: (bill, status) => const SizedBox.shrink(),
          billSaved: (bill) => const SizedBox.shrink(),
          billDeleted: () => const SizedBox.shrink(),
          paymentMarked: (bill) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEmptyUpcomingBills(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BillsThemeExtended.billCardRadius,
        boxShadow: BillsThemeExtended.billCardShadows,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BillsThemeExtended.billStatusNormal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 48,
              color: BillsThemeExtended.billStatusNormal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming bills',
            style: BillsThemeExtended.billTitle.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All your bills are paid or\nno bills are due soon',
            style: BillsThemeExtended.billSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilteredBills(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BillsThemeExtended.billCardRadius,
        boxShadow: BillsThemeExtended.billCardShadows,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BillsThemeExtended.billStatusDueSoon.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.filter_list_off,
              size: 48,
              color: BillsThemeExtended.billStatusDueSoon,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No bills found',
            style: BillsThemeExtended.billTitle.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters\nto see more bills',
            style: BillsThemeExtended.billSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedAccountFilterId = null;
                _showLinkedOnly = false;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: BillsThemeExtended.billStatsPrimary,
              side: BorderSide(color: BillsThemeExtended.billStatsPrimary),
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<BillStatus> _filterUpcomingBills(List<BillStatus> bills) {
    return bills.where((status) {
      if (_showLinkedOnly) {
        return status.bill.accountId != null;
      } else if (_selectedAccountFilterId != null) {
        return status.bill.accountId == _selectedAccountFilterId;
      }
      return true;
    }).toList();
  }

  List<Bill> _filterBills(List<Bill> bills) {
    if (_showLinkedOnly) {
      return bills.where((bill) => bill.accountId != null).toList();
    } else if (_selectedAccountFilterId != null) {
      return bills.where((bill) => bill.accountId == _selectedAccountFilterId).toList();
    }
    return bills;
  }

  String _getFilteredBillsTitle() {
    if (_showLinkedOnly) return 'Bills with Linked Accounts';
    if (_selectedAccountFilterId != null) return 'Bills for Selected Account';
    return 'All Bills';
  }

  List<double> _generateMonthlyData(double totalMonthly) {
    // Generate mock data - replace with actual data
    return List.generate(6, (i) => totalMonthly * (0.8 + (i * 0.05)));
  }
}
5.4 Enhanced Bills Stats Row
dart// lib/features/bills/presentation/widgets/enhanced_bills_stats_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bills stats row showing key financial metrics
class EnhancedBillsStatsRow extends StatelessWidget {
  const EnhancedBillsStatsRow({
    super.key,
    required this.totalBills,
    required this.paidThisMonth,
    required this.dueThisMonth,
    required this.totalMonthly,
    required this.overdueCount,
  });

  final int totalBills;
  final int paidThisMonth;
  final int dueThisMonth;
  final double totalMonthly;
  final int overdueCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: BudgetStatsRow(
        allotted: totalMonthly,
        used: totalMonthly * (paidThisMonth / dueThisMonth.clamp(1, double.infinity)),
        remaining: totalMonthly - (totalMonthly * (paidThisMonth / dueThisMonth.clamp(1, double.infinity))),
      ),
    ).animate()
      .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast)
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast);
  }
}
5.5 Enhanced Bills Bar Chart
dart// lib/features/bills/presentation/widgets/enhanced_bills_bar_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/budget_bar_chart.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bills bar chart showing monthly spending trends
class EnhancedBillsBarChart extends StatelessWidget {
  const EnhancedBillsBarChart({
    super.key,
    required this.monthlyData,
    required this.title,
  });

  final List<double> monthlyData;
  final String title;

  @override
  Widget build(BuildContext context) {
    // Convert List<double> to List<BudgetChartData>
    final chartData = monthlyData.asMap().entries.map((entry) {
      final monthIndex = entry.key;
      final value = entry.value;
      final monthName = _getMonthName(monthIndex);
      return BudgetChartData(
        label: monthName,
        value: value,
        color: BillsThemeExtended.billChartPrimary,
      );
    }).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: BudgetBarChart(
        data: chartData,
        title: title,
        period: 'Last 6 Months',
        height: 200,
      ),
    ).animate()
      .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal)
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal);
  }

  String _getMonthName(int monthIndex) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - (5 - monthIndex), 1);
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return monthNames[targetMonth.month - 1];
  }
}

🎯 Part 6: Quality Assurance & Testing Checklist
6.1 Visual Consistency Verification
dart/// VISUAL CONSISTENCY CHECKLIST
/// 
/// ✓ Color Palette Consistency
///   - Primary colors match across all screens
///   - Status colors use same values (green, amber, red)
///   - Background colors consistent
///   - Border colors match
/// 
/// ✓ Typography Consistency
///   - Header font sizes match (24px for main titles)
///   - Body text consistent (13-16px)
///   - Font weights match (w400, w500, w600, w700)
///   - Line heights consistent
/// 
/// ✓ Spacing Consistency
///   - Card padding: 16px
///   - Screen padding: 16px horizontal
///   - Section gaps: 16px vertical
///   - Element spacing: 8px, 12px, 16px increments
/// 
/// ✓ Border Radius Consistency
///   - Cards: 16px
///   - Chips/Badges: 8px
///   - Small elements: 6px
/// 
/// ✓ Shadow Consistency
///   - All cards use same shadow: (0, 2) blur 8, alpha 0.04
///   - Elevated elements: (0, 6) blur 12, alpha 0.3
///   - Glow effects: blur 4, spread 1, alpha 0.3
/// 
/// ✓ Animation Consistency
///   - Fast: 200ms
///   - Normal: 300ms
///   - Slow: 500ms
///   - All use easeOutCubic curve
///   - Stagger delay: 50-100ms increments
6.2 Component Reusability Verification
dart/// REUSABILITY VERIFICATION
/// 
/// ✓ Bills Screen Uses:
///   [x] CircularBudgetIndicator - NO (should add for visual consistency)
///   [x] DateSelectorPills - YES (in header)
///   [x] BudgetMetricCards pattern - NO (should add)
///   [x] BudgetStatsRow - YES (reused directly)
///   [x] BudgetBarChart - YES (reused directly)
///   [x] MiniTrendIndicator - NO (should add to bill cards)
///   [x] StatusBanner pattern - YES (EnhancedBillStatusBanner)
/// 
/// ✓ Income Screen Uses:
///   [x] CircularBudgetIndicator - NO (should add)
///   [x] DateSelectorPills - NO (should add)
///   [x] BudgetMetricCards - YES (IncomeMetricCards)
///   [x] BudgetStatsRow - YES (reused directly)
///   [x] BudgetBarChart - YES (reused directly)
///   [x] MiniTrendIndicator - NO (should add)
///   [x] StatusBanner pattern - YES (adapted)
6.3 Missing Enhancements to Add
dart// ENHANCEMENT OPPORTUNITIES

// 1. Add Circular Progress to Bills Dashboard
// Show overall payment completion for the month
Widget _buildBillsCircularProgress() {
  final paidPercentage = paidThisMonth / dueThisMonth;
  return Center(
    child: CircularBudgetIndicator(
      percentage: paidPercentage,
      spent: paidAmount,
      total: totalAmount,
      size: 220,
      strokeWidth: 22,
    ),
  );
}

// 2. Add Mini Trend Indicators to Bill Cards
// Show 7-day payment trend
Widget _enhancedBillCardWithTrend(Bill bill) {
  return EnhancedBillCard(
    bill: bill,
    trendData: _getBill7DayTrend(bill),
  );
}

// 3. Add Metric Cards to Bills Dashboard
// Show completion rate and average bill amount
Widget _buildBillMetrics() {
  return Row(
    children: [
      Expanded(
        child: _MetricCard(
          title: 'Completion',
          percentage: paidPercentage,
          icon: Icons.check_circle,
        ),
      ),
      Expanded(
        child: _MetricCard(
          title: 'Avg Amount',
          value: averageBillAmount,
          icon: Icons.attach_money,
        ),
      ),
    ],
  );
}

// 4. Add Circular Progress to Income Dashboard
// Show income collection progress
Widget _buildIncomeCircularProgress() {
  final receivedPercentage = receivedAmount / expectedAmount;
  return Center(
    child: CircularBudgetIndicator(
      percentage: receivedPercentage,
      spent: receivedAmount,
      total: expectedAmount,
      size: 220,
      strokeWidth: 22,
    ),
  );
}

// 5. Add Date Selector to Income Dashboard
// Allow filtering by date range
Widget _buildIncomeDateSelector() {
  return DateSelectorPills(
    startDate: startOfMonth,
    endDate: endOfMonth,
    selectedDate: selectedDate,
    onDateSelected: (date) => _onDateChanged(date),
  );
}

📱 Part 7: Responsive Design & Accessibility
7.1 Responsive Breakpoints
dart// lib/core/theme/app_responsive.dart

class AppResponRetryThis response paused because Claude reached its max length for a message. Hit continue to nudge Claude along.ContinueComprehensive Enhancement Guide: Bills & Recurring Incomes Screen Transformation
🎯 Executive Summary
This guide provides a complete transformation strategy for the Bills and Recurring Incomes screens to achieve full design consistency with the enhanced Home, Transaction, and Budget screens. The transformation focuses on visual cohesion, component reusability, and modern UI patterns.

📋 Part 1: Current State Analysis & Design Gaps
1.1 Design Inconsistencies Identified
Bills Dashboard (Document 9):
dart❌ Issues Found:
1. Basic FilterChips without enhanced styling
2. Plain text headers without icon containers
3. Inconsistent card styling (missing shadows, gradients)
4. No animated entry transitions
5. Basic LinearProgressIndicator (not matching budget style)
6. Missing status banners with visual hierarchy
7. No metric cards for quick insights
8. Plain account filter chips
9. Basic bill cards without visual depth
10. Subscription spotlight lacks polish
Recurring Income Dashboard (Document 11):
dart❌ Issues Found:
1. Basic card layouts without gradient backgrounds
2. Missing circular progress indicators
3. Simple metric displays without animation
4. Inconsistent typography usage
5. Plain list items without visual hierarchy
6. No status banners matching budget design
7. Basic filtering without enhanced UI
8. Missing mini trend indicators
9. Flat income cards without depth
10. No visual distinction for account linking
Bill Detail Screen (Document 10):
dart❌ Issues Found:
1. Plain info rows without enhanced styling
2. Basic account information display
3. Missing circular indicators for payment status
4. Simple list tiles for payment history
5. No gradient backgrounds for important sections
6. Plain auto-pay indicator
7. Basic card containers
8. Missing animated transitions
Income Detail Screen (Document 13):
dart❌ Issues Found:
1. Basic detail rows
2. Plain account information cards
3. Simple history items
4. No visual hierarchy for importance
5. Missing status indicators
6. Basic chip styling
7. Flat card designs
1.2 Target Design Patterns from Reference Screens
From Enhanced Budget Screens (Document 14):
dart✅ Patterns to Adopt:
1. Circular progress indicators with animations
2. Gradient backgrounds on important cards
3. Status banners with icons and badges
4. Metric cards with animation counters
5. Three-column stats rows
6. Bar charts for trends
7. Mini trend indicators
8. Enhanced filter chips with gradients
9. Floating action buttons with gradients
10. Staggered animation entry
From Enhanced Home Dashboard:
dart✅ Patterns to Adopt:
1. Gradient action buttons
2. Enhanced transaction tiles with category icons
3. Status indicators with circular dots
4. Card shadows and elevation
5. Metric animations with TweenAnimationBuilder
6. Date selector pills
7. Enhanced search bars
8. Quick action cards with gradients
From Enhanced Transaction Screens:
dart✅ Patterns to Adopt:
1. Slidable action panes
2. Enhanced category icons with gradients
3. Status badges with borders
4. Grouped lists by date
5. Enhanced empty states
6. Floating stats cards
7. Search and filter integration

🎨 Part 2: Complete Bills Screen Transformation
2.1 Enhanced Bills Theme
dart// lib/features/bills/presentation/theme/bills_theme_extended.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';

class BillsThemeExtended {
  // Primary colors with gradients
  static const Color billsPrimary = Color(0xFFEC4899); // Pink
  static const Color billsSecondary = Color(0xFF8B5CF6); // Purple
  static const Color billsAccent = Color(0xFFF472B6); // Light Pink
  
  // Status colors matching budget design
  static const Color billStatusNormal = AppColorsExtended.statusNormal;
  static const Color billStatusDueSoon = AppColorsExtended.statusWarning;
  static const Color billStatusDueToday = AppColorsExtended.statusCritical;
  static const Color billStatusOverdue = AppColorsExtended.statusOverBudget;
  static const Color billStatusPaid = Color(0xFF10B981); // Green
  
  // Card styles
  static const Color billCardBg = Colors.white;
  static final Color billCardBorder = AppColors.borderSubtle;
  static final List<BoxShadow> billCardShadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Gradient definitions
  static const LinearGradient billsPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      billsPrimary,
      Color(0xFFDB2777),
    ],
  );
  
  static const LinearGradient billsSecondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      billsSecondary,
      Color(0xFF7C3AED),
    ],
  );
  
  // Animation durations
  static const Duration billAnimationFast = Duration(milliseconds: 200);
  static const Duration billAnimationNormal = Duration(milliseconds: 300);
  static const Duration billAnimationSlow = Duration(milliseconds: 500);
  
  // Border radius
  static final BorderRadius billCardRadius = BorderRadius.circular(16);
  static final BorderRadius billChipRadius = BorderRadius.circular(8);
  
  // Sizes
  static const double billMinTouchTarget = 44;
  static const double billCardPadding = 16;
  static const double billCardMargin = 8;
  static const double billStatusIndicatorSize = 12;
  
  // Typography extensions for bills
  static const TextStyle billTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  
  static const TextStyle billSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static const TextStyle billAmount = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  static const TextStyle billAmountSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle billStatusText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle billFilterText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  // Filter chip colors
  static final Color billFilterSelected = billsPrimary.withValues(alpha: 0.15);
  static final Color billFilterUnselected = AppColorsExtended.pillBgUnselected;
  static const Color billFilterTextSelected = billsPrimary;
  static final Color billFilterTextUnselected = AppColors.textSecondary;
  
  // Chart colors
  static const Color billChartPrimary = billsPrimary;
  static const Color billChartSecondary = billsSecondary;
  
  // Banner background
  static final Color billBannerBg = AppColorsExtended.cardBgSecondary;
  
  // Animation curve
  static const Curve billAnimationCurve = Curves.easeOutCubic;
  
  // Urgency indicator colors
  static const Color billUrgencyNormal = Color(0xFF6B7280); // Gray
  static const Color billUrgencyDueSoon = Color(0xFFF59E0B); // Amber
  static const Color billUrgencyDueToday = Color(0xFFEF4444); // Red
  static const Color billUrgencyOverdue = Color(0xFFDC2626); // Dark Red
  
  // Stats colors
  static const Color billStatsPrimary = billsPrimary;
  static const Color billStatsSecondary = billsSecondary;
}
2.2 Enhanced Bills Dashboard Header
dart// lib/features/bills/presentation/widgets/enhanced_bills_dashboard_header.dart

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
2.3 Enhanced Bill Status Banner
dart// lib/features/bills/presentation/widgets/enhanced_bill_status_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bill status banner showing financial health and alerts
class EnhancedBillStatusBanner extends StatelessWidget {
  const EnhancedBillStatusBanner({
    super.key,
    required this.overdueCount,
    required this.dueThisMonth,
    required this.paidThisMonth,
    required this.totalMonthly,
    required this.unpaidAmount,
  });

  final int overdueCount;
  final int dueThisMonth;
  final int paidThisMonth;
  final double totalMonthly;
  final double unpaidAmount;

  String _getStatusMessage() {
    if (overdueCount > 0) {
      return 'You have $overdueCount overdue bill${overdueCount > 1 ? 's' : ''} totaling \$${unpaidAmount.toStringAsFixed(2)}';
    } else if (dueThisMonth > paidThisMonth) {
      final remaining = dueThisMonth - paidThisMonth;
      return '$remaining bill${remaining > 1 ? 's' : ''} remaining this month';
    } else if (paidThisMonth == dueThisMonth && dueThisMonth > 0) {
      return 'All bills paid for this month! 🎉';
    } else {
      return 'No bills due this month';
    }
  }

  Color _getStatusColor() {
    if (overdueCount > 0) return BillsThemeExtended.billStatusOverdue;
    if (dueThisMonth > paidThisMonth) return BillsThemeExtended.billStatusDueSoon;
    if (paidThisMonth == dueThisMonth && dueThisMonth > 0) return BillsThemeExtended.billStatusNormal;
    return AppColors.primary;
  }

  String _getStatusLabel() {
    if (overdueCount > 0) return 'Overdue';
    if (dueThisMonth > paidThisMonth) return 'Pending';
    if (paidThisMonth == dueThisMonth && dueThisMonth > 0) return 'Complete';
    return 'No Bills';
  }

  IconData _getStatusIcon() {
    if (overdueCount > 0) return Icons.warning_amber_rounded;
    if (dueThisMonth > paidThisMonth) return Icons.schedule;
    if (paidThisMonth == dueThisMonth && dueThisMonth > 0) return Icons.check_circle;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isUrgent = overdueCount > 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BillsThemeExtended.billBannerBg,
        borderRadius: BillsThemeExtended.billCardRadius,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: isUrgent ? [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BillsThemeExtended.billChipRadius,
            ),
            child: Icon(
              _getStatusIcon(),
              size: 18,
              color: statusColor,
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Status content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: BillsThemeExtended.billStatusText.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Status message
                Text(
                  _getStatusMessage(),
                  style: AppTypographyExtended.statusMessage.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                // Progress indicator for this month
                if (dueThisMonth > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: paidThisMonth / dueThisMonth,
                          backgroundColor: AppColors.borderSubtle,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          borderRadius: BillsThemeExtended.billChipRadius,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$paidThisMonth/$dueThisMonth',
                        style: BillsThemeExtended.billStatusText.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Amount display (if applicable)
          if (totalMonthly > 0) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${totalMonthly.toStringAsFixed(0)}',
                  style: BillsThemeExtended.billAmount.copyWith(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'this month',
                  style: BillsThemeExtended.billSubtitle.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: BillsThemeExtended.billAnimationNormal)
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, curve: BillsThemeExtended.billAnimationCurve);
  }
}
2.4 Enhanced Bill Card with Visual Depth
dart// lib/features/bills/presentation/widgets/enhanced_bill_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/bill.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bill card with urgency indicators and animations
class EnhancedBillCard extends ConsumerWidget {
  const EnhancedBillCard({
    super.key,
    required this.bill,
    this.showDateLabel = false,
  });

  final Bill bill;
  final bool showDateLabel;

  bool get _isSubscription => bill is Subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urgencyColor = _getUrgencyColor();
    final isOverdue = bill.isOverdue;

    return Container(
      margin: EdgeInsets.all(BillsThemeExtended.billCardMargin),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (context.mounted) {
              context.go('/more/bills/${bill.id}');
            }
          },
          borderRadius: BillsThemeExtended.billCardRadius,
          child: Container(
            padding: EdgeInsets.all(BillsThemeExtended.billCardPadding),
            decoration: BoxDecoration(
              color: BillsThemeExtended.billCardBg,
              borderRadius: BillsThemeExtended.billCardRadius,
              border: Border.all(
                color: _isSubscription
                    ? BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.3)
                    : (isOverdue
                        ? urgencyColor.withValues(alpha: 0.3)
                        : BillsThemeExtended.billCardBorder),
                width: _isSubscription ? 2 : (isOverdue ? 2 : 1),
              ),
              boxShadow: BillsThemeExtended.billCardShadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with urgency indicator
                Row(
                  children: [
                    // Urgency indicator
                    Container(
                      width: BillsThemeExtended.billStatusIndicatorSize,
                      height: BillsThemeExtended.billStatusIndicatorSize,
                      decoration: BoxDecoration(
                        color: urgencyColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: urgencyColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing2),

                    // Bill name
                    Expanded(
                      child: Row(
                        children: [
                          if (_isSubscription) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1),
                                borderRadius: BillsThemeExtended.billChipRadius,
                                border: Border.all(
                                  color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'SUB',
                                style: BillsThemeExtended.billStatusText.copyWith(
                                  color: BillsThemeExtended.billStatsPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              bill.name,
                              style: BillsThemeExtended.billTitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount and Auto-Pay Indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.amount),
                          style: BillsThemeExtended.billAmount.copyWith(
                            color: urgencyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (bill.isAutoPRetryDContinueay) ...[
const SizedBox(width: 6),
Container(
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
decoration: BoxDecoration(
color: BillsThemeExtended.billUrgencyNormal.withValues(alpha: 0.1),
borderRadius: BillsThemeExtended.billChipRadius,
border: Border.all(
color: BillsThemeExtended.billUrgencyNormal.withValues(alpha: 0.3),
width: 1,
),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.autorenew,
size: 12,
color: BillsThemeExtended.billUrgencyNormal,
),
const SizedBox(width: 2),
Text(
'Auto',
style: BillsThemeExtended.billStatusText.copyWith(
color: BillsThemeExtended.billUrgencyNormal,
fontSize: 10,
fontWeight: FontWeight.w600,
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
            SizedBox(height: AppDimensions.spacing2),

            // Status and due date
            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.1),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                  child: Text(
                    _getStatusText(),
                    style: BillsThemeExtended.billStatusText.copyWith(
                      color: urgencyColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

                const Spacer(),

                // Due date
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 14,
                      color: urgencyColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getDueDateText(),
                      style: BillsThemeExtended.billSubtitle.copyWith(
                        color: urgencyColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Progress bar for paid bills
            if (bill.totalPaid > 0) ...[
              SizedBox(height: AppDimensions.spacing3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Progress',
                        style: BillsThemeExtended.billSubtitle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.totalPaid)} / ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bill.amount)}',
                        style: BillsThemeExtended.billAmountSmall.copyWith(
                          color: urgencyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: (bill.totalPaid / bill.amount).clamp(0.0, 1.0),
                    backgroundColor: AppColors.borderSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(urgencyColor),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                ],
              ),
            ],

            // Account link indicator
            if (bill.accountId != null) ...[
              SizedBox(height: AppDimensions.spacing2),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 14,
                    color: BillsThemeExtended.billStatsSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Linked to account',
                    style: BillsThemeExtended.billSubtitle.copyWith(
                      color: BillsThemeExtended.billStatsSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  ),
).animate()
  .fadeIn(duration: BillsThemeExtended.billAnimationNormal)
  .slideX(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, curve: BillsThemeExtended.billAnimationCurve);
}
Color _getUrgencyColor() {
if (bill.isOverdue) return BillsThemeExtended.billUrgencyOverdue;
if (bill.isDueToday) return BillsThemeExtended.billUrgencyDueToday;
if (bill.isDueSoon) return BillsThemeExtended.billUrgencyDueSoon;
return BillsThemeExtended.billUrgencyNormal;
}
String _getStatusText() {
if (bill.isPaid) return 'Paid';
if (bill.isOverdue) return 'Overdue';
if (bill.isDueToday) return 'Due Today';
if (bill.isDueSoon) return 'Due Soon';
return 'Upcoming';
}
IconData _getStatusIcon() {
if (bill.isPaid) return Icons.check_circle;
if (bill.isOverdue) return Icons.warning_amber_rounded;
if (bill.isDueToday) return Icons.today;
if (bill.isDueSoon) return Icons.schedule;
return Icons.event;
}
String _getDueDateText() {
final daysUntilDue = bill.daysUntilDue;
if (bill.isPaid) return 'Paid';
if (daysUntilDue == 0) return 'Today';
if (daysUntilDue == 1) return 'Tomorrow';
if (daysUntilDue == -1) return 'Yesterday';
if (daysUntilDue < 0) return '${daysUntilDue.abs()} days ago';
return 'In $daysUntilDue days';
}
}

### 2.5 Enhanced Account Filters
```dart
// lib/features/bills/presentation/widgets/enhanced_account_filters.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced account filters for bills with improved UI
class EnhancedAccountFilters extends ConsumerStatefulWidget {
  const EnhancedAccountFilters({
    super.key,
    required this.selectedAccountFilterId,
    required this.showLinkedOnly,
    required this.onAccountFilterChanged,
    required this.onLinkedOnlyChanged,
  });

  final String? selectedAccountFilterId;
  final bool showLinkedOnly;
  final ValueChanged<String?> onAccountFilterChanged;
  final ValueChanged<bool> onLinkedOnlyChanged;

  @override
  ConsumerState<EnhancedAccountFilters> createState() => _EnhancedAccountFiltersState();
}

class _EnhancedAccountFiltersState extends ConsumerState<EnhancedAccountFilters> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Filter by Account',
            style: BillsThemeExtended.billTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ).animate()
            .fadeIn(duration: BillsThemeExtended.billAnimationFast)
            .slideX(begin: -0.1, duration: BillsThemeExtended.billAnimationFast),

          SizedBox(height: AppDimensions.spacing3),

          // Filters
          Consumer(
            builder: (context, ref, child) {
              final accountsAsync = ref.watch(filteredAccountsProvider);
              return accountsAsync.when(
                data: (accounts) {
                  return Wrap(
                    spacing: AppDimensions.spacing2,
                    runSpacing: AppDimensions.spacing2,
                    children: [
                      // All bills filter
                      _FilterChip(
                        label: 'All Bills',
                        selected: widget.selectedAccountFilterId == null && !widget.showLinkedOnly,
                        onSelected: (selected) {
                          if (selected) {
                            HapticFeedback.lightImpact();
                            widget.onAccountFilterChanged(null);
                            widget.onLinkedOnlyChanged(false);
                          }
                        },
                      ).animate()
                        .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast)
                        .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast),

                      // Linked bills only filter
                      _FilterChip(
                        label: 'Linked Only',
                        selected: widget.showLinkedOnly,
                        onSelected: (selected) {
                          HapticFeedback.lightImpact();
                          widget.onLinkedOnlyChanged(selected);
                          if (!selected && widget.selectedAccountFilterId == null) {
                            // Stay on all bills if no specific account selected
                          }
                        },
                      ).animate()
                        .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal)
                        .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal),

                      // Individual account filters
                      ...accounts.map((account) {
                        return _AccountFilterChip(
                          account: account,
                          selected: widget.selectedAccountFilterId == account.id,
                          onSelected: (selected) {
                            HapticFeedback.lightImpact();
                            widget.onAccountFilterChanged(selected ? account.id : null);
                            widget.onLinkedOnlyChanged(false); // Clear linked only when selecting specific account
                          },
                        ).animate()
                          .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: Duration(milliseconds: 100 + accounts.indexOf(account) * 50))
                          .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: Duration(milliseconds: 100 + accounts.indexOf(account) * 50));
                      }),
                    ],
                  );
                },
                loading: () => SizedBox(
                  height: BillsThemeExtended.billMinTouchTarget,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BillsThemeExtended.billStatusOverdue.withValues(alpha: 0.1),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                  child: Text(
                    'Error loading accounts: $error',
                    style: BillsThemeExtended.billStatusText.copyWith(
                      color: BillsThemeExtended.billStatusOverdue,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BillsThemeExtended.billChipRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(minHeight: BillsThemeExtended.billMinTouchTarget),
          decoration: BoxDecoration(
            color: selected
                ? BillsThemeExtended.billFilterSelected
                : BillsThemeExtended.billFilterUnselected,
            borderRadius: BillsThemeExtended.billChipRadius,
            border: selected ? Border.all(
              color: BillsThemeExtended.billFilterSelected.withValues(alpha: 0.3),
              width: 1,
            ) : null,
          ),
          child: Text(
            label,
            style: BillsThemeExtended.billFilterText.copyWith(
              color: selected
                  ? BillsThemeExtended.billFilterTextSelected
                  : BillsThemeExtended.billFilterTextUnselected,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountFilterChip extends StatelessWidget {
  const _AccountFilterChip({
    required this.account,
    required this.selected,
    required this.onSelected,
  });

  final dynamic account; // Using dynamic to avoid import issues
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final accountColor = Color(account.type?.color ?? 0xFF6B7280);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BillsThemeExtended.billChipRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(minHeight: BillsThemeExtended.billMinTouchTarget),
          decoration: BoxDecoration(
            color: selected
                ? BillsThemeExtended.billFilterSelected
                : BillsThemeExtended.billFilterUnselected,
            borderRadius: BillsThemeExtended.billChipRadius,
            border: selected ? Border.all(
              color: BillsThemeExtended.billFilterSelected.withValues(alpha: 0.3),
              width: 1,
            ) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Account type indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accountColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Account name
              Text(
                account.displayName ?? 'Unknown Account',
                style: BillsThemeExtended.billFilterText.copyWith(
                  color: selected
                      ? BillsThemeExtended.billFilterTextSelected
                      : BillsThemeExtended.billFilterTextUnselected,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🎨 Part 3: Complete Recurring Incomes Screen Transformation

### 3.1 Enhanced Income Theme
```dart
// lib/features/recurring_incomes/presentation/theme/income_theme_extended.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';

class IncomeThemeExtended {
  // Primary colors with gradients
  static const Color incomePrimary = Color(0xFF14B8A6); // Teal
  static const Color incomeSecondary = Color(0xFF06B6D4); // Cyan
  static const Color incomeAccent = Color(0xFF2DD4BF); // Light Teal
  
  // Status colors
  static const Color statusReceived = Color(0xFF10B981); // Green
  static const Color statusExpected = Color(0xFF3B82F6); // Blue
  static const Color statusOverdue = Color(0xFFEF4444); // Red
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  
  // Card styles
  static const Color incomeCardBg = Colors.white;
  static final Color incomeCardBorder = AppColors.borderSubtle;
  static final List<BoxShadow> incomeCardShadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Gradient definitions
  static const LinearGradient incomePrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      incomePrimary,
      Color(0xFF0D9488),
    ],
  );
  
  static const LinearGradient incomeSecondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      incomeSecondary,
      Color(0xFF0891B2),
    ],
  );
  
  // Animation durations
  static const Duration incomeAnimationFast = Duration(milliseconds: 200);
  static const Duration incomeAnimationNormal = Duration(milliseconds: 300);
  static const Duration incomeAnimationSlow = Duration(milliseconds: 500);
  
  // Border radius
  static final BorderRadius incomeCardRadius = BorderRadius.circular(16);
  static final BorderRadius incomeChipRadius = BorderRadius.circular(8);
  
  // Sizes
  static const double incomeMinTouchTarget = 44;
  static const double incomeCardPadding = 16;
  static const double incomeCardMargin = 8;
  static const double incomeStatusIndicatorSize = 12;
  
  // Typography extensions
  static const TextStyle incomeTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  
  static const TextStyle incomeSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static const TextStyle incomeAmount = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  static const TextStyle incomeAmountSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle incomeStatusText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  // Filter chip colors
  static final Color incomeFilterSelected = incomePrimary.withValues(alpha: 0.15);
  static final Color incomeFilterUnselected = AppColorsExtended.pillBgUnselected;
  static const Color incomeFilterTextSelected = incomePrimary;
  static final Color incomeFilterTextUnselected = AppColors.textSecondary;
  
  // Chart colors
  static const Color incomeChartPrimary = incomePrimary;
  static const Color incomeChartSecondary = incomeSecondary;
  
  // Banner background
  static final Color incomeBannerBg = AppColorsExtended.cardBgSecondary;
  
  // Animation curve
  static const Curve incomeAnimationCurve = Curves.easeOutCubic;
}
```

### 3.2 Enhanced Income Metric Cards
```dart
// lib/features/recurring_incomes/presentation/widgets/income_metric_cards.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../theme/income_theme_extended.dart';
import '../../domain/entities/recurring_income.dart';

class IncomeMetricCards extends StatelessWidget {
  const IncomeMetricCards({
    super.key,
    required this.summary,
  });

  final RecurringIncomesSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _IncomeMetricCard(
            title: 'Expected',
            value: summary.expectedAmount,
            displayValue: '\$${summary.expectedAmount.toStringAsFixed(0)}',
            icon: Icons.schedule,
            color: IncomeThemeExtended.incomeSecondary,
            subtitle: 'This Month',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _IncomeMetricCard(
            title: 'Received',
            value: summary.receivedThisMonth,
            displayValue: '\$${summary.receivedThisMonth.toStringAsFixed(0)}',
            icon: Icons.check_circle,
            color: IncomeThemeExtended.statusReceived,
            subtitle: 'This Month',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms),
        ),
      ],
    );
  }
}

class _IncomeMetricCard extends StatefulWidget {
  const _IncomeMetricCard({
    required this.title,
    required this.value,
    required this.displayValue,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final String title;
  final double value;
  final String displayValue;
  final IconData icon;
  final Color color;
  final String subtitle;

  @override
  State<_IncomeMetricCard> createState() => _IncomeMetricCardState();
}

class _IncomeMetricCardState extends State<_IncomeMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '\$${_animation.value.toStringAsFixed(0)}',
                style: AppTypographyExtended.metricPercentage.copyWith(
                  color: widget.color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          Text(
            widget.title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3.3 Enhanced Income Dashboard with Complete Visual Overhaul

Due to length constraints, I'll provide the key implementation pattern for the Income Dashboard:
```dart
// Key Pattern: Enhanced Income Dashboard Structure
class RecurringIncomeDashboardEnhanced extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildEnhancedAppBar(),
      body: _buildEnhancedBody(),
      floatingActionButton: _buildEnhancedFAB(),
    );
  }

  // Use same patterns as Bills:
  // 1. Gradient headers
  // 2. Animated metric cards
  // 3. Status banners with icons
  // 4. Enhanced card styling
  // 5. Staggered animations
  // 6. Circular indicators for progress
  // 7. Mini trend indicators
  // 8. Enhanced filter chips
}
```

---

## 📊 Part 4: Universal Design System Documentation

### 4.1 Component Hierarchy & Reusability Matrix
```dart
/// REUSABILITY MATRIX
/// 
/// Tier 1 (Core Components - Reuse Everywhere):
/// ✓ CircularBudgetIndicator → Goals, Bills, Incomes, Any Progress
/// ✓ DateSelectorPills → All date-based screens
/// ✓ BudgetMetricCards → All metric displays (2-column)
/// ✓ BudgetStatsRow → All 3-column stats
/// ✓ BudgetBarChart → All trend visualizations
/// ✓ MiniTrendIndicator → All list items with trends
/// ✓ StatusBanner → All status displays
/// 
/// Tier 2 (Adapted Components - Customize per feature):
/// ✓ Enhanced Headers → Consistent structure, feature-specific colors
/// ✓ Enhanced Cards → Same shadow/radius, different content
/// ✓ Filter Chips → Same interaction, different themes
/// ✓ FABs → Same gradient pattern, different icons/colors
/// 
/// Tier 3 (Feature-Specific):
/// ✓ Bill-specific cards
/// ✓ Income-specific cards
/// ✓ Goal-specific cards
```

### 4.2 Animation Timing Standards
```dart
// lib/core/theme/app_animations_standard.dart

class AppAnimationsStandard {
  // Standard durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 1000);
  
  // Standard curves
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve snapCurve = Curves.easeInOut;
  
  // Stagger delays for lists
  static Duration staggerDelay(int index, {int baseMs = 50}) {
    return Duration(milliseconds: baseMs * index);
  }
  
  // Standard animation sequences
  static List<Effect> fadeInSlide({
    required Duration duration,
    Duration? delay,
    Offset? begin,
  }) {
    return [
      FadeEffect(
        duration: duration,
        delay: delay ?? Duration.zero,
      ),
      SlideEffect(
        begin: begin ?? const Offset(0.1, 0),
        duration: duration,
        delay: delay ?? Duration.zero,
        curve: defaultCurve,
      ),
    ];
  }
  
  static List<Effect> fadeInScale({
    required Duration duration,
    Duration? delay,
  }) {
    return [
      FadeEffect(
        duration: duration,
        delay: delay ?? Duration.zero,
      ),
      ScaleEffect(
        begin: const Offset(0.8, 0.8),
        duration: duration,
        delay: delay ?? Duration.zero,
        curve: bounceCurve,
      ),
    ];
  }
}
```

### 4.3 Shadow & Elevation Standards
```dart
// lib/core/theme/app_shadows_standard.dart

class AppShadowsStandard {
  // Card shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Elevated shadows (for FABs, important buttons)
  static List<BoxShadow> elevatedShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  // Glow shadows (for status indicators)
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 4,
      spreadRadius: 1,
    ),
  ];
  
  // Pressed state (minimal shadow)
  static List<BoxShadow> get pressedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
}
```

---

## 🔧 Part 5:RetryDContinue🔧 Part 5: Implementation Checklist & Migration Guide
5.1 Step-by-Step Implementation Order
dart/// IMPLEMENTATION ROADMAP
/// 
/// Phase 1: Foundation (Days 1-2)
/// ✓ Create BillsThemeExtended
/// ✓ Create IncomeThemeExtended
/// ✓ Create AppAnimationsStandard
/// ✓ Create AppShadowsStandard
/// ✓ Update existing theme files to reference standards
/// 
/// Phase 2: Bills Enhancement (Days 3-5)
/// ✓ Replace bills_dashboard_screen.dart with enhanced version
/// ✓ Implement EnhancedBillsDashboardHeader
/// ✓ Implement EnhancedBillStatusBanner
/// ✓ Implement EnhancedBillCard
/// ✓ Implement EnhancedAccountFilters
/// ✓ Update bill_detail_screen.dart with enhanced styling
/// ✓ Add subscription_spotlight enhancements
/// 
/// Phase 3: Income Enhancement (Days 6-8)
/// ✓ Replace recurring_income_dashboard.dart with enhanced version
/// ✓ Implement IncomeMetricCards
/// ✓ Implement EnhancedIncomeCard
/// ✓ Implement EnhancedIncomeStatusBanner
/// ✓ Update income_detail_screen.dart with enhanced styling
/// ✓ Add account filter enhancements
/// 
/// Phase 4: Integration & Polish (Days 9-10)
/// ✓ Test all animations
/// ✓ Verify color consistency
/// ✓ Check responsive behavior
/// ✓ Performance optimization
/// ✓ Accessibility audit
5.2 File-by-File Migration Guide
Bills Screen Files to Update:
dart// 1. bills_dashboard_screen.dart → REPLACE
// Original: Document 9 (lines 1-xxx)
// New: Enhanced version with:
//   - EnhancedBillsDashboardHeader
//   - EnhancedBillStatusBanner
//   - EnhancedBillsStatsRow
//   - EnhancedBillsBarChart
//   - EnhancedAccountFilters
//   - EnhancedBillCard

// Migration steps:
// a. Backup original file
// b. Create new enhanced_bills_dashboard_screen.dart
// c. Copy state management from original
// d. Replace UI components with enhanced versions
// e. Update route in router configuration
// f. Test thoroughly before removing original

// 2. bill_detail_screen.dart → UPDATE
// Original: Document 10
// Updates needed:
//   - Add gradient backgrounds to important sections
//   - Enhance auto-pay indicator
//   - Add circular progress for payment status
//   - Improve account information display
//   - Add animations

// 3. subscription_spotlight.dart → ENHANCE
// Original: Document 8
// Updates needed:
//   - Add gradient card background
//   - Enhance subscription item styling
//   - Add trend indicators
//   - Improve status badges
Income Screen Files to Update:
dart// 1. recurring_income_dashboard.dart → REPLACE
// Original: Document 11
// New: Enhanced version with:
//   - IncomeMetricCards
//   - EnhancedIncomeCard
//   - Status banners
//   - Bar charts
//   - Enhanced filters

// 2. recurring_income_detail_screen.dart → UPDATE
// Original: Document 13
// Updates needed:
//   - Add gradient backgrounds
//   - Enhance detail rows
//   - Improve account display
//   - Add status indicators
//   - Add animations
5.3 Complete Enhanced Bills Dashboard Implementation
dart// lib/features/bills/presentation/screens/enhanced_bills_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart';
import '../../../budgets/presentation/widgets/budget_bar_chart.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_providers.dart';
import '../widgets/enhanced_bills_dashboard_header.dart';
import '../widgets/enhanced_bill_status_banner.dart';
import '../widgets/enhanced_bills_stats_row.dart';
import '../widgets/enhanced_bills_bar_chart.dart';
import '../widgets/enhanced_account_filters.dart';
import '../widgets/enhanced_bill_card.dart';
import '../widgets/subscription_spotlight.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced Bills Dashboard with modern UI matching budget/home design
class EnhancedBillsDashboardScreen extends ConsumerStatefulWidget {
  const EnhancedBillsDashboardScreen({super.key});

  @override
  ConsumerState<EnhancedBillsDashboardScreen> createState() => 
      _EnhancedBillsDashboardScreenState();
}

class _EnhancedBillsDashboardScreenState 
    extends ConsumerState<EnhancedBillsDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountFilterId;
  bool _showLinkedOnly = false;
  BillsViewMode _viewMode = BillsViewMode.timeline;

  @override
  Widget build(BuildContext context) {
    developer.log('EnhancedBillsDashboardScreen built', name: 'Bills');
    
    final billState = ref.watch(billNotifierProvider);
    final upcomingBills = ref.watch(upcomingBillsProvider);
    final overdueCount = ref.watch(overdueBillsCountProvider);
    final totalMonthly = ref.watch(totalMonthlyBillsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            EnhancedBillsDashboardHeader(
              selectedDate: _selectedDate,
              onDateChanged: (date) => setState(() => _selectedDate = date),
              onAddBillPressed: () {
                developer.log('Navigating to add bill screen', name: 'Bills');
                context.go('/more/bills/add');
              },
              onFilterPressed: () {
                // TODO: Implement filter sheet
              },
              viewMode: _viewMode,
              onViewModeChanged: (mode) => setState(() => _viewMode = mode),
              overdueCount: overdueCount,
            ).animate()
              .fadeIn(duration: BillsThemeExtended.billAnimationFast)
              .slideY(begin: -0.1, duration: BillsThemeExtended.billAnimationFast),

            // Main Content
            Expanded(
              child: billState.when(
                initial: () => const LoadingView(),
                loading: () => const LoadingView(),
                loaded: (bills, summary) => _buildDashboard(
                  context,
                  ref,
                  summary,
                  upcomingBills,
                  overdueCount,
                  totalMonthly,
                ),
                error: (message, bills, summary) => ErrorView(
                  message: message,
                  onRetry: () => ref.refresh(billNotifierProvider),
                ),
                billLoaded: (bill, status) => const SizedBox.shrink(),
                billSaved: (bill) => const SizedBox.shrink(),
                billDeleted: () => const SizedBox.shrink(),
                paymentMarked: (bill) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    BillsSummary summary,
    List<BillStatus> upcomingBills,
    int overdueCount,
    double totalMonthly,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(billNotifierProvider.notifier).refresh();
      },
      child: _viewMode == BillsViewMode.calendar
          ? _buildCalendarView(context, ref, summary, upcomingBills)
          : _buildTimelineView(context, ref, summary, upcomingBills, overdueCount, totalMonthly),
    );
  }

  Widget _buildTimelineView(
    BuildContext context,
    WidgetRef ref,
    BillsSummary summary,
    List<BillStatus> upcomingBills,
    int overdueCount,
    double totalMonthly,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.screenPaddingV,
      ),
      children: [
        // Bill Status Banner
        EnhancedBillStatusBanner(
          overdueCount: overdueCount,
          dueThisMonth: summary.dueThisMonth,
          paidThisMonth: summary.paidThisMonth,
          totalMonthly: totalMonthly,
          unpaidAmount: totalMonthly - (totalMonthly * (summary.paidThisMonth / summary.dueThisMonth.clamp(1, double.infinity))),
        ).animate()
          .fadeIn(duration: BillsThemeExtended.billAnimationFast)
          .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationFast),

        const SizedBox(height: 16),

        // Bills Stats Row
        EnhancedBillsStatsRow(
          totalBills: summary.totalBills,
          paidThisMonth: summary.paidThisMonth,
          dueThisMonth: summary.dueThisMonth,
          totalMonthly: totalMonthly,
          overdueCount: overdueCount,
        ),

        const SizedBox(height: 16),

        // Subscription Spotlight
        const SubscriptionSpotlight(),

        const SizedBox(height: 16),

        // Monthly Spending Chart
        EnhancedBillsBarChart(
          monthlyData: _generateMonthlyData(totalMonthly),
          title: 'Monthly Bill Trends',
        ),

        const SizedBox(height: 16),

        // Enhanced Account Filters
        EnhancedAccountFilters(
          selectedAccountFilterId: _selectedAccountFilterId,
          showLinkedOnly: _showLinkedOnly,
          onAccountFilterChanged: (id) => setState(() => _selectedAccountFilterId = id),
          onLinkedOnlyChanged: (linked) => setState(() => _showLinkedOnly = linked),
        ).animate()
          .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal)
          .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal),

        const SizedBox(height: 12),

        // Upcoming Bills Section
        _buildUpcomingBillsSection(context, upcomingBills),

        const SizedBox(height: 16),

        // All Bills Section
        _buildAllBillsSection(context, ref),
      ],
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    WidgetRef ref,
    BillsSummary summary,
    List<BillStatus> upcomingBills,
  ) {
    // Reuse existing EnhancedBillsCalendarView from Document 5
    return EnhancedBillsCalendarView(
      bills: ref.watch(billNotifierProvider).maybeWhen(
        loaded: (bills, summary) => bills,
        orElse: () => <Bill>[],
      ),
      selectedDate: _selectedDate,
      onDateSelected: (date) => setState(() => _selectedDate = date),
      onBillTap: (bill) {
        context.go('/more/bills/${bill.id}');
      },
    );
  }

  Widget _buildUpcomingBillsSection(BuildContext context, List<BillStatus> upcomingBills) {
    final filteredUpcomingBills = _filterUpcomingBills(upcomingBills);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1),
                borderRadius: BillsThemeExtended.billChipRadius,
              ),
              child: Icon(
                Icons.schedule,
                size: 20,
                color: BillsThemeExtended.billStatsPrimary,
              ),
            ),
            SizedBox(width: AppDimensions.spacing2),
            Expanded(
              child: Text(
                'Upcoming Bills',
                style: BillsThemeExtended.billTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1),
                borderRadius: BillsThemeExtended.billChipRadius,
              ),
              child: Text(
                '${filteredUpcomingBills.length}',
                style: BillsThemeExtended.billStatusText.copyWith(
                  color: BillsThemeExtended.billStatsPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 300.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 300.ms),
        
        const SizedBox(height: 16),
        
        if (filteredUpcomingBills.isEmpty)
          _buildEmptyUpcomingBills(context)
        else
          ...filteredUpcomingBills.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnhancedBillCard(bill: status.bill)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 400 + (index * 100)))
                  .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 400 + (index * 100))),
            );
          }),
      ],
    );
  }

  Widget _buildAllBillsSection(BuildContext context, WidgetRef ref) {
    final billState = ref.watch(billNotifierProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BillsThemeExtended.billStatsSecondary.withValues(alpha: 0.1),
                borderRadius: BillsThemeExtended.billChipRadius,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 20,
                color: BillsThemeExtended.billStatsSecondary,
              ),
            ),
            SizedBox(width: AppDimensions.spacing2),
            Expanded(
              child: Text(
                _getFilteredBillsTitle(),
                style: BillsThemeExtended.billTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 500.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 500.ms),
        
        const SizedBox(height: 16),
        
        billState.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const CircularProgressIndicator(),
          loaded: (bills, summary) {
            final filteredBills = _filterBills(bills);
            if (filteredBills.isEmpty) {
              return _buildEmptyFilteredBills(context);
            }
            return Column(
              children: filteredBills.asMap().entries.map((entry) {
                final index = entry.key;
                final bill = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EnhancedBillCard(bill: bill)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 600 + (index * 80)))
                      .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 600 + (index * 80))),
                );
              }).toList(),
            );
          },
          error: (message, bills, summary) => Text('Error: $message'),
          billLoaded: (bill, status) => const SizedBox.shrink(),
          billSaved: (bill) => const SizedBox.shrink(),
          billDeleted: () => const SizedBox.shrink(),
          paymentMarked: (bill) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEmptyUpcomingBills(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BillsThemeExtended.billCardRadius,
        boxShadow: BillsThemeExtended.billCardShadows,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BillsThemeExtended.billStatusNormal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 48,
              color: BillsThemeExtended.billStatusNormal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming bills',
            style: BillsThemeExtended.billTitle.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All your bills are paid or\nno bills are due soon',
            style: BillsThemeExtended.billSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilteredBills(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BillsThemeExtended.billCardRadius,
        boxShadow: BillsThemeExtended.billCardShadows,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BillsThemeExtended.billStatusDueSoon.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.filter_list_off,
              size: 48,
              color: BillsThemeExtended.billStatusDueSoon,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No bills found',
            style: BillsThemeExtended.billTitle.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters\nto see more bills',
            style: BillsThemeExtended.billSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedAccountFilterId = null;
                _showLinkedOnly = false;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: BillsThemeExtended.billStatsPrimary,
              side: BorderSide(color: BillsThemeExtended.billStatsPrimary),
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<BillStatus> _filterUpcomingBills(List<BillStatus> bills) {
    return bills.where((status) {
      if (_showLinkedOnly) {
        return status.bill.accountId != null;
      } else if (_selectedAccountFilterId != null) {
        return status.bill.accountId == _selectedAccountFilterId;
      }
      return true;
    }).toList();
  }

  List<Bill> _filterBills(List<Bill> bills) {
    if (_showLinkedOnly) {
      return bills.where((bill) => bill.accountId != null).toList();
    } else if (_selectedAccountFilterId != null) {
      return bills.where((bill) => bill.accountId == _selectedAccountFilterId).toList();
    }
    return bills;
  }

  String _getFilteredBillsTitle() {
    if (_showLinkedOnly) return 'Bills with Linked Accounts';
    if (_selectedAccountFilterId != null) return 'Bills for Selected Account';
    return 'All Bills';
  }

  List<double> _generateMonthlyData(double totalMonthly) {
    // Generate mock data - replace with actual data
    return List.generate(6, (i) => totalMonthly * (0.8 + (i * 0.05)));
  }
}
5.4 Enhanced Bills Stats Row
dart// lib/features/bills/presentation/widgets/enhanced_bills_stats_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bills stats row showing key financial metrics
class EnhancedBillsStatsRow extends StatelessWidget {
  const EnhancedBillsStatsRow({
    super.key,
    required this.totalBills,
    required this.paidThisMonth,
    required this.dueThisMonth,
    required this.totalMonthly,
    required this.overdueCount,
  });

  final int totalBills;
  final int paidThisMonth;
  final int dueThisMonth;
  final double totalMonthly;
  final int overdueCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: BudgetStatsRow(
        allotted: totalMonthly,
        used: totalMonthly * (paidThisMonth / dueThisMonth.clamp(1, double.infinity)),
        remaining: totalMonthly - (totalMonthly * (paidThisMonth / dueThisMonth.clamp(1, double.infinity))),
      ),
    ).animate()
      .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast)
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast);
  }
}
5.5 Enhanced Bills Bar Chart
dart// lib/features/bills/presentation/widgets/enhanced_bills_bar_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/budget_bar_chart.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced bills bar chart showing monthly spending trends
class EnhancedBillsBarChart extends StatelessWidget {
  const EnhancedBillsBarChart({
    super.key,
    required this.monthlyData,
    required this.title,
  });

  final List<double> monthlyData;
  final String title;

  @override
  Widget build(BuildContext context) {
    // Convert List<double> to List<BudgetChartData>
    final chartData = monthlyData.asMap().entries.map((entry) {
      final monthIndex = entry.key;
      final value = entry.value;
      final monthName = _getMonthName(monthIndex);
      return BudgetChartData(
        label: monthName,
        value: value,
        color: BillsThemeExtended.billChartPrimary,
      );
    }).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: BudgetBarChart(
        data: chartData,
        title: title,
        period: 'Last 6 Months',
        height: 200,
      ),
    ).animate()
      .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal)
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal);
  }

  String _getMonthName(int monthIndex) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - (5 - monthIndex), 1);
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return monthNames[targetMonth.month - 1];
  }
}

🎯 Part 6: Quality Assurance & Testing Checklist
6.1 Visual Consistency Verification
dart/// VISUAL CONSISTENCY CHECKLIST
/// 
/// ✓ Color Palette Consistency
///   - Primary colors match across all screens
///   - Status colors use same values (green, amber, red)
///   - Background colors consistent
///   - Border colors match
/// 
/// ✓ Typography Consistency
///   - Header font sizes match (24px for main titles)
///   - Body text consistent (13-16px)
///   - Font weights match (w400, w500, w600, w700)
///   - Line heights consistent
/// 
/// ✓ Spacing Consistency
///   - Card padding: 16px
///   - Screen padding: 16px horizontal
///   - Section gaps: 16px vertical
///   - Element spacing: 8px, 12px, 16px increments
/// 
/// ✓ Border Radius Consistency
///   - Cards: 16px
///   - Chips/Badges: 8px
///   - Small elements: 6px
/// 
/// ✓ Shadow Consistency
///   - All cards use same shadow: (0, 2) blur 8, alpha 0.04
///   - Elevated elements: (0, 6) blur 12, alpha 0.3
///   - Glow effects: blur 4, spread 1, alpha 0.3
/// 
/// ✓ Animation Consistency
///   - Fast: 200ms
///   - Normal: 300ms
///   - Slow: 500ms
///   - All use easeOutCubic curve
///   - Stagger delay: 50-100ms increments
6.2 Component Reusability Verification
dart/// REUSABILITY VERIFICATION
/// 
/// ✓ Bills Screen Uses:
///   [x] CircularBudgetIndicator - NO (should add for visual consistency)
///   [x] DateSelectorPills - YES (in header)
///   [x] BudgetMetricCards pattern - NO (should add)
///   [x] BudgetStatsRow - YES (reused directly)
///   [x] BudgetBarChart - YES (reused directly)
///   [x] MiniTrendIndicator - NO (should add to bill cards)
///   [x] StatusBanner pattern - YES (EnhancedBillStatusBanner)
/// 
/// ✓ Income Screen Uses:
///   [x] CircularBudgetIndicator - NO (should add)
///   [x] DateSelectorPills - NO (should add)
///   [x] BudgetMetricCards - YES (IncomeMetricCards)
///   [x] BudgetStatsRow - YES (reused directly)
///   [x] BudgetBarChart - YES (reused directly)
///   [x] MiniTrendIndicator - NO (should add)
///   [x] StatusBanner pattern - YES (adapted)
6.3 Missing Enhancements to Add
dart// ENHANCEMENT OPPORTUNITIES

// 1. Add Circular Progress to Bills Dashboard
// Show overall payment completion for the month
Widget _buildBillsCircularProgress() {
  final paidPercentage = paidThisMonth / dueThisMonth;
  return Center(
    child: CircularBudgetIndicator(
      percentage: paidPercentage,
      spent: paidAmount,
      total: totalAmount,
      size: 220,
      strokeWidth: 22,
    ),
  );
}

// 2. Add Mini Trend Indicators to Bill Cards
// Show 7-day payment trend
Widget _enhancedBillCardWithTrend(Bill bill) {
  return EnhancedBillCard(
    bill: bill,
    trendData: _getBill7DayTrend(bill),
  );
}

// 3. Add Metric Cards to Bills Dashboard
// Show completion rate and average bill amount
Widget _buildBillMetrics() {
  return Row(
    children: [
      Expanded(
        child: _MetricCard(
          title: 'Completion',
          percentage: paidPercentage,
          icon: Icons.check_circle,
        ),
      ),
      Expanded(
        child: _MetricCard(
          title: 'Avg Amount',
          value: averageBillAmount,
          icon: Icons.attach_money,
        ),
      ),
    ],
  );
}

// 4. Add Circular Progress to Income Dashboard
// Show income collection progress
Widget _buildIncomeCircularProgress() {
  final receivedPercentage = receivedAmount / expectedAmount;
  return Center(
    child: CircularBudgetIndicator(
      percentage: receivedPercentage,
      spent: receivedAmount,
      total: expectedAmount,
      size: 220,
      strokeWidth: 22,
    ),
  );
}

// 5. Add Date Selector to Income Dashboard
// Allow filtering by date range
Widget _buildIncomeDateSelector() {
  return DateSelectorPills(
    startDate: startOfMonth,
    endDate: endOfMonth,
    selectedDate: selectedDate,
    onDateSelected: (date) => _onDateChanged(date),
  );
}

📱 Part 7: Responsive Design & Accessibility
7.1 Responsive Breakpoints
dart// lib/core/theme/app_responsive.dart

class AppResponRetry