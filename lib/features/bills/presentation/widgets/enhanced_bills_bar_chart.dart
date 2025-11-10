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
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal, curve: BillsThemeExtended.billAnimationCurve);
  }

  String _getMonthName(int monthIndex) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - (5 - monthIndex), 1);
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return monthNames[targetMonth.month - 1];
  }
}