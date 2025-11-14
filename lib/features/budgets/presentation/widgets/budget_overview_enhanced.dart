import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/widgets/mini_trend_indicator.dart';
import '../../domain/entities/budget.dart' as budget_entity;

/// Enhanced budget overview section matching Home/Transaction design
class BudgetOverviewEnhanced extends ConsumerWidget {
  const BudgetOverviewEnhanced({
    super.key,
    required this.budgets,
    required this.budgetStatuses,
  });

  final List<budget_entity.Budget> budgets;
  final List<budget_entity.BudgetStatus> budgetStatuses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (budgets.isEmpty) {
      return _buildEmptyState(context);
    }

    return RepaintBoundary( // Add RepaintBoundary for performance
      child: Container(
        padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            SizedBox(height: DesignTokens.spacing5),

            // Budget cards grid
            ...budgets.take(6).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final budget = entry.value;
              final status = budgetStatuses.firstWhere(
                (s) => s.budget.id == budget.id,
                orElse: () => budgetStatuses.first,
              );

              return Padding(
                padding: EdgeInsets.only(bottom: DesignTokens.spacing3),
                child: RepaintBoundary( // Add RepaintBoundary for performance
                  child: _EnhancedBudgetCard(
                    budget: budget,
                    status: status,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/budgets/${budget.id}');
                    },
                  ).animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 100 * index),
                    )
                    .slideX(
                      begin: 0.1,
                      duration: 400.ms,
                      delay: Duration(milliseconds: 100 * index),
                    ),
                ),
              );
            }),

            // Show more button
            if (budgets.length > 6) ...[
              SizedBox(height: DesignTokens.spacing2),
              _buildShowMoreButton(context),
            ],
          ],
        ),
      ).animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: 0.1, duration: 500.ms, delay: 200.ms),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Gradient icon
        Container(
          padding: EdgeInsets.all(DesignTokens.spacing2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColorsExtended.budgetPrimary,
                AppColorsExtended.budgetPrimary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet,
            size: DesignTokens.iconMd,
            color: Colors.white,
          ),
        ),
        SizedBox(width: DesignTokens.spacing3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Budgets',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${budgets.length} budgets tracking',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // View all badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing3,
            vertical: DesignTokens.spacing2,
          ),
          decoration: BoxDecoration(
            color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Text(
            '${budgets.length}',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColorsExtended.budgetPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: -0.1, duration: 400.ms);
  }

  Widget _buildShowMoreButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          // Show all budgets
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing3),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.borderSubtle,
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Show ${budgets.length - 6} More',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColorsExtended.budgetPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: DesignTokens.spacing1),
              Icon(
                Icons.expand_more,
                size: 18,
                color: AppColorsExtended.budgetPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing5),
            decoration: BoxDecoration(
              color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 56,
              color: AppColorsExtended.budgetPrimary,
            ),
          ),
          SizedBox(height: DesignTokens.spacing4),
          Text(
            'No Active Budgets',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 16,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),
          Text(
            'Create your first budget to\nstart tracking spending',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Enhanced budget card with trend indicator and gradient
class _EnhancedBudgetCard extends StatelessWidget {
  const _EnhancedBudgetCard({
    required this.budget,
    required this.status,
    required this.onTap,
  });

  final budget_entity.Budget budget;
  final budget_entity.BudgetStatus status;
  final VoidCallback onTap;

  Color _getHealthColor(budget_entity.BudgetHealth health) {
    switch (health) {
      case budget_entity.BudgetHealth.healthy:
        return AppColorsExtended.statusNormal;
      case budget_entity.BudgetHealth.warning:
        return AppColorsExtended.statusWarning;
      case budget_entity.BudgetHealth.critical:
        return AppColorsExtended.statusCritical;
      case budget_entity.BudgetHealth.overBudget:
        return AppColorsExtended.statusOverBudget;
    }
  }

  IconData _getHealthIcon(budget_entity.BudgetHealth health) {
    switch (health) {
      case budget_entity.BudgetHealth.healthy:
        return Icons.check_circle;
      case budget_entity.BudgetHealth.warning:
        return Icons.warning_amber_rounded;
      case budget_entity.BudgetHealth.critical:
        return Icons.error;
      case budget_entity.BudgetHealth.overBudget:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = status.totalSpent / status.totalBudget;
    final healthColor = _getHealthColor(status.overallHealth);
    final isOverBudget = status.overallHealth == budget_entity.BudgetHealth.overBudget;

    // Generate mock trend data - replace with actual historical data
    final trendData = _generateTrendData(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Container(
          padding: EdgeInsets.all(DesignTokens.spacing4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                healthColor.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(
              color: isOverBudget
                  ? healthColor.withValues(alpha: 0.3)
                  : AppColors.borderSubtle,
              width: isOverBudget ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Type indicator with gradient
                  Container(
                    padding: EdgeInsets.all(DesignTokens.spacing2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          healthColor,
                          healthColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: healthColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getBudgetTypeIcon(budget.type),
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: DesignTokens.spacing3),

                  // Budget name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: AppTypographyExtended.metricLabel.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: DesignTokens.spacing2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: healthColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusSm,
                                ),
                              ),
                              child: Text(
                                budget.type.displayName,
                                style: AppTypographyExtended.metricLabel.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: healthColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.access_time,
                              size: 10,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${status.daysRemaining}d left',
                              style: AppTypographyExtended.metricLabel.copyWith(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Mini trend indicator
                  MiniTrendIndicator(
                    values: trendData,
                    color: healthColor,
                    width: 50,
                    height: 20,
                  ),

                  SizedBox(width: DesignTokens.spacing2),

                  // Health status badge
                  Container(
                    padding: EdgeInsets.all(DesignTokens.spacing1),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getHealthIcon(status.overallHealth),
                      size: 16,
                      color: healthColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: DesignTokens.spacing4),

              // Progress bar with gradient
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            healthColor,
                            healthColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: healthColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: DesignTokens.spacing3),

              // Amount details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Spent
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                            .format(status.totalSpent),
                        style: AppTypographyExtended.statsValue.copyWith(
                          fontSize: 16,
                          color: healthColor,
                        ),
                      ),
                    ],
                  ),

                  // Progress percentage badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacing3,
                      vertical: DesignTokens.spacing1,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          healthColor.withValues(alpha: 0.15),
                          healthColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(
                        color: healthColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          progress > 0.9
                              ? Icons.trending_up
                              : Icons.trending_flat,
                          size: 14,
                          color: healthColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppTypographyExtended.metricLabel.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: healthColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Budget total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Budget',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                            .format(status.totalBudget),
                        style: AppTypographyExtended.statsValue.copyWith(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Remaining amount indicator
              if (status.remainingAmount != 0) ...[
                SizedBox(height: DesignTokens.spacing3),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing3,
                    vertical: DesignTokens.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: status.remainingAmount > 0
                        ? AppColorsExtended.statusNormal.withValues(alpha: 0.1)
                        : AppColorsExtended.statusOverBudget.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        status.remainingAmount > 0
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: status.remainingAmount > 0
                            ? AppColorsExtended.statusNormal
                            : AppColorsExtended.statusOverBudget,
                      ),
                      SizedBox(width: DesignTokens.spacing2),
                      Expanded(
                        child: Text(
                          status.remainingAmount > 0
                              ? '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(status.remainingAmount)} remaining'
                              : '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(-status.remainingAmount)} over budget',
                          style: AppTypographyExtended.metricLabel.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status.remainingAmount > 0
                                ? AppColorsExtended.statusNormal
                                : AppColorsExtended.statusOverBudget,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBudgetTypeIcon(budget_entity.BudgetType type) {
    switch (type) {
      case budget_entity.BudgetType.zeroBased:
        return Icons.account_balance_wallet;
      case budget_entity.BudgetType.fiftyThirtyTwenty:
        return Icons.pie_chart;
      case budget_entity.BudgetType.envelope:
        return Icons.mail;
      case budget_entity.BudgetType.custom:
        return Icons.tune;
    }
  }

  List<double> _generateTrendData(budget_entity.BudgetStatus status) {
    // Generate mock trend data - replace with actual historical spending data
    final values = <double>[];
    final dailyAverage = status.totalSpent / 7;

    for (int i = 0; i < 7; i++) {
      final variance = (i * 0.2) - 0.6;
      values.add((dailyAverage * (1 + variance)).clamp(0, double.infinity));
    }

    return values;
  }
}