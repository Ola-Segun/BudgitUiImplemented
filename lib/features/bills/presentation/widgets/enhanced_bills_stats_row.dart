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
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast, curve: BillsThemeExtended.billAnimationCurve);
  }
}