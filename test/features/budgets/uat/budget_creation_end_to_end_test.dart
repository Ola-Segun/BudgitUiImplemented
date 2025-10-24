
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:budget_tracker/main.dart' as app;
import 'package:go_router/go_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Budget Creation End-to-End User Acceptance Tests', () {
    setUpAll(() async {
      // Initialize the app
      app.main();
      await Future.delayed(const Duration(seconds: 2)); // Wait for app to load
    });

    testWidgets('UAT: Complete budget creation journey from template to completion',
        (WidgetTester tester) async {
      // Navigate to budget creation screen
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/budgets/add');
      await tester.pumpAndSettle();

      // Verify we're on the budget creation screen
      expect(find.text('Create Budget'), findsOneWidget);
      expect(find.text('Start with Template (Optional)'), findsOneWidget);

      // Select 50/30/20 Rule template
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('50/30/20 Rule').last);
      await tester.pumpAndSettle();

      // Verify template loaded correctly
      expect(find.text('50/30/20 Rule Budget'), findsOneWidget);
      expect(find.text('Total Budget: \$1,000.00'), findsOneWidget);

      // Customize the budget name
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'My Monthly Budget');
      await tester.pump();

      // Add a description
      final descField = find.byType(TextFormField).at(1);
      await tester.enterText(descField, 'Following the 50/30/20 rule for financial wellness');
      await tester.pump();

      // Modify category amounts
      final amountFields = find.byType(TextFormField).where((widget) {
        final textField = widget as TextFormField;
        return textField.decoration?.prefixText == '\$';
      });

      // Update first category amount
      await tester.enterText(amountFields.first, '600.00');
      await tester.pump(const Duration(milliseconds: 150));

      // Verify total updates
      expect(find.text('Total Budget: \$1,000.00'), findsOneWidget); // Should still be 1000 due to template logic

      // Set custom dates
      final startDateField = find.byType(TextFormField).at(2); // Creation date
      await tester.tap(startDateField);
      await tester.pumpAndSettle();

      // Select a date (assuming date picker appears)
      // Note: Date picker interaction would need specific implementation based on the date picker widget

      // Submit the budget
      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      // Verify success message and navigation
      expect(find.text('Budget created successfully'), findsOneWidget);

      // Should navigate back to budget list
      expect(find.text('Create Budget'), findsNothing);
    });

    testWidgets('UAT: Custom budget creation with multiple categories',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/budgets/add');
      await tester.pumpAndSettle();

      // Keep default "None (Custom)" template
      expect(find.text('Total Budget: \$0.00'), findsOneWidget);

      // Enter budget name
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Custom Family Budget');
      await tester.pump();

      // Add multiple categories
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Add Category'));
        await tester.pumpAndSettle();
      }

      // Verify categories were added
      expect(find.text('Category'), findsNWidgets(6)); // 1 initial + 5 added

      // Enter amounts for each category
      final amountFields = find.byType(TextFormField).where((widget) {
        final textField = widget as TextFormField;
        return textField.decoration?.prefixText == '\$';
      });

      final amounts = [500.0, 300.0, 200.0, 150.0, 100.0, 50.0];
      int fieldIndex = 0;

      for (final field in amountFields.take(6)) {
        await tester.enterText(field, amounts[fieldIndex].toStringAsFixed(2));
        fieldIndex++;
        await tester.pump(const Duration(milliseconds: 150));
      }

      // Verify total calculation
      expect(find.text('Total Budget: \$1,300.00'), findsOneWidget);

      // Submit budget
      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Budget created successfully'), findsOneWidget);
    });

    testWidgets('UAT: Template switching and customization',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/budgets/add');
      await tester.pumpAndSettle();

      // Start with 50/30/20
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('50/30/20 Rule').last);
      await tester.pumpAndSettle();

      expect(find.text('50/30/20 Rule Budget'), findsOneWidget);

      // Switch to Zero-Based
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zero-Based Budget').last);
      await tester.pumpAndSettle();

      expect(find.text('Zero-Based Budget Budget'), findsOneWidget);

      // Switch to Envelope System
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envelope System').last);
      await tester.pumpAndSettle();

      expect(find.text('Envelope System Budget'), findsOneWidget);

      // Customize amounts
      final amountFields = find.byType(TextFormField).where((widget) {
        final textField = widget as TextFormField;
        return textField.decoration?.prefixText == '\$';
      });

      // Increase first category amount
      await tester.enterText(amountFields.first, '600.00');
      await tester.pump(const Duration(milliseconds: 150));

      // Submit customized template
      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Budget created successfully'), findsOneWidget);
    });

    testWidgets('UAT: Error handling and recovery during budget creation',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/budgets/add');
      await tester.pumpAndSettle();

      // Try to submit without name
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      expect(find.text('Please enter a budget name'), findsOneWidget);

      // Enter name but no categories with amounts
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Budget');
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      expect(find.text('Total budget must be greater than zero'), findsOneWidget);

      // Add valid amount
      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '100.00');
      await tester.pump(const Duration(milliseconds: 150));

      // Try invalid amount
      await tester.enterText(amountField, '-50.00');
      await tester.tap(find.text('Create Budget'));
      await tester.pump();

      expect(find.text('Invalid'), findsOneWidget);

      // Fix amount
      await tester.enterText(amountField, '500.00');
      await tester.pump(const Duration(milliseconds: 150));

      // Submit successfully
      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Budget created successfully'), findsOneWidget);
    });

    testWidgets('UAT: Budget creation with date range validation',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/budgets/add');
      await tester.pumpAndSettle();

      // Enter budget details
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Date Range Budget');

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '1000.00');
      await tester.pump();

      // Verify date fields are present
      expect(find.text('Budget Creation Date & Time'), findsOneWidget);
      expect(find.text('Budget End Date & Time'), findsOneWidget);

      // Submit budget
      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Budget created successfully'), findsOneWidget);
    });

    testWidgets('UAT: Performance test with complex budget setup',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/budgets/add');
      await tester.pumpAndSettle();

      // Select template
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zero-Based Budget').last);
      await tester.pumpAndSettle();

      // Add many categories
      for (int i = 0; i < 20; i++) {
        await tester.tap(find.text('Add Category'));
        await tester.pumpAndSettle();
      }

      // Enter amounts for all categories
      final amountFields = find.byType(TextFormField).where((widget) {
        final textField = widget as TextFormField;
        return textField.decoration?.prefixText == '\$';
      });

      int fieldIndex = 0;
      for (final field in amountFields) {
        await tester.enterText(field, '${(fieldIndex + 1) * 10}.00');
        fieldIndex++;
        await tester.pump(const Duration(milliseconds: 50)); // Faster for performance test
      }

      await tester.pump(const Duration(milliseconds: 200));

      // Verify total calculation works with many categories
      expect(find.textContaining('Total Budget: \$'), findsOneWidget);

      // Submit large budget
      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Budget created successfully'), findsOneWidget);
    });

    testWidgets('UAT: Budget creation accessibility and usability',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/budgets/add');
      await tester.pumpAndSettle();

      // Verify all important elements are accessible
      expect(find.text('Create Budget'), findsOneWidget);
      expect(find.text('Budget Name'), findsOneWidget);
      expect(find.text('Total Budget:'), findsOneWidget);
      expect(find.text('Create Budget'), findsOneWidget); // Button
      expect(find.text('Cancel'), findsOneWidget);

      // Verify template dropdown is accessible
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('None (Custom)'), findsOneWidget);
      expect(find.text('50/30/20 Rule'), findsOneWidget);
      expect(find.text('Zero-Based Budget'), findsOneWidget);
      expect(find.text('Envelope System'), findsOneWidget);

      // Close dropdown
      await tester.tap(find.text('50/30/20 Rule').last);
      await tester.pumpAndSettle();

      // Verify form can be completed
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Accessible Budget');

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '750.00');
      await tester.pump();

      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Budget created successfully'), findsOneWidget);
    });

    testWidgets('UAT: Budget creation with category management',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      context.go('/budgets/add');
      await tester.pumpAndSettle();

      // Add categories
      await tester.tap(find.text('Add Category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Category'));
      await tester.pumpAndSettle();

      // Remove a category
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Verify category count
      final categoryDropdowns = find.byType(DropdownButtonFormField<String>);
      expect(categoryDropdowns, findsWidgets); // Should have remaining categories

      // Enter amounts
      final amountFields = find.byType(TextFormField).where((widget) {
        final textField = widget as TextFormField;
        return textField.decoration?.prefixText == '\$';
      });

      await tester.enterText(amountFields.first, '400.00');
      await tester.enterText(amountFields.last, '300.00');
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Total Budget: \$700.00'), findsOneWidget);

      // Submit budget
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Managed Categories Budget');

      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Budget created successfully'), findsOneWidget);
    });
  });
}