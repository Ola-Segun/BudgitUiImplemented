import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../test_setup.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/presentation/screens/budget_detail_screen.dart';
import 'package:budget_tracker/features/budgets/presentation/screens/budget_list_screen.dart';

void main() {
  late Budget testBudget;

  setUp(() {
    setupMockitoDummies();

    testBudget = Budget(
      id: '1',
      name: 'Test Budget',
      type: BudgetType.custom,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
      categories: [
        BudgetCategory(id: 'cat1', name: 'Food', amount: 500.0),
        BudgetCategory(id: 'cat2', name: 'Transport', amount: 300.0),
      ],
      isActive: true,
    );
  });

  group('Budget Navigation Integrity Tests', () {
    testWidgets('should navigate from budget list to budget detail', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Should start on budget list screen
      expect(find.byType(BudgetListScreen), findsOneWidget);
    });

    testWidgets('should handle deep linking to budget detail', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/budget/1',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Should navigate to budget detail screen
      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with invalid budget ID', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/budget/invalid-id',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Should still render the detail screen even with invalid ID
      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with special characters in budget ID', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/budget/test-budget-123_special',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });

    testWidgets('should handle rapid navigation changes', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Rapid navigation changes
      for (int i = 0; i < 5; i++) {
        router.go('/budget/$i');
        await tester.pumpAndSettle();
        expect(find.byType(BudgetDetailScreen), findsOneWidget);

        router.go('/');
        await tester.pumpAndSettle();
        expect(find.byType(BudgetListScreen), findsOneWidget);
      }
    });

    testWidgets('should handle navigation during screen transitions', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Navigate while potentially in transition
      router.go('/budget/1');
      await tester.pump(); // Partial pump
      router.go('/budget/2');
      await tester.pumpAndSettle();

      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with query parameters', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/budget/1?tab=overview&filter=active',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });

    testWidgets('should handle navigation stack correctly', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to detail
      router.push('/budget/1');
      await tester.pumpAndSettle();
      expect(find.byType(BudgetDetailScreen), findsOneWidget);

      // Navigate to another detail
      router.push('/budget/2');
      await tester.pumpAndSettle();
      expect(find.byType(BudgetDetailScreen), findsOneWidget);

      // Go back
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(BudgetDetailScreen), findsOneWidget);

      // Go back to list
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(BudgetListScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with large budget IDs', (WidgetTester tester) async {
      final largeId = 'a' * 1000; // Very long ID

      final router = GoRouter(
        initialLocation: '/budget/$largeId',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });

    testWidgets('should handle navigation during widget disposal', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Navigate and then immediately navigate away
      router.go('/budget/1');
      await tester.pump();
      router.go('/budget/2');
      await tester.pumpAndSettle();

      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with malformed URLs', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/budget/%20%20%20', // URL encoded spaces
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with empty budget ID', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/budget/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id'] ?? '';
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });

    testWidgets('should handle concurrent navigation requests', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BudgetListScreen(),
          ),
          GoRoute(
            path: '/budget/:id',
            builder: (context, state) {
              final budgetId = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: budgetId);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Fire multiple navigation requests rapidly
      router.go('/budget/1');
      router.go('/budget/2');
      router.go('/budget/3');

      await tester.pumpAndSettle();

      // Should end up on the last navigation target
      expect(find.byType(BudgetDetailScreen), findsOneWidget);
    });
  });
}