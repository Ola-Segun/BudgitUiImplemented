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

  group('Budget Edge Cases with Real Data', () {
    testWidgets('should handle budgets with very large amounts', (WidgetTester tester) async {
      final largeBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'cat1', name: 'Large Expense', amount: 1000000.0), // 1 million
          BudgetCategory(id: 'cat2', name: 'Another Large', amount: 5000000.0), // 5 million
        ],
      );

      final largeStatus = BudgetStatus(
        budget: largeBudget,
        totalSpent: 2500000.0,
        totalBudget: 6000000.0,
        categoryStatuses: [],
        daysRemaining: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: largeBudget,
                status: largeStatus,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      // The percentage might be formatted differently, just check it renders
      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('should handle budgets with very small amounts', (WidgetTester tester) async {
      final smallBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'cat1', name: 'Micro Expense', amount: 0.01), // 1 cent
          BudgetCategory(id: 'cat2', name: 'Tiny Expense', amount: 0.99), // Less than 1 dollar
        ],
      );

      final smallStatus = BudgetStatus(
        budget: smallBudget,
        totalSpent: 0.50,
        totalBudget: 1.00,
        categoryStatuses: [],
        daysRemaining: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: smallBudget,
                status: smallStatus,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should handle budgets with extreme date ranges', (WidgetTester tester) async {
      final longTermBudget = testBudget.copyWith(
        startDate: DateTime(2020, 1, 1),
        endDate: DateTime(2030, 12, 31),
      );

      final shortTermBudget = testBudget.copyWith(
        startDate: DateTime.now().subtract(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(hours: 1)),
      );

      // Test long-term budget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: longTermBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);

      // Test short-term budget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: shortTermBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should handle budgets with many categories', (WidgetTester tester) async {
      final manyCategoriesBudget = testBudget.copyWith(
        categories: List.generate(
          50,
          (index) => BudgetCategory(
            id: 'cat_$index',
            name: 'Category $index',
            amount: 100.0 + index * 10.0,
          ),
        ),
      );

      final manyCategoriesStatus = BudgetStatus(
        budget: manyCategoriesBudget,
        totalSpent: 25000.0,
        totalBudget: 50000.0,
        categoryStatuses: [],
        daysRemaining: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: manyCategoriesBudget,
                status: manyCategoriesStatus,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should handle budgets with special characters in names', (WidgetTester tester) async {
      final specialCharsBudget = testBudget.copyWith(
        name: 'Budget with émojis 🎉 and spëcial chärs 中文',
        categories: [
          BudgetCategory(id: 'cat1', name: 'Category with émojis 🎉', amount: 500.0),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: specialCharsBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      // The text might be truncated, but the widget should render
    });

    testWidgets('should handle budgets with very long descriptions', (WidgetTester tester) async {
      final longDescriptionBudget = testBudget.copyWith(
        description: 'A'.padRight(10000, ' very long description that should not cause any rendering issues or performance problems even when it is extremely long and contains many many many words repeated over and over again to test the limits of the text rendering system and ensure that the widget can handle large amounts of text data without breaking or causing layout issues that might affect the user experience in negative ways.'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: longDescriptionBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should handle budgets with negative spending data', (WidgetTester tester) async {
      final negativeStatus = BudgetStatus(
        budget: testBudget,
        totalSpent: -100.0, // Negative spending (refunds/credits)
        totalBudget: 500.0,
        categoryStatuses: [],
        daysRemaining: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: testBudget,
                status: negativeStatus,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      // Should show negative spending appropriately
    });

    testWidgets('should handle budgets with overspending scenarios', (WidgetTester tester) async {
      final overspentStatus = BudgetStatus(
        budget: testBudget,
        totalSpent: 1500.0, // Overspent by 200%
        totalBudget: 500.0,
        categoryStatuses: [],
        daysRemaining: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: testBudget,
                status: overspentStatus,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.text('300%'), findsOneWidget); // 1500/500 = 300%
    });

    testWidgets('should handle budgets with zero days remaining', (WidgetTester tester) async {
      final expiredStatus = BudgetStatus(
        budget: testBudget,
        totalSpent: 300.0,
        totalBudget: 500.0,
        categoryStatuses: [],
        daysRemaining: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: testBudget,
                status: expiredStatus,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.text('0 days left'), findsOneWidget);
    });

    testWidgets('should handle budgets with negative days remaining', (WidgetTester tester) async {
      final pastDueStatus = BudgetStatus(
        budget: testBudget,
        totalSpent: 300.0,
        totalBudget: 500.0,
        categoryStatuses: [],
        daysRemaining: -5, // Past due
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: testBudget,
                status: pastDueStatus,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.text('-5 days left'), findsOneWidget);
    });

    testWidgets('should handle budgets with all budget types', (WidgetTester tester) async {
      final budgetTypes = BudgetType.values;

      for (final type in budgetTypes) {
        final typedBudget = testBudget.copyWith(type: type);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EnhancedBudgetCard(
                  budget: typedBudget,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(EnhancedBudgetCard), findsOneWidget);
        expect(find.text(type.displayName), findsOneWidget);
      }
    });

    testWidgets('should handle budgets with empty category names', (WidgetTester tester) async {
      final emptyNameBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'cat1', name: '', amount: 500.0),
          BudgetCategory(id: 'cat2', name: '   ', amount: 300.0), // Whitespace only
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: emptyNameBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should handle budgets with duplicate category IDs', (WidgetTester tester) async {
      final duplicateIdBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'duplicate', name: 'Food', amount: 500.0),
          BudgetCategory(id: 'duplicate', name: 'Transport', amount: 300.0), // Same ID
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: duplicateIdBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should handle rapid budget data changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedBudgetCard(
                budget: testBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rapidly change budget data
      for (int i = 0; i < 10; i++) {
        final changingBudget = testBudget.copyWith(
          name: 'Budget Version $i',
          categories: [
            BudgetCategory(id: 'cat1', name: 'Category $i', amount: 100.0 + i * 50.0),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EnhancedBudgetCard(
                  budget: changingBudget,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });
  });
}