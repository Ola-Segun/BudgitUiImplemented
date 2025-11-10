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

  group('Budget Performance Tests', () {
    testWidgets('should render quickly without frame drops', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

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

      stopwatch.stop();
      final renderTime = stopwatch.elapsedMilliseconds;

      // Should render within reasonable time (less than 2 seconds for 20 items)
      expect(renderTime, lessThan(2000));

      // All widgets should be rendered (ListView may only render visible items)
      expect(find.byType(EnhancedBudgetCard), findsWidgets);
    });

    testWidgets('should handle rapid state changes without performance degradation', (WidgetTester tester) async {
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

      final initialRenderTime = Stopwatch()..start();

      // Simulate rapid updates
      for (int i = 0; i < 10; i++) {
        final updatedStatus = BudgetStatus(
          budget: testBudget,
          totalSpent: 200.0 + (i * 10),
          totalBudget: 500.0,
          categoryStatuses: [],
          daysRemaining: 20 - i,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedBudgetCard(
                budget: testBudget,
                status: updatedStatus,
                onTap: () {},
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 16)); // ~60fps
      }

      initialRenderTime.stop();
      final updateTime = initialRenderTime.elapsedMilliseconds;

      // Updates should be fast (less than 500ms for 10 updates)
      expect(updateTime, lessThan(500));

      // Should still display correctly
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should maintain smooth scrolling performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 50,
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

      final scrollStartTime = Stopwatch()..start();

      // Perform scroll operations
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();

      scrollStartTime.stop();
      final scrollTime = scrollStartTime.elapsedMilliseconds;

      // Scrolling should be smooth (less than 1 second)
      expect(scrollTime, lessThan(1000));

      // Should still have widgets visible
      expect(find.byType(EnhancedBudgetCard), findsWidgets);
    });

    testWidgets('should handle memory efficiently with large lists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) => EnhancedBudgetCard(
                budget: testBudget.copyWith(
                  id: index.toString(),
                  name: 'Budget $index',
                  categories: List.generate(
                    5,
                    (catIndex) => BudgetCategory(
                      id: 'cat_${index}_$catIndex',
                      name: 'Category $catIndex',
                      amount: 100.0 + catIndex * 50.0,
                    ),
                  ),
                ),
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle large lists without crashing
      expect(find.byType(EnhancedBudgetCard), findsWidgets);

      // Test scrolling through large list
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsWidgets);
    });

    testWidgets('should render consistently across different screen sizes', (WidgetTester tester) async {
      final budgetStatus = BudgetStatus(
        budget: testBudget,
        totalSpent: 250.0,
        totalBudget: 500.0,
        categoryStatuses: [],
        daysRemaining: 15,
      );

      // Test different screen sizes
      final screenSizes = [
        const Size(400, 600), // Small screen
        const Size(800, 1200), // Medium screen
        const Size(1200, 1800), // Large screen
      ];

      for (final size in screenSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EnhancedBudgetCard(
                  budget: testBudget,
                  status: budgetStatus,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should render without errors on all screen sizes
        expect(find.byType(EnhancedBudgetCard), findsOneWidget);
        expect(find.text('Test Budget'), findsOneWidget);
      }
    });

    testWidgets('should handle rapid widget rebuilds efficiently', (WidgetTester tester) async {
      int rebuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                rebuildCount++;
                return EnhancedBudgetCard(
                  budget: testBudget,
                  onTap: () => setState(() {}),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialRebuilds = rebuildCount;

      // Trigger multiple rebuilds
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byType(EnhancedBudgetCard));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      final finalRebuilds = rebuildCount;

      // Should not have excessive rebuilds
      expect(finalRebuilds - initialRebuilds, lessThan(20));
    });

    testWidgets('should maintain performance with complex budget data', (WidgetTester tester) async {
      final complexBudget = testBudget.copyWith(
        categories: List.generate(
          10,
          (index) => BudgetCategory(
            id: 'cat_$index',
            name: 'Very Long Category Name That Should Not Affect Performance $index',
            amount: 100.0 + index * 25.0,
            description: 'A very detailed description for this category that includes lots of text to test performance with larger data sets and ensure the widget can handle complex information without degrading performance.',
            icon: 'icon_$index',
            color: 0xFF000000 + index * 0x111111,
            subcategories: List.generate(5, (subIndex) => 'sub_$subIndex'),
          ),
        ),
      );

      final complexStatus = BudgetStatus(
        budget: complexBudget,
        totalSpent: 750.0,
        totalBudget: 1250.0,
        categoryStatuses: List.generate(
          10,
          (index) => CategoryStatus(
            categoryId: 'cat_$index',
            spent: 50.0 + index * 10.0,
            budget: 100.0 + index * 25.0,
            percentage: 0.5,
            status: BudgetHealth.healthy,
          ),
        ),
        daysRemaining: 10,
      );

      final renderTime = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: complexBudget,
              status: complexStatus,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      renderTime.stop();
      final time = renderTime.elapsedMilliseconds;

      // Should render complex data within reasonable time
      expect(time, lessThan(1000));

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      // The text might be truncated, so just check that the widget renders
      expect(find.text('Test Budget'), findsOneWidget);
    });
  });
}