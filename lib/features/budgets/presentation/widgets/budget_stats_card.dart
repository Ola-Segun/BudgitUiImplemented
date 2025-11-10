import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/budget_providers.dart';

/// Card widget for displaying budget statistics
class BudgetStatsCard extends ConsumerWidget {
  const BudgetStatsCard({
    super.key,
    this.stats,
  });

  final BudgetStats? stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use provided stats or fetch from provider
    final asyncStats = stats != null
        ? AsyncValue.data(stats!)
        : ref.watch(budgetStatsProvider);

    return asyncStats.when(
      data: (stats) => _buildCard(context, stats),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text('Error loading budget stats: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, BudgetStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Key Metrics Row
            Row(
              children: [
                _buildMetric(
                  context,
                  'Total Budgets',
                  stats.totalBudgets.toString(),
                  Icons.account_balance_wallet,
                ),
                const SizedBox(width: 16),
                _buildMetric(
                  context,
                  'Active',
                  stats.activeBudgets.toString(),
                  Icons.play_circle_outline,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Health Status Indicators
            if (stats.activeBudgets > 0) ...[
              Text(
                'Budget Health',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),

              // Health bars
              _buildHealthBar(
                context,
                'Healthy',
                stats.healthyBudgets,
                stats.activeBudgets,
                const Color(0xFF10B981),
              ),
              const SizedBox(height: 4),
              _buildHealthBar(
                context,
                'Warning',
                stats.warningBudgets,
                stats.activeBudgets,
                const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 4),
              _buildHealthBar(
                context,
                'Critical',
                stats.criticalBudgets,
                stats.activeBudgets,
                const Color(0xFFEF4444),
              ),
              const SizedBox(height: 4),
              _buildHealthBar(
                context,
                'Over Budget',
                stats.overBudgetCount,
                stats.activeBudgets,
                const Color(0xFFDC2626),
              ),
            ],

            const SizedBox(height: 16),

            // Financial Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Budgeted',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            Text(
                              NumberFormat.currency(symbol: '\$').format(stats.totalBudgetAmount),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Active Budgets',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            Text(
                              NumberFormat.currency(symbol: '\$').format(stats.activeBudgetAmount),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Costs',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: stats.totalActiveCosts),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Text(
                                  NumberFormat.currency(symbol: '\$').format(value),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: stats.totalActiveCosts > stats.activeBudgetAmount * 0.9
                                            ? Colors.red
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Usage Rate',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: stats.activeCostsPercentage),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: value > 90
                                            ? Colors.red
                                            : value > 75
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color ?? Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBar(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 1,
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}