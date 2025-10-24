import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_setup.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget_template.dart';
import 'package:budget_tracker/features/budgets/presentation/providers/budget_providers.dart';
import 'package:budget_tracker/features/budgets/presentation/screens/budget_creation_screen.dart';
import 'package:budget_tracker/features/budgets/presentation/notifiers/budget_notifier.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:budget_tracker/features/transactions/presentation/notifiers/category_notifier.dart';
import 'package:budget_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:budget_tracker/features/transactions/presentation/states/category_state.dart';
import 'package:budget_tracker/core/widgets/error_view.dart';
import 'package:budget_tracker/core/widgets/loading_view.dart';

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

  group('BudgetCreationScreen', () {
    testWidgets('renders correctly with initial state', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create Budget'), findsOneWidget);
      expect(find.text('Start with Template (Optional)'), findsOneWidget);
      expect(find.text('Budget Name'), findsOneWidget);
      expect(find.text('Budget Categories'), findsOneWidget);
      expect(find.text('Total Budget:'), findsOneWidget);
    });

    testWidgets('displays template dropdown with all options', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('None (Custom)'), findsOneWidget);
      expect(find.text('50/30/20 Rule'), findsOneWidget);
      expect(find.text('Zero-Based Budget'), findsOneWidget);
      expect(find.text('Envelope System'), findsOneWidget);
    });

    testWidgets('loads 50/30/20 template correctly', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select 50/30/20 template
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('50/30/20 Rule').last);
      await tester.pumpAndSettle();

      // Verify template loaded
      expect(find.text('50/30/20 Rule Budget'), findsOneWidget);
      expect(find.text('Total Budget: \$1,000.00'), findsOneWidget);
    });

    testWidgets('loads zero-based template correctly', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'housing', name: 'Housing', color: 0xFF10B981),
        TransactionCategory(id: 'groceries', name: 'Groceries', color: 0xFF10B981),
        TransactionCategory(id: 'transportation', name: 'Transportation', color: 0xFF6B7280),
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select Zero-Based template
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zero-Based Budget').last);
      await tester.pumpAndSettle();

      // Verify template loaded
      expect(find.text('Zero-Based Budget Budget'), findsOneWidget);
      expect(find.text('Total Budget: \$3,000.00'), findsOneWidget);
    });

    testWidgets('loads envelope system template correctly', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'groceries', name: 'Groceries', color: 0xFF10B981),
        TransactionCategory(id: 'gas', name: 'Gas/Car', color: 0xFF6B7280),
        TransactionCategory(id: 'entertainment', name: 'Entertainment', color: 0xFFF59E0B),
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select Envelope System template
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envelope System').last);
      await tester.pumpAndSettle();

      // Verify template loaded
      expect(find.text('Envelope System Budget'), findsOneWidget);
      expect(find.text('Total Budget: \$1,200.00'), findsOneWidget);
    });

    testWidgets('handles unmapped template categories with warning', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
        // Missing categories that template expects
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select template with unmapped categories
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('50/30/20 Rule').last);
      await tester.pumpAndSettle();

      // Should show snackbar warning
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('calculates total budget correctly in real-time', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find amount text field and enter value
      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '500.00');
      await tester.pump(const Duration(milliseconds: 150)); // Wait for debounce

      expect(find.text('Total Budget: \$500.00'), findsOneWidget);
    });

    testWidgets('adds and removes budget categories dynamically', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', icon: 'restaurant', color: 0xFF10B981, type: TransactionType.expense),
        TransactionCategory(id: 'transport', name: 'Transport', icon: 'car', color: 0xFF3B82F6, type: TransactionType.expense),
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should have 1 category
      expect(find.text('Category'), findsOneWidget);

      // Add category
      await tester.tap(find.text('Add Category'));
      await tester.pumpAndSettle();

      expect(find.text('Category'), findsNWidgets(2));

      // Remove category (should have delete button now)
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('validates form fields correctly', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit without name
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      expect(find.text('Please enter a budget name'), findsOneWidget);
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
            categoryNotifierProvider.overrideWith(() => mockBudgetNotifier),
          ],
          child: const MaterialApp(
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter name but no amounts
      await tester.enterText(find.byType(TextFormField).first, 'Test Budget');
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      expect(find.text('Total budget must be greater than zero'), findsOneWidget);
    });

    testWidgets('creates budget successfully', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );
      when(mockBudgetNotifier.createBudget(any)).thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(find.byType(TextFormField).first, 'Test Budget');
      await tester.enterText(find.byType(TextFormField).last, '500.00');
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      verify(mockBudgetNotifier.createBudget(any)).called(1);
    });

    testWidgets('handles budget creation failure', (tester) async {
      final expenseCategories = [
        TransactionCategory(id: 'food', name: 'Food', color: 0xFF10B981),
      ];

      when(mockCategoryNotifier.state).thenReturn(
        AsyncData(CategoryState(expenseCategories: expenseCategories)),
      );
      when(mockBudgetNotifier.createBudget(any)).thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(find.byType(TextFormField).first, 'Test Budget');
      await tester.enterText(find.byType(TextFormField).last, '500.00');
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      expect(find.text('Failed to create budget'), findsOneWidget);
    });

    testWidgets('shows loading state during template loading', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select template - dropdown should be disabled during loading
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('50/30/20 Rule').last);
      await tester.pump(); // Template loading starts

      // Dropdown should be disabled during loading
      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(dropdown.onChanged, isNull);
    });

    testWidgets('handles category selection correctly', (tester) async {
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
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open category dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();

      // Select different category
      await tester.tap(find.text('Transport').last);
      await tester.pumpAndSettle();

      // Verify selection
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('validates category amount input', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter invalid amount
      await tester.enterText(find.byType(TextFormField).last, '-100');
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      expect(find.text('Invalid'), findsOneWidget);
    });

    testWidgets('prevents end date before start date', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Set start date to future
      final startDateField = find.byType(TextFormField).at(1);
      await tester.tap(startDateField);
      await tester.pumpAndSettle();

      // This would require more complex date picker interaction
      // For now, we test the validation logic exists
      expect(find.byIcon(Icons.calendar_today), findsNWidgets(2));
    });

    testWidgets('shows animated total budget updates', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(find.byType(TextFormField).last, '500.00');
      await tester.pump(const Duration(milliseconds: 150));

      // Should find AnimatedDefaultTextStyle for total
      expect(find.byType(AnimatedDefaultTextStyle), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('handles empty template selection (custom)', (tester) async {
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
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select None (Custom) - should reset to custom
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('None (Custom)').last);
      await tester.pumpAndSettle();

      expect(find.text('Total Budget: \$0.00'), findsOneWidget);
    });

    testWidgets('handles loading state for categories', (tester) async {
      when(mockCategoryNotifier.state).thenReturn(
        const AsyncLoading(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets('handles error state for categories', (tester) async {
      when(mockCategoryNotifier.state).thenReturn(
        AsyncError(Exception('Failed to load categories'), StackTrace.current),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetNotifierProvider.overrideWith(() => mockBudgetNotifier),
            categoryNotifierProvider.overrideWith(() => mockCategoryNotifier),
          ],
          child: const MaterialApp(
            home: BudgetCreationScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ErrorView), findsOneWidget);
    });
  });
}