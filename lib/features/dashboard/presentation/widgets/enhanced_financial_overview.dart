import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart';
import '../../../../shared/presentation/widgets/cards/balance_card.dart';
import '../../domain/entities/dashboard_data.dart';

/// Enhanced financial overview with circular indicator
class EnhancedFinancialOverview extends StatefulWidget {
  const EnhancedFinancialOverview({
    super.key,
    required this.snapshot,
  });

  final FinancialSnapshot snapshot;

  @override
  State<EnhancedFinancialOverview> createState() => _EnhancedFinancialOverviewState();
}

class _EnhancedFinancialOverviewState extends State<EnhancedFinancialOverview> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final netWorth = widget.snapshot.netWorth;
    final income = widget.snapshot.incomeThisMonth;
    final expenses = widget.snapshot.expensesThisMonth;
    final savingsRate = income > 0 ? (income - expenses) / income : 0.0;
    final expenseRate = income > 0 ? expenses / income : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: Text(
            'Financial Overview',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: -0.1, duration: 400.ms),

        SizedBox(height: AppDimensions.spacing4),



        // Tab Structure with PageView
        SizedBox(
          height: 230, // Height to accommodate both circular indicator and balance card
          child: PageView(
            controller: _pageController,
            children: [
              // Tab 1: Circular Indicator
              Center(
                child: CircularBudgetIndicator(
                  percentage: expenseRate.clamp(0.0, 1.0),
                  spent: expenses,
                  total: income > 0 ? income : expenses,
                  size: 190,
                  strokeWidth: 20,
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, delay: 200.ms, curve: Curves.elasticOut),

              // Tab 2: Balance Card
              Center(
                child: BalanceCard(
                  title: 'Net Worth',
                  amount: NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(netWorth),
                  icon: Icons.account_balance_wallet,
                  gradientStart: AppColors.primary,
                  gradientEnd: AppColors.primaryDark,
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, delay: 200.ms, curve: Curves.elasticOut),
            ],
          ),
        ),

        SizedBox(height: AppDimensions.spacing4),


                // Tab Indicator
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      2, // Number of pages
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: AppDimensions.spacing1),
                        width: _currentPage == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                      ),
                    ),
                  ),
                ),


        SizedBox(height: AppDimensions.spacing4),

        // Status Banner
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: _FinancialStatusBanner(
            netWorth: netWorth,
            income: income,
            expenses: expenses,
          ),
        ).animate()
          .fadeIn(duration: 400.ms, delay: 400.ms)
          .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms),

        SizedBox(height: AppDimensions.spacing4),

        // Metric Cards
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Savings Rate',
                  percentage: savingsRate,
                  icon: Icons.trending_up,
                  isPositive: savingsRate > 0,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms)
                  .slideX(begin: -0.1, duration: 400.ms, delay: 500.ms),
              ),
              SizedBox(width: AppDimensions.spacing4),
              Expanded(
                child: _MetricCard(
                  title: 'Expense Rate',
                  percentage: expenseRate,
                  icon: Icons.trending_down,
                  isPositive: false,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 600.ms)
                  .slideX(begin: 0.1, duration: 400.ms, delay: 600.ms),
              ),
            ],
          ),
        ),

        SizedBox(height: AppDimensions.spacing4),

        // Stats Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: BudgetStatsRow(
            allotted: income,
            used: expenses,
            remaining: netWorth,
          ),
        ).animate()
          .fadeIn(duration: 400.ms, delay: 700.ms)
          .slideY(begin: 0.1, duration: 400.ms, delay: 700.ms),
      ],
    );
  }
}

class _FinancialStatusBanner extends StatelessWidget {
  const _FinancialStatusBanner({
    required this.netWorth,
    required this.income,
    required this.expenses,
  });

  final double netWorth;
  final double income;
  final double expenses;

  String _getStatusMessage() {
    if (netWorth < 0) {
      return 'Expenses exceed income by ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(-netWorth)}';
    } else if (expenses > income * 0.9) {
      return 'You\'re spending 90% of your income';
    } else {
      return 'You\'re saving ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(netWorth)} this month';
    }
  }

  Color _getStatusColor() {
    if (netWorth < 0) return AppColorsExtended.statusOverBudget;
    if (expenses > income * 0.9) return AppColorsExtended.statusWarning;
    return AppColorsExtended.statusNormal;
  }

  String _getStatusLabel() {
    if (netWorth < 0) return 'Critical';
    if (expenses > income * 0.9) return 'Warning';
    return 'Healthy';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4, vertical: AppDimensions.spacing3 + 2),
      decoration: BoxDecoration(
        color: AppColorsExtended.cardBgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(
              netWorth >= 0 ? Icons.trending_up : Icons.trending_down,
              size: AppDimensions.iconSm,
              color: statusColor,
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),
          Expanded(
            child: Text(
              _getStatusMessage(),
              style: AppTypographyExtended.statusMessage.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacing2),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.spacing2),
          Text(
            _getStatusLabel(),
            style: AppTypographyExtended.statusMessage.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.percentage,
    required this.icon,
    required this.isPositive,
  });

  final String title;
  final double percentage;
  final IconData icon;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive
        ? AppColorsExtended.statusNormal
        : AppColorsExtended.statusCritical;

    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
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
            padding: EdgeInsets.all(AppDimensions.spacing2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: AppDimensions.iconSm, color: color),
          ),
          SizedBox(height: AppDimensions.spacing3),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: percentage),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '${(value * 100).toInt()}%',
                style: AppTypographyExtended.metricPercentage.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
          SizedBox(height: AppDimensions.spacing1),
          Text(
            title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}