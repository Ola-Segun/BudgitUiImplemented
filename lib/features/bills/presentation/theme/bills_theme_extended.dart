import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';

/// Extended theme for bills-specific components
class BillsThemeExtended {
  // Bill Status Colors
  static const Color billStatusNormal = AppColorsExtended.statusNormal;
  static const Color billStatusDueSoon = AppColorsExtended.statusWarning;
  static const Color billStatusDueToday = AppColorsExtended.statusCritical;
  static const Color billStatusOverdue = AppColorsExtended.statusOverBudget;

  // Bill Urgency Colors
  static const Color billUrgencyNormal = AppColorsExtended.statusNormal;
  static const Color billUrgencyDueSoon = AppColorsExtended.statusWarning;
  static const Color billUrgencyDueToday = AppColorsExtended.statusCritical;
  static const Color billUrgencyOverdue = AppColorsExtended.statusOverBudget;

  // Bill Card Colors
  static const Color billCardBg = Colors.white;
  static const Color billCardBorder = AppColors.borderSubtle;
  static const Color billCardShadow = Color(0x0D000000);

  // Bill Status Banner Colors
  static const Color billBannerBg = AppColorsExtended.cardBgSecondary;
  static const Color billBannerBorder = AppColorsExtended.statusWarning;

  // Bill Stats Colors - Updated to match teal palette
  static const Color billStatsPrimary = Color(0xFF00D4AA); // Teal (matching budget primary)
  static const Color billStatsSecondary = Color(0xFF7C3AED); // Purple (matching budget secondary)
  static const Color billStatsTertiary = Color(0xFFF59E0B); // Amber (matching budget tertiary)

  // Bill Filter Colors
  static const Color billFilterSelected = AppColorsExtended.budgetPrimary;
  static const Color billFilterUnselected = AppColorsExtended.pillBgUnselected;
  static const Color billFilterTextSelected = Colors.white;
  static const Color billFilterTextUnselected = AppColors.textSecondary;

  // Bill Chart Colors - Updated to match teal palette
  static const Color billChartPrimary = Color(0xFF00D4AA); // Teal (matching budget primary)
  static const Color billChartSecondary = Color(0xFF7C3AED); // Purple (matching budget secondary)
  static const Color billChartTertiary = Color(0xFFF59E0B); // Amber (matching budget tertiary)
  static const Color billChartGrid = AppColors.borderSubtle;

  // Bill Animation Colors - Updated to match teal palette
  static const Color billAnimationPrimary = Color(0xFF00D4AA); // Teal (matching budget primary)
  static const Color billAnimationSecondary = Color(0xFF10B981); // Green (matching status normal)

  // Bill Typography
  static TextStyle get billTitle => AppTypographyExtended.statsValue.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get billSubtitle => AppTypographyExtended.metricLabel.copyWith(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  static TextStyle get billAmount => AppTypographyExtended.statsValue.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get billAmountSmall => AppTypographyExtended.metricLabel.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get billStatusText => AppTypographyExtended.metricLabel.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get billFilterText => AppTypographyExtended.metricLabel.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  // Bill Dimensions
  static const double billCardBorderRadius = 16.0;
  static const double billCardPadding = 16.0;
  static const double billCardMargin = 8.0;
  static const double billStatusIndicatorSize = 8.0;
  static const double billIconSize = 20.0;
  static const double billAvatarSize = 40.0;

  // Bill Shadows
  static List<BoxShadow> get billCardShadows => [
        BoxShadow(
          color: billCardShadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // Bill Gradients
  static LinearGradient get billPrimaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          billStatsPrimary,
          billStatsPrimary.withValues(alpha: 0.8),
        ],
      );

  static LinearGradient get billSecondaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          billStatsSecondary,
          billStatsSecondary.withValues(alpha: 0.8),
        ],
      );

  // Bill Border Radius
  static BorderRadius get billCardRadius => BorderRadius.circular(billCardBorderRadius);
  static BorderRadius get billChipRadius => BorderRadius.circular(12);

  // Bill Accessibility
  static const double billMinTouchTarget = 48.0; // 48x48dp minimum touch area

  // Bill Animation Durations
  static const Duration billAnimationFast = Duration(milliseconds: 200);
  static const Duration billAnimationNormal = Duration(milliseconds: 300);
  static const Duration billAnimationSlow = Duration(milliseconds: 500);

  // Bill Animation Curves
  static const Curve billAnimationCurve = Curves.easeOutCubic;
  static const Curve billAnimationElastic = Curves.elasticOut;
}