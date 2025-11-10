import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../budgets/presentation/widgets/budget_stats_row.dart'; // Reuse
import '../../../budgets/presentation/widgets/budget_bar_chart.dart'; // Reuse
import '../theme/income_theme_extended.dart';
import '../widgets/income_metric_cards.dart';
import '../../domain/entities/recurring_income.dart';
import '../providers/recurring_income_providers.dart';

/// Enhanced Recurring Income Dashboard with advanced visualizations
class RecurringIncomeDashboardEnhanced extends ConsumerStatefulWidget {
  const RecurringIncomeDashboardEnhanced({super.key});

  @override
  ConsumerState<RecurringIncomeDashboardEnhanced> createState() =>
      _RecurringIncomeDashboardEnhancedState();
}

class _RecurringIncomeDashboardEnhancedState
    extends ConsumerState<RecurringIncomeDashboardEnhanced> {

  @override
  Widget build(BuildContext context) {
    final incomeState = ref.watch(recurringIncomeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Recurring Incomes',
          style: AppTypography.h1.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => context.go('/more/incomes/add'),
              style: TextButton.styleFrom(
                backgroundColor: IncomeThemeExtended.incomePrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'New Income',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: incomeState.when(
        initial: () => const LoadingView(),
        loading: () => const LoadingView(),
        loaded: (incomes, summary) => _buildDashboard(incomes, summary),
        incomeLoaded: (income, status) => const LoadingView(),
        incomeSaved: (income) => const LoadingView(),
        receiptRecorded: (income) => const LoadingView(),
        incomeDeleted: () => const LoadingView(),
        error: (message, incomes, summary) => ErrorView(
          message: message,
          onRetry: () => ref.refresh(recurringIncomeNotifierProvider),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    List<RecurringIncome> incomes,
    RecurringIncomesSummary summary,
  ) {
    if (incomes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(recurringIncomeNotifierProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income Metric Cards
            IncomeMetricCards(summary: summary),
            SizedBox(height: AppDimensions.sectionGap),

            // Stats Overview (Reuse BudgetStatsRow pattern)
            _buildStatsOverview(summary),
            SizedBox(height: AppDimensions.sectionGap),

            // Monthly Income Chart
            _buildMonthlyIncomeChart(incomes),
            SizedBox(height: AppDimensions.sectionGap),

            // Upcoming Incomes
            if (summary.upcomingIncomes.isNotEmpty) ...[
              _buildUpcomingIncomesSection(summary.upcomingIncomes),
              SizedBox(height: AppDimensions.sectionGap),
            ],

            // All Incomes List
            _buildAllIncomesSection(incomes),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(RecurringIncomesSummary summary) {
    return BudgetStatsRow(
      allotted: summary.expectedAmount,
      used: summary.receivedThisMonth,
      remaining: summary.expectedAmount - summary.receivedThisMonth,
    ).animate()
      .fadeIn(duration: 400.ms, delay: 400.ms)
      .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms);
  }

  Widget _buildMonthlyIncomeChart(List<RecurringIncome> incomes) {
    final chartData = _generateMonthlyChartData(incomes);

    return BudgetBarChart(
      data: chartData,
      title: 'Monthly Income Tracking',
      period: 'Last 6 Months',
      height: 200,
    ).animate()
      .fadeIn(duration: 500.ms, delay: 500.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildUpcomingIncomesSection(List<RecurringIncomeStatus> upcomingIncomes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Upcoming Incomes',
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: IncomeThemeExtended.incomePrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${upcomingIncomes.length}',
                style: AppTypography.bodyMedium.copyWith(
                  color: IncomeThemeExtended.incomePrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 600.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 600.ms),

        const SizedBox(height: 16),

        ...upcomingIncomes.asMap().entries.map((entry) {
          final index = entry.key;
          final status = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _EnhancedIncomeStatusCard(status: status)
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 100)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 100))),
          );
        }),
      ],
    );
  }

  Widget _buildAllIncomesSection(List<RecurringIncome> incomes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'All Incomes',
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: IncomeThemeExtended.incomeSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${incomes.length}',
                style: AppTypography.bodyMedium.copyWith(
                  color: IncomeThemeExtended.incomeSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 400.ms, delay: 800.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 800.ms),

        const SizedBox(height: 16),

        ...incomes.asMap().entries.map((entry) {
          final index = entry.key;
          final income = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _EnhancedIncomeCard(income: income)
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 900 + (index * 100)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 900 + (index * 100))),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            decoration: BoxDecoration(
              color: IncomeThemeExtended.incomePrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: IncomeThemeExtended.incomePrimary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'No recurring incomes',
            style: AppTypography.h1.copyWith(
              fontSize: 24,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Add your first recurring income to\nstart tracking your regular earnings',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),
          SizedBox(height: AppDimensions.spacing5),
          ElevatedButton.icon(
            onPressed: () => context.go('/more/incomes/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Income'),
            style: ElevatedButton.styleFrom(
              backgroundColor: IncomeThemeExtended.incomePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 400.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  List<BudgetChartData> _generateMonthlyChartData(List<RecurringIncome> incomes) {
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final date = DateTime(now.year, now.month - 5 + i, 1);
      return DateFormat('MMM').format(date);
    });

    return List.generate(6, (index) {
      // Calculate actual income amounts for each month
      final monthlyTotal = incomes.fold(0.0, (sum, income) {
        // Simplified calculation - in real app, use income history
        return sum + (income.amount / 12);
      });

      return BudgetChartData(
        label: months[index],
        value: monthlyTotal,
        color: IncomeThemeExtended.incomePrimary,
      );
    });
  }
}

/// Enhanced Income Status Card
class _EnhancedIncomeStatusCard extends StatelessWidget {
  const _EnhancedIncomeStatusCard({
    required this.status,
  });

  final RecurringIncomeStatus status;

  Color _getUrgencyColor() {
    switch (status.urgency) {
      case RecurringIncomeUrgency.overdue:
        return IncomeThemeExtended.statusOverdue;
      case RecurringIncomeUrgency.expectedToday:
        return IncomeThemeExtended.incomeSecondary;
      case RecurringIncomeUrgency.expectedSoon:
        return IncomeThemeExtended.statusExpected;
      case RecurringIncomeUrgency.normal:
        return IncomeThemeExtended.incomePrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/more/incomes/${status.income.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: status.urgency == RecurringIncomeUrgency.overdue ? Border.all(
              color: urgencyColor.withValues(alpha: 0.3),
              width: 2,
            ) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Urgency Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  status.urgency == RecurringIncomeUrgency.overdue
                      ? Icons.warning
                      : Icons.trending_up,
                  size: 20,
                  color: urgencyColor,
                ),
              ),
              const SizedBox(width: 12),

              // Income Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.income.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: urgencyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.isOverdue
                              ? '${status.daysUntilExpected.abs()} days overdue'
                              : status.daysUntilExpected == 0
                                  ? 'Expected today'
                                  : 'In ${status.daysUntilExpected} days',
                          style: AppTypography.caption.copyWith(
                            color: urgencyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount & Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${status.income.amount.toStringAsFixed(0)}',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: urgencyColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.urgency.displayName,
                      style: AppTypography.caption.copyWith(
                        color: urgencyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Income Card
class _EnhancedIncomeCard extends StatelessWidget {
  const _EnhancedIncomeCard({
    required this.income,
  });

  final RecurringIncome income;

  Color _getStatusColor() {
    if (income.hasEnded) return AppColors.textSecondary;
    return IncomeThemeExtended.incomePrimary;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isActive = !income.hasEnded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/more/incomes/${income.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: !isActive ? Border.all(
              color: AppColors.borderSubtle,
              width: 1,
            ) : null,
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
              // Header Row
              Row(
                children: [
                  // Income Icon with Account Indicator
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isActive ? Icons.trending_up : Icons.stop_circle,
                          size: 20,
                          color: statusColor,
                        ),
                      ),
                      if (income.defaultAccountId != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.link,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Income Name & Frequency
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          income.name,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: isActive ? null : TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          income.frequency.displayName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Ended',
                      style: AppTypography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amount and Next Expected
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${income.amount.toStringAsFixed(0)}',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),

                  // Next Expected
                  if (income.nextExpectedDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Next Expected',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM dd').format(income.nextExpectedDate!),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer Info
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${income.incomeHistory.length} receipts',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (income.defaultAccountId != null) ...[
                    Icon(
                      Icons.account_balance_wallet,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Linked',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.link_off,
                      size: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Not linked',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}