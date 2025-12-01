import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../bills/presentation/providers/bill_providers.dart';
import '../../../bills/presentation/widgets/create_bill_bottom_sheet.dart';
import '../../../recurring_incomes/presentation/providers/recurring_income_providers.dart';
import '../../../recurring_incomes/presentation/widgets/create_recurring_income_bottom_sheet.dart';
import '../../domain/entities/financial_obligation.dart';
import '../providers/financial_obligations_providers.dart';
import '../theme/obligations_theme.dart';
import '../theme/obligations_typography.dart';
import '../widgets/fixed_unified_obligations_header.dart' as fixed_header;
import '../widgets/fixed_cash_flow_circular_indicator.dart';
import '../widgets/fixed_smart_alert_banner.dart';
import '../widgets/fixed_cash_flow_stats_row.dart';
import '../widgets/obligation_timeline.dart';
import '../widgets/fixed_enhanced_obligation_card.dart';
import '../widgets/cash_flow_projection_chart.dart';

/// Unified dashboard combining bills and recurring income
class UnifiedObligationsDashboard extends ConsumerStatefulWidget {
  const UnifiedObligationsDashboard({super.key});

  @override
  ConsumerState<UnifiedObligationsDashboard> createState() => _UnifiedObligationsDashboardState();
}

class _UnifiedObligationsDashboardState extends ConsumerState<UnifiedObligationsDashboard> {
  late DateTime _selectedDate;
  fixed_header.ObligationFilter _activeFilter = fixed_header.ObligationFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    developer.log('UnifiedObligationsDashboard initialized', name: 'Obligations');
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building UnifiedObligationsDashboard', name: 'Obligations');
    final obligations = ref.watch(financialObligationsProvider);
    final summary = ref.watch(obligationsSummaryProvider);

