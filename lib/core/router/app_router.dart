import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/transactions/presentation/screens/transaction_list_screen.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transactions/presentation/screens/category_management_screen.dart';
import '../../features/transactions/presentation/widgets/add_transaction_bottom_sheet.dart';
import '../../features/transactions/presentation/providers/transaction_providers.dart';
import '../../features/budgets/presentation/screens/budget_list_screen.dart';
import '../../features/budgets/presentation/screens/budget_creation_screen.dart';
import '../../features/budgets/presentation/screens/budget_detail_screen.dart';
import '../../features/bills/presentation/screens/bills_dashboard_screen.dart';
import '../../features/bills/presentation/screens/bill_creation_screen.dart';
import '../../features/bills/presentation/screens/bill_detail_screen.dart';
import '../../features/goals/presentation/screens/goals_list_screen.dart';
import '../../features/goals/presentation/screens/goal_creation_screen.dart';
import '../../features/goals/presentation/screens/goal_detail_screen.dart';
import '../../features/insights/presentation/screens/insights_dashboard_screen.dart';
import '../../features/receipt_scanning/presentation/screens/receipt_scanning_screen.dart';
import '../../features/receipt_scanning/presentation/screens/receipt_review_screen.dart';
import '../../features/receipt_scanning/domain/entities/receipt_data.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/accounts/presentation/screens/accounts_overview_screen.dart';
import '../../features/accounts/presentation/screens/account_detail_screen.dart';
import '../../features/accounts/presentation/screens/bank_connection_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/settings/presentation/screens/help_center_screen.dart';
import '../../features/debt/presentation/screens/debt_dashboard_screen.dart';
import '../../features/recurring_incomes/presentation/screens/recurring_income_dashboard_screen.dart';
import '../../features/recurring_incomes/presentation/screens/recurring_income_detail_screen.dart';
import '../../features/recurring_incomes/presentation/screens/recurring_income_editing_screen.dart';
import '../../features/recurring_incomes/presentation/screens/recurring_income_creation_screen.dart';
import '../../features/recurring_incomes/presentation/screens/recurring_income_receipt_recording_screen.dart';
import '../widgets/app_bottom_sheet.dart';
import '../navigation/main_navigation_scaffold.dart';
import '../navigation/screens/home_dashboard_screen.dart';
import '../navigation/screens/more_menu_screen.dart';

/// App router configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Enable debug logging
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
            builder: (context, state) => const TransactionListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const _AddTransactionScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _TransactionDetailScreen(id: id);
                },
              ),
            ],
          ),

          // Budget routes
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const BudgetListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const _AddBudgetScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _BudgetDetailScreen(id: id);
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
                path: 'add',
                builder: (context, state) => const _AddGoalScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _GoalDetailScreen(id: id);
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
                builder: (context, state) => const _AccountsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _AccountDetailScreen(id: id);
                    },
                  ),
                  GoRoute(
                    path: 'bank-connection',
                    builder: (context, state) => const _BankConnectionScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'bills',
                builder: (context, state) => const _BillsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const _AddBillScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _BillDetailScreen(id: id);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'debt',
                builder: (context, state) => const _DebtScreen(),
              ),
              GoRoute(
                path: 'categories',
                builder: (context, state) => const _CategoriesScreen(),
              ),
              GoRoute(
                path: 'insights',
                builder: (context, state) => const _InsightsScreen(),
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const _NotificationCenterScreen(),
              ),
              GoRoute(
                path: 'help',
                builder: (context, state) => const _HelpCenterScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const _SettingsScreen(),
              ),
              GoRoute(
                path: 'incomes',
                builder: (context, state) => const _IncomesScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const _AddIncomeScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _IncomeDetailScreen(id: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return _EditIncomeScreen(incomeId: id);
                        },
                      ),
                      GoRoute(
                        path: 'receipt',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return _RecordIncomeReceiptScreen(incomeId: id);
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
    ),
  );
}

