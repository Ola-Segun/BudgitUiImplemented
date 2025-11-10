import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/enhanced_budget_card.dart';
import '../../domain/entities/dashboard_data.dart';

class EnhancedBudgetOverviewWidget extends StatelessWidget {
  const EnhancedBudgetOverviewWidget({
    super.key,
    required this.budgetOverview,
  });

  final List<BudgetCategoryOverview> budgetOverview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsExtended.budgetSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  size: 20,
                  color: AppColorsExtended.budgetSecondary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Overview',
                      style: AppTypographyExtended.statsValue.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (budgetOverview.isNotEmpty)
                      Text(
                        'Across all active budgets',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    context.go('/budgets');
                  }
                },
                child: Text(
                  'See All',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColorsExtended.budgetPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),

          if (budgetOverview.isEmpty)
            _buildEmptyState(context)
          else
            ...budgetOverview.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < budgetOverview.length - 1 ? 12 : 0,
                ),
                child: _EnhancedBudgetCategoryCard(
                  category: category,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                  .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 100 * index)),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Budgets Yet',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first budget to start\ntracking your spending',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              context.go('/budgets');
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Budget'),
            style: TextButton.styleFrom(
              foregroundColor: AppColorsExtended.budgetPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedBudgetCategoryCard extends StatelessWidget {
  const _EnhancedBudgetCategoryCard({
    required this.category,
  });

  final BudgetCategoryOverview category;

  Color _getProgressColor(BudgetHealthStatus status) {
    switch (status) {
      case BudgetHealthStatus.healthy:
        return AppColorsExtended.statusNormal;
      case BudgetHealthStatus.warning:
        return AppColorsExtended.statusWarning;
      case BudgetHealthStatus.critical:
        return AppColorsExtended.statusCritical;
      case BudgetHealthStatus.overBudget:
        return AppColorsExtended.statusOverBudget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = category.spent / category.budget;
    final progressColor = _getProgressColor(category.status);
    final isOverBudget = category.status == BudgetHealthStatus.overBudget;

    // Mock trend data - replace with actual historical data
    final trendData = List.generate(7, (i) => category.spent / 7 * (1 + (i * 0.1)));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
        border: isOverBudget
            ? Border.all(
                color: progressColor.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category indicator dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: progressColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),

              // Category name
              Expanded(
                child: Text(
                  category.categoryName,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Mini trend indicator
              MiniTrendIndicator(
                values: trendData,
                color: progressColor,
                width: 50,
                height: 20,
              ),

              SizedBox(width: AppDimensions.spacing2),

              // Percentage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.spacing3),

          // Progress bar
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        progressColor,
                        progressColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.spacing2),

          // Amount details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(category.spent),
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'of ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(category.budget)}',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          if (isOverBudget) ...[
            SizedBox(height: AppDimensions.spacing2),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: progressColor,
                ),
                SizedBox(width: AppDimensions.spacing1),
                Text(
                  'Over budget by ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(category.spent - category.budget)}',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}