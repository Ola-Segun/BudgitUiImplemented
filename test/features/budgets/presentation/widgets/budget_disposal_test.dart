import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_setup.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/enhanced_budget_card.dart';

void main() {
  late Budget testBudget;
  late ProviderContainer container;

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

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('Component Disposal Tests', () {
    testWidgets('should properly dispose of animation controllers', (WidgetTester tester) async {
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

      // Verify widget exists
      final finder = find.byType(EnhancedBudgetCard);
      expect(finder, findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // Widget should be disposed
      expect(find.byType(EnhancedBudgetCard), findsNothing);
    });

    testWidgets('should handle rapid widget disposal and recreation', (WidgetTester tester) async {
      // Create and dispose widget multiple times rapidly
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedBudgetCard(
                budget: testBudget.copyWith(name: 'Budget $i'),
                onTap: () {},
              ),
            ),
          ),
        );

        await tester.pump();

        // Dispose immediately
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Should not crash and should be properly disposed
      expect(find.byType(EnhancedBudgetCard), findsNothing);
    });

    testWidgets('should prevent memory leaks when widgets are disposed', (WidgetTester tester) async {
      // Create multiple widgets
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 10,
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

      expect(find.byType(EnhancedBudgetCard), findsWidgets);

      // Dispose all widgets
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // All widgets should be disposed
      expect(find.byType(EnhancedBudgetCard), findsNothing);
    });

    testWidgets('should handle disposal during ongoing animations', (WidgetTester tester) async {
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

      // Tap to potentially trigger animations
      await tester.tap(find.byType(EnhancedBudgetCard));
      await tester.pump();

      // Dispose immediately during potential animation
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // Should not crash
      expect(find.byType(EnhancedBudgetCard), findsNothing);
    });

    testWidgets('should properly dispose when parent widget is disposed', (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              key: key,
              child: EnhancedBudgetCard(
                budget: testBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);

      // Dispose parent container
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key), // Empty container
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Child should be disposed
      expect(find.byType(EnhancedBudgetCard), findsNothing);
    });

    testWidgets('should handle disposal with complex widget trees', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => EnhancedBudgetCard(
                      budget: testBudget.copyWith(
                        id: index.toString(),
                        name: 'Budget $index',
                      ),
                      onTap: () {},
                    ),
                    childCount: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsNWidgets(5));

      // Dispose entire scroll view
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // All widgets should be disposed
      expect(find.byType(EnhancedBudgetCard), findsNothing);
    });

    testWidgets('should prevent duplicate widget instances', (WidgetTester tester) async {
      // Create widget with same key multiple times
      final testKey = const Key('test_budget_card');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              key: testKey,
              budget: testBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(testKey), findsOneWidget);

      // Try to create another widget with same key
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EnhancedBudgetCard(
                  key: testKey,
                  budget: testBudget,
                  onTap: () {},
                ),
                EnhancedBudgetCard(
                  key: testKey, // Same key - should cause issues
                  budget: testBudget.copyWith(name: 'Duplicate'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // This should fail with duplicate keys error - expect it to throw
      await expectLater(
        () async => await tester.pumpAndSettle(),
        throwsA(isA<FlutterError>()),
      );
    });

    testWidgets('should handle disposal during state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
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

      // Trigger state change
      await tester.tap(find.byType(EnhancedBudgetCard));
      await tester.pump();

      // Dispose during state change
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // Should not crash
      expect(find.byType(EnhancedBudgetCard), findsNothing);
    });

    testWidgets('should properly dispose when navigator pops', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  body: EnhancedBudgetCard(
                    budget: testBudget,
                    onTap: () {},
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);

      // Simulate back button press
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Widget should be disposed
      expect(find.byType(EnhancedBudgetCard), findsNothing);
    });

    testWidgets('should handle disposal with retained state', (WidgetTester tester) async {
      final bucket = PageStorageBucket();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageStorage(
              bucket: bucket,
              child: EnhancedBudgetCard(
                budget: testBudget,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);

      // Dispose and recreate with same bucket
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageStorage(
              bucket: bucket,
              child: const SizedBox.shrink(), // Different widget
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Original widget should be disposed
      expect(find.byType(EnhancedBudgetCard), findsNothing);
    });

    testWidgets('should prevent memory leaks in list views', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
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

      // Scroll to create and dispose many widgets
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 2000));
      await tester.pumpAndSettle();

      // Should not have memory issues or crashes
      expect(find.byType(EnhancedBudgetCard), findsWidgets);
    });
  });
}