    return Scaffold(
      backgroundColor: ObligationsTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Unified Header
            fixed_header.UnifiedObligationsHeader(
              selectedDate: _selectedDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              activeFilter: _activeFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _activeFilter = filter;
                });
              },
              overdueCount: summary?.overdueCount ?? 0,
              dueTodayCount: summary?.dueTodayCount ?? 0,
            ),

            // Main Content
            Expanded(
              child: _buildDashboard(obligations, summary!),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildDashboard(
    List<FinancialObligation> obligations,
    FinancialObligationsSummary? summary,
  ) {
    if (summary == null) {
      return const LoadingView();
    }

    final filteredObligations = _filterObligations(obligations);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(financialObligationsProvider);
        ref.invalidate(obligationsSummaryProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Alert Banner
            if (summary.overdueCount > 0 || summary.dueTodayCount > 0 || summary.netCashFlow < 0)
              FixedSmartAlertBanner(summary: summary),

            if (summary.overdueCount > 0 || summary.dueTodayCount > 0 || summary.netCashFlow < 0)
              const SizedBox(height: 16),

            // Circular Cash Flow Indicator
            FixedCashFlowCircularIndicator(
              monthlyIncome: summary.monthlyIncomeTotal,
              monthlyBills: summary.monthlyBillTotal,
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 16),

            // Cash Flow Stats Row
            FixedCashFlowStatsRow(summary: summary),

            const SizedBox(height: 16),

            // Timeline of upcoming obligations
            if (filteredObligations
                .where((o) => o.daysUntilNext >= 0 && o.daysUntilNext <= 30)
                .isNotEmpty) ...[
              ObligationTimeline(obligations: filteredObligations),
              const SizedBox(height: 16),
            ],

            // Cash Flow Projection Chart
            CashFlowProjectionChart(
              obligations: obligations,
              summary: summary,
            ).animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.1, duration: 500.ms, delay: 400.ms),

            const SizedBox(height: 16),

            // All Obligations List
            _buildObligationsList(filteredObligations),
          ],
        ),
      ),
    );
  }

  Widget _buildObligationsList(List<FinancialObligation> obligations) {
    if (obligations.isEmpty) {
      return _buildEmptyState();
    }

    // Group by urgency
    final overdue = obligations.where((o) => o.isOverdue).toList();
    final dueToday = obligations.where((o) => o.isDueToday).toList();
    final dueSoon = obligations.where((o) => o.isDueSoon).toList();
    final upcoming = obligations.where((o) => o.isUpcoming).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          _getSectionTitle(),
          style: ObligationsTypography.sectionTitle,
        ).animate()
          .fadeIn(duration: 400.ms, delay: 500.ms)
          .slideX(begin: -0.1, duration: 400.ms, delay: 500.ms),

        const SizedBox(height: 14),

        // Overdue section
        if (overdue.isNotEmpty) ...[
          _buildSectionLabel('Overdue', overdue.length, const Color(0xFFDC2626)),
          const SizedBox(height: 12),
          ...overdue.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FixedEnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 600 + (index * 50)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 600 + (index * 50))),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Due today section
        if (dueToday.isNotEmpty) ...[
          _buildSectionLabel('Due Today', dueToday.length, const Color(0xFFEA580C)),
          const SizedBox(height: 12),
          ...dueToday.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FixedEnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 50)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 700 + (index * 50))),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Due soon section
        if (dueSoon.isNotEmpty) ...[
          _buildSectionLabel('Due Soon', dueSoon.length, const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          ...dueSoon.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FixedEnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 800 + (index * 50)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 800 + (index * 50))),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Upcoming section
        if (upcoming.isNotEmpty) ...[
          _buildSectionLabel('Upcoming', upcoming.length, const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          ...upcoming.asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FixedEnhancedObligationCard(
                obligation: obligation,
                onEdit: () => _editObligation(obligation),
                onDelete: () => _deleteObligation(obligation),
                onMarkComplete: () => _markComplete(obligation),
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 900 + (index * 50)))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 900 + (index * 50))),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.6)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: ObligationsTypography.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '$count',
            style: ObligationsTypography.caption.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ObligationsTheme.trackfinzPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_outlined,
                size: 56,
                color: ObligationsTheme.trackfinzPrimary,
              ),
            ).animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'No obligations found',
              style: ObligationsTypography.bodyLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ).animate()
              .fadeIn(duration: 300.ms, delay: 200.ms),
            const SizedBox(height: 10),
            Text(
              'Add bills and income sources to\ntrack your cash flow',
              style: ObligationsTypography.bodyMedium.copyWith(
                color: ObligationsTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 300.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ObligationsTheme.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ObligationsTheme.trackfinzPrimary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddObligationSheet(),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Add',
                  style: ObligationsTypography.label.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 1000.ms)
      .slideY(
        begin: 0.1,
        duration: 300.ms,
        delay: 1000.ms,
        curve: Curves.elasticOut,
      );
  }

  List<FinancialObligation> _filterObligations(List<FinancialObligation> obligations) {
    switch (_activeFilter) {
      case fixed_header.ObligationFilter.all:
        return obligations;
      case fixed_header.ObligationFilter.bills:
        return obligations.where((o) => o.type == ObligationType.bill).toList();
      case fixed_header.ObligationFilter.income:
        return obligations.where((o) => o.type == ObligationType.income).toList();
      case fixed_header.ObligationFilter.overdue:
        return obligations.where((o) => o.isOverdue || o.isDueToday).toList();
      case fixed_header.ObligationFilter.upcoming:
        return obligations.where((o) => o.isUpcoming || o.isDueSoon).toList();
      case fixed_header.ObligationFilter.automated:
        return obligations.where((o) => o.isAutomated == true).toList();
    }
  }

  String _getSectionTitle() {
    switch (_activeFilter) {
      case fixed_header.ObligationFilter.all:
        return 'All Obligations';
      case fixed_header.ObligationFilter.bills:
        return 'Bills';
      case fixed_header.ObligationFilter.income:
        return 'Income Sources';
      case fixed_header.ObligationFilter.overdue:
        return 'Urgent Items';
      case fixed_header.ObligationFilter.upcoming:
        return 'Upcoming';
      case fixed_header.ObligationFilter.automated:
        return 'Automated';
    }
  }

  void _showAddObligationSheet() {
    // Show bottom sheet to choose bill or income
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddObligationTypeSheet(
        onTypeSelected: (type) {
          Navigator.pop(context);
          if (type == ObligationType.bill) {
            // Show bill creation bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const CreateBillBottomSheet(),
            );
          } else {
            // Show income creation bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const CreateRecurringIncomeBottomSheet(),
            );
          }
        },
      ),
    );
  }

  void _editObligation(FinancialObligation obligation) {
    final isBill = obligation.type == ObligationType.bill;
    final route = isBill
        ? '/more/cash-flow/bills/${obligation.id}'
        : '/more/cash-flow/incomes/${obligation.id}';
    context.go(route);
  }

  Future<void> _deleteObligation(FinancialObligation obligation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Obligation'),
        content: Text(
          'Are you sure you want to delete "${obligation.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Delete obligation through provider
      final isBill = obligation.type == ObligationType.bill;
      if (isBill) {
        await ref.read(billNotifierProvider.notifier).deleteBill(obligation.id);
      } else {
        await ref.read(recurringIncomeNotifierProvider.notifier).deleteIncome(obligation.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obligation deleted')),
      );
    }
  }

  void _markComplete(FinancialObligation obligation) {
    final isBill = obligation.type == ObligationType.bill;
    final route = isBill
        ? '/more/cash-flow/bills/${obligation.id}'
        : '/more/cash-flow/incomes/${obligation.id}';
    context.go(route);
  }
}

class _AddObligationTypeSheet extends StatelessWidget {
  const _AddObligationTypeSheet({
    required this.onTypeSelected,
  });

  final ValueChanged<ObligationType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ObligationsTheme.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Add New Obligation',
            style: ObligationsTypography.bodyLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the type of obligation to add',
            style: ObligationsTypography.bodyMedium.copyWith(
              color: ObligationsTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Bill option
          _TypeOption(
            icon: Icons.arrow_upward,
            label: 'Bill',
            description: 'Recurring payment or expense',
            color: ObligationsTheme.statusCritical,
            onTap: () => onTypeSelected(ObligationType.bill),
          ),
          const SizedBox(height: 12),

          // Income option
          _TypeOption(
            icon: Icons.arrow_downward,
            label: 'Income',
            description: 'Recurring income or revenue',
            color: ObligationsTheme.statusNormal,
            onTap: () => onTypeSelected(ObligationType.income),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: ObligationsTypography.bodyMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: ObligationsTypography.bodySmall.copyWith(
                        color: ObligationsTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}