// Actual implemented screens

// Screen classes for sub-routes
class _AddTransactionScreen extends ConsumerWidget {
  const _AddTransactionScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show the add transaction bottom sheet immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppBottomSheet.show(
        context: context,
        child: AddTransactionBottomSheet(
          onSubmit: (transaction) async {
            await ref
                .read(transactionNotifierProvider.notifier)
                .addTransaction(transaction);

            if (context.mounted) {
              Navigator.pop(context); // Close bottom sheet
              context.go('/'); // Go back to home
            }
          },
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: const Center(child: Text('Loading...')),
    );
  }
}

class _TransactionDetailScreen extends StatelessWidget {
  const _TransactionDetailScreen({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return TransactionDetailScreen(transactionId: id);
  }
}

class _AddBudgetScreen extends ConsumerWidget {
  const _AddBudgetScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BudgetCreationScreen();
  }
}

class _BudgetDetailScreen extends StatelessWidget {
  const _BudgetDetailScreen({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BudgetDetailScreen(budgetId: id);
  }
}

class _AddGoalScreen extends ConsumerWidget {
  const _AddGoalScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const GoalCreationScreen();
  }
}

class _GoalDetailScreen extends StatelessWidget {
  const _GoalDetailScreen({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return GoalDetailScreen(goalId: id);
  }
}

class _BillsScreen extends ConsumerWidget {
  const _BillsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BillsDashboardScreen();
  }
}

class _AddBillScreen extends ConsumerWidget {
  const _AddBillScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BillCreationScreen();
  }
}

class _BillDetailScreen extends StatelessWidget {
  const _BillDetailScreen({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BillDetailScreen(billId: id);
  }
}

class _InsightsScreen extends ConsumerWidget {
  const _InsightsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const InsightsDashboardScreen();
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}

class _AccountsScreen extends ConsumerWidget {
  const _AccountsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AccountsOverviewScreen();
  }
}

class _AccountDetailScreen extends StatelessWidget {
  const _AccountDetailScreen({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return AccountDetailScreen(accountId: id);
  }
}

class _NotificationCenterScreen extends StatelessWidget {
  const _NotificationCenterScreen();

  @override
  Widget build(BuildContext context) {
    return const NotificationCenterScreen();
  }
}

class _HelpCenterScreen extends StatelessWidget {
  const _HelpCenterScreen();

  @override
  Widget build(BuildContext context) {
    return const HelpCenterScreen();
  }
}

class _BankConnectionScreen extends StatelessWidget {
  const _BankConnectionScreen();

  @override
  Widget build(BuildContext context) {
    return const BankConnectionScreen();
  }
}

class _DebtScreen extends ConsumerWidget {
  const _DebtScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DebtDashboardScreen();
  }
}

class _CategoriesScreen extends ConsumerWidget {
  const _CategoriesScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CategoryManagementScreen();
  }
}

class _IncomesScreen extends ConsumerWidget {
  const _IncomesScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const RecurringIncomeDashboardScreen();
  }
}

class _AddIncomeScreen extends ConsumerWidget {
  const _AddIncomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RecurringIncomeCreationScreen();
  }
}

class _IncomeDetailScreen extends StatelessWidget {
  const _IncomeDetailScreen({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return RecurringIncomeDetailScreen(incomeId: id);
  }
}

class _EditIncomeScreen extends StatelessWidget {
  const _EditIncomeScreen({required this.incomeId});

  final String incomeId;

  @override
  Widget build(BuildContext context) {
    return RecurringIncomeEditingScreen(incomeId: incomeId);
  }
}

class _RecordIncomeReceiptScreen extends StatelessWidget {
  const _RecordIncomeReceiptScreen({required this.incomeId});

  final String incomeId;

  @override
  Widget build(BuildContext context) {
    return RecurringIncomeReceiptRecordingScreen(incomeId: incomeId);
  }
}


class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Something went wrong'),
            if (error != null) Text('Error: $error'),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}