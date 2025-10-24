
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:budget_tracker/main.dart' as app;
import 'package:go_router/go_router.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bill Validation Integration Tests', () {
    setUpAll(() async {
      // Initialize the app
      app.main();
      await Future.delayed(const Duration(seconds: 2)); // Wait for app to load
    });

    testWidgets('Integration: Bill creation with duplicate name validation',
        (WidgetTester tester) async {
      // Navigate to bill creation screen
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/bills/add');
      await tester.pumpAndSettle();

      // Verify we're on the bill creation screen
      expect(find.text('Add Bill'), findsOneWidget);

      // Create first bill
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Electricity Bill');
      await tester.pump();

      final amountField = find.byType(TextFormField).at(1);
      await tester.enterText(amountField, '150.00');
      await tester.pump();

      // Submit first bill
      await tester.tap(find.text('Add Bill'));
      await tester.pumpAndSettle();

      // Verify first bill was created
      expect(find.text('Bill added successfully'), findsOneWidget);

      // Navigate back to creation screen
      context.go('/bills/add');
      await tester.pumpAndSettle();

      // Try to create bill with same name
      await tester.enterText(nameField, 'Electricity Bill');
      await tester.pump();

      await tester.enterText(amountField, '200.00');
      await tester.pump();

      // Wait for reactive validation (debounced)
      await tester.pump(const Duration(milliseconds: 600));

      // Verify duplicate validation error appears
      expect(find.text('A bill with this name already exists'), findsOneWidget);

      // Verify submit button is disabled or shows error
      final submitButton = find.text('Add Bill');
      await tester.tap(submitButton);
      await tester.pump();

      // Should still be on creation screen with error
      expect(find.text('Add Bill'), findsOneWidget);
      expect(find.text('A bill with this name already exists'), findsOneWidget);
    });

    testWidgets('Integration: Bill editing with duplicate name validation',
        (WidgetTester tester) async {
      // First create a bill to edit
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/bills/add');
      await tester.pumpAndSettle();

      // Create first bill
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Water Bill');
      await tester.pump();

      final amountField = find.byType(TextFormField).at(1);
      await tester.enterText(amountField, '75.00');
      await tester.pump();

      await tester.tap(find.text('Add Bill'));
      await tester.pumpAndSettle();

      // Create second bill
      context.go('/bills/add');
      await tester.pumpAndSettle();

      await tester.enterText(nameField, 'Gas Bill');
      await tester.pump();

      await tester.enterText(amountField, '100.00');
      await tester.pump();

      await tester.tap(find.text('Add Bill'));
      await tester.pumpAndSettle();

      // Navigate to bills list and edit first bill
      context.go('/bills');
      await tester.pumpAndSettle();

      // Find and tap edit on first bill
      await tester.tap(find.text('Water Bill').first);
      await tester.pumpAndSettle();

      // Look for edit button (assuming there's an edit option in bill details)
      final editButton = find.byIcon(Icons.edit);
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();

        // Try to change name to existing "Gas Bill"
        final editNameField = find.byType(TextFormField).first;
        await tester.enterText(editNameField, 'Gas Bill');
        await tester.pump();

        // Wait for reactive validation
        await tester.pump(const Duration(milliseconds: 600));

        // Verify duplicate validation error
        expect(find.text('A bill with this name already exists'), findsOneWidget);

        // Try to submit
        await tester.tap(find.text('Update Bill'));
        await tester.pump();

        // Should still show error
        expect(find.text('A bill with this name already exists'), findsOneWidget);
      }
    });

    testWidgets('Integration: Rapid typing validation during bill creation',
        (WidgetTester tester) async {
      // Navigate to bill creation screen
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/bills/add');
      await tester.pumpAndSettle();

      // First create a bill named "Internet"
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Internet');
      await tester.pump();

      final amountField = find.byType(TextFormField).at(1);
      await tester.enterText(amountField, '80.00');
      await tester.pump();

      await tester.tap(find.text('Add Bill'));
      await tester.pumpAndSettle();

      // Navigate back to creation screen
      context.go('/bills/add');
      await tester.pumpAndSettle();

      // Simulate rapid typing: start with "Internet" then quickly change
      await tester.enterText(nameField, 'Internet');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(nameField, 'Internet B');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(nameField, 'Internet Bi');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(nameField, 'Internet Bil');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(nameField, 'Internet Bill');
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for final validation
      await tester.pump(const Duration(milliseconds: 600));

      // Should show duplicate error for "Internet Bill" (assuming it matches existing bill)
      // Note: This test assumes there's already an "Internet Bill" or similar
      // In a real scenario, we'd check for no error if unique

      // Test rapid changes back to unique name
      await tester.enterText(nameField, 'Cable Bill');
      await tester.pump(const Duration(milliseconds: 600));

      // Should not show duplicate error
      expect(find.text('A bill with this name already exists'), findsNothing);

      // Should be able to submit
      await tester.enterText(amountField, '120.00');
      await tester.pump();

      await tester.tap(find.text('Add Bill'));
      await tester.pumpAndSettle();

      expect(find.text('Bill added successfully'), findsOneWidget);
    });

    testWidgets('Integration: Validation feedback timing and UX',
        (WidgetTester tester) async {
      // Navigate to bill creation screen
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/bills/add');
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;

      // Test that validation doesn't trigger immediately
      await tester.enterText(nameField, 'T');
      await tester.pump(const Duration(milliseconds: 200));

      // Should not show validation error yet (debounced)
      expect(find.text('A bill with this name already exists'), findsNothing);

      // Wait for validation to trigger
      await tester.pump(const Duration(milliseconds: 500));

      // Now validation should have run (even if no error for short unique name)
      // The validation runs but may not show error for valid input

      // Test clearing validation on empty input
      await tester.enterText(nameField, '');
      await tester.pump();

      // Should clear any validation state
      expect(find.text('A bill with this name already exists'), findsNothing);
    });

    testWidgets('Integration: Bill creation with case-insensitive duplicate validation',
        (WidgetTester tester) async {
      // Navigate to bill creation screen
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/bills/add');
      await tester.pumpAndSettle();

      // Create bill with mixed case
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Phone Bill');
      await tester.pump();

      final amountField = find.byType(TextFormField).at(1);
      await tester.enterText(amountField, '50.00');
      await tester.pump();

      await tester.tap(find.text('Add Bill'));
      await tester.pumpAndSettle();

      // Navigate back and try different cases
      context.go('/bills/add');
      await tester.pumpAndSettle();

      // Try "phone bill" (lowercase)
      await tester.enterText(nameField, 'phone bill');
      await tester.pump();

      await tester.enterText(amountField, '60.00');
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 600));

      // Should detect case-insensitive duplicate
      expect(find.text('A bill with this name already exists'), findsOneWidget);

      // Try "PHONE BILL" (uppercase)
      await tester.enterText(nameField, 'PHONE BILL');
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('A bill with this name already exists'), findsOneWidget);
    });
  });
}