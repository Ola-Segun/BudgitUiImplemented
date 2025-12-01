import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer' as developer;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/critical_alerts_banner.dart';
import '../../../core/widgets/enhanced_critical_alerts_banner.dart';
import '../../../features/transactions/presentation/widgets/scan_receipt_fab.dart';
import '../../../features/transactions/presentation/widgets/enhanced_add_transaction_bottom_sheet.dart';
import '../../../features/transactions/domain/entities/transaction.dart';
import '../../../features/transactions/presentation/providers/transaction_providers.dart';
import '../../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../../features/dashboard/domain/entities/dashboard_data.dart';
import '../../../features/dashboard/presentation/widgets/enhanced_dashboard_header.dart';
import '../../../features/dashboard/presentation/widgets/enhanced_financial_overview.dart';
import '../../../features/dashboard/presentation/widgets/enhanced_quick_actions.dart';
import '../../../features/dashboard/presentation/widgets/enhanced_budget_overview_widget.dart';
import '../../../features/dashboard/presentation/widgets/enhanced_upcoming_payments_widget.dart';
import '../../../features/bills/presentation/widgets/payment_recording_bottom_sheet.dart';
import '../../../features/bills/domain/entities/bill.dart';
import '../../../features/recurring_incomes/domain/entities/recurring_income.dart';
import '../../../features/recurring_incomes/presentation/widgets/receipt_recording_bottom_sheet.dart';
import 'package:go_router/go_router.dart';
import '../../../features/dashboard/presentation/widgets/enhanced_recent_transactions.dart';
import '../../../features/dashboard/presentation/widgets/enhanced_insights_card.dart';

/// Enhanced Home Dashboard Screen with modern UI
class HomeDashboardScreenEnhanced extends ConsumerStatefulWidget {
  const HomeDashboardScreenEnhanced({super.key});

  @override
  ConsumerState<HomeDashboardScreenEnhanced> createState() => _HomeDashboardScreenEnhancedState();
}

