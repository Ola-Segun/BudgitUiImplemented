import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/recurring_income.dart';
import '../providers/recurring_income_providers.dart';
import '../widgets/edit_recurring_income_bottom_sheet.dart';
import '../widgets/create_recurring_income_bottom_sheet.dart';

/// Dashboard screen for managing recurring incomes
class RecurringIncomeDashboardScreen extends ConsumerStatefulWidget {
  const RecurringIncomeDashboardScreen({super.key});

  @override
  ConsumerState<RecurringIncomeDashboardScreen> createState() => _RecurringIncomeDashboardScreenState();
}

class _RecurringIncomeDashboardScreenState extends ConsumerState<RecurringIncomeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    developer.log('RecurringIncomeDashboardScreen built', name: 'Navigation');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Incomes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              developer.log('Showing add recurring income bottom sheet', name: 'Navigation');
              CreateRecurringIncomeBottomSheet.show(context);
            },
            tooltip: 'Add Income',
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final incomeState = ref.watch(recurringIncomeNotifierProvider);

          return incomeState.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (incomes, summary) => _buildLoadedView(incomes, summary),
            incomeLoaded: (income, status) => _buildLoadedView([income], const RecurringIncomesSummary(
              totalIncomes: 1,
              activeIncomes: 1,
              expectedThisMonth: 0,
              totalMonthlyAmount: 0,
              receivedThisMonth: 0,
              expectedAmount: 0,
              upcomingIncomes: [],
            )),
            incomeSaved: (income) => _buildLoadedView([income], const RecurringIncomesSummary(
              totalIncomes: 1,
              activeIncomes: 1,
              expectedThisMonth: 0,
              totalMonthlyAmount: 0,
              receivedThisMonth: 0,
              expectedAmount: 0,
              upcomingIncomes: [],
            )),
            receiptRecorded: (income) => _buildLoadedView([income], const RecurringIncomesSummary(
              totalIncomes: 1,
              activeIncomes: 1,
              expectedThisMonth: 0,
              totalMonthlyAmount: 0,
              receivedThisMonth: 0,
              expectedAmount: 0,
              upcomingIncomes: [],
            )),
            incomeDeleted: () => _buildLoadedView([], const RecurringIncomesSummary(
              totalIncomes: 0,
              activeIncomes: 0,
              expectedThisMonth: 0,
              totalMonthlyAmount: 0,
              receivedThisMonth: 0,
              expectedAmount: 0,
              upcomingIncomes: [],
            )),
            error: (message, incomes, summary) => _buildErrorView(message),
          );
        },
      ),
    );
  }

  Widget _buildLoadedView(List<RecurringIncome> incomes, RecurringIncomesSummary summary) {
    if (incomes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(recurringIncomeNotifierProvider.notifier).refresh();
      },
      child: ListView(
        padding: AppTheme.screenPaddingAll,
        children: [
          // Summary Cards
          _buildSummaryCards(summary),
          const SizedBox(height: 24),

          // Upcoming Incomes
          if (summary.upcomingIncomes.isNotEmpty) ...[
            _buildUpcomingSection(summary.upcomingIncomes),
            const SizedBox(height: 24),
          ],

          // All Incomes List
          _buildIncomesList(incomes),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(RecurringIncomesSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Incomes',
            value: summary.totalIncomes.toString(),
            icon: Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Monthly Total',
            value: '\$${summary.totalMonthlyAmount.toStringAsFixed(0)}',
            icon: Icons.trending_up,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(List<RecurringIncomeStatus> upcoming) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...upcoming.map((status) => _buildUpcomingIncomeCard(status)),
      ],
    );
  }

  Widget _buildUpcomingIncomeCard(RecurringIncomeStatus status) {
    final urgencyColor = switch (status.urgency) {
      RecurringIncomeUrgency.overdue => Colors.red,
      RecurringIncomeUrgency.expectedToday => Colors.orange,
      RecurringIncomeUrgency.expectedSoon => Colors.amber,
      RecurringIncomeUrgency.normal => Colors.green,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: urgencyColor.withOpacity(0.1),
          child: Icon(
            status.isOverdue ? Icons.warning : Icons.schedule,
            color: urgencyColor,
          ),
        ),
        title: Text(status.income.name),
        subtitle: Text(
          status.isOverdue
              ? '${status.daysUntilExpected.abs()} days overdue'
              : status.daysUntilExpected == 0
                  ? 'Expected today'
                  : 'In ${status.daysUntilExpected} days',
        ),
        trailing: Text(
          '\$${status.income.amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        onTap: () {
          developer.log('Navigating to recurring income detail: ${status.income.id}', name: 'Navigation');
          context.go('/more/incomes/${status.income.id}');
        },
      ),
    );
  }

  Widget _buildIncomesList(List<RecurringIncome> incomes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Incomes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...incomes.map((income) => _buildIncomeCard(income)),
      ],
    );
  }

  Widget _buildIncomeCard(RecurringIncome income) {
    final nextDate = income.nextExpectedDate;
    final isActive = !income.hasEnded;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.trending_up,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          income.name,
          style: TextStyle(
            decoration: isActive ? null : TextDecoration.lineThrough,
            color: isActive ? null : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${income.frequency.displayName} • \$${income.amount.toStringAsFixed(2)}'),
            if (nextDate != null)
              Text(
                'Next: ${DateFormat('MMM dd, yyyy').format(nextDate)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            developer.log('Showing edit recurring income bottom sheet: ${income.id}', name: 'Navigation');
            EditRecurringIncomeBottomSheet.show(context, incomeId: income.id);
          },
        ),
        onTap: () {
          developer.log('Navigating to recurring income detail: ${income.id}', name: 'Navigation');
          context.go('/more/incomes/${income.id}');
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No recurring incomes yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first recurring income to start tracking your regular earnings.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              developer.log('Showing add recurring income bottom sheet from empty state', name: 'Navigation');
              CreateRecurringIncomeBottomSheet.show(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Recurring Income'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading incomes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(recurringIncomeNotifierProvider.notifier).clearError(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}