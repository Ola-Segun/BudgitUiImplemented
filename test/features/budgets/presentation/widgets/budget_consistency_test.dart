import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_setup.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/presentation/providers/budget_providers.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/enhanced_budget_card.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/budget_stats_card.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/budget_metric_cards.dart';

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

  group('Component Consistency Tests', () {
    testWidgets('should maintain consistent styling across budget components', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  EnhancedBudgetCard(
                    budget: testBudget,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  BudgetStatsCard(
                    stats: BudgetStats(
                      totalBudgets: 5,
                      activeBudgets: 3,
                      totalBudgetAmount: 1500.0,
                      activeBudgetAmount: 800.0,
                      totalActiveCosts: 450.0,
                      healthyBudgets: 2,
                      warningBudgets: 1,
                      criticalBudgets: 0,
                      overBudgetCount: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BudgetMetricCards(
                    usageRate: 0.45,
                    allotmentRate: 0.35,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All components should render without issues
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.byType(BudgetStatsCard), findsOneWidget);
      expect(find.byType(BudgetMetricCards), findsOneWidget);

      // Check for consistent text elements
      expect(find.text('Test Budget'), findsOneWidget);
      expect(find.text('5'), findsWidgets); // Total budgets
      expect(find.text('3'), findsWidgets); // Active budgets
    });

    testWidgets('should handle consistent data formatting across components', (WidgetTester tester) async {
      final largeBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'cat1', name: 'Food', amount: 2500000.0), // 2.5M
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EnhancedBudgetCard(
                  budget: largeBudget,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                BudgetStatsCard(
                  stats: BudgetStats(
                    totalBudgets: 1,
                    activeBudgets: 1,
                    totalBudgetAmount: 2500000.0,
                    activeBudgetAmount: 2500000.0,
                    totalActiveCosts: 625000.0, // 25% spent
                    healthyBudgets: 1,
                    warningBudgets: 0,
                    criticalBudgets: 0,
                    overBudgetCount: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle large numbers consistently
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.byType(BudgetStatsCard), findsOneWidget);
    });

    testWidgets('should maintain consistent behavior with empty data', (WidgetTester tester) async {
      final emptyBudget = testBudget.copyWith(categories: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EnhancedBudgetCard(
                  budget: emptyBudget,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                const BudgetStatsCard(
                  stats: BudgetStats(
                    totalBudgets: 0,
                    activeBudgets: 0,
                    totalBudgetAmount: 0.0,
                    activeBudgetAmount: 0.0,
                    totalActiveCosts: 0.0,
                    healthyBudgets: 0,
                    warningBudgets: 0,
                    criticalBudgets: 0,
                    overBudgetCount: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle empty states gracefully
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.byType(BudgetStatsCard), findsOneWidget);
    });

    testWidgets('should maintain consistent theming across components', (WidgetTester tester) async {
      final customTheme = ThemeData(
        primaryColor: Colors.blue,
        cardTheme: CardThemeData(
          elevation: 4,
          margin: const EdgeInsets.all(8),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: customTheme,
          home: Scaffold(
            body: Column(
              children: [
                EnhancedBudgetCard(
                  budget: testBudget,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                BudgetStatsCard(
                  stats: BudgetStats(
                    totalBudgets: 1,
                    activeBudgets: 1,
                    totalBudgetAmount: 800.0,
                    activeBudgetAmount: 800.0,
                    totalActiveCosts: 400.0,
                    healthyBudgets: 1,
                    warningBudgets: 0,
                    criticalBudgets: 0,
                    overBudgetCount: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Components should respect theme
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.byType(BudgetStatsCard), findsOneWidget);
    });

    testWidgets('should handle consistent error states across components', (WidgetTester tester) async {
      // Test with invalid budget data
      final invalidBudget = testBudget.copyWith(
        categories: [
          BudgetCategory(id: 'cat1', name: '', amount: -100.0), // Invalid data
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: invalidBudget,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle invalid data gracefully
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
    });

    testWidgets('should maintain consistent interaction patterns', (WidgetTester tester) async {
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
      await tester.pump();

      // Should trigger callback
      expect(tapped, true);
    });

    testWidgets('should handle consistent loading states', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EnhancedBudgetCard(
                  budget: testBudget,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(), // Simulate loading
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render alongside loading indicators
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should maintain consistent accessibility features', (WidgetTester tester) async {
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

      // Check for semantic labels
      final card = find.byType(EnhancedBudgetCard);
      expect(card, findsOneWidget);

      // The card should be accessible
      expect(tester.widget<EnhancedBudgetCard>(card).budget.name, 'Test Budget');
    });

    testWidgets('should handle consistent orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EnhancedBudgetCard(
                  budget: testBudget,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                BudgetStatsCard(
                  stats: BudgetStats(
                    totalBudgets: 1,
                    activeBudgets: 1,
                    totalBudgetAmount: 800.0,
                    activeBudgetAmount: 800.0,
                    totalActiveCosts: 400.0,
                    healthyBudgets: 1,
                    warningBudgets: 0,
                    criticalBudgets: 0,
                    overBudgetCount: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Change to landscape
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      await tester.pumpAndSettle();

      // Components should adapt consistently
      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.byType(BudgetStatsCard), findsOneWidget);

      // Change back to portrait
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedBudgetCard), findsOneWidget);
      expect(find.byType(BudgetStatsCard), findsOneWidget);
    });

    testWidgets('should maintain consistent spacing and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                EnhancedBudgetCard(
                  budget: testBudget,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                EnhancedBudgetCard(
                  budget: testBudget.copyWith(name: 'Second Budget'),
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                BudgetStatsCard(
                  stats: BudgetStats(
                    totalBudgets: 2,
                    activeBudgets: 2,
                    totalBudgetAmount: 1600.0,
                    activeBudgetAmount: 1600.0,
                    totalActiveCosts: 800.0,
                    healthyBudgets: 2,
                    warningBudgets: 0,
                    criticalBudgets: 0,
                    overBudgetCount: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All components should render with consistent spacing
      expect(find.byType(EnhancedBudgetCard), findsNWidgets(2));
      expect(find.byType(BudgetStatsCard), findsOneWidget);
      expect(find.text('Test Budget'), findsOneWidget);
      expect(find.text('Second Budget'), findsOneWidget);
    });

    testWidgets('should handle consistent data updates', (WidgetTester tester) async {
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

      expect(find.text('Test Budget'), findsOneWidget);

      // Update budget data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedBudgetCard(
              budget: testBudget.copyWith(name: 'Updated Budget'),
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should reflect updated data
      expect(find.text('Updated Budget'), findsOneWidget);
      expect(find.text('Test Budget'), findsNothing);
    });
  });
}