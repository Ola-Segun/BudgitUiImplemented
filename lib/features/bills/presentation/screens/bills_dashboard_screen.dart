import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../recurring_incomes/domain/entities/recurring_income.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_providers.dart';
import '../widgets/enhanced_bills_dashboard_header.dart';
import '../widgets/enhanced_bills_calendar_view.dart';
import '../widgets/enhanced_bill_status_banner.dart';
import '../widgets/enhanced_bills_stats_row.dart';
import '../widgets/enhanced_bills_bar_chart.dart';
import '../widgets/enhanced_account_filters.dart';
import '../widgets/enhanced_bill_card.dart';
import '../widgets/subscription_spotlight.dart';
import '../theme/bills_theme_extended.dart';

/// Dashboard screen for bills and subscriptions management
class BillsDashboardScreen extends ConsumerStatefulWidget {
  const BillsDashboardScreen({super.key});

  @override
  ConsumerState<BillsDashboardScreen> createState() => _BillsDashboardScreenState();
}

class _BillsDashboardScreenState extends ConsumerState<BillsDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountFilterId;
  bool _showLinkedOnly = false;
  String? _selectedIncomeAccountFilterId;
  bool _showIncomeLinkedOnly = false;
  BillsViewMode _viewMode = BillsViewMode.timeline;

  @override
  Widget build(BuildContext context) {
    developer.log('BillsDashboardScreen built', name: 'Navigation');
    final billState = ref.watch(billNotifierProvider);
    final upcomingBills = ref.watch(upcomingBillsProvider);
    final overdueCount = ref.watch(overdueBillsCountProvider);
    final totalMonthly = ref.watch(totalMonthlyBillsProvider);

    // Recurring income data
    final recurringIncomeSummary = ref.watch(recurringIncomesSummaryProvider);
    final upcomingIncomes = ref.watch(upcomingIncomesProvider);
    final expectedIncomesThisMonth = ref.watch(expectedIncomesThisMonthProvider);
    final totalMonthlyIncomes = ref.watch(totalMonthlyIncomesProvider);
    final receivedIncomesThisMonth = ref.watch(receivedIncomesThisMonthProvider);

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
                developer.log('Navigating to add bill screen', name: 'Navigation');
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
              .slideY(begin: -0.1, duration: BillsThemeExtended.billAnimationFast, curve: BillsThemeExtended.billAnimationCurve),

            // Main Content
            Expanded(
              child: billState.when(
                initial: () => const LoadingView(),
                loading: () => const LoadingView(),
                loaded: (bills, loadedSummary) => _buildDashboard(
                  context,
                  ref,
                  loadedSummary,
                  upcomingBills,
                  overdueCount,
                  totalMonthly,
                  recurringIncomeSummary,
                  upcomingIncomes,
                  expectedIncomesThisMonth,
                  totalMonthlyIncomes,
                  receivedIncomesThisMonth,
                ),
                error: (message, bills, errorSummary) => ErrorView(
                  message: message,
                  onRetry: () => ref.refresh(billNotifierProvider),
                ),
                billLoaded: (bill, status) => const SizedBox.shrink(), // Not used in dashboard
                billSaved: (bill) => const SizedBox.shrink(), // Not used in dashboard
                billDeleted: () => const SizedBox.shrink(), // Not used in dashboard
                paymentMarked: (bill) => const SizedBox.shrink(), // Not used in dashboard
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
    RecurringIncomesSummary? recurringIncomeSummary,
    List<RecurringIncomeStatus> upcomingIncomes,
    int expectedIncomesThisMonth,
    double totalMonthlyIncomes,
    double receivedIncomesThisMonth,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(billNotifierProvider.notifier).refresh();
      },
      child: _viewMode == BillsViewMode.calendar
          ? _buildCalendarView(context, ref, summary, upcomingBills, overdueCount, totalMonthly)
          : _buildTimelineView(context, ref, summary, upcomingBills, overdueCount, totalMonthly, recurringIncomeSummary, upcomingIncomes, expectedIncomesThisMonth, totalMonthlyIncomes, receivedIncomesThisMonth),
    );
  }

  Widget _buildTimelineView(
    BuildContext context,
    WidgetRef ref,
    BillsSummary summary,
    List<BillStatus> upcomingBills,
    int overdueCount,
    double totalMonthly,
    RecurringIncomesSummary? recurringIncomeSummary,
    List<RecurringIncomeStatus> upcomingIncomes,
    int expectedIncomesThisMonth,
    double totalMonthlyIncomes,
    double receivedIncomesThisMonth,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH, vertical: AppDimensions.screenPaddingV),
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
            .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationFast, curve: BillsThemeExtended.billAnimationCurve),

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
            monthlyData: [totalMonthly * 0.8, totalMonthly * 0.9, totalMonthly, totalMonthly * 1.1, totalMonthly * 0.95, totalMonthly * 1.05], // Sample data
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
            .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal, curve: BillsThemeExtended.billAnimationCurve),

          const SizedBox(height: 12),

          // Upcoming Bills Section
          _buildUpcomingBillsSection(context, upcomingBills),

          const SizedBox(height: 16),

          // All Bills Section
          _buildAllBillsSection(context, ref),

          // Quick Actions
          _buildQuickActions(context),
        ],
      );
  }

  Widget _buildCalendarView(
    BuildContext context,
    WidgetRef ref,
    BillsSummary summary,
    List<BillStatus> upcomingBills,
    int overdueCount,
    double totalMonthly,
  ) {
    return EnhancedBillsCalendarView(
      bills: ref.watch(billNotifierProvider).maybeWhen(
        loaded: (bills, summary) => bills,
        orElse: () => <Bill>[],
      ),
      selectedDate: _selectedDate,
      onDateSelected: (date) => setState(() => _selectedDate = date),
      onBillTap: (bill) {
        developer.log('Navigating to bill detail: ${bill.id}', name: 'Navigation');
        context.go('/more/bills/${bill.id}');
      },
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    BillsSummary summary,
    int overdueCount,
    double totalMonthly,
    RecurringIncomesSummary? recurringIncomeSummary,
    int expectedIncomesThisMonth,
    double totalMonthlyIncomes,
    double receivedIncomesThisMonth,
  ) {
    final billState = ref.watch(billNotifierProvider);
    final linkedBillsCount = billState.maybeWhen(
      loaded: (bills, loadedSummary) => bills.where((bill) => bill.accountId != null).length,
      orElse: () => 0,
    );
    final unlinkedBillsCount = summary.totalBills - linkedBillsCount;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Bills',
                summary.totalBills.toString(),
                Icons.receipt_long,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Overdue',
                overdueCount.toString(),
                Icons.warning,
                overdueCount > 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Monthly Total',
                '\$${totalMonthly.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Paid',
                '${summary.paidThisMonth}/${summary.dueThisMonth}',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Monthly Income',
                '\$${totalMonthlyIncomes.toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Received',
                '\$${receivedIncomesThisMonth.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Linked to Accounts',
                linkedBillsCount.toString(),
                Icons.account_balance_wallet,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Unlinked Bills',
                unlinkedBillsCount.toString(),
                Icons.link_off,
                unlinkedBillsCount > 0 ? Colors.orange : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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

  Widget _buildAccountFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final accountsAsync = ref.watch(filteredAccountsProvider);
            return accountsAsync.when(
              data: (accounts) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // All bills filter
          FilterChip(
            label: Text(
              'All Bills',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            selected: _selectedAccountFilterId == null && !_showLinkedOnly,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedAccountFilterId = null;
                  _showLinkedOnly = false;
                });
              }
            },
          ),
                    // Linked bills only filter
                    FilterChip(
                      label:  Text('Linked Only',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),),
                      selected: _showLinkedOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showLinkedOnly = selected;
                          if (!selected && _selectedAccountFilterId == null) {
                            // If unselecting linked only and no account selected, stay on all
                          }
                        });
                      },
                    ),
                    // Individual account filters
                    ...accounts.map((account) {
                      return FilterChip(
                        avatar: Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: Color(account.type.color),
                        ),
                        label: Text(account.displayName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),),
                        selected: _selectedAccountFilterId == account.id,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAccountFilterId = selected ? account.id : null;
                            _showLinkedOnly = false; // Clear linked only when selecting specific account
                          });
                        },
                      );
                    }),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error loading accounts: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingBillsSection(BuildContext context, List<BillStatus> upcomingBills) {
    final filteredUpcomingBills = upcomingBills.where((status) {
      if (_showLinkedOnly) {
        return status.bill.accountId != null;
      } else if (_selectedAccountFilterId != null) {
        return status.bill.accountId == _selectedAccountFilterId;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Bills',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (filteredUpcomingBills.isEmpty)
          _buildEmptyUpcomingBills(context)
        else
          ...filteredUpcomingBills.map((status) => _buildUpcomingBillCard(context, status)),
      ],
    );
  }

  Widget _buildAllBillsSection(BuildContext context, WidgetRef ref) {
    final billState = ref.watch(billNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getFilteredBillsTitle(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
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
              children: filteredBills.map((bill) => _buildAllBillCard(context, bill)).toList(),
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

  Widget _buildEmptyAllBills(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No bills yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first bill to start tracking payments',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllBillCard(BuildContext context, Bill bill) {
    return Slidable(
      key: ValueKey(bill.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showEditSheet(context, bill),
            backgroundColor: BillsThemeExtended.billStatsPrimary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _confirmDelete(context, ref, bill),
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: EnhancedBillCard(bill: bill),
    );
  }

  Widget _buildEmptyUpcomingBills(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No upcoming bills',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'All your bills are paid or no bills are due soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBillCard(BuildContext context, BillStatus status) {
    final color = _getUrgencyColor(status.urgency);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            Icons.receipt,
            color: color,
          ),
        ),
        title: Text(status.bill.name),
        subtitle: Text(
          '${status.daysUntilDue} days • \$${status.bill.amount.toStringAsFixed(2)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status.urgency.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () {
          developer.log('Navigating to bill detail: ${status.bill.id}', name: 'Navigation');
          context.go('/more/bills/${status.bill.id}');
        },
      ),
    );
  }

  Widget _buildUpcomingIncomesSection(BuildContext context, List<RecurringIncomeStatus> upcomingIncomes) {
    final filteredUpcomingIncomes = upcomingIncomes.where((status) {
      if (_showIncomeLinkedOnly) {
        return status.income.effectiveAccountId != null;
      } else if (_selectedIncomeAccountFilterId != null) {
        return status.income.effectiveAccountId == _selectedIncomeAccountFilterId;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Incomes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (filteredUpcomingIncomes.isEmpty)
          _buildEmptyUpcomingIncomes(context)
        else
          ...filteredUpcomingIncomes.map((status) => _buildUpcomingIncomeCard(context, status)),
      ],
    );
  }

  Widget _buildEmptyUpcomingIncomes(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.trending_up_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No upcoming incomes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'All your incomes are received or no incomes are expected soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingIncomeCard(BuildContext context, RecurringIncomeStatus status) {
    final color = _getIncomeUrgencyColor(status.urgency);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            Icons.trending_up,
            color: color,
          ),
        ),
        title: Text(status.income.name),
        subtitle: Text(
          '${status.daysUntilExpected} days • \$${status.income.amount.toStringAsFixed(2)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status.urgency.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () {
          developer.log('Navigating to income detail: ${status.income.id}', name: 'Navigation');
          context.go('/more/incomes/${status.income.id}');
        },
      ),
    );
  }

  Color _getIncomeUrgencyColor(RecurringIncomeUrgency urgency) {
    switch (urgency) {
      case RecurringIncomeUrgency.normal:
        return Colors.grey;
      case RecurringIncomeUrgency.expectedSoon:
        return Colors.blue;
      case RecurringIncomeUrgency.expectedToday:
        return Colors.green;
      case RecurringIncomeUrgency.overdue:
        return Colors.red.shade900;
    }
  }

  Widget _buildIncomeAccountFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Incomes by Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final accountsAsync = ref.watch(filteredAccountsProvider);
            return accountsAsync.when(
              data: (accounts) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // All incomes filter
                    FilterChip(
                      label: Text(
                        'All Incomes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      selected: _selectedIncomeAccountFilterId == null && !_showIncomeLinkedOnly,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedIncomeAccountFilterId = null;
                            _showIncomeLinkedOnly = false;
                          });
                        }
                      },
                    ),
                    // Linked incomes only filter
                    FilterChip(
                      label: Text('Linked Only',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),),
                      selected: _showIncomeLinkedOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showIncomeLinkedOnly = selected;
                          if (!selected && _selectedIncomeAccountFilterId == null) {
                            // If unselecting linked only and no account selected, stay on all
                          }
                        });
                      },
                    ),
                    // Individual account filters
                    ...accounts.map((account) {
                      return FilterChip(
                        avatar: Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: Color(account.type.color),
                        ),
                        label: Text(account.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),),
                        selected: _selectedIncomeAccountFilterId == account.id,
                        onSelected: (selected) {
                          setState(() {
                            _selectedIncomeAccountFilterId = selected ? account.id : null;
                            _showIncomeLinkedOnly = false; // Clear linked only when selecting specific account
                          });
                        },
                      );
                    }),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error loading accounts: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                'Add Bill',
                Icons.add,
                Colors.blue,
                () => context.go('/more/bills/add'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionButton(
                context,
                'Add Income',
                Icons.trending_up,
                Colors.teal,
                () => context.go('/more/incomes/add'), // Assuming this route exists
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                'View All Bills',
                Icons.list,
                Colors.green,
                () {
                  // Already on the bills dashboard, maybe scroll to top or refresh
                  // For now, just show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All bills shown above')),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionButton(
                context,
                'View All Incomes',
                Icons.account_balance_wallet,
                Colors.purple,
                () {
                  developer.log('Navigating to incomes dashboard from quick actions', name: 'Navigation');
                  context.go('/more/incomes');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Color _getUrgencyColor(BillUrgency urgency) {
    switch (urgency) {
      case BillUrgency.normal:
        return Colors.grey;
      case BillUrgency.dueSoon:
        return Colors.orange;
      case BillUrgency.dueToday:
        return Colors.red;
      case BillUrgency.overdue:
        return Colors.red.shade900;
    }
  }

  String _getFilteredBillsTitle() {
    if (_showLinkedOnly) {
      return 'Bills with Linked Accounts';
    } else if (_selectedAccountFilterId != null) {
      return 'Bills for Selected Account';
    } else {
      return 'All Bills';
    }
  }

  List<Bill> _filterBills(List<Bill> bills) {
    if (_showLinkedOnly) {
      return bills.where((bill) => bill.accountId != null).toList();
    } else if (_selectedAccountFilterId != null) {
      return bills.where((bill) => bill.accountId == _selectedAccountFilterId).toList();
    } else {
      return bills;
    }
  }

  Widget _buildEmptyFilteredBills(BuildContext context) {
    String message;
    String subtitle;

    if (_showLinkedOnly) {
      message = 'No bills with linked accounts';
      subtitle = 'Link accounts to your bills to see them here';
    } else if (_selectedAccountFilterId != null) {
      message = 'No bills for selected account';
      subtitle = 'Create bills linked to this account or change the filter';
    } else {
      return _buildEmptyAllBills(context);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.filter_list_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
              child: const Text('Show All Bills'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, Bill bill) {
    HapticFeedback.lightImpact();
    // Navigate to edit screen
    context.go('/more/bills/${bill.id}/edit');
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Bill bill) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text(
          'Are you sure you want to delete "${bill.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(billNotifierProvider.notifier)
          .deleteBill(bill.id);

      if (success && context.mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill deleted successfully')),
        );
      }
    }
  }
}