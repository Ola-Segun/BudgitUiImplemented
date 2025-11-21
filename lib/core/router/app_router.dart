import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/transactions/presentation/screens/transaction_list_screen_enhanced.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transactions/presentation/screens/category_management_screen.dart';
import '../../features/budgets/presentation/screens/budget_list_screen.dart';
import '../../features/budgets/presentation/screens/budget_detail_screen.dart';
import '../../features/bills/presentation/screens/bills_dashboard_screen.dart';
import '../../features/bills/presentation/screens/bill_detail_screen.dart';
import '../../features/goals/presentation/screens/goals_list_screen.dart';
import '../../features/goals/presentation/screens/goal_detail_screen_enhanced.dart';
import '../../features/goals/presentation/screens/goal_template_selection_screen.dart';
import '../../features/insights/presentation/screens/insights_dashboard_screen.dart';
import '../../features/receipt_scanning/presentation/screens/receipt_scanning_screen.dart';
import '../../features/receipt_scanning/presentation/screens/receipt_review_screen.dart';
import '../../features/receipt_scanning/domain/entities/receipt_data.dart';
import '../../features/settings/presentation/screens/settings_screen_enhanced.dart';
import '../../features/accounts/presentation/screens/accounts_overview_screen.dart';
import '../../features/accounts/presentation/screens/account_detail_screen.dart';
import '../../features/accounts/presentation/screens/bank_connection_screen.dart';
import '../../features/accounts/presentation/screens/transfer_screen.dart';
import '../../features/accounts/presentation/screens/reconciliation_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen_enhanced.dart';
import '../../features/more/presentation/screens/help_center_screen_enhanced.dart';
import '../../features/debt/presentation/screens/debt_dashboard_screen.dart';
import '../../features/recurring_incomes/presentation/screens/recurring_income_dashboard_enhanced.dart';
import '../../features/recurring_incomes/presentation/screens/recurring_income_detail_screen.dart';
import '../../features/recurring_incomes/presentation/screens/recurring_income_receipt_recording_screen.dart';
import '../navigation/main_navigation_scaffold.dart';
import '../navigation/screens/home_dashboard_screen.dart';
import '../navigation/screens/more_menu_screen.dart';

/// App router configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainNavigationScaffold(child: child),
        routes: [
          // Home/Dashboard
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeDashboardScreen(),
            routes: [
              GoRoute(
                path: 'scan-receipt',
                builder: (context, state) => const ReceiptScanningScreen(),
              ),
              GoRoute(
                path: 'review-receipt',
                builder: (context, state) {
                  final receiptData = state.extra as ReceiptData?;
                  if (receiptData == null) {
                    return _ErrorScreen(error: Exception('No receipt data provided'));
                  }
                  return ReceiptReviewScreen(receiptData: receiptData);
                },
              ),
            ],
          ),

          // Transaction routes
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionListScreenEnhanced(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TransactionDetailScreen(transactionId: id);
                },
              ),
            ],
          ),

          // Budget routes - FIXED
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const BudgetListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BudgetDetailScreen(budgetId: id);
                },
              ),
            ],
          ),

          // Goals routes
          GoRoute(
            path: '/goals',
            builder: (context, state) => const GoalsListScreen(),
            routes: [
              GoRoute(
                path: 'templates',
                builder: (context, state) => const GoalTemplateSelectionScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return GoalDetailScreenEnhanced(goalId: id);
                },
              ),
            ],
          ),

          // More menu routes
          GoRoute(
            path: '/more',
            builder: (context, state) => const MoreMenuScreen(),
            routes: [
              GoRoute(
                path: 'accounts',
                builder: (context, state) => const AccountsOverviewScreen(),
                routes: [
                  GoRoute(
                    path: 'transfer',
                    builder: (context, state) {
                      final sourceAccountId = state.extra as String?;
                      return TransferScreen(sourceAccountId: sourceAccountId);
                    },
                  ),
                  GoRoute(
                    path: 'bank-connection',
                    builder: (context, state) => const BankConnectionScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return AccountDetailScreen(accountId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'reconcile',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ReconciliationScreen(accountId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'bills',
                builder: (context, state) => const BillsDashboardScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BillDetailScreen(billId: id);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'debt',
                builder: (context, state) => const DebtDashboardScreen(),
              ),
              GoRoute(
                path: 'categories',
                builder: (context, state) => const CategoryManagementScreen(),
              ),
              GoRoute(
                path: 'insights',
                builder: (context, state) => const InsightsDashboardScreen(),
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const NotificationCenterScreenEnhanced(),
              ),
              GoRoute(
                path: 'help',
                builder: (context, state) => const HelpCenterScreenEnhanced(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreenEnhanced(),
              ),
              GoRoute(
                path: 'incomes',
                builder: (context, state) => const RecurringIncomeDashboardEnhanced(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return RecurringIncomeDetailScreen(incomeId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'receipt',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return RecurringIncomeReceiptRecordingScreen(incomeId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(
      error: state.error,
      route: state.uri.toString(),
    ),
  );
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error, this.route});

  final Exception? error;
  final String? route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page Not Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The page you are looking for does not exist.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              if (route != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Route: $route',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Error: $error',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}