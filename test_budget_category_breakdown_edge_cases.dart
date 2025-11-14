import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/budget_category_breakdown_enhanced.dart';
import 'package:budget_tracker/features/transactions/domain/services/category_icon_color_service.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/category_notifier.dart';

// Mock classes
class MockCategoryNotifier extends Mock implements CategoryNotifier {}
class MockCategoryIconColorService extends Mock implements CategoryIconColorService {}

void main() {
  group('BudgetCategoryBreakdownEnhanced Edge Cases', () {
    late MockCategoryNotifier mockCategoryNotifier;
    late MockCategoryIconColorService mockCategoryIconColorService;

    setUp(() {
      mockCategoryNotifier = MockCategoryNotifier();
      mockCategoryIconColorService = MockCategoryIconColorService();
    });

    testWidgets('handles zero spending gracefully', (WidgetTester tester) async {
      // Create budget with zero spending
      final budget = Budget(
        id: 'test',
        name: 'Test Budget',
        type: BudgetType.custom,
        categories: [
          BudgetCategory(
            id: 'cat1',
            name: 'Category 1',
            amount: 100.0,
          ),
        ],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        budget: budget,
        totalBudget: 100.0,
        totalSpent: 0.0,
        categoryStatuses: [
          CategoryStatus(
            categoryId: 'cat1',
            spent: 0.0,
            budget: 100.0,
            percentage: 0.0,
            status: BudgetHealth.healthy,
          ),
        ],
        daysRemaining: 30,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: budget,
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      // Should not crash and should render
      await tester.pumpAndSettle();
      expect(find.text('Category Breakdown'), findsOneWidget);
      expect(find.text('0 categories'), findsNothing); // Should have 1 category
    });

    testWidgets('handles zero budget gracefully', (WidgetTester tester) async {
      final budget = Budget(
        id: 'test',
        name: 'Test Budget',
        categories: [
          BudgetCategory(
            id: 'cat1',
            name: 'Category 1',
            amount: 0.0,
          ),
        ],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        totalBudget: 0.0,
        totalSpent: 50.0,
        categoryStatuses: [
          CategoryStatus(
            categoryId: 'cat1',
            spent: 50.0,
            budget: 0.0,
            status: BudgetStatusEnum.overBudget,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: budget,
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Category Breakdown'), findsOneWidget);
    });

    testWidgets('handles empty categories gracefully', (WidgetTester tester) async {
      final budget = Budget(
        id: 'test',
        name: 'Test Budget',
        categories: [],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        totalBudget: 100.0,
        totalSpent: 0.0,
        categoryStatuses: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: budget,
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('No spending data available'), findsOneWidget);
    });

    testWidgets('handles corrupted data gracefully', (WidgetTester tester) async {
      final budget = Budget(
        id: 'test',
        name: 'Test Budget',
        categories: [
          BudgetCategory(
            id: 'cat1',
            name: 'Category 1',
            amount: double.nan,
          ),
        ],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        totalBudget: double.nan,
        totalSpent: double.nan,
        categoryStatuses: [
          CategoryStatus(
            categoryId: 'cat1',
            spent: double.nan,
            budget: double.nan,
            status: BudgetStatusEnum.onTrack,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: budget,
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Invalid budget amount data'), findsOneWidget);
    });

    testWidgets('handles null budget gracefully', (WidgetTester tester) async {
      final budgetStatus = BudgetStatus(
        totalBudget: 100.0,
        totalSpent: 50.0,
        categoryStatuses: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: null as Budget, // Force null
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Budget data is missing'), findsOneWidget);
    });

    testWidgets('handles infinite values gracefully', (WidgetTester tester) async {
      final budget = Budget(
        id: 'test',
        name: 'Test Budget',
        categories: [
          BudgetCategory(
            id: 'cat1',
            name: 'Category 1',
            amount: double.infinity,
          ),
        ],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        totalBudget: double.infinity,
        totalSpent: double.infinity,
        categoryStatuses: [
          CategoryStatus(
            categoryId: 'cat1',
            spent: double.infinity,
            budget: double.infinity,
            status: BudgetStatusEnum.onTrack,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: budget,
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Invalid budget amount data'), findsOneWidget);
    });

    testWidgets('handles negative values gracefully', (WidgetTester tester) async {
      final budget = Budget(
        id: 'test',
        name: 'Test Budget',
        categories: [
          BudgetCategory(
            id: 'cat1',
            name: 'Category 1',
            amount: -100.0,
          ),
        ],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        totalBudget: -100.0,
        totalSpent: -50.0,
        categoryStatuses: [
          CategoryStatus(
            categoryId: 'cat1',
            spent: -50.0,
            budget: -100.0,
            status: BudgetStatusEnum.onTrack,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: budget,
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Category Breakdown'), findsOneWidget);
      // Negative values should be clamped to 0
    });

    testWidgets('handles very large numbers gracefully', (WidgetTester tester) async {
      final budget = Budget(
        id: 'test',
        name: 'Test Budget',
        categories: [
          BudgetCategory(
            id: 'cat1',
            name: 'Category 1',
            amount: 1e15,
          ),
        ],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        totalBudget: 1e15,
        totalSpent: 5e14,
        categoryStatuses: [
          CategoryStatus(
            categoryId: 'cat1',
            spent: 5e14,
            budget: 1e15,
            status: BudgetStatusEnum.onTrack,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: budget,
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Category Breakdown'), findsOneWidget);
    });

    testWidgets('handles percentage calculations correctly', (WidgetTester tester) async {
      final budget = Budget(
        id: 'test',
        name: 'Test Budget',
        categories: [
          BudgetCategory(
            id: 'cat1',
            name: 'Category 1',
            amount: 200.0,
          ),
        ],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        totalBudget: 200.0,
        totalSpent: 50.0,
        categoryStatuses: [
          CategoryStatus(
            categoryId: 'cat1',
            spent: 50.0,
            budget: 200.0,
            status: BudgetStatusEnum.onTrack,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: budget,
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('25%'), findsOneWidget); // 50/200 = 0.25 = 25%
    });

    testWidgets('handles over-budget scenarios correctly', (WidgetTester tester) async {
      final budget = Budget(
        id: 'test',
        name: 'Test Budget',
        categories: [
          BudgetCategory(
            id: 'cat1',
            name: 'Category 1',
            amount: 100.0,
          ),
        ],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      final budgetStatus = BudgetStatus(
        totalBudget: 100.0,
        totalSpent: 150.0,
        categoryStatuses: [
          CategoryStatus(
            categoryId: 'cat1',
            spent: 150.0,
            budget: 100.0,
            status: BudgetStatusEnum.overBudget,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
            categoryIconColorServiceProvider.overrideWithValue(mockCategoryIconColorService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BudgetCategoryBreakdownEnhanced(
                budget: budget,
                budgetStatus: budgetStatus,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Over'), findsOneWidget);
      expect(find.text('150%'), findsOneWidget); // 150/100 = 1.5 = 150%
    });
  });
}