class _HomeDashboardScreenEnhancedState extends ConsumerState<HomeDashboardScreenEnhanced>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    developer.log('HomeDashboardScreenEnhanced initialized', name: 'HomeDashboard');
  }

  @override
  void dispose() {
    developer.log('HomeDashboardScreenEnhanced disposed', name: 'HomeDashboard');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    developer.log('Building HomeDashboardScreenEnhanced', name: 'HomeDashboard');
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            EnhancedDashboardHeader(
              selectedDate: _selectedDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),

            // Critical Alerts Banner
            const EnhancedCriticalAlertsBanner(),

            // Main Content
            Expanded(
              child: dashboardAsync.when(
                loading: () => const LoadingView(),
                error: (error, stack) {
                  developer.log('Dashboard error: $error', name: 'HomeDashboard', error: error);
                  return _buildErrorState(error);
                },
                data: (dashboardData) => _buildDashboardContent(dashboardData),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const ScanReceiptFAB(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error loading dashboard'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ref.refresh(dashboardDataProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardData dashboardData) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardDataProvider);
      },
      child: SingleChildScrollView(
        key: const PageStorageKey('dashboard_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Financial Overview with Circular Indicator
              EnhancedFinancialOverview(
                snapshot: dashboardData.financialSnapshot,
              ),
              SizedBox(height: AppDimensions.sectionGap),

              // Quick Actions
              EnhancedQuickActions(
                onIncomePressed: () => _showIncomeSheet(context),
                onExpensePressed: () => _showExpenseSheet(context),
                onTransferPressed: () {
                  context.go('/more/accounts/transfer');
                },
              ).animate()
                .fadeIn(duration: 400.ms, delay: 800.ms)
                .slideY(begin: 0.1, duration: 400.ms, delay: 800.ms),

              SizedBox(height: AppDimensions.sectionGap),

              // Budget Overview
              if (dashboardData.budgetOverview.isNotEmpty) ...[
                EnhancedBudgetOverviewWidget(
                  budgetOverview: dashboardData.budgetOverview,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 900.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 900.ms),
                SizedBox(height: AppDimensions.sectionGap),
              ],


              // Upcoming Payments & Income
              if (dashboardData.upcomingBills.isNotEmpty ||
                  dashboardData.upcomingIncomes.isNotEmpty) ...[
                EnhancedUpcomingPaymentsWidget(
                  upcomingBills: dashboardData.upcomingBills,
                  upcomingIncomes: dashboardData.upcomingIncomes,
                  onBillPaymentPressed: (bill) => _showPaymentBottomSheet(context, bill),
                  onIncomeReceiptPressed: (incomeStatus) => _showIncomeReceiptBottomSheet(context, incomeStatus),
                  onBillDetailPressed: (bill) => _navigateToBillDetail(context, bill),
                  onIncomeDetailPressed: (incomeStatus) => _navigateToIncomeDetail(context, incomeStatus),
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 1000.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 1000.ms),
                SizedBox(height: AppDimensions.sectionGap),
              ],

              // Recent Transactions
              if (dashboardData.recentTransactions.isNotEmpty) ...[
                EnhancedRecentTransactions(
                  recentTransactions: dashboardData.recentTransactions,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 1100.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 1100.ms),
                SizedBox(height: AppDimensions.sectionGap),
              ],

              // Insights
              if (dashboardData.insights.isNotEmpty) ...[
                EnhancedInsightsCard(
                  insights: dashboardData.insights,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 1200.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 1200.ms),
                SizedBox(height: AppDimensions.sectionGap),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showIncomeSheet(BuildContext context) async {
    if (!context.mounted) return;

    await EnhancedAddTransactionBottomSheet.show(
      context: context,
      initialType: TransactionType.income,
      onSubmit: (transaction) async {
        final success = await ref
            .read(transactionNotifierProvider.notifier)
            .addTransaction(transaction);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Income added successfully')),
          );
        }
      },
    );
  }

  Future<void> _showExpenseSheet(BuildContext context) async {
    if (!context.mounted) return;

    await EnhancedAddTransactionBottomSheet.show(
      context: context,
      initialType: TransactionType.expense,
      onSubmit: (transaction) async {
        final success = await ref
            .read(transactionNotifierProvider.notifier)
            .addTransaction(transaction);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully')),
          );
        }
      },
    );
  }

  Future<void> _showPaymentBottomSheet(BuildContext context, Bill bill) async {
    if (!context.mounted) return;

    try {
      await PaymentRecordingBottomSheet.show(
        context: context,
        bill: bill,
        onPaymentRecorded: () {
          // Refresh dashboard data after payment
          ref.invalidate(dashboardDataProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment recorded successfully')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording payment: $e')),
        );
      }
    }
  }

  Future<void> _showIncomeReceiptBottomSheet(BuildContext context, RecurringIncomeStatus incomeStatus) async {
    if (!context.mounted) return;

    try {
      await ReceiptRecordingBottomSheet.show(
        context: context,
        incomeId: incomeStatus.income.id,
        onReceiptRecorded: () {
          // Refresh dashboard data after receipt recording
          ref.invalidate(dashboardDataProvider);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error showing receipt recording: $e')),
        );
      }
    }
  }

  Future<void> _navigateToBillDetail(BuildContext context, Bill bill) async {
    if (!context.mounted) return;

    try {
      await context.push('/bills/${bill.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error navigating to bill details: $e')),
        );
      }
    }
  }

  Future<void> _navigateToIncomeDetail(BuildContext context, RecurringIncomeStatus incomeStatus) async {
    if (!context.mounted) return;

    try {
      await context.push('/more/incomes/${incomeStatus.income.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error navigating to income details: $e')),
        );
      }
    }
  }
}

/// Legacy Home/Dashboard screen - kept for backward compatibility
/// Use HomeDashboardScreenEnhanced for the new enhanced UI
class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    developer.log('HomeDashboardScreen initialized', name: 'HomeDashboard');
  }

  @override
  void dispose() {
    developer.log('HomeDashboardScreen disposed', name: 'HomeDashboard');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Redirect to enhanced version
    return const HomeDashboardScreenEnhanced();
  }
}

// Legacy code removed - using enhanced widgets instead

// Legacy code removed - using enhanced widgets instead

// Legacy code removed - using enhanced widgets instead

// Legacy code removed - using enhanced widgets instead

// Legacy code removed - using enhanced widgets instead

// Legacy code removed - using enhanced widgets instead

// Legacy code removed - using enhanced widgets instead

// Legacy code removed - using enhanced widgets instead

// Legacy code removed - using enhanced widgets instead