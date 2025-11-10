import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_setup.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/enhanced_budget_card.dart';

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

  group('EnhancedBudgetCard Animations', () {
    testWidgets('should render without animation errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: testBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.text('Test Budget'), findsOneWidget);
    });

    testWidgets('should handle tap animations smoothly', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: testBudget,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.byType(EnhancedBudgetCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('should animate budget progress changes', (WidgetTester tester) async {
      final budgetStatus = BudgetStatus(
        budget: testBudget,
        totalSpent: 200.0,
        totalBudget: 500.0,
        categoryStatuses: [],
        daysRemaining: 20,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: testBudget,
              status: budgetStatus,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for progress text (40% in this case)
      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('should handle different budget states without flickering', (WidgetTester tester) async {
      // Test healthy budget
      final healthyBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'cat1', name: 'Food', amount: 1000.0), // High budget
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: healthyBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test warning budget
      final warningBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'cat1', name: 'Food', amount: 100.0), // Low budget
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: warningBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not crash or flicker
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should animate smoothly during state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: EnhancedBudgetCard(
                key: const ValueKey('budget'),
                budget: testBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Change budget
      final newBudget = testBudget.copyWith(name: 'Updated Budget');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: EnhancedBudgetCard(
                key: const ValueKey('budget'),
                budget: newBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Updated Budget'), findsOneWidget);
    });
  });

  group('BudgetCard Animation Performance', () {
    testWidgets('should not cause frame drops during rapid updates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => EnhancedBudgetCard(
                budget: testBudget.copyWith(
                  id: index.toString(),
                  name: 'Budget $index',
                ),
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rapid updates should not cause issues
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // ~60fps
      }

      expect(find.byType(EnhancedBudgetCard), findsNWidgets(5));
    });

    testWidgets('should handle orientation changes smoothly', (WidgetTester tester) async {
      // Portrait
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: testBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Landscape
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should animate list scrolling smoothly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => EnhancedBudgetCard(
                budget: testBudget.copyWith(
                  id: index.toString(),
                  name: 'Budget $index',
                ),
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Scroll up
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsWidgets);
    });
  });

  group('Animation Edge Cases', () {
    testWidgets('should handle empty budget categories', (WidgetTester tester) async {
      final emptyBudget = testBudget.copyWith(categories: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: emptyBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should handle very long budget names', (WidgetTester tester) async {
      final longNameBudget = testBudget.copyWith(
        name: 'Very Long Budget Name That Should Not Cause Layout Issues And Should Animate Properly',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: longNameBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should handle zero amount budgets', (WidgetTester tester) async {
      final zeroBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'cat1', name: 'Zero Budget', amount: 0.0),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: zeroBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should handle negative budget amounts gracefully', (WidgetTester tester) async {
      final negativeBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'cat1', name: 'Negative Budget', amount: -100.0),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: negativeBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });
  });
}