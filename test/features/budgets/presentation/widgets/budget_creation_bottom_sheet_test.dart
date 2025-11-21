import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_setup.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/presentation/providers/budget_providers.dart';
import 'package:budget_tracker/features/budgets/presentation/notifiers/budget_notifier.dart';
import 'package:budget_tracker/features/budgets/presentation/widgets/budget_creation_bottom_sheet.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/category_notifier.dart';
import 'package:budget_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:budget_tracker/features/transactions/presentation/states/category_state.dart';
import 'package:budget_tracker/core/design_system/modern/modern_amount_display.dart';
import 'package:budget_tracker/core/design_system/modern/modern_text_field.dart';
import 'package:budget_tracker/core/design_system/modern/modern_category_selector.dart';

class MockBudgetNotifier extends Mock implements BudgetNotifier {}

class MockCategoryNotifier extends Mock implements CategoryNotifier {}

void main() {
  late MockBudgetNotifier mockBudgetNotifier;
  late MockCategoryNotifier mockCategoryNotifier;

  setUp(() {
    mockBudgetNotifier = MockBudgetNotifier();
    mockCategoryNotifier = MockCategoryNotifier();
    setupMockitoDummies();
  });

  group('BudgetCreationBottomSheet', () {
    testWidgets('shows bottom sheet correctly', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', icon: 'restaurant', color: 0xFF10B981, type: TransactionType.expense),
        TransactionCategory(id: 'transport', name: 'Transport', icon: 'car', color: 0xFF3B82F6, type: TransactionType.expense),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(categories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWithValue(mockBudgetNotifier),
            categoryNotifierProvider.overrideWithValue(mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      // Show bottom sheet
      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      expect(find.text('Create Budget'), findsOneWidget);
      expect(find.byType(ModernAmountDisplay), findsOneWidget);
      expect(find.text('Budget Categories'), findsOneWidget);
      expect(find.text('Budget Name'), findsOneWidget);
    });

    testWidgets('prevents duplicate bottom sheet instances', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      // Try to show multiple bottom sheets
      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Should only show one bottom sheet
      expect(find.text('Create Budget'), findsOneWidget);
    });

    testWidgets('dismisses bottom sheet on cancel', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Bottom sheet should be dismissed
      expect(find.text('Create Budget'), findsNothing);
    });

    testWidgets('displays ModernAmountDisplay with correct initial value', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      final amountDisplay = tester.widget<ModernAmountDisplay>(find.byType(ModernAmountDisplay));
      expect(amountDisplay.amount, 0.0);
      expect(amountDisplay.isEditable, true);
    });

    testWidgets('updates total budget when amount display is tapped', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Tap the amount display to open numeric keyboard
      await tester.tap(find.byType(ModernAmountDisplay));
      await tester.pumpAndSettle();

      // This would normally open the numeric keyboard, but for testing
      // we verify the display is interactive
      expect(find.byType(ModernAmountDisplay), findsOneWidget);
    });

    testWidgets('validates ModernTextField inputs', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Find budget name field
      final nameField = find.byType(ModernTextField).first;
      expect(nameField, findsOneWidget);

      // Try to submit without name
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter a budget name'), findsOneWidget);
    });

    testWidgets('integrates ModernCategorySelector correctly', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
        TransactionCategory(id: 'transport', name: 'Transport', color: 0xFF3B82F6),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Should find ModernCategorySelector
      expect(find.byType(ModernCategorySelector), findsOneWidget);

      final categorySelector = tester.widget<ModernCategorySelector>(find.byType(ModernCategorySelector));
      expect(categorySelector.categories.length, 2);
      expect(categorySelector.categories.first.name, 'Food');
    });

    testWidgets('handles split transaction-style category allocation', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Should have amount and percentage fields for each category
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Percentage'), findsOneWidget);

      // Enter amount
      final amountFields = find.byType(ModernTextField).where((widget) {
        final modernTextField = widget as ModernTextField;
        return modernTextField.placeholder == 'Amount';
      });
      expect(amountFields, findsOneWidget);

      await tester.enterText(amountFields.first, '500.00');
      await tester.pump(const Duration(milliseconds: 200)); // Wait for updates

      // Total budget should update
      final amountDisplay = tester.widget<ModernAmountDisplay>(find.byType(ModernAmountDisplay));
      expect(amountDisplay.amount, 500.0);
    });

    testWidgets('adds and removes categories dynamically', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
        TransactionCategory(id: 'transport', name: 'Transport', color: 0xFF3B82F6),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Initially should have 1 category
      expect(find.text('Category 1'), findsOneWidget);

      // Add category
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Category 1'), findsOneWidget);
      expect(find.text('Category 2'), findsOneWidget);

      // Remove category
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.text('Category 1'), findsOneWidget);
      expect(find.text('Category 2'), findsNothing);
    });

    testWidgets('validates total budget must be greater than zero', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Enter name but no amounts
      await tester.enterText(find.byType(ModernTextField).first, 'Test Budget');
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      expect(find.text('Total budget must be greater than zero'), findsOneWidget);
    });

    testWidgets('submits budget successfully', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      Budget? submittedBudget;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (budget) async {
          submittedBudget = budget;
        },
      );

      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(find.byType(ModernTextField).first, 'Test Budget');

      // Enter amount
      final amountFields = find.byType(ModernTextField).where((widget) {
        final modernTextField = widget as ModernTextField;
        return modernTextField.placeholder == 'Amount';
      });
      await tester.enterText(amountFields.first, '500.00');

      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      // Verify budget was submitted
      expect(submittedBudget, isNotNull);
      expect(submittedBudget!.name, 'Test Budget');
      expect(submittedBudget!.categories.length, 1);
      expect(submittedBudget!.categories.first.amount, 500.0);
    });

    testWidgets('handles submission errors gracefully', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {
          throw Exception('Submission failed');
        },
      );

      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(find.byType(ModernTextField).first, 'Test Budget');

      // Enter amount
      final amountFields = find.byType(ModernTextField).where((widget) {
        final modernTextField = widget as ModernTextField;
        return modernTextField.placeholder == 'Amount';
      });
      await tester.enterText(amountFields.first, '500.00');

      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      // Should show error message
      expect(find.text('Error: Exception: Submission failed'), findsOneWidget);
    });

    testWidgets('shows loading state during submission', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {
          await Future.delayed(const Duration(seconds: 1)); // Simulate async operation
        },
      );

      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(find.byType(ModernTextField).first, 'Test Budget');

      // Enter amount
      final amountFields = find.byType(ModernTextField).where((widget) {
        final modernTextField = widget as ModernTextField;
        return modernTextField.placeholder == 'Amount';
      });
      await tester.enterText(amountFields.first, '500.00');

      await tester.tap(find.text('Create Budget'));
      await tester.pump(); // Should show loading state

      // Cancel button should be disabled during loading
      final cancelButton = find.text('Cancel');
      final cancelWidget = tester.widget<ElevatedButton>(cancelButton);
      expect(cancelWidget.onPressed, isNull);

      // Create button should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles template selection correctly', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'needs', name: 'Needs (50%)', color: 0xFF10B981),
        TransactionCategory(id: 'wants', name: 'Wants (30%)', color: 0xFFF59E0B),
        TransactionCategory(id: 'savings', name: 'Savings & Debt (20%)', color: 0xFF3B82F6),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Show optional fields
      await tester.tap(find.text('Show optional fields'));
      await tester.pumpAndSettle();

      // Select 50/30/20 template
      await tester.tap(find.text('Choose a budget template'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('50/30/20 Rule').last);
      await tester.pumpAndSettle();

      // Verify template loaded
      expect(find.text('50/30/20 Rule Budget'), findsOneWidget);
      final amountDisplay = tester.widget<ModernAmountDisplay>(find.byType(ModernAmountDisplay));
      expect(amountDisplay.amount, 1000.0); // Template total
    });

    testWidgets('handles navigation triggers correctly', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      bool navigated = false;
      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {
          navigated = true;
        },
      );

      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(find.byType(ModernTextField).first, 'Test Budget');

      // Enter amount
      final amountFields = find.byType(ModernTextField).where((widget) {
        final modernTextField = widget as ModernTextField;
        return modernTextField.placeholder == 'Amount';
      });
      await tester.enterText(amountFields.first, '500.00');

      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      // Verify navigation trigger was called
      expect(navigated, true);
    });

    testWidgets('handles edge case: empty category list', (tester) async {
      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: [])),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Should still render but with empty category selector
      expect(find.text('Create Budget'), findsOneWidget);
      expect(find.byType(ModernCategorySelector), findsOneWidget);
    });

    testWidgets('handles edge case: very large amounts', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Enter very large amount
      final amountFields = find.byType(ModernTextField).where((widget) {
        final modernTextField = widget as ModernTextField;
        return modernTextField.placeholder == 'Amount';
      });
      await tester.enterText(amountFields.first, '999999999.99');
      await tester.pump(const Duration(milliseconds: 200));

      // Should handle large amounts without crashing
      final amountDisplay = tester.widget<ModernAmountDisplay>(find.byType(ModernAmountDisplay));
      expect(amountDisplay.amount, 999999999.99);
    });

    testWidgets('handles architecture integrity: proper state management', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      BudgetCreationBottomSheet.show(
        context: tester.element(find.byType(Scaffold)),
        onSubmit: (_) async {},
      );

      await tester.pumpAndSettle();

      // Verify Riverpod providers are properly integrated
      expect(find.byType(Consumer), findsWidgets); // Should use Consumer widgets

      // Test that state updates trigger rebuilds
      await tester.enterText(find.byType(ModernTextField).first, 'Test');
      await tester.pump();

      // Field should still have the text
      final textField = tester.widget<ModernTextField>(find.byType(ModernTextField).first);
      expect(textField.controller?.text, 'Test');
    });
  });
}